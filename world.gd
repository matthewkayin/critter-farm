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
        var target_cell = tilemap.get_mouse_cell()
        if target_cell != null:
            for unit in get_tree().get_nodes_in_group("units"):
                if not unit.is_selected:
                    continue
                unit.path_to(target_cell)
                move_arrow.arrow_point(target_cell)
    
    if move_arrow.visible:
        var should_hide_arrow = true
        for unit in get_tree().get_nodes_in_group("units"):
            if not unit.is_selected:
                continue
            if unit.has_goal():
                should_hide_arrow = false
        if should_hide_arrow:
            move_arrow.hide()