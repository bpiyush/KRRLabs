# Necessary libraries that will be employed
import itertools
from copy import deepcopy
from dataclasses import dataclass
from typing import List

from sudoku_func import *

#!{sys.executable} -m pip install clingo
#!{sys.executable} -m pip install python-sat
import clingo
import pysat
from pysat.formula import CNF
from pysat.solvers import MinisatGH


program = \
"""

% define all constants
#const k=3.
#const m=10.

% define all variables
row(1..k*k).
col(1..k*k).
value(1..k*k).

% define cell of the board
cell(I, J) :- row(I), col(J).

% let assign(I, J, V) denote the assignment of value V to cell (I, J)

% every cell should be assigned exactly 1 value
1 { assign(I, J, V): value(V) } 1 :- cell(I, J).

% every row should have different values
:- assign(I, J, V), assign(I', J, V), I!=I'.

% every column should have different values
:- assign(I, J, V), assign(I, J', V), J!=J'.

% no two values in a single *block* should be the same
:- assign(I, J, V), assign(I', J', V), J!=J', I!=I', (I - 1)/k==(I' - 1)/k, (J - 1)/k==(J' - 1)/k.

% no two adjacent neighbors should have the same value
same_cell(I, J, I', J') :- cell(I, J), cell(I', J'), I==I', J==J'.
is_adjacent(I, I') :- row(I), row(I'), (I - I') <= 1, (I - I') >= -1.
adjacent_neighbors(I, J, I', J') :- cell(I,J), cell(I',J'), 
                                    is_adjacent(I, I'), is_adjacent(J, J'),
                                    not same_cell(I, J, I', J').
:- assign(I, J, V), assign(I', J', V), adjacent_neighbors(I, J, I', J').

% knights constraint
valid_cell(I, J):- cell(I, J), I >= 1, J <= k*k.
knight_attacked(I, J, I', J') :- cell(I, J), cell(I', J'),
                                 I' - I >= -2, I' - I <= 2, I!=I',
                                 J' - J >= -2, J' - J <= 2, J!=J',
                                 I' - I != J'-J, I' - I != J - J'.
:- assign(I, J, V), assign(I', J', V), valid_cell(I, J), valid_cell(I', J'), knight_attacked(I, J, I', J').

%% Saturation part begins here

% filter out all assignments with only m number of values
m {shown_assign(I,J,V): assign(I, J, V)} m.

% Use saturation to express that there is no other solution different from the
% current one that satisfies the constraints

% generate the space of all counterexaamples
other_assign(I, J, V) : value(V) :- cell(I, J).

% if the counterexample does not agree with the shown assignment, then saturate
saturate :- other_assign(I, J, V1), shown_assign(I, J, V2), V1 != V2.

% if the counterexample does not satisfy the puzzle constraints, then saturate
saturate :- other_assign(I, J, V), other_assign(I', J, V), I!=I'.
saturate :- other_assign(I, J, V), other_assign(I, J', V), J!=J'.
saturate :- other_assign(I, J, V), other_assign(I', J', V), J!=J', I!=I', (I - 1)/k==(I' - 1)/k, (J - 1)/k==(J' - 1)/k.
saturate :- other_assign(I, J, V), other_assign(I', J', V), adjacent_neighbors(I, J, I', J').
saturate :- other_assign(I, J, V), other_assign(I', J', V), valid_cell(I', J'), knight_attacked(I, J, I', J').

% if the counterexample is the same as reference solution, then saturate
saturate :- other_assign(I, J, V): assign(I, J, V).

% if saturates, then put all atoms in other_assign
other_assign(I, J, V):- saturate, cell(I, J), value(V).

:- not saturate.
"""


def filter_answer_set(model, convert_to_str=False, verbose=True):
    
    atoms = model.symbols(atoms=True)
    k = 3
    m = 10
    empty_sudoku = [[0 for _ in range(k * k)] for _ in range(k * k)]
    
    # helper functions
    filter_atoms = lambda x: [atom for atom in atoms if atom.name.startswith(x)]

    def fill_sudoku_with_items(sudoku, items, show=False):
        filled_sudoku = deepcopy(sudoku)
        for item in items:
            i, j, v = item.arguments[0].number, item.arguments[1].number, item.arguments[2].number
            filled_sudoku[i-1][j-1] = v
        
        if show:
            print(pretty_repr(filled_sudoku, k=k))

        return filled_sudoku
    
    shown_puzzle = filter_atoms("shown_assign")
    assert len(shown_puzzle) == m
    shown_sudoku = fill_sudoku_with_items(empty_sudoku, shown_puzzle, show=verbose)
    
    assigned_sudoku = filter_atoms("assign")
    assigned_sudoku = fill_sudoku_with_items(empty_sudoku, assigned_sudoku, show=verbose)
    
    return shown_sudoku


def generate(control):
    for model in control.solve(yield_=True):
        shown_sudoku = filter_answer_set(model, convert_to_str=False, verbose=False)
        yield shown_sudoku


control = clingo.Control()
control.add("base", [], program)
control.ground([("base", [])])
control.configuration.solve.models = 0
solutions = generate(control)


if __name__ == "__main__":
    from solve_sudoku_asp import solve_sudoku_ASP
    num_check = 100
    shown_sudokus = []
    for i in range(num_check):
        print("Checking solution {}".format(i))
        x = next(solutions)
        shown_sudokus.append(pretty_repr(x, k=3))
        assert check_num_solutions(sudoku=x, k=3, num_solutions=1, solver=solve_sudoku_ASP)
    
    assert len(set(shown_sudokus)) == num_check
