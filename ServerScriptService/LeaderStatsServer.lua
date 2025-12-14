local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	-- This folder name MUST be "leaderstats"
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Example stat (change name if needed)
	local score = Instance.new("IntValue")
	score.Name = "Summits" -- Column name in leaderboard
	score.Value = 0
	score.Parent = leaderstats
end)
