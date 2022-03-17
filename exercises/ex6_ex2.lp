
#const k=3.
#const t=40.

row(1..k).
col(1..k).
cell(I, J) :- row(I), col(J).
value(1..(k*k - 1)).

time(1..t).

% fill(T, cell(I, J), V) denotes that cell(I, J) is filled with value V at time T.
% initial configuration
% fill(1, cell(I, J), 0) :- row(I), col(J).
fill(cell(1, 1), 0).
fill(cell(1, 2), 1).
fill(cell(1, 3), 2).
fill(cell(2, 1), 3).
fill(cell(2, 2), 4).
fill(cell(2, 3), 5).
fill(cell(3, 1), 6).
fill(cell(3, 2), 7).
fill(cell(3, 3), 8).

% define the goal state
goal(cell(1, 1), 0).
goal(cell(1, 2), 8).
goal(cell(1, 3), 7).
goal(cell(2, 1), 6).
goal(cell(2, 2), 5).
goal(cell(2, 3), 4).
goal(cell(3, 1), 3).
goal(cell(3, 2), 2).
goal(cell(3, 3), 1).


% one move at a time
same_cell(I, J, I', J') :- cell(I, J), cell(I', J'), I = I', J = J'.
ngbd(I, J, I', J') :- cell(I, J), cell(I', J'), |I - I'| <= 1, |J - J'| <= 1, not same_cell(I, J, I', J').


% move(T, cell(I, J), cell(I', J')) :- time(T), cell(I, J), cell(I', J'), ngbd(I, J, I', J'), fill(cell(I, J), 0).
% 1 {move(T, cell(I, J), cell(I', J')): cell(I, J), cell(I', J'), ngbd(I, J, I', J'), fill(cell(I, J), 0)} 1 :- time(T).
1 {move(T, cell(I, J), cell(I', J')): cell(I, J), cell(I', J')} 1 :- time(T).
% 1 {move(T, cell(I, J), cell(I', J')): cell(I, J), cell(I', J'), ngbd(I, J, I', J')} 1 :- time(T).

% % only move into empty cell
:- move(T, cell(I, J), cell(I', J')), fill(cell(I', J'), V), V!=0, time(T).

% % only move from a neighboring cell
% same_cell(I, J, I', J') :- cell(I, J), cell(I', J'), I = I', J = J'.
% ngbd(I, J, I', J') :- cell(I, J), cell(I', J'), |I - I'| <= 1, |J - J'| <= 1, not same_cell(I, J, I', J').
:- move(T, cell(I, J), cell(I', J')), not ngbd(I, J, I', J').

% % what happens when a move occurs
% % change the value of the cell I', J' to the value of the cell I, J
% % fill(T + 1, cell(I, J), V) :- fill(T, cell(I, J), V), time(T).
% fill(T + 1, cell(I', J'), V) :- move(T, cell(I, J), cell(I', J')), fill(T, cell(I, J), V), ngbd(I, J, I', J'), time(T).
% fill(T + 1, cell(I, J), 0) :- move(T, cell(I, J), _), time(T).


fill(cell(I', J'), V),fill(cell(I, J), 0) :- move(T, cell(I, J), cell(I', J')), fill(cell(I, J), V), V!=0, fill(cell(I', J'), 0), ngbd(I, J, I', J'), time(T), value(V).
% fill(cell(I, J), 0) :- move(T, cell(I, J), _), time(T).

% % goal condition
goal_reached(T):- time(T), goal(cell(I, J), V), fill(cell(I, J), V).
:- not goal_reached(t).

% #show row/1.
#show fill/2.
#show move/3.

