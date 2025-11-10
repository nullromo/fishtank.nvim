local M = {}

---@alias VimAugroup integer

---@alias VimNamespace integer

-- set up a function to be called every n milliseconds
---@param interval integer
---@param callback fun(): nil
---@return uv.uv_timer_t
M.setInterval = function(interval, callback)
    local timer = vim.uv.new_timer()
    if timer == nil then
        error('Fishtank.nvim could not initialize a timer')
    end
    timer:start(
        interval,
        interval,
        vim.schedule_wrap(function()
            callback()
        end)
    )
    return timer
end

-- clear a previously set interval
---@param timer uv.uv_timer_t
---@return nil
M.clearInterval = function(timer)
    timer:stop()
    timer:close()
end

-- determine size of editor
---@return { rows: integer, cols: integer }
M.getEditorSize = function()
    return {
        rows = tonumber(
            vim.api.nvim_exec2('echo &lines', { output = true }).output
        ) or 0,
        cols = tonumber(
            vim.api.nvim_exec2('echo &columns', { output = true }).output
        ) or 0,
    }
end

return M
