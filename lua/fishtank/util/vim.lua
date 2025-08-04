local M = {}

-- set up a function to be called every n milliseconds
M.setInterval = function(interval, callback)
    local timer = vim.uv.new_timer()
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
M.clearInterval = function(timer)
    timer:stop()
    timer:close()
end

-- determine size of editor
M.getEditorSize = function()
    return {
        rows = tonumber(vim.api.nvim_command_output('echo &lines')) or 0,
        cols = tonumber(vim.api.nvim_command_output('echo &columns')) or 0,
    }
end

return M
