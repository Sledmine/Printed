-- Set motor direction 
gpio.write(3, gpio.HIGH)

local function motor()
    if (startMotor) then
        gpio.write(2, gpio.HIGH)
        tmr.delay(motorDelay)
        gpio.write(2, gpio.LOW)
        tmr.delay(motorDelay)
    else
        gpio.write(2, gpio.LOW)
    end
end

local function temp()
    local Vo = adc.read(0)
    local R2 = R1 * (1023.0 / Vo - 1.0)
    local logR2 = log10(R2)
    local tempCalculation
    tempCalculation = (1.0 / (c1 + c2 * logR2 + c3 * logR2 * logR2 * logR2))
    tempCalculation = tempCalculation - 273.15
    currentTemp = round(tempCalculation)
    if (tempControl) then
        if (currentTemp < desiredTemp) then
            gpio.write(1, gpio.LOW)
        else
            gpio.write(1, gpio.HIGH)
            --startMotor = true
        end
    end
end

motorLoop:alarm(4, tmr.ALARM_AUTO, motor)
tempLoop:alarm(350, tmr.ALARM_AUTO, temp)
