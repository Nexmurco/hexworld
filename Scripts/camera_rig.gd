extends Node3D

@export var speed: float = 0.1
@export var speed_rotation: float = 100
@export var orbit_distance: float = 2.0
@export var camera_mount: Node3D
@export var camera: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:    
    var orth1 = camera.global_position.cross(camera_mount.global_position).normalized()
    var orth2 = orth1.cross(camera_mount.global_position).normalized()
    camera.look_at(camera_mount.global_position, orth2)
    set_orbit_distance(orbit_distance)
    
func set_orbit_distance(dist) -> void:
    orbit_distance = dist
    camera_mount.position = Vector3(0.0, 0.0, orbit_distance)
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

    
    var orth1 = camera.global_position.cross(camera_mount.global_position).normalized()
    var orth2 = orth1.cross(camera_mount.global_position).normalized()
    
    if Input.is_action_pressed("ui_up"):
        rotate(orth1, speed/orbit_distance)
    if Input.is_action_pressed("ui_down"):
        rotate(orth1, -speed/orbit_distance)
    if Input.is_action_pressed("ui_right"):
        rotate(orth2, speed/orbit_distance)
    if Input.is_action_pressed("ui_left"):
        rotate(orth2, -speed/orbit_distance)
        
    camera.look_at(camera_mount.global_position, orth2)
