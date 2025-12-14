local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TuronDialog = ReplicatedStorage:WaitForChild("TuronDialog")

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = playerGui:WaitForChild("TuronGui")
local frame = gui:WaitForChild("Frame")
local textLabel = frame:WaitForChild("TextLabel")

frame.Visible = false

-- Queue system to show one message at a time
TuronDialog.OnClientEvent:Connect(function(messages)
	frame.Visible = true
	for _, msg in ipairs(messages) do
		textLabel.Text = msg  -- msg is a string
		task.wait(4)          -- show each message for 4 seconds
	end
	frame.Visible = false
end)
