local utils = require("utils")

MOVE_STEPS = 15
MAX_VELOCITY = 10
DIRECTORION_CHANGE_FACTOR = 0.5

local function reset_state()
	left_v = robot.random.uniform(0, MAX_VELOCITY)
	right_v = robot.random.uniform(0, MAX_VELOCITY)
	robot.wheels.set_velocity(left_v, right_v)
	robot.leds.set_all_colors("black")
end

function init()
	reset_state()
end

function reset()
	reset_state()
end

function destroy() end

function step()
	follow_light()
end

function follow_light()
	local max_light, _ = utils.get_max_for_sensor(2, robot.light)
	local angle = robot.light[max_light].angle

	log("Highest light found at light[" .. max_light .. "] with an angle=" .. angle)

	local l = robot.wheels.velocity_left
	local r = robot.wheels.velocity_right

	if max_light == 1 or max_light == 24 then
		local max = math.max(l, r)
		robot.wheels.set_velocity(max, max)
	end

	if angle > 0 then
		r = math.min(r + DIRECTORION_CHANGE_FACTOR, MAX_VELOCITY)
		l = math.max(l - DIRECTORION_CHANGE_FACTOR, 1)
	else
		l = math.min(l + DIRECTORION_CHANGE_FACTOR, MAX_VELOCITY)
		r = math.max(r - DIRECTORION_CHANGE_FACTOR, 1)
	end
	robot.wheels.set_velocity(l, r)
end
