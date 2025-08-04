local M = {}

M.ternary = function(condition, ifTrue, ifFalse)
    if condition then
        return ifTrue
    else
        return ifFalse
    end
end

M.splitFirstToken = function(value)
    local first, rest = value:match('^(%S+)%s*(.*)')
    return { first = first, rest = rest }
end

return M
