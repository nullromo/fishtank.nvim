local constants = require('fishtank.constants')
local luaUtils = require('fishtank.luaUtils')
local vimUtils = require('fishtank.vimUtils')

local M = {}

-- global window ID
local fishtankBufferID = nil
local fishtankWindowID = nil

-- global interval ID
local intervalID = nil

-- global fish object
local fish = {
    position = { row = 0, col = 0 },
    text = constants.RIGHT_FACING_FISH,
    travelPoints = {},
}

-- generate a random position in the editor
local randomPosition = function()
    local editorSize = vimUtils.getEditorSize()
    return {
        row = math.floor(math.random(editorSize.rows)),
        col = math.floor(math.random(editorSize.cols)),
    }
end

-- compute distance between points
local computeDistance = function(start, finish)
    return math.sqrt(
        math.pow(finish.row - start.row, 2)
            + math.pow(finish.col - start.col, 2)
    )
end

-- generates a smooth set of points between start and end
local sinspace = function(start, finish)
    -- compute distance scale based on maximum possible travel distance
    local editorSize = vimUtils.getEditorSize()
    local maxDistance = computeDistance(
        { row = 0, col = 0 },
        { row = editorSize.rows, col = editorSize.cols }
    )
    local distance = computeDistance(start, finish)
    local distanceScale = distance / maxDistance

    -- minimum travel points is based on how far the fish has to go. If the
    -- fish is not moving far, then distance scale will be small and it's
    -- allowed to only travel a few points. However, if the fish is moving
    -- far, then distance scale will be large and it's not allowed to zoom
    -- super fast
    local minTravelPoints = constants.MIN_TRAVEL_POINTS
        + constants.MIN_POINTS_SCALING
            * (constants.MAX_TRAVEL_POINTS - constants.MIN_TRAVEL_POINTS)
            * distanceScale
    if minTravelPoints > constants.MAX_TRAVEL_POINTS then
        minTravelPoints = constants.MAX_TRAVEL_POINTS
    end

    -- number of points to travel through to get to destination
    local numberOfPoints =
        math.floor(math.random(minTravelPoints, constants.MAX_TRAVEL_POINTS))

    -- compute the speed relative to the potential speed
    local speedFactor = (numberOfPoints - minTravelPoints)
        / (constants.MAX_TRAVEL_POINTS - minTravelPoints)
    if speedFactor < 0 then
        speedFactor = 0
    end

    -- array of points from 0 to 1
    local sinValues = {}
    for i = 1, numberOfPoints do
        local value = math.pi / 2 / numberOfPoints * i
        sinValues[i] = math.sin(value) * math.sin(value)
    end

    -- compute total distance
    local rowDistance = finish.row - start.row
    local colDistance = finish.col - start.col

    -- fill in points array
    local points = {}
    for i, point in ipairs(sinValues) do
        points[i] = {
            row = point * rowDistance + start.row,
            col = point * colDistance + start.col,
        }
    end

    -- add delay points
    local numberOfDelayPoints = math.floor(
        math.random(constants.MIN_DELAY_POINTS, constants.MAX_DELAY_POINTS)
    ) * (1 + speedFactor * constants.EXHAUSTION_FACTOR)
    for i = 1, numberOfDelayPoints do
        points[numberOfPoints + i] = { row = finish.row, col = finish.col }
    end

    return points
end

-- initializes the fish's data
local initializeFish = function()
    -- select a random position
    fish.position = randomPosition()

    -- select a random direction
    fish.text = luaUtils.ternary(
        math.random(2) == 1,
        constants.RIGHT_FACING_FISH,
        constants.LEFT_FACING_FISH
    )

    -- reset the travel points
    fish.travelPoints = {}
end

-- determine a new destination point and generate a list of points to
-- travel along to get to that point
local computeNewPath = function()
    local destination = randomPosition()
    return sinspace(fish.position, destination)
end

-- updates the fish's position
local updateFish = function()
    -- if the fish has no planned route, create a new one
    if #fish.travelPoints == 0 then
        -- get a new route
        fish.travelPoints = computeNewPath()

        -- update the fish's facing position based on the new destination
        fish.text = luaUtils.ternary(
            fish.travelPoints[#fish.travelPoints].col > fish.position.col,
            constants.RIGHT_FACING_FISH,
            constants.LEFT_FACING_FISH
        )
    end

    -- pop the first position in the route and move the fish there
    local position = table.remove(fish.travelPoints, 1)
    fish.position = position
end

-- redraws the fish
local updateFishtank = function()
    -- do nothing if the fishtank is not showing
    if fishtankWindowID == nil then
        return
    end

    -- move the fishtank window
    vim.api.nvim_win_set_config(fishtankWindowID, {
        relative = 'editor',
        row = fish.position.row,
        col = fish.position.col,
    })

    -- update the fish text
    vim.api.nvim_buf_set_lines(fishtankBufferID, 0, 1, false, { fish.text })
end

-- turns off the fishtank and wipes the state
M.hideFishtank = function()
    -- if the fishtank is not showing, do nothing
    if fishtankWindowID == nil then
        return
    end

    -- close the fishtank window
    vim.api.nvim_win_close(fishtankWindowID, true)

    -- reset the global window ID
    fishtankWindowID = nil

    -- clear interval and global ID
    vimUtils.clearInterval(intervalID)
    intervalID = nil
end

-- turns on the fishtank and initializes the state
M.showFishtank = function(args)
    -- if the fishtank is already showing, do nothing
    if fishtankWindowID ~= nil then
        return
    end

    -- initialize the fish
    initializeFish()

    -- create an unlisted scratch buffer
    fishtankBufferID = vim.api.nvim_create_buf(false, true)
    -- wipe the buffer when it is hidden
    vim.api.nvim_buf_set_var(fishtankBufferID, 'bufhidden', 'wipe')

    -- insert the fish text into the buffer
    vim.api.nvim_buf_set_lines(fishtankBufferID, 0, 1, false, { fish.text })

    -- create a floating window and set the global window ID
    fishtankWindowID = vim.api.nvim_open_win(fishtankBufferID, false, {
        relative = 'editor',
        width = 3,
        height = 1,
        row = fish.position.row,
        col = fish.position.col,
        focusable = false,
        mouse = false,
        zindex = 999,
        style = 'minimal',
        noautocmd = true,
    })

    -- start interval and set global ID
    intervalID = vimUtils.setInterval(constants.POINT_TRAVEL_TIME, function()
        updateFish()
        updateFishtank()
    end)
end

M.fishtankUserCommand = function(args)
    -- split arguments
    local splitResult = luaUtils.splitFirstToken(args)

    -- take action based on first argument
    if splitResult.first == 'start' then
        M.showFishtank()
    elseif splitResult.first == 'stop' then
        hideFishtank()
    elseif splitResult.first == 'toggle' then
        vim.print('TODO toggle')
    else
        vim.print(
            'Invalid Fishtank.nvim command. See `:h fishtank` for details.'
        )
    end
end

return M
