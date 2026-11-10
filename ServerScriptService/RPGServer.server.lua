local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("ClassConfig"))
local remotes = ReplicatedStorage:FindFirstChild("RPGRemotes") or Instance.new("Folder")
remotes.Name = "RPGRemotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
    local item = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
    item.Name = name
    item.Parent = remotes
    return item
end

local chooseClass = remote("ChooseClass")
local attack = remote("Attack")
local useAbility = remote("UseAbility")
local notify = remote("Notify")
local saveStore = DataStoreService:GetDataStore("AdventureRPG_v1")
local lastAttack, lastAbility, saving = {}, {}, {}

local function message(player, text)
    notify:FireClient(player, text)
end

local function setupStats(player, data)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    for _, name in ipairs({"Level", "Coins", "XP"}) do
        local value = Instance.new("IntValue")
        value.Name = name
        value.Value = math.max(0, math.floor(tonumber(data[name]) or (name == "Level" and 1 or 0)))
        value.Parent = leaderstats
    end
    player:SetAttribute("Class", Config.Classes[data.Class] and data.Class or "Knight")
    player:SetAttribute("AbilityReady", true)
end

local function save(player)
    if saving[player] then return end
    saving[player] = true
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local payload = {Class = player:GetAttribute("Class") or "Knight"}
        for _, name in ipairs({"Level", "Coins", "XP"}) do
            payload[name] = stats[name].Value
        end
        pcall(function() saveStore:SetAsync(tostring(player.UserId), payload) end)
    end
    saving[player] = nil
end

local function applyClass(player, character)
    local class = Config.Classes[player:GetAttribute("Class") or "Knight"] or Config.Classes.Knight
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    humanoid.MaxHealth = class.MaxHealth
    humanoid.Health = class.MaxHealth
end

Players.PlayerAdded:Connect(function(player)
    local data = {}
    local ok, stored = pcall(function() return saveStore:GetAsync(tostring(player.UserId)) end)
    if ok and type(stored) == "table" then data = stored end
    setupStats(player, data)
    player.CharacterAdded:Connect(function(character) applyClass(player, character) end)
    if player.Character then task.spawn(applyClass, player, player.Character) end
end)
Players.PlayerRemoving:Connect(function(player)
    save(player)
    lastAttack[player], lastAbility[player] = nil, nil
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do task.spawn(save, player) end
    task.wait(2)
end)

chooseClass.OnServerEvent:Connect(function(player, name)
    if type(name) ~= "string" or not Config.Classes[name] then return end
    player:SetAttribute("Class", name)
    if player.Character then applyClass(player, player.Character) end
    message(player, "Class changed to " .. name)
end)

local function targetsInRange(player, range)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    local results = {}
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:GetAttribute("IsRPGEnemy") then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local enemyRoot = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
            if humanoid and humanoid.Health > 0 and enemyRoot and (enemyRoot.Position - root.Position).Magnitude <= range then
                table.insert(results, {Model = model, Humanoid = humanoid, Root = enemyRoot})
            end
        end
    end
    table.sort(results, function(a, b)
        return (a.Root.Position - root.Position).Magnitude < (b.Root.Position - root.Position).Magnitude
    end)
    return results
end

local function damageEnemy(player, target, amount)
    if not target or not target.Humanoid or target.Humanoid.Health <= 0 then return end
    local before = target.Humanoid.Health
    target.Humanoid:TakeDamage(amount)
    if before > 0 and target.Humanoid.Health <= 0 and not target.Model:GetAttribute("Rewarded") then
        target.Model:SetAttribute("Rewarded", true)
        local stats = player:FindFirstChild("leaderstats")
        if not stats then return end
        local xp = math.max(1, tonumber(target.Model:GetAttribute("RewardXP")) or 30)
        local coins = math.max(0, tonumber(target.Model:GetAttribute("RewardCoins")) or 12)
        stats.XP.Value += xp
        stats.Coins.Value += coins
        local needed = stats.Level.Value * 100
        while stats.XP.Value >= needed do
            stats.XP.Value -= needed
            stats.Level.Value += 1
            needed = stats.Level.Value * 100
            message(player, "Level up! You are now level " .. stats.Level.Value)
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth += 8
                humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 35)
            end
        end
        message(player, "+" .. xp .. " XP  +" .. coins .. " coins")
    end
end

attack.OnServerEvent:Connect(function(player, requestedPosition)
    if typeof(requestedPosition) ~= "Vector3" then return end
    local class = Config.Classes[player:GetAttribute("Class") or "Knight"] or Config.Classes.Knight
    local now = os.clock()
    if now - (lastAttack[player] or 0) < class.Cooldown then return end
    lastAttack[player] = now
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then return end
    local direction = requestedPosition - root.Position
    if direction.Magnitude > 0.1 then root.CFrame = CFrame.lookAt(root.Position, root.Position + Vector3.new(direction.X, 0, direction.Z)) end
    local targets = targetsInRange(player, class.Range)
    local maxTargets = class.Range < 15 and 3 or 1
    for index = 1, math.min(maxTargets, #targets) do damageEnemy(player, targets[index], class.Damage) end
end)

useAbility.OnServerEvent:Connect(function(player, requestedPosition)
    if typeof(requestedPosition) ~= "Vector3" then return end
    local className = player:GetAttribute("Class") or "Knight"
    local class = Config.Classes[className]
    local now = os.clock()
    if now - (lastAbility[player] or 0) < class.AbilityCooldown then return end
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then return end
    lastAbility[player] = now
    local targets = targetsInRange(player, class.Range)
    if className == "Knight" then
        for index = 1, math.min(7, #targets) do damageEnemy(player, targets[index], class.Damage * 1.7) end
    elseif className == "Ranger" then
        for index = 1, math.min(3, #targets) do damageEnemy(player, targets[index], class.Damage * 1.15) end
    else
        local center = requestedPosition
        if (center - root.Position).Magnitude > class.Range then center = root.Position + (center - root.Position).Unit * class.Range end
        for _, target in ipairs(targets) do
            if (target.Root.Position - center).Magnitude <= 16 then damageEnemy(player, target, class.Damage * 2) end
        end
        local effect = Instance.new("Part")
        effect.Shape, effect.Anchored, effect.CanCollide = Enum.PartType.Ball, true, false
        effect.Material, effect.Color, effect.Transparency = Enum.Material.Neon, class.Color, 0.35
        effect.Size, effect.CFrame = Vector3.new(32, 32, 32), CFrame.new(center)
        effect.Parent = workspace
        Debris:AddItem(effect, 0.25)
    end
end)
