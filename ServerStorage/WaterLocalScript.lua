local RS = game:GetService("ReplicatedStorage")
local UseConsumable = RS:WaitForChild("UseConsumable")
local tool = script.Parent
local uses = 1

tool.Activated:Connect(function()
	if uses <= 0 then return end
	uses -= 1

	-- Send the tool's actual name to the server for processing & cleanup
	UseConsumable:FireServer(tool.Name)

	-- small delay then destroy locally (client)
	if uses <= 0 then
		wait(0.05)
		if tool and tool.Parent then
			tool:Destroy()
		end
	end
end)
