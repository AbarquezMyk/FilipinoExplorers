-- ServerScriptService/CampfireQuestServer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Paths
local campFolder = Workspace:WaitForChild("Games"):WaitForChild("Campfire Tasks")
local npcPrompt = campFolder:WaitForChild("Ria"):WaitForChild("ProximityPart"):WaitForChild("ProximityPrompt")

local campfire = campFolder:WaitForChild("Campfire")
local campfireMesh = campfire:WaitForChild("CampfireMeshPart")
local campfirePrompt = campfireMesh:WaitForChild("ProximityPrompt")

-- Fire + PointLight
local fireObj = campfireMesh:FindFirstChild("Fire")
local lightObj = campfireMesh:FindFirstChild("PointLight")

-- RemoteEvent
local questEvent = ReplicatedStorage:FindFirstChild("CampfireQuestEvent")
if not questEvent then
	questEvent = Instance.new("RemoteEvent")
	questEvent.Name = "CampfireQuestEvent"
	questEvent.Parent = ReplicatedStorage
end

-- Turn off fire at start
if fireObj then fireObj.Enabled = false end
if lightObj then lightObj.Enabled = false end

-- Dialogues
local dialogues = {
	[1] = {
		"Ria: Maligayang pagdating sa Kampo 2.",
		"Ria: Kumuha ka ng kahoy para sa apoy."
	},
	[2] = {
		"Ria: Magaling! Nakuha mo ang kahoy.",
		"Ria: Dalhin mo ito at gamitin sa campfire."
	},
	[3] = {
		"Ria: Maganda ang apoy!",
		"Ria: Ngayon, magluto ka ng hotdog sa campfire."
	},
	[4] = {
		"Ria: Magaling! Naluto mo ang hotdog.",
		"Ria: Maaari ka nang magpahinga."
	}
}

-- Progress
local progress = {}

local function setProgress(player, step)
	progress[player.UserId] = step
	questEvent:FireClient(player, "Dialogue", dialogues[step])
end

Players.PlayerAdded:Connect(function(player)
	progress[player.UserId] = 0
end)

Players.PlayerRemoving:Connect(function(player)
	progress[player.UserId] = nil
end)

-- NPC start
npcPrompt.Triggered:Connect(function(player)
	local step = progress[player.UserId] or 0
	if step == 0 then
		setProgress(player, 1)
	else
		questEvent:FireClient(player, "Dialogue", dialogues[step])
	end
end)

-- Wood pickup: single part version
local woodPart = campFolder:WaitForChild("Woods") -- this is a Part
local woodTool = ReplicatedStorage:WaitForChild("WoodTool")

local debounce = false
woodPart.Touched:Connect(function(hit)
	if debounce then return end
	debounce = true

	local plr = Players:GetPlayerFromCharacter(hit.Parent)
	if plr then
		local step = progress[plr.UserId] or 0
		if step == 1 then
			if not plr.Backpack:FindFirstChild("WoodTool") 
				and not plr.Character:FindFirstChild("WoodTool") then
				local toolClone = woodTool:Clone()
				toolClone.Parent = plr.Backpack
				setProgress(plr, 2)
			end
		end
	end

	task.wait(1)
	debounce = false
end)

-- Campfire prompt logic
local hotdogTool = ReplicatedStorage:WaitForChild("HotdogTool")

campfirePrompt.Triggered:Connect(function(player)
	local step = progress[player.UserId] or 0

	if step == 2 then
		-- Check if player has wood
		local hasWood = player.Backpack:FindFirstChild("WoodTool") or player.Character:FindFirstChild("WoodTool")
		if hasWood then
			hasWood:Destroy() -- remove wood when used
			if fireObj then fireObj.Enabled = true end
			if lightObj then lightObj.Enabled = true end
			setProgress(player, 3)

			-- Give HotdogTool after lighting fire
			if not player.Backpack:FindFirstChild("HotdogTool") 
				and not player.Character:FindFirstChild("HotdogTool") then
				local hotdogClone = hotdogTool:Clone()
				hotdogClone.Parent = player.Backpack
			end
		else
			questEvent:FireClient(player, "Dialogue", {"Ria: Kailangan mo ng kahoy bago mo magamit ang apoy."})
		end

	elseif step == 3 then
		-- Cook hotdog (fire stays on)
		local hasHotdog = player.Backpack:FindFirstChild("HotdogTool") or player.Character:FindFirstChild("HotdogTool")
		if hasHotdog then
			hasHotdog:Destroy() -- remove raw hotdog
			-- You could replace with a "CookedHotdogTool" if you want
			setProgress(player, 4)
		else
			questEvent:FireClient(player, "Dialogue", {"Ria: Kailangan mo ng hotdog para lutuin."})
		end

	else
		questEvent:FireClient(player, "Dialogue", dialogues[step])
	end
end)
