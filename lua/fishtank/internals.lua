local Fish = require('fishtank.fish')
local colors = require('fishtank.colors')
local constants = require('fishtank.constants')
local luaUtils = require('fishtank.util.lua')
local options = require('fishtank.options')
local vimUtils = require('fishtank.util.vim')

local M = {}

---@alias FishtankGlobalState {
---    fishList: Fish[],
---    intervalID: uv.uv_timer_t | nil,
---    state: FishtankState,
---    paused: boolean,
---    screensaverTimer: uv.uv_timer_t | nil,
---}

-- global state
---@type FishtankGlobalState
local globalState = {
    fishList = {},
    intervalID = nil,
    state = constants.FISHTANK_HIDDEN,
    paused = false,
    screensaverTimer = nil,
}

-- initializes the fishList data
---@return nil
local initializeFish = function()
    local fishList = {}
    for _ = 1, options.opts.numberOfFish do
        table.insert(fishList, Fish:new())
    end

    -- initialize global state with fish
    globalState.fishList = fishList
end

-- updates all fish
---@return nil
local updateAllFish = function()
    -- do nothing if paused
    if globalState.paused then
        return
    end

    -- update all fish in the fishList
    for _, fish in ipairs(globalState.fishList) do
        fish:update()
    end
end

-- redraws all the fish
---@return nil
local redrawFishtank = function()
    -- do nothing if the fishtank is not showing
    if globalState.state == constants.FISHTANK_HIDDEN then
        return
    end

    for _, fish in ipairs(globalState.fishList) do
        -- if the window is somehow closed
        if not vim.api.nvim_win_is_valid(fish.windowID) then
            -- TODO: should be made per fish once we have multiple fish support
            M.hideFishtank()
            M.userNotIdle()
            break
        end

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
---@return nil
local closeAllFishWindows = function()
    for _, fish in ipairs(globalState.fishList) do
        fish:close()
    end
end

-- turns off the fishtank and wipes the state
---@return nil
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
---@param args? { state: FishtankState }
---@return nil
M.showFishtank = function(args)
    -- if the fishtank is not already showing, show it
    if globalState.state == constants.FISHTANK_HIDDEN then
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
    end

    -- update the global state
    globalState.state = (args or {}).state or constants.FISHTANK_SHOWN_BY_USER
end

-- shows or hides the fish
---@return nil
M.toggleFishtank = function()
    if globalState.state == constants.FISHTANK_HIDDEN then
        M.showFishtank()
    else
        M.hideFishtank()
    end
end

-- handles the :Fishtank user command
---@param args string
---@return nil
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

-- pauses fish updates
---@return nil
M.pauseFishtank = function()
    globalState.paused = true
end

-- resumes fish updates
---@return nil
M.resumeFishtank = function()
    globalState.paused = false
end

-- starts the screensaver timer
---@return nil
local startScreensaverTimer = function()
    globalState.screensaverTimer:start(
        options.opts.screensaver.timeout,
        0,
        vim.schedule_wrap(function()
            if globalState.state == constants.FISHTANK_HIDDEN then
                M.showFishtank({
                    state = constants.FISHTANK_SHOWN_BY_TIMER,
                })
            end
        end)
    )
end

-- initializes the screensaver timer
---@return nil
M.initializeScreensaver = function()
    -- create timer if it doesn't exist
    if globalState.screensaverTimer == nil then
        globalState.screensaverTimer = vim.uv.new_timer()
    end

    startScreensaverTimer()
end

-- called when the user does something that interrupts the screensaver
---@return nil
M.userNotIdle = function()
    -- if the screensaver is on, turn it off
    if globalState.state == constants.FISHTANK_SHOWN_BY_TIMER then
        M.hideFishtank()
    end

    -- restart the screensaver timer
    startScreensaverTimer()
end

return M
