extends Node2D

@onready var sprite = $sprite
@onready var tilemap = get_node("../tilemap")

enum SpriteAnimation {
    IDLE,
    WALK
}

const SPRITE_ANIMATION_NAME = {
    SpriteAnimation.IDLE: "idle",
    SpriteAnimation.WALK: "walk"
}

const SPEED = 100.0

var direction: Vector2 = Vector2.DOWN
var sprite_animation = SpriteAnimation.IDLE
var current_cell: Vector2
var target_cell: Vector2
var target_position: Vector2
var is_moving = false
var path = []
var is_selected = false

func _ready():
    add_to_group("units")
    current_cell = tilemap.local_to_map(position)
    target_cell = current_cell
    target_position = tilemap.map_to_local(target_cell)
    tilemap.astar_set_point_disabled(current_cell, true)

func get_rect() -> Rect2:
    return Rect2(position + Vector2(3, -2), Vector2(26, 17))

func _process(delta):
    # Movement
    if not is_moving:
        try_move_to_next_path_point()
    if is_moving:
        var movement_left = SPEED * delta
        while movement_left > 0:
            # Movement Step
            var step = min(position.distance_to(target_position), movement_left)
            position += position.direction_to(target_position) * step
            movement_left -= step

            # Movement Reached Target
            if position == target_position:
                tilemap.astar_set_point_disabled(current_cell, false)
                current_cell = target_cell
                is_moving = false
                try_move_to_next_path_point()
                if not is_moving:
                    break

    # Update Sprite
    sprite_animation = SpriteAnimation.WALK if is_moving else SpriteAnimation.IDLE
    sprite.play(SPRITE_ANIMATION_NAME[sprite_animation] + "_" + ("front" if direction == Vector2.DOWN or direction == Vector2.RIGHT else "back"))
    sprite.flip_h = direction == Vector2.RIGHT or direction == Vector2.LEFT

func set_selected(value: bool):
    is_selected = value
    sprite.material.set_shader_parameter("show_outline", value)

func path_to(point: Vector2i):
    path = tilemap.astar_get_path(target_cell, point)

func try_move_to_next_path_point():
    if path.size() == 0: 
        is_moving = false
        return
    
    direction = current_cell.direction_to(path[0])
    if tilemap.astar_is_point_disabled(path[0]):
        is_moving = false
        return
    target_cell = path[0]
    path.remove_at(0)
    target_position = tilemap.map_to_local(target_cell)
    tilemap.astar_set_point_disabled(target_cell, true)
    is_moving = true
