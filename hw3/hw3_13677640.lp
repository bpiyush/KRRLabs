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
edge(1,10).
edge(1,3).
edge(3,5).

% Edges are undirected, so include their reverse
edge(X,Y) :- edge(Y,X).
:- edge(X, Y), X = Y.

% Represent the charging stations using charging_station/1.
charging_station(N) : node(N), N = 2.
charging_station(N) : node(N), N = 4.

% Represent delivery location using delivery_location/1.
delivery_location(N) : node(N), N = 1.
delivery_location(N) : node(N), N = 6.

% Represent warehouse location using warehouse_location/1.
warehouse_location(N) : node(N), N = 7.

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

% wait: make a truck wait at its current location
action(wait).

% move(N): move a truck to node N
action(move(N)) :- node(N).

% load: load a truck at a node
action(load).

% unload: unload a truck at a node
action(unload).

% charge: charge a truck at a charging station
action(charge).


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
% These are split for trucks, warehouse and delivery location.

% ::::::: TRUCKS ::::::: %

% - truck_location(V T, N) : the location of truck V at time T is node N
% - truck_load(V, T, L, Lmax)    : the load of truck V at time T is L with a maximum capacity of Lmax
% - truck_battery(V, T, B, Bmax)    : the battery of truck V at time T is B with a maximum battery Bmax

truck_location(1, 1, 11).
truck_load(1, 1, 0, 1).
truck_battery(1, 1, 6, 10).

truck_location(2, 1, 12).
truck_load(2, 1, 0, 2).
truck_battery(2, 1, 7, 10).

truck_location(3, 1, 13).
truck_load(3, 1, 0, 3).
truck_battery(3, 1, 10, 10).

% ::::::: WAREHOUSES ::::::: %

% - warehouse_tracker(W, T, L) : the load of warehouse node W at time T is L
warehouse_tracker(7, 1, 5).

% ::::::: DELIVERIES ::::::: %

% - delivery_tracker(D, T, R) : the requirement of delivery node D at time T is R
delivery_tracker(1, 1, 2).
delivery_tracker(6, 1, 2).




%*
SUBSEQUENT STATES OF THE WORLD:
- Encode the subsequent states, based on the actions taken

Explanation (max 100 words):

Summary:
- For each state variable, we define how it changes when a particular action is taken.

Examples:
- The truck location does not change when a truck chooses one of 
(wait, load, unload, charge) actions. But it changes when a truck moves to a new node.
- For tracking state of the warehouse, notably, it does not change when *all* the trucks
are not involved in loading. It changes when there exists a truck that loads.
- Likewise for delivery trackers, it does not change when *a*. trucks are not involved in
unloading. It changes when there exists a truck that unloads.

*%

% Effect on truck location
% No change when a truck chooses one of (wait, load, unload, charge) actions
truck_location(V, T + 1, N) :- do(V, T, wait), truck_location(V, T, N), time(T), time(T + 1), truck(V), node(N).
truck_location(V, T + 1, N) :- do(V, T, load), truck_location(V, T, N), time(T), time(T + 1), truck(V), node(N).
truck_location(V, T + 1, N) :- do(V, T, unload), truck_location(V, T, N), time(T), time(T + 1), truck(V), node(N).
truck_location(V, T + 1, N) :- do(V, T, charge), truck_location(V, T, N), time(T), time(T + 1), truck(V), node(N).
% move it to a new node on action move(M)
truck_location(V, T + 1, M) :- do(V, T, move(M)), truck_location(V, T, N), time(T), time(T + 1), truck(V), node(N).

% Effect on truck battery
% No change when a truck chooses one of (wait, load, unload) actions
truck_battery(V, T + 1, B, Bmax) :- do(V, T, wait), truck_battery(V, T, B, Bmax), time(T), time(T + 1), truck(V), node(N).
truck_battery(V, T + 1, B, Bmax) :- do(V, T, load), truck_battery(V, T, B, Bmax), time(T), time(T + 1), truck(V), node(N).
truck_battery(V, T + 1, B, Bmax) :- do(V, T, unload), truck_battery(V, T, B, Bmax), time(T), time(T + 1), truck(V), node(N).
% Increase the battery when a truck charges
truck_battery(V, T + 1, B + 1, Bmax) :- do(V, T, charge), truck_battery(V, T, B, Bmax), time(T), time(T + 1), truck(V), node(N).
% Decrease the battery when a truck moves
truck_battery(V, T + 1, B - 1, Bmax) :- do(V, T, move(M)), truck_battery(V, T, B, Bmax), time(T), time(T + 1), truck(V), node(N).

% Effect on truck load
% No change when a truck chooses one of (wait, move, charge) actions
truck_load(V, T + 1, L, Lmax) :- do(V, T, wait), truck_load(V, T, L, Lmax), time(T), time(T + 1), truck(V), node(N).
% Increase the load when a truck loads
truck_load(V, T + 1, L + 1, Lmax) :- do(V, T, load), truck_load(V, T, L, Lmax), time(T), time(T + 1), truck(V), node(N).
% Decrease the load when a truck unloads
truck_load(V, T + 1, L - 1, Lmax) :- do(V, T, unload), truck_load(V, T, L, Lmax), time(T), time(T + 1), truck(V), node(N).
truck_load(V, T + 1, L, Lmax) :- do(V, T, charge), truck_load(V, T, L, Lmax), time(T), time(T + 1), truck(V), node(N).
truck_load(V, T + 1, L, Lmax) :- do(V, T, move(M)), truck_load(V, T, L, Lmax), time(T), time(T + 1), truck(V), node(N).

% Effect on warehouse tracker
% If none of the trucks are involved in loading, the warehouse tracker does not change
warehouse_tracker(N, T + 1, L) :- not do(V, T, load) : truck(V); warehouse_tracker(N, T, L), time(T).
% If there is a truck that loads, the warehouse load decreases
warehouse_tracker(N, T + 1, L - 1) :- do(V, T, load), truck(V), warehouse_tracker(N, T, L).

% Effect on delivery tracker
% If none of the trucks are involved in unloading, the delivery tracker does not change
delivery_tracker(N, T + 1, R) :- not do(V, T, unload) : truck(V); delivery_tracker(N, T, R), time(T).
% If there is a truck that unloads, the delivery requirement decreases since 1 packages is delivered
delivery_tracker(N, T + 1, R - 1) :- do(V, T, unload), truck_location(V, T, N), delivery_tracker(N, T, R), truck_load(V, T, B, Bmax), delivery_location(N).




%*
RESTRICTIONS ON THE ACTIONS:
- Restrict the actions taken by the trucks, based on the state of the world

Explanation (max 100 words):

Summary:
- For each action, we define the restrictions on the actions that can be taken.
- We use constraints in ASP to define the restrictions.

Examples:
- A truck cannot move to a node that isn't neighbor of it's current node.
- A truck cannot unload if it has no load or it is not at delivery location and
the delivery location has pending requirements.
- A truck cannot load if it has enough capacity and is not at the warehouse
and the warehouse has atleast one load.
- A truck cannot charge if it's not at charging station and it does not have
a full battery.
*%

% ::::::::: ACTION: WAIT ::::::::: %
% No restrictions on the "wait" action

% ::::::::: ACTION: MOVE ::::::::: %
% A truck can only move to a node that is adjacent to its current location
:- do(V, T, move(M)), truck_location(V, T, N), not edge(N, M).

% ::::::::: ACTION: LOAD ::::::::: %
% A truck can only be loaded at a warehouse location and
% if the warehouse has atleast one package to be loaded
% and if the truck has enough capacity to load the package
:- do(V, T, load), truck_load(V, T, L, Lmax), warehouse_tracker(N, T, P), P < 1.
:- do(V, T, load), truck_load(V, T, L, Lmax), warehouse_tracker(N, T, L), L + 1 > Lmax.
:- do(V, T, load), truck_location(V, T, N), not warehouse_location(N).

% ::::::::: ACTION: UNLOAD ::::::::: %
% If it is at a delivery location that still needs some packages,
% and the truck has at least one package to be unloaded
:- do(V, T, unload), truck_load(V, T, L, Lmax), delivery_tracker(N, T, R), R < 1.
:- do(V, T, unload), truck_load(V, T, L, Lmax), delivery_tracker(N, T, R), L < 1.
:- do(V, T, unload), truck_location(V, T, N), not delivery_location(N).

% ::::::::: ACTION: CHARGE ::::::::: %
% If it is at a charging station, and the battery is not at full capacity
:- do(V, T, charge), truck_battery(V, T, B, Bmax), B >= Bmax.
:- do(V, T, charge), truck_location(V, T, N), not charging_station(N).


% ::::::::: ADDITIONAL CONSTRAINTS ::::::::: %

% A truck cannot move to another node if its battery level is empty
:- do(V, T, move(M)), truck_battery(V, T, B, Bmax), B < 1.

% At each location, there can be at most one truck at the same time.
:- truck_location(V1, T, N), truck_location(V2, T, N), V1 != V2.

% Trucks cannot pass each other on a piece of road—e.g.,
% trucks at adjacent locations cannot swap places in a single time step
:- truck_location(V1, T, N1), truck_location(V2, T, N2), edge(N1, N2), do(V1, T, move(N2)), do(V2, T, move(N1)).

%*
GOAL CONDITIONS:
- Constraints that express that the goal must be reached

Explanation (max 100 words):

Summary:
- We define the goal conditions for the problem. For each goal,
we define it as a predicate that we track at each time step, like

single_goal(T)

denoting if single_goal is reached at time T. To satisfy all of them, we 
have a predicate goal_reached(T) that returns true if all the goals are
reached at time T. Details for each individual goals are provided in in-line comments.
*%

% 1. All required deliveries must have been performed.
all_packages_delivered(T) :- delivery_tracker(N, T, 0) : delivery_location(N); time(T).

% 2. All trucks are located at a parking spot.
some_truck_not_parked(V, T) :- truck(V), truck_location(V, T, N), not parking_location(N).
all_trucks_parked(T) :- not some_truck_not_parked(_, T), time(T).

% 3. Each truck must have no packaged aboard.
packages_left(V, T) :- truck(V), truck_load(V, T, L, Lmax), L > 0.
no_packages_on_trucks(T) :- not packages_left(_, T), time(T).

% 4 .Each truck must have a battery level that allows
% it to reach some charging station—e.g., if the shortest path
% from the truck to a charging station has length
% then the truck’s battery level must be at least

% Snippet to compute the shortest path from one node to another
#const n_nodes=13.
num(1..n_nodes).
shortest_dist(A, A, 0) :- node(A).
shortest_dist(A, B, D + 1) :- edge(A, C), shortest_dist(C, B, D), num(D+1), not shortest_dist(A, B, D'):D' <= D, num(D').
% Defines if there is a truck that does not have sufficient battery to reach charging station
some_truck_with_not_enough_battery(V, T) :- truck(V), truck_battery(V, T, B, Bmax), truck_location(V, T, N),
    charging_station(S), B < D, shortest_dist(N, S, D), num(D).
% We do not want any truck to have a battery level that does not allows it to reach a charging station
all_trucks_charged(T) :- not some_truck_with_not_enough_battery(_, T), time(T).


% Make sure the goal is reached and before the time limit t=25
goal_reached(T) :- 
    all_packages_delivered(T),
    all_trucks_parked(T),
    no_packages_on_trucks(T),
    all_trucks_charged(T),
    time(T).
:- not goal_reached(t).



%*
OPTIMIZATION:
- Express an optimization statement to find a solution within the smallest
  number of time steps

Explanation (max 100 words):
- We find the optimal time at which a valid solution is found as follows:
- We find a time T s.t. goal is reached at time T but it has not reached at time (T - 1).
This given the minimum number of time steps to reach the goal.

*%


first_time_goal_reached(T) :- goal_reached(T), not goal_reached(T-1).
#minimize {T : first_time_goal_reached(T)}.



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
% #show truck/1.
% #show truck_battery/3.
% #show delivery_tracker/3.
% #show shortest_dist/3.
#show first_time_goal_reached/1.

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
    warehouse = dict()
    deliveries = dict()

    atoms = model.symbols(atoms=True)
    nodes = [x for x in atoms if x.name == "node"]
    assert len(nodes) == 13, "There should be 13 nodes"
    edges = [x for x in atoms if x.name == "edge"]
    assert len(edges) // 2 == 20, "There should be 20 edges"

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

        if atom.name == "warehouse_tracker":
            time = atom.arguments[1].number
            if time not in loads:
                warehouse[time] = ""

            node = atom.arguments[0].number
            if node not in [7]:
                continue
            requirement = str(atom.arguments[2])
            warehouse[time] = str(requirement)
        
        if atom.name == "delivery_tracker":
            time = atom.arguments[1].number
            if time not in deliveries:
                deliveries[time] = ["", ""]

            node = atom.arguments[0].number
            if node not in [1, 6]:
                continue
            requirement = str(atom.arguments[2])
            deliveries[time][int(node == 1)] = str(requirement)

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

    for time in deliveries:
        deliveries[time] = [x.ljust(3) for x in deliveries[time]]
        deliveries[time] = "\t".join(deliveries[time])

    print()
    print("-" * 80)
    print("-" * 80)
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
    
    print(":" * 30 + " WAREHOUSE " + ":" * 30)
    time_steps = [time for time in warehouse]
    time_steps.sort()

    for time in time_steps:
        print(f"- At time step {time} warehouse:\t  {warehouse[time]}")

    print(":" * 30 + " DELIVERIES " + ":" * 30)
    time_steps = [time for time in deliveries]
    time_steps.sort()

    for time in time_steps:
        print(f"- At time step {time} deliveries:\t  {deliveries[time]}")

    print("-" * 80)
    print("-" * 80)

def main(prg):
    prg.ground([("base", [])])
    prg.solve(on_model=on_model)

#end.

