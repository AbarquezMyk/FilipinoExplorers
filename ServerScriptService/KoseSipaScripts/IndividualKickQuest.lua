-- ServerScriptService/IndividualKickQuest.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

-- RemoteEvents
local RegisterKick = ReplicatedStorage:WaitForChild("RegisterKick")
local UpdateQuest = ReplicatedStorage:WaitForChild("UpdateQuest")
local QuestFinished = ReplicatedStorage:WaitForChild("QuestFinished")

-- Quest settings
local goalKicks = 10
local playerKicks = {} -- store per-player progress
local TOOL_NAME = "SipaTool" -- tool in ServerStorage

-- Function to give and automatically equip the tool
local function giveAndEquipTool(player)
	-- Wait for character and humanoid to exist
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local backpack = player:WaitForChild("Backpack")

	-- Check if player already has the tool
	if backpack:FindFirstChild(TOOL_NAME) or character:FindFirstChild(TOOL_NAME) then
		return
	end

	-- Clone tool from ServerStorage
	local toolTemplate = ServerStorage:FindFirstChild(TOOL_NAME)
	if toolTemplate then
		local toolClone = toolTemplate:Clone()
		toolClone.Parent = backpack

		-- Delay a tiny bit to ensure Roblox registers the tool
		task.wait(0.1)
		humanoid:EquipTool(toolClone) -- automatically equips it
	end
end

-- When a player kicks
RegisterKick.OnServerEvent:Connect(function(player)
	local userId = player.UserId

	-- Initialize player's counter if not existing
	if not playerKicks[userId] then
		playerKicks[userId] = 0
	end

	-- Give and automatically equip the tool
	giveAndEquipTool(player)

	-- Increment player's kick count
	playerKicks[userId] += 1
	local kicks = playerKicks[userId]

	-- Update only this player's quest progress
	UpdateQuest:FireClient(player, kicks)

	-- Bounce the tool
	local character = player.Character
	if character then
		local tool = character:FindFirstChild(TOOL_NAME) or character:FindFirstChildOfClass("Tool")
		if tool then
			local handle = tool:FindFirstChild("Handle")
			if handle then
				handle.Anchored = false
				handle.CanCollide = true

				local bv = Instance.new("BodyVelocity")
				bv.Velocity = Vector3.new(0, 25, 0) -- bounce upward
				bv.MaxForce = Vector3.new(0, 10000, 0)
				bv.Parent = handle

				Debris:AddItem(bv, 0.2)
			end
		end
	end

	-- If quest completed
	if kicks >= goalKicks then
		QuestFinished:FireClient(player)

		-- Remove the tool from backpack and hand
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			local tool = backpack:FindFirstChild(TOOL_NAME)
			if tool then tool:Destroy() end
		end

		if character then
			local handTool = character:FindFirstChild(TOOL_NAME)
			if handTool then handTool:Destroy() end
		end
	end
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
	playerKicks[player.UserId] = nil
end)
