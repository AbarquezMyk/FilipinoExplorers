local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LockCamera = ReplicatedStorage:WaitForChild("LockCamera")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

LockCamera.OnClientEvent:Connect(function()
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	camera.FieldOfView = 70
end)
