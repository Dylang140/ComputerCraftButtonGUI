--Dylang140 
--January 29, 2022
--CC Tewaked GUI Prorgam
--Intended for CC Tweaked and Immersive Engineering for Minecraft 1.18
--Feel free to change or copy this code for other mods, versions, or projects

--======CONFIG SECTION======--

local speaker = peripheral.find("speaker")
local bundledConnection = "bottom"
local bundledInput = "left"
local monitor = peripheral.find("monitor")
local dataSave = "disk/savedData.txt"
local diskDrive = peripheral.wrap("left")
local capA, capB, capC, capD, capE = peripheral.find("capacitor_hv") 

local currentOne, currentTwo, currentThree, currentFour = peripheral.find("current_transformer")
local currents = {currentOne, currentTwo, currentThree, currentFour}
local currentValues = {}
local numCurrents = 8

local caps = {capA, capB, capC, capD, capE}
local capNumbers = {3, 4, 5, 6, 7} --Number for the capacitors used (capacitor_hv_4, ex)
local capMaxes = {0,2,3,4,5}
local capValues = {}
local numCaps = 5

local bgColor = colors.black
--local capA = caps[1]
--local capB = caps[2]

--How often the screen refreshes (in seconds) (also affects save frequency and custom logic, like alarms)

local refreshRate = 2

--==========================--

--========GUI BUILD SECTION=========--

--Define output (0 - 15) for each connected redstone device on bundled output 1
local outOne = 1
local outTwo = 2
local outThree = 3
local outFour = 4
local outFive = 5
local outSix = 6
local outSeven = 7
local outEight = 8
local outNine = 9
local outTen = 10
local outEleven = 11
local outTwelve = 12

--Define Inputs(1-16) (work in progress)
--local inputOne

--Some variables for helping build the gui
--These are not necessary, but can help add items without doing the math for the coordinates
local width, height = monitor.getSize()
local buttonRowOne = height - 20
local buttonRowTwo = height - 13
local buttonRowThree = height - 6
local colWidth = (width - 15) / 6
local col1 = 2
local col2 = col1 + colWidth + 3
local col3 = col2 + colWidth + 3
local col4 = col3 + colWidth + 3
local col5 = col4 + colWidth + 3
local col6 = col5 + colWidth + 3

local rebootButton = {width - 17, 4, width - 2, 8}


--Define BUTTONS as nested tables
--xOne, yOne, xTwo, yTwo, control, state, label
local buttons = {
	--Col 1
	{col1, buttonRowOne, 	col1 + colWidth, 	buttonRowOne + 5, outOne, 	false,	"Generator A"  },
	{col1, buttonRowTwo, 	col1 + colWidth, 	buttonRowTwo + 5, outTwo, 	false,	"Generator B"},
	{col1, buttonRowThree, 	col1 + colWidth, 	buttonRowThree + 5, outThree, false,"Generator C"},
	--Col 2
	--Col 3
	{col3, buttonRowOne, 	col3 + colWidth,	buttonRowOne + 5, outFour, false,	"A Enable"},
	{col3, buttonRowTwo, 	col3 + colWidth,	buttonRowTwo + 5, outFive, 	false, 	"B Enable"},
	{col3, buttonRowThree, 	col3 + colWidth, 	buttonRowThree + 5, outSix, false, 	"C Enable"},
	--Col 4
	{col4, buttonRowOne, 	col4 + colWidth, 	buttonRowOne + 5, outSeven, false, 	"D Enable"},
	{col4, buttonRowTwo, 	col4 + colWidth, 	buttonRowTwo + 5, outEight, false, 	"E Enable"},
	--Col 5
	{col5, buttonRowOne, 	col5 + colWidth, 	buttonRowOne + 5, outNine, 	false, 		"Fake Load A"},
	{col5, buttonRowTwo, 	col5 + colWidth, 	buttonRowTwo + 5, outTen, 	false, 		"Fake Load B"},
	{col5, buttonRowThree, 	col5 + colWidth, 	buttonRowThree + 5, outEleven,	false, 	"Fake Load C"  },
	--Col 6
	{col6, buttonRowOne, 	col6 + colWidth,	buttonRowOne + 5, outTwelve, false, 	"Fake Load D"}
	--Other
}
--Must manually update!!!
local numButtons = 12

--Define ENERGY Bar GRAPHS (horizontal) as nested tables
--xPosTop, yPosTop, width, height(down), input), vertical (1) or horizontal (0)
local graphs = {
	{2, 4, 20, 2, {1}, "Capcitor A", 0},
	{2, 9, 20, 2, {2}, "Capcitor B", 0},
	{2, 14, 20, 2, {3}, "Capcitor C", 0},
	{2, 19, 20, 2, {4}, "Capcitor D", 0},
	{2, 24, 20, 2, {5}, "Capcitor E", 0},
	{55, 14, 30, 3, {1,2,3,4,5}, "Total Stored", 0}
}

--Define LABELS as nested tables
--xPos, yPos, text, color, graph number (to link a percentage)
local labels = {
	{2, 3, "Capacitor A", colors.purple, {1}},
	{2, 8, "Capacitor B", colors.purple, {2}},
	{2, 13, "Capacitor C", colors.purple, {3}},
	{2, 18, "Capacitor D", colors.purple, {4}},
	{2, 23, "Capacitor E", colors.purple, {5}},
	{61, 8, "Total Power Stored: Loading...", colors.cyan, {}},
	{70, 9, "", colors.cyan, {1,2,3,4,5}},
	{107, 13, "Load A", colors.purple, {}},
	{107, 17, "Load B", colors.purple, {}},
	{107, 23, "Load C", colors.purple, {}},
	{107, 27, "Load D", colors.purple, {}}
}

--Define ALARMS as nested tables
--graph number, threshold percentage, over or under (1 or 0)
local alarms = {
	{1, 25, 0},
	{2, 25, 0},
	{3, 25, 0},
	{4, 25, 0},
	{5, 25, 0}
}
--Must manually update!!!
local numAlarms = 5

--Define OUTPUT INDICATORS as nested tables (Buttons, but that cannot be clicked) - True if any of specified outputs true, else false
--x, y, width, height, true color, false color, {list of states from 'Outputs'}, label
--Color Codes: https://tweaked.cc/module/colors.html
local outputIndicators = {
	{30, 4, 15, 3, 2048, 256, {2},  "Generator #1"},
	{30, 10, 15, 3, 2048, 256, {3}, "Generator #2"},
	{30, 16, 15, 3, 2048, 256, {4}, "Generator #3"}
}

--Define OUTPUT INDICATOR LINES as nested tables (Buttons, but that cannot be clicked) - True if any of specified outputs true, else false
--Lines draw left to right, then top to bottom if the y coordinates are different
--x start, y start, x end, y end, true color, false color, {list of states from 'Outputs'}
--Color Codes: https://tweaked.cc/module/colors.html
local outputLineIndicators = {

}

--Define CURRENT INDICATOR LINES as nested tables (Buttons, but that cannot be clicked) - True if any of specified outputs true, else false
--Lines draw left to right, then top to bottom if the y coordinates are different
--x start, y start, x end, y end, true color, false color, {list of current transformers}, currentVal (use 0)
--Remeber: The TOP LEFT corner is (0,0) so going down means HIGHER Y values
--Color Codes: https://tweaked.cc/module/colors.html
local currentLineIndicators = {
	{46, 6, 50, 12, 1024, 256,  {2}},
	{46, 11, 50, 12, 1024, 256, {3}},
	{46, 17, 50, 12, 1024, 256, {4}},
	{50, 11, 70, 13, 1024, 256, {2, 3, 4}},
	{70, 18, 70, 19, 1024, 256, {1}},
	{70, 20, 100, 20, 1024, 256, {1}},
	{100, 21, 100, 23, 1024, 256, {7, 8}},
	{101, 23, 105, 23, 1024, 256, {7}},
	{100, 24, 100, 27, 1024, 256, {8}},
	{100, 27, 105, 27, 1024, 256, {8}},
	{100, 19, 100, 17, 1024, 256, {5, 6}},
	{101, 17, 105, 17, 1024, 256, {6}},
	{100, 16, 100, 13, 1024, 256, {5}},
	{100, 13, 105, 13, 1024, 256, {5}}
}

--===============================================
--============END CONFIG SECTION=================
--===============================================

--Array that initializes all redstone outputs as false and stores states while the program runs
-- 1 - 16 represent redstone outputs, thelast 4 are extra states for other logic that should be saved
--This table is overwritten each time the program starts if there is a file with saved data avaliable
local outputs = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}

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
local alarmPhase = 0
local activeAlarms = 0

--Functions

function saveAll()
	f = io.open(dataSave, "w+")
	for i = 1, 20 do
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

local currents = peripheral.find("current_transformer")
local currentValues = {}

function updateCurrentValues()
	local tempString
	for i = 0, numCurrents do
		tempString = "current_transformer_"
		tempString = tempString .. (i)
		currentValues[i + 1] = peripheral.call(tempString, "getAveragePower")
	end
end

function updateCapValues()
	local tempString
	for i, v in ipairs(capNumbers) do
		tempString = "capacitor_hv_"
		tempString = tempString .. (v)
		capValues[i] = peripheral.call(tempString, "getEnergyStored")
		capMaxes[i] = peripheral.call(tempString, "getMaxEnergyStored")
	end
end

function getSumCapVals()
	local t = 0
	for i, v in ipairs(capValues) do t = t + v end
	return t
end

function alarmTrigger()
	if alarmPhase == 0 then
		speaker.playNote("bit", 3.0, 6)
		speaker.playNote("flute", 3.0, 9)
	elseif alarmPhase == 1 then
		speaker.playNote("bit", 3.0, 8)
		speaker.playNote("flute", 3.0, 10) 
		alarmPhase = -1
	end
	alarmPhase = alarmPhase + 1
end

function doAlarm(n)
	alarmTemp = alarms[n]
	currentVal = capValues[alarmTemp[1]] / capMaxes[alarmTemp[1]] * 100
	if alarmTemp[3] == 0 then
		if currentVal < alarmTemp[2] then
			activeAlarms = activeAlarms + 1
		end
	elseif alarmTemp[3] == 1 then
		if currentVal > alarmTemp[2] then
			activeAlarms = activeAlarms + 1
		end
	end
end

function printAndClearAlarms()
	xPos, yPos = monitor.getSize()
	monitor.setCursorPos(xPos - 12, 2)
	if activeAlarms > 0 then
		if alarmPhase == 0 then
			monitor.setTextColor(colors.red)
		else
			monitor.setTextColor(colors.white)
		end
		alarmTrigger()
	end
	print(activeAlarms .. " Alarm(s)!")
	monitor.setTextColor(colors.white)
	activeAlarms = 0
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

function drawGraphs()
	local tempCurrent
	local tempMax
	local threshold
	for i, v in ipairs(graphs) do
		tempCurrent = 0
		tempMax = 0
		for j, b in ipairs(v[5]) do
			tempCurrent = tempCurrent + capValues[b]
			tempMax = tempMax + capMaxes[b]
		end
		threshold = (tempCurrent / tempMax) * v[3]
		for i = v[1], v[3] + v[1] do
		for j = v[2], v[4] + v[2] do
			if i < (threshold + v[1] + 1) then
				if threshold < (v[3] / 4) then
					if threshold < (v[3] / 10) then
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
end

function drawLabel(n)
	label = labels[n]
	monitor.setCursorPos(label[1], label[2])
	monitor.setTextColor(label[4])
	print(label[3])
	if not (label[5] == nil) then
		monitor.setCursorPos(label[1] + #label[3], label[2])
		print(" " .. (capValues[label[5]] / capMaxes[label[5]]) * 100 .. "%")
	end
	monitor.setTextColor(colors.white)
end

function drawLabels()
	local tempMax, tempVal
	for i, v in ipairs(labels) do
		tempMax = 0
		tempVal = 0
		for j, k in ipairs(v[5]) do
			tempMax = tempMax + capMaxes[k]
			tempVal = tempVal + capValues[k]
		end
		monitor.setCursorPos(v[1], v[2])
		monitor.setTextColor(v[4])
		print(v[3])
		if not (tempMax == 0) then
			monitor.setCursorPos(v[1] + #v[3], v[2])
			print(" " .. string.format("%.2f", ((tempVal / tempMax) * 100)) .. "%")
		end
		monitor.setTextColor(colors.white)
	end
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
	if (xPos >= rebootButton[1] and xPos <= rebootButton[3] and yPos >= rebootButton[2] and yPos <= rebootButton[4]) then
		monitor.clear()
		os.reboot()
	end
	drawButton(n)
end

function buttonInit(n)
	local tab = buttons[n]
	if outputs[tab[5]] == true then
		tab[6] = true
	else
		tab[6] = false
	end
end

function drawOutputIndicators()
	local tempBool
	for i, v in ipairs(outputIndicators) do
		tempBool = false
		for j, b in ipairs(v[7]) do
			if outputs[b] == true then
				tempBool = true
			end
		end
		
		if tempBool then
			monitor.setBackgroundColor(v[5])
		else
			monitor.setBackgroundColor(v[6])
		end
		
		paintutils.drawFilledBox(v[1], v[2], v[1] + v[3], v[2] + v[4])
		
		term.setCursorPos(v[1] + (v[3]/2) - (string.len(v[8]) / 2), v[2] + (v[4] / 2))
		print(v[8])
	end
	
	monitor.setBackgroundColor(bgColor)
end

function drawOutputLineIndicators()
	local tempBool
	for i, v in ipairs(outputLineIndicators) do
		tempBool = false
		for j, b in ipairs(v[7]) do
			if outputs[b] == true then
				tempBool = true
			end
		end
		
		if tempBool then
			monitor.setBackgroundColor(v[5])
		else
			monitor.setBackgroundColor(v[6])
		end
		
		paintutils.drawLine(v[1], v[2], v[3], v[2])
		paintutils.drawLine(v[3], v[2], v[3], v[4])
	end
	
	monitor.setBackgroundColor(bgColor)
end

function drawCurrentLineIndicators()
	local tempVal
	for i, v in ipairs(currentLineIndicators) do
		tempVal = 0
		for j, b in ipairs(v[7]) do
			tempVal = tempVal + currentValues[b]
		end
		
		if tempVal > 1 then
			monitor.setBackgroundColor(v[5])
		else
			monitor.setBackgroundColor(v[6])
		end
		
		paintutils.drawLine(v[1], v[2], v[3], v[2])
		paintutils.drawLine(v[3], v[2], v[3], v[4])
	end
	
	monitor.setBackgroundColor(bgColor)
end

function formatNum(n)
	local str = ""
	local result = ""
	str = str .. n
	for i = 1, string.len(str) do
		result = result .. string.sub(str, i, i)
		if ((string.len(str) - i) % 3 == 0) and not (i == string.len(str)) then
			result = result .. ","
		end
	end
	return result
end

--Main Section for Creating GUI
readData()

for i = 1, numButtons do
	buttonInit(i)
end

monitor.clear()
updateOutput()
updateCurrentValues()
updateCapValues()


monitor.setCursorPos(width / 2, height / 2)
print("Welcome")
monitor.setCursorPos(width / 2 - 6, height / 2 + 1)
print("Starting Program...")
os.sleep(1)
monitor.clear()

timeout = os.startTimer(refreshRate)

while true do
	
	for i = 1, numButtons do
		drawButton(i)
	end
	
	drawGraphs()
	
	for i = 1, numAlarms do
		doAlarm(i)
	end
	
	drawLabels()
	drawOutputIndicators()
	drawOutputLineIndicators()
	drawCurrentLineIndicators()
	
	printAndClearAlarms()
	
	paintutils.drawFilledBox(rebootButton[1], rebootButton[2], rebootButton[3], rebootButton[4], colors.brown)
	monitor.setCursorPos((rebootButton[3] - rebootButton[1]) / 2 + rebootButton[1] - 2, (rebootButton[4] - rebootButton[2] / 2))
	print("Reboot")
	monitor.setBackgroundColor(bgColor)
	
	--event, side, xPos, yPos = os.pullEvent("monitor_touch")
	event = {os.pullEvent()}
	if event[1] == "monitor_touch" then
    --handle monitor touches
		for j = 1, numButtons do
			doButton(j, event[3], event[4])
		end
		timeout = os.startTimer(refreshRate)
	elseif event[1] == "timer" and event[2] == timeout then
		timeout = os.startTimer(refreshRate)
	end
	
	updateCurrentValues()
	updateCapValues()
	
	--============== Add Custom Logic Here =================
	--Note: Getting data from a peripheral (like getting accumulator capacity) in the loop
	--might cause the screen to blink as it refreshes. Putting it here SHOULD prevent that,
	--since it is before the screen clears
	
	labels[6][3] = "Total Power Stored: " .. formatNum(getSumCapVals()) .. " IF"
	
	monitor.clear()
	saveAll()
end
