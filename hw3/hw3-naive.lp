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
% ...

% Edges are undirected, so include their reverse
edge(X,Y) :- edge(Y,X).
:- edge(X, Y), X = Y.

% Represent the charging stations using charging_station/1.
charging_station(N) : node(N), N = 2.
charging_station(N) : node(N), N = 4.

% Represent delivery location using delivery_location/2.
% delivery_location(N, R). where N is a node and R denotes requirements.
delivery_location(N, 2) : node(N), N = 1.
delivery_location(N, 2) : node(N), N = 6.

% Represent warehouse location using warehouse_location/2.
% warehouse_location(N, C). where N is a node and C denotes capacity.
warehouse_location(N, 5) : node(N), N = 2.

% Represent parking location using parking_location/1.
parking_location(N) : node(N), N = 11.
parking_location(N) : node(N), N = 12.
parking_location(N) : node(N), N = 13.

% Represent the trucks using truck/1.
truck(1..3).


%*
TIME STEPS:
- Represent the different time steps (up to some upper bound)

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%

#const t=25. % This is an upper bound on the number of time steps needed

% Define the time variable
time(1..t).


%*
ACTIONS:
- Represent the possible actions that each truck can take

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%

% For each truck, define the possible actions.
% Actions are represented by the predicates:

% wait      : make a truck wait at its current location
action(wait).

% move(N)   : move a truck to node N
action(move(N)) :- node(N).


%*
GENERATE A SEQUENCE OF ACTIONS:
- Generate a sequence of actions (for each truck)

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%

% For each truck, we perform exactly one action per time step.
% do(V, T, A): the truck V performs the action A at the given time step T.
1 { do(V, T, A) : action(A) } 1 :- truck(V), time(T), T < t.




%*
INITIAL STATE:
- Encode the initial state

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%

% In order to define state at a given time,
% we define the following state variables:

% ::::::: TRUCKS ::::::: %
% - truck_location(V T, N) : the location of truck V at time T is node N
% - truck_load(V, T, L, Lmax)    : the load of truck V at time T is L with a maximum capacity of Lmax
% - truck_battery(V, T, B, Bmax)    : the battery of truck V at time T is B with a maximum battery Bmax

% truck_location(V, T, N) : truck(V), time(T), node(N), V = 1, T = 1, N = 11.
truck_location(1, 1, 11).
truck_load(1, 1, 0, 1).
truck_battery(1, 1, 6, 10).

% truck_location(V, T, N) : truck(V), time(T), node(N), V = 2, T = 1, N = 12.
truck_location(2, 1, 12).
truck_load(2, 1, 0, 2).
truck_battery(2, 1, 7, 10).

% truck_location(V, T, N) : truck(V), time(T), node(N), V = 3, T = 1, N = 13.
truck_location(3, 1, 13).
truck_load(3, 1, 0, 3).
truck_battery(3, 1, 10, 10).

% For now, we do not care about the state of warehouse, deliveries, etc.
% ::::::: WAREHOUSES ::::::: %

% ::::::: DELIVERIES ::::::: %




%*
SUBSEQUENT STATES OF THE WORLD:
- Encode the subsequent states, based on the actions taken

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%

% ::::::::: ACTION: WAIT ::::::::: %

% Effect on truck-related states
% Location, load, battery of the truck remain the same
truck_location(V, T + 1, N) :- do(V, T, wait), truck_location(V, T, N).
truck_battery(V, T + 1, B, Bmax) :- do(V, T, wait), truck_battery(V, T, B, Bmax).
truck_load(V, T + 1, L, Lmax) :- do(V, T, wait), truck_load(V, T, L, Lmax).

% Effect of warehouse-related states

% Effect of delivery-related states

% ::::::::: ACTION: MOVE ::::::::: %

% Effect on truck-related states
% Location of the truck changes
truck_location(V, T + 1, M) :- do(V, T, move(M)), truck_location(V, T, N).
% Battery of the truck decreases
truck_battery(V, T + 1, B - 1, Bmax) :- do(V, T, move(M)), truck_battery(V, T, B, Bmax).
% Load of the truck does not change
truck_load(V, T + 1, L, Lmax) :- do(V, T, move(M)), truck_load(V, T, L, Lmax).

% Effect of warehouse-related states

% Effect of delivery-related states


%*
RESTRICTIONS ON THE ACTIONS:
- Restrict the actions taken by the trucks, based on the state of the world

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%

% ::::::::: ACTION: WAIT ::::::::: %
% No restrictions on the "wait" action

% ::::::::: ACTION: MOVE ::::::::: %
% A truck can only move to a node that is adjacent to its current location
:- do(V, T, move(M)), truck_location(V, T, N), not edge(N, M).


% ::::::::: ADDITIONAL CONSTRAINTS ::::::::: %

% A truck cannot move to another node if its battery level is empty
:- do(V, T, move(M)), truck_battery(V, T, B, Bmax), B < 1.

% At each location, there can be at most one truck at the same time.
:- truck_location(V1, T, N), truck_location(V2, T, N), V1 != V2.

% Trucks cannot pass each other on a piece of road—e.g.,
% trucks at adjacent locations cannot swap places in a single time step
:- truck_location(V1, T, N1), truck_location(V2, T, N2), edge(N1, N2), do(V1, T, move(N2)), do(V2, T, move(N2)).

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

% #show charging_station/1.
% #show delivery_location/2.
% #show warehouse_location/2.
% #show parking_location/1.
% #show do/3.
% #show truck_location/3.
#show truck/1.
% #show truck_battery/3.

%*
PRETTY PRINTING
*%
#script (python)

import clingo

def on_model(model):
    actions = dict()
    locations = dict()
    batteries = dict()
    loads = dict()

    for atom in model.symbols(atoms=True):
        if atom.name == "do":

            time = atom.arguments[1].number
            if time not in actions:
                actions[time] = ["", "", ""]

            truck = atom.arguments[0].number
            action = str(atom.arguments[2])
            actions[time][truck - 1] = action

        if atom.name == "truck_location":
            time = atom.arguments[1].number
            if time not in locations:
                locations[time] = ["", "", ""]

            truck = atom.arguments[0].number
            location = str(atom.arguments[2])
            locations[time][truck - 1] = location

        if atom.name == "truck_battery":
            time = atom.arguments[1].number
            if time not in batteries:
                batteries[time] = ["", "", ""]

            truck = atom.arguments[0].number
            battery = str(atom.arguments[2])
            batteries[time][truck - 1] = battery

        if atom.name == "truck_load":
            time = atom.arguments[1].number
            if time not in loads:
                loads[time] = ["", "", ""]

            truck = atom.arguments[0].number
            battery = str(atom.arguments[2])
            loads[time][truck - 1] = battery
    
    for time in actions:
        actions[time] = [x.ljust(10) for x in actions[time]]
        actions[time] = "\t".join(actions[time])

    for time in locations:
        locations[time] = [x.ljust(3) for x in locations[time]]
        locations[time] = "\t".join(locations[time])

    for time in batteries:
        batteries[time] = [x.ljust(3) for x in batteries[time]]
        batteries[time] = "\t".join(batteries[time])

    for time in loads:
        loads[time] = [x.ljust(3) for x in loads[time]]
        loads[time] = "\t".join(loads[time])

    print("Pretty printed answer set:")

    print(":" * 30 + " ACTIONS " + ":" * 30)
    time_steps = [time for time in actions]
    time_steps.sort()

    for time in time_steps:
        print(f"- At time step {time} do:\t  {actions[time]}")

    print(":" * 30 + " LOCATIONS " + ":" * 30)
    time_steps = [time for time in locations]
    time_steps.sort()

    for time in time_steps:
        print(f"- At time step {time} location:\t  {locations[time]}")

    print(":" * 30 + " BATTERIES " + ":" * 30)
    time_steps = [time for time in batteries]
    time_steps.sort()

    for time in time_steps:
        print(f"- At time step {time} battery:\t  {batteries[time]}")

    print(":" * 30 + " LOADS " + ":" * 30)
    time_steps = [time for time in loads]
    time_steps.sort()

    for time in time_steps:
        print(f"- At time step {time} load:\t  {loads[time]}")

    print("-" * 80)

def main(prg):
    prg.ground([("base", [])])
    prg.solve(on_model=on_model)

#end.

