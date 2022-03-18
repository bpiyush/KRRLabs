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
% ...

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

% Define a tracker that tracks state of a truck.
% tracker(Truck, Time, Node, CurLoad, MaxLoad, CurBattery, MaxBattery).
%   - Truck is the truck
%   - Time is the time the truck is at the current node
%   - Node is the current node of the truck
%   - CurLoad is the current load of the truck
%   - MaxLoad is the maximum load of the truck
%   - CurBattery is the current battery of the truck
%   - MaxBattery is the maximum battery of the truck

% Define initial state of the three trucks.
tracker(truck(1), 1, node(11), 0, 1, 6, 10).
tracker(truck(2), 1, node(12), 0, 2, 7, 10).
tracker(truck(3), 1, node(13), 0, 3, 10, 10).

% define constants
#const t=25.

% Define time
time(1..t).

%*
ACTIONS:
- Represent the possible actions that each truck can take

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%

% For each truck, define the possible actions.
action(wait(I);move(I),load(I);unload(I);charge(I)) :- truck(I).


% Define conditions to check if a node is occupied by a truck.
node_occupied(T, Node) :- time(T), tracker(Truck, _, Node, _, _, _, _).

% Define conditions to check if an edge is occupied by a truck.
% edge_occupied(Edge) :- edge(X, Y), tracker(Truck, _, X, _, _, _, _), edge(X, Y).
% Edge E is occupied if there is a truck Tr at time Ti at node X and edge(X, Y) is true.
% Edge E is occupied if either of the nodes of edge E is occupied and either of the trucks moving. 



% Display answer set
#show tracker/7.
#show action/1.


%*
PRETTY PRINTING
*%
#script (python)

import clingo
import networkx as nx
import matplotlib.pyplot as plt

def show_graph(G, node_color=None):
    nx.draw(G, with_labels=True, node_color=node_color)
    plt.show()


def filter_atom(model, atom):
    symbols = model.symbols(atoms=True)
    atoms = [a for a in symbols if a.name == atom]
    return atoms

def on_model(model, verbose=False):
    actions = dict()
    print("Hello World!")
    
    G = nx.Graph()

    nodes = filter_atom(model, "node")
    node_ids = [n.arguments[0].number for n in nodes]
    G.add_nodes_from(node_ids)

    edges = filter_atom(model, "edge")
    edge_ids = [(e.arguments[0].number, e.arguments[1].number) for e in edges]
    G.add_edges_from(edge_ids)

    warehouse_locations = filter_atom(model, "warehouse_location")
    warehouse_locations = [w.arguments[0].arguments[0].number for w in warehouse_locations]

    delivery_locations = filter_atom(model, "delivery_location")
    delivery_locations = [w.arguments[0].arguments[0].number for w in delivery_locations]

    charging_stations = filter_atom(model, "charging_station")
    charging_stations = [w.arguments[0].arguments[0].number for w in charging_stations]

    node_color = []
    for n in node_ids:
        if n in warehouse_locations:
            node_color.append('red')
        elif n in delivery_locations:
            node_color.append('green')
        elif n in charging_stations:
            node_color.append('blue')
        else:
            node_color.append('lightgray')
    
    if verbose:
        show_graph(G, node_color)

def main(prg):
    prg.ground([("base", [])])
    prg.solve(on_model=on_model)

#end.
