local char = script.Parent
local replicated = game:GetService("ReplicatedStorage")
local NameGui = replicated.NameGUI
local Players = game:GetService("Players")

local nameClone = NameGui:Clone()

local displayName = char.Name -- fallback to character name
for _, player in Players:GetPlayers() do
    if player.Character == char then
        displayName = player.DisplayName
        break
    end
end

nameClone.name.Text = displayName
nameClone.Adornee = char.Head
nameClone.Parent = char.Head

local human = char:WaitForChild("Humanoid")

human.DisplayDistanceType = "None"

