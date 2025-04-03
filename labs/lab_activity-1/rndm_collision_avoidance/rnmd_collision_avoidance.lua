local utils = require "utils"

MOVE_STEPS = 15
MAX_VELOCITY = 15
PROX_THRESHOLD = 0.55

n_steps = 0

local function reset_state()
	local left_v = robot.random.uniform(0,MAX_VELOCITY)
	local right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function init()
	reset_state()
end

function reset()
	reset_state()
end


function destroy()
end

function step()
	local l, r = avoid_obstacles()
	if l ~= nil and r ~= nil then
		robot.wheels.set_velocity(l, r)
	else
		random_walk()
	end
end

function random_walk()
	n_steps = n_steps + 1

	local left_v = robot.wheels.velocity_left
	local right_v = robot.wheels.velocity_right

	if n_steps % MOVE_STEPS == 0 then
		left_v = robot.random.uniform(0,MAX_VELOCITY)
		right_v = robot.random.uniform(0,MAX_VELOCITY)
	end
	robot.wheels.set_velocity(left_v,right_v)
end

function avoid_obstacles()
	local sensor, value = utils.get_max_for_sensor(2, robot.proximity)
	if value > PROX_THRESHOLD then
		local angle = robot.proximity[sensor].angle

		if angle > 0 then
			return MAX_VELOCITY, 0
		else
			return 0, MAX_VELOCITY
		end
	else
		return nil
	end
end
