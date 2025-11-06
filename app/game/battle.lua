local ____lualib = require("lualib_bundle")
local __TS__ArrayPush = ____lualib.__TS__ArrayPush
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery
local ____exports = {}
local ____field = require("game.field")
local CellState = ____field.CellState
local ____player = require("game.player")
local Player = ____player.Player
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
function ____exports.Battle()
    local start_turn, end_turn, is_need_switch_turn, switch_turn, get_current_turn_player_index, get_opponent, is_win, players, current_turn_player_index, current_turn_player_shot_state, start_turn_cb, end_turn_cb, win_cb, turn_timer
    function start_turn()
        current_turn_player_shot_state = ____exports.ShotState.ERROR
        turn_timer = timer.delay(5, false, end_turn)
        start_turn_cb()
    end
    function end_turn()
        timer.cancel(turn_timer)
        end_turn_cb()
        if is_win() then
            win_cb()
            return
        end
        if is_need_switch_turn() then
            switch_turn()
        end
        start_turn()
    end
    function is_need_switch_turn()
        return current_turn_player_shot_state == ____exports.ShotState.ERROR or current_turn_player_shot_state == ____exports.ShotState.MISS
    end
    function switch_turn()
        current_turn_player_index = 1 - current_turn_player_index
    end
    function get_current_turn_player_index()
        return current_turn_player_index
    end
    function get_opponent(self_idx)
        return players[1 - self_idx + 1]
    end
    function is_win()
        local player = get_opponent(get_current_turn_player_index())
        if __TS__ArrayEvery(
            player.ships_uids,
            function(____, ship) return player.ships_lifes[ship] == 0 end
        ) then
            return true
        end
        return false
    end
    players = {}
    current_turn_player_index = 0
    local function setup(config)
        start_turn_cb = config.start_turn_callback
        end_turn_cb = config.end_turn_callback
        win_cb = config.win_callback
        local player1 = Player()
        local player2 = Player()
        player1.setup(config.width, config.height)
        player2.setup(config.width, config.height)
        __TS__ArrayPush(players, player1, player2)
        player1.auto_place_ships({{length = 4, count = 1}, {length = 3, count = 2}, {length = 2, count = 3}, {length = 1, count = 4}})
        player2.auto_place_ships({{length = 4, count = 1}, {length = 3, count = 2}, {length = 2, count = 3}, {length = 1, count = 4}})
    end
    local function start()
        start_turn()
    end
    local function get_current_player()
        return players[current_turn_player_index + 1]
    end
    local function get_players()
        return players
    end
    local function get_player(index)
        return players[index + 1]
    end
    local function shot(x, y)
        local player = get_opponent(current_turn_player_index)
        local field = player.get_field()
        local cell_state = field.get_value(x, y)
        if cell_state == CellState.HIT or cell_state == CellState.MISS then
            current_turn_player_shot_state = ____exports.ShotState.ERROR
            return {state = ____exports.ShotState.ERROR, shot_pos = {x = x, y = y}}
        end
        if not player.has_ship_part(x, y) then
            field.set_value(x, y, CellState.MISS)
            current_turn_player_shot_state = ____exports.ShotState.MISS
            return {state = ____exports.ShotState.MISS, shot_pos = {x = x, y = y}}
        end
        field.set_value(x, y, CellState.HIT)
        current_turn_player_shot_state = ____exports.ShotState.HIT
        local ship = player.get_ship(x, y)
        local ____player_ships_lifes_0, ____ship_1 = player.ships_lifes, ship
        ____player_ships_lifes_0[____ship_1] = ____player_ships_lifes_0[____ship_1] - 1
        if player.ships_lifes[ship] == 0 then
            current_turn_player_shot_state = ____exports.ShotState.KILL
            return {
                state = ____exports.ShotState.KILL,
                shot_pos = {x = x, y = y},
                data = player.miss_around_ship(ship)
            }
        end
        return {state = ____exports.ShotState.HIT, shot_pos = {x = x, y = y}}
    end
    return {
        setup = setup,
        start = start,
        shot = shot,
        end_turn = end_turn,
        get_current_turn_player_index = get_current_turn_player_index,
        get_current_player = get_current_player,
        get_opponent = get_opponent,
        get_players = get_players,
        get_player = get_player
    }
end
return ____exports
