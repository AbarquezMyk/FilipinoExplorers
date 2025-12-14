local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SellerDialog = ReplicatedStorage:WaitForChild("SellerDialog")
local BuyFromStall = ReplicatedStorage:WaitForChild("BuyFromStall")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = playerGui:WaitForChild("SellerGui")  -- your GUI
local frame = gui:WaitForChild("Frame")
local layout = frame:WaitForChild("UIListLayout") -- where buttons will go

-- Clear old buttons
local function clearButtons()
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

-- Show stall options
SellerDialog.OnClientEvent:Connect(function(items, stallName)
	clearButtons()
	frame.Visible = true

	for _, itemName in ipairs(items) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, -10, 0, 50)
		button.Text = "Pabili po ng " .. itemName
		button.TextSize = 20
		button.Parent = frame
		button.LayoutOrder = layout:GetChildren() and #layout:GetChildren() or 0

		-- When player clicks button, fire RemoteEvent
		button.MouseButton1Click:Connect(function()
			print(player.Name .. " clicked to buy " .. itemName)
			BuyFromStall:FireServer(itemName, stallName)
			frame.Visible = false
		end)
	end
end)
