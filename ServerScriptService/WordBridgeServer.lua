-- ServerScript: WordBridgeServer
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

---------------------------------------------------
-- 🔗 References
---------------------------------------------------
local gamesFolder = Workspace:WaitForChild("Games")
local tulay = gamesFolder:WaitForChild("Tulay ng Salita")

-- Word Bridge is a MODEL
local wordBridge = tulay:WaitForChild("Word Bridge")
local wordsFolder = wordBridge:WaitForChild("Words")

local correctFolder = wordsFolder:WaitForChild("CorrectWords")
local wrongFolder = wordsFolder:WaitForChild("WrongWords")
local bridgeStart = Workspace:WaitForChild("Checkpoints"):WaitForChild("9")

---------------------------------------------------
-- 📡 Remotes
---------------------------------------------------
local updateRemote = ReplicatedStorage:WaitForChild("Bridge_UpdateSentence")
local failRemote = ReplicatedStorage:WaitForChild("Bridge_Fail")

---------------------------------------------------
-- ✏️ Sentence setup
---------------------------------------------------
local sentenceWords = {"kaya", "bumaha", "sa", "kalsada", "at", "nahirapang", "makauwi", "ang", "lahat"}
local basePhrase = "Umuulan kagabi"
local finalSentence = "Umuulan kagabi kaya bumaha sa kalsada at nahirapang makauwi ang lahat"
local finishMessage = "Natapos mo na ang Tulay ng Salita, pwede ka na magpatuloy sa daan."

---------------------------------------------------
-- 📊 Per-player tracking
---------------------------------------------------
local playerData = {}

---------------------------------------------------
-- 🧭 Teleport helper
---------------------------------------------------
local function teleportToCheckpoint(player)
	local data = playerData[player.UserId]
	if not data or data.finished then return end

	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		print("[TELEPORT]", player.Name, "to checkpoint:", data.checkpoint)
		char.HumanoidRootPart.CFrame = CFrame.new(data.checkpoint)
	end
end

---------------------------------------------------
-- 🧍 Player setup
---------------------------------------------------
local function setupPlayer(player)
	local alreadyFinished = player:GetAttribute("WordBridgeDone")

	playerData[player.UserId] = {
		progress = 0,
		checkpoint = bridgeStart.Position + Vector3.new(0, 5, 0),
		debounce = {},
		finished = alreadyFinished or false
	}

	-- ⚠️ Prevent teleporting right when the player joins (stay in SpawnLocation)
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local data = playerData[player.UserId]
		if not data then return end

		-- Only teleport if the player has actually started the Word Bridge minigame
		if char and char:FindFirstChild("HumanoidRootPart") and data.progress > 0 and not data.finished then
			char.HumanoidRootPart.CFrame = CFrame.new(data.checkpoint)
		end
	end)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	playerData[player.UserId] = nil
end)

---------------------------------------------------
-- 🟩 Handle correct step
---------------------------------------------------
local function handleCorrectStep(player, part, stepNum)
	local data = playerData[player.UserId]
	if not data or data.finished then return end
	if data.debounce[part] then return end
	data.debounce[part] = true

	task.defer(function()
		local expected = data.progress + 1
		local stepValue = tonumber(stepNum)
		print(string.format("[CORRECT TOUCH] %s on %s | Step: %d | Expected: %d", player.Name, part.Name, stepValue, expected))

		if stepValue == expected then
			data.progress += 1
			data.checkpoint = part.Position + Vector3.new(0, part.Size.Y / 2 + 3, 0)

			local updatedText = basePhrase .. " " .. table.concat(sentenceWords, " ", 1, data.progress)
			print(string.format("[DEBUG PROGRESS] %s: %d of %d", player.Name, data.progress, #sentenceWords))

			-- 🟨 Send sentence updates while not finished
			if data.progress < #sentenceWords then
				updateRemote:FireClient(player, updatedText, data.progress, #sentenceWords, false)
			end

			-- 🏁 Finished the bridge
			if data.progress == #sentenceWords and not data.finished then
				data.finished = true
				player:SetAttribute("WordBridgeDone", true)
				print("[FINISHED]", player.Name, "completed the bridge!")

				-- 1️⃣ Show final sentence
				updateRemote:FireClient(player, finalSentence, data.progress, #sentenceWords, true)

				-- 2️⃣ After 4 seconds, show “natapos na” message
				task.delay(4, function()
					updateRemote:FireClient(player, finishMessage, data.progress, #sentenceWords, true)
				end)
			end
		else
			print("[WRONG ORDER]", player.Name, "on", part.Name, "expected step", expected)
			failRemote:FireClient(player, nil)
			task.wait(1.2)
			teleportToCheckpoint(player)
		end

		task.wait(0.3)
		data.debounce[part] = nil
	end)
end

---------------------------------------------------
-- 🟥 Handle wrong step
---------------------------------------------------
local function handleWrongStep(player, part)
	local data = playerData[player.UserId]
	if not data or data.finished then return end
	if data.debounce[part] then return end
	data.debounce[part] = true

	task.defer(function()
		print("[WRONG TOUCH]", player.Name, "on", part.Name)
		failRemote:FireClient(player, part)
		task.wait(1.2)
		teleportToCheckpoint(player)
		task.wait(0.3)
		data.debounce[part] = nil
	end)
end

---------------------------------------------------
-- 👣 Detect player from touch
---------------------------------------------------
local function getPlayerFromTouch(hit)
	local char = hit.Parent
	return char and Players:GetPlayerFromCharacter(char) or nil
end

---------------------------------------------------
-- 🔗 Connect all parts
---------------------------------------------------
for _, part in ipairs(correctFolder:GetChildren()) do
	if part:IsA("BasePart") then
		local stepNum = part:GetAttribute("Step")
		if not stepNum then
			warn("❌ Correct part missing Step attribute:", part.Name)
		else
			print("✅ Connected correct part:", part.Name, "Step:", stepNum)
			part.Touched:Connect(function(hit)
				local player = getPlayerFromTouch(hit)
				if player then handleCorrectStep(player, part, stepNum) end
			end)
		end
	end
end

for _, part in ipairs(wrongFolder:GetChildren()) do
	if part:IsA("BasePart") then
		print("⚠️ Connected wrong part:", part.Name)
		part.Touched:Connect(function(hit)
			local player = getPlayerFromTouch(hit)
			if player then handleWrongStep(player, part) end
		end)
	end
end
