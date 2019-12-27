-- Serving static files
dofile('httpServerm.lua')
httpServer:listen(80)

-- Launch temperature
httpServer:use('/temperature', function(req, res)
	local inputTemp = tonumber(req.query.temperature)
	if (inputTemp) then
		desiredTemp = inputTemp
		print("Desired sent temperature: " .. tostring(desiredTemp))
	end
	res:type('text/plain')
	res:send('{"OK"}')
end)

-- Get json
httpServer:use('/temp', function(req, res)
	res:type('text/plain')
	res:send(currentTemp)
end)

-- Trigger stop
httpServer:use('/stop', function(req, res)
	--tempControl = false
	startMotor = false
	res:type('text/plain')
	res:send('{"OK"}')
end)

-- Trigger start
httpServer:use('/start', function(req, res)
	--tempControl = true
	startMotor = true
	res:type('text/plain')
	res:send('{"OK"}')
end)