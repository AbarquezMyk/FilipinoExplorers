-- ServerScriptService/HideSpawnPoints.lua
local spawnParent = workspace:WaitForChild("Games"):WaitForChild("Bahay Kubo Builder"):WaitForChild("ItemsSpawnPoints")

for _, p in ipairs(spawnParent:GetChildren()) do
	if p:IsA("BasePart") then
		p.Transparency = 1
		p.CanCollide = false
		p.Anchored = true
	end
end
