extends Object
class_name Solid

var vertices = {}
var faces = {}
var edge_to_children = {}
var edge_to_faces = {}
var vert_to_faces = {}

var parent: Solid

func set_parent(parent_solid: Solid):
    parent = parent_solid
    vertices = parent_solid.vertices.duplicate(true)

func create_face_with_id(id) -> Face:
    var f = Face.new(id)
    faces[f.id] = f
    return f

func create_face() -> Face:
    return create_face_with_id(UUID.v4())

func add_face(face: Face):
    faces[face.id] = face

func add_vertex(v: Vertex):
    vertices[v.id] = v

func create_vertex_id(id: String) -> Vertex:
    var v = Vertex.new(id)
    add_vertex(v)
    return v

func create_vertex_at_position(position: Vector3) -> Vertex:
    var v = Vertex.new(UUID.v4(), position)
    add_vertex(v)
    return v

func create_vertex_with_id(id: String, position: Vector3) -> Vertex:
    var v = Vertex.new(id, position)
    add_vertex(v)
    return v

func get_vertex(vertex_id: String):
    if vertex_id in vertices:
        return vertices[vertex_id]
    return null

func add_edge_by_ids(id1: String, id2: String):
    if id1 in vertices and id2 in vertices:
        add_edge(vertices[id1], vertices[id2])
        return true
    
    return null

func add_edge(v1: Vertex, v2: Vertex):
    v1.add_adjacent_vertex(v2)
    v2.add_adjacent_vertex(v1)

func add_edge_by_id(vertex_id_1: String, vertex_id_2: String):
    var vert1 = vertices[vertex_id_1]
    var vert2 = vertices[vertex_id_2]

    vert1.add_adjacent_vertex(vert2)
    vert2.add_adjacent_vertex(vert1)

func add_edge_child(vertex_id_1: String, vertex_id_2: String,  vertex_id_child: String):    
    var id_set = [vertex_id_1, vertex_id_2]
    Utility.push_back_dict_array(edge_to_children, id_set, vertex_id_child)

func get_edge_children(vertex_id_1: String, vertex_id_2: String):    
    var id_set = [vertex_id_1, vertex_id_2]

    if id_set in edge_to_children:
        return edge_to_children[id_set]
    
    return null

func set_adjacent_faces(face1: Face, face2: Face):
    if face1.id in faces and face2.id in faces:
        faces[face1.id].add_adjacent_face(face2)
        faces[face2.id].add_adjacent_face(face1)
    return null
