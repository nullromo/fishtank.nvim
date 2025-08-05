local M = {}

local checkType = function(value, valueName, typeName)
    if type(value) ~= typeName then
        error(valueName .. ' must be a ' .. typeName .. ' for fishtank.nvim')
    end
end

-- default options if unspecified by user
M.defaultOptions = {
    -- options for controlling the behavior of the screensaver
    screensaver = {
        -- whether or not the screensaver comes on at all
        enabled = true,
        -- amount of idle time before the screensaver comes on
        timeout = 60 * 1000 * 10, -- 10 minutes
    },
}

M.validateOptions = function(opts)
    for key, value in pairs(opts) do
        if key == 'screensaver' then
            for key2, value2 in pairs(value) do
                if key2 == 'enabled' then
                    checkType(value2, 'opts.screensaver.enabled', 'boolean')
                elseif key2 == 'timeout' then
                    checkType(value2, 'opts.screensaver.timeout', 'number')
                else
                    error(
                        '"opts.screensaver.'
                            .. key2
                            .. '" is not a valid option for fishtank.nvim'
                    )
                end
            end
        else
            error(
                '"opts.' .. key .. '" is not a valid option for fishtank.nvim'
            )
        end
    end
end

-- actual options for use throughout the plugin
M.opts = vim.tbl_deep_extend('keep', {}, M.defaultOptions)

M.setOptions = function(opts)
    opts = vim.tbl_deep_extend('keep', opts or {}, M.defaultOptions)
    M.validateOptions(opts)
    M.opts = opts
end

return M
