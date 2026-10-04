-- Delta 專用：獨立 Died / Kick 伺服器封包攔截開關
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Name = "AntiServerControl"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleButton.Size = UDim2.new(0, 150, 0, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "🛡️ 封包攔截: 關閉"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18

local hookActive = false
local oldNamecall

-- 核心 Hook 邏輯
local function startHook()
    if oldNamecall then return end
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if not hookActive then return oldNamecall(self, ...) end
        
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" or method == "InvokeServer" or method == "OnClientEvent" then
            local eventName = string.lower(self.Name)
            if string.find(eventName, "die") or string.find(eventName, "died") or string.find(eventName, "kill") or string.find(eventName, "kick") or string.find(eventName, "damage") then
                print("⚠️ [已攔截] 伺服器傳來危險事件: " .. self.Name)
                return nil -- 拋棄封包，完全不管伺服器
            end
            for _, arg in pairs(args) do
                if type(arg) == "string" then
                    local lowerArg = string.lower(arg)
                    if string.find(lowerArg, "die") or string.find(lowerArg, "died") or string.find(lowerArg, "kick") then
                        print("⚠️ [已攔截] 封包內含危險參數: " .. arg)
                        return nil
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

pcall(startHook)

ToggleButton.MouseButton1Click:Connect(function()
    hookActive = not hookActive
    if hookActive then
        ToggleButton.Text = "🛡️ 封包攔截: 開啟"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        print("🔒 攔截功能已啟動！伺服器現在無法對你執行 died 或 kick。")
    else
        ToggleButton.Text = "🛡️ 封包攔截: 關閉"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        print("🔓 攔截功能已關閉。")
    end
end)
