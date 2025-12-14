-- 🌉 Tulay ng Salita (Word Bridge) GUI Controller
-- Handles bridge feedback, text updates, and completion animation.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("WordBridgeGUI")
local frame = gui:WaitForChild("Frame")
local textLabel = frame:WaitForChild("TextLabel")

local failRemote = ReplicatedStorage:WaitForChild("Bridge_Fail")
local updateRemote = ReplicatedStorage:WaitForChild("Bridge_UpdateSentence")

frame.Visible = false
textLabel.TextTransparency = 0

local hiddenParts = {}
local questFinished = false

---------------------------------------------------
-- 🚪 Early exit if already done
---------------------------------------------------
if player:GetAttribute("WordBridgeDone") then
	print("[CLIENT] Player already completed Word Bridge — hiding GUI")
	gui.Enabled = false
	return
end

---------------------------------------------------
-- 🟥 Wrong step / wrong order
---------------------------------------------------
failRemote.OnClientEvent:Connect(function(part)
	if questFinished then return end

	if part and part:IsA("BasePart") then
		if hiddenParts[part] then return end
		hiddenParts[part] = {
			originalCFrame = part.CFrame,
			originalTransparency = part.Transparency,
			originalCollide = part.CanCollide
		}

		local tween = TweenService:Create(
			part,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{CFrame = part.CFrame * CFrame.new(0, -20, 0), Transparency = 1}
		)
		tween:Play()
		tween.Completed:Connect(function()
			part.CanCollide = false
		end)
	else
		print("[CLIENT] Wrong order! Teleporting back, not removing platform.")
	end
end)

---------------------------------------------------
-- ✅ Handle progress and completion
---------------------------------------------------
updateRemote.OnClientEvent:Connect(function(updatedText, progress, total, finished)
	warn("[CLIENT EVENT]", "updatedText =", updatedText, "progress =", progress, "finished =", finished)

	if questFinished and not finished then
		print("[CLIENT] Ignored late update — already finished")
		return
	end

	-- ✅ Show progress text normally
	if not finished then
		if updatedText and updatedText ~= "" then
			textLabel.Text = updatedText
			frame.Visible = true
			textLabel.TextTransparency = 0
			print("[CLIENT] Showing progress text:", updatedText)
		end
	else
		-- 🏁 Final completion logic
		questFinished = true
		print("[CLIENT] Quest finished — showing final sentence")

		-- Restore hidden wrong parts
		for part, original in pairs(hiddenParts) do
			if part and part:IsA("BasePart") then
				part.CFrame = original.originalCFrame
				part.Transparency = original.originalTransparency
				part.CanCollide = original.originalCollide
			end
		end
		hiddenParts = {}

		-- Show completion message
		frame.Visible = true
		frame.BackgroundTransparency = 0
		textLabel.TextTransparency = 0
		textLabel.Text = updatedText ~= "" and updatedText or "Natapos mo na!"

		-- Step 1️⃣: Wait 4 seconds to display final word
		task.wait(4)

		-- Step 2️⃣: Fade out current text then show final line
		local fadeOut = TweenService:Create(textLabel, TweenInfo.new(1), {TextTransparency = 1})
		fadeOut:Play()
		fadeOut.Completed:Wait()

		textLabel.Text = "Natapos mo na ang Tulay ng Salita, pwede ka na magpatuloy sa daan."
		local fadeIn = TweenService:Create(textLabel, TweenInfo.new(1), {TextTransparency = 0})
		fadeIn:Play()
		fadeIn.Completed:Wait()

		-- Step 3️⃣: Keep for 5 seconds, then fade all out smoothly
		task.wait(5)
		print("[CLIENT] Fading out final message...")

		local fadeOutText = TweenService:Create(textLabel, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1})
		local fadeOutFrame = TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})

		fadeOutText:Play()
		fadeOutFrame:Play()

		fadeOutText.Completed:Wait()
		fadeOutFrame.Completed:Wait()

		-- Hide GUI and reset
		frame.Visible = false
		frame.BackgroundTransparency = 0
		textLabel.TextTransparency = 0
		textLabel.Text = ""
		player:SetAttribute("WordBridgeDone", true)

		print("[CLIENT] GUI faded out successfully — quest done.")
	end
end)
