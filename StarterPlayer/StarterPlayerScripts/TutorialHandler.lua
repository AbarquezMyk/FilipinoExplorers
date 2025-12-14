local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Wait for GUI to load in PlayerGui
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("TutorialGui")
local frame = gui:WaitForChild("Frame")
local textLabel = frame:WaitForChild("TextLabel")

-- Wait for the server-created IntValue
local stepValue = player:WaitForChild("TutorialStep")

-- Tutorial messages
local messages = {
	[1] = "Maligayang Pagdating! Una, magpalit ka muna ng damit sa istasyon ng pananamit sa loob ng bahay.",
	[2] = "Ayos! Ngayon, kumuha ng bag sa istasyon ng bag.",
	[3] = "Galing! Lumabas at kumuha ng pagkain para sa iyong lakad.",
	[4] = "Ngayon, uminom ng tubig para manatiling may sapat na tubig sa katawan.",
	[5] = "Handa ka na! Tumungo sa daanan para simulan ang iyong paglalakad.",
	[6] = "Tapos na ang gabay! Masayang paglalakbay!"
}

-- Function to update tutorial text
local function updateMessage(step)
	local msg = messages[step]
	if msg then
		gui.Enabled = true
		frame.Visible = true
		textLabel.Visible = true
		textLabel.Text = msg
	else
		gui.Enabled = false
	end

	-- Hide GUI after 3 seconds on the final step
	if step == 6 then
		task.delay(3, function()
			gui.Enabled = false
		end)
	end
end

-- Initialize
updateMessage(stepValue.Value)

-- Update whenever the server changes the step
stepValue:GetPropertyChangedSignal("Value"):Connect(function()
	updateMessage(stepValue.Value)
end)
