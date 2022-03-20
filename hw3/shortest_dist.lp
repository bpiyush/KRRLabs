% Computes shortest distance between two nodes in a graph

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
% ...

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

% define source and destination nodes
source(1).
destination(6).

% find all possible subsets of edges containing nodes N1 and N2
% {edge(N1, N2)} :- node(N1), node(N2), N1 != N2.
% pair(N1, N2): node(N1), node(N2), N1 != N2.
% ngbr(1) :- {M : edge(1, M), node(M)}.

% generate all possible subsets of nodes
% {choose(N) : node(N)}.

% % both source and destination nodes should be part of chosen path
% :- not choose(X), source(X).
% :- not choose(X), destination(X).

% % if there is no path between any two chosen nodes, then eliminate that set
% :- choose(X), choose(Y), not edge(X, Y), node(X), node(Y), X!=Y.

% Let dist(A, B, D) denote that distance between node A and node B is D.
% initial condition: dist(A, A, 0) :- node(A).

#const n_nodes=13.

% n_nodes(S) :- S = #sum{N: node(N)}.
% num(1..t) :- n_nodes(t).
num(1..n_nodes).

shortest_dist(A, A, 0) :- node(A).
shortest_dist(A, B, D + 1) :- edge(A, C), shortest_dist(C, B, D), num(D+1), not shortest_dist(A, B, D'):D' <= D, num(D').

#show shortest_dist/3.