extends AnimatedSprite2D

@onready var tilemap = get_node("../tilemap")

const MAX_PLAYS = 3
var play_count = 0

func _ready():
    arrow_hide()
    animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
    arrow_hide()

func arrow_hide():
    stop()
    frame = 0
    visible = false

func arrow_point(cell: Vector2i):
    arrow_hide()
    position = tilemap.map_to_local(cell)
    visible = true
    play_count = 0
    play()