local Fish = require('fishtank.fish')
local colors = require('fishtank.colors')
local constants = require('fishtank.constants')
local luaUtils = require('fishtank.util.lua')
local mathUtils = require('fishtank.util.math')
local options = require('fishtank.options')
local vimUtils = require('fishtank.util.vim')

local M = {}

-- global state
local globalState = {
    fishList = {},
    intervalID = nil,
    state = constants.FISHTANK_HIDDEN,
    paused = false,
    screensaverTimer = nil,
}

-- initializes the fishList data
local initializeFish = function()
    -- initialize global state with 1 fish
    globalState.fishList = { Fish:new() }
end

local updateAllFish = function()
    -- do nothing if paused
    if globalState.paused then
        return
    end

    -- update all fish in the fishList
    for i, fish in ipairs(globalState.fishList) do
        fish:update()
    end
end

-- redraws all the fish
local redrawFishtank = function()
    -- do nothing if the fishtank is not showing
    if globalState.state == constants.FISHTANK_HIDDEN then
        return
    end

    for i, fish in ipairs(globalState.fishList) do
        -- move the fishtank window
        vim.api.nvim_win_set_config(fish.windowID, {
            relative = 'editor',
            row = fish.position.row,
            col = fish.position.col,
        })

        -- update the fish text
        -- NOTE: this will set the buffer's actual text, but the extmark uses
        -- the right colors
        --vim.api.nvim_buf_set_lines(fish.bufferID, 0, 1, false, { fish.text })
        vim.api.nvim_buf_set_extmark(
            fish.bufferID,
            colors.highlightNamespace,
            0,
            0,
            {
                id = 1,
                virt_text_pos = 'overlay',
                virt_text = { { fish.text, 'Fish' } },
            }
        )
    end
end

-- closes all the fish's windows
local closeAllFishWindows = function()
    for i, fish in ipairs(globalState.fishList) do
        fish:close()
    end
end

-- turns off the fishtank and wipes the state
M.hideFishtank = function()
    -- if the fishtank is not showing, do nothing
    if globalState.state == constants.FISHTANK_HIDDEN then
        return
    end

    -- close all fish windows
    closeAllFishWindows()

    -- reset the global state
    vimUtils.clearInterval(globalState.intervalID)
    globalState.intervalID = nil
    globalState.state = constants.FISHTANK_HIDDEN
end

-- turns on the fishtank and initializes the state
M.showFishtank = function(args)
    -- if the fishtank is already showing, do nothing
    if globalState.state ~= constants.FISHTANK_HIDDEN then
        return
    end

    -- initialize the fish
    initializeFish()

    -- start interval and set global ID
    globalState.intervalID = vimUtils.setInterval(
        constants.POINT_TRAVEL_TIME,
        function()
            updateAllFish()
            redrawFishtank()
        end
    )

    globalState.state = (args or {}).state or constants.FISHTANK_SHOWN_BY_USER
end

M.toggleFishtank = function()
    if globalState.state == constants.FISHTANK_HIDDEN then
        M.showFishtank()
    else
        M.hideFishtank()
    end
end

M.fishtankUserCommand = function(args)
    -- split arguments
    local splitResult = luaUtils.splitFirstToken(args)

    -- take action based on first argument
    if
        splitResult.first == 'start'
        or splitResult.first == 'on'
        or splitResult.first == 'open'
        or splitResult.first == 'show'
    then
        M.showFishtank()
    elseif
        splitResult.first == 'stop'
        or splitResult.first == 'off'
        or splitResult.first == 'close'
        or splitResult.first == 'hide'
    then
        M.hideFishtank()
    elseif splitResult.first == 'toggle' then
        M.toggleFishtank()
    else
        vim.print(
            'Invalid Fishtank.nvim command. See `:h fishtank` for details.'
        )
    end
end

M.pauseFishtank = function()
    globalState.paused = true
end
M.resumeFishtank = function()
    globalState.paused = false
end

local startScreensaverTimer = function()
    globalState.screensaverTimer:start(
        options.opts.screensaver.timeout,
        0,
        vim.schedule_wrap(function()
            M.showFishtank({ state = constants.FISHTANK_SHOWN_BY_TIMER })
        end)
    )
end

M.initializeScreensaver = function()
    -- create timer if it doesn't exist
    if globalState.screensaverTimer == nil then
        globalState.screensaverTimer = vim.uv.new_timer()
    end

    startScreensaverTimer()
end

M.userNotIdle = function()
    -- if the screensaver is on, turn it off
    if globalState.state == constants.FISHTANK_SHOWN_BY_TIMER then
        M.hideFishtank()
    end

    -- restart the screensaver timer
    startScreensaverTimer()
end

return M
