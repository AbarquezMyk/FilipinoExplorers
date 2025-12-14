-- Script in ServerScriptService
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local giveEvent = ReplicatedStorage:WaitForChild("GiveItemEvent")

giveEvent.OnServerEvent:Connect(function(player, choice)
	if choice == "Tubig" then
		local tubig = ServerStorage:FindFirstChild("Water"):Clone()
		tubig.Parent = player.Backpack
	elseif choice == "Pagkain" then
		local pagkain = ServerStorage:FindFirstChild("Food"):Clone()
		pagkain.Parent = player.Backpack
	elseif choice == "Pareho" then
		local tubig = ServerStorage:FindFirstChild("Water"):Clone()
		local pagkain = ServerStorage:FindFirstChild("Food"):Clone()
		tubig.Parent = player.Backpack
		pagkain.Parent = player.Backpack
	end
end)
