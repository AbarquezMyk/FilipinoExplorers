-- ServerScriptService/KampoQuestServer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Helper: create or get RemoteEvent
local function getOrCreateRemote(name)
	local r = ReplicatedStorage:FindFirstChild(name)
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = ReplicatedStorage
	end
	return r
end

local StartEvent = getOrCreateRemote("StartKampoQuest")
local FinishEvent = getOrCreateRemote("FinishKampoQuest")

-- Create per-player quest folder and value
Players.PlayerAdded:Connect(function(player)
	local quests = Instance.new("Folder")
	quests.Name = "Quests"
	quests.Parent = player

	local kampoQuest = Instance.new("BoolValue")
	kampoQuest.Name = "KampoQuestDone"
	kampoQuest.Value = false
	kampoQuest.Parent = quests
end)

-- When the client reports completion -> mark only that player's value true
FinishEvent.OnServerEvent:Connect(function(player)
	local quests = player:FindFirstChild("Quests")
	if not quests then return end
	local kampo = quests:FindFirstChild("KampoQuestDone")
	if kampo and not kampo.Value then
		-- (Optional) add server-side validation here later
		kampo.Value = true
		print(player.Name .. " finished Kampo quest (server)")
		-- put reward logic here (award points, give tool, badges, etc.)
	end
end)

-- OPTIONAL: How to start the quest when player interacts with an NPC or prompt.
-- Add a Part named "StartPromptPart" under: Workspace.Games["Ayusin ang Kampo"] (or change path to match your scene).
-- Put a ProximityPrompt into that part. This block will fire StartEvent only if the player hasn't finished.
local success, kampoFolder = pcall(function()
	return Workspace:WaitForChild("Games"):WaitForChild("Ayusin ang Kampo")
end)

if success and kampoFolder then
	local startPart = kampoFolder:FindFirstChild("StartPromptPart")
	if startPart then
		local prompt = startPart:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			prompt.Triggered:Connect(function(player)
				local quests = player:FindFirstChild("Quests")
				if quests and quests:FindFirstChild("KampoQuestDone") and not quests.KampoQuestDone.Value then
					StartEvent:FireClient(player)
				else
					-- player already did the quest: do nothing or optionally notify them
					-- Example: you can send a short message via another RemoteEvent if you want.
					-- StartEvent:FireClient(player, "alreadyDone") -- would require client handling
				end
			end)
		end
	end
end
