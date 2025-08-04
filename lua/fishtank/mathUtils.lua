local M = {}

-- compute distance between points
M.computeDistance = function(start, finish)
    return math.sqrt(
        math.pow(finish.row - start.row, 2)
            + math.pow(finish.col - start.col, 2)
    )
end

return M
