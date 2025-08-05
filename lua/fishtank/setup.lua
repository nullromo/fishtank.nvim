local options = require('fishtank.options')

local M = {}

local fishtankAugroup =
    vim.api.nvim_create_augroup('fishtank.nvim', { clear = true })

M.setupUserCommand = function()
    vim.api.nvim_create_user_command('Fishtank', function(opts)
        internals.fishtankUserCommand(opts.args)
    end, { nargs = '+', desc = 'Start fishtank.nvim' })
end

M.setupAutocommands = function()
    -- handle cmdline
    vim.api.nvim_create_autocmd({ 'CmdlineEnter' }, {
        callback = function()
            internals.pauseFishtank()
        end,
        group = fishtankAugroup,
        desc = 'pause fishtank.nvim while typing a command',
    })
    vim.api.nvim_create_autocmd({ 'CmdlineLeave' }, {
        callback = function()
            -- NOTE: this will resume the fishtank even if there is a "Press
            -- ENTER or type command to continue" prompt
            internals.resumeFishtank()
        end,
        group = fishtankAugroup,
        desc = 'resume fishtank.nvim when done typing a command',
    })

    vim.print(options.opts)
end

return M
