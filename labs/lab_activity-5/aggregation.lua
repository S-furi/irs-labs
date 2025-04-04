config = {
	N_STEPS_STRAIGHT = 15,
	N_STEPS_TURNING = 5,
	MAX_WHEEL_TURNING_SPEED = 15,
	MAX_VELOCITY = 15,
	DEFAULT_STRAIGHT_VELOCITY = 15,
	PROX_THRESHOLD = 0.80,
	R_B_RANGE = 30,
	MIN_GROUND_THRESHOLD = 0.01,
	PROBABILITIES = {
		W = 0.1,
		S = 0.01,
		P_S_MAX = 0.99,
		P_W_MIN = 0.005,
		D_S = 0.05,
		D_W = 0.01,
		ALPHA = 0.1,
		BETA = 0.05,
	}
}

states = {
	WANDER_STRAIGHT = "wander",
	WANDER_TURNING = "turning",
	STOPPED = "stopped",
}

N_STEPS = 0
CUR_STATE = states.STOPPED
RESUME_STATE = states.WANDER_STRAIGHT
CUR_L, CUR_R = 0, 0

function reset_state()
	N_STEPS = 0
	CUR_STATE = states.STOPPED
	CUR_L, CUR_R = 0, 0
end

function init() reset_state() end

function reset() reset_state() end

function destroy() end

function step()
	notify_others(CUR_STATE)
	local state = get_next_state(CUR_STATE)

	local is_changed = false
	if state ~= CUR_STATE then
		N_STEPS = 0
		is_changed = true
	else
		N_STEPS = N_STEPS + 1
	end

	CUR_STATE = state
	handle_state(CUR_STATE, is_changed)
end

function handle_state(state, init)
	if state == states.STOPPED then
		robot.wheels.set_velocity(0, 0)
	elseif state == states.WANDER_STRAIGHT then
		go_forward(init)
	elseif state == states.WANDER_TURNING then
		turn(init)
	end
end

function get_next_state(state)
	local n = count_rab()
	if state == states.STOPPED then
		local pw = compute_moving_probability(n)
		local t = robot.random.uniform()
		if t <= pw then
			robot.leds.set_all_colors("green")
			return states.WANDER_STRAIGHT
		end
	else
		local ps = compute_stop_probability(n)
		local t = robot.random.uniform()
		if t <= ps then
			robot.leds.set_all_colors("red")
			return states.STOPPED
		end

		if check_collisions() then
			robot.leds.set_all_colors("blue")
			return states.WANDER_TURNING
		end

		if state == states.WANDER_STRAIGHT then
			if N_STEPS >= config.N_STEPS_STRAIGHT then
				robot.leds.set_all_colors("yellow")
				return states.WANDER_TURNING
			end
		end

		if state == states.WANDER_TURNING then
			if N_STEPS >= config.N_STEPS_TURNING then
				robot.leds.set_all_colors("green")
				return states.WANDER_STRAIGHT
			end
		end
	end
	return state
end

function check_collisions()
	local max_val = -math.huge
	for i = 1, #robot.proximity do
		local val = robot.proximity[i].value
		if val > max_val then max_val = val end
	end
	return max_val >= config.PROX_THRESHOLD
end

function go_forward(init)
	if init then
		robot.wheels.set_velocity(config.DEFAULT_STRAIGHT_VELOCITY, config.DEFAULT_STRAIGHT_VELOCITY)
	end
end

function turn(init)
	if init then
		local l, r = get_random_turning_velocities()
		robot.wheels.set_velocity(l, r)
	end
end

function notify_others(state)
	if state == states.STOPPED then
		robot.range_and_bearing.set_data(1,1)
	else
		robot.range_and_bearing.set_data(1,0)
	end
end

function compute_stop_probability(n)
	local p_g_s = 0
	if check_on_spot() then
		p_g_s = config.PROBABILITIES.D_S
	end
	return math.min(config.PROBABILITIES.P_S_MAX, config.PROBABILITIES.S + (config.PROBABILITIES.ALPHA * n) + p_g_s)
end

function compute_moving_probability(n)
	local p_d_w = 0
	if check_on_spot() then
		p_d_w = config.PROBABILITIES.D_W
	end
	return math.max(config.PROBABILITIES.P_W_MIN, config.PROBABILITIES.W - (config.PROBABILITIES.BETA * n) - p_d_w)
end

function check_on_spot()
	local spot = false
	for i = 1, 4 do
		if robot.motor_ground[i].value <= config.MIN_GROUND_THRESHOLD then
			spot = true
			break
		end
	end
	return spot
end

function get_random_turning_velocities()
	local vel = robot.random.uniform(5, config.MAX_WHEEL_TURNING_SPEED)
	if robot.random.uniform() >= 0.5 then
		-- turn right
		return vel, 0
	else
		return 0, vel
	end
end

function count_rab()
	local n_robot_sensed = 0
	for i = 1, #robot.range_and_bearing do
		if robot.range_and_bearing[i].range < config.R_B_RANGE and robot.range_and_bearing[i].data[1] == 1 then
			n_robot_sensed = n_robot_sensed + 1
		end
	end
	return n_robot_sensed
end
