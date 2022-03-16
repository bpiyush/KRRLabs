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

% Represent delivery location using delivery_location/1.
delivery_location(node(1)).
delivery_location(node(6)).

% Represent warehouse location using warehouse_location/1.
warehouse_location(node(7)).

% Represent the trucks using truck/1.
truck(1..3).


% define constants
#const n=2.
#const m=5.

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

def on_model(model):
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
    
    show_graph(G, node_color)

    import ipdb; ipdb.set_trace()

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
