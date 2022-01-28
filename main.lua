local speaker = peripheral.find("speaker")
local bundledConnection = "back"
local monitor = peripheral.find("monitor")
local dataSave = "disk/savedData.txt"
local diskDrive = peripheral.wrap("top")

local outputs = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
local allColors = colors.combine(
colors.white,
colors.orange,
colors.magenta,
colors.lightBlue,
colors.yellow,
colors.lime,
colors.pink,
colors.gray,
colors.lightGray,
colors.cyan,
colors.purple,
colors.blue,
colors.brown,
colors.green,
colors.red,
colors.black)

term.redirect(monitor)

--Define output (0-15) for each connected redstone device on bundled output 1
local alarmLights = 1
local testRed = 2
local testThree = 3
local testFour = 4

--Define buttons as nested Tables
--xOne, yOne, xTwo, yTwo, control, state, label
local buttons = {
	{2, 2, 9, 4, alarmLights, false, "Lights"},
	{11, 2, 18, 4, testRed, false, "Test"},
	{11, 6, 18, 8, testThree, false, "Test2"},
	{2, 6, 9, 8, testFour, false, "Test3"}
}
--Must manually update!!!
local numButtons = 4

--Misc Variables

local tempNum = 0

--Functions

function saveAll()
	f = io.open(dataSave, "w+")
	for i = 1, 16 do
		if outputs[i] == true then
			f:write("a" .. "\n")
		else
			f:write("b" .. "\n")
		end
	end
	io.close(f)
end

function readData()
	f = io.open(dataSave)
	i = 1
	for line in io.lines(dataSave) do
		if line == "a" then
			outputs[i] = true
		else
			outputs[i] = false
		end
		i = i + 1
	end
	io.close(f)
end

function drawButton(n)
	local tab = buttons[n]
	if tab[6] == true then
		paintutils.drawFilledBox(tab[1], tab[2], tab[3], tab[4], colors.green)
	else
		paintutils.drawFilledBox(tab[1], tab[2], tab[3], tab[4], colors.red)
	end
	monitor.setCursorPos((((tab[3] + tab[1]) / 2) - string.len(tab[7]) / 2) + 1, ((tab[4] + tab[2]) / 2))
	print(tab[7])
	monitor.setBackgroundColor(colors.black)
end

function updateOutput()
	local colorStatesColors = allColors
	for i = 0, 16 do
		if outputs[i] == false then
			if i == 0 then
				colorStatesColors = colors.subtract(colorStatesColors, 1)
			else
				colorStatesColors = colors.subtract(colorStatesColors, 2 ^ i)
			end
		end
	end
	
	redstone.setBundledOutput(bundledConnection, colorStatesColors)
end

function toggleOn(n)
	outputs[n] = true;
	updateOutput();
end

function toggleOff(n)
	outputs[n] = false;
	updateOutput();
end

function toggle(n)
	outputs[n] = not outputs[n];
	updateOutput();
end

function doButton(n, xPos, yPos)
	local tab = buttons[n]
	if(xPos >= tab[1] and xPos <= tab[3] and yPos >= tab[2] and yPos <= tab[4]) then
		tab[6] = not tab[6]
		toggle(tab[5])
	end
	drawButton(n)
end

function buttonInit(n)
	local tab = buttons[n]
	if outputs[n] == true then
		tab[6] = true
	else
		tab[6] = false
	end
end

--Main Section for Creating GUI
readData()

for i = 1, numButtons do
	buttonInit(i)
end

updateOutput()
	
monitor.clear()

while true do

	for i = 1, numButtons do
		drawButton(i)
	end
	
	event, side, xPos, yPos = os.pullEvent("monitor_touch")
	
	for j = 1, numButtons do
		doButton(j, xPos, yPos)
	end
	
	monitor.clear()
	saveAll()
end

--Extra
drawButton(lightButton)
	drawButton(testButton)
	drawButton(testButtonTwo)
	drawButton(testButtonThree)
	
	doButton(lightButton, xPos, yPos)
	doButton(testButton, xPos, yPos)
	doButton(testButtonTwo, xPos, yPos)
	doButton(testButtonThree, xPos, yPos)
