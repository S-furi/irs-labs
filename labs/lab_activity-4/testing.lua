testing = {}

local N_STEPS=0
local LIGHT_THRESHOLD = 0.1

function testing.reset_steps()
	N_STEPS = 0
end

function testing.test_light_proximity(robot, light)
	local x = robot.positioning.position.x
	local y = robot.positioning.position.y

	local dist_x = math.abs(light.x - x)
	local dist_y = math.abs(light.y - y)

	local distance = euclidean_distance_score(x, y, light.x, light.y)

	if dist_x > LIGHT_THRESHOLD or dist_y > LIGHT_THRESHOLD then
		N_STEPS = N_STEPS + 1
		return nil, distance
	end
	return N_STEPS, distance
end

function euclidean_distance_score(r_x, r_y, l_x, l_y)
	return math.sqrt((r_x - l_x)^2 + (r_y + l_y)^2)
end

function testing.get_curr_step_n()
	return N_STEPS
end

return testing
