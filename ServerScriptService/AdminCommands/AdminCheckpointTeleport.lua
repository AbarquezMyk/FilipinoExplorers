local Players = game:GetService("Players")
local CheckpointsFolder = workspace:FindFirstChild("Checkpoints")

-- Teleport function by checkpoint name
local function teleportToCheckpoint(player, checkpointName)
	local checkpoint = CheckpointsFolder:FindFirstChild(tostring(checkpointName))
	if checkpoint and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character:PivotTo(checkpoint.CFrame + Vector3.new(0, 4, 0))
	end
end

-- Chat command (!goto <number>)
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		local args = string.split(msg, " ")
		if args[1] == "!goto" and args[2] then
			local checkpointName = args[2]
			if CheckpointsFolder:FindFirstChild(checkpointName) then
				teleportToCheckpoint(player, checkpointName)
				print(player.Name.." teleported to checkpoint "..checkpointName)
			else
				warn("❌ Invalid checkpoint number: "..tostring(checkpointName))
			end
		end
	end)
end)
