-- ServerScriptService/LetterDeliveryQuest
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ShowQuestGui = ReplicatedStorage:WaitForChild("ShowQuestGui")

-- Paths to prompts
local lakbayPamana = workspace:WaitForChild("Games"):WaitForChild("Lakbay Pamana")
local carmelitaPrompt = lakbayPamana:WaitForChild("Carmelita"):WaitForChild("ProximityPart"):WaitForChild("ProximityPrompt")
local mariaPrompt = lakbayPamana:WaitForChild("Maria"):WaitForChild("ProximityPart"):WaitForChild("ProximityPrompt")

-- Sulat Tool
local sulatTool = ReplicatedStorage:WaitForChild("Sulat")

-- Give Sulat & marker
local function giveSulat(player)
	if player:FindFirstChild("HasSulat") then return end

	local marker = Instance.new("BoolValue")
	marker.Name = "HasSulat"
	marker.Parent = player

	local sulatClone = sulatTool:Clone()
	sulatClone.Parent = player.Backpack

	local starterClone = sulatTool:Clone()
	starterClone.Parent = player:WaitForChild("StarterGear")
end

-- Carmelita interaction
carmelitaPrompt.Triggered:Connect(function(player)
	-- First part of the dialogue
	local firstMsg = "Magandang araw " .. player.DisplayName ..
		", pwede ba ako humingi ng pabor?"

	-- Second part of the dialogue
	local secondMsg = "Pwede mo ba ihatid itong sulat sa kaibigan ko na si Maria?"

	-- Fire the first line immediately
	ShowQuestGui:FireClient(player, "CarmelitaGUI", firstMsg)

	-- Fire the second line after 5 seconds (replace = true)
	task.delay(5, function()
		ShowQuestGui:FireClient(player, "CarmelitaGUI", secondMsg, false, true)
	end)

	giveSulat(player)
end)

-- Maria interaction
mariaPrompt.Triggered:Connect(function(player)
	if player:FindFirstChild("HasSulat") then
		-- Remove Sulat from Backpack & StarterGear
		for _, tool in ipairs(player.Backpack:GetChildren()) do
			if tool.Name == "Sulat" then tool:Destroy() end
		end
		for _, tool in ipairs(player.StarterGear:GetChildren()) do
			if tool.Name == "Sulat" then tool:Destroy() end
		end

		player:FindFirstChild("HasSulat"):Destroy()

		local msg = "Salamat, " .. player.DisplayName .. "."
		ShowQuestGui:FireClient(player, "MariaGUI", msg)
	end
end)
