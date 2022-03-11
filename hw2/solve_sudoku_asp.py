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

from sudoku_func import check_num_solutions


def solve_sudoku_ASP(sudoku, k):
    """
    Solve a sudoku input by encoding the problem into ASP, calling an ASP solver,
    and retrieving the solution for the sudoku input from an answer set given by the ASP solver.

    Parameters:
        sudoku (list(list(int))): An input puzzle.
        k (int): The dimension of the sudoku input.

    Returns:
        A generator using yield instead of returning a (list(list(list(int)))).
    """
    
    constant_definition = f"        #const k={k}.\n"
    program = constant_definition + \
    """

        % define variables
        row(1..k*k).
        col(1..k*k).
        value(1..k*k).

        % define veriable to denote a cell in the sudoku
        cell(I, J) :- row(I), col(J).

        % every cell should be assigned exactly 1 value
        1 { assign(I, J, V): value(V) } 1 :- cell(I, J).

        % every row should have different values
        :- assign(I, J, V), assign(I', J, V), I!=I'.

        % every column should have different values
        :- assign(I, J, V), assign(I, J', V), J!=J'.

        % no two values in a single *block* should be the same
        % note that if (I, J) and (I', J') are two different cells
        % then they lie in the same block iff (I - 1) / k == (I' - 1) / k
        % and likewise for the column
        :- assign(I, J, V), assign(I', J', V), J!=J', I!=I', (I - 1)/k==(I' - 1)/k, (J - 1)/k==(J' - 1)/k.

        % define a predicate that takes in (I, J, I', J') and
        % returns true iff (I, J) and (I', J') are `adjacent_neighbors`
        same_cell(I, J, I', J') :- cell(I, J), cell(I', J'), I==I', J==J'.
        row_diff(I, I') :- row(I), row(I'), (I - I') <= 1, (I - I') >= -1.
        col_diff(I, I') :- col(I), col(I'), (I - I') <= 1, (I - I') >= -1.
        adjacent_neighbors(I, J, I', J') :- cell(I,J), cell(I',J'), row_diff(I, I'), col_diff(J, J'), not same_cell(I, J, I', J').
        % adjacent_neighbors(I, J, I', J') :- cell(I, J), cell(I', J'), (I - I') <= 1, (I - I') >= -1, (J - J') <= 1, (J - J') >= -1, not check_same_cell(I, J, I', J').
        :- assign(I, J, V), assign(I', J', V), adjacent_neighbors(I, J, I', J').

        % knights constraint
        valid_cell(I, J):- cell(I, J), I >= 1, J <= k*k.
        % decides if cell (I, J) is attacked by a knights move by cell (I', J')
        knight_attacked(I, J, I', J') :- cell(I, J), cell(I', J'), I' - I >= -2, I' - I <= 2, I!=I', J' - J >= -2, J' - J <= 2, J!=J', I' - I != J'-J, I' - I != J - J'.
        :- assign(I, J, V), assign(I', J', V), valid_cell(I, J), valid_cell(I', J'), knight_attacked(I, J, I', J').

        % input constraint
    """

    for I in range(len(sudoku)):
        for J in range(len(sudoku)):
            V = sudoku[I][J]
            if V:
                program += f"    :- not assign({I + 1}, {J + 1}, {V}).\n"

    control = clingo.Control()
    control.add("base", [], program)
    control.ground([("base", [])])

    control.configuration.solve.models = 0

    def filter_answer_set(model, convert_to_str=False, verbose=True):

        # get all assignments
        assignments = [atom for atom in model.symbols(atoms=True) if str(atom).startswith("assign")]

        # get all assignments that are positive
        assignments = [atom for atom in assignments if atom.positive]

        if convert_to_str:
            assignments = [str(atom) for atom in assignments]
        else:
            solved_sudoku = deepcopy(sudoku)
            for atom in assignments:
                arguments = atom.arguments
                i, j, v = [x.number for x in arguments]
                solved_sudoku[i - 1][j - 1] = v

            if verbose:
                print("Input:")
                print(pretty_repr(sudoku, k=k))
                print()
                print("Solution:")
                print(pretty_repr(solved_sudoku, k=k))
                print()

        return solved_sudoku

    def generate():
        for model in control.solve(yield_=True):
            solved_sudoku = filter_answer_set(model, convert_to_str=False, verbose=False)
            yield solved_sudoku

    solutions = generate()  
    
    return solutions


def check_soduku_solution(sudoku, k, num_solutions):
    solver = solve_sudoku_ASP(sudoku, k=3)
    check_num_solutions(sudoku, k, num_solutions, solver)


if __name__ == "__main__":
    from sudoku_func import test_inputs
    
    for num, test_input in enumerate(test_inputs, 1):
        print("- Testing on test input #{}".format(num))
        assert check_num_solutions(
            test_input.sudoku,
            test_input.k,
            test_input.num_solutions,
            solve_sudoku_ASP
        ) == True
        print("  Found exactly the set of correct solutions")


