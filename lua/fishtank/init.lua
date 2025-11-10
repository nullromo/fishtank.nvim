local options = require('fishtank.options')
local setup = require('fishtank.setup')

local M = {}

---@param opts FishtankOptions
---@return nil
M.setup = function(opts)
    -- set user options
    options.setOptions(opts)

    -- setup
    setup.setupUserCommand()
    setup.setupAutocommands()
    setup.setupScreensaver()
end

return M
