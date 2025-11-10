local M = {}

---@class Point
---@field row integer
---@field col integer

-- compute distance between points
---@param start Point
---@param finish Point
---@return number
M.computeDistance = function(start, finish)
    return math.sqrt(
        ((finish.row - start.row) ^ 2) + ((finish.col - start.col) ^ 2)
    )
end

return M
