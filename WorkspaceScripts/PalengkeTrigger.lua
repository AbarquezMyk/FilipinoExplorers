local trigger = script.Parent
local Players = game:GetService("Players")
local event = game.ReplicatedStorage:WaitForChild("PalengkeTrigger")

-- Track who already triggered
local triggeredPlayers = {}

trigger.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if player and not triggeredPlayers[player] then
		triggeredPlayers[player] = true
		event:FireClient(player)
	end
end)
