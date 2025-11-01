local ____exports = {}
____exports.CellState = CellState or ({})
____exports.CellState.EMPTY = 0
____exports.CellState[____exports.CellState.EMPTY] = "EMPTY"
____exports.CellState.HIT = 1
____exports.CellState[____exports.CellState.HIT] = "HIT"
____exports.CellState.MISS = 2
____exports.CellState[____exports.CellState.MISS] = "MISS"
____exports.CellState.SHIP = 3
____exports.CellState[____exports.CellState.SHIP] = "SHIP"
function ____exports.Field(width, height)
    local values = {}
    local function init()
        do
            local y = 0
            while y < height do
                values[y + 1] = {}
                do
                    local x = 0
                    while x < width do
                        values[y + 1][x + 1] = ____exports.CellState.EMPTY
                        x = x + 1
                    end
                end
                y = y + 1
            end
        end
    end
    local function set_value(x, y, value)
        values[y + 1][x + 1] = value
    end
    local function get_value(x, y)
        return values[y + 1][x + 1]
    end
    local function in_boundaries(x, y)
        return y >= 0 and y < #values and x >= 0 and x < #values[y + 1]
    end
    local function get_index(x, y)
        return y * width + x
    end
    local function ____debug()
        do
            local y = 0
            while y < height do
                local output = ""
                do
                    local x = 0
                    while x < width do
                        output = (output .. " ") .. tostring(get_value(x, y))
                        x = x + 1
                    end
                end
                log((tostring(y + 1) .. " ") .. output)
                y = y + 1
            end
        end
    end
    init()
    return {
        set_value = set_value,
        get_value = get_value,
        in_boundaries = in_boundaries,
        get_index = get_index,
        debug = ____debug,
        width = width,
        height = height
    }
end
return ____exports
