local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local folder = Workspace:FindFirstChild("RPGEnemies") or Instance.new("Folder")
folder.Name, folder.Parent = "RPGEnemies", Workspace
local spawnPoints = {
    Vector3.new(24, 3, 0), Vector3.new(-24, 3, 0), Vector3.new(0, 3, 24),
    Vector3.new(0, 3, -24), Vector3.new(28, 3, 24), Vector3.new(-28, 3, -24),
}
local function spawnEnemy(position)
    local model = Instance.new("Model")
    model.Name = "Training Slime"
    model:SetAttribute("IsRPGEnemy", true)
    model:SetAttribute("RewardXP", 35)
    model:SetAttribute("RewardCoins", 14)
    local root = Instance.new("Part")
    root.Name, root.Shape = "HumanoidRootPart", Enum.PartType.Ball
    root.Size, root.Position = Vector3.new(4, 4, 4), position
    root.Color, root.Material = Color3.fromRGB(90, 205, 132), Enum.Material.SmoothPlastic
    root.Anchored, root.CanCollide = false, true
    root.Parent = model
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth, humanoid.Health = 75, 75
    humanoid.DisplayName = "Training Slime"
    humanoid.Parent = model
    model.PrimaryPart = root
    model.Parent = folder
    local glow = Instance.new("PointLight")
    glow.Color, glow.Range, glow.Brightness = root.Color, 9, 1.2
    glow.Parent = root
    humanoid.Died:Connect(function()
        root.Anchored = true
        task.delay(8, function()
            if model.Parent then model:Destroy() end
            spawnEnemy(position)
        end)
    end)
    local born = os.clock()
    task.spawn(function()
        while model.Parent and humanoid.Health > 0 and os.clock() - born < 60 do
            local closest, distance
            for _, player in ipairs(Players:GetPlayers()) do
                local character = player.Character
                local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = character and character:FindFirstChildOfClass("Humanoid")
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local current = (targetRoot.Position - root.Position).Magnitude
                    if current < (distance or 30) then closest, distance = targetRoot, current end
                end
            end
            if closest and distance > 5 then
                humanoid:MoveTo(closest.Position)
            elseif closest and distance <= 5 then
                local targetHumanoid = closest.Parent:FindFirstChildOfClass("Humanoid")
                if targetHumanoid then targetHumanoid:TakeDamage(5) end
                task.wait(1.5)
            end
            task.wait(0.45)
        end
        if model.Parent and humanoid.Health > 0 then
            model:Destroy()
            task.delay(1, function() spawnEnemy(position) end)
        end
    end)
end
for _, position in ipairs(spawnPoints) do spawnEnemy(position) end
