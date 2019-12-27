-- Initialize pinoutput
gpio.mode(2, gpio.OUTPUT)
gpio.mode(3, gpio.OUTPUT)
gpio.mode(5, gpio.OUTPUT)

-- Global variables
motorDelay = 1400
desiredTemp = 160
currentTemp = 0
tempControl = true

-- Global timers
motorLoop = tmr.create()
tempLoop = tmr.create()

R1 = 10000
c1 = 2.114990448e-03
c2 = 0.3832381228e-04
c3 = 5.228061052e-07

function log(x)
  assert(x > 0)
  local a, b, c, d, e, f = x < 1 and x or 1/x, 0, 0, 1, 1
  repeat
     repeat
        c, d, e, f = c + d, b * d / e, e + 1, c
     until c == f
     b, c, d, e, f = b + 1 - a * c, 0, 1, 1, b
  until b <= f
  return a == x and -f or f
end

 function log10(i)
  local x = i
  print(x)
  if (x < 0) then
    x = x * -1
    print("Fixed: " .. x)
  end
  if (x == 0) then
    x = 0.1
  end
  return log(x) / 2.3025850929940459
end

function round(number)
  if (number - (number % 0.1)) - (number - (number % 1)) < 0.5 then
    number = number - (number % 1)
  else
    number = (number - (number % 1)) + 1
  end
 return number
end


print('Setting up WIFI...')
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid='Salva', pwd='12345679', auto=true})

local connectionLoop = tmr.create()
connectionLoop:alarm(1000, tmr.ALARM_AUTO, function()
	if wifi.sta.getip() == nil then
		print('Waiting for IP ...')
	else
		gpio.write(5, gpio.HIGH)
        print('IP is ' .. wifi.sta.getip())
        dofile('server.lua')
        dofile('main.lua')
        connectionLoop:stop(1)
	end
end)