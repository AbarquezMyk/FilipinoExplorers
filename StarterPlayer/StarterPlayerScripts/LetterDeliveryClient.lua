-- StarterPlayerScripts/LetterDeliveryClient
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ShowQuestGui = ReplicatedStorage:WaitForChild("ShowQuestGui")

ShowQuestGui.OnClientEvent:Connect(function(guiName, message, append)
	local gui = playerGui:FindFirstChild(guiName)
	if gui then
		local frame = gui:FindFirstChild("Frame")
		local textLabel = frame and frame:FindFirstChild("TextLabel")

		if textLabel then
			if append then
				-- Add a line break before appending the second part
				textLabel.Text = textLabel.Text .. "\n" .. message
			else
				-- Replace with the first message
				textLabel.Text = message
			end
		end

		gui.Enabled = true
		if frame then frame.Visible = true end

		-- Auto-hide after 10 seconds (enough time for both lines)
		task.delay(10, function()
			if gui then
				if frame then frame.Visible = false end
				gui.Enabled = false
			end
		end)
	end
end)
