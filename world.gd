extends Node2D

@onready var select_rect = $select_rect
@onready var tilemap = $tilemap
@onready var move_arrow = $move_arrow

func _ready():
    pass

func _process(_delta):
    if select_rect.selecting:
        for unit in get_tree().get_nodes_in_group("units"):
            var is_selected = select_rect.select_rect.intersects(unit.get_rect())
            unit.set_selected(is_selected)

    if Input.is_action_just_pressed("right_click"):
        var target_cell = tilemap.get_mouse_cell_astar()
        if target_cell != null:
            # create action
            var should_queue_action = Input.is_action_pressed("shift")
            var action = {
                "type": Unit.ActionType.MOVE,
                "target": target_cell
            }

            # give action to each selected unit
            for unit in get_tree().get_nodes_in_group("units"):
                if not unit.is_selected:
                    continue
                if should_queue_action:
                    unit.queue_action(action)
                else:
                    unit.give_action(action)

            # apply visual effect for player feedback
            move_arrow.arrow_point(target_cell)