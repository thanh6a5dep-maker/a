local HttpService = game:GetService("HttpService")
local URL = "https://raw.githubusercontent.com/cthanh137/MyHub.lua/refs/heads/main/Getkeyhwid.lua"

local function CheckSubscription()
    local success, response = pcall(function()
        return game:HttpGet(URL)
    end)

    if success then
        -- Kiểm tra xem nội dung trả về có chứa từ khóa "hoạt động" hay không
        if string.find(response, "Rabit") then
            local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local ContextActionService= game:GetService("ContextActionService")
local VirtualUser         = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService     = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local CoreGui             = game:GetService("CoreGui")
local LocalPlayer  = Players.LocalPlayer
local Camera       = workspace.CurrentCamera
local Workspace    = workspace
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("OpenUI") then
    CoreGui.OpenUI:Destroy()
end

local OpenUI = Instance.new("ScreenGui")
OpenUI.Name = "OpenUI"
OpenUI.Parent = CoreGui
OpenUI.ResetOnSpawn = false

-- Bóng
local Shadow = Instance.new("TextLabel")
Shadow.Parent = OpenUI
Shadow.Size = UDim2.fromOffset(55,55)
Shadow.Position = UDim2.new(0.05,3,0.3,3) -- lệch xuống phải
Shadow.BackgroundTransparency = 1
Shadow.Text = "🐇"
Shadow.TextSize = 40
Shadow.TextColor3 = Color3.fromRGB(0,0,0)
Shadow.TextTransparency = 0.5
Shadow.ZIndex = 0

-- Nút chính
local Button = Instance.new("TextButton")
Button.Parent = OpenUI
Button.Size = UDim2.fromOffset(55,55)
Button.Position = UDim2.new(0.05,0,0.3,0)

Button.Text = "👑"
Button.TextSize = 40
Button.TextColor3 = Color3.new(1,1,1)

Button.BackgroundTransparency = 1
Button.BorderSizePixel = 0

Button.Active = true
Button.Draggable = true
Button.AutoButtonColor = true
Button.ZIndex = 1

-- Di chuyển bóng theo nút
Button:GetPropertyChangedSignal("Position"):Connect(function()
    Shadow.Position = Button.Position + UDim2.fromOffset(3,3)
end)

Button.MouseButton1Click:Connect(function()
    VIM:SendKeyEvent(true, Enum.KeyCode.P, false, game)
    task.wait()
    VIM:SendKeyEvent(false, Enum.KeyCode.P, false, game)
end)




-- =========================================================================
-- NÚT MỞ UI (🎮)
-- =========================================================================

-- =========================================================================
-- LOAD FLUENT UI
-- =========================================================================
local Fluent          = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager     = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager= loadstring(game:HttpGet("https://raw.githubusercontent.com/cthanh137/MyHub.lua/refs/heads/main/SeverVipCreateJoin.lua"))()

local Window = Fluent:CreateWindow({
    Title      = "RABBIT FINAL | " .. Fluent.Version,
    SubTitle   = "Time Fix Gần nhất 5:40",
    TabWidth   = 160,
    Size       = UDim2.fromOffset(550, 450),
    Acrylic    = true,
    Theme      = "Darker",
    MinimizeKey= Enum.KeyCode.P,
})

local Tabs = {
    Main     = Window:AddTab({ Title = "Main",                Icon = "layout-dashboard" }), 
    Farm     = Window:AddTab({ Title = "Farm Setting",                Icon = "shovel"           }),
    Fishs     = Window:AddTab({ Title = "Fishing",                Icon = "anchor"           }),
    chiso     = Window:AddTab({ Title = "Farm Stats",                Icon = "star" }),
    Players  = Window:AddTab({ Title = "Player",              Icon = "users"            }),
    Map      = Window:AddTab({ Title = "Location",            Icon = "map-pin"          }),
    Fruits   = Window:AddTab({ Title = "Sniper Fruit & Compass",    Icon = "box"            }),
    
    thongtin    = Window:AddTab({ Title = "Information",                Icon = "info" }),
    Settings = Window:AddTab({ Title = "Settings",            Icon = "sliders"          }),
}
local Options = Fluent.Options
local IsAutoFarmEnabled = false
local SelectedTargetName = nil

-- Hàm lấy danh sách quái

local States = {
    Fly         = false,
    FlySpeed    = 50,
    SpeedToggle = false,
    WalkSpeed   = 16,
    InfJump     = false,
    Spectate    = false,
    Player = {
        FlightSpeed  = 200,
        FlightEnabled= false,
        ESPEnabled   = false,
        FullSpy      = { SelectedPlayer = nil, Spectate = false, TPToPlayer = false },
    },
    Fruit = {
        AutoFruitEnabled  = false,
        AutoCompassEnabled= false,
    },
}

-- =========================================================================
-- AUTO FARM MOB
-- =========================================================================
-- Khai báo hệ thống (Bổ sung để tránh lỗi trùng/thiếu biến)
-- Khai báo hệ thống (Bổ sung để tránh lỗi trùng/thiếu biến)
-- Định nghĩa các Services hệ thống (Bắt buộc để không bị lỗi ẩn)




-- Khai báo Service (Tránh lỗi chưa định nghĩa)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local SelectedMobs = {}
local IsAutoFarmEnabled = false
local FarmMode = "Đứng kế bên"
local OffsetDistance = 3

-- Hàm lấy danh sách quái
local function GetMobs()
    local mobs, added = {}, {}
    local Alive = workspace:FindFirstChild("Alive")
    if not Alive then return mobs end
    for _, mob in ipairs(Alive:GetChildren()) do
        if mob and mob.Name and not added[mob.Name] then
            added[mob.Name] = true
            table.insert(mobs, mob.Name)
        end
    end
    table.sort(mobs)
    return mobs
end

-- UI Setup (Fluent / Linoria)
local MobDropdown = Tabs.Farm:AddDropdown("MobSelectFinalUltimate", {
    Title = "Select Mob", Values = GetMobs(), Multi = true, Default = {},
})
MobDropdown:OnChanged(function(Value) SelectedMobs = Value end)

Tabs.Farm:AddDropdown("FarmModeSelect", {
    Title = "Chế độ Farm",
    Values = {"Đứng trên cao", "Đứng kế bên", "Dưới lòng đất"},
    Default = "Đứng kế bên",
    Callback = function(Value) FarmMode = Value end
})

Tabs.Farm:AddButton({ Title = "Refresh Mob", Callback = function()
    MobDropdown:SetValues(GetMobs())
end })

Tabs.Farm:AddToggle("FarmToggleFinalUltimate", {
    Title = "Auto Farm", Default = false
}):OnChanged(function(Value) IsAutoFarmEnabled = Value end)

-- Hàm tìm mục tiêu gần nhất
local function FindNearestTarget(myHRP)
    local Alive = workspace:FindFirstChild("Alive")
    if not Alive or not SelectedMobs or not myHRP then return nil end
    local nearestMob, shortestDistance = nil, math.huge
    for _, mob in ipairs(Alive:GetChildren()) do
        local isSelected = (typeof(SelectedMobs) == "table" and SelectedMobs[mob.Name]) or (table.find(SelectedMobs, mob.Name))
        if isSelected then
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            local hum = mob:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (myHRP.Position - hrp.Position).Magnitude
                if d < shortestDistance then shortestDistance = d; nearestMob = mob end
            end
        end
    end
    return nearestMob
end

-- [NÂNG CẤP] Luồng 1: Auto Respawn + Auto Equip Tool
task.spawn(function()
    while true do
        task.wait(0.5)
        if IsAutoFarmEnabled then
            local char = LocalPlayer.Character
            local myHum = char and char:FindFirstChildOfClass("Humanoid")
            
            -- Auto Respawn
            if not char or (myHum and myHum.Health <= 0) then
                pcall(function() LocalPlayer:LoadCharacter() end)
                task.wait(2)
            else
                -- Auto Equip Tool: Nếu trong người không cầm Tool, tìm trong Backpack để cầm lên
                if not char:FindFirstChildOfClass("Tool") then
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    local tool = backpack and backpack:FindFirstChildOfClass("Tool")
                    if tool then
                        myHum:EquipTool(tool)
                    end
                end
            end
        end
    end
end)

-- Luồng 2: Auto Click (Giữ nguyên sự ổn định)
task.spawn(function()
    while true do
        task.wait(0.05) -- Tốc độ click tối ưu, không quá nhanh gây crash remote
        if IsAutoFarmEnabled then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function()
                        tool:Activate()
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(999, 999))
                    end)
                end
            end
        end
    end
end)

-- [NÂNG CẤP MẠNH] Luồng 3: Tối ưu vị trí & Noclip bằng RunService
RunService.Stepped:Connect(function()
    if not IsAutoFarmEnabled then return end
    
    local char = LocalPlayer.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    -- 1. Kích hoạt Noclip xuyên tường khi đang farm để tránh kẹt map
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
    
    -- 2. Tìm quái và di chuyển mượt mà
    local targetMob = FindNearestTarget(myHRP)
    if targetMob then
        local mobHRP = targetMob:FindFirstChild("HumanoidRootPart")
        if mobHRP then
            local offset
            if FarmMode == "Đứng trên cao" then
                offset = CFrame.new(0, 5, 0)
            elseif FarmMode == "Dưới lòng đất" then
                offset = CFrame.new(0, -5, 0)
            else 
                offset = CFrame.new(0, 0, OffsetDistance)
            end
            
            -- Tính toán vị trí đích hướng mặt về phía quái
            local targetCFrame = mobHRP.CFrame * offset
            myHRP.CFrame = CFrame.lookAt(targetCFrame.Position, mobHRP.Position)
            
            -- Triệt tiêu hoàn toàn mọi lực vật lý (tránh bị văng)
            myHRP.AssemblyLinearVelocity = Vector3.zero
            myHRP.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)
-- AUTO EQUIP WEAPON
-- =========================================================================
local SelectedWeapon   = nil
local AutoEquipWeapon  = false

local function GetWeapons()
    local list, seen = {}, {}
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local char     = LocalPlayer.Character
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
WeaponDropdown:OnChanged(function(Value) SelectedWeapon = Value end)

Tabs.Farm:AddButton({ Title = "Refresh Weapon", Callback = function()
    WeaponDropdown:SetValues(GetWeapons())
end })

Tabs.Farm:AddToggle("AutoEquipWeapon", {
    Title = " Auto EquipWeapon", Default = false,
}):OnChanged(function(Value) AutoEquipWeapon = Value end)

task.spawn(function()
    while true do
        if not AutoEquipWeapon or not SelectedWeapon then task.wait(0.3); continue end
        local char    = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum     = char:FindFirstChildOfClass("Humanoid")
        local backpack= LocalPlayer:FindFirstChildOfClass("Backpack")
        if hum and hum.Health > 0 and backpack then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") and item.Name ~= SelectedWeapon then
                    item.Parent = backpack
                end
            end
            if not char:FindFirstChild(SelectedWeapon) then
                local tool = backpack:FindFirstChild(SelectedWeapon)
                if tool and tool:IsA("Tool") then
                    tool.Parent = char
                    task.wait(0.02)
                end
            end
        end
        task.wait(0.01)
    end
end)
local Trangvbi = Tabs.Farm:AddSection("Setting Hokey")
-- =========================================================================
-- AUTO SKILL (SPAM PHÍM)
-- =========================================================================
local SelectedKeys  = {}
local AutoSkillSpam = false

Tabs.Farm:AddDropdown("SkillKeys", {
    Title = "Chọn Phím Skill",
    Values = {"Z","X","C","V","B","Q","R","T","Y"},
    Multi = true, Default = {},
}):OnChanged(function(Value) SelectedKeys = Value end)

Tabs.Farm:AddToggle("AutoSkillSpam", {
    Title = "Auto Skill", Default = false,
}):OnChanged(function(Value) AutoSkillSpam = Value end)

task.spawn(function()
    while task.wait(0.05) do
        if not AutoSkillSpam then continue end
        for KeyName, Enabled in pairs(SelectedKeys) do
            if Enabled and Enum.KeyCode[KeyName] then
                VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode[KeyName], false, game)
                task.wait(0.03)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[KeyName], false, game)
            end
        end
    end
end)

-- =========================================================================
-- AUTO HOLD SKILL (GIỮ PHÍM)
-- =========================================================================
-- // Cấu hình ban đầu
local HoldKeys    = {} -- Sẽ lưu dạng { ["Z"] = true, ["X"] = true }
local HoldEnabled = false
local HoldTime    = 1 

-- Dropdown giữ phím
Tabs.Farm:AddDropdown("HoldSkillKeys", {
    Title = "Phím Giữ (Hold Skill)",
    Values = {"Z","X","C","V","B","Q","R","T","Y"},
    Multi = true, 
    Default = {},
}):OnChanged(function(v) 
    HoldKeys = v -- v ở đây là bảng { ["Phím"] = true/false }
end)

-- Toggle
Tabs.Farm:AddToggle("AutoHoldSkill", {
    Title = "Auto Giữ Phím Skill", Default = false,
}):OnChanged(function(v) HoldEnabled = v end)

-- Input nhập thời gian
Tabs.Farm:AddInput("HoldTimeInput", {
    Title = "Thời gian giữ phím (giây)",
    Default = "1",
    Placeholder = "1.0",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        HoldTime = tonumber(v) or 1
    end
})

-- Vòng lặp xử lý chính
task.spawn(function()
    while task.wait(0.1) do
        if not HoldEnabled then continue end
        
        -- Duyệt qua bảng HoldKeys
        for key, enabled in pairs(HoldKeys) do
            if not HoldEnabled then break end
            
            -- Chỉ chạy nếu phím đó đang được bật (enabled == true)
            if enabled then
                local k = Enum.KeyCode[key]
                if k then
                    -- Nhấn giữ
                    VirtualInputManager:SendKeyEvent(true, k, false, game)
                    task.wait(HoldTime)
                    -- Thả phím
                    VirtualInputManager:SendKeyEvent(false, k, false, game)
                    -- Nghỉ nhẹ giữa các phím
                    task.wait(0.1)
                end
            end
        end
    end
end)
local MapSection = Tabs.Map:AddSection("Teleport Island")
-- =========================================================================
-- TELEPORT - ĐỊA ĐIỂM
-- =========================================================================
local tpLocations = {
    ["Đảo tân thủ"]      = CFrame.new(-80,    216,   -296),
    ["Cave"]              = CFrame.new(2210, 216, -611),
    ["Admin tặng quà"]   = CFrame.new(-32.60, 200003, 195),
    ["Đảo Sam"]          = CFrame.new(-1279,  218,  -1351),
    ["Đảo cát lâu đài"]  = CFrame.new(1231,   224,  -3242),
    ["Nhiệm Vụ Box Fish"] = CFrame.new(-1693,  216,   -328),
    ["Đảo Tím"]          = CFrame.new(-5224,  518,  -7779),
    ["Đảo tuyết to"]     = CFrame.new(6313,   541,  -1330),
    ["Đảo tuyết"]        = CFrame.new(-1858,  297,   3156),
    ["Đảo tôn ngộ không"]= CFrame.new(4571,   226,   5110),
    ["Đảo nhà có cây"]   = CFrame.new(1120,   217,   3351),
    ["Đảo cây lớn"]      = CFrame.new(-5996,  362,    -10),
    ["Bãi đá"]      =CFrame.new(-971, 535, 11329),
     ["Kuimui"]      =CFrame.new(-10776, 354, 5989),
      ["Đảo trống"]      =CFrame.new(-11635, 276, -3827),
       ["Ai cập"]      =CFrame.new(786, 286, 5502),
        ["Tháp hải đăng"]      =CFrame.new(2086, 288, -1876),
         ["Chiến sự"]      =CFrame.new(4395, 319, -3259),
          ["vỏ óc"]      =CFrame.new(4759, 570, -7191),
           ["Đảo hải quân"]      =CFrame.new(-3019, 217, -3076),
    
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
TPDropdown:OnChanged(function(value) selectedTP = value end)

Tabs.Map:AddButton({ Title = "Teleport", Callback = function()
    if not selectedTP then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and tpLocations[selectedTP] then
        hrp.CFrame = tpLocations[selectedTP] + Vector3.new(0, 3, 0)
    end
end })

-- =========================================================================
-- TELEPORT - NPC
-- =========================================================================
local tpnpc = {
    ["C0"]                  = CFrame.new(902,   269,  1222),
    ["Cooker"]              = CFrame.new(1982,  217,   567),
    ["Fisherman"]           = CFrame.new(-1699, 215,  -327),
    ["Gemologist"]          = CFrame.new(-1235, 217,   634),
    ["Sam"]                 = CFrame.new(-1304, 217, -1351),
    ["Bart Nospmis"]        = CFrame.new(-432,  216,  -174),
    ["Bandit Leader"]       = CFrame.new(33,    295,  -826),
    ["Chill Billy"]         = CFrame.new(35,    232,  -193),
    ["Demon Hunter"]        = CFrame.new(-51,   217,  -914),
    ["Explorer"]            = CFrame.new(-520,  217,  -892),
    ["Fallen Captain"]      = CFrame.new(-237,  218,  -866),
    ["Guard Captain"]       = CFrame.new(-50,   262,   332),
    ["Joe"]                 = CFrame.new(-58,   215,  -317),
    ["Marge Nospmis"]       = CFrame.new(-102,  223,   -76),
    ["Old Beggar"]          = CFrame.new(186,   217,  -141),
    ["Rayleigh"]            = CFrame.new(-1010, 4010, 10132),
    ["Traceur"]             = CFrame.new(-294,  310,  -580),
    ["Lord"]                = CFrame.new(1787,  642,  13024),
    ["Strange Dealer"]      = CFrame.new(1243,  224,  -3241),
    ["Ana"]                 = CFrame.new(1110,  216,   3366),
    ["Better Drink Merchant"]= CFrame.new(1490, 260,   2170),
    ["Dancer"]              = CFrame.new(1520,  260,   2162),
    ["Drink Merchant"]      = CFrame.new(-1282, 218,  -1368),
    ["Kiruma"]              = CFrame.new(-1072, 361,   1665),
    ["Lucy"]                = CFrame.new(799,   230,   5351),
    ["Mad Scientist"]       = CFrame.new(-2602, 255,   1088),
    ["Sniper Merchant"]     = CFrame.new(-1844, 222,   3412),
    ["Sword Merchant"]      = CFrame.new(998,   223,  -3337),
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
NPCDropdown:OnChanged(function(value) selectedTPs = value end)

Tabs.Map:AddButton({ Title = "Teleport NPC", Callback = function()
    if not selectedTPs then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and tpnpc[selectedTPs] then
        hrp.CFrame = tpnpc[selectedTPs] + Vector3.new(0, 3, 0)
    end
end })

-- =========================================================================
-- AUTO FARM CHEST
-- =========================================================================
local AutoFarmChests = false

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
    AutoFarmChests = v
    if v then
        task.spawn(function()
            while AutoFarmChests do
                local character = LocalPlayer.Character
                local rootPart  = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    for _, object in pairs(Workspace:GetDescendants()) do
                        if not AutoFarmChests then break end
                        if object.Name == "Chest" or object.Name:find("Chest") then
                            local targetPart = (object:IsA("BasePart") and object)
                                            or object:FindFirstChildWhichIsA("BasePart")
                            if targetPart and targetPart:IsDescendantOf(Workspace) then
                                if (rootPart.Position - targetPart.Position).Magnitude > 3 then
                                    rootPart.CFrame   = CFrame.new(targetPart.Position + Vector3.new(0, 2, 0))
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

-- =========================================================================
-- AUTO FARM STATS (BARREL/CRATE + DRINK)
-- =========================================================================
local Running     = false
local DrinkEnabled= false

local TargetNames = { barrel = true, crate = true, bowl = true }
local DrinkList   = {
    ["Apple Juice"]  = true, ["Sour Juice"]   = true, ["Pumpkin Juice"] = true,
    ["Fruit Juice"]  = true, ["Banana Juice"]  = true, ["Golden Apple"]  = true,
    ["Coconut Milk"] = true, ["Pear Juice"]    = true,
}

local function GetChar() return LocalPlayer.Character end

-- Cơ chế Noclip liên tục: Luôn ép CanCollide = false trong mỗi khung hình
RunService.Stepped:Connect(function()
    if Running then
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
        if Running then
            local char = GetChar()
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not Running then break end
                    local lowerName = string.lower(obj.Name)
                    
                    if TargetNames[lowerName] then
                        local cd = obj:FindFirstChildWhichIsA("ClickDetector", true)
                        if cd then
                            local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPivot().Position)
                            if pos then
                                -- Teleport đến vị trí thấp hơn 5 đơn vị so với vật thể
                                -- Vì đã có Noclip liên tục, bạn sẽ không bị đẩy lên nữa
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
        if DrinkEnabled then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local char     = GetChar()
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
}):OnChanged(function(v) Running = v; DrinkEnabled = v end)

-- =========================================================================
-- PLAYER - SPEED / INF JUMP
-- =========================================================================
local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

local PlayerDropdown = Tabs.Players:AddDropdown("PlayerDropdown", {
    Title = "Chọn người chơi", Values = GetPlayerNames(), Multi = false, Default = "",
})
PlayerDropdown:OnChanged(function(Value)
    States.Player.FullSpy.SelectedPlayer = Players:FindFirstChild(Value or "")
end)

Tabs.Players:AddButton({
    Title = "Tải lại người chơi",
    Description = "Cập nhật lại danh sách người chơi trong server",
    Callback = function()
        local currentList = GetPlayerNames()
        PlayerDropdown:SetValues(currentList)
        PlayerDropdown:SetValue(currentList[1] or "")
    end,
})

local SpectateToggle = Tabs.Players:AddToggle("SpectateToggle", {
    Title = "Xem góc nhìn người chơi", Default = false,
})
SpectateToggle:OnChanged(function(Value)
    States.Player.FullSpy.Spectate = Value
    if not Value and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
    end
end)

local TPToggle = Tabs.Players:AddToggle("TPToggle", {
    Title = "Dịch chuyển đến người chơi", Default = false,
})
TPToggle:OnChanged(function(Value) States.Player.FullSpy.TPToPlayer = Value end)

task.spawn(function()
    while true do
        local target = States.Player.FullSpy.SelectedPlayer
        if target and target.Character then
            if States.Player.FullSpy.Spectate then
                local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                if tHum and Camera.CameraSubject ~= tHum then Camera.CameraSubject = tHum end
            end
            if States.Player.FullSpy.TPToPlayer and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = target.Character.HumanoidRootPart
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                end
                States.Player.FullSpy.TPToPlayer = false
                TPToggle:SetValue(false)
            end
        end
        if not States.Player.FullSpy.Spectate and LocalPlayer.Character then
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
    if States.Player.FullSpy.SelectedPlayer == plr then
        States.Player.FullSpy.Spectate = false
        SpectateToggle:SetValue(false)
        local lHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if lHum then Camera.CameraSubject = lHum end
    end
end)
UpdatePlayerDropdown()
local fff = Tabs.Players:AddSection("Chỉnh Người Chơi")
Tabs.Players:AddToggle("InfJumpToggle", {
    Title = "Nhảy Liên Tục", Default = false,
    Callback = function(Value) States.InfJump = Value end,
})

UserInputService.JumpRequest:Connect(function()
    if States.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)


-- =========================================================================
-- PLAYER - SPECTATE / TP TO PLAYER
-- =========================================================================
Tabs.Players:AddToggle("SpeedToggle", {
    Title = "Speed", Default = false,
    Callback = function(Value) States.SpeedToggle = Value end,
})
Tabs.Players:AddSlider("SpeedSlider", {
    Title = "Tốc độ chạy", Description = "Mặc định",
    Default = 16, Min = 16, Max = 500, Rounding = 0,
    Callback = function(Value) States.WalkSpeed = Value end,
})

task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if States.SpeedToggle then
                hum.WalkSpeed = States.WalkSpeed
            elseif hum.WalkSpeed == States.WalkSpeed then
                hum.WalkSpeed = 16
            end
        end
    end
end)

-- =========================================================================
-- PLAYER - FLY
-- =========================================================================
local flyConnection = nil

Tabs.Players:AddToggle("Flight", { Title = "Nhân vật bay", Default = false })
    :OnChanged(function(Value)
    States.Player.FlightEnabled = Value
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if Value then
        flyConnection = RunService.RenderStepped:Connect(function(dt)
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp     = LocalPlayer.Character.HumanoidRootPart
            local humanoid= LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local camCF   = Camera.CFrame
            if humanoid then humanoid.PlatformStand = true end
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W)          then moveDir += camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)          then moveDir -= camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)          then moveDir -= camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)          then moveDir += camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)      then moveDir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)  then moveDir -= Vector3.new(0,1,0) end
            if moveDir.Magnitude > 0 then
                hrp.CFrame   = hrp.CFrame + (moveDir.Unit * States.Player.FlightSpeed * dt)
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
    Title = "Tốc độ bay", Default = 200, Min = 100, Max = 5000, Rounding = 0,
    Callback = function(Value) States.Player.FlightSpeed = Value end,
})

-- =========================================================================
-- PLAYER - NOCLIP
-- =========================================================================
local noclipConnection

Tabs.Players:AddToggle("NoclipToggle", {
    Title = "Bật Noclip", Default = false, Description = "Đi xuyên vật thể",
}):OnChanged(function(Value)
    if Value then
        noclipConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

-- =========================================================================
-- PLAYER - ESP
-- =========================================================================
local ESPCache     = {}
local ESPConnection= nil

local function CreateESP(player)
    if ESPCache[player] then return end
    local Box     = Drawing.new("Square")
    Box.Visible   = false; Box.Color = Color3.fromRGB(255,0,0); Box.Thickness = 1.5; Box.Filled = false
    local Tracer  = Drawing.new("Line")
    Tracer.Visible= false; Tracer.Color = Color3.fromRGB(255,255,255); Tracer.Thickness = 1
    local NameTag = Drawing.new("Text")
    NameTag.Visible = false; NameTag.Text = player.Name
    NameTag.Color   = Color3.fromRGB(255,255,255); NameTag.Size = 14
    NameTag.Center  = true; NameTag.Outline = true; NameTag.OutlineColor = Color3.fromRGB(0,0,0)
    ESPCache[player] = { Box = Box, Tracer = Tracer, NameTag = NameTag }
end

local function RemoveESP(player)
    if ESPCache[player] then
        ESPCache[player].Box:Destroy()
        ESPCache[player].Tracer:Destroy()
        ESPCache[player].NameTag:Destroy()
        ESPCache[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

local function StartESP()
    ESPConnection = RunService.RenderStepped:Connect(function()
        for player, drawings in pairs(ESPCache) do
            local char = player.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if States.Player.ESPEnabled and char and hrp and hum and hum.Health > 0 then
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local head    = char:FindFirstChild("Head")
                    local headPos = head and Camera:WorldToViewportPoint(head.Position)
                                        or Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,2,0))
                    local legPos  = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                    local height  = math.abs(headPos.Y - legPos.Y)
                    local width   = height / 1.5
                    drawings.Box.Size       = Vector2.new(width, height)
                    drawings.Box.Position   = Vector2.new(hrpPos.X - width/2, hrpPos.Y - height/2)
                    drawings.Box.Visible    = true
                    drawings.Tracer.From    = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    drawings.Tracer.To      = Vector2.new(hrpPos.X, hrpPos.Y + height/2)
                    drawings.Tracer.Visible = true
                    drawings.NameTag.Position= Vector2.new(hrpPos.X, hrpPos.Y - height/2 - 18)
                    drawings.NameTag.Visible = true
                else
                    drawings.Box.Visible = false; drawings.Tracer.Visible = false; drawings.NameTag.Visible = false
                end
            else
                drawings.Box.Visible = false; drawings.Tracer.Visible = false; drawings.NameTag.Visible = false
            end
        end
    end)
end

local function StopESP()
    if ESPConnection then ESPConnection:Disconnect(); ESPConnection = nil end
    for _, drawings in pairs(ESPCache) do
        drawings.Box.Visible = false; drawings.Tracer.Visible = false; drawings.NameTag.Visible = false
    end
end

Tabs.Players:AddToggle("PlayerESP", { Title = "Bật ESP Player", Default = false })
    :OnChanged(function(Value)
    States.Player.ESPEnabled = Value
    if Value then StartESP() else StopESP() end
end)

-- =========================================================================
-- AUTO FRUIT COLLECTOR (dùng ChildAdded thay Heartbeat)
-- =========================================================================
local RareFruitsSet = {
    "rumble","light","quake","magma","flare","paw","sand","rubber","string","dark",
    "phoenix","ice","rare box","ultra rare box","candy","gas","plasma","buddha",
    "chilly","gravity","gum","ope","dough","flare","snow"
}
-- chuyển thành lookup table để so khớp nhanh hơn
local RareFruitsLookup = {}
for _, f in ipairs(RareFruitsSet) do RareFruitsLookup[f] = true end

local BlacklistFruit = { ["small flooper"]=true,["large flooper"]=true,["huge flooper"]=true,["medium flooper"]=true,["cooked small flooper"]=true }

local function IsRareFruit(name)
    if not name then return false end
    local ln = string.lower(name)
    if BlacklistFruit[ln] then return false end
    if string.find(ln,"juice") or string.find(ln,"sling") or string.find(ln,"shot") then return false end
    for key in pairs(RareFruitsLookup) do
        if string.find(ln, key) then return true end
    end
    return false
end

local ActiveFruits   = {}
local LastClickTime  = 0

local function ClickOnFruit(tool)
    if tick() - LastClickTime < 0.1 then return end
    pcall(function()
        if not tool or not tool.Parent or not fireclickdetector then return end
        LastClickTime = tick()
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
        if obj:IsA("Tool") and IsRareFruit(obj.Name) then RegisterFruit(obj) end
    end
end

Tabs.Fruits:AddToggle("AutoFruitCollector", {
    Title = "Auto Bring Rare Fruits and Ultra and Box",
    Description = "Spawm or Drop ",
    Default = false,
}):OnChanged(function(Value)
    States.Fruit.AutoFruitEnabled = Value
    if Value then task.spawn(QuickScanExistingFruits) else table.clear(ActiveFruits) end
end)

task.spawn(function()
    while true do
        if States.Fruit.AutoFruitEnabled then
            local hasFruit = false
            for tool in pairs(ActiveFruits) do
                if not tool or not tool.Parent or tool.Parent ~= workspace then
                    ActiveFruits[tool] = nil; continue
                end
                hasFruit = true
                ClickOnFruit(tool)
            end
            task.wait(hasFruit and 0.1 or 0.5)
        else
            task.wait(1)
        end
    end
end)

-- ChildAdded thay thế Heartbeat — chỉ kích hoạt khi có vật phẩm mới xuất hiện
workspace.ChildAdded:Connect(function(obj)
    if States.Fruit.AutoFruitEnabled and obj:IsA("Tool") and IsRareFruit(obj.Name) then
        RegisterFruit(obj)
    end
end)

-- =========================================================================
-- AUTO COMPASS COLLECTOR
-- =========================================================================
-- // CÁC HÀM CŨ CỦA BẠN //
local ProcessedCompass = {}

local function TouchCompass(tool)
    if not tool or not tool.Parent or ProcessedCompass[tool] then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true)
    if handle and handle:IsA("BasePart") then
        pcall(function()
            ProcessedCompass[tool] = true
            firetouchinterest(hrp, handle, 0)
            task.wait(0.05)
            firetouchinterest(hrp, handle, 1)
        end)
    end
end

-- // HÀM QUÉT TOÀN BỘ MAP (Giải quyết vấn đề quét lại)
local function FullMapScan()
    if not States.Fruit.AutoCompassEnabled then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and string.find(string.lower(obj.Name), "compass") then
            TouchCompass(obj)
        end
    end
end

-- // TOGGLE
Tabs.Fruits:AddToggle("AutoCompassCollector", {
    Title = "Auto Compass", Description = "Bring Compass", Default = false,
}):OnChanged(function(Value)
    States.Fruit.AutoCompassEnabled = Value
    if Value then 
        FullMapScan() -- Quét ngay khi bật
    else 
        table.clear(ProcessedCompass) 
    end
end)

-- // VÒNG LẶP QUÉT TOÀN MAP (Cái này giúp nó luôn tìm thấy Compass mới)
task.spawn(function()
    while true do
        task.wait(2) -- Quét lại toàn bộ map mỗi 2 giây
        if States.Fruit.AutoCompassEnabled then
            FullMapScan()
        end
    end
end)
-- =========================================================================
-- STATS CHANGER (UI giả lập chỉ số - chỉ thay đổi hiển thị local)
-- =========================================================================
local LocalPlayer = game:GetService("Players").LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Fluent = getgenv().Fluent -- Đảm bảo biến Fluent được khai báo

local StatChangerSettings = { TargetStat = "Nametag", InputValue = "" }
local OriginalTexts = {}
local rainbowEnabled = false

-- Hàm hỗ trợ tìm Menu
local function GetMenu()
    return PlayerGui:FindFirstChild("Menu", true) -- Tìm sâu hơn trong PlayerGui
end

local function ApplyStatChange()
    local MenuGui = GetMenu()
    if not MenuGui then
        Fluent:Notify({ Title="Hệ thống Error", Content="Không tìm thấy 'Menu'!", Duration=4 })
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
    
    if isFound then
        Fluent:Notify({ Title="Success!", Content="Đã cập nhật " .. targetName, Duration=3 })
    else
        Fluent:Notify({ Title="Thất bại", Content="Không tìm thấy '" .. targetName .. "'", Duration=4 })
    end
end

local function ResetToOriginal()
    local resetCount = 0
    for obj, originalText in pairs(OriginalTexts) do
        if obj and obj.Parent then 
            obj.Text = originalText
            resetCount += 1 
        end
    end
    table.clear(OriginalTexts)
    Fluent:Notify({ Title = "System Reset", Content = resetCount > 0 and "Đã khôi phục mặc định!" or "Không có gì để reset.", Duration=3 })
end

-- UI Section
local StatSection = Tabs.Settings:AddSection("Smart Stats Changer")

StatSection:AddDropdown("SelectStatType", {
    Title="Chọn Value",
    Values={"Nametag","BeriAmount","BountyAmount","GemsAmount","KillsAmount"},
    CurrentValue="Nametag",
    Callback=function(Value) StatChangerSettings.TargetStat = Value end,
})

StatSection:AddInput("StatTextInput", {
    Title="Nhập Value",
    Default="",
    Placeholder="Nhập nội dung mới",
    Callback=function(Value) StatChangerSettings.InputValue = Value end,
})

StatSection:AddButton({ Title="Áp dụng thay đổi", Callback = ApplyStatChange })
StatSection:AddButton({ Title="Reset về gốc", Callback = ResetToOriginal })

-- Toggle Rainbow
StatSection:AddToggle("RainbowNametag", {
    Title = "Rainbow Nametag",
    Description = "Hiệu ứng 7 màu cho Nametag",
    Default = false,
    Callback = function(Value)
        rainbowEnabled = Value
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
-- =========================================================================
-- SERVER FAST CONNECT
-- =========================================================================
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

local FastServerSection = Tabs.Map:AddSection("Server Fast Connect")
FastServerSection:AddButton({
    Title="Copy Mã Server Hiện Tại", Description="Sao chép JobId vào clipboard",
    Callback=function()
        local fn = setclipboard or toclipboard or (syn and syn.setclipboard)
        if fn then pcall(function() fn(game.JobId); SafeNotify("Copied!", "Đã sao chép!") end)
        else SafeNotify("Executor Error", "Không hỗ trợ clipboard!") end
    end,
})
FastServerSection:AddInput("ServerCodeInputField", {
    Title="Nhập Mã Server", Default="", Placeholder="Dán JobId vào đây...", NumericOnly=false,
    Callback=function(Value) ServerJoinerSettings.TargetServerId = Value end,
})
FastServerSection:AddButton({ Title="Join Server", Callback=JoinServerByCode })

-- =========================================================================
-- AUTO FISHING
-- =========================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local autoFishEnabled = false
local FOLDER_NAME = "FishingRope_" .. LocalPlayer.UserId

-- Danh sách ưu tiên cần câu (từ yếu đến mạnh)
local ROD_PRIORITY = {"Super Rod", "Sturdy Rod", "Wood Rod"}

-- Hàm tìm và trang bị cần câu tốt nhất có trong Inventory
local function equipBestRod()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    
    -- Kiểm tra nếu đã cầm một trong các cần câu đúng chuẩn thì bỏ qua
    if character and character:FindFirstChildOfClass("Tool") then
        local currentTool = character:FindFirstChildOfClass("Tool")
        for _, rodName in ipairs(ROD_PRIORITY) do
            if currentTool.Name == rodName then return end
        end
    end

    -- Tìm trong Backpack để lấy cần tốt nhất
    if backpack then
        for _, rodName in ipairs(ROD_PRIORITY) do
            local rod = backpack:FindFirstChild(rodName)
            if rod and character and character:FindFirstChild("Humanoid") then
                character.Humanoid:EquipTool(rod)
                return
            end
        end
    end
end

-- Vòng lặp Auto Click Minigame
local function autoPullIt()
    task.spawn(function()
        while autoFishEnabled do
            pcall(function()
                local fishingGui = game:FindFirstChild("FishingMinigame", true)
                if fishingGui and fishingGui.Enabled then
                    local mainFrame = fishingGui:FindFirstChild("Frame")
                    if mainFrame then
                        for _, btn in ipairs(mainFrame:GetDescendants()) do
                            if btn:IsA("TextButton") and btn.Visible then
                                local c = btn.BackgroundColor3
                                -- Check màu nút (trắng)
                                if c and c.R > 0.85 and c.G > 0.85 and c.B > 0.85 then
                                    pcall(function() firesignal(btn.MouseButton1Click) end)
                                    pcall(function() btn:Activate() end)
                                    task.wait(0.5) -- Tối ưu: giảm nhẹ delay click minigame xuống 0.15s
                                    break
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.05) -- Tối ưu: quét GUI nhanh hơn
        end
    end)
end

-- Vòng lặp thả câu và giật câu
local function autoFishLoop()
    task.spawn(function()
        local isProcessing = false -- Biến chặn spam click (Debounce)

        while autoFishEnabled do
            equipBestRod()
            
            local fishingFolder = Workspace:FindFirstChild(FOLDER_NAME)
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            
            -- KIỂM TRA QUAN TRỌNG: Nếu đang chơi Minigame thì ngừng tác động vào cần câu
            local isMinigameActive = false
            local fishingGui = game:FindFirstChild("FishingMinigame", true)
            if fishingGui and fishingGui.Enabled then
                isMinigameActive = true
            end
            
            if tool and not isMinigameActive and not isProcessing then
                if fishingFolder and fishingFolder:FindFirstChild("Bobber") then
                    local bobber = fishingFolder:FindFirstChild("Bobber")
                    
                    -- Cá cắn câu -> Giật cần
                    if bobber:FindFirstChild("Sparkles") then
                        isProcessing = true
                        tool:Activate()
                        task.wait(0.5) -- Cho server thời gian xóa phao và hiện Minigame
                        isProcessing = false
                    end
                else
                    -- Không có Phao trên mặt nước -> Tiến hành quăng câu
                    isProcessing = true
                    tool:Activate()
                    
                    -- Đợi thông minh: Đợi cho đến khi Bobber thực sự xuất hiện trên server (tối đa 1.5s)
                    -- Phao hiện ra lúc nào thì code thoát loop lúc đó, giúp thả câu nhanh mà không giật
                    local timeout = 0
                    while not (fishingFolder and fishingFolder:FindFirstChild("Bobber")) and timeout < 1.5 do
                        task.wait(0.1)
                        timeout = timeout + 0.1
                    end
                    isProcessing = false
                end
            end
            
            -- Quét trạng thái cực nhanh để bắt ngay khoảnh khắc cá cắn
            task.wait(0.05) 
        end
    end)
end

-- Tích hợp vào Fluent UI
Tabs.Fishs:AddToggle("AutoFishFullToggle", {
    Title = "Auto Fishing", 
    Default = false,
    Callback = function(Value)
        autoFishEnabled = Value
        if Value then 
            autoFishLoop()
            autoPullIt() 
        end
    end,
})
-- =========================================================================
-- AUTO SELL FISH (COOKER)
-- =========================================================================
local autoPullEnabled = false

local function openCooker()
    -- Kiểm tra lại lần nữa, nếu tắt toggle rồi thì không mở NPC nữa
    if not autoPullEnabled then return end
    
    pcall(function()
        local cooker = workspace:WaitForChild("Ignore", 2):WaitForChild("NPCs", 2)
                                   :WaitForChild("DailyQuest", 2):WaitForChild("Cooker", 2)
        if cooker then
            local hrp = cooker:FindFirstChild("HumanoidRootPart") or cooker:FindFirstChildWhichIsA("BasePart")
            local cd  = (hrp and hrp:FindFirstChildOfClass("ClickDetector")) or cooker:FindFirstChildOfClass("ClickDetector", true)
            if cd then fireclickdetector(cd) end
        end
    end)
end

local autoPullEnabled = false
local lastCookerFrame = nil -- Biến lưu lại Frame của Cooker để bật lại khi tắt toggle

local function openCooker()
    if not autoPullEnabled then return end
    pcall(function()
        local cooker = workspace:WaitForChild("Ignore", 2):WaitForChild("NPCs", 2)
                                   :WaitForChild("DailyQuest", 2):WaitForChild("Cooker", 2)
        if cooker then
            local hrp = cooker:FindFirstChild("HumanoidRootPart") or cooker:FindFirstChildWhichIsA("BasePart")
            local cd  = (hrp and hrp:FindFirstChildOfClass("ClickDetector")) or cooker:FindFirstChildOfClass("ClickDetector", true)
            if cd then fireclickdetector(cd) end
        end
    end)
end

local autoPullEnabled = false
local lastCookerFrame = nil -- Biến lưu lại Frame của Cooker để bật lại khi tắt toggle
local sellCooldown = 30 -- Thời gian giãn cách mặc định (thấp nhất là 30 giây)
local lastSellTime = 0 -- Lưu mốc thời gian của lần chạy trước

-- Hàm mở NPC
local function openCooker()
    if not autoPullEnabled then return end
    pcall(function()
        local cooker = workspace:WaitForChild("Ignore", 2):WaitForChild("NPCs", 2)
                                   :WaitForChild("DailyQuest", 2):WaitForChild("Cooker", 2)
        if cooker then
            local hrp = cooker:FindFirstChild("HumanoidRootPart") or cooker:FindFirstChildWhichIsA("BasePart")
            local cd  = (hrp and hrp:FindFirstChildOfClass("ClickDetector")) or cooker:FindFirstChildOfClass("ClickDetector", true)
            if cd then fireclickdetector(cd) end
        end
    end)
end

-- 1. Thêm Toggle bật/tắt
Tabs.Fishs:AddToggle("AutoPullToggle", {
    Title = "Auto Sell Fish", Default = false,
    Callback = function(state) 
        autoPullEnabled = state 
        
        -- Nếu người dùng TẮT toggle, ngay lập tức hiện lại GUI cũ nếu có
        if not state and lastCookerFrame and lastCookerFrame.Parent then
            lastCookerFrame.Visible = true
            lastCookerFrame = nil
        end
    end,
})

-- 2. Thêm Ô Nhập Thời Gian (Input)
Tabs.Fishs:AddInput("SellCooldownInput", {
    Title = "Thời gian giãn cách (giây)",
    Default = "30",
    Numeric = true, -- Chỉ cho phép nhập số
    Finished = true, -- Chỉ cập nhật khi người dùng nhấn Enter hoặc bấm ra ngoài
    Callback = function(value)
        local num = tonumber(value)
        if num then
            if num < 30 then
                sellCooldown = 30 -- Nếu nhập nhỏ hơn 30, tự động đưa về 30
                -- Bạn có thể thêm thông báo UI ở đây nếu muốn (ví dụ: Fluent:Notify)
            else
                sellCooldown = num
            end
        else
            sellCooldown = 30 -- Phòng trường hợp nhập lỗi chữ
        end
    end
})

-- Vòng lặp chính
task.spawn(function()
    while true do
        if autoPullEnabled then
            -- Kiểm tra xem thời gian hiện tại đã cách lần chạy trước đủ 'sellCooldown' giây chưa
            if (tick() - lastSellTime) >= sellCooldown then
                
                -- 1. Mở GUI Cooker
                openCooker()
                task.wait(0.5)

                if not autoPullEnabled then continue end

                -- 2. Tìm nút bấm màu trắng và click, sau đó ẩn Frame chứa nó
                local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
                if pg then
                    for _, btn in ipairs(pg:GetDescendants()) do
                        if btn:IsA("TextButton") and btn.Visible and btn.BackgroundColor3 then
                            local c = btn.BackgroundColor3
                            -- Kiểm tra màu trắng (Nút bán)
                            if c.R > 0.88 and c.G > 0.88 and c.B > 0.88 then
                                -- Click bán cá
                                pcall(function() firesignal(btn.MouseButton1Click) end)
                                
                                -- Cập nhật lại mốc thời gian vừa bán thành công
                                lastSellTime = tick()
                                
                                -- Tìm cái Frame chứa cái nút này
                                local frame = btn:FindFirstAncestorWhichIsA("Frame") or btn:FindFirstAncestorWhichIsA("ImageLabel")
                                if frame then
                                    frame.Visible = false -- Ẩn khung Cooker đi
                                    lastCookerFrame = frame -- Lưu lại vào bộ nhớ để tí bật lại
                                end
                                break 
                            end
                        end
                    end
                end
                
            end
        end
        
        -- Vòng lặp quét điều kiện liên tục mỗi 0.5 giây để đảm bảo mượt mà khi tắt/bật toggle
        task.wait(0.5) 
    end
end)
-- =========================================================================
-- AUTO SPAWN (bấm nút spawn khi chết)
-- =========================================================================
_G.AutoSpawnEnabled = _G.AutoSpawnEnabled or false

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local isClicking = false

-- Fix camera sau khi hồi sinh
local function FixCamera()
    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end

    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    workspace.CurrentCamera.CameraSubject = Humanoid
end

local function ForceClickButton(guiObj)
    if isClicking then
        return
    end

    isClicking = true

    pcall(function()
        local absPos = guiObj.AbsolutePosition
        local absSize = guiObj.AbsoluteSize

        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(
            Vector2.new(
                absPos.X + absSize.X / 2,
                absPos.Y + absSize.Y / 2
            )
        )

        for _, eventName in ipairs({
            "MouseButton1Click",
            "MouseButton1Down",
            "Activated"
        }) do
            if guiObj[eventName] then
                for _, connection in ipairs(getconnections(guiObj[eventName])) do
                    pcall(function()
                        connection:Fire()
                    end)
                end
            end
        end
    end)

    task.wait(0.3)

    -- Fix camera sau khi spawn
    task.delay(1, FixCamera)

    isClicking = false
end

local function ScanAndSpawn()
    if not _G.AutoSpawnEnabled or isClicking then
        return
    end

    local loadGui = playerGui:FindFirstChild("Load")

    if not loadGui or not loadGui.Enabled then
        return
    end

    for _, v in ipairs(loadGui:GetDescendants()) do
        if v:IsA("TextButton") then
            local text = string.lower(v.Text)
            local name = string.lower(v.Name)

            if (text:find("spawn") or name:find("spawn"))
            and v.AbsoluteSize.X > 0 then

                ForceClickButton(v)
                break
            end
        end
    end
end

task.spawn(function()
    while true do
        if _G.AutoSpawnEnabled then
            pcall(ScanAndSpawn)
            task.wait(0.3)
        else
            task.wait(0.5)
        end
    end
end)

-- Mỗi lần nhân vật hồi sinh sẽ ép camera về người chơi
LocalPlayer.CharacterAdded:Connect(function(Character)
    task.wait(1)

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then
        return
    end

    -- Giữ camera trong 5 giây để chống script game giành lại
    task.spawn(function()
        for i = 1, 300 do
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            workspace.CurrentCamera.CameraSubject = Humanoid
            task.wait()
        end
    end)
end)

Tabs.Main:AddToggle("AutoSpawnToggle", {
    Title = "Auto Spawn",
    Description = "Fix Camera",
    Default = _G.AutoSpawnEnabled
}):OnChanged(function(Value)
    _G.AutoSpawnEnabled = Value
end)

-- =========================================================================
-- ANTI-AFK
-- =========================================================================
local AntiAFKEnabled = false

LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
        end)
    end
end)

Tabs.Main:AddToggle("AntiAFKToggle", {
    Title=" Anti-AFK", Default=false, Description="",
}):OnChanged(function(Value)
    AntiAFKEnabled = Value
    if Fluent then Fluent:Notify({ Title="Anti AFK", Content=Value and "Enable" or "Disable", Duration=3 }) end
end)

--- Lấy các Service và Component cần thiết


local Running = false
local DelayTime = 0.05


local function GetChar()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHRP()
	return GetChar():WaitForChild("HumanoidRootPart")
end

-- Auto Compass
task.spawn(function()
    while true do -- Bỏ task.wait vào trong vòng lặp để đạt tốc độ tối đa
        if Running then
            local Char = LocalPlayer.Character
            if Char then
                local Humanoid = Char:FindFirstChildOfClass("Humanoid")
                local Compass = Char:FindFirstChild("Compass") or LocalPlayer.Backpack:FindFirstChild("Compass")

                if Humanoid and Compass and Compass:IsA("Tool") then
                    -- Trang bị Compass nếu chưa cầm
                    if Compass.Parent ~= Char then
                        Humanoid:EquipTool(Compass)
                    end

                    -- Cất các tool khác (tối ưu hóa bằng cách chỉ chạy khi cần thiết)
                    for _, v in ipairs(Char:GetChildren()) do
                        if v:IsA("Tool") and v.Name ~= "Compass" then
                            v.Parent = LocalPlayer.Backpack
                        end
                    end

                    -- Kích hoạt với tần suất cao
                    pcall(function()
                        Compass:Activate()
                    end)
                end
            end
        end
        task.wait(0.001) -- Thiết lập delay mong muốn
    end
end)

local DropSam = false

local DropSam = false

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

DropSam = false

Tabs.Main:AddToggle("DropSam", {
    Title = "Auto Drop Sam (Mobile)",
    Default = false
}):OnChanged(function(Value)
    DropSam = Value
end)

local function SendChat(msg)
    pcall(function()
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

task.spawn(function()
    while task.wait(1) do
        if not DropSam then
            continue
        end

        local Character = LocalPlayer.Character
        local Backpack = LocalPlayer:FindFirstChild("Backpack")

        if not Character or not Backpack then
            continue
        end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid then
            continue
        end

        local Compass =
            Character:FindFirstChild("Compass") or
            Backpack:FindFirstChild("Compass")

        if Compass and Compass:IsA("Tool") then
            if Compass.Parent ~= Character then
                Humanoid:EquipTool(Compass)
                task.wait(0.2)
            end

            SendChat("!drop")
        end
    end
end)
local AutoFindSamLuck = false


local function GetChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHRP()
    local char = GetChar()
    return char:WaitForChild("HumanoidRootPart", 5)
end

-- Auto Equip + Spam Compass
task.spawn(function()
    while task.wait(0.5) do
        if AutoFindSamLuck then
            local Char = GetChar()
            local Humanoid = Char:FindFirstChildOfClass("Humanoid")
            local Backpack = LocalPlayer:FindFirstChild("Backpack")

            if Humanoid and Backpack then
                local Compass = Char:FindFirstChild("Compass") or Backpack:FindFirstChild("Compass")

                if Compass and Compass:IsA("Tool") then
                    if Compass.Parent ~= Char then
                        Humanoid:EquipTool(Compass)
                    end

                    for _,v in ipairs(Char:GetChildren()) do
                        if v:IsA("Tool") and v.Name ~= "Compass" then
                            v.Parent = Backpack
                        end
                    end

                    pcall(function() Compass:Activate() end)
                end
            end
        end
    end
end)



-- Giả sử bạn đã khởi tạo Fluent và Tabs như sau:
-- local Fluent = loadstring(game:HttpGet("..."))()
-- local Window = Fluent:CreateWindow({ ... })
-- local Tabs = { Main = Window:AddTab({ Title = "Main", Icon = "" }) }



-- Đường dẫn đến ClickDetector
local cookingStation = workspace:WaitForChild("MapFolder"):WaitForChild("Island8")
    :WaitForChild("Kitchen"):WaitForChild("Cooking"):WaitForChild("CookingStation")
local clickDetector = cookingStation:FindFirstChildOfClass("ClickDetector")

-- Biến lưu trạng thái
local autoCookEnabled = false

-- Tạo Toggle trong Tabs.Main
local Toggle = Tabs.Fishs:AddToggle("AutoCookToggle", {
    Title = "Auto Cook",
    Description = "Tự động tương tác với Cooking Station",
    Default = false
})

-- Xử lý sự kiện khi gạt Toggle
Toggle:OnChanged(function(Value)
    autoCookEnabled = Value
end)

-- Vòng lặp chạy Auto Cook
task.spawn(function()
    while true do
        if autoCookEnabled and clickDetector then
            -- Gọi hàm fireclickdetector (yêu cầu executor có hỗ trợ)
            fireclickdetector(clickDetector)
        end
        task.wait(0.5) -- Tốc độ click
    end
end)-- Thêm các nút điều hướng vào Tab Map
Tabs.Map:AddButton({
    Title = "Rejoin Server",
    Description = "Tải lại phiên bản server hiện tại",
    Icon = "refresh-cw",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Player = game:GetService("Players").LocalPlayer
        TeleportService:Teleport(game.PlaceId, Player)
    end
})


-- Đảm bảo các biến này nằm ở đầu script
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Đoạn code cấu trúc sạch sẽ, không lỗi cú pháp:
Tabs.Map:AddButton({
    Title = "Hop Server",
    Description = "Chuyển sang một server khác",
    Icon = "arrow-right-from-line",
    Callback = function()
        if Fluent then
            Fluent:Notify({
                Title = "Server Hop",
                Content = "Đang quét sâu danh sách server...",
                Duration = 3
            })
        end

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
            if Fluent then
                Fluent:Notify({
                    Title = "Thành Công",
                    Content = "Đang tiến hành dịch chuyển...",
                    Duration = 3
                })
            end
            task.wait(0.5)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, randomServer.id, LocalPlayer)
            end)
        else
            if Fluent then
                Fluent:Notify({
                    Title = "Chế độ dự phòng",
                    Content = "Đang tự động nhảy ngẫu nhiên...",
                    Duration = 3
                })
            end
            task.wait(0.5)
            pcall(function()
                TeleportService:Teleport(placeId, LocalPlayer)
            end)
        end
    end
}) -- Đóng đúng cú pháp của AddButton


-- Hàm lấy danh sách các Altar từ folder "Altars"
local function getAltarList()
    -- Luôn gọi Workspace từ biến đã định nghĩa ở trên để tránh lỗi
    local altarFolder = Workspace:FindFirstChild("Altars")
    local list = {}
    if altarFolder then
        for _, obj in ipairs(altarFolder:GetChildren()) do
            table.insert(list, obj.Name)
        end
    end
    return list
end


-- Hàm lấy danh sách các Altar từ folder "Altars"
local function getAltarList()
    local altarFolder = Workspace:FindFirstChild("Altars")
    local list = {}
    if altarFolder then
        for _, obj in ipairs(altarFolder:GetChildren()) do
            -- Chỉ thêm vào danh sách nếu là Model hoặc có PrimaryPart
            table.insert(list, obj.Name)
        end
    end
    return list
end

-- Section trong tab Map
local MapSection = Tabs.Map:AddSection("Teleport Altar")

-- Dropdown để chọn Altar
local AltarDropdown = MapSection:AddDropdown("SelectAltar", {
    Title = "Chọn Altar",
    Values = getAltarList(),
    Multi = false,
    Default = nil,
    Callback = function(Value)
        -- Khi chọn Altar, ta tìm vị trí của nó và tele đến
        local altarFolder = Workspace:FindFirstChild("Altars")
        local target = altarFolder and altarFolder:FindFirstChild(Value)
        
        if target then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Dịch chuyển đến vị trí của Altar (ưu tiên PrimaryPart nếu có)
                local pos = target:IsA("Model") and target:GetPivot().Position or target.Position
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) -- Cộng thêm Y để không bị kẹt đất
                Fluent:Notify({ Title = "Teleport", Content = "Đã dịch chuyển đến: " .. Value, Duration = 2 })
            end
        end
    end
})

-- Nút làm mới danh sách (phòng khi folder Altars thay đổi)
MapSection:AddButton({
    Title = "Làm mới danh sách Altar",
    Callback = function()
        AltarDropdown:SetValues(getAltarList())
        Fluent:Notify({ Title = "Success", Content = "Đã cập nhật danh sách!", Duration = 2 })
    end
})


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AutoOpenCache = false
local AutoMixerFruit = false

Tabs.chiso:AddToggle("AutoMixerFruit", {
    Title = "Auto Mixer Fruit",
    Default = false,
    Callback = function(Value)
        AutoMixerFruit = Value

        if Value then
            task.spawn(function()
                while AutoMixerFruit do
                    local Count = 0

                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v.Name == "Mixer1" then
                            local CD = v:FindFirstChildOfClass("ClickDetector")

                            if CD then
                                fireclickdetector(CD)
                                Count += 1
                            end
                        end
                    end

                    task.wait(0.1) -- chỉnh tốc độ tại đây
                end
            end)
        end
    end
})
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local DrinkList = {
    ["Apple Juice"]   = true,
    ["Sour Juice"]    = true,
    ["Pumpkin Juice"] = true,
    ["Fruit Juice"]   = true,
    ["Banana Juice"]  = true,
    ["Golden Apple"]  = true,
    ["Coconut Milk"]  = true,
    ["Pear Juice"]    = true,
}

local AutoDrink = false

Tabs.chiso:AddToggle("AutoDrink Fruit Mix", {
    Title = "Auto Drink",
    Default = false,
    Callback = function(Value)
        AutoDrink = Value

        if Value then
            task.spawn(function()
                while AutoDrink do
                    local Character = LocalPlayer.Character
                    local Backpack = LocalPlayer:FindFirstChild("Backpack")
                    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

                    if Character and Backpack and Humanoid then
                        -- Kiểm tra Backpack
                        for _, Tool in ipairs(Backpack:GetChildren()) do
                            if Tool:IsA("Tool") and DrinkList[Tool.Name] then
                                pcall(function()
                                    Humanoid:EquipTool(Tool)
                                end)

                                task.wait(0.03)

                                pcall(function()
                                    Tool:Activate()
                                    Tool:Activate()
                                    Tool:Activate()
                                end)
                            end
                        end

                        -- Kiểm tra Tool đang cầm
                        for _, Tool in ipairs(Character:GetChildren()) do
                            if Tool:IsA("Tool") and DrinkList[Tool.Name] then
                                pcall(function()
                                    Tool:Activate()
                                    Tool:Activate()
                                    Tool:Activate()
                                end)
                            end
                        end
                    end

                    task.wait(0.05)
                end
            end)
        end
    end
})
local DropSam = false

Tabs.Main:AddToggle("DropSam", {
    Title = "Auto Drop Sam ( PC)",
    Default = false
}):OnChanged(function(Value)
    DropSam = Value
end)

task.spawn(function()
    while task.wait(0.5) do
        if not DropSam then
            continue
        end

        local Character = LocalPlayer.Character
        local Backpack = LocalPlayer:FindFirstChild("Backpack")

        if not Character or not Backpack then
            continue
        end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid then
            continue
        end

        local Compass =
            Character:FindFirstChild("Compass") or
            Backpack:FindFirstChild("Compass")

        if Compass and Compass:IsA("Tool") then
            pcall(function()
                if Compass.Parent ~= Character then
                    Humanoid:EquipTool(Compass)
                    task.wait(0.15)
                end

                -- Thả tool
                Compass.Parent = workspace
            end)
        end
    end
end)
-- Khai báo biến điều khiển
local ChestNames = {"Platinum Cache", "Silver Cache", "Gold Cache", "Copper Cache"}
local AutoOpenFish = false

local function OpenFishChests()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    if not player then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Bước 1: Quét toàn bộ Backpack để thu thập danh sách các Cache đang có
    local cachesToOpen = {}
    for _, item in ipairs(player.Backpack:GetChildren()) do
        if table.find(ChestNames, item.Name) then
            table.insert(cachesToOpen, item)
        end
    end

    -- Bước 2: Nếu phát hiện có Cache, lập tức cất các trang bị khác (cần câu) đi
    if #cachesToOpen > 0 then
        humanoid:UnequipTools()
        task.wait(0.2) -- Đợi một chút để server ghi nhận việc cất đồ
        
        -- Bước 3: Lần lượt trang bị và mở từng Cache
        for _, cacheTool in ipairs(cachesToOpen) do
            if not AutoOpenFish then break end -- Dừng lại nếu bạn tắt Toggle giữa chừng
            
            -- Trang bị Cache lên tay
            humanoid:EquipTool(cacheTool)
            task.wait(0.2)
            
            -- Kiểm tra xem Cache đã nằm trên tay (trong Character) chưa
            local heldTool = character:FindFirstChild(cacheTool.Name)
            if heldTool then
                heldTool:Activate()
                task.wait(0.6) -- Đợi Cache mở xong và biến mất (có thể tăng/giảm nhẹ tùy ping)
            end
        end
    end
end

-- Tích hợp vào Fluent UI
Tabs.Fishs:AddToggle("AutoOpenCache", {
    Title = "Auto Mở Cache",
    Description = "Tự động cất cần câu và tập trung mở Cache",
    Default = false,
    Callback = function(Value)
        AutoOpenFish = Value
        if AutoOpenFish then
            task.spawn(function()
                while AutoOpenFish do
                    OpenFishChests()
                    task.wait(0.1) -- Quét nhanh hơn để không bị Auto Fish cướp lại slot
                end
            end)
        end
    end
})
local MapSection = Tabs.Map:AddSection("Teleport Secret")
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
            warn("Không tìm thấy đường dẫn Workspace.Ignore.NPCs.Secret")
        end
        
        if #Config.ItemList == 0 then
            table.insert(Config.ItemList, "Không có mục nào")
        end
    end

    -- Quét danh sách lần đầu
    refreshSecretList()

    -- Tạo Dropdown trực tiếp vào Tabs.Map có sẵn của bạn
    local SecretDropdown = Tabs.Map:AddDropdown("SecretTeleportDropdown", {
        Title = "Chọn Npc hiện có",
        Values = Config.ItemList,
        CurrentValue = Config.ItemList[1],
        Multi = false,
        Callback = function(Value)
            local target = Config.ItemMap[Value]
            if target then
                -- An toàn tuyệt đối trước lỗi DataModel "Ugc"
                local PlayersService = game:GetService("Players")
                local player = PlayersService.LocalPlayer
                
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
                    
                    Fluent:Notify({
                        Title = "Teleport",
                        Content = "Đã dịch chuyển đến: " .. Value,
                        Duration = 3
                    })
                end
            end
        end
    })

    -- Tạo Button Reset trực tiếp vào Tabs.Map có sẵn của bạn
    Tabs.Map:AddButton({
        Title = "Reset List (Cập nhật)",
        Description = "",
        Callback = function()
            refreshSecretList()
            SecretDropdown:SetValues(Config.ItemList)
            SecretDropdown:SetValue(Config.ItemList[1])
            
            Fluent:Notify({
                Title = "Hệ thống",
                Content = "Đã cập nhật lại danh sách vị trí!",
                Duration = 3
            })
        end
    })
end


-- Biến lưu trạng thái hoạt động
-- =======================================================
-- 1. KHỞI TẠO CẤU HÌNH TOÀN CỤC CHỐNG TRÀN BỘ NHỚ (REGISTER)
-- =======================================================
if not _G.WebhookConfig then
    _G.WebhookConfig = {
        URL = "",
        Active = false
    }
end

-- =======================================================
-- 2. HÀM QUÉT VÀ ĐẾM CHÍNH XÁC SỐ LƯỢNG CACHE TRONG NGƯỜI
-- =======================================================
local function GetCacheInventory()
    local p = game:GetService("Players").LocalPlayer
    local counts = { 
        ["Platinum Cache"] = 0, 
        ["Gold Cache"] = 0, 
        ["Silver Cache"] = 0, 
        ["Copper Cache"] = 0 
    }
    
    -- Quét trong Backpack (Hòm đồ của người chơi)
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, item in pairs(bp:GetChildren()) do
            if counts[item.Name] ~= nil then
                counts[item.Name] = counts[item.Name] + 1
            end
        end
    end
    
    -- Quét trong Character (Nếu đang cầm vật phẩm trên tay)
    local char = p.Character
    if char then
        for _, item in pairs(char:GetChildren()) do
            if counts[item.Name] ~= nil then
                counts[item.Name] = counts[item.Name] + 1
            end
        end
    end
    
    return counts
end

-- =======================================================
-- 3. HÀM GỬI DISCORD WEBHOOK (DÙNG PROXY VÀ OS.DATE CỦA BẠN)
-- =======================================================
local function SendCacheLogToDiscord(reportContent)
    local currentURL = _G.WebhookConfig.URL
    -- Kiểm tra xem người dùng đã nhập link chưa và có đúng định dạng không
    if currentURL == "" or not string.find(currentURL, "discord.com/api/webhooks") then 
        return 
    end
    
    -- Bypass chặn webhook bằng proxy an toàn
    local secureURL = string.gsub(currentURL, "discord.com", "webhook.lewisakura.moe")
    
    local data = {
        ["username"] = "Cache Scanner Hub",
        ["embeds"] = {{
            ["title"] = "🎣 Phát hiện Cache trong hòm đồ! 🎣",
            ["color"] = 16753920, -- Màu cam giống bản mẫu của bạn
            ["description"] = reportContent,
            ["fields"] = {
                {["name"] = "Người chơi:", ["value"] = game:GetService("Players").LocalPlayer.Name, ["inline"] = true},
                {["name"] = "Mã Server:", ["value"] = game.JobId, ["inline"] = false}
            },
            ["footer"] = {["text"] = "Thời gian quét: " .. os.date("%H:%M:%S")} -- Dùng os.date chuẩn chỉnh
        }}
    }
    
    local encoded = game:GetService("HttpService"):JSONEncode(data)
    
    -- Nhận diện mọi executor (syn, request, http_request...) theo code mẫu của bạn
    local request_func = (syn and syn.request) or request or http_request or (http and http.request)
    if request_func then
        pcall(function()
            request_func({
                Url = secureURL, 
                Method = "POST", 
                Headers = {["Content-Type"] = "application/json"}, 
                Body = encoded
            })
        end)
    else
        pcall(function()
            game:HttpPost(secureURL, encoded)
        end)
    end
end

-- =======================================================
-- 4. GIAO DIỆN FLUENT UI (Ô NHẬP LINK & NÚT BẬT TẮT)
-- =======================================================

-- Ô NHẬP MÃ WEBHOOK (Nhập xong link nhớ ấn Enter hoặc nhấn ra ngoài để UI lưu lại)
Tabs.Fishs:AddInput("WebhookInput", {
    Title = "Discord Webhook URL",
    Description = "Dán và nhấn Enter",
    Default = _G.WebhookConfig.URL,
    Placeholder = "https://discord.com/api/webhooks/...",
    Numeric = false,
    Finished = true, 
    Callback = function(Value)
        _G.WebhookConfig.URL = Value
    end
})

-- NÚT TOGGLE AUTO SEND (Đã loại bỏ hoàn toàn vòng lặp for lỗi cú pháp)
Tabs.Fishs:AddToggle("AutoSendWebhook", {
    Title = "Auto Send Webhook", 
    Description = "Tự động đếm và báo số lượng Cache về Discord",
    Default = false,
    Callback = function(Value)
        _G.WebhookConfig.Active = Value
        
        if _G.WebhookConfig.Active then
            task.spawn(function()
                while _G.WebhookConfig.Active do
                    local res = GetCacheInventory()
                    local reportLines = {}
                    local totalFound = 0
                    
                    -- Kiểm tra trực tiếp từng loại Cache và cộng dồn số lượng
                    if res["Platinium Cache"] and res["Platinum Cache"] > 0 then
                        totalFound = totalFound + res["Platinum Cache"]
                        table.insert(reportLines, "💎 **Platinium Cache:** " .. res["Platinium Cache"] .. " cái")
                    end
                    
                    if res["Gold Cache"] and res["Gold Cache"] > 0 then
                        totalFound = totalFound + res["Gold Cache"]
                        table.insert(reportLines, "🥇 **Gold Cache:** " .. res["Gold Cache"] .. " cái")
                    end
                    
                    if res["Silver Cache"] and res["Silver Cache"] > 0 then
                        totalFound = totalFound + res["Silver Cache"]
                        table.insert(reportLines, "🥈 **Silver Cache:** " .. res["Silver Cache"] .. " cái")
                    end
                    
                    if res["Copper Cache"] and res["Copper Cache"] > 0 then
                        totalFound = totalFound + res["Copper Cache"]
                        table.insert(reportLines, "🥉 **Copper Cache:** " .. res["Copper Cache"] .. " cái")
                    end
                    
                    -- Nếu có ít nhất 1 cái cache trong người thì tiến hành gửi báo cáo về Discord
                    if totalFound > 0 then
                        local finalString = "📋 **Số lượng Cache hiện có trong người:**\n" .. table.concat(reportLines, "\n")
                        SendCacheLogToDiscord(finalString)
                    end
                    
                    task.wait(200) -- Đúng 60 giây sau tự động quét lại một lần
                end
            end)
        end
    end
})
-- =======================================================
-- ĐOẠN ĐƯỢC FIX LỖI UI (ĐÚNG CÚ PHÁP FLUENT CHUẨN)
-- =======================================================
-- 1. Tạo ô hiển thị thông tin (Đặt ngoài hàm)
local CacheLabel = Tabs.thongtin:AddParagraph({
    Title = "Số lượng Vật Phẩm trong Backpack",
    Content = "Đang kiểm tra..."
})

local function UpdateCacheCount()
    local itemCounts = {
        ["Platinum Cache"] = 0, 
        ["Gold Cache"] = 0, 
        ["Silver Cache"] = 0, 
        ["Copper Cache"] = 0,

        ["Small Busser"] = 0, 
        ["Small Flooper"] = 0, 
        ["Small Lubber"] = 0, 
        ["Small Jawber"] = 0, 

        ["Medium Lubber"] = 0, 
        ["Medium Flooper"] = 0,
        ["Medium Busser"] = 0,
        ["Medium Jawber"] = 0,

        ["Large Flooper"] = 0,
        ["Large Busser"] = 0, 
        ["Large Lubber"] = 0,

        ["Huge Flooper"] = 0,
        ["Huge Busser"] = 0,
        ["Huge Lubber"] = 0,
    }
    
    local player = game:GetService("Players").LocalPlayer
    local backpack = player:FindFirstChild("Backpack")
    
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if itemCounts[item.Name] ~= nil then
                itemCounts[item.Name] = itemCounts[item.Name] + 1
            end
        end
    end
    
    -- ĐÃ BỎ FONT: Chỉ giữ lại chữ và Icon nguyên bản
    local displayText = string.format(
        "📦 [CACHES]\n" ..
        "💎 Platinum Cache: %d\n" ..
        "🥇 Gold Cache: %d\n" ..
        "🥈 Silver Cache: %d\n" ..
        "🟤 Copper Cache: %d\n\n" ..
        
        "🐟 [SMALL FISH]\n" ..
        "🔹 Small Busser: %d\n" ..
        "🔹 Small Flooper: %d\n" ..
        "🔹 Small Lubber: %d\n" ..
        "🔹 Small Jawber: %d\n\n" ..
        
        "🐠 [MEDIUM FISH]\n" ..
        "🔸 Medium Lubber: %d\n" ..
        "🔸 Medium Flooper: %d\n" ..
        "🔸 Medium Busser: %d\n" ..
        "🔸 Medium Jawber: %d\n\n" ..
        
        "🦈 [LARGE FISH]\n" ..
        "🔴 Large Lubber: %d\n" ..
        "🔴 Large Flooper: %d\n" ..
        "🔴 Large Busser: %d\n\n" ..

        "👑 [HUGE FISH]\n" ..
        "🟣 Huge Lubber: %d\n" ..
        "🟣 Huge Flooper: %d\n" ..
        "🟣 Huge Busser: %d",
        
        -- Caches
        itemCounts["Platinum Cache"],
        itemCounts["Gold Cache"],
        itemCounts["Silver Cache"],
        itemCounts["Copper Cache"],
        
        -- Small
        itemCounts["Small Busser"],
        itemCounts["Small Flooper"],
        itemCounts["Small Lubber"],
        itemCounts["Small Jawber"],
        
        -- Medium
        itemCounts["Medium Lubber"],
        itemCounts["Medium Flooper"],
        itemCounts["Medium Busser"],
        itemCounts["Medium Jawber"],
        
        -- Large
        itemCounts["Large Lubber"],
        itemCounts["Large Flooper"],
        itemCounts["Large Busser"],

        -- Huge
        itemCounts["Huge Lubber"],
        itemCounts["Huge Flooper"],
        itemCounts["Huge Busser"]
    )
    
    CacheLabel:SetTitle("Số lượng Vật Phẩm hiện tại:")
    CacheLabel:SetDesc(displayText)
end

-- Vòng lặp tự động cập nhật mỗi 120 giây (2 phút)
task.spawn(function()
    while true do
        UpdateCacheCount()
        task.wait(120)
    end
end)
-- Lấy các Service và Component cần thiết





-- Khởi tạo các dịch vụ cần thiết

local autoFindActive = false
local Connection -- Biến để lưu kết nối khóa trang bị

-- Hàm kiểm tra xem Compass có tồn tại trong người không
local function hasCompass()
    if not LocalPlayer then return false end
    local char = LocalPlayer.Character
    local pack = LocalPlayer.Backpack
    return (char and char:FindFirstChild("Compass")) or (pack and pack:FindFirstChild("Compass"))
end

-- Hàm khóa cứng Compass vào tay
local function lockCompassToHand()
    if not autoFindActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local tool = char:FindFirstChild("Compass")
    local pack = LocalPlayer.Backpack
    
    if not tool and pack then
        local foundTool = pack:FindFirstChild("Compass")
        if foundTool and humanoid then
            humanoid:EquipTool(foundTool)
            tool = foundTool
        end
    end
    
    if tool then
        tool:Activate()
    end
end

-- Toggle chính (Đã tối ưu logic)

-- Khởi tạo các biến toàn cục
_G.MainAutoSamToggle = false
_G.ClickCooldown  = 2 -- Thời gian nghỉ giữa các lần click nhẹ nhàng
local isProcessing = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ==========================================
-- 1. KIỂM TRA READY MẠNH MẼ (QUÉT SIÊU TỐC)
-- ==========================================
local function GetSamTimer()
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            -- Xóa khoảng trắng, chuyển chữ thường để check chính xác
            local cleanText = string.lower(string.gsub(obj.Text, "%s+", ""))
            if string.find(cleanText, "ready!") and string.find(cleanText, "1/1") then
                -- Tránh nhận nhầm text hội thoại trong Dialogue
                if not string.find(string.lower(obj:GetFullName()), "dialogue") then
                    return obj
                end
            end
        end
    end
    return nil
end

local function GetSamClickDetector()
    local ignore = Workspace:FindFirstChild("Ignore")
    local npcs = ignore and ignore:FindFirstChild("NPCs")
    local dailyQuest = npcs and npcs:FindFirstChild("DailyQuest")
    local sam = dailyQuest and dailyQuest:FindFirstChild("Sam")
    local hrp = sam and sam:FindFirstChild("HumanoidRootPart")
    return hrp and hrp:FindFirstChild("ClickDetector")
end

local function GetOptionsFolder()
    local questGui = playerGui:FindFirstChild("QuestGui")
    local dialogue = questGui and questGui:FindFirstChild("Dialogue")
    return dialogue and dialogue:FindFirstChild("Options")
end

-- ==========================================
-- 2. NHẤN GUI NHẸ NHÀNG (MÔ PHỎNG TOUCH/CLICK CHUẨN)
-- ==========================================
local function GentleClick(guiObj)
    if not guiObj or not guiObj.Parent then return end
    
    -- Lấy vị trí tâm của nút
    local absPos  = guiObj.AbsolutePosition
    local absSize = guiObj.AbsoluteSize
    local targetX = absPos.X + absSize.X / 2
    local targetY = absPos.Y + absSize.Y / 2
    
    pcall(function()
        -- Kích hoạt kết nối sự kiện (MouseButton1Click / Activated) nếu có executor hỗ trợ
        if getconnections then
            local clicked = false
            for _, c in ipairs(getconnections(guiObj.MouseButton1Click)) do c:Fire() clicked = true end
            for _, c in ipairs(getconnections(guiObj.Activated))         do c:Fire() clicked = true end
            if clicked then return end -- Nếu fire kết nối thành công thì không cần click chuột ảo nữa
        end
        
        -- Nếu không có getconnections, click chuột ảo nhẹ nhàng phát một bằng VirtualInputManager
        VirtualInputManager:SendMouseButtonEvent(targetX, targetY, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(targetX, targetY, 0, false, game, 1)
    end)
end

-- ==========================================
-- 3. CHUỖI KHỞI TẠO TELE & NHẬN GUI (VÒNG LẶP LIÊN TỤC)
-- ==========================================
local function ExecuteSamSequence()
    -- Bước 1: Teleport đến Sam NPC
    local ignore = Workspace:FindFirstChild("Ignore")
    local samNPC = ignore and ignore.NPCs.DailyQuest.Sam
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if samNPC and myHrp then
        myHrp.CFrame = samNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1)
    else
        return false
    end
    
    task.wait(0.2) -- Chờ ổn định vị trí sau tele
    
    -- Bước 2: Click NPC để mở GUI nhận quest
    local samClickDetector = GetSamClickDetector()
    if samClickDetector then
        fireclickdetector(samClickDetector)
    else
        return false
    end
    
    -- Bước 3: Đợi GUI Dialogue xuất hiện và tìm Option nhận nhiệm vụ
    local targetOption = nil
    for i = 1, 15 do -- Giảm thời gian chờ xuống để xử lý nhanh hơn (15 * 0.1s = 1.5s max)
        if not _G.MainAutoSamToggle then return false end
        local optionsFolder = GetOptionsFolder()
        if optionsFolder then
            targetOption = optionsFolder:FindFirstChild("Option")
            if targetOption and targetOption.AbsoluteSize.X > 0 then
                break 
            end
        end
        task.wait(0.1)
    end
    
    -- Bước 4: Kiểm tra Text bên trong Option và Tiến hành click nhẹ nhàng
    if targetOption then
        local hasTargetText = false
        for _, child in ipairs(targetOption:GetDescendants()) do
            if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Visible then
                local cleanText = string.lower(string.gsub(child.Text, "%s+", ""))
                if string.find(cleanText, "compasses") or string.find(cleanText, "claim1") then
                    hasTargetText = true
                    break
                end
            end
        end
        
        if hasTargetText then
            GentleClick(targetOption)
            return true -- Thực hiện thành công một lượt
        end
    end
    
    return false
end

-- TẠO UI TOGGLE
Tabs.Main:AddToggle("AutoSam", {
    Title = "Auto Nhận Sam",
    Default = false,
    Callback = function(state)
        _G.MainAutoSamToggle = state
    end
})

-- ==========================================
-- 4. VÒNG LẶP ĐIỀU KHIỂN CHÍNH: ACTIVE & SLEEP
-- ==========================================
task.spawn(function()
    while true do
        task.wait(1) -- Tốc độ quét cực nhanh (0.1 giây một lần) để bắt kịp trạng thái Ready
        
        if _G.MainAutoSamToggle and not isProcessing then
            local timerObj = GetSamTimer()
            
            -- NẾU THẤY READY: BẮT ĐẦU VÀO TRẠNG THÁI HOẠT ĐỘNG MẠNH MẼ (ACTIVE)
            if timerObj then
                isProcessing = true
                
                -- Vòng lặp cưỡng ép làm liên tục cho đến khi không còn chữ Ready nữa mới thôi
                while _G.MainAutoSamToggle and timerObj and timerObj.Parent do
                    local success = pcall(ExecuteSamSequence)
                    
                    task.wait(_G.ClickCooldown) -- Nghỉ nhẹ nhàng giữa các lượt làm việc
                    
                    -- Quét lại xem còn Ready không để tiếp tục loop hoặc thoát
                    timerObj = GetSamTimer()
                    if not timerObj then
                      
                        break
                    end
                end
                
                isProcessing = false
      
            end
        end
    end
end)
-- =========================================================================
-- SAVE MANAGER & FINALIZE
-- =========================================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({ Title="Premium Free", Content="Rabbit Hub Cảm ơn anh bạn", Duration=20 })
SaveManager:LoadAutoloadConfig()
        else

            print("Hết hạn")
        end
    else
        warn("Không thể kết nối đến máy chủ kiểm tra.")
    end
end

-- Chạy hàm kiểm tra ngay khi script được load
CheckSubscription()
