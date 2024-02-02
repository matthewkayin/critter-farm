extends Node2D

var selecting = false
var select_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
var select_origin: Vector2 = Vector2.ZERO

func _ready():
    pass 

func _draw():
    if selecting:
        draw_rect(select_rect, Color.WHITE, false)

func _process(_delta):
    if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        return
    if Input.is_action_just_pressed("left_click"):
        select_origin = get_global_mouse_position()
        select_rect = Rect2(select_origin, Vector2(1, 1))
        selecting = true
        queue_redraw()
    elif selecting and Input.is_action_pressed("left_click"):
        var mouse_position = get_global_mouse_position()
        select_rect = Rect2(select_origin, mouse_position - select_origin if mouse_position != select_origin else Vector2(1, 1)).abs()
        queue_redraw()
    elif Input.is_action_just_released("left_click"):
        selecting = false
        queue_redraw()