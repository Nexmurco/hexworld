extends MeshInstance3D

var data: ChunkData

@export_category("Load Data")
@export var file_path: String
@export var triangle_vertices: Array[Vector3]
@export var should_load_data: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if should_load_data:
        pass
        
    else:
        data = ChunkData.new(0,20,1)
        generate_chunk_data()
        data.convert_ico_to_hex_data()
    
    data.create_mesh_face_data()
    var surface_array = data.generate_surface_array()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES , surface_array)
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass


func construct_chunk_from_data() -> void:
    pass
    
func load_chunk_data() -> void:
    pass

func save_chunk_data() -> void:
    pass

func generate_chunk_data() -> void:
    Generator.generate_triangle_chunk(data.ico, Vertex.new(0, triangle_vertices[0]), Vertex.new(1, triangle_vertices[1]), Vertex.new(2, triangle_vertices[2]), data.partitions)
  
