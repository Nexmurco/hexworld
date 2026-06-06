extends Node2D

enum popup_ids {
    test1,
    test2
}

var popup_id_to_label = { 
    popup_ids.test1: "test 1",
    popup_ids.test2: "test 2"
}

var mouse_pos_click
@export var popup_menu: PopupMenu   



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    print(popup_id_to_label)
    for popup_id in popup_ids:
        var id = popup_ids[popup_id]
        popup_menu.add_item(popup_id_to_label[id], id)  



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("ui_right_click"):
        generate_popup()
        

func generate_popup() -> void:
    mouse_pos_click = get_global_mouse_position()
    popup_menu.popup(Rect2(mouse_pos_click.x, mouse_pos_click.y, popup_menu.size.x, popup_menu.size.y))


func _on_popup_menu_id_pressed(id: int) -> void:
    print("id: " + str(id))
    
    match id:
        popup_ids.test1:
            print("test 1 pressed")
        popup_ids.test2:
            print("test 2 pressed")

func _on_popup_menu_index_pressed(index: int) -> void:
    print("index: " + str(index))
