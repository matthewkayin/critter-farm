extends TileMap

const LAYER_TILE = 0

const NEIGHBOR_OFFSET = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

@onready var selection = $selection
@onready var outline = $outline

var grass_tiles = {}
var selecting = false
var selected_tile = null

var astar: AStar2D
var astar_point_id_lookup = {}

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
    selection.visible = false

    astar = AStar2D.new()
    for cell in get_used_cells(LAYER_TILE):
        var cell_data = get_cell_tile_data(LAYER_TILE, cell)
        if cell_data.get_custom_data("blocked"):
            continue

        var point_id = astar.get_available_point_id()
        astar.add_point(point_id, Vector2(cell))
        astar_point_id_lookup[cell] = point_id
    for cell in get_used_cells(LAYER_TILE):
        if not astar_point_id_lookup.has(cell):
            continue
        for neighbor_offset in NEIGHBOR_OFFSET:
            var child = cell + neighbor_offset
            if not astar_point_id_lookup.has(child): 
                continue
            astar.connect_points(astar_point_id_lookup[cell], astar_point_id_lookup[child])

func get_mouse_cell():
    var mouse_position = get_global_mouse_position()
    for cell in get_used_cells(LAYER_TILE):
        var cell_center = map_to_local(cell)
        var relative_mouse_position = mouse_position - cell_center
        var mouse_inside_cell = (abs(relative_mouse_position.x) * 9.0) + (abs(relative_mouse_position.y) * 16.0) <= 9.0 * 16.0
        if mouse_inside_cell:
            return cell
    return null

func is_cell_water(cell: Vector2i):
    var cell_atlas_coords = get_cell_atlas_coords(LAYER_TILE, cell)
    return cell_atlas_coords == Vector2i(15, 2)

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
        selected_tile = get_mouse_cell()
    if selecting and selected_tile != null:
        var cell_atlas_coords
        var cell_tile_data = get_cell_tile_data(LAYER_TILE, selected_tile)
        if cell_tile_data.get_custom_data("is_grass"):
            cell_atlas_coords = grass_tiles[cell_tile_data.get_custom_data("moisture")][Vector2i(2, 2)]
        else:
            cell_atlas_coords = get_cell_atlas_coords(LAYER_TILE, selected_tile)
        selection.region_rect.position = Vector2(cell_atlas_coords.x * 32, cell_atlas_coords.y * 16)
        selection.position = map_to_local(selected_tile)
        selection.visible = true
    else:
        selection.visible = false

# Pathfinding

func astar_get_path(from: Vector2i, to: Vector2i):
    var destination = null
    if astar_point_id_lookup.has(to):
        destination = to
    else:
        for neighbor_offset in NEIGHBOR_OFFSET:
            var child = to + neighbor_offset
            if not astar_point_id_lookup.has(child):
                continue
            if destination == null or (from - child).length() < (from - destination).length():
                destination = to + neighbor_offset
        if destination == null:
            destination = Vector2i(astar.get_point_position(astar.get_closest_point(to)))

    var from_id = astar_point_id_lookup[from]
    var to_id = astar_point_id_lookup[destination]
    var to_disabled = astar.is_point_disabled(to_id)
    if to_disabled:
        astar.set_point_disabled(to_id, false)

    var path = astar.get_point_path(from_id, to_id)
    path.remove_at(0)

    if to_disabled:
        astar.set_point_disabled(to_id, true)
    
    return path

func astar_set_point_disabled(point: Vector2i, value: bool):
    astar.set_point_disabled(astar_point_id_lookup[point], value)

func astar_is_point_disabled(point: Vector2i):
    return astar.is_point_disabled(astar_point_id_lookup[point])

func display_outline(cell: Vector2i):
    outline.position = map_to_local(cell)
    outline.visible = true
    for i in range(0, 3):
        var tween = get_tree().create_tween()
        tween.tween_interval(0.2)
        await tween.finished
        outline.visible = not outline.visible