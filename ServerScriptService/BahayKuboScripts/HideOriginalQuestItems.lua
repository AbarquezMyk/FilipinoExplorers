local function hideItem(model)
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Transparency = 1
			obj.CanCollide = false
		end
	end
end

-- Wait for items to spawn
task.wait(1)

for _, item in ipairs(workspace:GetChildren()) do
	if item:GetAttribute("QuestItem") == true then
		hideItem(item)
	end
end
