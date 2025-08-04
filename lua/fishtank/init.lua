local internals = require('fishtank.internals')

local M = {}

local fishtankNamespace = vim.api.nvim_create_namespace('fishtank.nvim')

M.setup = function()
    vim.api.nvim_create_user_command('Fishtank', function(opts)
        internals.fishtankUserCommand(opts.args)
    end, { nargs = '+', desc = 'Start fishtank.nvim' })

    vim.api.nvim_create_autocmd({ 'CmdlineEnter' }, {
        callback = function()
            internals.pauseFishtank()
        end,
        desc = 'pause fishtank.nvim while typing a command',
    })

    vim.api.nvim_create_autocmd({ 'CmdlineLeave' }, {
        callback = function()
            -- NOTE: this will resume the fishtank even if there is a "Press
            -- ENTER or type command to continue" prompt
            internals.resumeFishtank()
        end,
        desc = 'resume fishtank.nvim when done typing a command',
    })
end

return M
