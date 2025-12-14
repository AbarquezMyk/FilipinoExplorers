local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RequestStartQuest = ReplicatedStorage:WaitForChild("RequestStartQuest")
local RegisterKick       = ReplicatedStorage:WaitForChild("RegisterKick")
local UpdateQuest        = ReplicatedStorage:WaitForChild("UpdateQuest")
local StartQuest         = ReplicatedStorage:WaitForChild("StartQuest")

local GOAL = 10
local playerKicks = {}
local playerActive = {}

-- Player asked to start quest (sent by client when they press Accept)
RequestStartQuest.OnServerEvent:Connect(function(player, questName)
	if questName ~= "sipaQuest" then return end
	if playerActive[player] then return end

	playerActive[player] = true
	playerKicks[player] = 0

	-- give SipaTool server-side (more reliable than client-clone)
	local sipaTool = ReplicatedStorage:FindFirstChild("SipaTool")
	if sipaTool then
		local clone = sipaTool:Clone()
		-- ensure LocalScripts inside will run for that player
		clone.Parent = player:WaitForChild("Backpack")
	end

	-- tell client quest started and the goal
	StartQuest:FireClient(player, "start", GOAL)
	UpdateQuest:FireClient(player, 0, GOAL)
end)

-- Each click from client
RegisterKick.OnServerEvent:Connect(function(player)
	if not playerActive[player] then return end
	playerKicks[player] = (playerKicks[player] or 0) + 1
	local kicks = playerKicks[player]

	-- send progress back to that player
	UpdateQuest:FireClient(player, kicks, GOAL)

	-- finished?
	if kicks >= GOAL then
		playerActive[player] = nil
		-- remove any SipaTool in backpack/character
		local bp = player:FindFirstChild("Backpack")
		if bp then
			local t = bp:FindFirstChild("SipaTool")
			if t then t:Destroy() end
		end
		local char = player.Character
		if char then
			local t = char:FindFirstChild("SipaTool")
			if t then t:Destroy() end
		end

		-- optional: send a completion/dialogue message
		StartQuest:FireClient(player, "complete", "Natapos mo ang sipa quest! Bumalik kay Kose.")
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	playerKicks[player] = nil
	playerActive[player] = nil
end)
