extends Camera2D

@onready var viewport_rect = get_viewport_rect()
const DRAG_MARGIN: int = 5
const DRAG_SPEED: float = 300.0

func _ready():
    pass 

func _process(delta):
    if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        if Input.is_action_just_pressed("left_click"):
            Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
        else:
            return
    if Input.mouse_mode == Input.MOUSE_MODE_CONFINED and Input.is_action_just_pressed("escape"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    var mouse_position = get_viewport().get_mouse_position()
    var drag_direction = Vector2.ZERO
    if mouse_position.x <= DRAG_MARGIN:
        drag_direction.x = -1
    elif mouse_position.x >= viewport_rect.size.x - DRAG_MARGIN:
        drag_direction.x = 1
    if mouse_position.y <= DRAG_MARGIN:
        drag_direction.y = -1
    elif mouse_position.y >= viewport_rect.size.y - DRAG_MARGIN:
        drag_direction.y = 1

    position += drag_direction * DRAG_SPEED * delta