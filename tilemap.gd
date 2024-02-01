extends TileMap

const LAYER_TILE = 0

const NEIGHBOR_OFFSET = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

@onready var selection = $selection

var grass_tiles = {}
var selecting = false
var selected_tile = null

func _ready():
    for i in range(-3, 3):
        grass_tiles[i] = {}
    var tileset_source = tile_set.get_source(tile_set.get_source_id(0))
    for tile_id in range(0, tileset_source.get_tiles_count()):
        var atlas_coords = tileset_source.get_tile_id(tile_id)
        var tile_data = tileset_source.get_tile_data(atlas_coords, 0)
        if tile_data.get_custom_data("is_grass"):
            grass_tiles[tile_data.get_custom_data("moisture")][tile_data.get_custom_data("offset")] = atlas_coords
    update_tile_edges()
    start_selecting()

func update_tile_edges():
    for cell in get_used_cells(LAYER_TILE):
        var tile_data = get_cell_tile_data(LAYER_TILE, cell)
        if not tile_data.get_custom_data("is_grass"):
            continue

        # determine neighbors
        var has_neighbors = [false, false, false, false]
        var neighbor_count = 0
        for i in range(0, 4):
            var neighbor_tile_data = get_cell_tile_data(LAYER_TILE, cell + NEIGHBOR_OFFSET[i])
            has_neighbors[i] = neighbor_tile_data != null
            if has_neighbors[i]:
                neighbor_count += 1

        # determine cell offset
        var offset = Vector2i.ZERO
        if neighbor_count == 0:
            offset = Vector2(2, 2)
        else:
            for i in range(0, 4):
                if not has_neighbors[i]:
                    offset += NEIGHBOR_OFFSET[i]

        var moisture = tile_data.get_custom_data("moisture")
        set_cell(LAYER_TILE, cell, tile_set.get_source_id(0), grass_tiles[moisture][offset])

func start_selecting():
    selecting = true
    selected_tile = null

func _process(_delta):
    if selecting:
        var mouse_position = get_global_mouse_position()
        selected_tile = null
        for cell in get_used_cells(LAYER_TILE):
            var cell_center = map_to_local(cell)
            var relative_mouse_position = mouse_position - cell_center
            var mouse_inside_cell = (abs(relative_mouse_position.x) * 9.0) + (abs(relative_mouse_position.y) * 16.0) <= 9.0 * 16.0
            if mouse_inside_cell:
                selected_tile = cell
                var cell_atlas_coords = get_cell_atlas_coords(LAYER_TILE, cell)
                selection.region_rect.position = Vector2(cell_atlas_coords.x * 32, cell_atlas_coords.y * 16)
                break
    if selecting and selected_tile != null:
        selection.position = map_to_local(selected_tile)
        selection.visible = true
    else:
        selection.visible = false