-- LocalScript (StarterPlayerScripts/SprintControl)
local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local sprinting = player:WaitForChild("IsSprinting")

local WALK_SPEED = 18
local SPRINT_SPEED = 38

-- Function to attach sprinting to the current character
local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")

	-- Start sprinting when Shift is pressed
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.LeftShift then
			if humanoid.Health > 0 then
				sprinting.Value = true
				humanoid.WalkSpeed = SPRINT_SPEED
			end
		end
	end)

	-- Stop sprinting when Shift is released
	UIS.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift then
			sprinting.Value = false
			humanoid.WalkSpeed = WALK_SPEED
		end
	end)

	-- Reset sprint when stamina runs out
	local stats = player:WaitForChild("Stats")
	local stamina = stats:WaitForChild("Stamina")
	stamina:GetPropertyChangedSignal("Value"):Connect(function()
		if stamina.Value <= 0 then
			sprinting.Value = false
			humanoid.WalkSpeed = WALK_SPEED
		end
	end)

	-- Also stop sprinting when the character dies
	humanoid.Died:Connect(function()
		sprinting.Value = false
	end)
end

-- Connect to current and future characters
if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)
