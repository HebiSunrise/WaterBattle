local ____exports = {}
local ____GoManager = require("modules.GoManager")
local GoManager = ____GoManager.GoManager
local ____battle = require("game.battle")
local Battle = ____battle.Battle
local ShotState = ____battle.ShotState
function ____exports.Game()
    local render_field, in_cell, on_click, render_shot, render_killed, cell_size, gm, battle, start_pos_bfield_x, start_pos_bfield_y
    function render_field(start_pos_x, start_pos_y)
        local field = battle:get_field()
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
    function in_cell(start_pos_x, start_pos_y, pos)
        local x = math.floor((pos.x - (start_pos_x - cell_size * 0.5)) / cell_size)
        local y = math.floor((-pos.y + (start_pos_y + cell_size * 0.5)) / cell_size)
        if x < 0 or x > 9 or y < 0 or y > 9 then
            return nil
        end
        return {x = x, y = y}
    end
    function on_click(pos)
        local tmp = Camera.window_to_world(pos.x, pos.y)
        log(tmp.x, " ", tmp.y)
        local cell_cord = in_cell(start_pos_bfield_x, start_pos_bfield_y, tmp)
        log(cell_cord)
        if not cell_cord then
            return
        end
        local shot_state = battle:shot(cell_cord.x, cell_cord.y)
        repeat
            local ____switch12 = shot_state.state
            local ____cond12 = ____switch12 == ShotState.HIT
            if ____cond12 then
                render_shot(cell_cord.x, cell_cord.y, "hit")
                break
            end
            ____cond12 = ____cond12 or ____switch12 == ShotState.MISS
            if ____cond12 then
                render_shot(cell_cord.x, cell_cord.y, "miss")
                break
            end
            ____cond12 = ____cond12 or ____switch12 == ShotState.KILL
            if ____cond12 then
                render_killed(cell_cord.x, cell_cord.y, shot_state.data)
                break
            end
        until true
        battle.user.get_field().debug()
    end
    function render_shot(x, y, state)
        gm.make_go(
            state,
            vmath.vector3(x * cell_size + start_pos_bfield_x, y * -cell_size + start_pos_bfield_y, 1)
        )
    end
    function render_killed(x, y, data)
        render_shot(x, y, "hit")
        do
            local i = 0
            while i < #data do
                local cord = data[i + 1]
                render_shot(cord.x, cord.y, "miss")
                i = i + 1
            end
        end
        if battle:is_win() then
            log("win")
        end
    end
    cell_size = 34
    gm = GoManager()
    battle = Battle()
    local start_pos_ufield_x = 50
    local start_pos_ufield_y = -50
    start_pos_bfield_x = 440
    start_pos_bfield_y = -50
    local function init()
        EventBus.on("MSG_ON_UP", on_click)
        render_field(start_pos_ufield_x, start_pos_ufield_y)
        render_field(start_pos_bfield_x, start_pos_bfield_y)
    end
    local function on_message(message_id, message)
        gm.do_message(message_id, message)
    end
    init()
    return {on_message = on_message}
end
return ____exports
