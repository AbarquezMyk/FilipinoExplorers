-- PalengkeQuestServer (ServerScriptService)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TuronDialog = ReplicatedStorage:WaitForChild("TuronDialog")
local BuyFromStall = ReplicatedStorage:WaitForChild("BuyFromStall")
local SellerDialog = ReplicatedStorage:WaitForChild("SellerDialog")
local ItemsFolder = ReplicatedStorage:WaitForChild("Items")

local palengke = workspace:WaitForChild("Games"):WaitForChild("Palengke Pursuit")
local turon = palengke:WaitForChild("Turon")
local stallCollection = palengke:WaitForChild("Stall Collection")

local promptpart = turon:WaitForChild("ProximityPart")
local prompt = promptpart:FindFirstChildWhichIsA("ProximityPrompt", true)

-- Quest order
local requests = {"Baboy", "Mansanas", "Pandesal", "Manok", "Pakwan", "Isda", "Dalandan"}

-- Stall → items
local stallItems = {
	["Baboy At Manok Stall"] = {"Baboy", "Manok"},
	["Isda Stall"] = {"Isda"},
	["Pandesal Stall"] = {"Pandesal"},
	["Prutas Stall"] = {"Mansanas", "Dalandan", "Pakwan"}
}

-- Player progress
local playerProgress = {}

local function getDisplayName(player)
	return player.DisplayName ~= "" and player.DisplayName or player.Name
end

local function getCurrentRequest(player)
	local progress = playerProgress[player.UserId] or 0
	if progress == 0 then return nil end
	if progress <= #requests then return requests[progress] end
	return nil
end

-- ========================= TURON DIALOG =========================
if prompt then
	prompt.Triggered:Connect(function(player)
		local progress = playerProgress[player.UserId] or 0
		local messages = {}

		-- Quest completed
		if progress > #requests then
			messages = { "Salamat po! Ingat po kayo sa daan." }

			-- First time talking → start quest
		elseif progress == 0 then
			playerProgress[player.UserId] = 1
			local name = getDisplayName(player)
			messages = {
				"Magandang umaga, " .. name .. "! Pwede mo ba ako tulungan sa pagbili ng kailangan ng aking ina?",
				"Mahirap kasi maiwan ang aking kapatid kaya hindi ako makalayo.",
				"Kailangan ko ng " .. requests[1] .. ". Pwede mo ba akong tulungan bilhin ito?"
			}

			-- Ongoing quest
		else
			local currentRequest = requests[progress]
			local hasItem = player.Backpack:FindFirstChild(currentRequest) 
				or (player.Character and player.Character:FindFirstChild(currentRequest))

			if hasItem then
				-- Accept item
				hasItem:Destroy()
				playerProgress[player.UserId] = progress + 1  -- increment progress

				table.insert(messages, "Salamat sa pagdala ng " .. currentRequest .. "!")

				-- Next request (if any)
				if progress + 1 <= #requests then
					table.insert(messages, "Kailangan ko naman ng " .. requests[progress + 1] .. ".")
				end

			else
				messages = { "Kailangan ko ng " .. currentRequest .. ". Pwede mo ba akong bilhan?" }
			end
		end

		TuronDialog:FireClient(player, messages)
	end)
else
	warn("Turon ProximityPrompt missing!")
end

-- ========================= STALL DIALOG =========================
for stallName, items in pairs(stallItems) do
	local stall = stallCollection:FindFirstChild(stallName)
	if stall then
		local prompt = stall:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			prompt.Triggered:Connect(function(player)
				print(player.Name .. " triggered stall: " .. stallName)
				SellerDialog:FireClient(player, items, stallName)
			end)
		end
	end
end

-- ========================= BUY ITEM =========================
BuyFromStall.OnServerEvent:Connect(function(player, chosenItem, stallName)
	print(player.Name .. " requested " .. tostring(chosenItem) .. " from " .. tostring(stallName))

	if type(chosenItem) ~= "string" or type(stallName) ~= "string" then
		warn("Invalid BuyFromStall parameters")
		return
	end

	local progress = playerProgress[player.UserId] or 0

	-- Quest not started or already completed
	if progress == 0 or progress > #requests then
		TuronDialog:FireClient(player, {"Wala ka nang kailangang bilhin ngayon."})
		return
	end

	local requiredItem = requests[progress]
	if chosenItem ~= requiredItem then
		TuronDialog:FireClient(player, {
			"Hindi mo pa kailangan ang " .. chosenItem .. ".",
			"Ang kailangan mo ngayon ay: " .. requiredItem .. "."
		})
		return
	end

	-- Stall validation
	local allowedList = stallItems[stallName]
	local allowed = false
	if allowedList then
		for _, v in ipairs(allowedList) do
			if v == chosenItem then
				allowed = true
				break
			end
		end
	end

	if not allowed then
		TuronDialog:FireClient(player, {"Hindi binebenta ang " .. chosenItem .. " dito."})
		return
	end

	-- Give the item
	local itemModel = ItemsFolder:FindFirstChild(chosenItem)
	if itemModel then
		local clone = itemModel:Clone()
		clone.Parent = player:WaitForChild("Backpack")
		print("Gave " .. chosenItem .. " to " .. player.Name)
	else
		warn("Item missing in ReplicatedStorage.Items: " .. chosenItem)
	end

	TuronDialog:FireClient(player, {
		"Heto po ang " .. chosenItem .. ".",
		"Maraming salamat po! Bumalik ka na kay Turon."
	})
end)

-- ========================= CLEANUP =========================
Players.PlayerRemoving:Connect(function(player)
	playerProgress[player.UserId] = nil
end)
