-- ServerScriptService/FallDamageServer
local Players = game:GetService("Players")

local SAFE_FALL = 12
local DMG_PER_STUD = 3
local MAX_DMG = 100

local function hookCharacter(char)
	local hum = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")
	local startY = nil

	hum.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Freefall then
			startY = hrp.Position.Y

		elseif new == Enum.HumanoidStateType.Swimming then
			hum.Health = 0

		elseif (new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running) and startY then
			local dist = startY - hrp.Position.Y
			if dist > SAFE_FALL then
				local dmg = math.min(MAX_DMG, (dist - SAFE_FALL) * DMG_PER_STUD)
				hum:TakeDamage(dmg)
			end
			startY = nil
		end
	end)

	-- FIX: Reset fall counter when dying
	hum.Died:Connect(function()
		startY = nil
	end)
end

Players.PlayerAdded:Connect(function(plr)
	if plr.Character then
		hookCharacter(plr.Character)
	end
	plr.CharacterAdded:Connect(hookCharacter)
end)
