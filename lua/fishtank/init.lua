local internals = require('fishtank.internals')

local M = {}

M.setup = function()
    vim.api.nvim_create_user_command('Fishtank', function()
        internals.showFishtank()
    end, { desc = 'Start fishtank' })
end

return M
