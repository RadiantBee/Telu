local Button = require("button")

local userChoice = -1 -- 0 for HIGHER, 1 for LOWER
local currentNumber
local counter = -1
local backCount = -1
local randomNumber = -1
local winsInARow = 0

local sound = {
	buttonClick = love.audio.newSource("buttonClick.wav", "static"),
	highlightCount = love.audio.newSource("highlight.wav", "static"),
	goThroughRed = love.audio.newSource("red.wav", "static"),
	goThroughGreen = love.audio.newSource("green.wav", "static"),
	win = love.audio.newSource("win.wav", "static"),
	loose = love.audio.newSource("loose.wav", "static"),
	play = function(self, sound)
		if self[sound]:isPlaying() then
			self[sound]:stop()
		end
		self[sound]:play()
	end,
}

local highlightTimer = {
	current = 0,
	max = 0.05,
	isTimerDone = true,
}

local randomShowTimer = {
	current = 0,
	max = 0.07,
	isTimerDone = true,
}
local ui = {
	amountOfBoxes = 100,
	boxes = {},
	winButton = Button(winsInARow, nil, nil, 760, 170, 100, 20),
	buttonHigher = Button("HIGHER", nil, nil, 700, 110, 100, 20),
	buttonLower = Button("LOWER", nil, nil, 820, 110, 100, 20),
	buttonResult = Button("AGAIN?", nil, nil, 760, 140, 100, 20),
	highlight = function(self, number, colorBox, colorText, mode)
		self.boxes[number].colorIdle = colorBox or { 1, 1, 1 }
		self.boxes[number].colorTextIdle = colorText or { 0, 0, 0 }
		self.boxes[number].modeIdle = mode or "fill"
	end,
	resetBoxes = function(self)
		for i = 1, self.amountOfBoxes, 1 do
			self.boxes[i].text = i
			self.boxes[i].colorIdle = { 1, 1, 1 }
			self.boxes[i].colorTextIdle = { 1, 1, 1 }
			self.boxes[i].modeIdle = "line"
		end
	end,
}

local mouseX, mouseY = 0, 0

function love.load()
	math.randomseed(os.time())
	currentNumber = math.random(10 + 4 * (winsInARow % 10), 90 - 4 * (winsInARow % 10))
	for i = 1, ui.amountOfBoxes, 1 do
		ui.boxes[i] = Button(i, nil, nil, 55 * ((i - 1) % 10 + 1), 55 * (math.floor((i - 1) / 10) + 1), 50, 50)
	end

	for key, value in pairs(sound) do
		if key ~= "play" then
			value:setVolume(0.5)
		end
	end
end

function love.mousepressed()
	if userChoice == -1 then
		if ui.buttonHigher:checkHighlighted(mouseX, mouseY) then
			userChoice = 0
			sound:play("buttonClick")
		elseif ui.buttonLower:checkHighlighted(mouseX, mouseY) then
			userChoice = 1
			sound:play("buttonClick")
		end
	elseif userChoice == -4 and ui.buttonResult:checkHighlighted(mouseX, mouseY) then
		sound:play("buttonClick")
		userChoice = -1
		currentNumber = math.random(10 + 4 * (winsInARow % 10), 90 - 4 * (winsInARow % 10))
		ui:resetBoxes()
	end
end

function love.update(dt)
	mouseX, mouseY = love.mouse.getPosition()

	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	if userChoice == -1 then
		ui:highlight(currentNumber)
	elseif userChoice == 0 or userChoice == 1 then
		if userChoice == 0 then
			if counter == -1 then
				counter = currentNumber + 1
				backCount = currentNumber - 1
				highlightTimer.isTimerDone = false
			end
			if counter ~= 100 or backCount ~= 1 then
				if highlightTimer.current > highlightTimer.max then
					highlightTimer.current = 0
					sound:play("highlightCount")
					ui:highlight(counter, { 0.1, 0.5, 0.1 }, { 1, 1, 1 }, "line")
					ui:highlight(backCount, { 0.7, 0.1, 0.1 }, { 1, 1, 1 }, "line")
					counter = counter ~= 100 and counter + 1 or 100
					backCount = backCount ~= 1 and backCount - 1 or 1
				end
			else
				if not highlightTimer.isTimerDone then
					ui:highlight(counter, { 0.1, 0.5, 0.1 }, { 1, 1, 1 }, "line")
					ui:highlight(backCount, { 0.7, 0.1, 0.1 }, { 1, 1, 1 }, "line")
					highlightTimer.isTimerDone = true
					highlightTimer.current = 0
					randomShowTimer.isTimerDone = false
					userChoice = -2
				end
			end
		elseif userChoice == 1 then
			if counter == -1 then
				counter = currentNumber - 1
				backCount = currentNumber + 1
				highlightTimer.isTimerDone = false
			end
			if counter ~= 1 or backCount ~= 100 then
				if highlightTimer.current > highlightTimer.max then
					highlightTimer.current = 0
					sound:play("highlightCount")
					ui:highlight(counter, { 0.1, 0.5, 0.1 }, { 1, 1, 1 }, "line")
					ui:highlight(backCount, { 0.7, 0.1, 0.1 }, { 1, 1, 1 }, "line")
					counter = counter ~= 1 and counter - 1 or 1
					backCount = backCount ~= 100 and backCount + 1 or 100
				end
			else
				if not highlightTimer.isTimerDone then
					ui:highlight(counter, { 0.1, 0.5, 0.1 }, { 1, 1, 1 }, "line")
					ui:highlight(backCount, { 0.7, 0.1, 0.1 }, { 1, 1, 1 }, "line")
					highlightTimer.isTimerDone = true
					highlightTimer.current = 0
					randomShowTimer.isTimerDone = false
					userChoice = -2
				end
			end
		end
	elseif userChoice == -2 then
		counter = 1
		userChoice = -3
		randomNumber = math.random(1, 100)
	elseif userChoice == -3 then
		if counter < randomNumber then
			if randomShowTimer.current > randomShowTimer.max then
				randomShowTimer.current = 0
				if counter ~= currentNumber then
					if ui.boxes[counter].colorIdle[2] == 0.5 then
						ui:highlight(counter, { 0.1, 0.5, 0.1 }, { 1, 1, 1 }, "fill")
						sound:play("goThroughGreen")
					else
						ui:highlight(counter, { 0.7, 0.1, 0.1 }, { 1, 1, 1 }, "fill")
						sound:play("goThroughRed")
					end
				end
				counter = counter + 1
			end
		else
			randomShowTimer.isTimerDone = true
			randomShowTimer.current = 0
			if ui.boxes[randomNumber].colorIdle[2] == 0.5 or randomNumber == currentNumber then
				winsInARow = winsInARow + 1
				sound:play("win")
			else
				sound:play("loose")
				winsInARow = 0
			end
			ui:highlight(randomNumber, { 0.1, 0.1, 0.7 }, { 1, 1, 1 }, "fill")
			ui.winButton.text = winsInARow
			userChoice = -4
			counter = -1
			backCount = -1
			highlightTimer.max = 0.05 - 0.001 * winsInARow
			randomShowTimer.max = 0.07 - 0.001 * winsInARow
		end
	end

	if not highlightTimer.isTimerDone then
		highlightTimer.current = highlightTimer.current + dt
	end
	if not randomShowTimer.isTimerDone then
		randomShowTimer.current = randomShowTimer.current + dt
	end
end

function love.draw()
	for i = 1, ui.amountOfBoxes, 1 do
		ui.boxes[i]:draw(nil, nil, 0, 0, 18, 18)
	end
	if userChoice == -1 then
		ui.buttonHigher:draw(nil, nil, mouseX, mouseY, 27, 2)
		ui.buttonLower:draw(nil, nil, mouseX, mouseY, 27, 2)
	end
	if userChoice == -4 then
		ui.buttonResult:draw(nil, nil, mouseX, mouseY, 28, 2)
	end
	if winsInARow > 0 then
		ui.winButton:draw(nil, nil, 0, 0, 2, 2)
	end
end
