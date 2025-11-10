local constants = require('fishtank.constants')
local mathUtils = require('fishtank.util.math')
local vimUtils = require('fishtank.util.vim')

local M = {}

-- generate a random position in the editor
---@return Point
M.randomPosition = function()
    local editorSize = vimUtils.getEditorSize()
    return {
        row = math.floor(math.random(editorSize.rows)),
        col = math.floor(math.random(editorSize.cols)),
    }
end

-- generates a smooth set of points between start and end
---@param start Point
---@param finish Point
---@return Point[]
local sinspace = function(start, finish)
    -- compute distance scale based on maximum possible travel distance
    local editorSize = vimUtils.getEditorSize()
    local maxDistance = mathUtils.computeDistance(
        { row = 0, col = 0 },
        { row = editorSize.rows, col = editorSize.cols }
    )
    local distance = mathUtils.computeDistance(start, finish)
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
    ---@type Point[]
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

-- determine a new destination point and generate a list of points to
-- travel along to get to that point
---@param fish Fish
---@return Point[]
M.computeNewPath = function(fish)
    local destination = M.randomPosition()
    return sinspace(fish.position, destination)
end

return M
