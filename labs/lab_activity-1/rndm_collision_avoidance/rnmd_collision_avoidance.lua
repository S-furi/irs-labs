-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
PROX_THRESHOLD = 0.15 

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
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		left_v = robot.random.uniform(0,MAX_VELOCITY)
		right_v = robot.random.uniform(0,MAX_VELOCITY)
	end
	robot.wheels.set_velocity(left_v,right_v)


	-- Search for the reading with the highest value
	value = -1 -- highest value found so far
	idx = -1   -- index of the highest value
	for i=1,#robot.proximity do
		if value < robot.proximity[i].value then
			idx = i
			value = robot.proximity[i].value
		end
	end
	log("robot max proximity sensor: " .. idx .. "," .. value)

end

function avoid_obstacles()
	local sensor = get_prox_sensor_avg(3, function (curr, max) return curr > max end)
	
end

function get_prox_sensor_avg(n_avg, func)
	local sensor = 1
	local avg = -math.huge

	for i = 1, #robot.proximity do
		local curr_avg = circular_avg(i, n_avg)
		if func(curr_avg, avg) then
			avg = curr_avg
			sensor = i
		end
	end
	return sensor
end


function circular_avg(index, n)
    local total = 0
    local count = 0
    local size = #robot.proximity
    local left_n = math.floor(n / 2)
    local right_n = math.ceil(n / 2)

    for i = -left_n, right_n do
        local wrapped_index = ((index + i - 1) % size) + 1
        total = total + robot.proximity[wrapped_index].value
        count = count + 1
    end

    return total / count
end

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
