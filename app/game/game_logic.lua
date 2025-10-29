local ____exports = {}
local flow = require("ludobits.m.flow")
local ____GoManager = require("modules.GoManager")
local GoManager = ____GoManager.GoManager
local ____battle = require("game.battle")
local Battle = ____battle.Battle
function ____exports.Game()
    local wait_event, gm
    function wait_event()
        while true do
            local message_id, message = flow.until_any_message()
            gm.do_message(message_id, message)
        end
    end
    local cell_size = 20
    gm = GoManager()
    local battle = Battle()
    local function init()
        local battle = Battle()
        battle.setup(10, 10)
        battle.auto_place_ships({{length = 4, count = 1}, {length = 3, count = 2}, {length = 2, count = 3}, {length = 1, count = 4}})
        local field = battle.get_field()
        do
            local y = 0
            while y < field.height do
                local output = ""
                do
                    local x = 0
                    while x < field.width do
                        output = (output .. " ") .. tostring(field.get_value(x, y))
                        x = x + 1
                    end
                end
                log((tostring(y + 1) .. " ") .. output)
                y = y + 1
            end
        end
        wait_event()
    end
    init()
    return {}
end
return ____exports
