utils = {}

function neighbor_weighted_avg(index, n, sensors)
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

function utils.get_max_for_sensor(n_avg, sensors)
	local sensor = -1
	local avg = -math.huge

	for i = 1, #sensors do
		local curr_avg = neighbor_weighted_avg(i, n_avg, sensors)
		if curr_avg > avg then
			avg = curr_avg
			sensor = i
		end
	end
	return sensor, avg
end

return utils

