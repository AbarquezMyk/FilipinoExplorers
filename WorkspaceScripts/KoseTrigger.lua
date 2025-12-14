local prompt = script.Parent
local kampoFolder = workspace.Games["Ayusin ang Kampo"]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StartEvent = ReplicatedStorage:WaitForChild("StartKampoQuest")
local FinishEvent = ReplicatedStorage:WaitForChild("FinishKampoQuest")

local questActive = {}

prompt.Triggered:Connect(function(player)
	if questActive[player.UserId] then return end
	questActive[player.UserId] = true
	prompt.Enabled = false
	StartEvent:FireClient(player)
end)

FinishEvent.OnServerEvent:Connect(function(player)
	questActive[player.UserId] = nil
	prompt.Enabled = true
end)
