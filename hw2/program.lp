
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
m {shown_asssign(I,J,V): assign(I, J, V)} m.

% Use saturation to express that there is no other solution different from the
% current one that satisfies the constraints

% generate the space of all counterexaamples
other_assign(I, J, V):- cell(I, J), value(V).

% if the counterexample does not agree with the shown assignment, then saturate
saturate :- other_assign(I, J, V1), shown_asssign(I, J, V2), V1 != V2.

% if the counterexample does not satisfy the puzzle constraints, then saturate
saturate :- other_assign(I, J, V), other_assign(I', J, V), I!=I'.
saturate :- other_assign(I, J, V), other_assign(I, J', V), J!=J'.
saturate :- other_assign(I, J, V), other_assign(I', J', V), J!=J', I!=I', (I - 1)/k==(I' - 1)/k, (J - 1)/k==(J' - 1)/k.
saturate :- other_assign(I, J, V), other_assign(I', J', V), adjacent_neighbors(I, J, I', J').
saturate :- other_assign(I, J, V), other_assign(I', J', V'), knight_attacked(I, J, I', J').

% if the counterexample is the same as reference solution, then saturate
saturate :- other_assign(I, J, V), asssign(I, J, V).

% if saturates, then put all atoms in other_assign
other_assign(I, J, V):- saturate, cell(I, J), value(V).

:- not saturate.




% #show assign/3.
#show shown_asssign/3.
% #show other_assign/3.
#show saturate.