-- StarterPlayerScripts/BahayKuboCameraHandler
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local MoveCamera = ReplicatedStorage:WaitForChild("MoveCamera")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Locate models
local bahayModel = Workspace.Games["Bahay Kubo Builder"]:WaitForChild("BahayKubo")
local obbyModel = Workspace.Games["Bahay Kubo Builder"]:WaitForChild("ObbyTrail")

-- Function to hide a model's PrimaryPart
local function hidePrimaryPart(model)
	if model and model.PrimaryPart then
		model.PrimaryPart.Transparency = 1
		model.PrimaryPart.CanCollide = false
		model.PrimaryPart.CastShadow = false
	end
end

MoveCamera.OnClientEvent:Connect(function(waypoints)
	-- 🟢 Make sure Bahay Kubo & Obby are visible BEFORE camera pans
	bahayModel.Parent = Workspace.Games["Bahay Kubo Builder"]
	obbyModel.Parent = Workspace.Games["Bahay Kubo Builder"]

	-- 🔥 Hide their PrimaryPart so player can't see it
	hidePrimaryPart(bahayModel)
	hidePrimaryPart(obbyModel)

	local originalCFrame = camera.CFrame

	-- 🎥 Camera tween loop
	for _, wp in ipairs(waypoints) do
		local tween = TweenService:Create(camera, TweenInfo.new(wp.Time), {CFrame = wp.CFrame})
		tween:Play()
		tween.Completed:Wait()
	end

	-- Return camera to player
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local returnTween = TweenService:Create(camera, TweenInfo.new(2), {
			CFrame = player.Character.HumanoidRootPart.CFrame
		})
		returnTween:Play()
	end
end)
