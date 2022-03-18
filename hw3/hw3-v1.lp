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
action(wait(I); load(I); unload(I); charge(I)) :- truck(I).
action(move(I, N)) :- truck(I), node(N).

% For each truck, we perform exactly one action per time step.
1 { do(A,T) : action(A) } 1 :- time(T), T < t.

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
