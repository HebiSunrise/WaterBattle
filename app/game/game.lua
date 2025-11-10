local ____exports = {}
local ____GoManager = require("modules.GoManager")
local GoManager = ____GoManager.GoManager
local ____battle = require("game.battle")
local Battle = ____battle.Battle
local ShotState = ____battle.ShotState
local ____config = require("game.config")
local Config = ____config.Config
local ____field = require("game.field")
local CellState = ____field.CellState
local ____bot = require("game.bot")
local Bot = ____bot.Bot
____exports.PlayerIndex = PlayerIndex or ({})
____exports.PlayerIndex.PLAYER = 0
____exports.PlayerIndex[____exports.PlayerIndex.PLAYER] = "PLAYER"
____exports.PlayerIndex.BOT = 1
____exports.PlayerIndex[____exports.PlayerIndex.BOT] = "BOT"
function ____exports.Game()
    local render_player, render_field, on_turn_start, on_turn_end, on_shot_end, on_win, shot_animate, on_click, in_cell, render_shot, render_killed, reset, cell_size, gm, battle, bot, bot_think_timer, is_block_input
    function render_player(st_x, st_y, player)
        render_field(
            st_x,
            st_y,
            player.get_field()
        )
    end
    function render_field(start_pos_x, start_pos_y, field)
        do
            local y = 0
            while y < field.height do
                do
                    local x = 0
                    while x < field.width do
                        gm.make_go(
                            "cell",
                            vmath.vector3(x * 34 + start_pos_x, y * -34 + start_pos_y, 0)
                        )
                        repeat
                            local ____switch9 = field.get_value(x, y)
                            local ____cond9 = ____switch9 == CellState.HIT
                            if ____cond9 then
                                render_shot(
                                    x,
                                    y,
                                    "hit",
                                    start_pos_x,
                                    start_pos_y
                                )
                                break
                            end
                            ____cond9 = ____cond9 or ____switch9 == CellState.MISS
                            if ____cond9 then
                                render_shot(
                                    x,
                                    y,
                                    "miss",
                                    start_pos_x,
                                    start_pos_y
                                )
                                break
                            end
                        until true
                        x = x + 1
                    end
                end
                y = y + 1
            end
        end
    end
    function on_turn_start(index)
        GameStorage.set(
            "battle_state",
            battle.save_state()
        )
        EventBus.send("ON_SWIYCH_TURN", index)
        repeat
            local ____switch11 = index
            local bot_shot_info
            local ____cond11 = ____switch11 == ____exports.PlayerIndex.PLAYER
            if ____cond11 then
                is_block_input = false
                break
            end
            ____cond11 = ____cond11 or ____switch11 == ____exports.PlayerIndex.BOT
            if ____cond11 then
                GameStorage.set(
                    "bot_state",
                    bot.save_state()
                )
                bot_shot_info = bot.shot()
                bot_think_timer = timer.delay(
                    1,
                    false,
                    function() return shot_animate(bot_shot_info, Config.start_pos_ufield_x, Config.start_pos_ufield_y, on_shot_end) end
                )
                break
            end
        until true
    end
    function on_turn_end(index)
        repeat
            local ____switch14 = index
            local ____cond14 = ____switch14 == ____exports.PlayerIndex.BOT
            if ____cond14 then
                timer.cancel(bot_think_timer)
                break
            end
            ____cond14 = ____cond14 or ____switch14 == ____exports.PlayerIndex.PLAYER
            if ____cond14 then
                is_block_input = true
                break
            end
        until true
    end
    function on_shot_end()
        battle.end_turn()
    end
    function on_win(index)
        log("Победил игрок " .. tostring(index))
    end
    function shot_animate(info, st_pos_fld_x, st_pos_fld_y, on_end)
        local x = info.shot_pos.x
        local y = info.shot_pos.y
        repeat
            local ____switch18 = info.state
            local ____cond18 = ____switch18 == ShotState.HIT
            if ____cond18 then
                render_shot(
                    x,
                    y,
                    "hit",
                    st_pos_fld_x,
                    st_pos_fld_y
                )
                break
            end
            ____cond18 = ____cond18 or ____switch18 == ShotState.MISS
            if ____cond18 then
                render_shot(
                    x,
                    y,
                    "miss",
                    st_pos_fld_x,
                    st_pos_fld_y
                )
                break
            end
            ____cond18 = ____cond18 or ____switch18 == ShotState.KILL
            if ____cond18 then
                render_killed(
                    x,
                    y,
                    info.data,
                    st_pos_fld_x,
                    st_pos_fld_y
                )
                break
            end
            ____cond18 = ____cond18 or ____switch18 == ShotState.ERROR
            if ____cond18 then
                return
            end
        until true
        on_end()
    end
    function on_click(pos)
        local tmp = Camera.window_to_world(pos.x, pos.y)
        local cell_cord = in_cell(Config.start_pos_efield_x, Config.start_pos_efield_y, tmp)
        if not cell_cord then
            return
        end
        local info = battle.shot(cell_cord.x, cell_cord.y)
        shot_animate(info, Config.start_pos_efield_x, Config.start_pos_efield_y, on_shot_end)
    end
    function in_cell(start_pos_x, start_pos_y, pos)
        local x = math.floor((pos.x - (start_pos_x - cell_size * 0.5)) / cell_size)
        local y = math.floor((-pos.y + (start_pos_y + cell_size * 0.5)) / cell_size)
        if x < 0 or x > 9 or y < 0 or y > 9 then
            return nil
        end
        return {x = x, y = y}
    end
    function render_shot(x, y, state, field_start_pos_x, field_start_pos_y)
        gm.make_go(
            state,
            vmath.vector3(x * cell_size + field_start_pos_x, y * -cell_size + field_start_pos_y, 1)
        )
    end
    function render_killed(x, y, data, field_start_pos_x, field_start_pos_y)
        render_shot(
            x,
            y,
            "hit",
            field_start_pos_x,
            field_start_pos_y
        )
        do
            local i = 0
            while i < #data do
                local cord = data[i + 1]
                render_shot(
                    cord.x,
                    cord.y,
                    "miss",
                    field_start_pos_x,
                    field_start_pos_y
                )
                i = i + 1
            end
        end
    end
    function reset()
        GameStorage.set("battle_state", {})
        GameStorage.set("bot_state", {})
        Scene.restart()
    end
    cell_size = 34
    gm = GoManager()
    battle = Battle()
    bot = Bot(battle, ____exports.PlayerIndex.BOT)
    is_block_input = true
    local function init()
        EventBus.on("MSG_ON_UP", on_click)
        EventBus.on("ON_RESET", reset)
        battle.setup({
            width = Config.field_width,
            height = Config.field_height,
            start_turn_callback = on_turn_start,
            end_turn_callback = on_turn_end,
            win_callback = on_win
        })
        bot.setup()
        local state = GameStorage.get("battle_state")
        if state.current_turn_player_index ~= nil then
            battle.load_state(GameStorage.get("battle_state"))
            bot.load_state(GameStorage.get("bot_state"))
        end
        render_player(
            Config.start_pos_ufield_x,
            Config.start_pos_ufield_y,
            battle.get_player(____exports.PlayerIndex.PLAYER)
        )
        render_player(
            Config.start_pos_efield_x,
            Config.start_pos_efield_y,
            battle.get_player(____exports.PlayerIndex.BOT)
        )
        timer.delay(0.1, false, battle.start)
    end
    local function on_message(message_id, message)
        if is_block_input then
            return
        end
        gm.do_message(message_id, message)
    end
    init()
    return {on_message = on_message}
end
return ____exports
