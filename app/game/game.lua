local ____exports = {}
local ____GoManager = require("modules.GoManager")
local GoManager = ____GoManager.GoManager
local ____battle = require("game.battle")
local Battle = ____battle.Battle
local ShotState = ____battle.ShotState
local ____config = require("game.config")
local Config = ____config.Config
local ____bot = require("game.bot")
local Bot = ____bot.Bot
function ____exports.Game()
    local render_player, render_field, on_turn_start, on_turn_end, on_shot_end, on_win, shot_animate, on_click, in_cell, render_shot, render_killed, cell_size, gm, PLAYER_INDEX, BOT_INDEX, battle, bot, bot_think_timer, is_block_input
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
                        x = x + 1
                    end
                end
                y = y + 1
            end
        end
    end
    function on_turn_start()
        local idx = battle.get_current_turn_player_index()
        repeat
            local ____switch9 = idx
            local bot_shot_info
            local ____cond9 = ____switch9 == PLAYER_INDEX
            if ____cond9 then
                is_block_input = false
                break
            end
            ____cond9 = ____cond9 or ____switch9 == BOT_INDEX
            if ____cond9 then
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
    function on_turn_end()
        repeat
            local ____switch12 = battle.get_current_turn_player_index()
            local ____cond12 = ____switch12 == BOT_INDEX
            if ____cond12 then
                timer.cancel(bot_think_timer)
                break
            end
            ____cond12 = ____cond12 or ____switch12 == PLAYER_INDEX
            if ____cond12 then
                is_block_input = true
                break
            end
        until true
    end
    function on_shot_end()
        battle.end_turn()
    end
    function on_win()
        log("Победил игрок " .. tostring(battle.get_current_turn_player_index()))
    end
    function shot_animate(info, st_pos_fld_x, st_pos_fld_y, on_end)
        local x = info.shot_pos.x
        local y = info.shot_pos.y
        repeat
            local ____switch16 = info.state
            local ____cond16 = ____switch16 == ShotState.HIT
            if ____cond16 then
                render_shot(
                    x,
                    y,
                    "hit",
                    st_pos_fld_x,
                    st_pos_fld_y
                )
                break
            end
            ____cond16 = ____cond16 or ____switch16 == ShotState.MISS
            if ____cond16 then
                render_shot(
                    x,
                    y,
                    "miss",
                    st_pos_fld_x,
                    st_pos_fld_y
                )
                break
            end
            ____cond16 = ____cond16 or ____switch16 == ShotState.KILL
            if ____cond16 then
                render_killed(
                    x,
                    y,
                    info.data,
                    st_pos_fld_x,
                    st_pos_fld_y
                )
                break
            end
            ____cond16 = ____cond16 or ____switch16 == ShotState.ERROR
            if ____cond16 then
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
    cell_size = 34
    gm = GoManager()
    PLAYER_INDEX = 0
    BOT_INDEX = 1
    battle = Battle()
    bot = Bot(battle, BOT_INDEX)
    is_block_input = true
    local function init()
        EventBus.on("MSG_ON_UP", on_click)
        battle.setup({
            width = Config.field_width,
            height = Config.field_height,
            start_turn_callback = on_turn_start,
            end_turn_callback = on_turn_end,
            win_callback = on_win
        })
        bot.setup()
        render_player(
            Config.start_pos_ufield_x,
            Config.start_pos_ufield_y,
            battle.get_player(PLAYER_INDEX)
        )
        render_player(
            Config.start_pos_efield_x,
            Config.start_pos_efield_y,
            battle.get_player(BOT_INDEX)
        )
        battle.start()
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
