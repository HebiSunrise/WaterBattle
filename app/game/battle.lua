local ____lualib = require("lualib_bundle")
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery
local ____exports = {}
local ____utils = require("utils.utils")
local generate_random_integer = ____utils.generate_random_integer
local ____field = require("game.field")
local CellState = ____field.CellState
local Field = ____field.Field
____exports.Direction = Direction or ({})
____exports.Direction.HORIZONTAL = 0
____exports.Direction[____exports.Direction.HORIZONTAL] = "HORIZONTAL"
____exports.Direction.VERTICAL = 1
____exports.Direction[____exports.Direction.VERTICAL] = "VERTICAL"
function ____exports.Battle()
    local is_can_place_ship, create_ship, miss_around_ship, get_ship, has_ship_part, generate_uid, uid_counter, field, ships_uids, ships_bb, ships_lifes, index_to_ship_uid
    function is_can_place_ship(start, ____end)
        if not field.in_boundaries(start.x, start.y) or not field.in_boundaries(____end.x, ____end.y) then
            return false
        end
        do
            local y = start.y - 1
            while y <= ____end.y + 1 do
                do
                    local x = start.x - 1
                    while x <= ____end.x + 1 do
                        if field.in_boundaries(x, y) then
                            if field.get_value(x, y) == CellState.SHIP then
                                return false
                            end
                        end
                        x = x + 1
                    end
                end
                y = y + 1
            end
        end
        return true
    end
    function create_ship(x, y, length, direction)
        local ship_uid = generate_uid()
        ships_uids[#ships_uids + 1] = ship_uid
        ships_lifes[ship_uid] = length
        local start = {x = x, y = y}
        local ____end = {x = x, y = y}
        repeat
            local ____switch18 = direction
            local ____cond18 = ____switch18 == ____exports.Direction.HORIZONTAL
            if ____cond18 then
                do
                    local i = 0
                    while i < length do
                        index_to_ship_uid[field.get_index(x + i, y)] = ship_uid
                        field.set_value(x + i, y, CellState.SHIP)
                        i = i + 1
                    end
                end
                ____end = {x = x + length - 1, y = y}
                break
            end
            ____cond18 = ____cond18 or ____switch18 == ____exports.Direction.VERTICAL
            if ____cond18 then
                do
                    local i = 0
                    while i < length do
                        index_to_ship_uid[field.get_index(x, y + i)] = ship_uid
                        field.set_value(x, y + i, CellState.SHIP)
                        i = i + 1
                    end
                end
                ____end = {x = x, y = y + length - 1}
                break
            end
        until true
        ships_bb[ship_uid] = {start = start, ["end"] = ____end}
        return ship_uid
    end
    function miss_around_ship(ship)
        local ____ships_bb_ship_0 = ships_bb[ship]
        local start = ____ships_bb_ship_0.start
        local ____end = ____ships_bb_ship_0["end"]
        do
            local y = start.y - 1
            while y <= ____end.y + 1 do
                do
                    local x = start.x - 1
                    while x <= ____end.x + 1 do
                        if field.in_boundaries(x, y) then
                            if field.get_value(x, y) ~= CellState.SHIP then
                                field.set_value(x, y, CellState.MISS)
                            end
                        end
                        x = x + 1
                    end
                end
                y = y + 1
            end
        end
    end
    function get_ship(x, y)
        return index_to_ship_uid[field.get_index(x, y)]
    end
    function has_ship_part(x, y)
        return index_to_ship_uid[field.get_index(x, y)] ~= nil
    end
    function generate_uid()
        local ____uid_counter_1 = uid_counter
        uid_counter = ____uid_counter_1 + 1
        return ____uid_counter_1
    end
    uid_counter = 0
    ships_uids = {}
    ships_bb = {}
    ships_lifes = {}
    index_to_ship_uid = {}
    local function setup(fieldWidth, fieldHiegth)
        field = Field(fieldWidth, fieldHiegth)
    end
    local function auto_place_ships(ships)
        local dir_count = 2
        do
            local i = 0
            while i < #ships do
                do
                    local j = 0
                    while j < ships[i + 1].count do
                        local is_search = true
                        while is_search do
                            local start = {
                                x = generate_random_integer(field.width),
                                y = generate_random_integer(field.height)
                            }
                            local ____end = __TS__ObjectAssign({}, start)
                            local direction = generate_random_integer(dir_count)
                            repeat
                                local ____switch8 = direction
                                local ____cond8 = ____switch8 == ____exports.Direction.HORIZONTAL
                                if ____cond8 then
                                    ____end.x = ____end.x + ships[i + 1].length
                                    break
                                end
                                ____cond8 = ____cond8 or ____switch8 == ____exports.Direction.VERTICAL
                                if ____cond8 then
                                    ____end.y = ____end.y + ships[i + 1].length
                                    break
                                end
                            until true
                            if not is_can_place_ship(start, ____end) then
                                is_search = true
                            else
                                is_search = false
                                create_ship(start.x, start.y, ships[i + 1].length, direction)
                                log((((((((((("start: x:" .. tostring(start.x)) .. ", y:") .. tostring(start.y)) .. " end: x:") .. tostring(____end.x)) .. ", y:") .. tostring(____end.y)) .. ", dir:") .. tostring(direction)) .. ", leng:") .. tostring(ships[i + 1].length))
                            end
                        end
                        j = j + 1
                    end
                end
                i = i + 1
            end
        end
    end
    local function try_damage(x, y)
        if not has_ship_part(x, y) then
            field.set_value(x, y, CellState.MISS)
            return false
        end
        field.set_value(x, y, CellState.HIT)
        local ship = get_ship(x, y)
        ships_lifes[ship] = ships_lifes[ship] - 1
        if ships_lifes[ship] == 0 then
            miss_around_ship(ship)
        end
        return true
    end
    local function is_win()
        return __TS__ArrayEvery(
            ships_uids,
            function(____, ship) return ships_lifes[ship] == 0 end
        )
    end
    local function get_field()
        return field
    end
    return {setup = setup, auto_place_ships = auto_place_ships, try_damage = try_damage, get_field = get_field}
end
return ____exports
