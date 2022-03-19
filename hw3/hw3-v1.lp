%*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% KRR 2022, HOMEWORK ASSIGNMENT 3 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Name:             Piyush Bagad
Student number:   13677640

Name:             ...
Student number:   ...

*%

%*
INPUT REPRESENTATION:
- Represent the input of the problem (the map, the trucks, etc.)

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS (SEE EXAMPLE BELOW)]
*%

% Represent the nodes and edges of the map using node/1 and edge/2.
node(1..13).
edge(1,2).
edge(2,3).
edge(3,4).
edge(4,5).
edge(5,6).
edge(6,7).
edge(7,8).
edge(8,9).
edge(9,10).
edge(10,11).
edge(11,12).
edge(12,13).
edge(7,13).
edge(5,8).
edge(5,9).
edge(3,9).
edge(3,10).

% Edges are undirected, so include their reverse
edge(X,Y) :- edge(Y,X).
:- edge(X, Y), X = Y.

% Represent the charging stations using charging_station/1.
charging_station(node(2)).
charging_station(node(4)).

% Represent delivery location using delivery_location/2.
% delivery_location(node(X), R). where R denotes requirements.
delivery_location(node(1), 2).
delivery_location(node(6), 2).

% Represent warehouse location using warehouse_location/2.
% warehouse_location(node(X), C). where C denotes capacity.
warehouse_location(node(7), 5).

% Represent parking location using parking_location/1.
parking_location(node(11)).
parking_location(node(12)).
parking_location(node(13)).

% Represent the trucks using truck/1.
truck(1..3).



%*
TIME STEPS:
- Represent the different time steps (up to some upper bound)

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%

#const t=25. % This is an upper bound on the number of time steps needed

% Define a time variable
time(1..t).



%*
ACTIONS:
- Represent the possible actions that each truck can take

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%

% For each truck, define the possible actions.
% Actions are represented by the predicates:
% wait(Truck): the truck waits at its current node
% move(Truck, Node): the truck moves to a node
% load(Truck): the truck load ONE single package at its current node, a warehouse
% unload(Truck): the truck unloads ONE single package at its current node, a delivery location
% charge(Truck): the truck charges at its current node, a charging station
% action(wait; load; unload; charge).
action(wait).
action(move(N)) :- node(N).

% For each truck (vehicle), we perform exactly one action per time step.
% do(Truck, Time, Action): the truck performs the action at the given time step.
1 { do(V, T, A) : action(A) } 1 :- truck(V), time(T), T < t.


% Define state of each truck at each time step
% location_tracker(Truck, Time, Node): the truck is on the given node at the given time step
% battery_tracker(Truck, Time, Battery, BatteryMax): the truck's battery level at the given time step
% load_tracker(Truck, Time, Load, LoadMax): the truck's load level at the given time step

% initial state of truck 1
location_tracker(1, 1, node(11)).
battery_tracker(1, 1, 6, 10).
load_tracker(1, 1, 0, 1).

% initial state of truck 2
location_tracker(2, 1, node(12)).
battery_tracker(2, 1, 7, 10).
load_tracker(2, 1, 0, 2).

% initial state of truck 3
location_tracker(3, 1, node(13)).
battery_tracker(3, 1, 10, 10).
load_tracker(3, 1, 0, 3).


% Define pre-conditions for each action.
% For now, let's focus on move and wait actions.

% Precondition for move action:
% 1. A truck can only move to a node that is connected to its current node.
% :- location_tracker(V, T+1, node(M)), location_tracker(V, T, node(N)), not edge(N, M), time(T).
% 2. Two trucks cannot end up at the same node at the same time.
% :- location_tracker(V1, T, node(N)), location_tracker(V2, T, node(N)), V1 != V2, time(T).
% :- location_tracker(V1, T, node(N)), location_tracker(V2, T, node(N)), V1 != V2.
:- do(V1, T, move(N)), do(V2, T, move(N)), V1 != V2, time(T).
% :- do(V1, T, move(N)), do(V2, T, wait), location_tracker(V2, T - 1, node(N)), V1 != V2.
% 3. A truck cannot move if its battery level is < 1.
% :- do(V, T, move(N)), battery_tracker(V, T, B, Bmax), B < 1, time(T).

% Precondition for wait action: None




% move(Truck, Node): the truck can only move to an adjacent node
% and that node is not occupied by another truck and that truck
% does not fire a move action at the same time step towards the same node
% neither does it fire a wait action at the same time step
% :- move(I, N), truck(I), node(N), not edge(N, M).

% Define the effects of each action.

% Effects of the move action:
location_tracker(V, T + 1, node(N)) :- 
    do(V, T, move(N)),
    location_tracker(V, T, node(M)), edge(M, N),
    battery_tracker(V, T, B, Bmax), B > 0.
battery_tracker(V, T + 1, B - 1, Bmax) :- 
    do(V, T, move(N)),
    location_tracker(V, T, node(M)), edge(M, N),
    battery_tracker(V, T, B, Bmax), B > 0.
% battery_tracker(V, T + 1, B - 1, Bmax) :- do(V, T, move(N)), time(T), T < t, battery_tracker(V, T, B, Bmax).

% Effects of the wait action:
location_tracker(V, T + 1, node(N)) :- 
    do(V, T, wait),
    location_tracker(V, T, node(N)).
battery_tracker(V, T + 1, B, Bmax) :- 
    do(V, T, wait),
    battery_tracker(V, T, B, Bmax).

%*
GENERATE A SEQUENCE OF ACTIONS:
- Generate a sequence of actions (for each truck)

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%




%*
INITIAL STATE:
- Encode the initial state

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%




%*
SUBSEQUENT STATES OF THE WORLD:
- Encode the subsequent states, based on the actions taken

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
RESTRICTIONS ON THE ACTIONS:
- Restrict the actions taken by the trucks, based on the state of the world

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
GOAL CONDITIONS:
- Constraints that express that the goal must be reached

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
OPTIMIZATION:
- Express an optimization statement to find a solution within the smallest
  number of time steps

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
OPTIONAL: ADDITIONAL RULES
- If you add anything to your program that doesn't fit in any of the other
  headings, put it here.

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
THE END
*%

% #show action/1.
% #show do/3.
#show location_tracker/3.

%*
PRETTY PRINTING
*%
#script (python)

import clingo

def on_model(model):
    actions = dict()
    locations = dict()

    for atom in model.symbols(atoms=True):
        if atom.name == "do":

            time = atom.arguments[1].number
            if time not in actions:
                actions[time] = ["", "", ""]

            truck = atom.arguments[0].number
            action = str(atom.arguments[2])
            actions[time][truck - 1] = action
        
        if atom.name == "location_tracker":
            time = atom.arguments[1].number
            if time not in locations:
                locations[time] = ["", "", ""]

            truck = atom.arguments[0].number
            location = str(atom.arguments[2])
            locations[time][truck - 1] = location
    
    for time in actions:
        actions[time] = [x.ljust(10) for x in actions[time]]
        actions[time] = "\t".join(actions[time])
    
    for time in locations:
        locations[time] = [x.ljust(10) for x in locations[time]]
        locations[time] = "\t".join(locations[time])


    time_steps = [time for time in actions]
    time_steps.sort()
    print("Pretty printed answer set:")

    print("ACTIONS :::::::")
    for time in time_steps:
        print(f"- At time step {time} do:\t  {actions[time]}")
    
    print("LOCATIONS :::::")
    for time in time_steps:
        print(f"- At time step {time} location:\t  {locations[time]}")

def main(prg):
    prg.ground([("base", [])])
    prg.solve(on_model=on_model)

#end.
