local internals = require('fishtank.internals')

local M = {}

local fishtankNamespace = vim.api.nvim_create_namespace('fishtank.nvim')

M.setup = function()
    vim.api.nvim_create_user_command('Fishtank', function(opts)
        internals.fishtankUserCommand(opts.args)
    end, { nargs = '+', desc = 'Start fishtank.nvim' })

    vim.api.nvim_create_autocmd({ 'CmdlineEnter' }, {
        callback = function()
            vim.notify('cmdline entered')
        end,
        desc = 'pause fishtank.nvim while typing a command',
    })
end

return M
