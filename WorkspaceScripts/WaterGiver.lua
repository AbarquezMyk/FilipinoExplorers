-- Workspace.WaterGiver (Script) — persistent Water unless consumed
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local TOOL_NAME = "Water"
local TEMPLATE = ServerStorage:WaitForChild(TOOL_NAME)
local REQUIRED_STEP = 4
local DEBOUNCE_TIME = 0.5

local lastTouched = {}

-- Utility: safe print prefix
local function log(...)
	print("[WaterGiver]", ...)
end

-- Create or get the player's HasPersistentWater BoolValue
local function getOrCreateFlag(player)
	local flag = player:FindFirstChild("HasPersistentWater")
	if not flag then
		flag = Instance.new("BoolValue")
		flag.Name = "HasPersistentWater"
		flag.Value = false
		flag.Parent = player
	end
	return flag
end

-- Give a Water tool to player's Backpack and set up listeners
local function equipPersistentToolToPlayer(player)
	if not player or not player.Parent then return end
	local bp = player:FindFirstChild("Backpack")
	if not bp then
		log("No Backpack found when trying to give Water to", player.Name)
		return
	end

	-- Don't duplicate
	if bp:FindFirstChild(TOOL_NAME) or (player.Character and player.Character:FindFirstChild(TOOL_NAME)) then
		log("Tool already present for", player.Name)
		return
	end

	local clone = TEMPLATE:Clone()
	clone.CanBeDropped = false
	clone:SetAttribute("PersistentWater", true)
	clone.Parent = bp
	log("Gave Water to", player.Name)

	-- Only detect actual consumption
	if clone:IsA("Tool") then
		clone.Activated:Connect(function()
			local flag = getOrCreateFlag(player)
			if flag.Value then
				flag.Value = false
				log("Tool.Activated -> marked HasPersistentWater = false for", player.Name)
			end
			if clone.Parent then
				clone:Destroy()
				log("Tool.Activated -> destroyed Water for", player.Name)
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
		log("restoreIfNeeded: player already has Water:", player.Name)
		return
	end

	log("restoreIfNeeded: restoring Water for", player.Name)
	equipPersistentToolToPlayer(player)
end

-- Setup listeners for a player
local function setupPlayer(player)
	local flag = getOrCreateFlag(player)

	-- Character handling
	player.CharacterAdded:Connect(function(char)
		local humanoid = char:WaitForChild("Humanoid", 5)
		if humanoid then
			humanoid.Died:Connect(function()
				log("Humanoid.Died recorded for", player.Name)
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

-- Give Water and set persistent flag
local function giveWaterAndFlag(player)
	local flag = getOrCreateFlag(player)
	if flag.Value then
		restoreIfNeeded(player)
		return
	end
	flag.Value = true
	log("Set HasPersistentWater = true for", player.Name)
	equipPersistentToolToPlayer(player)
end

-- Setup already-connected players
for _, pl in ipairs(Players:GetPlayers()) do
	setupPlayer(pl)
end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	local flag = player:FindFirstChild("HasPersistentWater")
	if flag then flag:Destroy() end
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
		warn("[WaterGiver] No TutorialStep for", player.Name)
		return
	end

	log("Touched by", player.Name, "step=", step.Value, "BackpackHasWater=", player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(TOOL_NAME) and true or false)

	-- Tutorial phase
	if step.Value == REQUIRED_STEP then
		if not (player.Backpack:FindFirstChild(TOOL_NAME) or (player.Character and player.Character:FindFirstChild(TOOL_NAME))) then
			giveWaterAndFlag(player)
		else
			log("Player already has Water during tutorial for", player.Name)
		end
		step.Value = REQUIRED_STEP + 1
		log("Advanced tutorial to", step.Value, "for", player.Name)
		return
	end

	-- Post-tutorial resupply
	if step.Value > REQUIRED_STEP then
		if not (player.Backpack:FindFirstChild(TOOL_NAME) or (player.Character and player.Character:FindFirstChild(TOOL_NAME))) then
			giveWaterAndFlag(player)
		else
			log("Resupply skipped; player already has Water:", player.Name)
		end
	end
end)
