-- Workspace.FoodGiver (Script) — persistent Food unless consumed
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local TOOL_NAME = "Food"
local TEMPLATE = ServerStorage:WaitForChild(TOOL_NAME)
local REQUIRED_STEP = 3
local DEBOUNCE_TIME = 0.5

local lastTouched = {}
local lastDeathTime = {} -- userId -> tick()

-- Utility: safe print prefix
local function log(...)
	print("[FoodGiver]", ...)
end

-- Create or get the player's HasPersistentFood BoolValue
local function getOrCreateFlag(player)
	local flag = player:FindFirstChild("HasPersistentFood")
	if not flag then
		flag = Instance.new("BoolValue")
		flag.Name = "HasPersistentFood"
		flag.Value = false
		flag.Parent = player
	end
	return flag
end

-- Give a Food tool to player's Backpack and set up listeners
local function equipPersistentToolToPlayer(player)
	if not player or not player.Parent then return end
	local bp = player:FindFirstChild("Backpack")
	if not bp then
		log("No Backpack found when trying to give Food to", player.Name)
		return
	end

	-- Don't duplicate
	if bp:FindFirstChild(TOOL_NAME) or (player.Character and player.Character:FindFirstChild(TOOL_NAME)) then
		log("Tool already present for", player.Name)
		return
	end

	local clone = TEMPLATE:Clone()
	clone.CanBeDropped = false
	clone:SetAttribute("PersistentFood", true)
	clone.Parent = bp
	log("Gave Food to", player.Name)

	-- Only detect actual consumption
	if clone:IsA("Tool") then
		clone.Activated:Connect(function()
			local flag = getOrCreateFlag(player)
			if flag.Value then
				flag.Value = false
				log("Tool.Activated -> marked HasPersistentFood = false for", player.Name)
			end
			if clone.Parent then
				clone:Destroy()
				log("Tool.Activated -> destroyed Food for", player.Name)
			end
		end)
	end
end

-- Restore tool if the player should still have it
local function restoreIfNeeded(player)
	local flag = getOrCreateFlag(player)
	if not flag.Value then return end

	if (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(TOOL_NAME)) or
		(player.Character and player.Character:FindFirstChild(TOOL_NAME)) then
		log("restoreIfNeeded: player already has Food:", player.Name)
		return
	end

	log("restoreIfNeeded: restoring Food for", player.Name)
	equipPersistentToolToPlayer(player)
end

-- Setup listeners for a player
local function setupPlayer(player)
	local flag = getOrCreateFlag(player)
	lastDeathTime[player.UserId] = lastDeathTime[player.UserId] or 0

	-- Character handling
	player.CharacterAdded:Connect(function(char)
		local humanoid = char:WaitForChild("Humanoid", 5)
		if humanoid then
			humanoid.Died:Connect(function()
				lastDeathTime[player.UserId] = tick()
				log("Humanoid.Died recorded for", player.Name, "at", lastDeathTime[player.UserId])
				-- restore after Roblox moves tools
				task.delay(0.12, function()
					restoreIfNeeded(player)
				end)
			end)
		end

		task.delay(0.1, function()
			restoreIfNeeded(player)
		end)
	end)

	-- If flag becomes true, restore immediately
	flag.Changed:Connect(function(new)
		if new == true then
			restoreIfNeeded(player)
		end
	end)
end

-- Give Food and set persistent flag
local function giveFoodAndFlag(player)
	local flag = getOrCreateFlag(player)
	if flag.Value then
		restoreIfNeeded(player)
		return
	end
	flag.Value = true
	log("Set HasPersistentFood = true for", player.Name)
	equipPersistentToolToPlayer(player)
end

-- Setup already-connected players
for _, pl in ipairs(Players:GetPlayers()) do
	setupPlayer(pl)
end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	local flag = player:FindFirstChild("HasPersistentFood")
	if flag then flag:Destroy() end
	lastDeathTime[player.UserId] = nil
end)

-- Main Touched logic
script.Parent.Touched:Connect(function(hit)
	local char = hit.Parent
	if not char or not char:FindFirstChild("Humanoid") then return end
	local player = Players:GetPlayerFromCharacter(char)
	if not player then return end

	local now = tick()
	local uid = player.UserId
	if lastTouched[uid] and now - lastTouched[uid] < DEBOUNCE_TIME then return end
	lastTouched[uid] = now

	local step = player:FindFirstChild("TutorialStep")
	if not step then
		warn("[FoodGiver] No TutorialStep for", player.Name)
		return
	end

	log("Touched by", player.Name, "step=", step.Value, "BackpackHasFood=", player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(TOOL_NAME) and true or false)

	if step.Value == REQUIRED_STEP then
		if not (player.Backpack:FindFirstChild(TOOL_NAME) or (player.Character and player.Character:FindFirstChild(TOOL_NAME))) then
			giveFoodAndFlag(player)
		else
			log("Player already has Food during tutorial for", player.Name)
		end
		step.Value = REQUIRED_STEP + 1
		log("Advanced tutorial to", step.Value, "for", player.Name)
		return
	end

	if step.Value > REQUIRED_STEP then
		if not (player.Backpack:FindFirstChild(TOOL_NAME) or (player.Character and player.Character:FindFirstChild(TOOL_NAME))) then
			giveFoodAndFlag(player)
		else
			log("Resupply skipped; player already has Food:", player.Name)
		end
	end
end)
