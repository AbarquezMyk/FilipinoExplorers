-- Igib ng Tubig Quest Script (Final Updated with 5s dialogue + tool removal)
-- Place this in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- World references (adjust if names differ)
local LolaPrompt = workspace.Games["Lakbay Pamana"].Lola.ProximityPart.ProximityPrompt
local BalonPrompt = workspace.Games["Lakbay Pamana"].Balon.ProximityPart.ProximityPrompt

-- Tools
local TimbaTool = ReplicatedStorage:WaitForChild("TimbaTool") -- empty bucket tool

-- Quest state
local questStatus = {} -- [userId] = "Started" | "Completed"

-- Lola's intro dialogue lines
local lolaDialogues = {
	"Magandang araw! Pwede mo ba ako tulongan?",
	"Pwede mo ba ako ipag-igib ng tubig? Wala akong kasama sa bahay ngayon.",
	"Nahihirapan ako mag-igib ng tubig kasi matanda na ako."
}

-- Helper: show dialogue in LolaGUI for 5 seconds
local function showLolaDialogue(player, message)
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end

	local gui = playerGui:FindFirstChild("LolaGUI")
	if not gui then return end

	local frame = gui:FindFirstChild("Frame")
	if not frame then return end

	local label = frame:FindFirstChild("TextLabel")
	if not label then return end

	frame.Visible = true
	label.Text = message

	-- Keep visible for 5 seconds, then hide
	task.delay(5, function()
		if frame and frame.Parent then
			frame.Visible = false
		end
	end)
end

-- Helper: play dialogue sequence automatically
local function playDialogueSequence(player, lines, delayTime, onFinish)
	coroutine.wrap(function()
		for _, line in ipairs(lines) do
			showLolaDialogue(player, line)
			task.wait(delayTime or 5) -- wait 5s before next line
		end
		if onFinish then
			onFinish()
		end
	end)()
end

-- Helper: give a tool to the player (only if they don’t already have it)
local function giveTool(player, tool)
	if not tool then return end
	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character

	if (backpack and backpack:FindFirstChild(tool.Name)) or (character and character:FindFirstChild(tool.Name)) then
		return -- already has it
	end

	local clone = tool:Clone()
	clone.Parent = backpack
end

-- Helper: remove any Timba tools (empty or filled)
local function removeTimba(player)
	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character

	if backpack then
		if backpack:FindFirstChild("TimbaTool") then
			backpack.TimbaTool:Destroy()
		end
		if backpack:FindFirstChild("Filled TimbaTool") then
			backpack["Filled TimbaTool"]:Destroy()
		end
	end

	if character then
		if character:FindFirstChild("TimbaTool") then
			character.TimbaTool:Destroy()
		end
		if character:FindFirstChild("Filled TimbaTool") then
			character["Filled TimbaTool"]:Destroy()
		end
	end
end

-- Lola interaction
LolaPrompt.Triggered:Connect(function(player)
	local status = questStatus[player.UserId]

	-- If quest not started yet, play intro dialogue
	if not status then
		playDialogueSequence(player, lolaDialogues, 5, function()
			questStatus[player.UserId] = "Started"
			showLolaDialogue(player, "Salamat, eto ang timba. Paki-igib mo ako ng tubig.")
			giveTool(player, TimbaTool)
			print(player.Name .. " started Igib ng Tubig.")
		end)
		return
	end

	-- If quest already started, check bucket
	if status == "Started" then
		local backpack = player:FindFirstChild("Backpack")
		local character = player.Character
		local hasFilled = (backpack and backpack:FindFirstChild("Filled TimbaTool")) or (character and character:FindFirstChild("Filled TimbaTool"))

		if hasFilled then
			questStatus[player.UserId] = "Completed"
			showLolaDialogue(player, "Salamat! Tinulongan mo ako.")
			removeTimba(player) -- remove bucket after quest complete
			print(player.Name .. " completed Igib ng Tubig.")
		else
			showLolaDialogue(player, "Wala ka pang tubig. Paki-igib mo muna.")
		end
	end
end)

-- Balon interaction
BalonPrompt.Triggered:Connect(function(player)
	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character

	local emptyInBackpack = backpack and backpack:FindFirstChild("TimbaTool")
	local emptyEquipped = character and character:FindFirstChild("TimbaTool")

	if emptyInBackpack or emptyEquipped then
		-- Remove empty bucket
		if emptyInBackpack then emptyInBackpack:Destroy() end
		if emptyEquipped then emptyEquipped:Destroy() end

		-- Create filled version
		local filled = TimbaTool:Clone()
		filled.Name = "Filled TimbaTool"
		filled.Parent = player.Backpack

		showLolaDialogue(player, "Napuno mo ang timba ng tubig!")
		print(player.Name .. " filled the bucket at the Balon.")
	else
		showLolaDialogue(player, "Kunin muna ang timba kay Lola bago mag-igib.")
	end
end)
