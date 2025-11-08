local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1423711439360626889/Pu_PSdrn_uapX1k8NMmNM0ayVa0tw9tBkECMLHI_E0d7rQDLz7mOr3k7v_TuJ-UVLZzi"

local LocalPlayer = Players.LocalPlayer

local MIN_SECONDS_BETWEEN_SENDS = 3
local lastSend = 0

local function BuildPayloadEmbed()
    local placeId = tostring(game.PlaceId or "nil")
    local jobId = tostring(game.JobId or "nil")
    local playerName = LocalPlayer and LocalPlayer.Name or "Unknown"
    local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

    local embed = {
        title = "📥 Script đã được chạy",
        color = 3447003,
        fields = {
            { name = "Tên game :", value = playerName, inline = true },
            { name = "PlaceId :", value = placeId, inline = true },
            { name = "JobId :", value = jobId, inline = false },
            { name = "Thời gian (UTC) :", value = timestamp, inline = false },
        },
        timestamp = timestamp
    }

    local payload = { embeds = { embed } }
    return HttpService:JSONEncode(payload)
end

local function try_http_request(jsonBody)
    local ok, res

    if syn and syn.request then
        ok, res = pcall(function()
            return syn.request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = jsonBody
            })
        end)
        if ok then return true, res end
    end

    local req = (rawget(_G, "http_request") and http_request) or (rawget(_G, "request") and request) or (rawget(_G, "http") and http and http.request)
    if req then
        ok, res = pcall(function()
            return req({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = jsonBody
            })
        end)
        if ok then return true, res end
    end

    if http and http.request then
        ok, res = pcall(function()
            return http.request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = jsonBody
            })
        end)
        if ok then return true, res end
    end

    return false, "no_request_function_available"
end

local function SendPlayerRunWebhook()
    if tick() - lastSend < MIN_SECONDS_BETWEEN_SENDS then
        return false, "rate_limited_local"
    end

    local jsonPayload = BuildPayloadEmbed()
    local ok, res = try_http_request(jsonPayload)
    if ok then
        lastSend = tick()
        return true, res
    else
        return false, res
    end
end

do
    local ok, res = pcall(SendPlayerRunWebhook)
    if ok and res then
   
    else
       
    end
end
local Fluent = loadstring(Game:HttpGet("https://raw.githubusercontent.com/cthanh137/s-ss/refs/heads/main/mssnss.lua", true))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local vim = game:GetService("VirtualInputManager")
local Window = Fluent:CreateWindow({
    Title = "One Piece Legends Unleashed " ,
    SubTitle = "by Rabbit",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Balloon",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})


local Tabs = {
Main= Window:AddTab({ Title = "Main", Icon = "home" }),
	Farm = Window:AddTab({ Title = "Farm Mob", Icon = "bookmark" }),
    Players = Window:AddTab({ Title = "Player", Icon = "ghost" }),
    Fruits = Window:AddTab({ Title = "Fruit", Icon = "apple" }),
    Map = Window:AddTab({ Title = "Location", Icon = "loader-2" }),
		Shop = Window:AddTab({ Title = "Settings", Icon = "" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local States = {
    Misc = {
        AutoChest = false
    },
    Fruit = {
        AutoClaimSam = false,
        SamDelay = 1,
        FruitESP = false
    },
    Player = 
    {
        FlightEnabled = false,
        FlightSpeed = 200,
    },
    
}
local EnemiesFolder = workspace:WaitForChild("MOBS"):WaitForChild("Mobs")

local blacklist = {}

local Config = {
    Enabled = false,
    ScanRadius = 400,
    OrbitRadius = 4,
    OrbitSpeed = 1,
    FarmAngle = 0,
    FarmDistance = 5
}

local Target = nil
local Angle = 0


--// HÀM CƠ BẢN
local function GetChar()
    return LocalPlayer.Character
end

local function GetHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsValidEnemy(enemy)
    if not enemy:IsA("Model") then return false end
    if blacklist[enemy.Name] then return false end
    local hum = enemy:FindFirstChildOfClass("Humanoid", true)
    local hrp = enemy:FindFirstChild("HumanoidRootPart", true)
    return hum and hrp and hum.Health > 0
end

local function FindNearestEnemy(radius)
    local char = GetChar()
    local hrp = GetHRP(char)
    if not hrp then return nil end

    local nearest, minDist = nil, math.huge
    for _, enemy in pairs(EnemiesFolder:GetDescendants()) do
        if IsValidEnemy(enemy) then
            local eHRP = enemy:FindFirstChild("HumanoidRootPart", true)
            local dist = (eHRP.Position - hrp.Position).Magnitude
            if dist < minDist and dist <= radius then
                nearest = enemy
                minDist = dist
            end
        end
    end
    return nearest
end

--// AUTO FARM FUNCTION (tách riêng để dễ restart)
local function StartAutoFarmLoop()
    task.spawn(function()
        while task.wait() do
            if not Config.Enabled then continue end

            local char = GetChar()
            local hrp = GetHRP(char)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not humanoid then continue end

            if not Target or not IsValidEnemy(Target) then
                Target = FindNearestEnemy(Config.ScanRadius)
                continue
            end

            local npc = Target
            local enemyHRP = npc:FindFirstChild("HumanoidRootPart", true)
            if enemyHRP then
                Angle += Config.OrbitSpeed * RunService.Heartbeat:Wait()

                local radians = math.rad(Config.FarmAngle)
                local dir = CFrame.new(enemyHRP.Position) * CFrame.Angles(0, radians, 0)
                local offset = dir.LookVector * -Config.FarmDistance
                local standPos = enemyHRP.Position + offset

                hrp.CFrame = CFrame.new(standPos, enemyHRP.Position)

                -- 🥊 Auto Attack
                local tool = char:FindFirstChildOfClass("Tool") or char:FindFirstChildWhichIsA("Tool")
                if tool then
                    while npc and npc:FindFirstChildOfClass("Humanoid", true) and npc:FindFirstChildOfClass("Humanoid", true).Health > 0 and humanoid and humanoid.Parent and Config.Enabled do
                        pcall(function()
                            hrp.CFrame = enemyHRP.CFrame * CFrame.new(0, 0, 3)
                            tool:Activate()
                        end)
                        task.wait(0.001)
                    end
                end
            end
        end
    end)
end

--// GIỮ AUTO FARM SAU KHI CHẾT
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    char:WaitForChild("Humanoid", 10)
    if Config.Enabled then
        task.wait(0.1) -- chờ nhân vật hồi sinh ổn định
        StartAutoFarmLoop()
    end
end)

--// CHẠY LẦN ĐẦU
StartAutoFarmLoop()

--// FLUENT UI (TAB MAIN)
pcall(function()
    if Tabs and Tabs.Farm then
        Tabs.Farm:AddToggle("AutoFarm", {
            Title = "Auto Farm Mobs",
            Default = false,
            Callback = function(value)
                Config.Enabled = value
                if value then
                    StartAutoFarmLoop()
                end
            end
        })

        Tabs.Farm:AddSlider("ScanRadius", {
            Title = "Tầm Quét",
            Min = 500,
            Max = 10000,
            Default = Config.ScanRadius,
            Rounding = 0,
            Callback = function(v)
                Config.ScanRadius = v
            end
        })

        Tabs.Farm:AddSlider("FarmDistance", {
            Title = "Khoảng cách đứng",
            Min = 1,
            Max = 10,
            Default = Config.FarmDistance,
            Rounding = 2,
            Callback = function(v)
                Config.FarmDistance = v
            end
        })
    end
end)

--// TẠO NÚT TELEPORT VÀ BLACKLIST CHO QUÁI
if Tabs and Tabs.Farm then
    for _, enemy in pairs(EnemiesFolder:GetDescendants()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart", true) then
            local name = enemy.Name

       

         
        end
    end
end


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
repeat task.wait() until LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")

-- chọn tab: ưu tiên Main, không có thì Quai, rồi Farm
local uiTab = (Tabs and (Tabs.Farm or Tabs.Quai or Tabs.Farm))
if not uiTab then
    return
end

-- trạng thái toàn cục (giữ khi reload)
getgenv().AF = getgenv().AF or {}
local AF = getgenv().AF
AF.AutoEquip = AF.AutoEquip or {}
AF.CurrentTool = AF.CurrentTool or nil

-- hàm lấy tool list
local function GetToolNames()
    local names = {}
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and not table.find(names, t.Name) then table.insert(names, t.Name) end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and not table.find(names, t.Name) then table.insert(names, t.Name) end
        end
    end
    return names
end

-- Store toggle objects
local ToolToggles = {}

-- Hàm tạo toggle cho từng vũ khí
local function RefreshToolToggles()
    local toolNames = GetToolNames()
    local existed = {}
    
    -- nếu tool có toggle rồi thì bỏ qua, nếu chưa thì thêm toggle
    for _, name in ipairs(toolNames) do
        existed[name] = true
        if not ToolToggles[name] then
            ToolToggles[name] = uiTab:AddToggle("Tool_" .. name, {
                Title = "🗡️ " .. name,
                Default = AF.AutoEquip[name] or false
            })
         ToolToggles[name]:OnChanged(function(v)
    AF.AutoEquip[name] = v
    if v then
        AF.CurrentTool = name
        for otherName, otherToggle in pairs(ToolToggles) do 
            if otherName ~= name then
                otherToggle:SetValue(false)
                AF.AutoEquip[otherName] = false
            end
        end
        TryEquip(name) -- 🆕 ép trang bị ngay khi bật toggle
    elseif AF.CurrentTool == name then
        AF.CurrentTool = nil
    end
end)
        end
    end
    
    -- xóa toggle thừa khi tool biến mất
    for name, toggle in pairs(ToolToggles) do
        if not existed[name] then
            toggle:Remove()
            ToolToggles[name] = nil
            AF.AutoEquip[name] = nil
        end
    end
end

-- Nút cập nhật toggle
uiTab:AddButton({
    Title = "🔁 Cập nhật Vũ Khí",
    Callback = RefreshToolToggles
})

-- Tự động cập nhật mỗi 5s
task.spawn(function()
    while task.wait(5) do
        RefreshToolToggles()
    end
end)

-- Hàm trang bị tool
local function TryEquip(toolName)
    if not toolName then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    if char:FindFirstChild(toolName) then return true end
    
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local tool = bp and bp:FindFirstChild(toolName)
    if not tool then
        tool = char:FindFirstChild(toolName)
    end
    
    if tool and tool:IsA("Tool") then
        pcall(function() tool.Parent = char end)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum:EquipTool(tool) end)
        end
        return true
    end
    return false
end

-- Vòng lặp Auto Equip
task.spawn(function()
    while task.wait(1) do
        if AF.CurrentTool then 
            TryEquip(AF.CurrentTool)
        end
    end
end)

---------------------
local thongbao = Tabs.Farm:AddSection("Tự động kĩ năng liên tục")

States.AutoSkill = {
    Z = false,
    X = false,
    C = false,
    V = false,
    B = false,
	Q = false,
	F = false,
    G = false,
	H = false,
    Threads = {}
}




local function StartSpamKey(key)
    return task.spawn(function()
        while States.AutoSkill[key] do
            if Enum.KeyCode[key] then
                vim:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                task.wait(0.03)
                vim:SendKeyEvent(false, Enum.KeyCode[key], false, game)
            end
            task.wait(0.05)
        end
    end)
end

local function CreateKeyToggle(key)
    local toggle = Tabs.Farm:AddToggle("Auto"..key, {
        Title = "Auto 🟢 " .. key,
        Default = false
    })

    toggle:OnChanged(function(Value)
        States.AutoSkill[key] = Value
        if Value then
            States.AutoSkill.Threads[key] = StartSpamKey(key)
        else
            if States.AutoSkill.Threads[key] then
                task.cancel(States.AutoSkill.Threads[key])
                States.AutoSkill.Threads[key] = nil
            end
        end
    end)
end

CreateKeyToggle("Z")
CreateKeyToggle("X")
CreateKeyToggle("C")
CreateKeyToggle("V")
CreateKeyToggle("B")
CreateKeyToggle("Q")
CreateKeyToggle("F")
CreateKeyToggle("G")
CreateKeyToggle("H")

local lowGameButton = Tabs.Main:AddButton({
    Title = "Tối ưu game",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://pastefy.app/zHXeYX07/raw", true))()
        end)
        if not success then
   
        end
    end
})
States.AutoTPSafe = States.AutoTPSafe or {}

local AutoTPSafeToggle = Tabs.Main:AddToggle("AutoTPSafe", {
    Title = "Auto TP Safe Zone",
    Default = false
})

AutoTPSafeToggle:OnChanged(function(Value)
    States.AutoTPSafe.Enabled = Value
    local Workspace = game:GetService("Workspace")

    local safeZone = Workspace:FindFirstChild("PrivateFarmZone")
    if not safeZone then
        safeZone = Instance.new("Part")
        safeZone.Size = Vector3.new(512, 1, 512)
        safeZone.Position = Vector3.new(50005, 5000, 50000)
        safeZone.Anchored = true
        safeZone.Locked = true
        safeZone.BrickColor = BrickColor.new("Dark stone grey")
        safeZone.Name = "PrivateFarmZone"
        safeZone.Parent = Workspace
    end

    local SafeZoneCFrame = CFrame.new(safeZone.Position + Vector3.new(0, 5, 0))

    if Value then
        task.spawn(function()
            while States.AutoTPSafe.Enabled do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = SafeZoneCFrame
                end
                task.wait(0.01) -- delay 1s để không spam teleport quá nhanh
            end
        end)
    end
end)

local safe = Tabs.Main:AddButton({
    Title = "Tp Safe Zone",
    Callback = function()
        local workspace = game:GetService("Workspace")
        local safeZone = workspace:FindFirstChild("PrivateFarmZone")

        if not safeZone then
            safeZone = Instance.new("Part")
            safeZone.Size = Vector3.new(512, 1, 512) -- 📏 Kích thước chuẩn Baseplate 2021
            safeZone.Position = Vector3.new(50005, 5000, 50000)
            safeZone.Anchored = true
            safeZone.Locked = true
            safeZone.BrickColor = BrickColor.new("Dark stone grey")
            safeZone.Name = "PrivateFarmZone"
            safeZone.Parent = workspace
        end

        local SafeZoneCFrame = CFrame.new(safeZone.Position + Vector3.new(0, 5, 0))

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SafeZoneCFrame
        end

        print("Afk Zone đã sẵn sàng tại:", safeZone.Position)
    end
})











RefreshToolToggles()
States.AntiAFK = States.AntiAFK or {}

local AntiAFKToggle = Tabs.Main:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Default = false,
})

AntiAFKToggle:OnChanged(function(Value)
    States.AntiAFK.Enabled = Value

    if Value then
        task.spawn(function()
            while States.AntiAFK.Enabled do
                task.wait(600) -- mỗi 10 phút
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
    end
end)


























local tpLocations = {
    ["Đảo tân thủ xanh"] = CFrame.new( -8.0,  59.6,  382.1),
    ["NPC Sam"] = CFrame.new( 1086.1,  61.6,  847.7),
	["NPC bán nước 10K"] = CFrame.new( -4393.6,  67.4,  -1488.7),
	["NPC bán nước 5K"] = CFrame.new( 1058.2,  61.6,  847.9),
	["NPC Lucy"] = CFrame.new( -1101.4,  162.5,  -5789.3),
	["NPC bán kiếm"] = CFrame.new( -279.5,  60.0,  470.5),
	["NPC bán súng"] = CFrame.new( 1696.0,  59.1,  -1125.8),
	["NPC bán kiếm Krima"] = CFrame.new( 1296.7,  221.6,  -2474.3),
	["Đảo Cát"] = CFrame.new( -653.6,  60.5,  -5263.1),
	["Đảo Cave"] = CFrame.new( -2338.1,  68.2,  1258.5),
    ["Tháp không lưu"] = CFrame.new( -3866.1,  614.8,  6450.9 ),
	["Đảo tuyết lớn"] = CFrame.new( -8740.3,  475.9,  3229.8 ),
	["Tân thủ cát"] = CFrame.new( -73.6,  59.6,  -169.2 ),
	["Autumn Island"] = CFrame.new(-4565, 62, -388 ),
	["Desert Island"] = CFrame.new(-1290, 72, -5909 ),
	["Expertise Island"] = CFrame.new(-627, 61, -1563 ),
	["Filler Islands"] = CFrame.new(-881, 62, 1343 ),
	["Grassy Island"] = CFrame.new( 210, 155, -67),
	["Pursuer Island "] = CFrame.new( -3140, 79, 5888),
	["Rocky Island"] = CFrame.new(-2659, 94, 797 ),
	["Sam Island"] = CFrame.new(990, 60, 544 ),
	["Small Island"] = CFrame.new( 4651, 57, 1614),
    ["Snow Island"] = CFrame.new(-7886, 310, 2175 ),
	["Napoclip"] = CFrame.new(-8832, 309, 3323 ),
		
   
}

local locationNames = {}
for name, _ in pairs(tpLocations) do
    table.insert(locationNames, name)
end

local MapSection = Tabs.Map:AddSection("Dịch chuyển đảo")
local TPDropdown = Tabs.Map:AddDropdown("TPDropdown", {
    Title = "Đảo",
    Values = locationNames,
    Multi = false
})

TPDropdown:OnChanged(function(Value)
    local target = tpLocations[Value]
    local player = game.Players.LocalPlayer
    if target and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local char = player.Character

        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        char.HumanoidRootPart.CFrame = target

        task.wait(0.5)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

States.Player.FullSpy = {
    SelectedPlayer = nil,
    Spectate = false,
    TPToPlayer = false
}


local thongbao = Tabs.Players:AddSection("Kẻ địch")

local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

local PlayerDropdown = Tabs.Players:AddDropdown("PlayerDropdown", 
{
    Title = "Chọn người chơi",
    Values = GetPlayerNames(),
    Multi = false,
    Default = 1
})

PlayerDropdown:OnChanged(function(Value)
    States.Player.FullSpy.SelectedPlayer = Players:FindFirstChild(Value)
end)

local ReloadButton = Tabs.Players:AddButton({
    Title = "Cập nhật người chơi",
    Description = "Cập nhật lại danh sách người chơi trong server",
    Callback = function()
        PlayerDropdown.Values = GetPlayerNames()
        PlayerDropdown:SetValue(PlayerDropdown.Values[1] or "")
    end
})

local SpectateToggle = Tabs.Players:AddToggle("SpectateToggle", {
    Title = "Xem góc nhìn người chơi",
    Default = false
})

SpectateToggle:OnChanged(function(Value)
    States.Player.FullSpy.Spectate = Value
    local target = States.Player.FullSpy.SelectedPlayer
    if Value and target and target.Character and target.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)

local TPToggle = Tabs.Players:AddToggle("TPToggle", {
    Title = "Dịch chuyển đến người chơi",
    Default = false
})

TPToggle:OnChanged(function(Value)
    States.Player.FullSpy.TPToPlayer = Value
end)

task.spawn(function()
    while true do
        local target = States.Player.FullSpy.SelectedPlayer
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart

            if States.Player.FullSpy.TPToPlayer then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0,3,0)
                end
                States.Player.FullSpy.TPToPlayer = false -- tự tắt
                TPToggle:SetValue(false)
            end

            if not States.Player.FullSpy.Spectate and workspace.CurrentCamera.CameraSubject ~= LocalPlayer.Character.Humanoid then
                workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end

        task.wait(0.03)
    end
end)

local function UpdatePlayerDropdown()
    PlayerDropdown.Values = GetPlayerNames()
end

Players.PlayerAdded:Connect(UpdatePlayerDropdown)
Players.PlayerRemoving:Connect(function(plr)
    UpdatePlayerDropdown()

    if States.Player.FullSpy.SelectedPlayer == plr then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        end
        States.Player.FullSpy.Spectate = false
        SpectateToggle:SetValue(false)
    end
end)

UpdatePlayerDropdown()
--------------















local TARGET_PLAYER_COUNT = 5 -- Ưu tiên đúng 2 người
local FALLBACK_MAX_PLAYERS = 18 -- fallback tối đa
local PLACE_ID = game.PlaceId
local MAX_PAGES = 100 -- Giới hạn quét trang
local RETRY_DELAY = 0.1 -- thời gian chờ giữa mỗi lần quét (giây)

-- 🔍 Hàm lấy danh sách server
local function GetServers(placeId)
    local servers = {}
    local cursor = ""
    local pageCount = 0

    repeat
        pageCount += 1
        if pageCount > MAX_PAGES then break end

        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100&cursor=%s", placeId, cursor)
        local success, response = pcall(function()
            return request({ Url = url, Method = "GET" })
        end)

        if success and response and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            if data and data.data then
                for _, server in ipairs(data.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        table.insert(servers, server)
                    end
                end
                cursor = data.nextPageCursor or ""
            else
                break
            end
        else
      
            break
        end
    until cursor == ""

    return servers
end

-- 🚀 Hàm tìm server phù hợp
local function FindServer()
    local allServers = GetServers(PLACE_ID)
    if #allServers == 0 then return nil end

    local target = nil
    for _, server in ipairs(allServers) do
        if server.playing == TARGET_PLAYER_COUNT then
            target = server
            break
        end
    end

    if not target then
        for _, server in ipairs(allServers) do
            if server.playing <= FALLBACK_MAX_PLAYERS then
                target = server
                break
            end
        end
    end
    return target
end

-- 🔁 Hàm chạy auto loop
local function AutoServerHop()
    task.spawn(function()
        while true do

            local targetServer = FindServer()

            if targetServer then
               
                local ok, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, targetServer.id, LocalPlayer)
                end)
                if ok then
               
                    break
                else
                    warn("❌ Teleport lỗi: " .. tostring(err))
                end
            else
                print("⚠️ Chưa có server phù hợp, thử lại sau " .. RETRY_DELAY .. " giây...")
            end

            task.wait(RETRY_DELAY)
        end
    end)
end

-- 🟦 Nút trong Tabs.Map
Tabs.Map:AddButton({
    Title = "Hop sever ít người",
    Description = "Tự động tìm và chuyển đến server ít người nhất.",
    Callback = function()
        AutoServerHop()
    end
})
local lowGameButton = Tabs.Main:AddButton({
    Title = "Low Game",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://pastefy.app/zHXeYX07/raw", true))()
        end)
        if not success then
            warn("Lỗi khi chạy script Low Game: "..err)
        end
    end
})
local MapSection = Tabs.Map:AddSection("Teleport Server")

States.Map = States.Map or {}
States.Map.AutoTeleport = false

local teleportInput = MapSection:AddInput("TeleportCodeInput", {
    Title = "Mã máy chủ thường",
    Default = "",
    Placeholder = '.......'
})
Tabs.Map:AddButton({
    Title = "Sao chép mã sever hiện tại",
    Description = "Sao chép mã vào clipboard.",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local placeId = tostring(game.PlaceId)
        local jobId = tostring(game.JobId)

        -- Chuỗi teleport command
        local teleportCmd = string.format(
            'game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s")',
            placeId, jobId
        )

    

        -- Sao chép vào clipboard nếu có hỗ trợ
        if setclipboard then
            local ok, err = pcall(setclipboard, teleportCmd)
            if ok then
                print("✅ Đã sao chép vào clipboard!")
            else
          
            end
        else
        
        end
    end
})
local teleportToggle = MapSection:AddToggle("TeleportToggle", {
    Title = "Dịch chuyển",
    Default = false,
    Callback = function(Value)
        States.Map.AutoTeleport = Value
        if Value then
            local success, err = pcall(function()
                local code = teleportInput.Value
                loadstring("return " .. code)()
            end)
            if not success then
                warn("Teleport lỗi: ", err)
            end
        end
    end
})

local thongbao = Tabs.Fruits:AddSection("Trái hiếm và cực hiếm")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local RareFruitsList = {
    "Barrier", "Bomb", "Candy", "Chilly", "Clone", "Chop", "Slip", "Dark",
    "Diamond", "Flare", "Gas", "Gravity", "Gum", "Hot", "Light", "Love",
    "Magma", "More", "Ope", "Phoenix", "Quake", "Rumble", "Sand", "Spin",
    "Smelt", "Clear", "More Fruit", "Spring"
}

States = States or {}
States.Fruit = States.Fruit or {}
States.Fruit.AutoGrabFruits = {}
local lastGrab = {}

--// CHỈ EQUIP hoặc CLICK NHẶT, KHÔNG BRING
local function GrabFruit(fruitTool)
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    -- sử dụng cooldown theo tên trái, không theo object
    local fruitName = fruitTool.Name
    if tick() - (lastGrab[fruitName] or 0) < 0.01  then return end
    lastGrab[fruitName] = tick()

    pcall(function()
        hum:EquipTool(fruitTool)
    end)
end

local grabConn
local function StartGrabThread()
    if grabConn then return end
    grabConn = game:GetService("RunService").Heartbeat:Connect(function()
        local fruitsFolder = workspace:FindFirstChild("Fruits")
        if not fruitsFolder then return end

        -- kiểm tra xem có trái nào đang được bật
        local active = false
        for _, enabled in pairs(States.Fruit.AutoGrabFruits) do
            if enabled then
                active = true
                break
            end
        end
        if not active then return end

        -- lặp tất cả trái trong folder
        for _, fruit in pairs(fruitsFolder:GetChildren()) do
            if fruit:IsA("Tool") and fruit:FindFirstChild("Handle") then
                for fruitName, enabled in pairs(States.Fruit.AutoGrabFruits) do
                    if enabled and string.find(fruit.Name, fruitName) then
                        GrabFruit(fruit) -- nhặt tất cả trái phù hợp
                    end
                end
            end
        end
    end)
end

-- Tạo toggle UI tự động thêm cho mỗi trái
for _, fruitName in ipairs(RareFruitsList) do
    States.Fruit.AutoGrabFruits[fruitName] = false
    local tgl = Tabs.Fruits:AddToggle("Grab_" .. fruitName, {
        Title = "Nhặt trái: " .. fruitName,
        Default = false
    })
    tgl:OnChanged(function(Value)
        States.Fruit.AutoGrabFruits[fruitName] = Value
        StartGrabThread()
    end)
end



local function createFruitESP(fruit)
    if not fruit:IsDescendantOf(workspace) then return end
    if fruit:FindFirstChild("FruitESP") then return end
    local target = fruit:FindFirstChild("Handle") or fruit.PrimaryPart or (fruit:IsA("BasePart") and fruit)
    if not target then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FruitESP"
    billboard.Size = UDim2.new(0,200,0,50)
    billboard.AlwaysOnTop = true
    billboard.Adornee = target
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = fruit

    local frame = Instance.new("Frame")
    frame.AutomaticSize = Enum.AutomaticSize.X  -- co khung theo text
    frame.Size = UDim2.new(0, 0, 0, 24)        -- chiều cao cố định
    frame.AnchorPoint = Vector2.new(0.5, 1)
    frame.Position = UDim2.new(0.5, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 40, 80) -- nền xanh đậm
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local nameText = Instance.new("TextLabel")
    nameText.Size = UDim2.new(1, -10, 1, 0) -- có padding để chữ không dính mép
    nameText.Position = UDim2.new(0, 5, 0, 0)
    nameText.BackgroundTransparency = 1
    nameText.TextStrokeTransparency = 0.2
    nameText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameText.TextSize = 16
    nameText.Font = Enum.Font.GothamBold -- font đẹp
    nameText.TextColor3 = Color3.fromRGB(50, 200, 255) -- xanh sáng
    nameText.Text = fruit.Name
    nameText.Parent = frame

    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = Color3.fromRGB(50, 200, 255)
    line.Visible = true



    task.spawn(function()
        while billboard.Parent and fruitEspEnabled do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and target then
                local dist = (target.Position - player.Character.HumanoidRootPart.Position).Magnitude
                label.Text = string.format("%s\n%.0f", fruit.Name, dist)
            end
            task.wait(0.3)
        end
        if billboard then billboard:Destroy() end
    end)
end

local function StartFruitESP()
    for _, fruit in ipairs(workspace:GetDescendants()) do
        if fruit:IsA("Model") and fruit.Name:match("Fruit") then
            createFruitESP(fruit)
        end
    end
    workspace.DescendantAdded:Connect(function(obj)
        if fruitEspEnabled and obj:IsA("Model") and obj.Name:match("Fruit") then
            createFruitESP(obj)
        end
    end)
end

local FruitESP_Toggle = Tabs.Fruits:AddToggle("FruitESP", { Title = "Devil Fruit Location", Default = false })
FruitESP_Toggle:OnChanged(function(Value)
    fruitEspEnabled = Value
    States.Fruit.FruitESP = Value
    if Value then StartFruitESP()
    else
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BillboardGui") and v.Name == "FruitESP" then v:Destroy() end
        end
    end
end)



local thongbao = Tabs.Players:AddSection("Cài Đặt Nhân Vật")

-- NoClip / Xuyên tường
local NoClipToggle = Tabs.Players:AddToggle("NoClip", {
    Title = "Đi xuyên tường",
    Default = false
})

-- SpeedHack / Chạy nhanh
local SpeedToggle = Tabs.Players:AddToggle("SpeedHack", {
    Title = "Chạy nhanh",
    Default = false
})

local SpeedSlider = Tabs.Players:AddSlider("SpeedSlider", {
    Title = "Tốc độ chạy",
    Min = 16,
    Max = 200,
    Default = 16,
    Rounding = 0
})

-- Giá trị runtime
local NoClipEnabled = false
local SpeedEnabled = false
local WalkSpeedValue = 16


-- NoClip logic
NoClipToggle:OnChanged(function(Value)
    NoClipEnabled = Value
    if Value then
        
    else
        
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if NoClipEnabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)


-- SpeedHack logic
SpeedToggle:OnChanged(function(Value)
    SpeedEnabled = Value
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.WalkSpeed = Value and WalkSpeedValue or 16
    end
end)

SpeedSlider:OnChanged(function(Value)
    WalkSpeedValue = Value
    if SpeedEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hum then
            hum.WalkSpeed = WalkSpeedValue
        end
    end
end)


-- Giữ khi respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid")
    if SpeedEnabled and hum then
        hum.WalkSpeed = WalkSpeedValue
    end
end)


--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// BIẾN LƯU TRẠNG THÁI
local flyConnection = nil
local States = {
    Player = {
        FlightEnabled = false,
        FlightSpeed = 200, -- Tốc độ mặc định
    }
}

--🕊️ TOGGLE: Bay
local FlightToggle = Tabs.Players:AddToggle("Flight", {
    Title = "Nhân vật bay",
    Default = false
})

--⚡ SLIDER: Tốc độ bay
local FlightSlider = Tabs.Players:AddSlider("FlightSpeed", {
    Title = "Tốc độ bay",
    Description = "Chỉnh tốc độ bay của nhân vật",
    Default = States.Player.FlightSpeed,
    Min = 100,
    Max = 5000,
    Rounding = 0
})

--📏 CẬP NHẬT TỐC ĐỘ KHI KÉO SLIDER
FlightSlider:OnChanged(function(value)
    States.Player.FlightSpeed = value
end)

--🚀 HÀNH ĐỘNG KHI BẬT TẮT BAY
FlightToggle:OnChanged(function(enabled)
    States.Player.FlightEnabled = enabled

    if enabled then
        if flyConnection then flyConnection:Disconnect() end

        flyConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local camCF = workspace.CurrentCamera.CFrame
            local moveDir = Vector3.new()

            -- Điều hướng WASD + Space + Shift
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

            hrp.Velocity = moveDir.Magnitude > 0
                and moveDir.Unit * States.Player.FlightSpeed
                or Vector3.new(0, 0, 0)
        end)

    else
        -- Tắt bay
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
    end
end)

States.Player.JumpEnabled = false
States.Player.JumpValue = 50 -- mặc định

local InfiniteJumpToggle = Tabs.Players:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
	Description = "Nhảy vô hạn",
})

InfiniteJumpToggle:OnChanged(function(Value)
    States.Player.InfiniteJump = Value
    if Value then
        if InfiniteJumpConn then InfiniteJumpConn:Disconnect() end
        InfiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            if States.Player.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if InfiniteJumpConn then
            InfiniteJumpConn:Disconnect()
            InfiniteJumpConn = nil
        end
    end
end)

Options.InfiniteJump:SetValue(States.Player.InfiniteJump)

local JumpToggle = Tabs.Players:AddToggle("JumpToggle", {
    Title = "Bật Nhảy Cao",
    Default = false
})
JumpToggle:OnChanged(function(Value)
    States.Player.JumpEnabled = Value
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = Value and States.Player.JumpValue or 50
    end
end)

local JumpSlider = Tabs.Players:AddSlider("JumpSlider", {
    Title = "Điều chỉnh Nhảy",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 0
})
JumpSlider:OnChanged(function(Value)
    States.Player.JumpValue = Value
    if States.Player.JumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = Value
    end
end)

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    if States.Player.SpeedEnabled then
        char.Humanoid.WalkSpeed = States.Player.SpeedValue
    end
    if States.Player.JumpEnabled then
        char.Humanoid.JumpPower = States.Player.JumpValue
    end
end)

------------local Players = game:GetService("Players")

local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")
local samUI = playerGui:WaitForChild("SamUI")
local frame = samUI:WaitForChild("Frame")
-- Nút Claim trong frame

-- Trạng thái toggle
local showFrame = false

-- Hàm cập nhật
local function UpdateFrame()
    frame.Visible = showFrame
end

-- Tạo toggle vào Tabs.Mai
Tabs.Main:AddToggle("ShowSamUIFrame", {
    Title = "Menu Sam từ xa",
    Default = false
}):OnChanged(function(Value)
    showFrame = Value
    UpdateFrame()
end)
local States = States or {}
States.Drink = States.Drink or {}

local BuyLimitInput = Tabs.Shop:AddInput("BuyLimitInput", {
    Title = "Số Lần Mua ",
    Default = "1", -- giá trị mặc định
    Numeric = true, -- chỉ cho nhập số
    Placeholder = "Nhập số lần",
    Callback = function(value)
        local n = tonumber(value)
        if n then
            _G.AutoBuyCiderLimit = n
        else
            _G.AutoBuyCiderLimit = 1 -- fallback mặc định
        end
    end
})

-- Toggle Auto Buy Cider
local buy = Tabs.Shop:AddToggle("AutoBuyCider", {
    Title = "Auto Buy Cider",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local gui = player:WaitForChild("PlayerGui"):WaitForChild("NPCUI"):WaitForChild("BuyDrinksPlus")
        local cider = gui:WaitForChild("Cider")
        gui.Visible = state -- show/hide menu theo toggle

        if state then
            _G.AutoBuyCiderRunning = true
            _G.AutoBuyCiderLimit = _G.AutoBuyCiderLimit or 1 -- mặc định 5 lần

            task.spawn(function()
                local count = 0
                while _G.AutoBuyCiderRunning and count < _G.AutoBuyCiderLimit do
                    -- Fire tất cả MouseButton1Click connections
                    for _, v in pairs(getconnections(cider.MouseButton1Click)) do
                        v:Fire()
                    end

                    -- Optional: click bằng VirtualInputManager
                    local vp = cider:FindFirstChild("ViewportFrame")
                    if vp then
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        local pos = vp.AbsolutePosition + vp.AbsoluteSize / 2
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                    end

                    count = count + 1
                    task.wait(0.1) -- delay giữa các lần click
                end

                -- Tự động tắt toggle sau khi hoàn tất số lần
                _G.AutoBuyCiderRunning = false
                gui.Visible = false
                buy:Set(false)
            end)
        else
            -- Tắt auto-click nếu toggle bị tắt
            _G.AutoBuyCiderRunning = false
            gui.Visible = false
        end
    end
})
local LemonadeLimitInput = Tabs.Shop:AddInput("LemonadeLimitInput", {
    Title = "Số Lần Mua Lemonade",
    Default = "1",
    Numeric = true,
    Placeholder = "Nhập số lần",
    Callback = function(value)
        local n = tonumber(value)
        if n then
            _G.AutoBuyLemonadeLimit = n
        else
            _G.AutoBuyLemonadeLimit = 1 -- fallback mặc định
        end
    end
})

-- Toggle Auto Buy Lemonade
local buyLemonade = Tabs.Shop:AddToggle("AutoBuyLemonade", {
    Title = "Auto Buy Lemonade",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local gui = player:WaitForChild("PlayerGui"):WaitForChild("NPCUI"):WaitForChild("BuyDrinksPlus")
        local lemonade = gui:WaitForChild("Lemonade")
        gui.Visible = state -- show/hide menu theo toggle

        if state then
            _G.AutoBuyLemonadeRunning = true
            _G.AutoBuyLemonadeLimit = _G.AutoBuyLemonadeLimit or 1 -- mặc định 5 lần

            task.spawn(function()
                local count = 0
                while _G.AutoBuyLemonadeRunning and count < _G.AutoBuyLemonadeLimit do
                    -- Fire tất cả MouseButton1Click connections
                    for _, v in pairs(getconnections(lemonade.MouseButton1Click)) do
                        v:Fire()
                    end

                    -- Click bằng VirtualInputManager (nếu có ViewportFrame)
                    local vp = lemonade:FindFirstChild("ViewportFrame")
                    if vp then
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        local pos = vp.AbsolutePosition + vp.AbsoluteSize / 2
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                    end

                    count = count + 1
                    task.wait(0.1)
                end

                -- Tự động tắt toggle sau khi hoàn tất số lần
                _G.AutoBuyLemonadeRunning = false
                gui.Visible = false
                buyLemonade:Set(false)
            end)
        else
            -- Tắt auto-click nếu toggle bị tắt
            _G.AutoBuyLemonadeRunning = false
            gui.Visible = false
        end
    end
})

-- Thêm ô input để chỉnh số lần mua Smoothie
local SmoothieLimitInput = Tabs.Shop:AddInput("SmoothieLimitInput", {
    Title = "Số Lần Mua Smoothie",
    Default = "1",
    Numeric = true,
    Placeholder = "Nhập số lần",
    Callback = function(value)
        local n = tonumber(value)
        if n then
            _G.AutoBuySmoothieLimit = n
        else
            _G.AutoBuySmoothieLimit = 1 -- fallback mặc định
        end
    end
})

-- Toggle Auto Buy Smoothie
local buySmoothie = Tabs.Shop:AddToggle("AutoBuySmoothie", {
    Title = "Auto Buy Smoothie",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local gui = player:WaitForChild("PlayerGui"):WaitForChild("NPCUI"):WaitForChild("BuyDrinksPlus")
        local smoothie = gui:WaitForChild("Smoothie")
        gui.Visible = state -- show/hide menu theo toggle

        if state then
            _G.AutoBuySmoothieRunning = true
            _G.AutoBuySmoothieLimit = _G.AutoBuySmoothieLimit or 1 -- mặc định 5 lần

            task.spawn(function()
                local count = 0
                while _G.AutoBuySmoothieRunning and count < _G.AutoBuySmoothieLimit do
                    -- Fire tất cả MouseButton1Click connections
                    for _, v in pairs(getconnections(smoothie.MouseButton1Click)) do
                        v:Fire()
                    end

                    -- Click bằng VirtualInputManager (nếu có ViewportFrame)
                    local vp = smoothie:FindFirstChild("ViewportFrame")
                    if vp then
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        local pos = vp.AbsolutePosition + vp.AbsoluteSize / 2
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                    end

                    count = count + 1
                    task.wait(0.1)
                end

                -- Tự động tắt toggle sau khi hoàn tất số lần
                _G.AutoBuySmoothieRunning = false
                gui.Visible = false
                buySmoothie:Set(false)
            end)
        else
            -- Tắt auto-click nếu toggle bị tắt
            _G.AutoBuySmoothieRunning = false
            gui.Visible = false
        end
    end
})
-- Thêm ô input để chỉnh số lần mua Juice
local JuiceLimitInput = Tabs.Shop:AddInput("JuiceLimitInput", {
    Title = "Số Lần Mua Juice",
    Default = "1",
    Numeric = true,
    Placeholder = "Nhập số lần",
    Callback = function(value)
        local n = tonumber(value)
        if n then
            _G.AutoBuyJuiceLimit = n
        else
            _G.AutoBuyJuiceLimit = 1 -- fallback mặc định
        end
    end
})

-- Toggle Auto Buy Juice
local buyJuice = Tabs.Shop:AddToggle("AutoBuyJuice", {
    Title = "Auto Buy Juice",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local gui = player:WaitForChild("PlayerGui"):WaitForChild("NPCUI"):WaitForChild("BuyDrinksPlus")
        local juice = gui:WaitForChild("Juice")
        gui.Visible = state -- show/hide menu theo toggle

        if state then
            _G.AutoBuyJuiceRunning = true
            _G.AutoBuyJuiceLimit = _G.AutoBuyJuiceLimit or 1 -- mặc định 5 lần

            task.spawn(function()
                local count = 0
                while _G.AutoBuyJuiceRunning and count < _G.AutoBuyJuiceLimit do
                    -- Fire tất cả MouseButton1Click connections
                    for _, v in pairs(getconnections(juice.MouseButton1Click)) do
                        v:Fire()
                    end

                    -- Click bằng VirtualInputManager (nếu có ViewportFrame)
                    local vp = juice:FindFirstChild("ViewportFrame")
                    if vp then
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        local pos = vp.AbsolutePosition + vp.AbsoluteSize / 2
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                    end

                    count = count + 1
                    task.wait(0.1)
                end

                -- Tự động tắt toggle sau khi hoàn tất số lần
                _G.AutoBuyJuiceRunning = false
                gui.Visible = false
                buyJuice:Set(false)
            end)
        else
            -- Tắt auto-click nếu toggle bị tắt
            _G.AutoBuyJuiceRunning = false
            gui.Visible = false
        end
    end
})

States = States or {}
States.Drink = States.Drink or {}

local AllowedDrinks = {
    ["Cider+"] = true,
    ["Lemonade+"] = true,
    ["Juice+"] = true,
    ["Smoothie+"] = true,
}

local DropAmount = 1
local LocalPlayer = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")

-- Input Số lượng thả
local DropBox = Tabs.Shop:AddInput("DropDrinkAmount", {
    Title = "Số lượng thả",
    Default = "1",
    Placeholder = "Nhập số lượng...",
    Numeric = true
})

DropBox:OnChanged(function(Value)
    local num = tonumber(Value)
    DropAmount = (num and num > 0) and num or 1
end)

-- Toggle AutoDrop
local DropToggle = Tabs.Shop:AddToggle("AutoDropDrink", {
    Description = "Thả nước liên tục",
    Title = "Auto Drop Nước",
    Default = false
})

DropToggle:OnChanged(function(Value)
    States.Drink.AutoDrop = Value
    if Value then
        task.spawn(function()
            autoDropContinuous()
        end)
    end
end)

function autoDropContinuous()
    while States.Drink.AutoDrop do
        local backpack, char = LocalPlayer.Backpack, LocalPlayer.Character
        if not (backpack and char and char:FindFirstChild("Humanoid")) then
            task.wait(0.5)
        else
            local dropped = 0
            for _, tool in ipairs(backpack:GetChildren()) do
                if dropped >= DropAmount then break end
                if tool:IsA("Tool") and AllowedDrinks[tool.Name] then
                    char.Humanoid:EquipTool(tool)

                    local startTime = tick()
                    while tool.Parent ~= char and tick() - startTime < 1 do
                        task.wait(0.01)
                    end

                    while tool.Parent == char and States.Drink.AutoDrop do
                        VIM:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
                        task.wait(0.01)
                        VIM:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
                        task.wait(0.01)
                    end
                    dropped += 1
                end
            end
        end
        task.wait(0.05)
    end
end

-- Toggle AutoDrink
getgenv().DRINK_DELAY = 0.1 -- delay giữa mỗi lần uống
local DrinkToggle = Tabs.Shop:AddToggle("AutoDrink", {
    Description = "Tự động uống nước",
    Title = "Auto Drink",
    Default = false
})

DrinkToggle:OnChanged(function(Value)
    States.Drink.AutoDrink = Value
    if Value then
        task.spawn(autoDrinkLoop)
    end
end)

function autoDrinkLoop()
    while States.Drink.AutoDrink do
        local backpack, char = LocalPlayer.Backpack, LocalPlayer.Character
        if backpack and char and char:FindFirstChild("Humanoid") then
            for _, tool in ipairs(backpack:GetChildren()) do
                if not States.Drink.AutoDrink then break end
                if tool:IsA("Tool") and AllowedDrinks[tool.Name] then
                    char.Humanoid:EquipTool(tool)
                    task.wait(0.05)
                    if tool.Parent == char then
                        tool:Activate()
                        task.wait(getgenv().DRINK_DELAY)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end
--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--// CÀI ĐẶT
local CHECK_INTERVAL = 0.5 -- kiểm tra mỗi 0.5s
local CLICK_INTERVAL = 0.08 -- khoảng giữa các click (tùy chỉnh)
local TELEPORT_STEPS = 10 -- số bước di chuyển khi teleport
local TELEPORT_DELAY = 0.03 -- delay giữa mỗi bước teleport

--// TRẠNG THÁI CLICK
local isClicking = false
local AutoFindSamEnabled = false -- trạng thái toggle

--// HÀM LẤY COMPASS VÀ TARGETPOS
local function getCompassTarget()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item and item.Name == "Compass" then
                local targetValue = item:FindFirstChild("TargetPos")
                if targetValue and targetValue:IsA("Vector3Value") then
                    return item, targetValue.Value
                end
            end
        end
    end

    if Character then
        for _, item in pairs(Character:GetChildren()) do
            if item and item.Name == "Compass" then
                local targetValue = item:FindFirstChild("TargetPos")
                if targetValue and targetValue:IsA("Vector3Value") then
                    return item, targetValue.Value
                end
            end
        end
    end

    return nil, nil
end

--// HÀM TELEPORT TỪ DƯỚI LÊN
local function safeTeleport(targetPos)
    if not HumanoidRootPart then return end

    local currentPos = HumanoidRootPart.Position
    local increment = (targetPos - currentPos) / TELEPORT_STEPS

    for i = 1, TELEPORT_STEPS do
        pcall(function()
            HumanoidRootPart.CFrame = CFrame.new(currentPos + increment * i)
        end)
        wait(TELEPORT_DELAY)
    end
end

--// HÀM CLICK bằng VirtualUser
local function startAutoClicking(stopCheckFunc)
    if isClicking then return end
    isClicking = true

    spawn(function()
        while isClicking do
            if not AutoFindSamEnabled then break end

            local ok, shouldContinue = pcall(function() return stopCheckFunc() end)
            if not ok or not shouldContinue then break end

            pcall(function()
                VirtualUser:ClickButton1(Vector2.new(0,0))
            end)

            wait(CLICK_INTERVAL)
        end
        isClicking = false
    end)
end

local function stopAutoClicking()
    isClicking = false
end

--// CẬP NHẬT CHARACTER KHI RESPAWN
local function refreshCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.1)
    refreshCharacter()
end)

--// TOGGLE GUI
local AutoFindSam = Tabs.Main:AddToggle("AutoSam", { 
    Title = "Auto Find Sam", 
    Default = false
})

AutoFindSam:OnChanged(function(value)
    AutoFindSamEnabled = value
    if not value then
        stopAutoClicking()
    end
end)

--// LOOP CHÍNH (teleport + equip + auto click)
RunService.Heartbeat:Connect(function()
    if not AutoFindSamEnabled then return end

    local compass, targetPos = getCompassTarget()
    if compass and targetPos then
        -- Trang bị Compass
        pcall(function()
            local humanoid = Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(compass)
            end
        end)

        -- Teleport từ dưới lên
        safeTeleport(targetPos + Vector3.new(0,1,0)) -- offset +1 để tránh dính đất

        -- Bắt đầu auto click
        startAutoClicking(function()
            return (compass and compass.Parent and (compass.Parent:IsDescendantOf(LocalPlayer) or compass.Parent.Name == "Backpack"))
        end)
    else
        stopAutoClicking()
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
Fluent:Notify({
    Title = "Rabbit Hub",
    Content = "Cập nhật script thành công",
    Duration = 8
})
SaveManager:LoadAutoloadConfig()
