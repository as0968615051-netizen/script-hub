-- Delta 專用：終極三角形聖光陣十字架 (不含防死，純粹物理湮滅)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

local UltimateCrucifix = Instance.new("Tool")
UltimateCrucifix.Name = "✝️ 終極幾何聖光十字架"
UltimateCrucifix.RequiresHandle = true

local Handle = Instance.new("Part")
Handle.Name = "Handle"
Handle.Size = Vector3.new(1.5, 3, 0.5)
Handle.BrickColor = BrickColor.new("Neon orange")
Handle.Material = Enum.Material.Neon
Handle.Parent = UltimateCrucifix

local pointLight = Instance.new("PointLight")
pointLight.Range = 40
pointLight.Brightness = 12
pointLight.Color = Color3.fromRGB(255, 140, 0)
pointLight.Parent = Handle

-- 手持加速
local originalSpeed = 16
UltimateCrucifix.Equipped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then originalSpeed = hum.WalkSpeed hum.WalkSpeed = 35 end
end)
UltimateCrucifix.Unequipped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = originalSpeed end
end)

-- 幾何法陣邏輯
local lastClick = 0
local activeTriangle = nil

UltimateCrucifix.Activated:Connect(function()
    local now = tick()
    if now - lastClick < 0.3 then
        if activeTriangle then
            -- 第二次雙擊：全部消失
            for _, part in pairs(activeTriangle) do if part and part.Parent then part:Destroy() end end
            activeTriangle = nil
            print("🧹 聖光箭陣已手動收回。")
        else
            -- 第一次雙擊：畫出三角形與箭
            activeTriangle = {}
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local center = root.Position - Vector3.new(0, 2.5, 0)
                local size = 18
                local p1 = center + (root.CFrame.LookVector * size)
                local p2 = center + (root.CFrame.RightVector * size) - (root.CFrame.LookVector * (size/2))
                local p3 = center - (root.CFrame.RightVector * size) - (root.CFrame.LookVector * (size/2))
                local vertices = {p1, p2, p3}
                
                for i = 1, 3 do
                    local startPos = vertices[i]
                    local endPos = vertices[i % 3 + 1]
                    local wall = Instance.new("Part")
                    wall.Anchored = true wall.CanCollide = false
                    wall.Size = Vector3.new(0.6, 8, (endPos - startPos).Magnitude)
                    wall.CFrame = CFrame.lookAt((startPos + endPos)/2, endPos)
                    wall.BrickColor = BrickColor.new("Deep orange") wall.Material = Enum.Material.Neon
                    wall.Transparency = 0.3 wall.Parent = workspace
                    table.insert(activeTriangle, wall)
                    
                    -- 高頻抹除
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not wall or not wall.Parent then conn:Disconnect() return end
                        local region = Region3.new(wall.Position - wall.Size/2, wall.Position + wall.Size/2)
                        for _, p in pairs(workspace:FindPartsInRegion3(region, nil, 100)) do
                            if p.Parent and p.Name ~= "Baseplate" and not p:IsDescendantOf(char) then
                                local target = p.Parent:IsA("Model") and p.Parent or p
                                target:Destroy()
                            end
                        end
                    end)
                    
                    -- 生成向外突出的箭頭
                    local arrow = Instance.new("Part")
                    arrow.Anchored = true arrow.CanCollide = false
                    arrow.Size = Vector3.new(2.5, 0.4, 5)
                    arrow.CFrame = CFrame.lookAt((startPos + endPos)/2, (startPos + endPos)/2 + wall.CFrame.RightVector * 6)
                    arrow.BrickColor = BrickColor.new("Gold") arrow.Material = Enum.Material.Neon
                    arrow.Parent = workspace
                    table.insert(activeTriangle, arrow)
                end
            end
        end
        lastClick = 0
    else lastClick = now end
end)

UltimateCrucifix.Parent = Backpack
