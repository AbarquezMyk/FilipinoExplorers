-- Checkpoint System v10 (UPDATED)
-- Persistent checkpoint tracking (Base → Summit)
-- Leaderboard (Summits) is now synced correctly

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local progressStore = DataStoreService:GetDataStore("CheckpointSaveV10")

-- === CONFIG ===
local CHECKPOINTS_FOLDER = workspace:WaitForChild("Checkpoints")
local SUMMIT_NAME = "Summit"
local SUMMIT_LABEL = "Tuktok"
local START_SPAWN = workspace:WaitForChild("SpawnLocation")
local DEBOUNCE_TIME = 2
-- =====================

local checkpointParts = {}
local playerData = {}
local summitReached = {}
local lastTouchTime = {}

-- === GATHER CHECKPOINTS ===
for _, part in ipairs(CHECKPOINTS_FOLDER:GetChildren()) do
	if part:IsA("BasePart") then
		table.insert(checkpointParts, part)
	end
end

-- === UTILITIES ===
local function playFeedback(part)
	local sound = part:FindFirstChildOfClass("Sound")
	if sound then sound:Play() end
end

-- === LEADERBOARD SYNC ===
local function syncLeaderboard(player)
	local data = playerData[player]
	if not data then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local summits = leaderstats:FindFirstChild("Summits")
		if summits then
			summits.Value = data.summitVisits
		end
	end
end

-- === SAFE DATASTORE SAVE ===
local function savePlayerData(player)
	local data = playerData[player]
	if not data then return end

	local success, err = pcall(function()
		progressStore:SetAsync(player.UserId, {
			lastCheckpointName = data.lastCheckpointName,
			summitVisits = data.summitVisits
		})
	end)

	if success then
		print("💾 Saved:", player.Name, data.lastCheckpointName, data.summitVisits)
	else
		warn("❌ Save failed for", player.Name, err)
	end
end

-- === LOAD DATA ===
local function loadPlayerData(player)
	local success, result = pcall(function()
		return progressStore:GetAsync(player.UserId)
	end)

	if success and result then
		playerData[player] = {
			lastCheckpointName = result.lastCheckpointName,
			summitVisits = result.summitVisits or 0
		}
	else
		playerData[player] = {
			lastCheckpointName = nil,
			summitVisits = 0
		}
	end

	summitReached[player] = false
	syncLeaderboard(player)
end

-- === SUMMIT TAG ===
local function ensureSummitTag(player)
	local character = player.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	if not head then return end

	local billboard = head:FindFirstChild("SummitTag")
	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "SummitTag"
		billboard.Size = UDim2.new(0, 140, 0, 30)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head

		local text = Instance.new("TextLabel")
		text.Name = "Label"
		text.Size = UDim2.new(1, 0, 1, 0)
		text.BackgroundTransparency = 1
		text.TextScaled = true
		text.Font = Enum.Font.GothamBold
		text.TextColor3 = Color3.new(1, 1, 1)
		text.Parent = billboard
	end

	local data = playerData[player]
	local label = billboard.Label

	if data.summitVisits > 0 then
		label.Text = ("🏔️ %s %d"):format(SUMMIT_LABEL, data.summitVisits)
	else
		label.Text = "🏕️ Baguhan"
	end
end

local function updateSummitDisplay(player)
	task.defer(function()
		if player.Character then
			ensureSummitTag(player)
		end
	end)
end

-- === TELEPORT HANDLER ===
local function teleportToCheckpoint(player, character)
	local data = playerData[player]
	if not data or not character then return end

	local checkpointName = data.lastCheckpointName

	if checkpointName == SUMMIT_NAME then
		checkpointName = nil
		summitReached[player] = false
	end

	local target = START_SPAWN
	if checkpointName then
		local cp = CHECKPOINTS_FOLDER:FindFirstChild(checkpointName)
		if cp then
			target = cp
		end
	end

	if target and character:FindFirstChild("HumanoidRootPart") then
		character:PivotTo(target.CFrame + Vector3.new(0, 3, 0))
	end
end

-- === CHECKPOINT TOUCH ===
local function onCheckpointTouched(player, checkpoint)
	local data = playerData[player]
	if not data then return end

	playFeedback(checkpoint)

	if checkpoint.Name == SUMMIT_NAME then
		if not summitReached[player] then
			data.summitVisits += 1
			summitReached[player] = true

			syncLeaderboard(player)
			savePlayerData(player)

			print(player.Name, "completed a run:", data.summitVisits)
		end
	else
		summitReached[player] = false
	end

	data.lastCheckpointName = checkpoint.Name
	savePlayerData(player)
	updateSummitDisplay(player)
end

-- === TOUCH CONNECTIONS ===
for _, checkpoint in ipairs(checkpointParts) do
	checkpoint.Touched:Connect(function(hit)
		local char = hit.Parent
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then return end

		local player = Players:GetPlayerFromCharacter(char)
		if not player then return end

		local now = tick()
		if lastTouchTime[player] and now - lastTouchTime[player] < DEBOUNCE_TIME then
			return
		end

		lastTouchTime[player] = now
		onCheckpointTouched(player, checkpoint)
	end)
end

-- === PLAYER JOIN / LEAVE ===
Players.PlayerAdded:Connect(function(player)
	loadPlayerData(player)

	player.CharacterAdded:Connect(function(character)
		task.wait(0.1)
		teleportToCheckpoint(player, character)
		updateSummitDisplay(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
	playerData[player] = nil
	summitReached[player] = nil
	lastTouchTime[player] = nil
end)
