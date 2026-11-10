local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage:WaitForChild("ClassConfig"))
local remotes = ReplicatedStorage:WaitForChild("RPGRemotes")
local attack, ability, chooseClass, notify = remotes.Attack, remotes.UseAbility, remotes.ChooseClass, remotes.Notify
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "AdventureHUD", false
gui.Parent = player:WaitForChild("PlayerGui")

local function label(parent, text, size, position, color)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency, item.Text, item.TextColor3 = 1, text, color or Color3.new(1, 1, 1)
    item.Font, item.TextSize, item.Size, item.Position = Enum.Font.GothamBold, size, UDim2.new(1, 0, 0, 28), position
    item.Parent = parent
    return item
end
local panel = Instance.new("Frame")
panel.Size, panel.Position, panel.BackgroundColor3 = UDim2.fromOffset(300, 145), UDim2.fromOffset(18, 18), Color3.fromRGB(22, 26, 40)
panel.BackgroundTransparency, panel.Parent = 0.1, gui
local title = label(panel, "ADVENTURE RPG", 20, UDim2.fromOffset(12, 8), Color3.fromRGB(255, 214, 115))
title.TextXAlignment = Enum.TextXAlignment.Left
local info = label(panel, "Loading...", 14, UDim2.fromOffset(12, 42), Color3.fromRGB(210, 220, 235))
info.TextXAlignment = Enum.TextXAlignment.Left
local barBack = Instance.new("Frame")
barBack.Size, barBack.Position, barBack.BackgroundColor3 = UDim2.new(1, -24, 0, 14), UDim2.fromOffset(12, 78), Color3.fromRGB(55, 60, 78)
barBack.Parent = panel
local bar = Instance.new("Frame")
bar.BackgroundColor3, bar.Size = Color3.fromRGB(75, 200, 115), UDim2.fromScale(0, 1)
bar.Parent = barBack
local help = label(panel, "Click to attack  •  Q: class ability", 12, UDim2.fromOffset(12, 104), Color3.fromRGB(165, 175, 195))
help.TextXAlignment = Enum.TextXAlignment.Left

local classPanel = Instance.new("Frame")
classPanel.Size, classPanel.Position, classPanel.BackgroundColor3 = UDim2.fromOffset(380, 70), UDim2.new(0.5, -190, 1, -90), Color3.fromRGB(22, 26, 40)
classPanel.BackgroundTransparency, classPanel.Parent = 0.1, gui
for index, className in ipairs({"Knight", "Ranger", "Mage"}) do
    local button = Instance.new("TextButton")
    button.Text, button.Font, button.TextSize = className, Enum.Font.GothamBold, 15
    button.TextColor3, button.BackgroundColor3 = Config.Classes[className].Color, Color3.fromRGB(43, 48, 67)
    button.Size, button.Position = UDim2.fromOffset(112, 42), UDim2.fromOffset(8 + (index - 1) * 124, 14)
    button.Parent = classPanel
    button.MouseButton1Click:Connect(function() chooseClass:FireServer(className) end)
end
local toast = label(gui, "", 18, UDim2.new(0.5, -250, 0, 180), Color3.fromRGB(255, 235, 150))
toast.Size = UDim2.fromOffset(500, 35)
toast.TextStrokeTransparency = 0.4
notify.OnClientEvent:Connect(function(text)
    toast.Text = text
    task.delay(3, function() if toast.Text == text then toast.Text = "" end end)
end)
local function update()
    local stats = player:FindFirstChild("leaderstats")
    local className = player:GetAttribute("Class") or "Knight"
    if stats then
        local needed = stats.Level.Value * 100
        info.Text = string.format("%s  |  Level %d  |  %d coins  |  %d/%d XP", className, stats.Level.Value, stats.Coins.Value, stats.XP.Value, needed)
        bar.Size = UDim2.fromScale(math.clamp(stats.XP.Value / needed, 0, 1), 1)
    end
end
RunService.RenderStepped:Connect(update)
mouse.Button1Down:Connect(function() attack:FireServer(mouse.Hit.Position) end)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Q then ability:FireServer(mouse.Hit.Position) end
end)
