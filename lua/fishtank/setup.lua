local internals = require('fishtank.internals')
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
end

M.setupScreensaver = function()
    if options.opts.screensaver.enabled then
        -- start the screensaver timer
        internals.initializeScreensaver()

        -- whenever the user does anything, restart the screensaver timer
        vim.api.nvim_create_autocmd({
            'CursorMoved',
            'CursorMovedC',
            'CursorMovedI',
            'FocusGained',
            'ModeChanged',
            'InsertCharPre',
            'WinScrolled',
            'WinResized',
        }, {
            callback = vim.schedule_wrap(function()
                internals.initializeScreensaver()
            end),
            group = fishtankAugroup,
            desc = 'restart fishtank.nvim screensaver timer when not idle',
        })
    end
end

return M
