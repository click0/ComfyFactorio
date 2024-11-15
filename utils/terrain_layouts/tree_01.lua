local math_floor = math.floor
local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove

local NoiseVector = require 'utils.functions.noise_vector_path'

local function get_vector()
    local x = 1000 - math_random(0, 2000)
    local y = -1000 + math_random(0, 1100)

    x = x * 0.001
    y = y * 0.001
    return { x, y }
end

local function can_draw_branch(surface, chunk_position)
    for x = -3, 3, 1 do
        for y = -3, 3, 1 do
            if not surface.is_chunk_generated({ chunk_position[1] + x, chunk_position[2] + y }) then
                return false
            end
        end
    end
    return true
end

local function draw_branch(surface, key)
    local position = storage.tree_points[key][1]
    local vector = storage.tree_points[key][3]
    local size = storage.tree_points[key][4]

    if surface.count_tiles_filtered({ name = 'green-refined-concrete', area = { { position.x - 32, position.y - 32 }, { position.x + 32, position.y + 32 } } }) > 960 then
        table_remove(storage.tree_points, key)
        return
    end

    local tiles = NoiseVector.noise_vector_tile_path(surface, 'green-refined-concrete', position, vector, size * 4, size * 0.25)

    for i = #tiles - math_random(0, 3), #tiles, 1 do
        table_insert(
            storage.tree_points,
            {
                tiles[i].position,
                { math_floor(tiles[i].position.x / 32), math_floor(tiles[i].position.y / 32) },
                get_vector(position),
                math_random(8, 16)
            }
        )
    end

    table_remove(storage.tree_points, key)
end

local function on_init()
    storage.chunks_charted = {}
    storage.tree_points = {}

    storage.tree_points[1] = { { x = 0, y = 0 }, { 0, 0 }, { 0, -1 }, 16 }
    --position | chunk position | vector | size
end

local function tick()
    local surface = game.surfaces[1]
    for key, point in pairs(storage.tree_points) do
        if can_draw_branch(surface, point[2]) then
            draw_branch(surface, key)
        end
    end

    game.print(#storage.tree_points)
end

local Event = require 'utils.event'
Event.on_init(on_init)
Event.on_nth_tick(120, tick)
