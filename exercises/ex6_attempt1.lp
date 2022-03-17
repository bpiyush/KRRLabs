

%% ENCODING THE INPUT
#const t=15.
time(1..t).

% Define the subjects
cannibal(c1; c2; c3).
missionair(m1; m2; m3).
person(P) :- cannibal(P).
person(P) :- missionair(P).

% Define the object (in this case a boat)
boat.

% Define the bank location
bank(here; there).
otherside(here, there).
otherside(there, here).

%% ENCODE THE INITIAL STATE
% All persons are here
% The boat is here
at(1, P, here) :- person(P).
at(1, boat, here).

%% EXPRESS WHAT ACTIONS ARE AVAILABLE
% The boat can cross with either one or two people aboard.
1 {move(T, P): person(P)} 2 :- time(T).
% If there is no movement at time T, then there should be no movement at time T+1
:- not move(T, _), move(T + 1, _), time(T).

% % boat can only be at one bank at a given time
% :- at(T, boat, here), not at(T, boat, there), time(T).

% % If a person moves at time T, then they should be at the other side at time T+1
% at(T + 1, P, NotS), at(T + 1, boat, NotS) :- move(T, P), at(T, P, S), at(T, boat, S), otherside(S, NotS), time(T).
% at(T + 1, P, NotS):- move(T, P), at(T, P, S), at(T, boat, S), otherside(S, NotS), time(T).
% at(T + 1, boat, NotS) :- move(T, P), at(T, P, S), at(T, boat, S), otherside(S, NotS), time(T).
at(T + 1, P, NotS) :- move(T, P), at(T, P, S), otherside(S, NotS), time(T), person(P).
at(T + 1, boat, NotS) :- move(T, P), person(P), at(T, boat, S), otherside(S, NotS), time(T).

% % If a person does not move at time T, then they should be at the same place at time T+1
% % at(T + 1, P, S), at(T + 1, boat, S) :- not move(T, P), at(T, P, S), at(T, boat, S), time(T).
at(T + 1, P, S) :- not move(T, P), at(T, P, S), time(T).

% % A person cannot be moved if it is at the other end of the bank as the boat
% :- move(T, P), at(T, P, S1), at(T, boat, S2), S1 != S2, time(T).

%% EXPRESS CONSTRAINT
count_cannibals(T, S, C) :- time(T), bank(S), C = #count{P: at(T, P, S), cannibal(P)}.
count_missionairs(T, S, C) :- time(T), bank(S), C = #count{P: at(T, P, S), missionair(P)}.
:- count_cannibals(T, S, C), count_missionairs(T, S, M), C > M, M > 0.


% goal_reached(T) :- count_cannibals(T, there, 3), count_missionairs(T, there, 3).
% :- not goal_reached(t).

% Encode the goal as a constraint
% Evetually, all persons should be at the other side of the bank
% Step 1: 
% Step 2: If all persons are on the other side


% #show at/3.
#show move/2.
% #show count_cannibals/3.
#show at/3.


%*
PRETTY PRINTING
*%
#script (python)

import clingo


def filter_atom(model, atom):
    symbols = model.symbols(atoms=True)
    atoms = [a for a in symbols if a.name == atom]
    return atoms

def on_model(model):
    actions = dict()

    times = filter_atom(model, "time")
    locations = filter_atom(model, "at")
    moves = filter_atom(model, "move")
    count_cannibals = filter_atom(model, "count_cannibals")
    for t in range(len(times)):
        
        locations_at_t = [l for l in locations if l.arguments[0].number == times[t].arguments[0].number]

        here = []
        there = []
        for l in locations_at_t:
            if l.arguments[2].name == "here":
                here.append(l.arguments[1].name)
            else:
                there.append(l.arguments[1].name)
        
        print("Time: " + str(times[t].arguments[0].number))
        here = sorted(here)
        there = sorted(there)

        print("State: ")
        print(f"{str(here).ljust(50)} | \t\t | {str(there)}")

        moves_at_t = [m.arguments[1].name for m in moves if m.arguments[0].number == times[t].arguments[0].number]
        print("Moves: ", moves_at_t)

        count_cannibals_here_at_t = [c.arguments[2].number for c in count_cannibals if c.arguments[0].number == times[t].arguments[0].number and c.arguments[1].name == "here"]
        print("Cannibals here: ", count_cannibals_here_at_t[0])

        print("-" * 100)

def main(prg):
    prg.ground([("base", [])])
    prg.solve(on_model=on_model)

#end.
