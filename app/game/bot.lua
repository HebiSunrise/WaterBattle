local ____exports = {}
local ____utils = require("utils.utils")
local generate_random_integer = ____utils.generate_random_integer
local ____config = require("game.config")
local Config = ____config.Config
function ____exports.Bot()
    local function step()
        local x = generate_random_integer(Config.field_width)
        local y = generate_random_integer(Config.field_height)
        log(x, y)
        return {x = x, y = y}
    end
    return {step = step}
end
return ____exports
