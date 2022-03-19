%*
%%% WOLF, GOAT AND CABBAGE PROBLEM %%%
% https://en.wikipedia.org/wiki/Wolf,_goat_and_cabbage_problem
%%%
*%

%*
%%% GENERAL: PICK A SEQUENCE OF TIME STEPS %%%
*%

% Use some upper bound on the number of time steps
#const t=15.

% Generate time(1), time(2), ..., time(Max), for some Max <= t.
possible_time(1..t).
{ time(T) : possible_time(T) }.
:- not time(1).
:- possible_time(T), possible_time(T+1), not time(T), time(T+1).

% Store the last time step
max_time(MaxTime) :- MaxTime = #max { T : time(T) }.


%*
%%% PROBLEM-SPECIFIC: DESCRIBE THE BASIC PARTS OF THE SETTING %%%
*%

% Declare some parts of the setting
side(left;right).
otherside(left,right).
otherside(right,left).

item(wolf;goat;cabbage).

% Declare what we will treat as fluents
fluent(on_side(I,S)) :- item(I), side(S).

% These are the possible actions that we can take
action(transfer(I)) :- item(I).
action(empty_transfer).

% This defines the location of the boat (always alternating)
state(T,on_side(boat,left)) :- time(T), T \ 2 = 1.
state(T,on_side(boat,right)) :- time(T), T \ 2 = 0.

% Initial state of the fluents
state(1,on_side(I,left)) :- item(I).


%*
%%% GENERAL: CHOOSE ACTIONS, AND MACHINERY FOR FLUENTS %%%
*%

% We perform exactly one action at each time step
1 { do(A,T) : action(A) } 1 :- time(T), T < M, max_time(M).

% Respect the conditions that certain statements must be true or false
:- must_be_true(T,Statement), not state(T,Statement).
:- must_be_false(T,Statement), state(T,Statement).

% Fluents stay true, unless explicitly made false
state(T,Statement) :- time(T),
    fluent(Statement), state(T-1,Statement), not make_false(T,Statement).
% Fluents that are explicitly made true, become true
state(T,Statement) :- time(T),
    fluent(Statement), make_true(T,Statement).


%*
%%% PROBLEM-SPECIFIC: DESCRIBE PRECONDITIONS AND EFFECTS
       OF THE ACTIONS, ADDITIONAL CONSTRAINTS, AND THE GOAL %%%
*%

% Define some helpful properties, based on state/2.
state(T,on_same_side(I,boat)) :- time(T), item(I),
    state(T,on_side(I,S)), state(T,on_side(boat,S)).
state(T,on_same_side(I,boat)) :- state(T,on_same_side(boat,I)).

state(T,on_same_side_without_boat(I,J)) :-
    time(T), item(I), item(J), I != J,
    state(T,on_side(I,S1)), state(T,on_side(J,S1)),
    otherside(S1,S2), state(T,on_side(boat,S2)).

% Precondition of the actions: boat must be on the same side as I if we
% want to transfer I to the other side
must_be_true(T,on_same_side(I,boat)) :- do(transfer(I),T).

% Effects of the actions: if we transfer I, then it will go to the other side
make_true(T+1,on_side(I,S2)) :-
    do(transfer(I),T),
    state(T,on_side(I,S1)), otherside(S1,S2).
make_false(T+1,on_side(I,S)) :-
    do(transfer(I),T),
    state(T,on_side(I,S)).

% Additional conditions: nothing may get eaten
forbidden_pair(wolf,goat).
forbidden_pair(cabbage,goat).
must_be_false(T,on_same_side_without_boat(A,B)) :- time(T), forbidden_pair(A,B).

% Symmetry breaking: do not perform two identical transfers in a row
:- do(transfer(I),T), do(transfer(I),T+1).
:- do(empty_transfer,T), do(empty_transfer,T+1).

% Define the goal
goal_reached(T) :- time(T), state(T,on_side(boat,right)),
    state(T,on_side(I,right)) : item(I).
% We require that we reach the goal at the end
:- max_time(M), not goal_reached(M).
% Once we reached the goal, stop the clock!
:- max_time(M), goal_reached(T), time(T), T < M.


%*
%%% GENERAL: MINIMIZE AND SHOW %%%
*%

% Find the shortest sequence
#minimize { 1,T : time(T) }.

% Show the sequence of actions that we took
#show do/2.


%*
PRETTY PRINTING
*%
#script (python)

import clingo

def on_model(model):
    actions = dict()

    for atom in model.symbols(atoms=True):
        if atom.name == "do":
            time = atom.arguments[1].number
            action = str(atom.arguments[0])
            actions[time] = action

    time_steps = [time for time in actions]
    time_steps.sort()
    print("Pretty printed answer set:")
    for time in time_steps:
        print(f"- At time step {time} do: {actions[time]}")

def main(prg):
    prg.ground([("base", [])])
    prg.solve(on_model=on_model)

#end.
