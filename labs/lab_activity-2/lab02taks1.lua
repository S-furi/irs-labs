MAX_VELOCITY = 15
PROX_THRESHOLD = 0.55
DIRECTORION_CHANGE_FACTOR = 1

local utils = require "utils"
local testing = require "testing"
local score = nil
local min_distance = math.huge

function init() end

function reset()
	testing.reset_steps()
	score = nil
	min_distance = math.huge
end

function destroy()
	if score == nil then
		log("Robot cannot reach light in thresholds steps")
		log("Min distance reached: " .. min_distance)
	else
		log("score: " .. score)
	end
end

function step()
	local l, r = avoid_obstacles()
	if l ~= nil and r ~= nil then
		robot.wheels.set_velocity(l, r)
	else
		follow_light()
	end
	local curr_score, curr_distance = testing.test_light_proximity(robot, { x = -1, y = 0 })
	if curr_score ~= nil and score == nil then
		score = curr_score
		log("Robot reached light in: " .. score .. " steps!")
	else
		if curr_distance < min_distance then
			min_distance = curr_distance
			log("min_distance: " .. min_distance)
		end
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
