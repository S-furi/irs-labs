-- Define robot structure for suppressing LSP errors (ARGoS will provide the actual robot object)
---@diagnostic disable: undefined-global
if false then -- This block is never executed at runtime
	---@class Robot
	robot = {
		light = { [1] = { value = 0, angle = 0 }, velocity_right = 0, velocity_left = 0 }, -- 24
		proximity = { [1] = { value = 0, angle = 0 } }, -- 24
		motor_ground = { [1] = { value = 0, angle = 0 } }, -- NW, SW, SE, NE
		wheels = { left = 0, right = 0 },
		random = { uniform = 0 },
	}
end
---@diagnostic enable: undefined-global

local vector = require("vector")
local utils = require("utils")

local config = {
	MAX_WHEEL_VELOCITY = 15,
	MOVE_STEPS = 15,
	NUM_EXTRA_FRONT_SENSORS = 2,
	TURN_RATIO = 1,
	AVG_SENSORS = 3,
	RND_N_STEPS = 5,
	MIN_LIGHT_THRESHOLD = 0.05,
	MIN_PROX_THRESHOLD = 0.05,
	MIN_GROUND_THRESHOLD = 0.01,
	PROX_THRESHOLD = 0.1,
	D_PROX = 0.65,
	D_LIGHT = 0.65,
}

STEP = 0

function init() end
function reset() end
function destroy() end

function step()
	STEP = STEP + 1
	local p_vec = phototaxis()
	local c_vec = collision_avoidance()
	local r_vec = random_walk()

	local vectors = { p_vec, c_vec, r_vec }
	local acc = { length = 0, angle = 0 }
	for _,  vec in ipairs(vectors) do
		acc = vector.vec2_polar_sum(acc, vec)
	end

	log("resulting vector: " .. acc.length .. ", " .. acc.angle)
	local l, r = vector.to_differential_steering(robot, acc)
	robot.wheels.set_velocity(l, r)

end

function phototaxis()
	local max_sensor, max_val = 1, robot.light[1].value

	for i = 2, #robot.light do
		local value = robot.light[i].value
		if value > max_val then
			max_val = value
			max_sensor = i
		end
	end

	local len = 0.0
	local angle = 0.0
	if max_val > config.MIN_LIGHT_THRESHOLD then
		-- attractive potential field correction (slow down when approaching light)
		len = (1 - (max_val / config.D_LIGHT))
		angle = robot.light[max_sensor].angle
	end
	return { length = len, angle = angle }
end

function collision_avoidance()
	local acc = { length = 0, angle = 0 }

	for i = 1, #robot.proximity do
		local value = robot.proximity[i].value
		local angle = robot.proximity[i].angle
		if angle > 0 then
			angle = angle - math.pi
		else
			angle = angle + math.pi
		end

		acc = vector.vec2_polar_sum(acc, { length = value, angle = angle })
	end

	return acc
end

function random_walk()
	local _, max_prox_val = utils.get_max_for_sensor(1, robot.proximity)
	local _, max_light_val = utils.get_max_for_sensor(1, robot.light)

	if (max_prox_val < config.MIN_PROX_THRESHOLD) and (max_light_val < config.MIN_LIGHT_THRESHOLD) then
		local angle = 0
		if STEP % config.RND_N_STEPS == 0 then
			-- random angle
			angle = robot.random.uniform(-math.pi / 2, math.pi / 2)
		end
		return { length = 0.2, angle = angle }
	end

	return { length = 0.0, angle = 0.0 }
end


