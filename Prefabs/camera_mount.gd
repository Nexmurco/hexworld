extends Node3D

@export var camera: Node3D
var mouse_sensitivity: float = 1
var mouse_sensitivity_rads: float = mouse_sensitivity * PI / 360

var verticality: float

var upper_verticality: float = 0.99
var lower_verticality: float = 0.1

var min_cam_dist_lower_verticality: float = 0.1
var max_cam_dist_lower_verticality: float = 0.9

var min_camera_dist: float = 1
var max_camera_dist: float = 500
@export var zoom_speed: float = 1

var dragging: bool = false

var camera_correction_speed: float = PI/360

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    calc_verticality()

func _process(_delta: float) -> void:
    
    if calc_verticality() < lower_verticality:
        global_rotate(camera.global_position.cross(global_position).normalized(), camera_correction_speed)
        


    
func calc_verticality():
    verticality = (camera.global_position - global_position).normalized().dot(global_position.normalized())
    return verticality


func get_lower_verticality_from_zoom():
    var zoom_percent = (camera.position.length() - min_camera_dist) / (max_camera_dist - min_camera_dist) 
    var new_v = min_cam_dist_lower_verticality + (zoom_percent * (max_cam_dist_lower_verticality - min_cam_dist_lower_verticality))
    return new_v
    

func _input(event):
    if event is InputEventMouseButton:
        if (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN) and event.pressed:
            
            if event.button_index == MOUSE_BUTTON_WHEEL_UP :
                if camera.position.length() > min_camera_dist:
                    camera.position += camera.position.normalized() * -zoom_speed
                if camera.position.length() < min_camera_dist:
                    camera.position = camera.position.normalized() * min_camera_dist
                
                
                
                    
            elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                if camera.position.length() < max_camera_dist:
                    camera.position += camera.position.normalized() * zoom_speed
                if camera.position.length() > max_camera_dist:
                    camera.position = camera.position.normalized() * max_camera_dist
            
            lower_verticality = get_lower_verticality_from_zoom()
        


func _unhandled_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
        dragging = event.pressed
        if dragging:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        else:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
    if event is InputEventMouseMotion and dragging:
        rotate(position.normalized(), mouse_sensitivity_rads * event.relative.x)
        
        calc_verticality()
        
        var y_direction = sign(-event.relative.y)
        if (y_direction > 0 and verticality < upper_verticality) or (y_direction < 0 and verticality > lower_verticality):                
            var y_rotation = camera.global_position.cross(global_position).normalized()
            global_rotate(y_rotation, -event.relative.y * mouse_sensitivity_rads)
        

        
    camera.look_at(position, Vector3.UP)
