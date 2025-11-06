local ____lualib = require("lualib_bundle")
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local ____exports = {}
local ____utils = require("utils.utils")
local generate_random_integer = ____utils.generate_random_integer
local ____battle = require("game.battle")
local ShotState = ____battle.ShotState
local ____field = require("game.field")
local CellState = ____field.CellState
function ____exports.Bot(battle, player_idx)
    local on_kill, on_hit, on_miss, generate_pos, delete_idx, delete_neigh, detect_neighbors, get_random_neighbor, vertical_search, down_search, up_search, horizontal_search, left_search, right_search, last_hit, first_hit, available_indexes, neighbors, was_hit, was_no_hit
    function on_kill(info, field)
        if info.data then
            for ____, pos in ipairs(info.data) do
                local idx = __TS__ArrayIndexOf(
                    available_indexes,
                    field.get_index(pos.x, pos.y)
                )
                if idx ~= -1 then
                    __TS__ArraySplice(available_indexes, idx, 1)
                end
            end
        end
        delete_idx(field, info.shot_pos)
        last_hit.x = info.shot_pos.x
        last_hit.y = info.shot_pos.y
        delete_neigh()
        was_no_hit = true
        was_hit = false
        first_hit.x = -1
        first_hit.y = -1
        last_hit.x = -1
        last_hit.y = -1
    end
    function on_hit(info, field)
        if was_no_hit then
            first_hit.x = info.shot_pos.x
            first_hit.y = info.shot_pos.y
            was_no_hit = false
        end
        last_hit.x = info.shot_pos.x
        last_hit.y = info.shot_pos.y
        was_hit = true
        delete_idx(field, info.shot_pos)
    end
    function on_miss(info, field)
        delete_idx(field, info.shot_pos)
        was_hit = false
    end
    function generate_pos(filed)
        local index = generate_random_integer(#available_indexes - 1)
        local x = available_indexes[index + 1] % filed.width
        local y = math.floor(available_indexes[index + 1] / filed.height)
        return {x = x, y = y}
    end
    function delete_idx(field, pos)
        local idx = __TS__ArrayIndexOf(
            available_indexes,
            field.get_index(pos.x, pos.y)
        )
        __TS__ArraySplice(available_indexes, idx, 1)
    end
    function delete_neigh()
        if first_hit.x ~= last_hit.x or first_hit.y ~= last_hit.y then
            if #neighbors > 0 then
                __TS__ArraySplice(neighbors, 0, #neighbors)
            end
        end
    end
    function detect_neighbors(field)
        if field.in_boundaries(first_hit.x + 1, first_hit.y) and field.get_value(first_hit.x + 1, first_hit.y) ~= CellState.MISS then
            neighbors[#neighbors + 1] = {x = first_hit.x + 1, y = first_hit.y}
        end
        if field.in_boundaries(first_hit.x - 1, first_hit.y) and field.get_value(first_hit.x - 1, first_hit.y) ~= CellState.MISS then
            neighbors[#neighbors + 1] = {x = first_hit.x - 1, y = first_hit.y}
        end
        if field.in_boundaries(first_hit.x, first_hit.y + 1) and field.get_value(first_hit.x, first_hit.y + 1) ~= CellState.MISS then
            neighbors[#neighbors + 1] = {x = first_hit.x, y = first_hit.y + 1}
        end
        if field.in_boundaries(first_hit.x, first_hit.y - 1) and field.get_value(first_hit.x, first_hit.y - 1) ~= CellState.MISS then
            neighbors[#neighbors + 1] = {x = first_hit.x, y = first_hit.y - 1}
        end
    end
    function get_random_neighbor()
        local next = generate_random_integer(#neighbors - 1)
        local x = neighbors[next + 1].x
        local y = neighbors[next + 1].y
        __TS__ArraySplice(neighbors, next, 1)
        return {x = x, y = y}
    end
    function vertical_search(field)
        local pos = {x = 0, y = 0}
        local is_down_search = first_hit.y > last_hit.y
        if is_down_search then
            pos.y = down_search(field)
        end
        local is_up_search = first_hit.y < last_hit.y
        if is_up_search then
            pos.y = up_search(field)
        end
        pos.x = last_hit.x
        return pos
    end
    function down_search(field)
        if field.get_value(last_hit.x, last_hit.y - 1) ~= CellState.MISS then
            return last_hit.y - 1
        end
        return first_hit.y + 1
    end
    function up_search(field)
        if field.get_value(last_hit.x, last_hit.y + 1) ~= CellState.MISS then
            return last_hit.y + 1
        end
        return first_hit.y - 1
    end
    function horizontal_search(field)
        local pos = {x = 0, y = 0}
        local is_right_search = first_hit.x < last_hit.x
        if is_right_search then
            pos.x = right_search(field)
        end
        local is_left_search = first_hit.x > last_hit.x
        if is_left_search then
            pos.x = left_search(field)
        end
        pos.y = last_hit.y
        return pos
    end
    function left_search(field)
        if field.get_value(last_hit.x - 1, last_hit.y) ~= CellState.MISS then
            return last_hit.x - 1
        end
        return first_hit.x + 1
    end
    function right_search(field)
        if field.get_value(last_hit.x + 1, last_hit.y) ~= CellState.MISS then
            return last_hit.x + 1
        end
        return first_hit.x - 1
    end
    last_hit = {x = -1, y = -1}
    first_hit = {x = -1, y = -1}
    available_indexes = {}
    neighbors = {}
    was_hit = false
    was_no_hit = true
    local function setup()
        local opponent = battle.get_opponent(player_idx)
        local field = opponent.get_field()
        do
            local y = 0
            while y < field.height do
                do
                    local x = 0
                    while x < field.width do
                        available_indexes[#available_indexes + 1] = field.get_index(x, y)
                        x = x + 1
                    end
                end
                y = y + 1
            end
        end
    end
    local function shot()
        local opponent = battle.get_opponent(player_idx)
        local field = opponent.get_field()
        local pos = {x = 0, y = 0}
        if was_no_hit then
            pos = generate_pos(field)
        end
        local is_same_first_last_hit = first_hit.x == last_hit.x and first_hit.y == last_hit.y
        if was_hit and is_same_first_last_hit then
            if #neighbors == 0 then
                detect_neighbors(field)
            end
            if #neighbors > 0 then
                pos = get_random_neighbor()
            end
        end
        local is_vertical_search = first_hit.x == last_hit.x and first_hit.y ~= last_hit.y
        if is_vertical_search then
            pos = vertical_search(field)
        end
        local is_horizontal_search = first_hit.x ~= last_hit.x and first_hit.y == last_hit.y
        if is_horizontal_search then
            pos = horizontal_search(field)
        end
        local result = battle.shot(pos.x, pos.y)
        repeat
            local ____switch13 = result.state
            local ____cond13 = ____switch13 == ShotState.KILL
            if ____cond13 then
                on_kill(result, field)
                break
            end
            ____cond13 = ____cond13 or ____switch13 == ShotState.HIT
            if ____cond13 then
                on_hit(result, field)
                break
            end
            ____cond13 = ____cond13 or ____switch13 == ShotState.MISS
            if ____cond13 then
                on_miss(result, field)
                break
            end
        until true
        if first_hit.x ~= -1 then
            was_hit = true
        end
        delete_neigh()
        return result
    end
    return {setup = setup, shot = shot}
end
return ____exports
