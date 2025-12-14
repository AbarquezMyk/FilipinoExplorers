local Players = game:GetService("Players")

-- List of admin usernames (case insensitive)
local admins = {
	"miquixotic",
}

-- Helper to check admin
local function isAdmin(player)
	for _, name in ipairs(admins) do
		if player.Name:lower() == name:lower() then
			return true
		end
	end
	return false
end

-- Listen for player chats
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if isAdmin(player) then
			if message:lower() == "!skip" then
				local step = player:FindFirstChild("TutorialStep")
				if step then
					step.Value = 6 -- instantly finish tutorial
					print(player.Name .. " skipped their tutorial using command.")
				end
			end
		end
	end)
end)
