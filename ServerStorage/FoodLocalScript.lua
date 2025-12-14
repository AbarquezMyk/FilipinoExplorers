local RS = game:GetService("ReplicatedStorage")
local UseConsumable = RS:WaitForChild("UseConsumable")
local tool = script.Parent
local uses = 1

tool.Activated:Connect(function()
	if uses <= 0 then return end
	uses -= 1

	-- Tell server the tool was used
	UseConsumable:FireServer(tool.Name)

	-- DO NOT DESTROY THE TOOL ON CLIENT
	-- Server will handle removing it from inventory
end)
