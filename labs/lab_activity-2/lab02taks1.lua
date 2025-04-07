MAX_VELOCITY = 15
PROX_THRESHOLD = 0.55
DIRECTORION_CHANGE_FACTOR = 1

local utils = require "utils"

function init() end

function reset() end

function destroy() end

function step()
	local l, r = avoid_obstacles()
	if l ~= nil and r ~= nil then
		robot.wheels.set_velocity(l, r)
	else
		follow_light()
	end
end

function follow_light()
	local sensor, _ = utils.get_max_for_sensor(2, robot.light)
	local angle = robot.light[sensor].angle

	local l = robot.wheels.velocity_left
	local r = robot.wheels.velocity_right

	if sensor == 1 or sensor == 24 then
		robot.wheels.set_velocity(MAX_VELOCITY, MAX_VELOCITY)
	end

	if angle > 0 then
		r = MAX_VELOCITY
		l = 0
	else
		r = 0
		l = MAX_VELOCITY
	end
	robot.wheels.set_velocity(l, r)
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
	end
	return nil
end
