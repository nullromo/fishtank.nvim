local M = {}

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

M.clearInterval = function(timer)
    timer:stop()
    timer:close()
end

return M
