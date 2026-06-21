local function GetMobs()
    local mobs, added, Alive = {}, {}, Workspace:FindFirstChild("Alive")
    if not Alive then return mobs end
    local players = {}
    for _, p in ipairs(Players:GetPlayers()) do players[p.Name] = true end
    for _, m in ipairs(Alive:GetChildren()) do
        if m and m.Name and not players[m.Name] and not added[m.Name] then
            added[m.Name] = true
            table.insert(mobs, m.Name)
        end
    end
    table.sort(mobs)
    return mobs
end

-- ====== GET MOBS ======
local function GetBosses()
    local bosses, added = {}, {}
    local Alive = workspace:FindFirstChild("Alive")
    if not Alive then return bosses end
    
    local players = {}
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        players[player.Name] = true
    end
    
    for _, mob in ipairs(Alive:GetChildren()) do
        if mob and mob.Name then
            if not players[mob.Name] and not added[mob.Name] then
                if mob.Name == "Lv20000 Whitebeard" or 
                   mob.Name == "Lv2000 Vokun" or 
                   mob.Name == "Lv2000 Crocodile" then
                    added[mob.Name] = true
                    table.insert(bosses, mob.Name)
                end
            end
        end
    end
    table.sort(bosses)
    return bosses
end

-- ====== UI SETUP ======
local MobDropdown = Tabs.Farm:AddDropdown("MobSelectFinalUltimate", {
    Title = "Select Mob", Values = GetMobs(), Multi = true, Default = {},
})
MobDropdown:OnChanged(function(Value) 
    if Value ~= nil then 
        _G.SelectedMobs = Value 
    end
end)

local BossDropdown = Tabs.Farm:AddDropdown("BossSelect", {
    Title = "Select Boss", Values = GetBosses(), Multi = true, Default = {},
})
BossDropdown:OnChanged(function(Value) 
    if Value ~= nil then 
        _G.SelectedBosses = Value 
    end
end)

Tabs.Farm:AddDropdown("FarmModeSelect", {
    Title = "Chế độ Farm",
    Values = {"Đứng trên cao", "Đứng kế bên", "Dưới lòng đất"},
    Default = "Đứng kế bên",
    Callback = function(Value) 
        if Value ~= nil then _G.FarmMode = Value end
    end
})

Tabs.Farm:AddButton({ Title = "Refresh Mob", Callback = function()
    MobDropdown:SetValues(GetMobs())
    BossDropdown:SetValues(GetBosses())
end })

Tabs.Farm:AddToggle("FarmToggleFinalUltimate", {
    Title = "Auto Farm", Default = false
}):OnChanged(function(Value) 
    if Value ~= nil then 
        _G.IsAutoFarmEnabled = Value 
    end
end)

Tabs.Farm:AddToggle("BossFarmToggle", {
    Title = "Auto Farm Boss", Default = false
}):OnChanged(function(Value) 
    if Value ~= nil then 
        _G.IsBossFarmEnabled = Value 
    end
end)

-- ====== FIND TARGET ======
local function FindNearestTarget(myHRP, isBoss)
    if not myHRP then return nil end
    local Alive = workspace:FindFirstChild("Alive")
    if not Alive then return nil end
    
    local selectedTable = isBoss and _G.SelectedBosses or _G.SelectedMobs
    if not selectedTable or type(selectedTable) ~= "table" then return nil end
    
    local mobLookup = {}
    local hasSelected = false
    for mobName, isSelected in pairs(selectedTable) do
        if isSelected then 
            mobLookup[mobName] = true 
            hasSelected = true
        end
    end
    if not hasSelected then return nil end
    
    local nearestMob, shortestDistance = nil, math.huge
    for _, mob in ipairs(Alive:GetChildren()) do
        if mob and mob.Name and mobLookup[mob.Name] then
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            local hum = mob:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (myHRP.Position - hrp.Position).Magnitude
                if d < shortestDistance then
                    shortestDistance = d
                    nearestMob = mob
                end
            end
        end
    end
    return nearestMob
end

-- ====== AUTO RESPAWN ======
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.IsAutoFarmEnabled or _G.IsBossFarmEnabled then
            local char = LocalPlayer.Character
            local myHum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or (myHum and myHum.Health <= 0) then
                pcall(function() LocalPlayer:LoadCharacter() end)
                task.wait(2)
            else
                if not char:FindFirstChildOfClass("Tool") then
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    local tool = backpack and backpack:FindFirstChildOfClass("Tool")
                    if tool and myHum then
                        myHum:EquipTool(tool)
                    end
                end
            end
        end
    end
end)

-- ====== AUTO CLICK ======
task.spawn(function()
    while true do
        task.wait(0.01)
        if _G.IsAutoFarmEnabled or _G.IsBossFarmEnabled then
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function()
                    tool:Activate()
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(999, 999))
                end)
            end
        end
    end
end)

-- ====== DISABLE COLLISION ======
local function DisableCollision(char)
    if not char then return end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

-- ====== KÉO QUÁI VỀ PHÍA MÌNH ======
local function PullMobsToPlayer(origin, radius, isBoss)
    local Alive = workspace:FindFirstChild("Alive")
    if not Alive then return end

    local selectedTable = isBoss and _G.SelectedBosses or _G.SelectedMobs
    if not selectedTable or type(selectedTable) ~= "table" then return end

    local mobLookup = {}
    local hasSelected = false
    for mobName, isSelected in pairs(selectedTable) do
        if isSelected then 
            mobLookup[mobName] = true 
            hasSelected = true
        end
    end
    if not hasSelected then return end

    local count = 0
    local maxPull = 8 -- Giới hạn số quái kéo để tránh lag
    
    for _, mob in ipairs(Alive:GetChildren()) do
        if count >= maxPull then break end
        if not mob or not mob.Name then continue end
        if not mobLookup[mob.Name] then continue end

        local mobHRP = mob:FindFirstChild("HumanoidRootPart")
        local mobHum = mob:FindFirstChildOfClass("Humanoid")
        if not mobHRP or not mobHum or mobHum.Health <= 0 then continue end

        local dist = (mobHRP.Position - origin.Position).Magnitude
        if dist <= radius then
            -- Kéo quái về xung quanh người chơi
            local angle = math.random() * 2 * math.pi
            local radiusOffset = 3 + math.random() * 2
            local targetPos = origin.Position + Vector3.new(
                math.cos(angle) * radiusOffset,
                1,
                math.sin(angle) * radiusOffset
            )
            mobHRP.CFrame = CFrame.new(targetPos)
            mobHRP.AssemblyLinearVelocity = Vector3.zero
            count = count + 1
        end
    end
end

-- ====== DI CHUYỂN ======
local PullRadius = 150 -- Bán kính kéo quái
local LastPullTime = 0
local PullCooldown = 2 -- Cooldown 2 giây để tránh spam

RunService.Heartbeat:Connect(function()
    if not _G.IsAutoFarmEnabled and not _G.IsBossFarmEnabled then return end
    
    local char = LocalPlayer.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    DisableCollision(char)

    local targetMob
    if _G.IsBossFarmEnabled then
        targetMob = FindNearestTarget(myHRP, true)
    end
    
    if not targetMob and _G.IsAutoFarmEnabled then
        targetMob = FindNearestTarget(myHRP, false)
    end
    
    if targetMob then
        local mobHRP = targetMob:FindFirstChild("HumanoidRootPart")
        if mobHRP then
            local bossPos = mobHRP.Position
            
            if _G.FarmMode == "Dưới lòng đất" then
                local depth = 5
                local targetPos = Vector3.new(
                    bossPos.X,
                    bossPos.Y + depth,
                    bossPos.Z
                )
                myHRP.CFrame = CFrame.lookAt(targetPos, bossPos)
                myHRP.AssemblyLinearVelocity = Vector3.zero
                
            elseif _G.FarmMode == "Đứng trên cao" then
                local targetPos = Vector3.new(
                    bossPos.X,
                    bossPos.Y + 5,
                    bossPos.Z
                )
                myHRP.CFrame = CFrame.lookAt(targetPos, bossPos)
                myHRP.AssemblyLinearVelocity = Vector3.zero
                
            else
                local offset = _G.OffsetDistance or 5
                local targetPos = Vector3.new(
                    bossPos.X + offset,
                    bossPos.Y,
                    bossPos.Z
                )
                myHRP.CFrame = CFrame.lookAt(targetPos, bossPos)
                myHRP.AssemblyLinearVelocity = Vector3.zero
            end
            
            -- Kéo quái về phía mình mỗi khi di chuyển đến target mới
            if tick() - LastPullTime >= PullCooldown then
                local isBossMode = _G.IsBossFarmEnabled
                PullMobsToPlayer(myHRP, PullRadius, isBossMode)
                LastPullTime = tick()
            end
        end
    end
end)

-- ====== AUTO FARM ROAM ======
local FarmRadius = 150
local TeleportDelay = 0.1

local FarmSpots = {}
local CurrentSpotIndex = 1

local function FindNearestMobInRadius(origin, radius, isBoss)
    local Alive = workspace:FindFirstChild("Alive")
    if not Alive then return nil end

    local selectedTable = isBoss and _G.SelectedBosses or _G.SelectedMobs
    if not selectedTable or type(selectedTable) ~= "table" then return nil end

    local mobLookup = {}
    local hasSelected = false
    for mobName, isSelected in pairs(selectedTable) do
        if isSelected then 
            mobLookup[mobName] = true 
            hasSelected = true
        end
    end
    if not hasSelected then return nil end

    local nearest = nil
    local minDist = radius
    
    for _, mob in ipairs(Alive:GetChildren()) do
        if not mob or not mob.Name then continue end
        if not mobLookup[mob.Name] then continue end

        local hrp = mob:FindFirstChild("HumanoidRootPart")
        local hum = mob:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local d = (hrp.Position - origin.Position).Magnitude
            if d < minDist then
                minDist = d
                nearest = mob
            end
        end
    end
    
    return nearest
end

local function MoveToPosition(targetCF, hrp)
    if not hrp then return end
    hrp.CFrame = targetCF
    hrp.AssemblyLinearVelocity = Vector3.zero
end

task.spawn(function()
    while true do
        if not _G.IsAutoFarmEnabled and not _G.IsBossFarmEnabled then
            task.wait(0.5)
            continue
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            task.wait(1)
            continue
        end

        local isBossMode = _G.IsBossFarmEnabled
        local targetMob = FindNearestMobInRadius(hrp, FarmRadius, isBossMode)
        
        if not targetMob and not isBossMode and _G.IsAutoFarmEnabled then
            targetMob = FindNearestMobInRadius(hrp, FarmRadius, false)
        end
        
        if targetMob then
            local mobPos = targetMob:FindFirstChild("HumanoidRootPart")
            if mobPos then
                local moveCF = CFrame.new(mobPos.Position + Vector3.new(0, 1, 0)) * CFrame.new(0, 0, 5)
                MoveToPosition(moveCF, hrp)
            end
            task.wait(0.3)
        else
            if (_G.IsAutoFarmEnabled or _G.IsBossFarmEnabled) and #FarmSpots > 0 then
                CurrentSpotIndex = CurrentSpotIndex % #FarmSpots + 1
                local nextSpot = FarmSpots[CurrentSpotIndex]
                MoveToPosition(nextSpot + Vector3.new(0, 5, 0), hrp)
                task.wait(TeleportDelay)
            end
        end
        task.wait(0.1)
    end
end)
-- ====== AUTO EQUIP WEAPON ======
local function GetWeapons()
    local list, seen = {}, {}
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local char = LocalPlayer.Character
    for _, src in ipairs({backpack, char}) do
        if src then
            for _, v in ipairs(src:GetChildren()) do
                if v:IsA("Tool") and not seen[v.Name] then
                    seen[v.Name] = true
                    table.insert(list, v.Name)
                end
            end
        end
    end
    table.sort(list)
    return list
end

local WeaponDropdown = Tabs.Farm:AddDropdown("WeaponSelect", {
    Title = "Select Weapon", Values = GetWeapons(), Multi = false, Default = nil,
})
WeaponDropdown:OnChanged(function(Value) 
    if Value ~= nil then _G.SelectedWeapon = Value end
end)

Tabs.Farm:AddButton({ Title = "Refresh Weapon", Callback = function()
    WeaponDropdown:SetValues(GetWeapons())
end })

Tabs.Farm:AddToggle("AutoEquipWeapon", {
    Title = " Auto Equip Weapon", Default = false,
}):OnChanged(function(Value) 
    if Value ~= nil then _G.AutoEquipWeapon = Value end
end)

task.spawn(function()
    while true do
        if not _G.AutoEquipWeapon or not _G.SelectedWeapon then task.wait(0.3); continue end
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if hum and hum.Health > 0 and backpack then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") and item.Name ~= _G.SelectedWeapon then
                    item.Parent = backpack
                end
            end
            if not char:FindFirstChild(_G.SelectedWeapon) then
                local tool = backpack:FindFirstChild(_G.SelectedWeapon)
                if tool and tool:IsA("Tool") then
                    tool.Parent = char
                    task.wait(0.02)
                end
            end
        end
        task.wait(0.01)
    end
end)

-- ====== THÊM VÀO ĐẦU SCRIPT ======
-- ====== WHITEBEARD FARM ======

Tabs.Farm:AddSection("Skill Setting")
-- ====== AUTO SKILL ======
Tabs.Farm:AddDropdown("SkillKeys", {
    Title = "Select Bind",
    Values = {"Z","X","C","V","B","Q","R","T","E","N","G","F","H","J","K","L"},
    Multi = true, Default = {},
}):OnChanged(function(Value) 
    if Value ~= nil then _G.SelectedKeys = Value end
end)

Tabs.Farm:AddToggle("AutoSkillSpam", {
    Title = "Auto Skill", Default = false,
}):OnChanged(function(Value) 
    if Value ~= nil then _G.AutoSkillSpam = Value end
end)

task.spawn(function()
    while task.wait(0.05) do
        if not _G.AutoSkillSpam then continue end
        for KeyName, Enabled in pairs(_G.SelectedKeys) do
            if Enabled and Enum.KeyCode[KeyName] then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[KeyName], false, game)
                task.wait(0.03)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[KeyName], false, game)
            end
        end
    end
end)

-- ====== AUTO HOLD SKILL ======
Tabs.Farm:AddDropdown("HoldSkillKeys", {
    Title = "Select Bind",
    Values = {"Z","X","C","V","B","Q","R","T","E","N","G","F","H","J","K","L"},
    Multi = true, Default = {},
}):OnChanged(function(v) 
    if v ~= nil then _G.HoldKeys = v end
end)

Tabs.Farm:AddToggle("AutoHoldSkill", {
    Title = "Auto Hold Skill", Default = false,
}):OnChanged(function(v) 
    if v ~= nil then _G.HoldEnabled = v end
end)

Tabs.Farm:AddInput("HoldTimeInput", {
    Title = "Set Time",
    Default = "1",
    Placeholder = "1.0",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        _G.HoldTime = tonumber(v) or 1
    end
})

task.spawn(function()
    while task.wait(0.1) do
        if not _G.HoldEnabled then continue end
        for key, enabled in pairs(_G.HoldKeys) do
            if not _G.HoldEnabled then break end
            if enabled then
                local k = Enum.KeyCode[key]
                if k then
                    VirtualInputManager:SendKeyEvent(true, k, false, game)
                    task.wait(_G.HoldTime)
                    VirtualInputManager:SendKeyEvent(false, k, false, game)
                    task.wait(0.1)
                end
            end
        end
    end
end)

-- ====== TELEPORT LOCATIONS ======
local tpLocations = {
    ["Đảo tân thủ"] = CFrame.new(-80, 216, -296),
    ["Cave"] = CFrame.new(2210, 216, -611),
    ["Admin tặng quà"] = CFrame.new(-32.60, 200003, 195),
    ["Đảo Sam"] = CFrame.new(-1279, 218, -1351),
    ["Đảo cát lâu đài"] = CFrame.new(1231, 224, -3242),
    ["Nhiệm Vụ Box Fish"] = CFrame.new(-1693, 216, -328),
    ["Đảo Tím"] = CFrame.new(-5224, 518, -7779),
    ["Đảo tuyết to"] = CFrame.new(6313, 541, -1330),
    ["Đảo tuyết"] = CFrame.new(-1858, 297, 3156),
    ["Đảo tôn ngộ không"] = CFrame.new(4571, 226, 5110),
    ["Đảo nhà có cây"] = CFrame.new(1120, 217, 3351),
    ["Đảo cây lớn"] = CFrame.new(-5996, 362, -10),
    ["Bãi đá"] = CFrame.new(-971, 535, 11329),
    ["Kuimui"] = CFrame.new(-10776, 354, 5989),
    ["Đảo trống"] = CFrame.new(-11635, 276, -3827),
    ["Ai cập"] = CFrame.new(786, 286, 5502),
    ["Tháp hải đăng"] = CFrame.new(2086, 288, -1876),
    ["Chiến sự"] = CFrame.new(4395, 319, -3259),
    ["vỏ óc"] = CFrame.new(4759, 570, -7191),
    ["Đảo hải quân"] = CFrame.new(-3019, 217, -3076),
}
local selectedTP = nil

local TPDropdown = Tabs.Map:AddDropdown("TeleportSelect", {
    Title = "Island",
    Values = (function()
        local list = {}
        for name in pairs(tpLocations) do table.insert(list, name) end
        table.sort(list); return list
    end)(),
    Multi = false, Default = nil,
})
TPDropdown:OnChanged(function(value) 
    if value ~= nil then selectedTP = value end
end)

Tabs.Map:AddButton({ Title = "Teleport", Callback = function()
    if not selectedTP then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and tpLocations[selectedTP] then
        hrp.CFrame = tpLocations[selectedTP] + Vector3.new(0, 3, 0)
    end
end })

-- ====== TELEPORT NPC ======
local tpnpc = {
    ["C0"] = CFrame.new(902, 269, 1222),
    ["Cooker"] = CFrame.new(1982, 217, 567),
    ["Fisherman"] = CFrame.new(-1699, 215, -327),
    ["Gemologist"] = CFrame.new(-1235, 217, 634),
    ["Sam"] = CFrame.new(-1304, 217, -1351),
    ["Bart Nospmis"] = CFrame.new(-432, 216, -174),
    ["Bandit Leader"] = CFrame.new(33, 295, -826),
    ["Chill Billy"] = CFrame.new(35, 232, -193),
    ["Demon Hunter"] = CFrame.new(-51, 217, -914),
    ["Explorer"] = CFrame.new(-520, 217, -892),
    ["Fallen Captain"] = CFrame.new(-237, 218, -866),
    ["Guard Captain"] = CFrame.new(-50, 262, 332),
    ["Joe"] = CFrame.new(-58, 215, -317),
    ["Marge Nospmis"] = CFrame.new(-102, 223, -76),
    ["Old Beggar"] = CFrame.new(186, 217, -141),
    ["Rayleigh"] = CFrame.new(-1010, 4010, 10132),
    ["Traceur"] = CFrame.new(-294, 310, -580),
    ["Ana"] = CFrame.new(1110, 216, 3366),
    ["Better Drink Merchant"] = CFrame.new(1490, 260, 2170),
    ["Dancer"] = CFrame.new(1520, 260, 2162),
    ["Drink Merchant"] = CFrame.new(-1282, 218, -1368),
    ["Kiruma"] = CFrame.new(-1072, 361, 1665),
    ["Lucy"] = CFrame.new(799, 230, 5351),
    ["Mad Scientist"] = CFrame.new(-2602, 255, 1088),
    ["Sniper Merchant"] = CFrame.new(-1844, 222, 3412),
    ["Sword Merchant"] = CFrame.new(998, 223, -3337),
}
local selectedTPs = nil

local NPCDropdown = Tabs.Map:AddDropdown("NPCTeleportSelect", {
    Title = "NPC",
    Values = (function()
        local list = {}
        for name in pairs(tpnpc) do table.insert(list, name) end
        table.sort(list); return list
    end)(),
    Multi = false, Default = nil,
})
NPCDropdown:OnChanged(function(value) 
    if value ~= nil then selectedTPs = value end
end)

Tabs.Map:AddButton({ Title = "Teleport NPC", Callback = function()
    if not selectedTPs then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and tpnpc[selectedTPs] then
        hrp.CFrame = tpnpc[selectedTPs] + Vector3.new(0, 3, 0)
    end
end })

-- ====== AUTO FARM CHESTS ======
local function instantTouch(part)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root and part and firetouchinterest then
        firetouchinterest(root, part, 0)
        task.wait()
        firetouchinterest(root, part, 1)
    end
end

Tabs.Main:AddToggle("AutoFarmChests", {
    Title = "Auto Farm Chest", Default = false,
}):OnChanged(function(v)
    if v ~= nil then _G.AutoFarmChests = v end
    if v then
        task.spawn(function()
            while _G.AutoFarmChests do
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    for _, object in pairs(Workspace:GetDescendants()) do
                        if not _G.AutoFarmChests then break end
                        if object.Name == "Chest" or object.Name:find("Chest") then
                            local targetPart = (object:IsA("BasePart") and object) or object:FindFirstChildWhichIsA("BasePart")
                            if targetPart and targetPart:IsDescendantOf(Workspace) then
                                if (rootPart.Position - targetPart.Position).Magnitude > 3 then
                                    rootPart.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 2, 0))
                                    rootPart.Velocity = Vector3.new(0, 0, 0)
                                    rootPart.RotVelocity = Vector3.new(0, 0, 0)
                                end
                                instantTouch(targetPart)
                            end
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    end
end)

-- ====== AUTO FARM STATS ======
local TargetNames = { barrel = true, crate = true, bowl = true }
local DrinkList = {
    ["Apple Juice"] = true, ["Sour Juice"] = true, ["Pumpkin Juice"] = true,
    ["Fruit Juice"] = true, ["Banana Juice"] = true, ["Golden Apple"] = true,
    ["Coconut Milk"] = true, ["Pear Juice"] = true,
}

local function GetChar() return LocalPlayer.Character end

RunService.Heartbeat:Connect(function()
    if _G.Running then
        local char = GetChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

local function fastUse(tool)
    if not tool or not tool:IsA("Tool") then return end
    local char = GetChar()
    if tool.Parent ~= char then tool.Parent = char; task.wait(0.1) end
    pcall(function() tool:Activate() end)
end

task.spawn(function()
    while true do
        if _G.Running then
            local char = GetChar()
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not _G.Running then break end
                    local lowerName = string.lower(obj.Name)
                    
                    if TargetNames[lowerName] then
                        local cd = obj:FindFirstChildWhichIsA("ClickDetector", true)
                        if cd then
                            local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPivot().Position)
                            if pos then
                                char:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
                                task.wait(0.1)
                                pcall(function() fireclickdetector(cd) end)
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if _G.DrinkEnabled then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local char = GetChar()
            for _, src in ipairs({backpack, char}) do
                if src then
                    for _, tool in ipairs(src:GetChildren()) do
                        if DrinkList[tool.Name] then fastUse(tool) end
                    end
                end
            end
        end
        task.wait(3)
    end
end)

Tabs.chiso:AddToggle("AutoFarmStats", {
    Title = "Auto Farm Stats", Default = false,
}):OnChanged(function(v) 
    if v ~= nil then 
        _G.Running = v
        _G.DrinkEnabled = v 
    end
end)

-- ====== PLAYER FUNCTIONS ======
local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

local PlayerDropdown = Tabs.Players:AddDropdown("PlayerDropdown", {
    Title = "Select Player", Values = GetPlayerNames(), Multi = false, Default = "",
})
PlayerDropdown:OnChanged(function(Value)
    if Value ~= nil then
        _G.States.Player.FullSpy.SelectedPlayer = Players:FindFirstChild(Value or "")
    end
end)

Tabs.Players:AddButton({
    Title = "Reset Player",
    Description = "Upadate list",
    Callback = function()
        local currentList = GetPlayerNames()
        PlayerDropdown:SetValues(currentList)
        PlayerDropdown:SetValue(currentList[1] or "")
    end,
})

local SpectateToggle = Tabs.Players:AddToggle("SpectateToggle", {
    Title = "Spectate", Default = false,
})
SpectateToggle:OnChanged(function(Value)
    if Value ~= nil then
        _G.States.Player.FullSpy.Spectate = Value
        if not Value and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then Camera.CameraSubject = hum end
        end
    end
end)

local TPToggle = Tabs.Players:AddToggle("TPToggle", {
    Title = "Teleprot Player", Default = false,
})
TPToggle:OnChanged(function(Value) 
    if Value ~= nil then _G.States.Player.FullSpy.TPToPlayer = Value end
end)

task.spawn(function()
    while true do
        local target = _G.States.Player.FullSpy.SelectedPlayer
        if target and target.Character then
            if _G.States.Player.FullSpy.Spectate then
                local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                if tHum and Camera.CameraSubject ~= tHum then Camera.CameraSubject = tHum end
            end
            if _G.States.Player.FullSpy.TPToPlayer and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = target.Character.HumanoidRootPart
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                end
                _G.States.Player.FullSpy.TPToPlayer = false
                TPToggle:SetValue(false)
            end
        end
        if not _G.States.Player.FullSpy.Spectate and LocalPlayer.Character then
            local lHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if lHum and Camera.CameraSubject ~= lHum then Camera.CameraSubject = lHum end
        end
        task.wait()
    end
end)

local function UpdatePlayerDropdown()
    if PlayerDropdown then PlayerDropdown:SetValues(GetPlayerNames()) end
end
Players.PlayerAdded:Connect(UpdatePlayerDropdown)
Players.PlayerRemoving:Connect(function(plr)
    UpdatePlayerDropdown()
    if _G.States.Player.FullSpy.SelectedPlayer == plr then
        _G.States.Player.FullSpy.Spectate = false
        SpectateToggle:SetValue(false)
        local lHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if lHum then Camera.CameraSubject = lHum end
    end
end)
UpdatePlayerDropdown()

Tabs.Players:AddToggle("InfJumpToggle", {
    Title = "Inf Jump", Default = false,
    Callback = function(Value) 
        if Value ~= nil then _G.States.InfJump = Value end
    end,
})

UserInputService.JumpRequest:Connect(function()
    if _G.States.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

States = {
    SpeedToggle = false,
    WalkSpeed = 16
}

Tabs.Players:AddToggle("SpeedToggle", {
    Title = "Speed ",
    Default = false,
    Callback = function(Value) 
        States.SpeedToggle = Value 
    end,
})

Tabs.Players:AddSlider("SpeedSlider", {
    Title = "Speed Set",
    Description = "Normal",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) 
        States.WalkSpeed = Value 
    end,
})

task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if States.SpeedToggle then
                hum.WalkSpeed = States.WalkSpeed
            else
                hum.WalkSpeed = 16
            end
        end
    end
end)

local flyConnection = nil

Tabs.Players:AddToggle("Flight", { Title = "Flight", Default = false })
    :OnChanged(function(Value)
    if Value ~= nil then _G.States.Player.FlightEnabled = Value end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if Value then
        flyConnection = RunService.RenderStepped:Connect(function(dt)
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local camCF = Camera.CFrame
            if humanoid then humanoid.PlatformStand = true end
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end
            if moveDir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (moveDir.Unit * _G.States.Player.FlightSpeed * dt)
                hrp.Velocity = Vector3.zero
            else
                hrp.Velocity = Vector3.zero
            end
        end)
    else
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity = Vector3.zero end
        end
    end
end)

Tabs.Players:AddSlider("FlightSpeed", {
    Title = "Flight Speed", Default = 200, Min = 100, Max = 5000, Rounding = 0,
    Callback = function(Value) 
        if Value ~= nil then _G.States.Player.FlightSpeed = Value end
    end,
})

-- ====== ESP ======
if not _G.States then _G.States = {} end
if not _G.States.Player then 
    _G.States.Player = { 
        ESPEnabled = false, 
        TracerEnabled = true, 
        WeaponEnabled = true 
    } 
end

local ESPCache = {}
local ESPConnection = nil

local function GetRainbow(offset)
    return Color3.fromHSV((tick() + offset) % 6 / 6, 0.9, 1)
end

local function CreateESP(player)
    if ESPCache[player] then return end

    local d = {}
    d.Tracer = Drawing.new("Line")
    d.Tracer.Thickness = 1.3
    d.Tracer.Transparency = 0.8

    d.NameTag = Drawing.new("Text")
    d.NameTag.Text = player.Name
    d.NameTag.Size = 13
    d.NameTag.Center = true
    d.NameTag.Outline = true
    d.NameTag.Font = 3

    d.DistanceTag = Drawing.new("Text")
    d.DistanceTag.Size = 11
    d.DistanceTag.Center = true
    d.DistanceTag.Outline = true
    d.DistanceTag.Font = 3

    d.HealthBarBG = Drawing.new("Square")
    d.HealthBarBG.Color = Color3.fromRGB(30,30,30)
    d.HealthBarBG.Filled = true

    d.HealthBar = Drawing.new("Square")
    d.HealthBar.Filled = true

    d.HealthText = Drawing.new("Text")
    d.HealthText.Size = 12
    d.HealthText.Center = true
    d.HealthText.Outline = true
    d.HealthText.Font = 3

    d.WeaponTag = Drawing.new("Text")
    d.WeaponTag.Size = 11
    d.WeaponTag.Center = true
    d.WeaponTag.Outline = true
    d.WeaponTag.Font = 3
    d.WeaponTag.Color = Color3.fromRGB(255, 200, 0)

    ESPCache[player] = d
end

local function HideAll(d)
    for _, v in pairs(d) do
        pcall(function() v.Visible = false end)
    end
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPCache[p] then 
        HideAll(ESPCache[p])
        ESPCache[p] = nil
    end
end)

local function GetWeapons2(player)
    local list = {}
    local char = player.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then table.insert(list, tool.Name) end
        end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, tool in pairs(bp:GetChildren()) do
            if tool:IsA("Tool") then table.insert(list, tool.Name) end
        end
    end
    return #list > 0 and table.concat(list, " | ") or ""
end

local function StartESP()
    if ESPConnection then return end

    ESPConnection = RunService.RenderStepped:Connect(function()
        if not _G.States.Player.ESPEnabled then
            for _, d in pairs(ESPCache) do HideAll(d) end
            return
        end

        for player, d in pairs(ESPCache) do
            local char = player.Character
            if not char then 
                HideAll(d) 
                continue 
            end

            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if not (hrp and hum and hum.Health > 0) then
                HideAll(d)
                continue
            end

            local pos = Camera:WorldToViewportPoint(hrp.Position)
            if pos.Z <= 0 then 
                HideAll(d)
                continue 
            end

            local head = char:FindFirstChild("Head")
            local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
            local height = math.abs(headPos.Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3.5,0)).Y)

            local rainbow = GetRainbow(0)
            local rainbow2 = GetRainbow(2)

            if _G.States.Player.TracerEnabled then
                d.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                d.Tracer.To = Vector2.new(pos.X, pos.Y + height/2)
                d.Tracer.Color = rainbow2
                d.Tracer.Visible = true
            else
                d.Tracer.Visible = false
            end

            d.NameTag.Position = Vector2.new(pos.X, headPos.Y - 26)
            d.NameTag.Color = rainbow
            d.NameTag.Visible = true

            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = myRoot and math.floor((myRoot.Position - hrp.Position).Magnitude) or 0
            d.DistanceTag.Text = dist .. "m"
            d.DistanceTag.Position = Vector2.new(pos.X, pos.Y + height/2 + 7)
            d.DistanceTag.Visible = true

            local hp = hum.Health / hum.MaxHealth
            local w, h = 60, 4

            d.HealthBarBG.Size = Vector2.new(w, h)
            d.HealthBarBG.Position = Vector2.new(pos.X - w/2, headPos.Y - 13)
            d.HealthBarBG.Visible = true

            d.HealthBar.Size = Vector2.new(w * hp, h)
            d.HealthBar.Position = Vector2.new(pos.X - w/2, headPos.Y - 13)
            d.HealthBar.Color = Color3.fromRGB(0, 255, 100)
            d.HealthBar.Visible = true

            d.HealthText.Text = math.floor(hum.Health)
            d.HealthText.Position = Vector2.new(pos.X + 38, headPos.Y - 13)
            d.HealthText.Color = Color3.fromRGB(255, 255, 255)
            d.HealthText.Visible = true

            if _G.States.Player.WeaponEnabled then
                d.WeaponTag.Text = GetWeapons2(player)
                d.WeaponTag.Position = Vector2.new(pos.X, pos.Y + height/2 + 22)
                d.WeaponTag.Visible = true
            else
                d.WeaponTag.Visible = false
            end
        end
    end)
end

local function StopESP()
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end
    for _, d in pairs(ESPCache) do HideAll(d) end
end

if Tabs and Tabs.Players then
    Tabs.Players:AddToggle("PlayerESP", { Title = "Enable ESP Player", Default = false })
    :OnChanged(function(v)
        _G.States.Player.ESPEnabled = v
        if v then StartESP() else StopESP() end
    end)

    Tabs.Players:AddToggle("TracerToggle", { Title = "Enable  Tracer", Default = true })
    :OnChanged(function(v) _G.States.Player.TracerEnabled = v end)

    Tabs.Players:AddToggle("WeaponToggle", { Title = "Enable  Blackpack", Default = true })
    :OnChanged(function(v) _G.States.Player.WeaponEnabled = v end)
end

-- ====== AUTO FRUIT COLLECTOR ======
local RareFruitsSet = {
    "rumble","light","quake","magma","flare","paw","sand","rubber","string","dark",
    "phoenix","ice","rare box","ultra rare box","candy","gas","plasma","buddha",
    "chilly","gravity","gum","ope","dough","flare","snow"
}
local RareFruitsLookup = {}
for _, f in ipairs(RareFruitsSet) do RareFruitsLookup[f] = true end

local BlacklistFruit = { ["small flooper"]=true,["large flooper"]=true,["huge flooper"]=true,["medium flooper"]=true,["cooked small flooper"]=true }

local function IsRareFruit2(name)
    if not name then return false end
    local ln = string.lower(name)
    if BlacklistFruit[ln] then return false end
    if string.find(ln,"juice") or string.find(ln,"sling") or string.find(ln,"shot") then return false end
    for key in pairs(RareFruitsLookup) do
        if string.find(ln, key) then return true end
    end
    return false
end

local ActiveFruits = {}
local LastClickTime2 = 0

local function ClickOnFruit2(tool)
    if tick() - LastClickTime2 < 0.1 then return end
    pcall(function()
        if not tool or not tool.Parent or not fireclickdetector then return end
        LastClickTime2 = tick()
        local main1 = tool:FindFirstChild("Main1")
        if main1 then
            local cd = main1:FindFirstChildOfClass("ClickDetector")
            if cd then fireclickdetector(cd); return end
        end
        local cd = tool:FindFirstChildOfClass("ClickDetector") or tool:FindFirstChildWhichIsA("ClickDetector", true)
        if cd then fireclickdetector(cd) end
    end)
end

local function RegisterFruit(tool)
    if tool and not ActiveFruits[tool] then ActiveFruits[tool] = true end
end

local function QuickScanExistingFruits()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Tool") and IsRareFruit2(obj.Name) then RegisterFruit(obj) end
    end
end

Tabs.Fruits:AddToggle("AutoFruitCollector", {
    Title = "Auto Bring Rare Fruits and Ultra and Box",
    Description = "Spawn and Drop ",
    Default = false,
}):OnChanged(function(Value)
    if Value ~= nil then _G.States.Fruit.AutoFruitEnabled = Value end
    if Value then task.spawn(QuickScanExistingFruits) else table.clear(ActiveFruits) end
end)

task.spawn(function()
    while true do
        if _G.States.Fruit.AutoFruitEnabled then
            local hasFruit = false
            for tool in pairs(ActiveFruits) do
                if not tool or not tool.Parent or tool.Parent ~= workspace then
                    ActiveFruits[tool] = nil; continue
                end
                hasFruit = true
                ClickOnFruit2(tool)
            end
            task.wait(hasFruit and 0.1 or 0.5)
        else
            task.wait(1)
        end
    end
end)

workspace.ChildAdded:Connect(function(obj)
    if _G.States.Fruit.AutoFruitEnabled and obj:IsA("Tool") and IsRareFruit2(obj.Name) then
        RegisterFruit(obj)
    end
end)

-- ====== STATS CHANGER ======
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local StatChangerSettings = { TargetStat = "Nametag", InputValue = "" }
local OriginalTexts = {}
local rainbowEnabled = false

local function GetMenu()
    return PlayerGui:FindFirstChild("Menu", true)
end

local function ApplyStatChange()
    local MenuGui = GetMenu()
    if not MenuGui then
        return
    end
    
    local targetName = StatChangerSettings.TargetStat
    local newValue = StatChangerSettings.InputValue
    local isFound = false
    
    for _, obj in ipairs(MenuGui:GetDescendants()) do
        if obj.Name == targetName and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
            if OriginalTexts[obj] == nil then OriginalTexts[obj] = obj.Text end
            obj.Text = newValue
            isFound = true
        end
    end
end

local function ResetToOriginal()
    local resetCount = 0
    for obj, originalText in pairs(OriginalTexts) do
        if obj and obj.Parent then 
            obj.Text = originalText
            resetCount = resetCount + 1 
        end
    end
    table.clear(OriginalTexts)
end

Tabs.Settings:AddDropdown("SelectStatType", {
    Title="Value",
    Values={"Nametag","BeriAmount","BountyAmount","GemsAmount","KillsAmount"},
    CurrentValue="Nametag",
    Callback=function(Value) 
        if Value ~= nil then StatChangerSettings.TargetStat = Value end
    end,
})

Tabs.Settings:AddInput("StatTextInput", {
    Title="Value",
    Default="",
    Placeholder="Nhập nội dung mới",
    Callback=function(Value) 
        if Value ~= nil then StatChangerSettings.InputValue = Value end
    end,
})

Tabs.Settings:AddButton({ Title="Succes", Callback = ApplyStatChange })
Tabs.Settings:AddButton({ Title="Reset ", Callback = ResetToOriginal })

Tabs.Settings:AddToggle("RainbowNametag", {
    Title = "Rainbow Nametag",
    Default = false,
    Callback = function(Value)
        if Value ~= nil then rainbowEnabled = Value end
        if rainbowEnabled then
            task.spawn(function()
                while rainbowEnabled do
                    local MenuGui = GetMenu()
                    if MenuGui then
                        for _, obj in ipairs(MenuGui:GetDescendants()) do
                            if obj.Name == "Nametag" and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
                                obj.TextColor3 = Color3.fromHSV(tick() * 0.5 % 1, 1, 1)
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
})

-- ====== SERVER FAST CONNECT ======
local ServerJoinerSettings = { TargetServerId = "" }

local function SafeNotify(title, content)
    local fn = Fluent or _G.Fluent or Window
    if fn and fn.Notify then pcall(function() fn:Notify({ Title=title, Content=content, Duration=3 }) end) end
end

local function JoinServerByCode()
    local code = string.gsub(ServerJoinerSettings.TargetServerId, "%s+", "")
    if code == "" then SafeNotify("Thông báo", "Vui lòng nhập mã Server!"); return end
    if code == game.JobId then SafeNotify("Trùng Server", "Bạn đang ở Server này rồi!"); return end
    SafeNotify("Teleporting...", "Đang kết nối tới: " .. code)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, code, LocalPlayer) end)
end
local MapSection3 = Tabs.Map:AddSection("Teleport Secret")
do
    local Config = {
        Folder = workspace:FindFirstChild("Ignore") 
            and workspace.Ignore:FindFirstChild("NPCs") 
            and workspace.Ignore.NPCs:FindFirstChild("Secret"),
        ItemList = {},
        ItemMap = {}
    }

    local function refreshSecretList()
        Config.ItemList = {}
        Config.ItemMap = {}
        if Config.Folder then
            for _, child in ipairs(Config.Folder:GetChildren()) do
                if child:IsA("Model") or child:IsA("BasePart") then
                    table.insert(Config.ItemList, child.Name)
                    Config.ItemMap[child.Name] = child
                end
            end
        else
       
        end
        if #Config.ItemList == 0 then
            table.insert(Config.ItemList, "Không có mục nào")
        end
    end

    refreshSecretList()

    local SecretDropdown = Tabs.Map:AddDropdown("SecretTeleportDropdown", {
        Title = "Selection NPC",
        Values = Config.ItemList,
        CurrentValue = Config.ItemList[1],
        Multi = false,
        Callback = function(Value)
            local target = Config.ItemMap[Value]
            if target then
                local player = Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    if target:IsA("Model") then
                        if target.PrimaryPart then
                            hrp.CFrame = target.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                        else
                            hrp.CFrame = target:GetPivot() + Vector3.new(0, 3, 0)
                        end
                    elseif target:IsA("BasePart") then
                        hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                    end
               
               
                end
            end
        end
    })

    Tabs.Map:AddButton({
        Title = "Reset List",
        Description = "",
        Callback = function()
            refreshSecretList()
            SecretDropdown:SetValues(Config.ItemList)
            SecretDropdown:SetValue(Config.ItemList[1])
         
         
        end
    })
end
local FastServerSection = Tabs.Map:AddSection("Server Fast Connect")
FastServerSection:AddButton({
    Title="Copy Code Sever here", Description="Save JobId to clipboard",
    Callback=function()
        local fn = setclipboard or toclipboard or (syn and syn.setclipboard)
        if fn then pcall(function() fn(game.JobId); SafeNotify("Copied!", "Đã sao chép!") end)
        else SafeNotify("Executor Error", "Không hỗ trợ clipboard!") end
    end,
})
FastServerSection:AddInput("ServerCodeInputField", {
    Title="Code Server", Default="", Placeholder="Past JobId here...", NumericOnly=false,
    Callback=function(Value) 
        if Value ~= nil then ServerJoinerSettings.TargetServerId = Value end
    end,
})
FastServerSection:AddButton({ Title="Join Server", Callback=JoinServerByCode })

-- ====== AUTO FISHING ======
local FOLDER_NAME = "FishingRope_" .. LocalPlayer.UserId
local ROD_PRIORITY = {"Super Rod", "Sturdy Rod", "Wood Rod"}
local lastEquipTime = 0
local EQUIP_COOLDOWN = 2

local function equipBestRod()
    if (tick() - lastEquipTime) < EQUIP_COOLDOWN then return end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    
    if character and character:FindFirstChildOfClass("Tool") then
        local currentTool = character:FindFirstChildOfClass("Tool")
        for _, rodName in ipairs(ROD_PRIORITY) do
            if currentTool.Name == rodName then 
                lastEquipTime = tick()
                return 
            end
        end
    end

    if backpack then
        for _, rodName in ipairs(ROD_PRIORITY) do
            local rod = backpack:FindFirstChild(rodName)
            if rod and character and character:FindFirstChild("Humanoid") then
                character.Humanoid:EquipTool(rod)
                lastEquipTime = tick()
                return
            end
        end
    end
end

local function autoPullIt()
    task.spawn(function()
        while _G.autoFishEnabled do
            pcall(function()
                local fishingGui = game:FindFirstChild("FishingMinigame", true)
                if not fishingGui or not fishingGui.Enabled then
                    task.wait(0.2)
                    return
                end
                
                local mainFrame = fishingGui:FindFirstChild("Frame")
                if not mainFrame then
                    task.wait(0.1)
                    return
                end
                
                -- Tìm tất cả các nút trong Frame
                for _, btn in ipairs(mainFrame:GetDescendants()) do
                    if btn:IsA("TextButton") and btn.Visible and btn.Active then
                        local absSize = btn.AbsoluteSize
                        if absSize.X > 10 and absSize.Y > 10 then
                            local c = btn.BackgroundColor3
                            -- Nút màu trắng (nút kéo cá)
                            if c and c.R > 0.85 and c.G > 0.85 and c.B > 0.85 then
                                local success = false
                                
                                -- Cách 1: Fire signal
                                pcall(function()
                                    if btn.MouseButton1Click then
                                        firesignal(btn.MouseButton1Click)
                                        success = true
                                    end
                                end)
                                
                                -- Cách 2: Activate
                                if not success then
                                    pcall(function()
                                        btn:Activate()
                                        success = true
                                    end)
                                end
                                
                                -- Cách 3: VirtualUser (chỉ PC)
                                if not success then
                                    pcall(function()
                                        local vu = game:GetService("VirtualUser")
                                        if vu then
                                            local absPos = btn.AbsolutePosition
                                            vu:CaptureController()
                                            vu:ClickButton1(Vector2.new(
                                                absPos.X + absSize.X / 2,
                                                absPos.Y + absSize.Y / 2
                                            ))
                                            success = true
                                        end
                                    end)
                                end
                                
                                -- Cách 4: VirtualInputManager (chỉ PC)
                                if not success then
                                    pcall(function()
                                        local vim = game:GetService("VirtualInputManager")
                                        if vim then
                                            local absPos = btn.AbsolutePosition
                                            local clickPos = Vector2.new(
                                                absPos.X + absSize.X / 2,
                                                absPos.Y + absSize.Y / 2
                                            )
                                            vim:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, true, game, 0)
                                            task.wait(0.75)
                                            vim:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, false, game, 0)
                                            success = true
                                        end
                                    end)
                                end
                                
                                -- Cách 5: Dùng InputService (cho mobile)
                                if not success then
                                    pcall(function()
                                        local inputService = game:GetService("UserInputService")
                                        if inputService and inputService.TouchEnabled then
                                            local absPos = btn.AbsolutePosition
                                            local touchPos = Vector2.new(
                                                absPos.X + absSize.X / 2,
                                                absPos.Y + absSize.Y / 2
                                            )
                                            -- Mô phỏng touch trên mobile
                                            inputService:SetTouchEnabled(true)
                                            -- Gửi sự kiện touch
                                            local touch = {
                                                Position = touchPos,
                                                Id = 1,
                                                UserInputType = Enum.UserInputType.Touch
                                            }
                                            inputService:FireInputBegan(touch)
                                            task.wait(0.1)
                                            inputService:FireInputEnded(touch)
                                            success = true
                                        end
                                    end)
                                end
                                
                                if success then
                                    task.wait(0.3)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end

local function autoFishLoop()
    task.spawn(function()
        local isProcessing = false
        
        while _G.autoFishEnabled do
            equipBestRod()
            
            local char = LocalPlayer.Character
            if not char then
                task.wait(0.5)
            else
                local tool = char:FindFirstChildOfClass("Tool")
                local fishingGui = game:FindFirstChild("FishingMinigame", true)
                local isMinigameActive = fishingGui and fishingGui.Enabled

                if tool and not isMinigameActive and not isProcessing then
                    local fishingFolder = Workspace:FindFirstChild(FOLDER_NAME)
                    local bobber = fishingFolder and fishingFolder:FindFirstChild("Bobber")
                    
                    if bobber then
                        if bobber:FindFirstChild("Sparkles") then
                            isProcessing = true
                            tool:Activate()
                            local timeout = 0
                            while bobber.Parent and timeout < 2 do
                                task.wait(0.1)
                                timeout = timeout + 0.1
                            end
                            isProcessing = false
                        end
                    else
                        isProcessing = true
                        tool:Activate()
                        local timeout = 0
                        while not (fishingFolder and fishingFolder:FindFirstChild("Bobber")) and timeout < 2 do
                            task.wait(0.1)
                            timeout = timeout + 0.1
                        end
                        isProcessing = false
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

Tabs.Fishs:AddButton({
    Title = "Teleport Island Afk",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        if rootPart then
            rootPart.CFrame = CFrame.new(-12351, 215, -2948)
            Fluent:Notify({
                Title = "Teleport",
                Content = "Đã tới khu câu cá thành công!",
                Duration = 3
            })
        end
    end
})

Tabs.Fishs:AddToggle("AutoFishFullToggle", {
    Title = "🎣 Auto Fishing",
    Description = "Auto Rod, Robber ,Mini Game",
    Default = false,
    Callback = function(Value)
        if Value ~= nil then 
            _G.autoFishEnabled = Value 
            if Value then 
                autoFishLoop()
                autoPullIt()
                Fluent:Notify({
                    Title = "🎣 Auto Fishing",
                    Content = "✅ Đã bắt đầu câu cá!",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "🎣 Auto Fishing",
                    Content = "❌ Đã dừng câu cá!",
                    Duration = 2
                })
            end
        end
    end,
})

-- ====== AUTO SELL FISH ======
local lastCookerFrame = nil
local sellCooldown = 30
local lastSellTime = 0

local function openCooker()
    if not _G.autoPullEnabled then return end
    pcall(function()
        local cooker = workspace:WaitForChild("Ignore", 2):WaitForChild("NPCs", 2)
                                   :WaitForChild("DailyQuest", 2):WaitForChild("Cooker", 2)
        if cooker then
            local hrp = cooker:FindFirstChild("HumanoidRootPart") or cooker:FindFirstChildWhichIsA("BasePart")
            local cd = (hrp and hrp:FindFirstChildOfClass("ClickDetector")) or cooker:FindFirstChildOfClass("ClickDetector", true)
            if cd then fireclickdetector(cd) end
        end
    end)
end

Tabs.Fishs:AddToggle("AutoPullToggle", {
    Title = "Auto Sell Fish", Default = false,
    Callback = function(state) 
        if state ~= nil then _G.autoPullEnabled = state end
        if not state and lastCookerFrame and lastCookerFrame.Parent then
            lastCookerFrame.Visible = true
            lastCookerFrame = nil
        end
    end,
})

Tabs.Fishs:AddInput("SellCooldownInput", {
    Title = "Thời gian sell",
    Default = "30",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            sellCooldown = num < 30 and 30 or num
        else
            sellCooldown = 30
        end
    end
})

task.spawn(function()
    while true do
        if _G.autoPullEnabled then
            if (tick() - lastSellTime) >= sellCooldown then
                openCooker()
                task.wait(0.5)
                if not _G.autoPullEnabled then continue end
                local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
                if pg then
                    for _, btn in ipairs(pg:GetDescendants()) do
                        if btn:IsA("TextButton") and btn.Visible and btn.BackgroundColor3 then
                            local c = btn.BackgroundColor3
                            if c.R > 0.88 and c.G > 0.88 and c.B > 0.88 then
                                pcall(function() firesignal(btn.MouseButton1Click) end)
                                lastSellTime = tick()
                                local frame = btn:FindFirstAncestorWhichIsA("Frame") or btn:FindFirstAncestorWhichIsA("ImageLabel")
                                if frame then
                                    frame.Visible = false
                                    lastCookerFrame = frame
                                end
                                break 
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- ====== AUTO SPAWN ======
local playerGui2 = LocalPlayer:WaitForChild("PlayerGui")
local isClicking = false

local function fixCamera()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
end

local function clickButton(guiObject)
    if isClicking then return end
    isClicking = true
    
    pcall(function()
        local centerX = guiObject.AbsolutePosition.X + guiObject.AbsoluteSize.X / 2
        local centerY = guiObject.AbsolutePosition.Y + guiObject.AbsoluteSize.Y / 2
        
        if VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(centerX, centerY))
        end
        
        -- Fire UI events
        local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
        for _, eventName in ipairs(events) do
            if guiObject[eventName] then
                for _, connection in ipairs(getconnections(guiObject[eventName])) do
                    pcall(connection.Fire, connection)
                end
            end
        end
    end)
    
    task.wait(0.3)
    task.delay(1, fixCamera)
    isClicking = false
end

local function scanAndSpawn()
    if not _G.AutoSpawnEnabled or isClicking then return end
    
    local loadGui = playerGui2:FindFirstChild("Load")
    if not loadGui or not loadGui.Enabled then return end
    
    for _, descendant in ipairs(loadGui:GetDescendants()) do
        if descendant:IsA("TextButton") then
            local text = string.lower(descendant.Text)
            local name = string.lower(descendant.Name)
            
            if (text:find("spawn") or name:find("spawn")) and descendant.AbsoluteSize.X > 0 then
                clickButton(descendant)
                break
            end
        end
    end
end

-- Main loop
task.spawn(function()
    while task.wait(_G.AutoSpawnEnabled and 0.3 or 0.5) do
        if _G.AutoSpawnEnabled then
            pcall(scanAndSpawn)
        end
    end
end)

-- Camera fix on character spawn
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    task.spawn(function()
        for _ = 1, 300 do
            local camera = workspace.CurrentCamera
            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = humanoid
            task.wait()
        end
    end)
end)

-- UI Toggle
if Tabs and Tabs.Main then
    Tabs.Main:AddToggle("AutoSpawnToggle", {
        Title = "Auto Spawn",
        Description = "Fix Camera",
        Default = _G.AutoSpawnEnabled or false
    }):OnChanged(function(value)
        if value ~= nil then
            _G.AutoSpawnEnabled = value
        end
    end)
end

-- ====== ANTI-AFK ======
-- Anti AFK với kiểm tra an toàn
LocalPlayer.Idled:Connect(function()
    if not _G.AntiAFKEnabled then return end
    
    pcall(function()
        if not VirtualUser then return end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        -- Click ở vị trí ngẫu nhiên để tự nhiên hơn
        local randomX = math.random(100, 800)
        local randomY = math.random(100, 600)
        
        VirtualUser:Button2Down(Vector2.new(randomX, randomY), camera.CFrame)
        task.wait(0.2)  -- Giảm xuống 0.2s
        VirtualUser:Button2Up(Vector2.new(randomX, randomY), camera.CFrame)
    end)
end)

-- UI Toggle
if Tabs and Tabs.Main then
    Tabs.Main:AddToggle("AntiAFKToggle", {
        Title = "Anti AFK V1",
        Description = "Tự động chống AFK",
        Default = _G.AntiAFKEnabled or false
    }):OnChanged(function(value)
        if value ~= nil then
            _G.AntiAFKEnabled = value
            print("Anti AFK: " .. (value and "BẬT" or "TẮT"))
        end
    end)
end

local FastModeEnabled = false

local function GetCharacter()
    if LocalPlayer and LocalPlayer.Character then
        return LocalPlayer.Character
    end
    return nil
end

local function OptimizeObject(obj)
    if obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1 
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
        obj.Enabled = false 
    elseif obj:IsA("MeshPart") then
        obj.Material = Enum.Material.Plastic 
        obj.Reflectance = 0
    elseif obj:IsA("BasePart") and not obj:IsA("MeshPart") then
        obj.Material = Enum.Material.Plastic 
        obj.Reflectance = 0
    end
end

local function ToggleFastMode(state)
    FastModeEnabled = state
    
    if state then
        game.Lighting.Brightness = 2
        game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        game.Lighting.GlobalShadows = false
        
        for _, effect in pairs(game.Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
                effect.Enabled = false
            end
        end

        for _, obj in pairs(workspace:GetDescendants()) do
            OptimizeObject(obj)
        end

        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        local char = GetCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and not States.SpeedToggle then
            hum.WalkSpeed = 50
        end

    else
        game.Lighting.Brightness = 1
        game.Lighting.GlobalShadows = true
        
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)

        local char = GetCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and not States.SpeedToggle then
            hum.WalkSpeed = 16
        end
    end
end

Tabs.Main:AddToggle("FastMode", {
    Title = "Fast Mode",
    Description = "Tweak exture & Fix Lag",
    Default = false,
    Callback = ToggleFastMode
})

-- ====== DROP SAM ======
local function SendChat(msg)
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
        else
            game:GetService("ReplicatedStorage")
                .DefaultChatSystemChatEvents
                .SayMessageRequest
                :FireServer(msg, "All")
        end
    end)
end

Tabs.Samauto:AddToggle("DropSam", {
    Title = "Auto Drop Sam ",
    Default = false
}):OnChanged(function(Value)
    if Value ~= nil then _G.DropSam = Value end
end)

task.spawn(function()
    while task.wait(1) do
        if not _G.DropSam then continue end
        local Character = LocalPlayer.Character
        local Backpack = LocalPlayer:FindFirstChild("Backpack")
        if not Character or not Backpack then continue end
        local Compass = Character:FindFirstChild("Compass") or Backpack:FindFirstChild("Compass")
        if Compass and Compass:IsA("Tool") then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Compass.Parent == Backpack and Humanoid then
                Humanoid:EquipTool(Compass)
                task.wait(0.2)
            end
            if Compass.Parent == Character then SendChat("!drop") end
        end
    end
end)
local function SendChat(msg)
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
        else
            game:GetService("ReplicatedStorage")
                .DefaultChatSystemChatEvents
                .SayMessageRequest
                :FireServer(msg, "All")
        end
    end)
end

Tabs.Samauto:AddToggle("DropToken", {
    Title = "Auto Drop Reset Token ",
    Default = false
}):OnChanged(function(Value)
    if Value ~= nil then _G.DropSam = Value end
end)

task.spawn(function()
    while task.wait(1) do
        if not _G.DropSam then continue end
        local Character = LocalPlayer.Character
        local Backpack = LocalPlayer:FindFirstChild("Backpack")
        if not Character or not Backpack then continue end
        local Compass = Character:FindFirstChild("Reset Token") or Backpack:FindFirstChild("Reset Token")
        if Compass and Compass:IsA("Tool") then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Compass.Parent == Backpack and Humanoid then
                Humanoid:EquipTool(Compass)
                task.wait(0.2)
            end
            if Compass.Parent == Character then SendChat("!drop") end
        end
    end
end)
-- ====== AUTO COOK ======
local cookingStation = workspace:WaitForChild("MapFolder"):WaitForChild("Island8")
    :WaitForChild("Kitchen"):WaitForChild("Cooking"):WaitForChild("CookingStation")
local clickDetector = cookingStation:FindFirstChildOfClass("ClickDetector")
local autoCookEnabled = false

Tabs.Fishs:AddToggle("AutoCookToggle", {
    Title = "Auto Cook",
    Description = "Auto Click Cooking Station",
    Default = false
}):OnChanged(function(Value)
    if Value ~= nil then autoCookEnabled = Value end
end)

task.spawn(function()
    while true do
        if autoCookEnabled and clickDetector then
            fireclickdetector(clickDetector)
        end
        task.wait(0.5)
    end
end)

-- ====== REJOIN ======
Tabs.Map:AddButton({
    Title = "Rejoin Server",
    Icon = "refresh-cw",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

-- ====== HOP SERVER ======
_G.hopButton = Tabs.Map:AddButton({
    Title = "Hop Server",
    Icon = "arrow-right-from-line",
    Callback = function()
        local placeId = game.PlaceId
        local jobId = game.JobId
        local servers = {}
        local cursor = ""
        local pagesScanned = 0
        
        repeat
            local url = "https://games.roproxy.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=200&cursor=" .. cursor
            local success, response = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            
            if success and response and response.data then
                for _, server in pairs(response.data) do
                    if server.id and server.id ~= jobId and server.playing and server.playing > 0 then
                        table.insert(servers, server)
                    end
                end
                cursor = response.nextPageCursor or ""
                pagesScanned = pagesScanned + 1
            else
                break
            end
            task.wait(0.1)
        until cursor == "" or #servers >= 30 or pagesScanned >= 5

        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            task.wait(0.5)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, randomServer.id, LocalPlayer)
            end)
        else
            task.wait(0.5)
            pcall(function()
                TeleportService:Teleport(placeId, LocalPlayer)
            end)
        end
    end
})

-- Gọi từ bên ngoài


-- ====== ALTAR TELEPORT ======
local function getAltarList()
    local altarFolder = Workspace:FindFirstChild("Altars")
    local list = {}
    if altarFolder then
        for _, obj in ipairs(altarFolder:GetChildren()) do
            table.insert(list, obj.Name)
        end
    end
    return list
end

local MapSection2 = Tabs.Map:AddSection("Teleport Altar")

local AltarDropdown = MapSection2:AddDropdown("SelectAltar", {
    Title = "Selection Altar",
    Values = getAltarList(),
    Multi = false,
    Default = nil,
    Callback = function(Value)
        local altarFolder = Workspace:FindFirstChild("Altars")
        local target = altarFolder and altarFolder:FindFirstChild(Value)
        if target then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = target:IsA("Model") and target:GetPivot().Position or target.Position
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end
    end
})

MapSection2:AddButton({
    Title = "Update Altar",
    Callback = function()
        AltarDropdown:SetValues(getAltarList())
    end
})

-- ====== AUTO MIXER FRUIT ======
Tabs.chiso:AddToggle("AutoMixerFruit", {
    Title = "Auto Mixer Fruit",
    Default = false,
    Callback = function(Value)
        if Value ~= nil then _G.AutoMixerFruit = Value end
        if Value then
            task.spawn(function()
                while _G.AutoMixerFruit do
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v.Name == "Mixer1" then
                            local CD = v:FindFirstChildOfClass("ClickDetector")
                            if CD then fireclickdetector(CD) end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- ====== AUTO DRINK ======
local DrinkList2 = {
    ["Apple Juice"] = true,
    ["Sour Juice"] = true,
    ["Pumpkin Juice"] = true,
    ["Fruit Juice"] = true,
    ["Banana Juice"] = true,
    ["Golden Apple"] = true,
    ["Coconut Milk"] = true,
    ["Pear Juice"] = true,
}

Tabs.chiso:AddToggle("AutoDrink Fruit Mix", {
    Title = "Auto Drink",
    Default = false,
    Callback = function(Value)
        if Value ~= nil then _G.AutoDrink = Value end
        if Value then
            task.spawn(function()
                while _G.AutoDrink do
                    local Character = LocalPlayer.Character
                    local Backpack = LocalPlayer:FindFirstChild("Backpack")
                    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                    if Character and Backpack and Humanoid then
                        for _, Tool in ipairs(Backpack:GetChildren()) do
                            if Tool:IsA("Tool") and DrinkList2[Tool.Name] then
                                pcall(function() Humanoid:EquipTool(Tool) end)
                                task.wait(0.03)
                                pcall(function()
                                    Tool:Activate()
                                    Tool:Activate()
                                    Tool:Activate()
                                end)
                            end
                        end
                        for _, Tool in ipairs(Character:GetChildren()) do
                            if Tool:IsA("Tool") and DrinkList2[Tool.Name] then
                                pcall(function()
                                    Tool:Activate()
                                    Tool:Activate()
                                    Tool:Activate()
                                end)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

Tabs.Fishs:AddToggle("DropPlatinum", {
    Title = "Auto Drop Platinum Cache",
    Description = "",
    Default = false
}):OnChanged(function(Value)
    if Value ~= nil then 
        _G.DropPlatinum = Value 
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not _G.DropPlatinum then 
            task.wait(1)
            continue 
        end
        
        local Character = LocalPlayer.Character
        local Backpack = LocalPlayer:FindFirstChild("Backpack")
        
        if not Character or not Backpack then 
            task.wait(1)
            continue 
        end
        
        local platinumFound = false
        
        for _, item in pairs(Backpack:GetChildren()) do
            if item:IsA("Tool") and string.find(string.lower(item.Name), "platinum") and string.find(string.lower(item.Name), "cache") then
                platinumFound = true
                break
            end
        end
        
        if not platinumFound then
            for _, item in pairs(Character:GetChildren()) do
                if item:IsA("Tool") and string.find(string.lower(item.Name), "platinum") and string.find(string.lower(item.Name), "cache") then
                    platinumFound = true
                    break
                end
            end
        end
        
        if not platinumFound then
            task.wait(1)
            continue
        end
        
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid then 
            task.wait(1)
            continue 
        end
        
        local Compass = Character:FindFirstChild("Compass") or Backpack:FindFirstChild("Compass")
        
        if Compass and Compass:IsA("Tool") then
            if Compass.Parent == Backpack and Humanoid then
                Humanoid:EquipTool(Compass)
                task.wait(0.2)
            end
            
            if Compass.Parent == Character then
                SendChat("!drop")
                task.wait(0.5)
            end
        else
            SendChat("!drop")
            task.wait(0.5)
        end
    end
end)

-- ====== AUTO OPEN CACHE ======
local ChestNames = {"Platinum Cache", "Silver Cache", "Gold Cache", "Copper Cache"}

local function OpenFishChests()
    local player = LocalPlayer
    if not player then return end
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local cachesToOpen = {}
    for _, item in ipairs(player.Backpack:GetChildren()) do
        if table.find(ChestNames, item.Name) then
            table.insert(cachesToOpen, item)
        end
    end

    if #cachesToOpen > 0 then
        humanoid:UnequipTools()
        task.wait(0.2)
        for _, cacheTool in ipairs(cachesToOpen) do
            if not _G.AutoOpenFish then break end
            humanoid:EquipTool(cacheTool)
            task.wait(0.2)
            local heldTool = character:FindFirstChild(cacheTool.Name)
            if heldTool then
                heldTool:Activate()
                task.wait(0.6)
            end
        end
    end
end

Tabs.Fishs:AddToggle("AutoOpenCache", {
    Title = "Auto Use Cache",
    Default = false,
    Callback = function(Value)
        if Value ~= nil then _G.AutoOpenFish = Value end
        if _G.AutoOpenFish then
            task.spawn(function()
                while _G.AutoOpenFish do
                    OpenFishChests()
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- ====== WEBHOOK ======

-- ====== AUTO SAM ======
_G.MainAutoSamToggle = false
local isSpamming = false
local SAM_TELEPORT_POSITION = Vector3.new(-1302, 218, -1352)

local function SuperRealisticClick(guiObj)
    if isSpamming or not guiObj then return end
    isSpamming = true
    
    local absPos = guiObj.AbsolutePosition
    local absSize = guiObj.AbsoluteSize
    if absSize.X == 0 or absSize.Y == 0 then
        isSpamming = false
        return
    end
    
    local clickPos = Vector2.new(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2)

    if VirtualUser and type(VirtualUser.CaptureController) == "function" then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(clickPos)
            task.wait(math.random(30, 80) / 1000)
            VirtualUser:Button1Up(clickPos)
            VirtualUser:ClickButton1(clickPos)
        end)
    end

    if getconnections and type(getconnections) == "function" then
        pcall(function()
            for _, evt in ipairs({"MouseButton1Click", "Activated", "MouseButton1Down", "MouseButton1Up"}) do
                if guiObj[evt] then
                    for _, c in ipairs(getconnections(guiObj[evt])) do
                        pcall(c.Fire, c)
                    end
                end
            end
        end)
    end

    if VIM and type(VIM.SendMouseMoveEvent) == "function" then
        pcall(function()
            VIM:SendMouseMoveEvent(clickPos.X, clickPos.Y, 0, game)
            task.wait(math.random(10, 30) / 1000)
            VIM:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, true, game, 0)
            task.wait(math.random(50, 150) / 1000)
            VIM:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, false, game, 0)
            task.wait(math.random(20, 50) / 1000)
            VIM:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, true, game, 0)
            task.wait(math.random(40, 80) / 1000)
            VIM:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, false, game, 0)
        end)
    end

    local cd = guiObj:FindFirstChildWhichIsA("ClickDetector")
    if cd and fireclickdetector then
        pcall(fireclickdetector, cd)
    end

    pcall(function()
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            task.wait(0.02)
            mouse.Button1Up:Fire()
            mouse.Button1Click:Fire()
        end
    end)

    task.wait(math.random(150, 300) / 1000)
    isSpamming = false
end

local function CheckQuestOptions()
    local questGui = playerGui2:FindFirstChild("QuestGui")
    if not questGui then return false end
    
    local dialogue = questGui:FindFirstChild("Dialogue")
    if not dialogue then return false end
    
    local optionsContainer = dialogue:FindFirstChild("Options")
    if not optionsContainer then return false end

    local allOptions = {}
    for _, container in pairs(optionsContainer:GetChildren()) do
        local btn = container:IsA("TextButton") and container or container:FindFirstChildWhichIsA("TextButton")
        local label = container:FindFirstChild("OptionName") or container:FindFirstChild("OptionLabel")
        if btn and label and label:IsA("TextLabel") then
            table.insert(allOptions, {Button = btn, Label = label, Text = label.Text})
        end
    end

    if #allOptions == 0 then return false end

    local targetOptions = {}
    for _, opt in ipairs(allOptions) do
        local text = opt.Text:lower():gsub("%s+", "")
        if text:find("compass") or text:find("claim") or text:find("nhận") or 
           text:find("daily") or text:find("take") or text:find("collect") then
            table.insert(targetOptions, opt)
        end
    end

    if #targetOptions == 0 then 
        targetOptions = {allOptions[1]} 
    end

    for _, opt in ipairs(targetOptions) do
        for i = 1, 3 do
            SuperRealisticClick(opt.Button)
            task.wait(0.3)
        end
    end

    local confirm = dialogue:FindFirstChild("Confirm") or 
                    dialogue:FindFirstChild("Ok") or 
                    dialogue:FindFirstChild("Button")
    if confirm and confirm:IsA("TextButton") then
        SuperRealisticClick(confirm)
        task.wait(0.5)
        SuperRealisticClick(confirm)
    end

    task.wait(2)
    return true
end

local function ExecuteSamSequence()
    local ignore = workspace:FindFirstChild("Ignore")
    if not ignore then return false end
    
    local npcs = ignore:FindFirstChild("NPCs")
    if not npcs then return false end
    
    local dailyQuest = npcs:FindFirstChild("DailyQuest")
    if not dailyQuest then return false end
    
    local sam = dailyQuest:FindFirstChild("Sam")
    if not sam then return false end

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false end

    myHrp.CFrame = CFrame.new(SAM_TELEPORT_POSITION)
    task.wait(0.5)

    local samHrp = sam:FindFirstChild("HumanoidRootPart")
    if not samHrp then return false end
    
    local cd = samHrp:FindFirstChild("ClickDetector")
    if cd then
        fireclickdetector(cd)
    else
        local prompt = samHrp:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            prompt:InputHold()
            task.wait(0.2)
            prompt:InputRelease()
        end
    end

    local timeout = 0
    local options
    repeat
        local dialogue = playerGui2:FindFirstChild("QuestGui") and 
                        playerGui2.QuestGui:FindFirstChild("Dialogue")
        options = dialogue and dialogue:FindFirstChild("Options")
        if options and #options:GetChildren() > 0 then break end
        task.wait(0.2)
        timeout = timeout + 0.2
    until timeout > 3

    if options and #options:GetChildren() > 0 then
        local success = CheckQuestOptions()
        if success then
            task.wait(3)
            return true
        end
    end
    return false
end

task.spawn(function()
    local lastText = ""
    while task.wait(1) do
        if not _G.MainAutoSamToggle then
            lastText = "OFF"
            continue
        end

        local menu = playerGui2:FindFirstChild("Menu")
        if not menu then continue end
        
        local frame1 = menu:FindFirstChild("Frame")
        if not frame1 then continue end
        
        local menuList = frame1:FindFirstChild("MenuList")
        if not menuList then continue end
        
        local stats = menuList:FindFirstChild("Stats")
        if not stats then continue end
        
        local frame2 = stats:FindFirstChild("Frame")
        if not frame2 then continue end
        
        local a = frame2:FindFirstChild("A")
        if not a then continue end
        
        local sam = a:FindFirstChild("Sam")
        if not sam then continue end
        
        local samTimer = sam:FindFirstChild("SamTimer")
        if not samTimer or not samTimer:IsA("TextLabel") then continue end

        local currentText = samTimer.Text
        if currentText ~= lastText then 
            lastText = currentText 
        end

        if string.find(string.lower(currentText), "ready!") then
            ExecuteSamSequence()
            task.wait(1)
        end
    end
end)

if Tabs and Tabs.Main then
    Tabs.Samauto:AddToggle("AutoSam", {
        Title = "Auto Claim Sam",
        Default = false,
        Callback = function(state)
            if state ~= nil then 
                _G.MainAutoSamToggle = state 
            end
        end
    })
end
local ProcessedCompass = {}

local function IsCompass(obj)
    return obj:IsA("Tool") and string.find(string.lower(obj.Name), "compass")
end

local function TouchCompass(tool)
    if not tool or not tool.Parent then return end
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    local Handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true)
    if not Handle then return end
    if ProcessedCompass[tool] then return end
    ProcessedCompass[tool] = true

    task.spawn(function()
        for i = 1, 10 do
            if not _G.States.Fruit.AutoCompassEnabled then break end
            pcall(function()
                firetouchinterest(HRP, Handle, 0)
                task.wait()
                firetouchinterest(HRP, Handle, 1)
            end)
            if tool.Parent == Character or tool.Parent == LocalPlayer.Backpack then break end
            task.wait(0.15)
        end
    end)

    if not tool:GetAttribute("CompassHooked") then
        tool:SetAttribute("CompassHooked", true)
        tool.AncestryChanged:Connect(function()
            if tool.Parent == workspace then
                ProcessedCompass[tool] = nil
                if _G.States.Fruit.AutoCompassEnabled then
                    task.wait(0.2)
                    TouchCompass(tool)
                end
            end
        end)
    end
end

local function ScanCompass()
    for _, v in ipairs(workspace:GetDescendants()) do
        if IsCompass(v) then TouchCompass(v) end
    end
end

Tabs.Fruits:AddToggle("AutoCompassCollector", {
    Title = "Grab Compass",
    Description = "",
    Default = false
}):OnChanged(function(Value)
    if Value ~= nil then _G.States.Fruit.AutoCompassEnabled = Value end
    if Value then
        table.clear(ProcessedCompass)
        ScanCompass()
    else
        table.clear(ProcessedCompass)
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if not _G.States.Fruit.AutoCompassEnabled then return end
    if IsCompass(obj) then
        ProcessedCompass[obj] = nil
        task.wait(0.2)
        TouchCompass(obj)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if _G.States.Fruit.AutoCompassEnabled then ScanCompass() end
    end
end)

local AutoFindSamLuck = false

Tabs.Samauto:AddToggle("Auto Sam luck", {
    Title = "Auto Sam luck",
    Default = false
}):OnChanged(function(Value)
    AutoFindSamLuck = Value
    
    if Value then
        task.spawn(function()
            while AutoFindSamLuck do
                local success, player = pcall(function()
                    return game:GetService("Players").LocalPlayer
                end)
                
                if not success or not player then
                    task.wait(1)
                    continue
                end
                
                local character = player.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                if not hrp then 
                    task.wait(1)
                    continue 
                end
                
                local trees = {}
                for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
                    if obj.Name == "Tremi" and obj:IsA("Model") and obj.Parent then
                        table.insert(trees, obj)
                    end
                end
                
                if #trees == 0 then
                    task.wait(1)
                    continue
                end
                
                for _, tree in ipairs(trees) do
                    if not AutoFindSamLuck then break end
                    
                    local spawner = tree:FindFirstChild("Spawner", true)
                    if spawner then
                        local pos = nil
                        if spawner:IsA("BasePart") then
                            pos = spawner.Position
                        elseif spawner:IsA("Model") then
                            local primary = spawner.PrimaryPart or spawner:FindFirstChildWhichIsA("BasePart")
                            if primary then pos = primary.Position end
                        end
                        
                        if pos then
                            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                            task.wait(0.3)
                        end
                    end
                end
                
                task.wait(0.5)
            end
        end)
    end
end)

Tabs.Main:AddSection("💃 Troll ")



local ZoomEnabled = false
local ZoomLevel = 10

local function SetZoom(level)
    ZoomLevel = math.clamp(level, 10, 200)
    if ZoomEnabled then
        pcall(function()
            workspace.CurrentCamera.FieldOfView = ZoomLevel
        end)
    end
end

Tabs.Main:AddToggle("ZoomToggle", {
    Title = "Zoom Camera",
    Description = "Bật/tắt chỉnh góc nhìn",
    Default = false,
    Callback = function(Value)
        if Value ~= nil then
            ZoomEnabled = Value
            if ZoomEnabled then
                SetZoom(ZoomLevel)
            else
                pcall(function()
                    workspace.CurrentCamera.FieldOfView = 70
                end)
            end
        end
    end
})

Tabs.Main:AddSlider("ZoomSlider", {
    Title = "Size Zom",
    Default = 15,
    Min = 15,
    Max = 50,
    Rounding = 1,
    Callback = function(Value)
        if Value ~= nil then
            ZoomLevel = Value
            if ZoomEnabled then
                SetZoom(ZoomLevel)
            end
        end
    end
})

Tabs.Main:AddButton({
    Title = "Reset Camera",
    Description = "Normal Camera",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                workspace.CurrentCamera.CameraSubject = hum
                pcall(function()
                    workspace.CurrentCamera.FieldOfView = 70
                end)
                ZoomLevel = 100
            end
        end
    end
})

local CharSize = 1

Tabs.Main:AddSlider("CharSize", {
    Title = "Kích thước nhân vật",
    Default = 1,
    Min = 0.1,
    Max = 50,
    Rounding = 1,
    Callback = function(Value)
        if Value ~= nil then
            CharSize = Value
            local char = LocalPlayer.Character
            if char then
                char:SetAttribute("Size", CharSize)
                pcall(function()
                    char:ScaleTo(CharSize)
                end)
            end
        end
    end
})

_G.AutoTeleportV2 = false

-- =====================================================
-- PHẦN 1: CẤU HÌNH
-- =====================================================
local Config = {
    IsTeleporting = false,
    IsHolding = false,
    HoldConnection = nil,
    AutoClickConnection = nil,
    TeleportedSpawners = {},
    TeleportDelayV = 0.2,
    MaxRetries = 2,
    RetryDelay = 0.05,
    CheckCompassInHand = false, -- Thêm flag kiểm tra
}

-- =====================================================
-- PHẦN 2: HÀM KIỂM TRA ĐANG CẦM COMPASS TRÊN TAY
-- =====================================================
local function IsHoldingCompassInHand()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    -- KIỂM TRA TRONG CHARACTER (đang cầm trên tay)
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool.Name == "Compass" then
        return true
    end
    
    return false
end

-- =====================================================
-- PHẦN 3: HÀM KIỂM TRA CÓ COMPASS (TRONG TAY HOẶC BACKPACK)
-- =====================================================
local function HasCompass()
    local player = LocalPlayer
    if not player then return false end

    -- Kiểm tra trong Character
    local char = player.Character
    if char then
        if char:FindFirstChild("Compass") then
            return true
        end
    end

    -- Kiểm tra trong Backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("Compass") then
        return true
    end

    return false
end

-- =====================================================
-- PHẦN 4: HÀM TRANG BỊ COMPASS (CHỈ TRANG BỊ KHI CHƯA CÓ)
-- =====================================================
local function ForceEquipCompass()
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- Nếu đã cầm Compass trên tay thì không cần làm gì
    if IsHoldingCompassInHand() then
        return true
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local compass = backpack:FindFirstChild("Compass")
    if compass and compass:IsA("Tool") then
        humanoid:EquipTool(compass)
        task.wait(0.1)
        
        -- Kiểm tra đã trang bị thành công
        for i = 1, 5 do
            task.wait(0.1)
            if IsHoldingCompassInHand() then
                return true
            end
        end
    end
    
    return false
end

-- =====================================================
-- PHẦN 5: HÀM LẤY KIM LA BÀN
-- =====================================================
local function GetCompassNeedle()
    -- CHỈ LẤY KIM KHI ĐANG CẦM COMPASS TRÊN TAY
    if not IsHoldingCompassInHand() then
        return nil
    end
    
    local alive = Workspace:FindFirstChild("Alive")
    if not alive then return nil end
    
    local playerAlive = alive:FindFirstChild(LocalPlayer.Name)
    if not playerAlive then return nil end
    
    local compass = playerAlive:FindFirstChild("Compass")
    if not compass then return nil end
    
    local needle = compass:FindFirstChild("CompassNeedle")
    if not needle then
        needle = compass:FindFirstChild("CompassNeedle", true)
    end
    
    if needle and needle:IsA("BasePart") then
        return needle
    end
    
    return nil
end

-- =====================================================
-- PHẦN 6: HÀM LẤY HƯỚNG KIM (CÓ CACHE)
-- =====================================================
local lastDirection = nil
local lastDirectionTime = 0

local function GetDirection()
    -- Nếu không cầm Compass trên tay thì không lấy hướng
    if not IsHoldingCompassInHand() then
        return nil
    end
    
    local now = tick()
    
    if lastDirection and (now - lastDirectionTime) < 0.05 then
        return lastDirection
    end
    
    local needle = GetCompassNeedle()
    if not needle then return lastDirection end
    
    local lookVector = needle.CFrame.LookVector
    local dir = math.atan2(lookVector.X, -lookVector.Z) + math.pi/2
    
    lastDirection = dir
    lastDirectionTime = now
    
    return dir
end

-- =====================================================
-- PHẦN 7: HÀM KIỂM TRA SPAWNER
-- =====================================================
local function IsSpawner(obj)
    if not obj then return false end
    local name = string.lower(obj.Name)
    
    local keywords = {
        "spawner", "spawn"
    }
    
    for _, keyword in pairs(keywords) do
        if string.find(name, keyword) then
            return true
        end
    end
    
    return false
end

-- =====================================================
-- PHẦN 8: HÀM LẤY TẤT CẢ SPAWNER (CÓ CACHE)
-- =====================================================
local spawnerCache = {}
local lastSpawnerScan = 0

local function GetAllSpawners()
    local now = tick()
    if now - lastSpawnerScan < 0.5 then
        return spawnerCache
    end
    
    local spawners = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if IsSpawner(obj) then
            local pos = nil
            
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                if obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                else
                    pos = obj:GetPivot().Position
                end
            end
            
            if pos then
                table.insert(spawners, {
                    Object = obj,
                    Name = obj.Name,
                    Position = pos
                })
            end
        end
    end
    
    spawnerCache = spawners
    lastSpawnerScan = now
    
    return spawners
end

-- =====================================================
-- PHẦN 9: HÀM TELEPORT ĐẾN SPAWNER
-- =====================================================
local function TeleportToSpawner(spawner)
    if not spawner then return false end
    if Config.IsTeleporting then return false end
    
    -- KIỂM TRA ĐANG CẦM COMPASS TRÊN TAY TRƯỚC KHI TELEPORT
    if not IsHoldingCompassInHand() then
        return false
    end
    
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local teleportPos = spawner.Position
    
    Config.IsTeleporting = true
    local oldPos = hrp.Position
    
    local success, err = pcall(function()
        hrp.CFrame = CFrame.new(teleportPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end)
    
    if not success then
        pcall(function() hrp.CFrame = CFrame.new(oldPos) end)
        Config.IsTeleporting = false
        return false
    end
    
    Config.TeleportedSpawners[tostring(spawner.Position)] = os.time()
    task.wait(Config.TeleportDelayV)
    Config.IsTeleporting = false
    return true
end

-- =====================================================
-- PHẦN 10: HÀM QUÉT VÀ TELEPORT SPAWNER
-- =====================================================
local function ScanAndTeleport()
    if Config.IsTeleporting then return end
    
    -- KIỂM TRA ĐANG CẦM COMPASS TRÊN TAY
    if not IsHoldingCompassInHand() then
        return
    end
    
    local dir = GetDirection()
    if not dir then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local currentPos = hrp.Position
    local allSpawners = GetAllSpawners()
    
    if #allSpawners == 0 then return end
    
    local dirVec = Vector3.new(math.sin(dir), 0, -math.cos(dir)).Unit
    
    local nearestSpawner = nil
    local nearestDist = math.huge
    local angleLimit = 45
    
    for _, spawner in pairs(allSpawners) do
        local key = tostring(spawner.Position)
        
        if not Config.TeleportedSpawners[key] then
            local toSpawner = spawner.Position - currentPos
            local dist = Vector2.new(toSpawner.X, toSpawner.Z).Magnitude
            
            if dist > 5 and dist < 10000 then
                local toDir = Vector3.new(toSpawner.X, 0, toSpawner.Z).Unit
                local dot = dirVec:Dot(toDir)
                local angle = math.acos(math.clamp(dot, -1, 1))
                local angleDeg = math.deg(angle)
                
                if angleDeg < angleLimit then
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestSpawner = spawner
                    end
                end
            end
        end
    end
    
    if nearestSpawner then
        TeleportToSpawner(nearestSpawner)
    end
end

-- =====================================================
-- PHẦN 11: HÀM GIỮ COMPASS (LUÔN KIỂM TRA ĐANG CẦM TRÊN TAY)
-- =====================================================
local function StartHoldingCompass()
    if Config.IsHolding then return end
    Config.IsHolding = true
    
    if Config.HoldConnection then
        Config.HoldConnection:Disconnect()
        Config.HoldConnection = nil
    end
    
    Config.HoldConnection = RunService.Heartbeat:Connect(function()
        if not _G.AutoTeleportV2 or not Config.IsHolding then return end
        
        -- Nếu không có Compass trong tay hoặc backpack -> dừng script
        if not HasCompass() then
            _G.AutoTeleportV2 = false
            pcall(function()
                Tabs.Samauto:GetToggle("AutoTeleportCompassV2"):SetValue(false)
            end)
            return
        end
        
        -- Nếu không cầm Compass trên tay -> trang bị
        if not IsHoldingCompassInHand() then
            ForceEquipCompass()
        end
        
        -- CHỈ GIỮ CLICK KHI ĐANG CẦM COMPASS TRÊN TAY
        if IsHoldingCompassInHand() then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                if vu then
                    vu:CaptureController()
                    vu:Button1Down(Vector2.new(500, 500))
                end
            end)
        end
    end)
end

-- =====================================================
-- PHẦN 12: HÀM DỪNG GIỮ COMPASS
-- =====================================================
local function StopHoldingCompass()
    Config.IsHolding = false
    if Config.HoldConnection then
        Config.HoldConnection:Disconnect()
        Config.HoldConnection = nil
    end
    
    pcall(function()
        local vu = game:GetService("VirtualUser")
        if vu then
            vu:Button1Up(Vector2.new(500, 500))
        end
    end)
end

-- =====================================================
-- PHẦN 13: HÀM AUTO CLICK
-- =====================================================
local function StartAutoClick()
    if Config.AutoClickConnection then return end
    
    Config.AutoClickConnection = RunService.Heartbeat:Connect(function()
        if not _G.AutoTeleportV2 then return end
        
        -- CHỈ CLICK KHI ĐANG CẦM COMPASS TRÊN TAY
        if IsHoldingCompassInHand() then
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool and tool.Name == "Compass" then
                pcall(function()
                    tool:Activate()
                    local vu = game:GetService("VirtualUser")
                    if vu then
                        vu:CaptureController()
                        vu:Button1Down(Vector2.new(999, 999))
                    end
                end)
            end
        end
    end)
end

-- =====================================================
-- PHẦN 14: HÀM STOP AUTO CLICK
-- =====================================================
local function StopAutoClick()
    if Config.AutoClickConnection then
        Config.AutoClickConnection:Disconnect()
        Config.AutoClickConnection = nil
    end
end

-- =====================================================
-- PHẦN 15: VÒNG LẶP CHÍNH
-- =====================================================
local loopConnection = nil
local lastScanTime = 0

local function StartMainLoop()
    if loopConnection then return end
    
    loopConnection = RunService.Heartbeat:Connect(function()
        if not _G.AutoTeleportV2 then return end
        
        -- KIỂM TRA NẾU KHÔNG CÓ COMPASS THÌ DỪNG
        if not HasCompass() then
            _G.AutoTeleportV2 = false
            pcall(function()
                Tabs.Samauto:GetToggle("AutoTeleportCompassV2"):SetValue(false)
            end)
            return
        end
        
        -- Nếu không cầm Compass trên tay -> trang bị
        if not IsHoldingCompassInHand() then
            if not ForceEquipCompass() then
                return -- Không trang bị được, bỏ qua
            end
        end
        
        -- CHỈ SCAN VÀ TELEPORT KHI ĐANG CẦM COMPASS TRÊN TAY
        if IsHoldingCompassInHand() then
            local now = tick()
            if now - lastScanTime >= 0.001 then
                lastScanTime = now
                
                if not Config.IsTeleporting then
                    ScanAndTeleport()
                end
            end
        end
    end)
end

local function StopMainLoop()
    if loopConnection then
        loopConnection:Disconnect()
        loopConnection = nil
    end
    Config.IsTeleporting = false
end

-- =====================================================
-- PHẦN 16: TOGGLE CHÍNH
-- =====================================================
Tabs.Samauto:AddToggle("AutoTeleportCompassV2", {
    Title = "Auto Find Sam",
    Description = "",
    Default = false,
    Callback = function(Value)
        if Value ~= nil then
            _G.AutoTeleportV2 = Value
            
            if not _G.AutoTeleportV2 then
                StopHoldingCompass()
                StopAutoClick()
                StopMainLoop()
                Config.TeleportedSpawners = {}
                Config.IsTeleporting = false
                lastDirection = nil
                lastDirectionTime = 0
            else
                task.wait(0.2)
                
                Config.TeleportedSpawners = {}
                Config.IsTeleporting = false
                
                if HasCompass() then
                    if ForceEquipCompass() then
                        StartHoldingCompass()
                        StartAutoClick()
                        StartMainLoop()
                    else
                        _G.AutoTeleportV2 = false
                        pcall(function()
                            Tabs.Samauto:GetToggle("AutoTeleportCompassV2"):SetValue(false)
                        end)
                        warn("Không thể trang bị Compass!")
                    end
                else
                    _G.AutoTeleportV2 = false
                    pcall(function()
                        Tabs.Samauto:GetToggle("AutoTeleportCompassV2"):SetValue(false)
                    end)
                    warn("Không tìm thấy Compass! Vui lòng mua Compass trước.")
                end
            end
        end
    end
})
-- ====== SAM V2 SIMPLE - TELEPORT THEO HƯỚNG KIM CHỈ ======
local ConfigV2 = {
    HoldConnection = nil,
    IsHolding = false,
    AutoClickConnection = nil,
    TeleportedSpawners = {},
    IsTeleporting = false,
    TeleportDelay = 0.1,
    MaxRetries = 3,
    RetryDelay = 0.05,
    DirectionHistory = {},
    MaxDirHistory = 1,
    CurrentDirection = nil,
    FlyConnection = nil,
    IsFlying = false,
    CurrentFlyPos = nil,
    FlySpeed = 100,
    LastValidDir = nil,
    IsSpinning = false,
    RotationHistory = {},
    MaxRotationHistory = 10,
    SpinThreshold = 5,
    ScanRadiusSpinning = 2000,
    ScanRadiusSudden = 2000,
}

local function ForceEquipCompassV2()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and currentTool.Name == "Compass" then
        return true
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local compass = backpack:FindFirstChild("Compass")
    if compass and compass:IsA("Tool") then
        humanoid:EquipTool(compass)
        task.wait(0.1)
        
        for i = 1, 3 do
            task.wait(0.1)
            if char:FindFirstChild("Compass") then
                return true
            end
        end
    end
    
    return false
end

local function IsHoldingCompassV2()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("Compass") ~= nil
end

local function CheckCompassFullV2()
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- Kiểm tra trên tay
    if char:FindFirstChild("Compass") then
        return true
    end
    
    -- Kiểm tra trong Backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("Compass") then
        -- Equip lên tay
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local compass = backpack:FindFirstChild("Compass")
            humanoid:EquipTool(compass)
            task.wait(0.2)
            return true
        end
    end
    
    return false
end
local function StopOnLostCompassV2()
    if not CheckCompassFullV2() then
        _G.AutoTeleportV2 = false
        StopHoldingCompassV2()
        StopAutoClickCompassV2()
        StopFlyV2()
        UnlockCharacterV2()
        
        pcall(function()
            Tabs.Main:GetToggle("AutoTeleportCompassV2"):SetValue(false)
        end)
        
        return true
    end
    return false
end

local function GetCompassNeedleV2()
    local alive = Workspace:FindFirstChild("Alive")
    if not alive then return nil end
    
    local playerAlive = alive:FindFirstChild(LocalPlayer.Name)
    if not playerAlive then return nil end
    
    local compass = playerAlive:FindFirstChild("Compass")
    if not compass then return nil end
    
    local needle = compass:FindFirstChild("CompassNeedle")
    if not needle then
        needle = compass:FindFirstChild("CompassNeedle", true)
    end
    
    if needle and needle:IsA("BasePart") then
        return needle
    end
    
    return nil
end

local function GetStableDirectionV2()
    local needle = GetCompassNeedleV2()
    if not needle then return nil end
    
    local lookVector = needle.CFrame.LookVector
    local dir = math.atan2(lookVector.X, -lookVector.Z) + math.pi/2
    
    table.insert(ConfigV2.DirectionHistory, dir)
    if #ConfigV2.DirectionHistory > ConfigV2.MaxDirHistory then
        table.remove(ConfigV2.DirectionHistory, 1)
    end
    
    if #ConfigV2.DirectionHistory < ConfigV2.MaxDirHistory then
        return nil
    end
    
    local sumSin = 0
    local sumCos = 0
    for _, d in pairs(ConfigV2.DirectionHistory) do
        sumSin = sumSin + math.sin(d)
        sumCos = sumCos + math.cos(d)
    end
    
    ConfigV2.CurrentDirection = math.atan2(sumSin / #ConfigV2.DirectionHistory, sumCos / #ConfigV2.DirectionHistory)
    return ConfigV2.CurrentDirection
end

local function DetectSpinningV2(dir)
    table.insert(ConfigV2.RotationHistory, dir)
    if #ConfigV2.RotationHistory > ConfigV2.MaxRotationHistory then
        table.remove(ConfigV2.RotationHistory, 1)
    end
    
    if #ConfigV2.RotationHistory < 10 then
        return false
    end
    
    local totalRotation = 0
    local lastDir = ConfigV2.RotationHistory[1]
    local changes = 0
    
    for i = 2, #ConfigV2.RotationHistory do
        local currentDir = ConfigV2.RotationHistory[i]
        local diff = currentDir - lastDir
        
        while diff > math.pi do diff = diff - 2 * math.pi end
        while diff < -math.pi do diff = diff + 2 * math.pi end
        
        totalRotation = totalRotation + diff
        lastDir = currentDir
        
        if math.abs(diff) > 0.5 then
            changes = changes + 1
        end
    end
    
    return math.abs(totalRotation) > 5.5 and changes >= ConfigV2.SpinThreshold
end

local function DetectSuddenChangeV2(oldDir, newDir)
    if not oldDir or not newDir then return false end
    
    local diff = newDir - oldDir
    while diff > math.pi do diff = diff - 2 * math.pi end
    while diff < -math.pi do diff = diff + 2 * math.pi end
    
    return math.abs(diff) > math.rad(50)
end

local function IsValidSpawnerV2(obj)
    if not obj then return false end
    local nameLower = string.lower(obj.Name)
    local isValid = string.find(nameLower, "spawner") or string.find(nameLower, "spawn")
    return isValid and (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("SpawnLocation"))
end

local function GetAllSpawnersV2()
    local spawners = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if IsValidSpawnerV2(obj) then
            local pos = nil
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                pos = obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position
            end
            
            if pos and pos.X == pos.X then
                table.insert(spawners, {
                    Object = obj,
                    Name = obj.Name,
                    Position = pos,
                    Height = pos.Y
                })
            end
        end
    end
    return spawners
end

local function FindGroundV2(position)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local rayOrigin = Vector3.new(position.X, position.Y + 100, position.Z)
    local rayResult = workspace:Raycast(rayOrigin, Vector3.new(0, -1, 0) * 200, params)
    
    if rayResult then
        return rayResult.Position.Y + 3
    end
    
    rayOrigin = Vector3.new(position.X, -100, position.Z)
    rayResult = workspace:Raycast(rayOrigin, Vector3.new(0, 1, 0) * 300, params)
    
    if rayResult then
        return rayResult.Position.Y + 3
    end
    
    return position.Y + 10
end

local function ScanSpawnersAdvancedV2(dir, centerPos, radius, isSpinningMode)
    local allSpawners = GetAllSpawnersV2()
    local result = {}
    
    -- Tạo vector hướng từ góc độ
    local dirVec = Vector3.new(math.sin(dir), 0, -math.cos(dir)).Unit
    
    if isSpinningMode then
        -- Khi đang xoay, quét rộng hơn để tìm spawner ở mọi hướng
        for _, spawner in pairs(allSpawners) do
            local key = tostring(spawner.Position)
            if not ConfigV2.TeleportedSpawners[key] then
                local toSpawner = spawner.Position - centerPos
                local dist = Vector2.new(toSpawner.X, toSpawner.Z).Magnitude
                if dist > 3 and dist < radius then
                    -- Tính góc giữa hướng di chuyển và spawner
                    local toDir = Vector3.new(toSpawner.X, 0, toSpawner.Z).Unit
                    local dot = dirVec:Dot(toDir)
                    local angle = math.acos(math.clamp(dot, -1, 1))
                    
                    -- Khi xoay, quét rộng hơn (120 độ) để bắt spawner tốt hơn
                    if angle < math.rad(45) then
                        table.insert(result, spawner)
                    end
                end
            end
        end
    else
        -- Chế độ bình thường: quét chính xác theo hướng kim
        for _, spawner in pairs(allSpawners) do
            local key = tostring(spawner.Position)
            if not ConfigV2.TeleportedSpawners[key] then
                local toSpawner = spawner.Position - centerPos
                local dist = Vector2.new(toSpawner.X, toSpawner.Z).Magnitude
                
                -- Kiểm tra khoảng cách hợp lý
                if dist > 2 and dist < radius then
                    -- Vector từ vị trí hiện tại đến spawner
                    local toDir = Vector3.new(toSpawner.X, 0, toSpawner.Z).Unit
                    
                    -- Tính độ tương đồng (dot product) giữa hướng kim và hướng đến spawner
                    local dot = dirVec:Dot(toDir)
                    
                    -- Clamp dot để tránh lỗi math.acos
                    local clampedDot = math.clamp(dot, -1, 1)
                    
                    -- Tính góc (radian)
                    local angle = math.acos(clampedDot)
                    
                    -- Chuyển sang độ để dễ kiểm tra
                    local angleDeg = math.deg(angle)
                    
                    -- Chỉ lấy spawner trong góc 25 độ so với hướng kim (chính xác hơn)
                    -- Và ưu tiên spawner gần nhất trong góc đó
                    if angleDeg < 25 then
                        table.insert(result, spawner)
                    end
                end
            end
        end
    end
    
    -- Sắp xếp spawner theo khoảng cách từ gần đến xa
    table.sort(result, function(a, b)
        local da = (a.Position - centerPos).Magnitude
        local db = (b.Position - centerPos).Magnitude
        return da < db
    end)
    
    return result
end
-- Hàm kiểm tra nhân vật đã chạm đất chưa
local function IsOnGroundV2()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    -- Kiểm tra nhanh state
    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Physics then
        return true
    end
    
    -- Kiểm tra bằng raycast
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {char}
    
    local rayOrigin = hrp.Position
    local rayResult = workspace:Raycast(rayOrigin, Vector3.new(0, -5, 0), params)
    
    if rayResult then
        local distance = (rayOrigin - rayResult.Position).Magnitude
        return distance < 5
    end
    
    return false
end
local function TeleportToSpawnersV2(targetSpawners)
    if not targetSpawners or #targetSpawners == 0 then return end
    
    ConfigV2.IsFlying = false
    if ConfigV2.FlyConnection then
        ConfigV2.FlyConnection:Disconnect()
        ConfigV2.FlyConnection = nil
    end
    
    task.spawn(function()
        local teleportCount = 0
        local totalSpawners = #targetSpawners
        
        for i, spawner in ipairs(targetSpawners) do
            if not _G.AutoTeleportV2 then
                UnlockCharacterV2()
                StartFlyV2()
                return
            end
            
            if not CheckCompassFullV2() then
                UnlockCharacterV2()
                _G.AutoTeleportV2 = false
                
                pcall(function()
                    Tabs.Main:GetToggle("AutoTeleportCompassV2"):SetValue(false)
                end)
                
                return
            end
            
            local liveChar = LocalPlayer.Character
            if not liveChar then
                task.wait(0.2)
                liveChar = LocalPlayer.Character
                if not liveChar then
                    _G.AutoTeleportV2 = false
                    UnlockCharacterV2()
                    return
                end
            end
            
            local liveHrp = liveChar:FindFirstChild("HumanoidRootPart")
            if not liveHrp then
                task.wait(0.2)
                liveHrp = liveChar:FindFirstChild("HumanoidRootPart")
                if not liveHrp then
                    continue
                end
            end
            
            if not _G.AutoTeleportV2 then
                UnlockCharacterV2()
                StartFlyV2()
                return
            end
            
            -- ====== TÌM BỀ MẶT SPAWNER CHÍNH XÁC ======
            local sPos = spawner.Position
            
            -- Hàm tìm bề mặt của spawner bằng raycast
            local function FindSpawnerSurface(spawnerPart)
                local size = spawnerPart.Size or Vector3.new(4, 1, 4)
                local halfSize = size / 2
                
                -- Raycast từ trên xuống để tìm bề mặt trên cùng
                local rayOrigin = Vector3.new(
                    spawnerPart.Position.X,
                    spawnerPart.Position.Y + halfSize.Y + 10,
                    spawnerPart.Position.Z
                )
                local rayDirection = Vector3.new(0, -20, 0)
                
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                
                local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
                
                if result and result.Instance == spawnerPart then
                    -- Đã tìm thấy bề mặt spawner
                    return result.Position.Y
                end
                
                -- Nếu không tìm thấy bằng raycast, dùng vị trí + kích thước
                return spawnerPart.Position.Y + halfSize.Y
            end
            
            -- Tìm bề mặt spawner
            local surfaceY = FindSpawnerSurface(spawner)
            
            -- Tạo vị trí teleport trên bề mặt spawner
            local teleportPos = Vector3.new(sPos.X, surfaceY + 1.5, sPos.Z)
            
            -- Teleport chính xác
            liveHrp.CFrame = CFrame.new(teleportPos)
            pcall(function() liveHrp.AssemblyLinearVelocity = Vector3.zero end)
            
            -- Đánh dấu đã teleport
            ConfigV2.TeleportedSpawners[tostring(sPos)] = os.time()
            teleportCount = teleportCount + 1
            
            -- Đợi nhân vật ổn định trên spawner
            task.wait(0.15)
            
            -- Kiểm tra và sửa nếu nhân vật bị rơi
            local checkChar = LocalPlayer.Character
            if checkChar then
                local checkHrp = checkChar:FindFirstChild("HumanoidRootPart")
                if checkHrp and checkHrp.Position.Y < teleportPos.Y - 1.5 then
                    -- Teleport lại nếu bị rơi
                    checkHrp.CFrame = CFrame.new(teleportPos)
                    pcall(function() checkHrp.AssemblyLinearVelocity = Vector3.zero end)
                    task.wait(0.1)
                end
            end
            
            if not CheckCompassFullV2() then
                UnlockCharacterV2()
                _G.AutoTeleportV2 = false
                
                pcall(function()
                    Tabs.Main:GetToggle("AutoTeleportCompassV2"):SetValue(false)
                end)
                
                return
            end
            
            task.wait(ConfigV2.TeleportDelay or 0.3)
        end
        
        UnlockCharacterV2()
        
        if _G.AutoTeleportV2 then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos = hrp.Position
                    ConfigV2.CurrentFlyPos = Vector3.new(pos.X, 300, pos.Z)
                end
            end
            
            StartFlyV2()
        end
    end)
end
local function StopHoldingCompassV2()
    ConfigV2.IsHolding = false
    if ConfigV2.HoldConnection then
        ConfigV2.HoldConnection:Disconnect()
        ConfigV2.HoldConnection = nil
    end
    
    pcall(function()
        local vu = game:GetService("VirtualUser")
        if vu then
            vu:Button1Up(Vector2.new(500, 500))
        end
    end)
end

local function StartHoldingCompassV2()
    if ConfigV2.IsHolding then return end
    ConfigV2.IsHolding = true
    
    if ConfigV2.HoldConnection then
        ConfigV2.HoldConnection:Disconnect()
        ConfigV2.HoldConnection = nil
    end
    
    ConfigV2.HoldConnection = RunService.Heartbeat:Connect(function()
        if not _G.AutoTeleportV2 or not ConfigV2.IsHolding then return end
        
        if not IsHoldingCompassV2() then
            ForceEquipCompassV2()
        end
        
        pcall(function()
            local vu = game:GetService("VirtualUser")
            if vu then
                vu:CaptureController()
                vu:Button1Down(Vector2.new(500, 500))
            end
        end)
    end)
end

local function StartAutoClickCompassV2()
    if ConfigV2.AutoClickConnection then return end
    
    ConfigV2.AutoClickConnection = RunService.Heartbeat:Connect(function()
        if not _G.AutoTeleportV2 then return end
        
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool and tool.Name == "Compass" then
            pcall(function()
                tool:Activate()
                local vu = game:GetService("VirtualUser")
                if vu then
                    vu:CaptureController()
                    vu:Button1Down(Vector2.new(999, 999))
                end
            end)
        end
    end)
end

local function StopAutoClickCompassV2()
    if ConfigV2.AutoClickConnection then
        ConfigV2.AutoClickConnection:Disconnect()
        ConfigV2.AutoClickConnection = nil
    end
end

local function LockCharacterV2()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = false
    end
end

local function UnlockCharacterV2()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
    end
end

local function StopFlyV2()
    ConfigV2.IsFlying = false
    if ConfigV2.FlyConnection then
        ConfigV2.FlyConnection:Disconnect()
        ConfigV2.FlyConnection = nil
    end
    ConfigV2.CurrentFlyPos = nil
    ConfigV2.IsSpinning = false
    ConfigV2.RotationHistory = {}
end

local function StartFlyV2()
    if ConfigV2.IsFlying then return end
    
    if not ForceEquipCompassV2() then
        Fluent:Notify({
            Title = "⚠️ LỖI",
            Content = "Không tìm thấy Compass!",
            Duration = 3
        })
        _G.AutoTeleportV2 = false
        pcall(function()
            Tabs.Main:GetToggle("AutoTeleportCompassV2"):SetValue(false)
        end)
        return
    end
    
    ConfigV2.IsFlying = true
    ConfigV2.LastValidDir = nil
    ConfigV2.IsSpinning = false
    ConfigV2.RotationHistory = {}
    
    local char = LocalPlayer.Character
    if not char then ConfigV2.IsFlying = false return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then ConfigV2.IsFlying = false return end
    
    local pos = hrp.Position
    hrp.CFrame = CFrame.new(pos.X, 300, pos.Z)
    ConfigV2.CurrentFlyPos = Vector3.new(pos.X, 300, pos.Z)
    
    if ConfigV2.FlyConnection then
        ConfigV2.FlyConnection:Disconnect()
        ConfigV2.FlyConnection = nil
    end
    
    ConfigV2.FlyConnection = RunService.Heartbeat:Connect(function()
        if not _G.AutoTeleportV2 or not ConfigV2.IsFlying then return end
        
        if StopOnLostCompassV2() then
            ConfigV2.IsFlying = false
            if ConfigV2.FlyConnection then
                ConfigV2.FlyConnection:Disconnect()
                ConfigV2.FlyConnection = nil
            end
            return
        end
        
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local dir = GetStableDirectionV2()
        if not dir then return end
        
        local isSpinning = DetectSpinningV2(dir)
        if isSpinning and not ConfigV2.IsSpinning then
            ConfigV2.IsSpinning = true
        elseif not isSpinning and ConfigV2.IsSpinning then
            ConfigV2.IsSpinning = false
            ConfigV2.RotationHistory = {}
        end
        
        local isSudden = false
        if ConfigV2.LastValidDir then
            isSudden = DetectSuddenChangeV2(ConfigV2.LastValidDir, dir)
        end
        
        if isSudden or ConfigV2.IsSpinning then
            local radius = ConfigV2.IsSpinning and ConfigV2.ScanRadiusSpinning or ConfigV2.ScanRadiusSudden
            local spawners = ScanSpawnersAdvancedV2(dir, ConfigV2.CurrentFlyPos, radius, ConfigV2.IsSpinning)
            
            if #spawners > 0 then
                TeleportToSpawnersV2(spawners)
                return
            end
        end
        
        ConfigV2.LastValidDir = dir
        
        local dirVec = Vector3.new(math.sin(dir), 0, -math.cos(dir))
        local speed = ConfigV2.IsSpinning and ConfigV2.FlySpeed * 0.5 or ConfigV2.FlySpeed
        
        ConfigV2.CurrentFlyPos = ConfigV2.CurrentFlyPos + dirVec * (speed * 0.1)
        ConfigV2.CurrentFlyPos = Vector3.new(ConfigV2.CurrentFlyPos.X, 300, ConfigV2.CurrentFlyPos.Z)
        
        hrp.CFrame = CFrame.new(ConfigV2.CurrentFlyPos)
        pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
        
        for key, time in pairs(ConfigV2.TeleportedSpawners) do
            if os.time() - time > 30 then
                ConfigV2.TeleportedSpawners[key] = nil
            end
        end
    end)
end

Tabs.Samauto:AddToggle("AutoTeleportCompassV2", {
    Title = "Auto Find Sam V2",
    Description = "Use Fly",
    Default = false,
    Callback = function(Value)
        if Value ~= nil then
            _G.AutoTeleportV2 = Value
            if not _G.AutoTeleportV2 then
                StopHoldingCompassV2()
                StopAutoClickCompassV2()
                StopFlyV2()
                UnlockCharacterV2()
                ConfigV2.DirectionHistory = {}
                ConfigV2.TeleportedSpawners = {}
                ConfigV2.CurrentFlyPos = nil
                ConfigV2.RotationHistory = {}
                ConfigV2.IsSpinning = false
            else
                task.wait(0.5)
                ConfigV2.DirectionHistory = {}
                ConfigV2.TeleportedSpawners = {}
                ConfigV2.CurrentFlyPos = nil
                ConfigV2.RotationHistory = {}
                ConfigV2.IsSpinning = false
                
                if ForceEquipCompassV2() then
                    StartHoldingCompassV2()
                    StartAutoClickCompassV2()
                    LockCharacterV2()
                    StartFlyV2()
                else
                    _G.AutoTeleportV2 = false
                    StopAutoClickCompassV2()
                    StopFlyV2()
                    UnlockCharacterV2()
                    pcall(function()
                        Tabs.Main:GetToggle("AutoTeleportCompassV2"):SetValue(false)
                    end)
                end
            end
        end
    end
})


local AutoHakivutrangEnabled = false
local AutoHakiEnabled = false


-- Hàm lấy Character an toàn
local function getCharacter()
    return LocalPlayer.Character
end

-- Vòng lặp kiểm tra Haki
task.spawn(function()
    while true do
        task.wait(2)
        if AutoHakiEnabled then
            local char = getCharacter()
            if char then
                local observation = char:GetAttribute("Observation")
                if not observation then
                    pcall(function()
                        VirtualInput:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        task.wait(0.1)
                        VirtualInput:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                    end)
                end
            end
        end
    end
end)



Tabs.Hakis:AddToggle("AutoHakiToggle", {
    Title = "Auto Enable Observation",
    Default = false,
    Callback = function(Value)
        AutoHakiEnabled = Value
    end
})





-- Vòng lặp kiểm tra Haki chạy ngầm độc lập
task.spawn(function()
    while true do
        task.wait(2)
        if AutoHakivutrangEnabled then
            local char = getCharacter()
            if char then
                local observation = char:GetAttribute("Busoshoku")
                if not observation then
                    pcall(function()
                        VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end)
                end
            end
        end
    end
end)

-- Tạo Toggle tích hợp vào UI
Tabs.Hakis:AddToggle("AutoHakiBusoshoku", {
    Title = "Auto Enable Busoshoku",
    Default = false,
    Callback = function(Value)
        AutoHakivutrangEnabled = Value
    end
})


-- ====== AUTO TELEPORT HAKI + KIỂM TRA HAKI ======

local autoTeleHaki = false
local targetPosHaki = Vector3.new(2170, 216, -632)

-- Biến kiểm tra Haki
local hasNotified = false
local lastStatus = nil
local isCheckingHaki = false -- Trạng thái kiểm tra Haki

-- Hàm kiểm tra Haki
local function CheckHaki()
    if not isCheckingHaki then return end -- Nếu không bật thì không kiểm tra
    
    pcall(function()
        local PlayerGui = LocalPlayer.PlayerGui
        if not PlayerGui then return end
        
        local HealthBar = PlayerGui:FindFirstChild("HealthBar")
        if not HealthBar then return end
        
        local Frame = HealthBar:FindFirstChild("Frame")
        if not Frame then return end
        
        local Haki = Frame:FindFirstChild("Haki")
        if not Haki then return end
        
        local HakiFrame = Haki:FindFirstChild("Frame")
        if not HakiFrame then return end
        
        local currentSize = HakiFrame.Size
        local xScale = currentSize.X.Scale
        
        -- Xác định trạng thái hiện tại (ngưỡng 0.02)
        local isHakiEmpty = xScale < 0.02
        
        -- Chỉ in khi trạng thái thay đổi
        if lastStatus ~= isHakiEmpty then
            lastStatus = isHakiEmpty
            if isHakiEmpty then
          
                 local placeId = game.PlaceId
    local jobId = game.JobId
    local servers = {}
    local cursor = ""
    local pagesScanned = 0
    
    repeat
  
        local url = "https://games.roproxy.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100&cursor=" .. cursor
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if success and response and response.data then
            for _, server in pairs(response.data) do
                if server.id and server.id ~= jobId and server.playing and server.playing > 0 then
                    table.insert(servers, server)
                end
            end
            cursor = response.nextPageCursor or ""
            pagesScanned = pagesScanned + 1
        else
            break
        end
        task.wait(0.1)
    until cursor == "" or #servers >= 30 or pagesScanned >= 5

    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        task.wait(0.5)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, randomServer.id, LocalPlayer)
        end)
    else
        task.wait(0.5)
        pcall(function()
            TeleportService:Teleport(placeId, LocalPlayer)
              
        end)
    end
            else
           
            end
        end
        
        -- Báo khi hết Haki
        if isHakiEmpty then
            if not hasNotified then
                hasNotified = true
            
                
                -- TỰ ĐỘNG TẮT TOGGLE KHI HẾT HAKI
                autoTeleHaki = false
                isCheckingHaki = false
                
                -- Unanchor nhân vật
                pcall(function()
                    local character = LocalPlayer.Character
                    if character then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            rootPart.Anchored = false
                        end
                    end
                end)
            end
        else
            -- Reset khi Haki hồi (X.Scale >= 0.4)
            if xScale >= 0.4 then
                if hasNotified then
           
                end
                hasNotified = false
            end
        end
    end)
end

-- Toggle Auto Teleport Haki
Tabs.Hakis:AddToggle("AutoFarmHaki", {
    Title = "Auto Farm Haki Rejoin",
    Default = false,
    Callback = function(Value)
        autoTeleHaki = Value
        isCheckingHaki = Value -- Bật/tắt kiểm tra Haki theo toggle
        
        if Value then
        
            hasNotified = false -- Reset trạng thái đã báo
            lastStatus = nil
        else
        
            
            -- Unanchor nhân vật khi tắt
            pcall(function()
                local character = LocalPlayer.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        rootPart.Anchored = false
                    end
                end
            end)
        end
        
        task.spawn(function()
            while autoTeleHaki do
                pcall(function()
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    if character then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            local distance = (rootPart.Position - targetPosHaki).Magnitude
                            
                            if distance > 3 then
                                rootPart.Anchored = false
                                task.wait(0.05)
                                rootPart.CFrame = CFrame.new(targetPosHaki)
                                task.wait(0.2)
                            else
                                rootPart.Anchored = true
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
            
            if not autoTeleHaki then
                pcall(function()
                    local character = LocalPlayer.Character
                    if character then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            rootPart.Anchored = false
                        end
                    end
                end)
            end
        end)
    end
})

-- Kiểm tra Haki liên tục (chỉ khi isCheckingHaki = true)
task.spawn(function()
    while task.wait(0.1) do
        CheckHaki()
    end
end)


-- K
Tabs.Hakis:AddSection("Step Haki V1")

local AutoFindOldBook = false

-- Tạo toggle Auto Find Old Book
Tabs.Hakis:AddToggle("AutoFindOldBook", {
    Title = "Auto Find Old Book",
    Default = false
}):OnChanged(function(Value)
    AutoFindOldBook = Value
    
    if Value then
        task.spawn(function()
            while AutoFindOldBook do
                local shouldBreak = false
                
                pcall(function()
                    local player = game:GetService("Players").LocalPlayer
                    if not player then return end
                    
                    local character = player.Character
                    if not character then return end
                    
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end
                    
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    
                    -- TỰ ĐỘNG NHẢY LIÊN TỤC 0.1s
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    
                    -- KIỂM TRA BACKPACK CÓ OLD BOOK
                    local backpack = player:FindFirstChild("Backpack")
                    if backpack and backpack:FindFirstChild("Old Book") then
                      
                        shouldBreak = true
                        return
                    end
                    
                    -- Tìm Chest
                    local foundChest = false
                    for _, object in pairs(game:GetService("Workspace"):GetDescendants()) do
                        if not AutoFindOldBook then break end
                        
                        if object.Name == "Chest" or (type(object.Name) == "string" and object.Name:find("Chest")) then
                            local targetPart = (object:IsA("BasePart") and object) or object:FindFirstChildWhichIsA("BasePart")
                            
                            if targetPart and targetPart:IsDescendantOf(game:GetService("Workspace")) then
                                foundChest = true
                                
                                if (rootPart.Position - targetPart.Position).Magnitude > 3 then
                                    rootPart.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 2, 0))
                                    rootPart.Velocity = Vector3.new(0, 3, 3)
                                    rootPart.RotVelocity = Vector3.new(3, 0, 0)
                                end
                                
                                if instantTouch then
                                    instantTouch(targetPart)
                                end
                                
                                task.wait(0.0001)
                            end
                        end
                    end
                    
                    if not foundChest then
                        task.wait(0.001)
                    end
                end)
                
                -- Xử lý break bên ngoài pcall
                if shouldBreak then
                    AutoFindOldBook = false
                    Tabs.Hakis:GetToggle("AutoFindOldBook"):SetValue(false)
                    break
                end
                
                task.wait(0.001)
            end
           
        end)
    end
end)



Tabs.Hakis:AddButton({
    Title = "Tele Dance Buy Emotes",
    Callback = function()
        task.spawn(function()
            local player = game:GetService("Players").LocalPlayer
            local character = player and player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if not rootPart then
                return
            end
            
            local pos = Vector3.new(1517, 260, 2168)
            rootPart.CFrame = CFrame.new(pos)
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.RotVelocity = Vector3.new(0, 0, 0)
        end)
    end
})

local RingDropdown = Tabs.Hakis:AddDropdown("RingTeleport", {
    Title = "Teleport to Ring",
    Description = "",
    Values = {},
    Multi = false,
    Default = 1
})

local function LoadRings()
    local ringList = {}
    local rings = workspace:FindFirstChild("MapFolder") and workspace.MapFolder:FindFirstChild("Rings")
    
    if rings then
        for _, child in pairs(rings:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                table.insert(ringList, child.Name)
            end
        end
    end
    
    if #ringList == 0 then
        table.insert(ringList, "Không có Ring")
    end
    
    return ringList
end

RingDropdown:SetValues(LoadRings())

RingDropdown:OnChanged(function(selected)
    if not selected or selected == "Không có Ring" then return end
    
    task.spawn(function()
        local player = game:GetService("Players").LocalPlayer
        if not player then
            return
        end
        
        local character = player.Character
        if not character then
            return
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            return
        end
        
        local rings = workspace:FindFirstChild("MapFolder") and workspace.MapFolder:FindFirstChild("Rings")
        if rings then
            local target = rings:FindFirstChild(selected)
            if target then
                local part = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart")
                if part then
                    rootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                    rootPart.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
end)

Tabs.Hakis:AddButton({
    Title = "Refresh Ring List",
    Description = "Load lại danh sách Ring",
    Callback = function()
        local newRings = LoadRings()
        RingDropdown:SetValues(newRings)
    end
})

local LastClickTime3 = 0
local isCollecting = false

local function ClickOnFruit3(tool)
    if tick() - LastClickTime3 < 0.1 then return end
    pcall(function()
        if not tool or not tool.Parent or not fireclickdetector then return end
        LastClickTime3 = tick()
        local main1 = tool:FindFirstChild("Main1")
        if main1 then
            local cd = main1:FindFirstChildOfClass("ClickDetector")
            if cd then fireclickdetector(cd); return end
        end
        local cd = tool:FindFirstChildOfClass("ClickDetector") or tool:FindFirstChildWhichIsA("ClickDetector", true)
        if cd then fireclickdetector(cd) end
    end)
end

Tabs.Fruits:AddButton({
    Title = "Bring All Fruit",
    Description = "Fruit Workspace Here",
    Callback = function()
        if isCollecting then 
            return 
        end
        
        isCollecting = true
        task.spawn(function()
            local fruits = {}
            for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
                if v:IsA("Tool") and v.Name:find("Fruit") then
                    table.insert(fruits, v)
                end
            end
            
            if #fruits == 0 then
                isCollecting = false
                return
            end
            
            local collected = 0
            for i, fruit in ipairs(fruits) do
                if fruit.Parent then
                    task.wait(math.random(10, 30) / 100)
                    
                    local success = pcall(function()
                        ClickOnFruit3(fruit)
                        collected = collected + 1
                    end)
                    
                    if not success then
                        task.wait(0.5)
                        pcall(function()
                            ClickOnFruit3(fruit)
                            collected = collected + 1
                        end)
                    end
                end
            end
            
            isCollecting = false
        end)
    end
})

Tabs.Fruits:AddButton({
    Title = "Bring Reset Token",
    Description = "",
    Callback = function()
        task.spawn(function()
            local player = game:GetService("Players").LocalPlayer
            if not player then
                return
            end
            
            local character = player.Character
            if not character then
                return
            end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                return
            end
            
            local teleported = 0
            local pos = rootPart.Position
            
            for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
                if v.Name == "Reset Token" and v.Parent and v.Parent ~= player.Backpack then
                    pcall(function()
                        local part = nil
                        if v:IsA("Model") or v:IsA("Tool") then
                            for _, child in pairs(v:GetDescendants()) do
                                if child:IsA("BasePart") then
                                    part = child
                                    break
                                end
                            end
                        elseif v:IsA("BasePart") then
                            part = v
                        end
                        
                        if part then
                            part.CFrame = CFrame.new(pos + Vector3.new(0, teleported * 2, 0))
                            teleported = teleported + 1
                            task.wait(0.05)
                        end
                    end)
                end
            end
        end)
    end
})



local isDropping = false

Tabs.Samauto:AddButton({
    Title = "Drop All Tool",
    Description = "",
    Callback = function()
        if isDropping then return end
        isDropping = true
        
        task.spawn(function()
            local Character = LocalPlayer.Character
            local Backpack = LocalPlayer:FindFirstChild("Backpack")
            
            if not Character or not Backpack then
                isDropping = false
                return
            end
            
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if not Humanoid then
                isDropping = false
                return
            end
            
            local tools = {}
            for _, v in pairs(Backpack:GetChildren()) do
                if v:IsA("Tool") then
                    table.insert(tools, v)
                end
            end
            
            if #tools == 0 then
                isDropping = false
                return
            end
            
            for i, tool in ipairs(tools) do
                pcall(function()
                    if tool.Parent == Backpack then
                        Humanoid:EquipTool(tool)
                        task.wait(0.001)
                    end
                    
                    if tool.Parent == Character then
                        SendChat("!drop")
                        task.wait(0.1)
                    end
                end)
            end

            isDropping = false
        end)
    end
})
