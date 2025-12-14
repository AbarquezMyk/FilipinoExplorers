local Players = game:GetService("Players")

script.Parent.Touched:Connect(function(hit)
	local character = hit.Parent
	if character and character:FindFirstChild("Humanoid") then
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			local step = player:FindFirstChild("TutorialStep")

			-- ✅ Only works if the player is at step 5 (go to trail)
			if step and step.Value == 5 then
				step.Value = 6 -- Complete tutorial
			end
		end
	end
end)
