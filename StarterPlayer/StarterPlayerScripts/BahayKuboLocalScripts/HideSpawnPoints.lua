local spawnFolder = workspace:WaitForChild("Games"):WaitForChild("Bahay Kubo Builder"):WaitForChild("ItemsSpawnPoints")

for _, p in ipairs(spawnFolder:GetChildren()) do
	if p:IsA("BasePart") then
		p.Transparency = 1
		p.CanCollide = false
	end
end
