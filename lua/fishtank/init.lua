local internals = require('fishtank.internals')
local options = require('fishtank.options')
local setup = require('fishtank.setup')

local M = {}

M.setup = function(opts)
    -- set user options
    options.setOptions(opts)

    -- setup
    setup.setupUserCommand()
    setup.setupAutocommands()
end

return M
