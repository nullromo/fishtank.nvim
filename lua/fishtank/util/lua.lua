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

---@param value string
---@return string[]
M.splitIntoLines = function(value)
    ---@type string[]
    local result = {}
    for match in value:gmatch('([^(\n|\r\n)]+)') do
        table.insert(result, match)
    end
    return result
end

---@generic T, U
---@param array T[]
---@param action fun(T): U
---@return U[]
M.map = function(array, action)
    local result = {}
    for key, value in ipairs(array) do
        result[key] = action(value)
    end
    return result
end

---@param text string
---@return integer
M.getLongestLineLength = function(text)
    return math.max(unpack(M.map(M.splitIntoLines(text), function(line)
        return vim.fn.strdisplaywidth(line)
    end)))
end

return M
