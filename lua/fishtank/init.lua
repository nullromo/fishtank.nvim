local internals = require('fishtank.internals')

local M = {}

M.setup = function()
    vim.api.nvim_create_user_command('Fishtank', function(opts)
        internals.fishtankUserCommand(opts.args)
    end, { nargs = '+', desc = 'Start fishtank' })
end

return M
