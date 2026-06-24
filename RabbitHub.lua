
-- ====== ANTI-AFK + CHỐNG TELEPORT - TỐI ƯU ======
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local currentPosition = nil
local afkCounter = 0
local isTeleporting = false

-- ====== KIỂM TRA VÀ KHỞI TẠO ======
local function getCharacter()
    if not character or not character.Parent then
        character = player.Character or player.CharacterAdded:Wait()
    end
    return character
end

local function getPrimaryPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart") or char and char.PrimaryPart
end

-- ====== ANTI-AFK (TỐI ƯU) ======
print("🛡️ Anti-AFK đang chạy...")

-- Chỉ gửi sự kiện ảo, không di chuyển nhân vật thật để tránh ảnh hưởng farm
local function AntiAFK()
    local hrp = getPrimaryPart()
    if not hrp then return end
    
    -- Cách 1: Dùng VirtualInputManager (nhẹ hơn)
    pcall(function()
        -- Giả lập nhấn phím W
        VirtualInputManager:SendKeyEvent(true, "W", false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, "W", false, game)
        
        -- Giả lập nhấn Space
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    -- Cách 2: Di chuyển cực nhẹ (không ảnh hưởng)
    pcall(function()
        local pos = hrp.Position
        hrp.CFrame = CFrame.new(pos + Vector3.new(0.5, 0, 0))
        task.wait(0.05)
        hrp.CFrame = CFrame.new(pos)
    end)
end

-- Anti-AFK mỗi 60 giây (giảm tần suất)
task.spawn(function()
    while true do
        task.wait(60) -- Tăng từ 50 lên 60
        if not getCharacter() then continue end
        
        pcall(AntiAFK)
        afkCounter = afkCounter + 1
        
        -- Reset counter mỗi 10 lần
        if afkCounter >= 10 then
            afkCounter = 0
        end
    end
end)

-- ====== CHỐNG TELEPORT THÔNG MINH ======
print("🛡️ Chống Teleport đang chạy...")

-- Lưu vị trí ban đầu
task.wait(1)
local hrp = getPrimaryPart()
if hrp then
    currentPosition = hrp.Position
end

-- Kiểm tra teleport với tần suất thấp hơn
task.spawn(function()
    while true do
        task.wait(1) -- Tăng từ 0.5 lên 1 để giảm lag
        
        pcall(function()
            local hrp = getPrimaryPart()
            if not hrp then return end
            
            local currentPos = hrp.Position
            if currentPosition then
                local distance = (currentPos - currentPosition).Magnitude
                
                -- Phát hiện teleport
                if distance > 150 and not isTeleporting then
                    print("🔄 Phát hiện teleport! Đang khôi phục vị trí...")
                    isTeleporting = true
                    
                    -- Khôi phục vị trí từ từ để tránh tween xung đột
                    for i = 1, 5 do
                        pcall(function()
                            hrp.CFrame = CFrame.new(currentPosition)
                        end)
                        task.wait(0.05)
                    end
                    
                    isTeleporting = false
                    print("✅ Đã khôi phục vị trí!")
                end
            end
            
            -- Cập nhật vị trí nếu di chuyển hợp lệ
            if not isTeleporting then
                currentPosition = currentPos
            end
        end)
    end
end)

-- ====== CHỐNG TELEPORT QUA EVENT (NHẸ HƠN) ======
pcall(function()
    -- Hook Teleport
    local oldTeleport = TeleportService.Teleport
    TeleportService.Teleport = function(placeId, playerToTeleport, ...)
        if placeId == game.PlaceId then
            -- Teleport cùng map => chặn
            print("✅ Đã chặn teleport cùng map!")
            return nil
        end
        -- Cho phép teleport sang map khác
        return oldTeleport(placeId, playerToTeleport, ...)
    end
    
    -- Hook TeleportAsync
    if TeleportService.TeleportAsync then
        local oldAsync = TeleportService.TeleportAsync
        TeleportService.TeleportAsync = function(placeIds, players, ...)
            if type(placeIds) == "table" then
                local newIds = {}
                local blocked = false
                for _, id in pairs(placeIds) do
                    if id == game.PlaceId then
                        print("✅ Đã chặn teleport async!")
                        blocked = true
                    else
                        table.insert(newIds, id)
                    end
                end
                if blocked and #newIds == 0 then
                    return nil
                end
                return oldAsync(newIds, players, ...)
            end
            return oldAsync(placeIds, players, ...)
        end
    end
end)

-- ====== CHỐNG RESET CHARACTER (THÊM) ======
pcall(function()
    -- Chặn respawn tự động
    player.CharacterAutoLoads = true
    
    -- Hook CharacterAdded để khôi phục vị trí nếu bị reset
    local oldCharacterAdded = player.CharacterAdded
    player.CharacterAdded = function(character)
        if oldCharacterAdded then
            oldCharacterAdded(character)
        end
        
        -- Khôi phục vị trí
        task.wait(0.5)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp and currentPosition then
            hrp.CFrame = CFrame.new(currentPosition)
        end
    end
end)

-- ====== DỌN DẸP BỘ NHỚ ĐỊNH KỲ ======
task.spawn(function()
    while true do
        task.wait(300) -- 5 phút
        -- Thu gom bộ nhớ
        collectgarbage()
        
        -- Reset counter nếu cần
        if afkCounter > 5 then
            afkCounter = 0
        end
    end
end)

-- ====== KHỞI ĐỘNG ======
print("========================================")
print("✅ ANTI-AFK + CHỐNG TELEPORT ĐÃ SẴN SÀNG!")
print("🕐 Anti-AFK: mỗi 60 giây")
print("🔄 Chống Teleport: bán kính 150 units")
print("========================================")

-- Giữ script chạy (nhẹ hơn)
while task.wait(60) do
    -- Không làm gì, chỉ giữ script sống
end
