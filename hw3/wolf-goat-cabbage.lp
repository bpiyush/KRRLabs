% Use some upper bound on the number of time steps
#const t=10.
time(1..t).

% Declare some parts of the setting
side(left;right).
otherside(left,right).
otherside(right,left).

item(wolf;goat;cabbage).

% These are the possible actions that we can take
action(transfer(I)) :- item(I).
action(empty_transfer).
action(wait).

% We perform exactly one action at each time step
1 { do(A,T) : action(A) } 1 :- time(T), T < t.

% We cannot transfer an item if the boat is not currently on that side
:- do(transfer(I),T), side(S), at(T,boat,S), not at(T,I,S).

% This defines the location of the items, based on the actions taken
at(1,I,left) :- item(I).

at(T2,I,S) :-
    time(T1), time(T2), item(I), T2 = T1+1,
    at(T1,I,S), not do(transfer(I),T1).
at(T2,I,S2) :-
    time(T1), time(T2), item(I), T2 = T1+1,
    at(T1,I,S1), do(transfer(I),T1), otherside(S1,S2).

% This defines the location of the boat, based on the actions taken
at(1,boat,left).

at(T1+1,boat,S) :-
    time(T1), time(T1+1), at(T1,boat,S),
    do(wait,T1).
at(T1+1,boat,S2) :-
    time(T1), time(T1+1), at(T1,boat,S1), otherside(S1,S2),
    do(empty_transfer,T1).
at(T1+1,boat,S2) :-
    time(T1), time(T1+1), at(T1,boat,S1), otherside(S1,S2),
    do(transfer(_),T1).

% These are the conditions where something gets eaten, so we avoid those
:- time(T), at(T,boat,S1), otherside(S1,S2), at(T,wolf,S2), at(T,goat,S2).
:- time(T), at(T,boat,S1), otherside(S1,S2), at(T,cabbage,S2), at(T,goat,S2).

% This defines what the goal is
goal_reached(T) :- time(T), at(T,boat,right), at(T,I,right) : item(I).

% Once we perform the wait action, we must keep waiting
:- do(wait,T), not do(wait,T+1), time(T), time(T+1), T+1 < t.

% We require that we reach the goal at the end
:- not goal_reached(t).


% Symmetry breaking: do not perform two identical transfers directly after
% each other
:- do(transfer(I),T), do(transfer(I),T+1).
:- do(empty_transfer,T), do(empty_transfer,T+1).


% Find the shortest sequence, i.e., wait as much as possible
#maximize { 1,T : do(wait,T) }.

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
