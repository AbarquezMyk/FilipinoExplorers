local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local MakeItemsVisible = RS:WaitForChild("MakeItemsVisible")

local function spawnItem(template, spawnPart)
	print("📦 Spawning item from template:", template.Name)

	local itemClone = template:Clone()
	itemClone.Parent = Workspace

	-- Make pickup part invisible
	if itemClone:IsA("BasePart") then
		itemClone.CFrame = spawnPart.CFrame
		itemClone.Transparency = 1
		itemClone.CanCollide = false
		itemClone.Anchored = true
		itemClone.CanTouch = true

		print("✅ Pickup part hidden for:", itemClone.Name)
	else
		warn("❌ WARNING: Template root IS NOT a BasePart:", template.Name)
	end

	-- Make model visible
	for _, d in ipairs(itemClone:GetDescendants()) do
		if d:IsA("BasePart") or d:IsA("MeshPart") then
			d.Transparency = 0
			d.CanCollide = false
			d.Anchored = true

			print("🧱 Visible part:", d.Name, "Parent:", d.Parent.Name)
		end
	end

	-- Pickup detection
	local pickedUp = false

	itemClone.Touched:Connect(function(hit)
		if pickedUp then return end

		local char = player.Character
		if char and hit:IsDescendantOf(char) then
			pickedUp = true -- stop multiple triggers
			local itemType = template.Name:gsub("_Item","")

			print("🎒 Picked up item:", itemType)
			RS.CollectItem:FireServer(itemType)

			itemClone:Destroy()
		end
	end)
end

MakeItemsVisible.OnClientEvent:Connect(function()
	print("🚀 MakeItemsVisible event triggered")

	local spawnFolder = Workspace
		:WaitForChild("Games")
		:WaitForChild("Bahay Kubo Builder")
		:WaitForChild("ItemsSpawnPoints")

	for _, spawnPoint in ipairs(spawnFolder:GetChildren()) do
		if spawnPoint:IsA("BasePart") then
			local itemName = spawnPoint.Name:gsub("Spawn","") .. "_Item"
			local template = RS.ItemTemplates:FindFirstChild(itemName)

			print("🔍 Checking template:", itemName)

			if template then
				print("✅ Template found:", itemName, " → Spawning now")
				spawnItem(template, spawnPoint)
			else
				warn("⚠️ MISSING TEMPLATE for:", itemName)
			end
		end
	end
end)
