-- StarterPlayerScripts/BahayKuboVisibilityHandler
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateEvent = ReplicatedStorage:WaitForChild("UpdateBahayKuboVisibility")

local GAME_FOLDER = workspace:WaitForChild("Games"):WaitForChild("Bahay Kubo Builder")
local BAHAY = GAME_FOLDER:WaitForChild("BahayKubo")
local OBBY = GAME_FOLDER:WaitForChild("ObbyTrail")
local CHECKPOINT = workspace:WaitForChild("Checkpoints"):WaitForChild("1")

local function setVisible(model, visible)
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			desc.Transparency = visible and 0 or 1
			desc.CanCollide = visible
		elseif desc:IsA("Decal") or desc:IsA("Texture") then
			desc.Transparency = visible and 0 or 1
		end
	end
end

UpdateEvent.OnClientEvent:Connect(function(data)
	if data.BahayVisible ~= nil then
		setVisible(BAHAY, data.BahayVisible)
	end
	if data.ObbyVisible ~= nil then
		setVisible(OBBY, data.ObbyVisible)
	end
	if data.CheckpointVisible ~= nil then
		setVisible(CHECKPOINT, data.CheckpointVisible)
	end
end)
