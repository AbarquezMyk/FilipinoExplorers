-- ServerScriptService/StaminaMovementServer
local Players = game:GetService("Players")

-- TUNING
local WALK_DRAIN_PER_SEC   = 2   -- stamina drain when walking
local SPRINT_DRAIN_PER_SEC = 6    -- stamina drain when sprinting
local IDLE_REGEN_PER_SEC   = 1    -- stamina regen when standing still
local HEALTH_DRAIN_PER_SEC = 2    -- health drain when stamina is zero
local TICK = 0.50                 -- seconds between updates

local function getStats(plr)
	local stats = plr:FindFirstChild("Stats")
	if not stats then return end
	return stats:FindFirstChild("Stamina"), stats:FindFirstChild("MaxStamina")
end

-- Give players a Sprint flag
Players.PlayerAdded:Connect(function(plr)
	local sprinting = Instance.new("BoolValue")
	sprinting.Name = "IsSprinting"
	sprinting.Value = false
	sprinting.Parent = plr
end)

task.spawn(function()
	while true do
		for _, plr in ipairs(Players:GetPlayers()) do
			local char = plr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local s, m = getStats(plr)
			local sprinting = plr:FindFirstChild("IsSprinting")
			if hum and s and m and sprinting then
				local moving = hum.MoveDirection.Magnitude > 0.1
				local delta = 0

				if moving then
					if sprinting.Value then
						delta = -SPRINT_DRAIN_PER_SEC * TICK
					else
						delta = -WALK_DRAIN_PER_SEC * TICK
					end
				else
					delta = IDLE_REGEN_PER_SEC * TICK
				end

				s.Value = math.clamp(s.Value + delta, 0, m.Value)

				-- 🩸 Drain health if stamina is 0
				if s.Value <= 0 then
					hum.Health = math.max(hum.Health - (HEALTH_DRAIN_PER_SEC * TICK), 0)
				end
			end
		end
		task.wait(TICK)
	end
end)
