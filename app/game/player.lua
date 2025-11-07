local ____lualib = require("lualib_bundle")
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local ____exports = {}
local ____utils = require("utils.utils")
local copy = ____utils.copy
local generate_random_integer = ____utils.generate_random_integer
local ____field = require("game.field")
local CellState = ____field.CellState
local Field = ____field.Field
____exports.Direction = Direction or ({})
____exports.Direction.HORIZONTAL = 0
____exports.Direction[____exports.Direction.HORIZONTAL] = "HORIZONTAL"
____exports.Direction.VERTICAL = 1
____exports.Direction[____exports.Direction.VERTICAL] = "VERTICAL"
____exports.ShotState = ShotState or ({})
____exports.ShotState.HIT = 0
____exports.ShotState[____exports.ShotState.HIT] = "HIT"
____exports.ShotState.MISS = 1
____exports.ShotState[____exports.ShotState.MISS] = "MISS"
____exports.ShotState.KILL = 2
____exports.ShotState[____exports.ShotState.KILL] = "KILL"
____exports.ShotState.ERROR = 3
____exports.ShotState[____exports.ShotState.ERROR] = "ERROR"
function ____exports.Player()
    local is_can_place_ship, create_ship, generate_uid, uid_counter, field, ships_uids, ships_bb, ships_lifes, index_to_ship_uid
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
                            end
                        end
                        j = j + 1
                    end
                end
                i = i + 1
            end
        end
    end
    local function miss_around_ship(ship)
        local ____ships_bb_ship_0 = ships_bb[ship]
        local start = ____ships_bb_ship_0.start
        local ____end = ____ships_bb_ship_0["end"]
        local misses = {}
        do
            local y = start.y - 1
            while y <= ____end.y + 1 do
                do
                    local x = start.x - 1
                    while x <= ____end.x + 1 do
                        if field.in_boundaries(x, y) then
                            if field.get_value(x, y) ~= CellState.HIT then
                                field.set_value(x, y, CellState.MISS)
                                misses[#misses + 1] = {x = x, y = y}
                            end
                        end
                        x = x + 1
                    end
                end
                y = y + 1
            end
        end
        return misses
    end
    local function is_win()
        return __TS__ArrayEvery(
            ships_uids,
            function(____, ship) return ships_lifes[ship] == 0 end
        )
    end
    local function get_ship(x, y)
        return index_to_ship_uid[field.get_index(x, y)]
    end
    local function has_ship_part(x, y)
        return index_to_ship_uid[field.get_index(x, y)] ~= nil
    end
    local function get_field()
        return field
    end
    local function load_state(state)
        field.load_state(state.field)
        ships_uids = state.ships_uids
        ships_bb = state.ships_bb
        ships_lifes = state.ships_lifes
        index_to_ship_uid = state.index_to_ship_uid
    end
    local function save_state()
        local result = {
            field = field.save_state(),
            ships_uids = copy(ships_uids),
            ships_bb = {},
            ships_lifes = {},
            index_to_ship_uid = {}
        }
        for ____, ____value in ipairs(__TS__ObjectEntries(ships_bb)) do
            local key = ____value[1]
            local value = ____value[2]
            result.ships_bb[key] = value
        end
        for ____, ____value in ipairs(__TS__ObjectEntries(ships_lifes)) do
            local key = ____value[1]
            local value = ____value[2]
            result.ships_lifes[key] = value
        end
        for ____, ____value in ipairs(__TS__ObjectEntries(index_to_ship_uid)) do
            local key = ____value[1]
            local value = ____value[2]
            result.index_to_ship_uid[key] = value
        end
        return result
    end
    return {
        setup = setup,
        create_ship = create_ship,
        auto_place_ships = auto_place_ships,
        get_field = get_field,
        is_win = is_win,
        has_ship_part = has_ship_part,
        get_ship = get_ship,
        miss_around_ship = miss_around_ship,
        load_state = load_state,
        save_state = save_state,
        ships_lifes = ships_lifes,
        ships_uids = ships_uids
    }
end
return ____exports
