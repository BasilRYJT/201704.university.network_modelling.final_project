import networkx
import csv
import sys
import zen

# Read csv files cleaned created using R
csv.field_size_limit(sys.maxsize)
userreader = csv.reader(
    open("C:\Users\CRAZY\PycharmProjects\Small_Projects\NMProject\lastfm-dataset-1K\UserData.csv", "rb"))
musicreader = csv.reader(
    open("C:\Users\CRAZY\PycharmProjects\Small_Projects\NMProject\lastfm-dataset-1K\MusicData.csv", "rb"))

MegaGraph = networkx.DiGraph()

# Test csv reader
"""
rowno = 0
for row in musicreader:
    if rowno == 0:
        print type(row)
        rowno += 1
        continue
    elif rowno >= 50:
        break
    else:
        rowno += 1
        print row
"""

# Calibrate graph creation
"""
rowno = 0
for row in musicreader:
    if rowno == 0:
        rowno += 1
        continue
    elif rowno >= 50:
        break
    else:
        rowno += 1
        MegaGraph.add_node(row[0])
        MegaGraph.add_node(row[3],id=row[2])
        MegaGraph.add_node(row[5],id=row[4])
        if MegaGraph.has_edge(row[0],row[3]):
            MegaGraph[row[0]][row[3]]["weight"] += 1
        if not MegaGraph.has_edge(row[0], row[3]):
            MegaGraph.add_edge(row[0],row[3],weight=1)
        if MegaGraph.has_edge(row[0], row[5]):
            MegaGraph[row[0]][row[5]]["weight"] += 1
        if not MegaGraph.has_edge(row[0], row[5]):
            MegaGraph.add_edge(row[0], row[5], weight=1)

print MegaGraph.edges()
print MegaGraph.get_edge_data('user_000003', 'Simple Plan')
print MegaGraph.get_edge_data('user_000003', 'One Day')
"""
"""
# Full graph creation (with GML)
rowno = 0
for row in userreader:
    if rowno == 0:
        rowno += 1
        continue
    else:
        rowno += 1
        MegaGraph.add_node(row[0], ntype="user", gender=row[1], age=row[2], country=row[3], rgtdate=row[4])

print MegaGraph.number_of_nodes()
print MegaGraph.number_of_edges()

rowno = 0
for row in musicreader:
    if rowno == 0:
        rowno += 1
        continue
    else:
        rowno += 1
        if not MegaGraph.has_node(row[3]):
            MegaGraph.add_node(row[3], ntype="artist", mbid=row[2])
        if not MegaGraph.has_node(row[5]):
            MegaGraph.add_node(row[5], ntype="song", mbid=row[4])
        if MegaGraph.has_edge(row[0], row[3]):
            MegaGraph[row[0]][row[3]]["weight"] += 1
        if not MegaGraph.has_edge(row[0], row[3]):
            MegaGraph.add_edge(row[0], row[3], weight=1)
        if MegaGraph.has_edge(row[0], row[5]):
            MegaGraph[row[0]][row[5]]["weight"] += 1
        if not MegaGraph.has_edge(row[0], row[5]):
            MegaGraph.add_edge(row[0], row[5], weight=1)

print MegaGraph.number_of_nodes()
print MegaGraph.number_of_edges()

# Export graph as GML file
networkx.write_gml(MegaGraph,
                   "C:\Users\CRAZY\PycharmProjects\Small_Projects\NMProject\lastfm-dataset-1K\MusicGraph.gml")
"""

def bibliograph(G):
    B = networkx.Graph()
    for node in G.nodes():
        B.add_node(node)
    for node1 in G.nodes():
        for node2 in G.nodes():
            uvweight = 0
            for comout in list(set(G.neighbors(node1)) & set(G.neighbors(node2))):
                uvweight += G[node1][comout]["weight"] * G.weight[node2][comout]["weight"]
            B.add_edge(node1, node2, weight=uvweight)
    return B



"""

# Test Zen compatibility with output
MegaGraphMirror = zen.io.gml.read(
    'C:\Users\CRAZY\PycharmProjects\Small_Projects\NMProject\lastfm-dataset-1K\MusicGraph.gml',
    weight_fxn=lambda x: x["weight"])

print MegaGraphMirror.matrix()
print MegaGraphMirror.num_nodes()
print MegaGraphMirror.num_edges()
print MegaGraphMirror.node_data("user_000003")
print MegaGraphMirror.node_data("Simple Plan")
"""





print MegaGraph.number_of_nodes()
print MegaGraph.number_of_edges()

# Export graph as GML file
networkx.write_gml(MegaGraph,
                   "C:\Users\CRAZY\PycharmProjects\Small_Projects\NMProject\lastfm-dataset-1K\MusicGraph.gml")