local ____exports = {}
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
    local user = Player()
    local bot = Player()
    user.setup(10, 10)
    bot.setup(10, 10)
    bot.auto_place_ships({{length = 4, count = 1}, {length = 3, count = 2}, {length = 2, count = 3}, {length = 1, count = 4}})
    return {user = user, bot = bot}
end
return ____exports
