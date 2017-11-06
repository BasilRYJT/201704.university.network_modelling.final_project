import gexf

csv.field_size_limit(sys.maxsize)
monthreader = csv.reader(
    open("C:\Users\CRAZY\PycharmProjects\Small_Projects\NMProject\MonthData.csv", "rb"))

rowno = 0
for row in monthreader:
    if rowno == 0:
        rowno += 1
        continue
    if rowno == 1:
        rowno += 1
        month = monthreader[2]
        G = networkx.DiGraph()
        G.add_node(monthreader[0])
        G.add_node(monthreader[1])
        G.add_edge(monthreader[0],monthreader[1],weight=monthreader[3])
    else:
        if monthreader[2] == month:
            if not G.has_node(monthreader[0])
            G.add_node(monthreader[0])
            G.add_node(monthreader[1])
            G.add_edge(monthreader[0], monthreader[1], weight=monthreader[3])

gexf = gexf.Gexf('Your Name','28-11-2012')
#make an undirected dynamical graph
graph = gexf.addGraph('undirected','dynamic','28-11-2012',timeformat='date')
#you add nodes with a unique id
graph.addNode(Source,"source_id")
#make edge with unique id, the edge has time duration from start to end
graph.addEdge(edge_id,Source,Target,start = Date , end = Date)
#write the gexf format to fileout
gexf.write(fileOut)