local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local prompt = workspace:WaitForChild("Games")
	:WaitForChild("Bahay Kubo Builder")
	:WaitForChild("Jose")
	:WaitForChild("PromptPart")
	:WaitForChild("ProximityPrompt")

local StartBahayKuboQuest = ReplicatedStorage:WaitForChild("StartBahayKuboQuest")

prompt.Triggered:Connect(function()
	print("✅ Jose prompt triggered!")
	StartBahayKuboQuest:FireServer()
end)
