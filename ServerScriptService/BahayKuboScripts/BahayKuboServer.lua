local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local StartBahayKuboQuest = ReplicatedStorage:WaitForChild("StartBahayKuboQuest")
local MakeItemsVisible = ReplicatedStorage:WaitForChild("MakeItemsVisible")
local CollectItem = ReplicatedStorage:WaitForChild("CollectItem")
local ShowMessage = ReplicatedStorage:WaitForChild("ShowMessage")
local UpdateBahayKuboVisibility = ReplicatedStorage:WaitForChild("UpdateBahayKuboVisibility")
local MoveCamera = ReplicatedStorage:WaitForChild("MoveCamera")
local ItemTemplates = ReplicatedStorage:WaitForChild("ItemTemplates")

local playerProgress = {}
local playerMessageQueues = {}

-- Normalize item names
local function normalizeKey(itemName)
	if not itemName then return nil end
	local map = { bato = "Bato", kahoy = "Kahoy", yero = "Yero" }
	return map[string.lower(tostring(itemName))]
end

-- Get fake PrimaryPart inside a model
local function getFakePrimary(model)
	if not model then return nil end
	local fake = model:FindFirstChild("PrimaryPart")
	if fake and fake:IsA("BasePart") then
		fake.Transparency = 1
		fake.CanCollide = false
		fake.CastShadow = false
		return fake
	end
	return nil
end

-- Queue messages to player sequentially
local function queueMessage(player, message)
	if not playerMessageQueues[player] then
		playerMessageQueues[player] = {}
	end

	table.insert(playerMessageQueues[player], message)

	if #playerMessageQueues[player] == 1 then
		task.spawn(function()
			while #playerMessageQueues[player] > 0 do
				local msg = playerMessageQueues[player][1]
				ShowMessage:FireClient(player, msg)
				task.wait(4)
				table.remove(playerMessageQueues[player], 1)
			end
		end)
	end
end

-- Get or initialize player progress
local function getPlayerProgress(player)
	local p = playerProgress[player.UserId]
	if not p then
		p = {Bato=false, Kahoy=false, Yero=false, QuestDone=false, Started=false}
		playerProgress[player.UserId] = p
	end
	return p
end

-- Start or finish quest
StartBahayKuboQuest.OnServerEvent:Connect(function(player)
	local p = getPlayerProgress(player)

	-- Already finished
	if p.QuestDone then
		queueMessage(player, "Salamat ulit sa tulong mo!")
		return
	end

	-- Check missing items
	local missing = {}
	if not p.Bato then table.insert(missing, "Bato") end
	if not p.Kahoy then table.insert(missing, "Kahoy") end
	if not p.Yero then table.insert(missing, "Yero") end

	-- Start quest if not started
	if not p.Started then
		p.Started = true
		MakeItemsVisible:FireClient(player, ItemTemplates)

		local introDialogue = {
			"Magandang umaga, " .. player.DisplayName .. ". Pwede mo ba ako tulungan?",
			"Nasira ang aking bahay kubo dahil sa bagyo na dumaan.",
			"Kailangan ko ng kahoy, bato, at yero. Hanapin mo ito sa paligid."
		}

		for _, line in ipairs(introDialogue) do
			queueMessage(player, line)
		end
	end

	-- If missing items, remind player
	if #missing > 0 then
		queueMessage(player, "Kulang ka pa ng: " .. table.concat(missing, ", "))
		return
	end

	-- Finish quest
	p.QuestDone = true
	local finishDialogue = {
		"Salamat sa iyong tulong! Pwede ko nang buuin ang bahay kubo ko.",
		"Maaari ka na ring magpatuloy sa iyong paglalakbay."
	}

	for _, line in ipairs(finishDialogue) do
		queueMessage(player, line)
	end

	-- Show BahayKubo and Obby
	local gameFolder = workspace.Games:FindFirstChild("Bahay Kubo Builder")
	if not gameFolder then return end

	local bahay = gameFolder:FindFirstChild("BahayKubo")
	local obby = gameFolder:FindFirstChild("ObbyTrail")

	local bahayTarget = getFakePrimary(bahay)
	local obbyTarget = getFakePrimary(obby)

	if bahayTarget and obbyTarget then
		UpdateBahayKuboVisibility:FireClient(player, {
			BahayVisible = true,
			ObbyVisible = true,
			CheckpointVisible = true
		})

		local waypoints = {
			{ CFrame = CFrame.new(bahayTarget.Position + Vector3.new(0,20,20), bahayTarget.Position), Time = 3 },
			{ CFrame = CFrame.new(obbyTarget.Position + Vector3.new(0,20,-25), obbyTarget.Position), Time = 3 }
		}

		MoveCamera:FireClient(player, waypoints)
	end
end)

-- Collect items
CollectItem.OnServerEvent:Connect(function(player, itemType)
	local key = normalizeKey(itemType)
	if not key then return end

	local p = getPlayerProgress(player)
	if not p.Started then
		queueMessage(player, "Kausapin mo muna si Jose para simulan ang quest.")
		return
	end

	if not p[key] then
		p[key] = true
		queueMessage(player, "Nakolekta mo ang " .. key .. "!")
	else
		queueMessage(player, "May " .. key .. " ka na dati pa!")
	end
end)

-- Clean up on leave
Players.PlayerRemoving:Connect(function(player)
	playerProgress[player.UserId] = nil
	playerMessageQueues[player] = nil
end)
