extends Node3D

@export var camera: Node3D
@export var hex_multi_mesh: MultiMeshInstance3D


var pent_scene = preload("res://Prefabs/pent.tscn")
var hex_scene = preload("res://Prefabs/hex.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #need to get sphere raidus for this
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass
