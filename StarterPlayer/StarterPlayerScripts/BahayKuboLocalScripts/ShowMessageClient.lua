local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ShowMessage = ReplicatedStorage:WaitForChild("ShowMessage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI elements
local gui = playerGui:WaitForChild("BahayKuboGui")
local frame = gui:WaitForChild("Frame")
local textLabel = frame:WaitForChild("TextLabel")
frame.Visible = false

-- Queue messages safely
local messageQueue = {}
local displaying = false

local function displayNext()
	if displaying then return end
	displaying = true
	while #messageQueue > 0 do
		local msg = table.remove(messageQueue, 1)
		textLabel.Text = msg
		frame.Visible = true
		local startTime = tick()
		while tick() - startTime < 4 do
			task.wait(0.03)
		end
		frame.Visible = false
		task.wait(0.05)
	end
	displaying = false
end

ShowMessage.OnClientEvent:Connect(function(msg)
	table.insert(messageQueue, msg)
	task.spawn(displayNext)
end)

-- Re-setup after respawn
player.CharacterAdded:Connect(function()
	task.wait(0.1) -- allow PlayerGui rebuild
	gui = playerGui:WaitForChild("BahayKuboGui")
	frame = gui:WaitForChild("Frame")
	textLabel = frame:WaitForChild("TextLabel")
	frame.Visible = false
end)
