config = {
	MAX_WHEEL_VELOCITY = 15,
	MOVE_STEPS = 15,
	NUM_EXTRA_FRONT_SENSORS = 2,
	TURN_RATIO = 3,
	AVG_SENSORS = 3,
	MIN_LIGHT_THRESHOLD = 0.0,
	MIN_GROUND_THRESHOLD = 0.01,
	PROX_THRESHOLD = 0.1,
}

CONTROL_TAKEN = false
STEP = 0

function init() end
function reset() end
function destroy() end

function step()
	STEP = STEP + 1
	CONTROL_TAKEN = false

	halt_on_spot()
	avoid_front_obstacle()
	follow_light()
	random_walk()
	turn("up")
	go_forward()
	control_wheels(config.MAX_WHEEL_VELOCITY, config.MAX_WHEEL_VELOCITY)
end

-- layer 6
function halt_on_spot()
	if CONTROL_TAKEN then
		return
	end
	local spot = false
	for i = 1, 4 do
		if robot.motor_ground[i].value <= config.MIN_GROUND_THRESHOLD then
			spot = true
			break
		end
	end
	if spot then
		log("Spot detected, halting!")
		control_wheels(0, 0)
		CONTROL_TAKEN = true
	end
end

-- layer 5
function avoid_front_obstacle()
	if CONTROL_TAKEN then
		return
	end

	if detect_on_front() then
		log("Detected on front, looking for free positions")
		-- TODO: parameterise left/right/down detections with `config.AVG_SENSORS`
		local left_has_collisions = detect_on_sensors(6, 7)
		local right_has_collisions = detect_on_sensors(18, 19)
		local down_has_collision = detect_on_sensors(12, 13)

		-- prefer left and right movements instead of going backward
		-- (which, theoretically goes away from light (which can be good in some scenarios))
		if not left_has_collisions then
			turn("left")
		elseif not right_has_collisions then
			turn("right")
		else
			log("turning down..")
			turn("down")
		end
		CONTROL_TAKEN = true
	end
end

-- Layer 4
function follow_light()
	if CONTROL_TAKEN then
		return
	end
	local sensor, avg = get_max_ligh_sensor(config.AVG_SENSORS)
	if avg >= config.MIN_LIGHT_THRESHOLD then
		log("Light Detected!")
		if
			(sensor >= 1 and sensor <= 1 + config.NUM_EXTRA_FRONT_SENSORS)
			or (sensor <= 24 and sensor >= 24 - config.NUM_EXTRA_FRONT_SENSORS)
		then
			go_forward()
		elseif sensor > 1 + config.NUM_EXTRA_FRONT_SENSORS and sensor < 12 - config.NUM_EXTRA_FRONT_SENSORS then
			turn("left")
		elseif sensor >= 12 - config.NUM_EXTRA_FRONT_SENSORS and sensor <= 13 + config.NUM_EXTRA_FRONT_SENSORS then
			turn("down")
		else
			turn("right")
		end
		CONTROL_TAKEN = true
	end
end

-- Layer 3
function random_walk()
	if CONTROL_TAKEN then
		return
	end
	if STEP % config.MOVE_STEPS == 0 then
		log("Random walking")
		local left_v = robot.random.uniform(0, config.MAX_WHEEL_VELOCITY)
		local right_v = robot.random.uniform(0, config.MAX_WHEEL_VELOCITY)
		robot.wheels.set_velocity(left_v, right_v)
	end
	CONTROL_TAKEN = true
end

-- Layer 2
function turn(dir)
	if CONTROL_TAKEN then
		return
	end
	if dir == "left" then
		local r = (robot.wheels.velocity_left or 1) * config.TURN_RATIO
		control_wheels(0, r)
	elseif dir == "right" then
		local l = (robot.wheels.velocity_right or 1) * config.TURN_RATIO
		control_wheels(l, 0)
	elseif dir == "down" then
		local r = -(robot.wheels.velocity_left or 1)
		local l = -(robot.wheels.velocity_right or 1)

		control_wheels(l, r)
	else
		return
	end
	log("turned: " .. dir)
	CONTROL_TAKEN = true
end

-- Layer 1
function go_forward()
	if CONTROL_TAKEN then
		return
	end
	log("Going forward")
	control_wheels(config.MAX_WHEEL_VELOCITY, config.MAX_WHEEL_VELOCITY)
	CONTROL_TAKEN = true
end

-- Layer 0
function control_wheels(l, r)
	if CONTROL_TAKEN then
		return
	end
	l = math.min(config.MAX_WHEEL_VELOCITY, l)
	r = math.min(config.MAX_WHEEL_VELOCITY, r)
	robot.wheels.set_velocity(l, r)
	CONTROL_TAKEN = true
end

--[[
Utility functions
--]]

function get_max_ligh_sensor(n_avg)
	return get_max_for_sensor(n_avg, robot.light)
end

function detect_on_front()
	local front_left = circular_avg(1, config.AVG_SENSORS, robot.proximity)
	local front_right = circular_avg(23, config.AVG_SENSORS, robot.proximity)
	return ((front_left + front_right) / 2) >= config.PROX_THRESHOLD
end

function detect_on_sensors(center1, center2)
	local n = 2 + (config.AVG_SENSORS * 2)
	local agg_avg = 0

	for i = center1 - config.AVG_SENSORS, center2 + config.AVG_SENSORS do
		agg_avg = agg_avg + circular_avg(i, config.AVG_SENSORS, robot.proximity)
	end

	return (agg_avg / n) >= config.PROX_THRESHOLD
end

function circular_avg(index, n, sensors)
	local total = 0
	local count = 0
	local size = #sensors
	local left_n = math.floor(n / 2)
	local right_n = math.ceil(n / 2)

	for i = -left_n, right_n do
		local wrapped_index = ((index + i - 1) % size) + 1
		total = total + sensors[wrapped_index].value
		count = count + 1
	end

	return total / count
end

function get_max_for_sensor(n_avg, sensors)
	local sensor = -1
	local avg = -math.huge

	for i = 1, #sensors do
		local curr_avg = circular_avg(i, n_avg, sensors)
		if curr_avg > avg then
			avg = curr_avg
			sensor = i
		end
	end
	return sensor, avg
end
