extends Node2D

@onready var sprite = $sprite

enum SpriteAnimation {
    IDLE,
    WALK
}

const SPRITE_ANIMATION_NAME = {
    SpriteAnimation.IDLE: "idle",
    SpriteAnimation.WALK: "walk"
}

var direction: Vector2 = Vector2.DOWN
var sprite_animation = SpriteAnimation.IDLE

func _ready():
    add_to_group("units")

func get_rect() -> Rect2:
    return Rect2(position + Vector2(3, -2), Vector2(26, 17))

func _process(_delta):
    sprite.play(SPRITE_ANIMATION_NAME[sprite_animation] + "_" + ("front" if direction == Vector2.DOWN or direction == Vector2.RIGHT else "back"))
    sprite.flip_h = direction == Vector2.RIGHT or direction == Vector2.LEFT

func set_show_outline(value: bool):
    sprite.material.set_shader_parameter("show_outline", value)
