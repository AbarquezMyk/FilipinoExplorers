-- ServerScriptService/UseConsumableHandler
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UseConsumable = ReplicatedStorage:WaitForChild("UseConsumable")

UseConsumable.OnServerEvent:Connect(function(player, itemName)
	if not player then return end
	print("[UseConsumable] Received from", player.Name, "item:", tostring(itemName))

	-- Apply the item's effect (example)
	local lower = tostring(itemName):lower()
	if lower == "food" or lower == "burger" then
		-- example: heal
		local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 20)
		end
	elseif lower == "water" then
		-- example: restore thirst (custom)
		-- do your custom effect here
	end

	-- Helper to destroy tool if present
	local function destroyToolIfExists(container, name)
		if not container then return false end
		local t = container:FindFirstChild(name)
		if t then
			t:Destroy()
			print("[UseConsumable] Destroyed", name, "in", container:GetFullName())
			return true
		end
		return false
	end

	-- Try canonical names + raw name to be robust
	-- canonical mapping (adjust if your tool has different exact names)
	local canonical = nil
	if lower == "burger" or lower == "food" then canonical = "Food" end
	if lower == "water" then canonical = "Water" end

	if canonical then
		destroyToolIfExists(player.Backpack, canonical)
		destroyToolIfExists(player.Character, canonical)
	end

	-- also attempt raw itemName just in case
	destroyToolIfExists(player.Backpack, tostring(itemName))
	destroyToolIfExists(player.Character, tostring(itemName))
end)
