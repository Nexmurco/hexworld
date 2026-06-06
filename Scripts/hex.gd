extends Object
class_name Hex

var id: int
var f: Face

var v: Vertex
var color: Color
var height: float

###########################
#  OLD FUNCTIONALITY      #
###########################

# func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
#     var mouse_click = event as InputEventMouseButton
#     if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
#         print("clicked hex " + name)


# func _on_area_3d_mouse_entered() -> void:
#     outline_node.set_surface_override_material(0, material_active)


# func _on_area_3d_mouse_exited() -> void:
#     outline_node.set_surface_override_material(0, null)
