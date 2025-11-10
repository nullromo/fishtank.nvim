local M = {}

---@generic A
---@generic B
---@param condition boolean
---@param ifTrue A
---@param ifFalse B
---@return A | B
M.ternary = function(condition, ifTrue, ifFalse)
    if condition then
        return ifTrue
    end
    return ifFalse
end

---@param value string
---@return { first: string | nil, rest: string | nil }
M.splitFirstToken = function(value)
    ---@type string | nil, string | nil
    local first, rest = value:match('^(%S+)%s*(.*)')
    return { first = first, rest = rest }
end

return M
