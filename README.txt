MusicGraph

	directed: TRUE
	number of nodes: 367274
	number of edges: 1147642

Node Attributes

	ntype: node type [e.g. users, artist, song]
	gender: gender of user [e.g. M, F]*
	age: age of user
	country: country of user
	rgtdate: user registration date**
	mbid: mbid of artist or song***

Type of Nodes (with Attributes)

	users: {ntype="user", gender, age, country, rgtdate}
	artists: {ntype="artist", mbid}
	songs: {ntype="song", mbid}

Edge Attributes

	weight: number of interactions by user

Type of Edges

	edge(user, artist): user listened to artist Wa number of times, where Wa is the weight of the edge.
	edge(user, song): user listened to song Ws number of times, where Ws is the weight of the edge.


* For the sake of simplicity, nonbinary gender identities were not considered.
** The dates are stored in a string with format, "Oct 30, 2005".
*** MBID is a 36 character Universally Unique Identifier that is permanently assigned to each entity in the database