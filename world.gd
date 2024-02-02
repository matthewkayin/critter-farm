extends Node2D

@onready var select_rect = $select_rect

func _ready():
    pass

func _process(_delta):
    if select_rect.selecting:
        for unit in get_tree().get_nodes_in_group("units"):
            var is_selected = select_rect.select_rect.intersects(unit.get_rect())
            unit.set_show_outline(is_selected)

