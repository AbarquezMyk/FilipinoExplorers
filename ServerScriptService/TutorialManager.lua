local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local tutorialStore = DataStoreService:GetDataStore("TutorialProgressV1")

local function setupPlayer(player)
	local data
	local success = pcall(function()
		data = tutorialStore:GetAsync(player.UserId)
	end)

	local step = Instance.new("IntValue")
	step.Name = "TutorialStep"
	step.Parent = player

	if success and data and data >= 6 then
		step.Value = 6
	else
		step.Value = data or 1
	end

	step:GetPropertyChangedSignal("Value"):Connect(function()
		pcall(function()
			tutorialStore:SetAsync(player.UserId, step.Value)
		end)
	end)
end

Players.PlayerAdded:Connect(setupPlayer)

for _, p in ipairs(Players:GetPlayers()) do
	setupPlayer(p)
end
