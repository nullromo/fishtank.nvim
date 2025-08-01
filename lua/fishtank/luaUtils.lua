local M = {}

M.ternary = function(condition, ifTrue, ifFalse)
    if condition then
        return ifTrue
    else
        return ifFalse
    end
end

return M
