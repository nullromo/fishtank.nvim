local constants = require('fishtank.constants')
local luaUtils = require('fishtank.util.lua')
local path = require('fishtank.path')

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

    -- create a floating window and set the global window ID
    self.windowID = vim.api.nvim_open_win(self.bufferID, false, {
        relative = 'editor',
        width = 3,
        height = 1,
        row = self.position.row,
        col = self.position.col,
        focusable = false,
        mouse = false,
        zindex = 999,
        style = 'minimal',
        noautocmd = true,
    })

    -- set the window's highlight namespace
    vim.api.nvim_win_set_hl_ns(self.windowID, constants.highlightNamespace)

    -- if anything changed about the colorscheme since the Fish highlight was
    -- created, it may have the wrong background color. Update it here
    vim.api.nvim_set_hl(constants.highlightNamespace, 'Fish', {
        fg = '#FFFFFF',
        bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg,
        bold = true,
        force = true,
    })
    -- NOTE: transparent background would be ideal, but using this causes the
    -- foreground to also blend with what's behind it
    --vim.api.nvim_set_option_value('winblend', 100, { win = self.windowID })

    -- select a random direction
    self.text = luaUtils.ternary(
        math.random(2) == 1,
        constants.RIGHT_FACING_FISH,
        constants.LEFT_FACING_FISH
    )

    -- clear travel points
    self.travelPoints = {}
end

-- updates a fish's position
function Fish:update()
    -- if the fish has no planned route, create a new one
    if #self.travelPoints == 0 then
        -- get a new route
        self.travelPoints = path.computeNewPath(self)

        -- update the fish's facing position based on the new destination
        self.text = luaUtils.ternary(
            self.travelPoints[#self.travelPoints].col > self.position.col,
            constants.RIGHT_FACING_FISH,
            constants.LEFT_FACING_FISH
        )
    end

    -- pop the first position in the route and move the fish there
    local position = table.remove(self.travelPoints, 1)
    self.position = position
end

-- closes a fish's window
function Fish:close()
    vim.api.nvim_win_close(self.windowID, true)
    self.bufferID = nil
    self.windowID = nil
end

return Fish
