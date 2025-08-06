local colors = require('fishtank.colors')
local constants = require('fishtank.constants')
local luaUtils = require('fishtank.util.lua')
local options = require('fishtank.options')
local path = require('fishtank.path')
local vimUtils = require('fishtank.util.vim')

Fish = {
    position = { row = 0, col = 0 },
    text = '',
    bufferID = nil,
    windowID = nil,
    travelPoints = {},
}

function Fish:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self:initialize()
    return o
end

-- creates and returns a new fish
function Fish:initialize()
    -- select a random position
    self.position = path.randomPosition()

    -- create an unlisted scratch buffer
    self.bufferID = vim.api.nvim_create_buf(false, true)
    -- wipe the buffer when it is hidden
    vim.api.nvim_buf_set_var(self.bufferID, 'bufhidden', 'wipe')

    -- select a random direction
    self.text = luaUtils.ternary(
        math.random(2) == 1,
        options.opts.sprite.left,
        options.opts.sprite.right
    )

    -- create a floating window and set the global window ID
    self.windowID = vim.api.nvim_open_win(self.bufferID, false, {
        relative = 'editor',
        width = #self.text,
        height = 1,
        row = self.position.row,
        col = self.position.col,
        focusable = false,
        mouse = false,
        zindex = 999,
        style = 'minimal',
        noautocmd = true,
        border = '',
    })

    -- set the window's highlight namespace
    vim.api.nvim_win_set_hl_ns(self.windowID, colors.highlightNamespace)

    -- if anything changed about the colorscheme since the Fish highlight was
    -- created, it may have the wrong background color. Update it here
    vim.api.nvim_set_hl(colors.highlightNamespace, 'Fish', {
        fg = '#FFFFFF',
        bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg,
        bold = true,
        force = true,
    })
    -- NOTE: transparent background would be ideal, but using this causes the
    -- foreground to also blend with what's behind it
    --vim.api.nvim_set_option_value('winblend', 100, { win = self.windowID })

    -- clear travel points
    self.travelPoints = {}
end

-- updates a fish's position
function Fish:update()
    -- if the fish has no planned route, create a new one
    if #self.travelPoints == 0 then
        -- get a new route
        self.travelPoints = path.computeNewPath(self)

        -- update the fish's sprite based on the new destination
        self.text = luaUtils.ternary(
            self.travelPoints[#self.travelPoints].col > self.position.col,
            options.opts.sprite.right,
            options.opts.sprite.left
        )

        -- resize the window to fit the new sprite
        vim.api.nvim_win_set_width(self.windowID, #self.text)
    end

    -- pop the first position in the route and move the fish there
    local position = table.remove(self.travelPoints, 1)
    self.position = position
end

-- closes a fish's window
function Fish:close()
    if vim.api.nvim_win_is_valid(self.windowID) then
        vim.api.nvim_win_close(self.windowID, true)
    end

    self.bufferID = nil
    self.windowID = nil
end

return Fish
