-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
DIRECTORION_CHANGE_FACTOR = 0.5
LIGHT_THRESHOLD = 1.5

n_steps = 0


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	-- n_steps = n_steps + 1
	-- if n_steps % MOVE_STEPS == 0 then
	-- 	left_v = robot.random.uniform(0,MAX_VELOCITY)
	-- 	right_v = robot.random.uniform(0,MAX_VELOCITY)
	-- end
	-- robot.wheels.set_velocity(left_v,right_v)

	follow_light()
end

-- [ TODO: add check for overflow (24-1)
function get_max_light()
	local max_light = 2
	local max_avg = (robot.light[1].value + robot.light[2].value + robot.light[3].value) / 3
	local n_avg = 3
	local l_r_neigh = n_avg % 2

	local n = #robot.light

	for i = 1 + l_r_neigh, n - l_r_neigh do

		local l_sum = 0
		local r_sum = 0
		
		for j = i - l_sum, i do
			l_sum = l_sum + robot.light[j].value
		end

		for j = i + r_sum, i, -1 do
			l_sum = l_sum + robot.light[j].value
		end

		local avg = (l_sum + r_sum + robot.light[i].value) / n_avg

		if avg > max_avg then
			max_avg = avg
			max_light = i
		end

	end

	return max_light
end

function follow_light()
	local max_light = get_max_light()
	local angle = robot.light[max_light].angle

	log("Highest light found at light[" .. max_light .. "] with an angle=" .. angle)

	local l = robot.wheels.velocity_left
	local r = robot.wheels.velocity_right


	if max_light == 1 or max_light == 24 then
		local max = math.max(l, r)
		robot.wheels.set_velocity(max, max)
	end
	
	if angle > 0 then
		if r < MAX_VELOCITY then
			r = r + DIRECTORION_CHANGE_FACTOR
		end
		if l > 1 then
			l = l - DIRECTORION_CHANGE_FACTOR
		end
	else
		if l < MAX_VELOCITY then
			l = l + DIRECTORION_CHANGE_FACTOR
		end
		if r > 1 then
			r = r - DIRECTORION_CHANGE_FACTOR
		end
	end
	robot.wheels.set_velocity(l, r)
end



--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
