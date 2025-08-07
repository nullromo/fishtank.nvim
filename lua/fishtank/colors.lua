local M = {}

-- namespace for fishtank.nvim highlights
M.highlightNamespace = vim.api.nvim_create_namespace('fishtank.nvim')

-- create Fish highlight group
vim.api.nvim_set_hl(M.highlightNamespace, 'Fish', {
    fg = '#FFFFFF',
    bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg,
    bold = true,
})

return M
