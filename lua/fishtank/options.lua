local M = {}

---@param value unknown
---@param valueName string
---@param typeName string
---@return nil
local checkType = function(value, valueName, typeName)
    if type(value) ~= typeName then
        error(valueName .. ' must be a ' .. typeName .. ' for fishtank.nvim')
    end
end

---@alias FishtankOptions {
---    screensaver: {
---        enabled: boolean,
---        timeout: integer,
---    },
---    sprite: {
---        left: string,
---        right: string,
---        color: string,
---    },
---    numberOfFish: integer,
---}

-- default options if unspecified by user
---@type FishtankOptions
M.defaultOptions = {
    -- options for controlling the behavior of the screensaver
    screensaver = {
        -- whether or not the screensaver comes on at all
        enabled = true,
        -- amount of idle time before the screensaver comes on
        timeout = 60 * 1000 * 10, -- 10 minutes
    },
    -- sprite customization
    sprite = {
        left = '<><', -- fish moving to the left
        right = '><>', -- fish moving to the right
        color = '#FFFFFF', -- color of the fish
    },
    -- number of fish shown on the screen
    numberOfFish = 1,
}

---@param opts FishtankOptions
---@return nil
M.validateOptions = function(opts)
    for key, value in pairs(opts) do
        if key == 'screensaver' then
            for key2, value2 in
                pairs(value --[[@as { enabled: boolean, timeout: integer }]])
            do
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
        elseif key == 'sprite' then
            for key2, value2 in
                pairs(
                    value --[[@as { left: string, right: string, color: string }]]
                )
            do
                if key2 == 'left' then
                    checkType(value2, 'opts.sprite.left', 'string')
                elseif key2 == 'right' then
                    checkType(value2, 'opts.sprite.right', 'string')
                elseif key2 == 'color' then
                    checkType(value2, 'opts.sprite.color', 'string')
                else
                    error(
                        '"opts.sprite.'
                            .. key2
                            .. '" is not a valid option for fishtank.nvim'
                    )
                end
            end
        elseif key == 'numberOfFish' then
            checkType(value, 'opts.screensaver.numberOfFish', 'number')
        else
            error(
                '"opts.' .. key .. '" is not a valid option for fishtank.nvim'
            )
        end
    end
end

-- actual options for use throughout the plugin
---@type FishtankOptions
M.opts = vim.tbl_deep_extend('keep', {}, M.defaultOptions)

---@param opts FishtankOptions
---@return nil
M.setOptions = function(opts)
    opts = vim.tbl_deep_extend('keep', opts or {}, M.defaultOptions)
    M.validateOptions(opts)
    M.opts = opts
end

return M
