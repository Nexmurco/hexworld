extends Object
class_name Vertex

var id: String
var coordinates: Vector3

var mesh_index: int

var adjacent_vertices = {}
var faces = {}
var edges = []

var parent: Vertex
var children_vertices = {}

func _init(new_id = null, new_coordinates = null) -> void:
    if new_id == null:
        self.id = UUID.v4()
    elif new_id is int:
        self.id = str(new_id)
    else:
        self.id = new_id
        
    
    if new_coordinates:
        self.coordinates = new_coordinates

func add_adjacent_vertex(adjacent_vertex: Vertex) -> void:
    self.adjacent_vertices[adjacent_vertex.id] = adjacent_vertex
    
func add_face(new_face: Face) -> void:
    self.faces[new_face.id] = new_face
    
func add_edge(new_edge: Edge) -> void:
    self.edges.append(new_edge)

func set_parent_vertex(vert: Vertex):
    self.parent = vert
    vert.add_child_vertex(self)

func add_child_vertex(vert: Vertex):
    self.children_vertices[vert.id] = vert

func clone():
    var cloned_vert = Vertex.new(UUID.v4(), coordinates)
    cloned_vert.parent = self
    add_child_vertex(cloned_vert)
    
    return cloned_vert
