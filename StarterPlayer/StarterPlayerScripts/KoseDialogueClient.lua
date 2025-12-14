-- KoseDialogueClient (updated LocalScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local StartQuest = ReplicatedStorage:WaitForChild("StartQuest")
local RequestStartQuest = ReplicatedStorage:WaitForChild("RequestStartQuest")
local UpdateQuest = ReplicatedStorage:WaitForChild("UpdateQuest")
local QuestFinished = ReplicatedStorage:WaitForChild("QuestFinished")

-- UI (create these in StarterGui exactly as named)
local playerGui = player:WaitForChild("PlayerGui")
local koseGui = playerGui:WaitForChild("KoseGUI") -- ScreenGui
local frame = koseGui:WaitForChild("Frame")       -- Frame inside KoseGUI
local label = frame:WaitForChild("TextLabel")    -- TextLabel
local acceptButton = frame:WaitForChild("TextButton") -- "Tara laro tayo!"

-- === Quest State ===
local GOAL_DEFAULT = 10
local questActive = false
local goalKicks = GOAL_DEFAULT
local kickCount = 0

local filipinoNumbers = {
	[1] = "Isa",[2] = "Dalawa",[3] = "Tatlo",[4] = "Apat",[5] = "Lima",
	[6] = "Anim",[7] = "Pito",[8] = "Walo",[9] = "Siyam",[10] = "Sampu"
}

frame.Visible = false
acceptButton.Visible = false

-- Helper: reset camera properly
local function resetCamera()
	local camera = workspace.CurrentCamera
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		camera.CameraSubject = char:WaitForChild("Humanoid")
	end
	camera.CameraType = Enum.CameraType.Custom

	pcall(function()
		player.CameraMinZoomDistance = 5
		player.CameraMaxZoomDistance = 20
		player.CameraMode = Enum.CameraMode.Classic
	end)
end

-- small helper: hide frame after n seconds (safe)
local function hideFrameAfter(seconds)
	task.delay(seconds, function()
		if frame and frame.Visible then
			frame.Visible = false
			acceptButton.Visible = false
		end
	end)
end

-- === Handle Quest Events from Server ===
StartQuest.OnClientEvent:Connect(function(eventType, payload)
	frame.Visible = true

	if eventType == "dialogue" then
		acceptButton.Visible = false
		label.Text = payload or ""

		-- auto-hide if "Magaling" appears
		if payload and string.find(string.lower(payload), "magaling") then
			hideFrameAfter(3)
		end

	elseif eventType == "offer" then
		label.Text = payload or ""
		acceptButton.Visible = true

	elseif eventType == "start" then
		goalKicks = payload or GOAL_DEFAULT
		kickCount = 0
		questActive = true
		label.Text = "Maglaro ng Sipa! Sipain mo ito ng " .. tostring(goalKicks) .. " beses.\n(I-click ang tool.)"
		acceptButton.Visible = false

	elseif eventType == "complete" then
		label.Text = payload or "Natapos!"
		acceptButton.Visible = false
		hideFrameAfter(3)

	elseif eventType == "endDialogue" then
		-- cleanly hide the dialogue
		frame.Visible = false
		acceptButton.Visible = false
	end
end)

-- === Accept button clicked ===
acceptButton.MouseButton1Click:Connect(function()
	acceptButton.Visible = false
	label.Text = "Handa! Agarang ihahanda..."
	RequestStartQuest:FireServer("sipaQuest")
end)

-- === Update progress (server tells us kicks) ===
UpdateQuest.OnClientEvent:Connect(function(kicks, goal)
	goalKicks = goal or goalKicks
	if not questActive then return end

	kickCount = kicks or kickCount
	local numberWord = filipinoNumbers[kickCount] or tostring(kickCount)

	label.Text = numberWord .. " (" .. tostring(kickCount) .. "/" .. tostring(goalKicks) .. ")"

	if kickCount >= goalKicks then
		task.wait(2)
		questActive = false

		task.delay(2, function()
			if label.Text == numberWord .. " (" .. tostring(kickCount) .. "/" .. tostring(goalKicks) .. ")" then
				label.Text = "Natapos mo ang sipa quest! Bumalik kay Kose."
			end
			resetCamera()
			QuestFinished:FireServer()
		end)
	end
end)

-- === Optional: if server fires QuestFinished back to client ===
QuestFinished.OnClientEvent:Connect(function()
	resetCamera()
	hideFrameAfter(3)
end)
