extends Object
class_name Face

var id: String
var adjacent_faces = {}
var vertices = {}
var vertex_ids = []

var center_coordinates: Vector3

var color: Color
var height: float

func _init(new_id = null) -> void:
    if new_id == null:
        self.id = UUID.v4()
    elif new_id is int:
        self.id = str(new_id)
    else:
        self.id = new_id


func add_adjacent_face(adjacent_face: Face) -> void:
    self.adjacent_faces[adjacent_face.id] = adjacent_face
    
func add_vertex(vertex: Vertex) -> void:
    self.vertices[vertex.id] = vertex

func add_vertices(verts):
    for v in verts:
        add_vertex(v)
