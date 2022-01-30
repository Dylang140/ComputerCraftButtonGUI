--Dylang140 
--January 29, 2022
--CC Tewaked GUI Prorgam
--Intended for CC Tweaked and Immersive Engineering for Minecraft 1.18
--Feel free to change or copy this code for other mods, versions, or projects

--======CONFIG SECTION======--

local speaker = peripheral.find("speaker")
local bundledConnection = "back"
local bundledInput = "left"
local monitor = peripheral.find("monitor")
local dataSave = "disk/savedData.txt"
local diskDrive = peripheral.wrap("top")
local capA, capB = peripheral.find("capacitor_hv") 
--local capA = caps[1]
--local capB = caps[2]

--==========================--

--========GUI BUILD SECTION=========--

--Define output (1-16) for each connected redstone device on bundled output 1
local alarmLights = 1
local testRed = 2
local testThree = 3
local BtoA = 4
local AtoB = 5
local six = 7
local seven = 8
local eight = 9

--Define Inputs(1-16) (work in progress)
--local inputOne

--Define BUTTONS as nested tables
--xOne, yOne, xTwo, yTwo, control, state, label
local buttons = {
	{2, 2, 9, 4, alarmLights, false, "Lights"},
	{11, 2, 18, 4, testRed, false, "Charge"},
	{2, 6, 9, 8, AtoB, false, "A to B"},
	{11, 6, 18, 8, BtoA, false, "B to A"},
	{2, 10, 9, 12, six, false, "OUT 5"},
	{11, 10, 18, 12, seven, false, "OUT 6"},
	{2, 14, 9, 16, eight, false, "OUT 7"},
	{11, 14, 18, 16, 9, false, "OUT 8"}
}
--Must manually update!!!
local numButtons = 8

--Define ENERGY Bar GRAPHS (horizontal) as nested tables
--xPosTop, yPosTop, width, height(down), input)
local graphs = {
	{28, 4, 20, 2, capA, current = 0, maximum = 0, "Capcitor A"},
	{28, 10, 20, 2, capB, current = 0, maximum = 0, "Capcitor B"}
}

--Must manually update!!!
local numGraphs = 2

--Define LABELS as nested tables
--xPos, yPos, text, color, graph number (to link a percentage)
local labels = {
	{28, 2, "Capacitor A", colors.purple, 1},
	{28, 8, "Capacitor B", colors.purple, 2}
}
--Must manually update!!!
local numLabels = 2

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
monitor.setTextScale(0.5)



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

function graphCalc(n)
	graphs[n][6] = graphs[n][5].getEnergyStored()
	graphs[n][7] = graphs[n][5].getMaxEnergyStored()
end

function graphInit(n)
	graphCalc(n)
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

function drawGraph(n)
	local graph = graphs[n]
	--local width = graph[3]
	local currentValue = graph[6]
	local currentMax = graph[7]
	local threshold = (currentValue / currentMax) * graph[3]
	--strLength = #graphs[n][8]
	--local strStart = (graph[3] / 2) - (strLength / 2)
	for i = graph[1], graph[3] + graph[1] do
		for j = graph[2], graph[4] + graph[2] do
			if i < (threshold + graph[1] + 1) then
				if threshold < (graph[3] / 3) then
					if threshold < (graph[3] / 10) then
						monitor.setBackgroundColor(colors.red)
					else
						monitor.setBackgroundColor(colors.yellow)
					end
				else
					monitor.setBackgroundColor(colors.blue)
				end
			else
				monitor.setBackgroundColor(colors.lightGray)
			end
			monitor.setCursorPos(i, j)
			print(" ")
		end
	end
	monitor.setBackgroundColor(colors.black)
end

function drawLabel(n)
	label = labels[n]
	monitor.setCursorPos(label[1], label[2])
	monitor.setTextColor(label[4])
	print(label[3])
	if not (label[5] == nil) then
		monitor.setCursorPos(label[1] + #label[3], label[2])
		print(" " .. (graphs[label[5]][6] / graphs[label[5]][7]) * 100 .. "%")
	end
	monitor.setTextColor(colors.white)
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

for i = 1, numGraphs do
	graphInit(i)
end

updateOutput()
	
monitor.clear()

--local maxFill = cap.getMaxEnergyStored()
--local stored = cap.getEnergyStored()
--local timeout = os.startTimer(1)

while true do

	--monitor.setCursorPos(20, 2)
	--print(maxFill)
	--monitor.setCursorPos(20, 3)
    --print(stored)
	--formatted = string.format(
	--	"%.2f %%",
	--	stored / maxFill * 100
	--)
	--monitor.setCursorPos(20, 4)
	--print(formatted) 

	for i = 1, numButtons do
		drawButton(i)
	end
	
	for i = 1, numGraphs do
		drawGraph(i)
	end
	
	for i = 1, numLabels do
		drawLabel(i)
	end
	
	--event, side, xPos, yPos = os.pullEvent("monitor_touch")
	event = {os.pullEvent()}
	if event[1] == "monitor_touch" then
    --handle monitor touches
		for j = 1, numButtons do
			doButton(j, event[3], event[4])
		end
		timeout = os.startTimer(2)
	elseif event[1] == "timer" and event[2] == timeout then
		timeout = os.startTimer(2)
	end
	
	for i = 1, numGraphs do
		graphCalc(i)
	end
	
	--maxFill = cap.getMaxEnergyStored()
	--stored = cap.getEnergyStored()
	
	monitor.clear()
	saveAll()
end
