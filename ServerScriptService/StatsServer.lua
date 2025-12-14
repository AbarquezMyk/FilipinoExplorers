-- ServerScriptService/StatsServer
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

-- ===== CONFIG you can tweak =====
local MAX_HEALTH   = 100
local MAX_STAMINA  = 100
local WATER_GAIN   = 100   -- stamina from WaterBottle
local BURGER_HEAL  = 100   -- health from Food
local STAMINA_REGEN_PER_SEC = 1
-- =================================

local UseConsumable = RS:WaitForChild("UseConsumable")

-- Setup character stats
local function setupCharacter(player, character)
	local hum = character:WaitForChild("Humanoid")
	hum.MaxHealth = MAX_HEALTH
	hum.Health = MAX_HEALTH
end

-- Setup player stats
local function setupPlayer(player)
	-- Stats live on the Player so the client UI can read them
	local stats = player:FindFirstChild("Stats") or Instance.new("Folder")
	stats.Name = "Stats"
	stats.Parent = player

	local stamina = stats:FindFirstChild("Stamina") or Instance.new("NumberValue")
	stamina.Name = "Stamina"
	stamina.Value = MAX_STAMINA
	stamina.Parent = stats

	local maxStamina = stats:FindFirstChild("MaxStamina") or Instance.new("NumberValue")
	maxStamina.Name = "MaxStamina"
	maxStamina.Value = MAX_STAMINA
	maxStamina.Parent = stats

	if player.Character then setupCharacter(player, player.Character) end
	player.CharacterAdded:Connect(function(char) setupCharacter(player, char) end)
end

Players.PlayerAdded:Connect(setupPlayer)

-- Handle consumables used from client
UseConsumable.OnServerEvent:Connect(function(player, item)
	local lower = string.lower(item) -- normalize

	if lower == "water" then
		local stats = player:FindFirstChild("Stats")
		local s = stats and stats:FindFirstChild("Stamina")
		local m = stats and stats:FindFirstChild("MaxStamina")
		if s and m then
			s.Value = math.clamp(s.Value + WATER_GAIN, 0, m.Value)
			print("[StatsServer] Gave stamina from water to", player.Name)
		end

	elseif lower == "burger" or lower == "food" then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Health = math.clamp(hum.Health + BURGER_HEAL, 0, hum.MaxHealth)
			print("[StatsServer] Healed", player.Name, "from burger/food")
		end
	end
end)

-- Passive stamina regen loop
task.spawn(function()
	while true do
		for _, plr in ipairs(Players:GetPlayers()) do
			local stats = plr:FindFirstChild("Stats")
			if stats then
				local s = stats:FindFirstChild("Stamina")
				local m = stats:FindFirstChild("MaxStamina")
				if s and m then
					s.Value = math.min(s.Value + STAMINA_REGEN_PER_SEC, m.Value)
				end
			end
		end
		task.wait(1)
	end
end)
