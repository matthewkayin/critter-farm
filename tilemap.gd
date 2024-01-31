extends TileMap

const LAYER_TILE = 0

const NEIGHBOR_OFFSET = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

var grass_tiles = {}

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

func _process(delta):
    pass
