local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local event = ReplicatedStorage:WaitForChild("PalengkeTrigger")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

event.OnClientEvent:Connect(function()
	local playerGui = player:WaitForChild("PlayerGui")
	local turonGui = playerGui:WaitForChild("PalengkeTriggerGui")
	local frame = turonGui:WaitForChild("Frame")
	local textLabel = frame:WaitForChild("TextLabel")
	local cameraFocus = workspace:WaitForChild("Games"):WaitForChild("Palengke Pursuit"):WaitForChild("CameraFocus")

	-- Show GUI
	turonGui.Enabled = true
	frame.Visible = true
	textLabel.Visible = true
	textLabel.Text = "Kausapin si Turon. Kailangan niya ng tulong mo"

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
	turonGui.Enabled = false
end)
