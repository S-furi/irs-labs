MOVE_STEPS = 15
MAX_VELOCITY = 15
DIRECTORION_CHANGE_FACTOR = 1
LIGHT_THRESHOLD = 1.5
PROX_THRESHOLD = 0.05

function init()
end

function reset()
end

function destroy()
end

function step()
	if (detect_on_front()) then
		log('found something on front!')
		-- avoid_obstacle(get_min_prox_sensor(3))
		random_obstacle_avoidance()
	else
		follow_light()
	end
end

function follow_light()
	local max_sensor = get_max_ligh_sensor(3)
	if max_sensor == -1 then
		max_sensor = 1
	end

	local r = 0
	local l = 0

	if max_sensor == 1 or max_sensor == 24 then
		l = MAX_VELOCITY
		r = MAX_VELOCITY
	elseif max_sensor <= 13 then
		if r <= MAX_VELOCITY then
			r = robot.wheels.velocity_right + DIRECTORION_CHANGE_FACTOR
		end
	else
		if l <= MAX_VELOCITY then
			l = robot.wheels.velocity_left + DIRECTORION_CHANGE_FACTOR
		end
	end
	robot.wheels.set_velocity(l, r)
end

function random_obstacle_avoidance()
	local min_sensors = get_prox_sensors_below_thresh(3)
	local min_sensor = get_random_free_direction_light_aware(min_sensors)
	avoid_obstacle(min_sensor)
end

function get_random_free_direction(min_sensors)
	if #min_sensors > 0 then
		local random_index = math.random(1, #min_sensors)
		return min_sensors[random_index]
	else
		return get_min_prox_sensor(3)
	end
end

function get_random_free_direction_light_aware(min_sensors)
	local highest_light_sensor = get_max_ligh_sensor(3)
	if contains(min_sensors, highest_light_sensor) then
		return highest_light_sensor
	end
	if #min_sensors > 0 then
		local random_index = math.random(1, #min_sensors)
		return min_sensors[random_index]
	else
		return get_min_prox_sensor(3)
	end
end

function contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true  -- Element found
        end
    end
    return false  -- Element not found
end


function avoid_obstacle(min_sensor)

	local l = 0
	local r = 0

	if min_sensor == 1 or min_sensor == 24 then -- fron is clear
		l = MAX_VELOCITY
		r = MAX_VELOCITY
	elseif min_sensor < 13 then -- we're on the left hand side
		r = robot.wheels.velocity_right + DIRECTORION_CHANGE_FACTOR
	else
		l = robot.wheels.velocity_left + DIRECTORION_CHANGE_FACTOR
	end
	robot.wheels.set_velocity(l, r)
end

function detect_on_sensor(sensor_idx)
	return circular_avg(sensor_idx, 3, robot.proximity) > PROX_THRESHOLD
end

function detect_on_front()
	local front_left = circular_avg(1, 3, robot.proximity)
	local front_right = circular_avg(23, 3, robot.proximity)

	return ((front_left + front_right) / 2) > PROX_THRESHOLD
end

function get_max_ligh_sensor(n_avg)
	return get_max_for_sensor(n_avg, robot.light)
end

function get_min_prox_sensor(n_avg)
	return get_min_for_sensor(n_avg, robot.proximity)
end

function get_prox_sensors_below_thresh(n_avg)
	local sensors = {}

	for i = 1, #robot.proximity do
		local curr_avg = circular_avg(i, n_avg, robot.proximity)
		if curr_avg <=  PROX_THRESHOLD then
			table.insert(sensors, i)
		end
	end
	return sensors
end

function get_max_for_sensor(n_avg, sensors)
	local sensor = -1
	local avg = -math.huge

	for i = 1, #sensors do
		local curr_avg = circular_avg(i, n_avg, sensors)
		if curr_avg >  avg then
			avg = curr_avg
			sensor = i
		end
	end
	return sensor
end

function get_min_for_sensor(n_avg, sensors)
	local sensor = 1
	local avg = math.huge

	for i = 1, #sensors do
		local curr_avg = circular_avg(i, n_avg, sensors)
		if curr_avg <  avg then
			avg = curr_avg
			sensor = i
		end
	end
	return sensor
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

