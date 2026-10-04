-- Delta 專用：全隊肉體影響隔離棒 (手持時自動湮滅危脅)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

local ProtectionStick = Instance.new("Tool")
ProtectionStick.Name = "🌌 全隊影響湮滅棒"
ProtectionStick.RequiresHandle = true

local Handle = Instance.new("Part")
Handle.Name = "Handle"
Handle.Size = Vector3.new(0.5, 4, 0.5)
Handle.BrickColor = BrickColor.new("Electric Blue")
Handle.Material = Enum.Material.Neon
Handle.Parent = ProtectionStick

local isEquipped = false
local scanConnection

-- 掃描並刪除所有可能影響自己或隊友的實體（怪物/特定致命物件）
local function wipeThreats()
    if not isEquipped then return end
    
    -- 常見的 Doors 怪物與環境殺手實體清單
    local THREAT_KEYWORDS = {"rush", "eyes", "ambush", "seek", "screech", "halt", "figure", "snare", "giggle"}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local nameLower = string.lower(obj.Name)
            
            -- 排除自己和房間裡的隊友角色，避免把隊友刪掉
            local isFriendly = false
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and obj:IsDescendantOf(player.Character) then
                    isFriendly = true
                    break
                end
            end
            
            if not isFriendly and obj.Name ~= "Baseplate" and obj.Name ~= "Terrain" then
                -- 1. 根據名字匹配怪物
                local isThreat = false
                for _, keyword in pairs(THREAT_KEYWORDS) do
                    if string.find(nameLower, keyword) then isThreat = true break end
                end
                
                -- 2. 或是檢測這個物件是否帶有傷害性腳本/觸發器，並直接將其刪除
                if isThreat or obj:FindFirstChild("TouchInterest") then
                    pcall(function()
                        print("🌌 [物理隔離] 為了消除對全隊的影響，已直接抹除: " .. obj.Name)
                        obj:Destroy()
                    end)
                end
            end
        end
    end
end

-- 只有在「拿在手上」時，才會持續高頻率執行全地圖威脅刪除
ProtectionStick.Equipped:Connect(function()
    isEquipped = true
    print("🌌 影響隔離棒已裝備：全隊肉體安全防禦領域展開！")
    scanConnection = RunService.Heartbeat:Connect(function()
        wipeThreats()
    end)
end)

-- 放下棒子時，停止自動刪除
ProtectionStick.Unequipped:Connect(function()
    isEquipped = false
    if scanConnection then
        scanConnection:Disconnect()
        scanConnection = nil
    end
    print("🌌 影響隔離棒已收回：防禦領域關閉。")
end)

ProtectionStick.Parent = Backpack
