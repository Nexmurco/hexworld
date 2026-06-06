extends MultiMeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var gen = HexGenerator.new()
    gen.set_edge_segments(10)
    gen.generate_world()
    
    multimesh.instance_count = gen.count
    for i in range(gen.count):
        multimesh.set_instance_transform(i, gen.hex_id_to_transform[i])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass
