-- StarterPlayerScripts/CampfireQuestClient
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local questEvent = ReplicatedStorage:WaitForChild("CampfireQuestEvent")

-- Your existing GUI
local gui = player:WaitForChild("PlayerGui"):WaitForChild("RiaGUI")
local frame = gui:WaitForChild("Frame")
local label = frame:WaitForChild("TextLabel")

-- Show dialogue sentences one by one
local function showDialogue(sentences)
	frame.Visible = true
	for _, sentence in ipairs(sentences) do
		label.Text = sentence
		task.wait(5) -- wait 5 seconds before showing next sentence
	end
	frame.Visible = false
end

questEvent.OnClientEvent:Connect(function(action, data)
	if action == "Dialogue" and type(data) == "table" then
		showDialogue(data)
	end
end)