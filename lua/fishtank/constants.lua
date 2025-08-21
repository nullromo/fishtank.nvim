local M = {}

-- time to wait between updates
M.POINT_TRAVEL_TIME = 100 -- milliseconds per point (ms/pt)

-- number of points per path
M.MIN_TRAVEL_POINTS = 10 -- half a second at 100 ms/pt
M.MAX_TRAVEL_POINTS = 50 -- five seconds at 100 ms/pt

-- scaling factor for speed limiting
M.MIN_POINTS_SCALING = 0.9

-- min number of delay points after travel
M.MIN_DELAY_POINTS = 0 -- 0 seconds (no additional delay)
M.MAX_DELAY_POINTS = 20 -- two seconds at 100 ms/pt

-- scaling factor for exhaustion
M.EXHAUSTION_FACTOR = 3 -- amount to scale delay by based on speed

-- plugin states
M.FISHTANK_HIDDEN = 'hidden'
M.FISHTANK_SHOWN_BY_USER = 'shown by user'
M.FISHTANK_SHOWN_BY_TIMER = 'shown by timer'

return M
