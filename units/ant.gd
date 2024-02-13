extends Node2D
class_name Unit

@onready var sprite = $sprite
@onready var item_sprite = $item_sprite
@onready var move_timeout_timer = $move_timeout_timer
@onready var tilemap = get_node("../tilemap")

enum ActionType {
    MOVE,
    COLLECT_WATER
}

enum HeldItem {
    NONE,
    WATER
}

const SPEED = 100.0
const MOVE_TIMEOUT = 1.0

var direction: Vector2 = Vector2.DOWN
var current_cell: Vector2
var target_cell: Vector2
var target_position: Vector2
var actions = []
var current_action = null
var path = []
var is_moving = false
var is_selected = false
var held_item = HeldItem.NONE

func _ready():
    add_to_group("units")
    current_cell = tilemap.local_to_map(position)
    target_cell = current_cell
    target_position = tilemap.map_to_local(target_cell)
    tilemap.astar_set_point_disabled(current_cell, true)

    move_timeout_timer.timeout.connect(_on_move_timeout)

func has_goal():
    return is_moving or path.size() > 0

func get_rect() -> Rect2:
    return Rect2(position - Vector2(11.5, 8.5), Vector2(26, 17))

func _process(delta):
    # Movement
    if current_action == null and actions.size() != 0:
        start_next_action()
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
                # End movement
                if not is_moving:
                    if current_action.type == ActionType.COLLECT_WATER and current_cell.distance_to(current_action.target) == 1:
                        direction = current_cell.direction_to(current_action.target)
                        held_item = HeldItem.WATER
                    current_action = null
                    break

    # Update Sprite
    var is_holding = held_item != HeldItem.NONE
    var sprite_animation = "walk" if is_moving else "idle"
    if is_holding:
        sprite_animation = "hold_" + sprite_animation
    sprite_animation += "_front" if direction == Vector2.DOWN or direction == Vector2.RIGHT else "_back"
    sprite.play(sprite_animation) 
    sprite.flip_h = direction == Vector2.RIGHT or direction == Vector2.LEFT

    item_sprite.visible = is_holding
    if item_sprite.visible:
        item_sprite.position = Vector2(-4, -10) if direction == Vector2.DOWN or direction == Vector2.RIGHT else Vector2(6, -18)
        if not is_moving and sprite.frame == 1:
            item_sprite.position.y += 1
        elif is_moving and (item_sprite.frame == 1 or item_sprite.frame == 2):
            item_sprite.position.x += 1
        if sprite.flip_h:
            item_sprite.position.x *= -1
        item_sprite.speed_scale = 1.667 if is_moving else 1.0
        if held_item == HeldItem.WATER:
            item_sprite.play("water")

func set_selected(value: bool):
    is_selected = value
    sprite.material.set_shader_parameter("show_outline", value)

func give_action(action):
    current_action = null
    actions = [action]
    start_next_action()

func queue_action(action):
    actions.push_back(action)
    if current_action == null:
        start_next_action()

func start_next_action():
    current_action = actions[0]
    actions.remove_at(0)

    if current_action.type == ActionType.MOVE:
        path_to(current_action.target)
    elif current_action.type == ActionType.COLLECT_WATER:
        if current_cell.distance_to(current_action.target) == 1:
            direction = current_cell.direction_to(current_action.target)
            held_item = HeldItem.WATER
            current_action = null
        else:
            path_to(current_action.target)

func path_to(point: Vector2i):
    path = tilemap.astar_get_path(target_cell, point)

func try_move_to_next_path_point():
    if path.size() == 0: 
        is_moving = false
        return
    
    direction = current_cell.direction_to(path[0])
    if tilemap.astar_is_point_disabled(path[0]):
        is_moving = false
        if move_timeout_timer.is_stopped():
            move_timeout_timer.start(MOVE_TIMEOUT)
        return
    move_timeout_timer.stop()
    target_cell = path[0]
    path.remove_at(0)
    target_position = tilemap.map_to_local(target_cell)
    tilemap.astar_set_point_disabled(target_cell, true)
    is_moving = true

func _on_move_timeout():
    # Possible TODO, have unit re-pathfind under certain conditions
    path.clear()
    is_moving = false