local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local event = ReplicatedStorage:WaitForChild("TutorialEvent")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

event.OnClientEvent:Connect(function()
	local playerGui = player:WaitForChild("PlayerGui")
	local bahayKuboGui = playerGui:WaitForChild("JoseGui")
	local frame = bahayKuboGui:WaitForChild("Frame")
	local textLabel = frame:WaitForChild("TextLabel")
	local cameraFocus = workspace:WaitForChild("Games"):WaitForChild("Bahay Kubo Builder"):WaitForChild("CameraFocus")

	-- Show GUI
	bahayKuboGui.Enabled = true
	frame.Visible = true
	textLabel.Visible = true
	textLabel.Text = "Kausapin si Jose. Kailangan niya ng tulong mo"

	-- Set camera to Scriptable
	camera.CameraType = Enum.CameraType.Scriptable

	-- Create smooth tween
	local targetCFrame = CFrame.new(cameraFocus.Position + Vector3.new(0, 10, -20), cameraFocus.Position)
	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) -- 2 seconds smooth move
	local tween = TweenService:Create(camera, tweenInfo, {CFrame = targetCFrame})
	tween:Play()
	tween.Completed:Wait()

	-- Hold for 5 seconds
	task.wait(5)

	-- Reset camera
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = player.Character:WaitForChild("Humanoid")

	-- Hide GUI
	bahayKuboGui.Enabled = false
end)
