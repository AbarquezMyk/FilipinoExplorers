local backpackFolder = script.Parent
local Players = game:GetService("Players")

-- Remove only backpacks from this giver system
local function removeBackpack(player)
	if not player.Character then return end
	for _, item in ipairs(player.Character:GetChildren()) do
		if item:IsA("Accessory") and item:FindFirstChild("Handle") then
			-- Check if this accessory matches any in the folder
			for _, giver in ipairs(backpackFolder:GetChildren()) do
				local giverAccessory = giver:FindFirstChildWhichIsA("Accessory")
				if giverAccessory and item.Name == giverAccessory.Name then
					item:Destroy()
				end
			end
		end
	end
end

-- Give backpack to player
local function giveBackpack(player, accessory)
	if not player.Character then return end

	-- Remove the old backpack first
	removeBackpack(player)

	-- Clone new backpack
	local newAccessory = accessory:Clone()

	-- Ensure handle is unanchored
	local handle = newAccessory:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then
		handle.Anchored = false
	end

	-- Give to character
	newAccessory.Parent = player.Character
end

-- Setup all BackpackGivers
for _, giver in ipairs(backpackFolder:GetChildren()) do
	if giver:IsA("Model") then
		local touchPart = giver:FindFirstChild("Part") -- Trigger part
		local accessory = giver:FindFirstChildWhichIsA("Accessory")

		if touchPart and accessory then
			touchPart.Touched:Connect(function(hit)
				local character = hit.Parent
				local player = Players:GetPlayerFromCharacter(character)
				if player then
					local step = player:FindFirstChild("TutorialStep")

					-- ✅ Give backpack
					giveBackpack(player, accessory)

					-- ✅ Advance tutorial ONLY if still on step 2
					if step and step.Value == 2 then
						step.Value = 3
					end
				end
			end)
		else
			warn("BackpackGiver missing TouchPart or Accessory:", giver.Name)
		end
	end
end
