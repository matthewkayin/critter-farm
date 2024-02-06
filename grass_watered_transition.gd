extends Sprite2D

var progress = 0.0

func _ready():
    pass

func initialize(atlas_coords: Vector2i):
    region_rect.position = Vector2(atlas_coords.x * 32, atlas_coords.y * 16)
    material.set_shader_parameter("region_rect_pos", region_rect.position)
    var tween = get_tree().create_tween()
    progress = 0.0
    tween.tween_property(self, "progress", 1.0, 1.0)
    await tween.finished
    queue_free()

func _process(_delta):
    material.set_shader_parameter("progress", progress)
