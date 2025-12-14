local Players = game:GetService("Players")
local debounce = false

for _, ClothesGiver in pairs(script.Parent:GetChildren()) do
	if ClothesGiver:IsA("Model") then
		local Rig = ClothesGiver:WaitForChild("Rig")
		local Button = ClothesGiver:WaitForChild("Button")
		local Pants = Rig:FindFirstChildWhichIsA("Pants")
		local Shirt = Rig:FindFirstChildWhichIsA("Shirt")

		Button.Touched:Connect(function(hit)
			if hit.Parent:FindFirstChild("Humanoid") then
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if player then
					local step = player:FindFirstChild("TutorialStep")

					-- ✅ Allow choosing clothes any time
					if not debounce then
						debounce = true

						local character = player.Character or player.CharacterAdded:Wait()

						-- Apply pants & shirt to character
						for _, v in pairs(character:GetChildren()) do
							if v:IsA("Pants") then
								v.PantsTemplate = Pants.PantsTemplate
							elseif v:IsA("Shirt") then
								v.ShirtTemplate = Shirt.ShirtTemplate
							end
						end

						-- ✅ Advance tutorial ONLY if still on step 1
						if step and step.Value == 1 then
							step.Value = 2
						end

						task.wait(0.5)
						debounce = false
					end
				end
			end
		end)
	end
end
