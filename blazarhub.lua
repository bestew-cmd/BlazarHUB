-- injector script — Blazar HUB: flight, aimbot, anti-aim, spinbot, esp, fling, misc, custom kick, exit
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local cam = Workspace.CurrentCamera

local running = true
local speed = 120
local flyEnabled = false
local aaEnabled = false
local aaMode = "back"
local espEnabled = false
local spinEnabled = false
local spinSpeed = 15

local flingEnabled = false
local speedWalkEnabled = false
local speedWalkValue = 35
local jumpPowerEnabled = false
local jumpPowerValue = 120
local noclipEnabled = false
local kickMessage = "Kick :D"

local aimEnabled = false
local aimFov = 120
local aimSmooth = 0.3

local bodyVel, bodyGyro, part
local aaGyro
local espCache = {}

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "blazarhub_menu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 640, 0, 440)
frame.Position = UDim2.new(0.5, -320, 0.5, -220)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(45, 45, 45); stroke.Thickness = 1

local sidebar = Instance.new("Frame", frame)
sidebar.Size = UDim2.new(0, 160, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15); sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)

local logo = Instance.new("TextLabel", sidebar)
logo.Size = UDim2.new(1, 0, 0, 60)
logo.BackgroundTransparency = 1
logo.Text = "Blazar HUB"
logo.TextColor3 = Color3.fromRGB(240, 240, 240)
logo.Font = Enum.Font.GothamBold; logo.TextSize = 20

local tabs = {"General", "Combat", "Visuals", "Misc", "Exit"}
local tabButtons = {}
for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, 60 + (i-1)*42)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); btn.BorderSizePixel = 0
    btn.Text = "   " .. name
    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.GothamMedium; btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    tabButtons[name] = btn
end

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -160, 0, 40)
title.Position = UDim2.new(0, 160, 0, 0)
title.BackgroundTransparency = 1
title.Text = "  Blazar HUB"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.GothamMedium; title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left

local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local function newPage()
    local p = Instance.new("Frame", frame)
    p.Size = UDim2.new(1, -180, 1, -60)
    p.Position = UDim2.new(0, 170, 0, 50)
    p.BackgroundTransparency = 1; p.Visible = false
    return p
end
local pages = { General = newPage(), Combat = newPage(), Visuals = newPage(), Misc = newPage() }

local function addToggle(parent, labelText, y, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.Position = UDim2.new(0, 0, 0, y)
    row.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(0.85, 0, 0.5, -10)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.BorderSizePixel = 0; btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 3, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(120, 120, 120); dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        dot.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        dot.BackgroundColor3 = state and Color3.fromRGB(90, 160, 255) or Color3.fromRGB(120, 120, 120)
        callback(state)
    end)
end

local function addSlider(parent, labelText, y, minV, maxV, defaultV, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 46)
    row.Position = UDim2.new(0, 0, 0, y)
    row.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. ": " .. defaultV
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local bar = Instance.new("Frame", row)
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45); bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((defaultV - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(90, 160, 255); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local drag = false
    local function update(mx)
        local rel = mx - bar.AbsolutePosition.X
        local pct = math.clamp(rel / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(minV + (maxV - minV) * pct)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        lbl.Text = labelText .. ": " .. v
        callback(v)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; update(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

addToggle(pages.General, "Flight (F5)", 0, function(s) setFly(s) end)
addSlider(pages.General, "Speed", 40, 10, 2000, speed, function(v) speed = v end)

addToggle(pages.Combat, "Aimbot", 0, function(s) aimEnabled = s end)
addSlider(pages.Combat, "Aimbot FOV", 40, 20, 400, aimFov, function(v) aimFov = v end)
addSlider(pages.Combat, "Smoothness", 90, 1, 100, math.floor(aimSmooth*100), function(v) aimSmooth = v/100 end)
addToggle(pages.Combat, "Anti-Aim", 150, function(s) setAA(s) end)
local aaModeBtn = Instance.new("TextButton", pages.Combat)
aaModeBtn.Size = UDim2.new(0, 120, 0, 26)
aaModeBtn.Position = UDim2.new(0, 0, 0, 190)
aaModeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); aaModeBtn.BorderSizePixel = 0
aaModeBtn.Text = "mode: back"
aaModeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
aaModeBtn.Font = Enum.Font.Gotham; aaModeBtn.TextSize = 12
Instance.new("UICorner", aaModeBtn).CornerRadius = UDim.new(0, 4)
local aaModes = {"back", "side", "jitter"}
local aaIdx = 1
aaModeBtn.MouseButton1Click:Connect(function()
    aaIdx = aaIdx % #aaModes + 1
    aaMode = aaModes[aaIdx]
    aaModeBtn.Text = "mode: " .. aaMode
end)
addToggle(pages.Combat, "Spinbot", 230, function(s) spinEnabled = s end)
addSlider(pages.Combat, "Spin speed", 270, 1, 60, spinSpeed, function(v) spinSpeed = v end)
addToggle(pages.Combat, "Fling", 320, function(s) flingEnabled = s end)

addToggle(pages.Visuals, "ESP", 0, function(s) espEnabled = s; if not s then clearESP() end end)

addToggle(pages.Misc, "NoClip", 0, function(s) noclipEnabled = s end)
addToggle(pages.Misc, "Speed Walk", 40, function(s) setSpeedWalk(s) end)
addSlider(pages.Misc, "Walk Speed", 80, 16, 200, speedWalkValue, function(v) speedWalkValue = v; if speedWalkEnabled then setSpeedWalk(true) end end)
addToggle(pages.Misc, "Jump Power", 140, function(s) setJumpPower(s) end)
addSlider(pages.Misc, "Jump Power Value", 180, 50, 500, jumpPowerValue, function(v) jumpPowerValue = v; if jumpPowerEnabled then setJumpPower(true) end end)

local kickInput = Instance.new("TextBox", pages.Misc)
kickInput.Size = UDim2.new(1, -10, 0, 30)
kickInput.Position = UDim2.new(0, 0, 0, 250)
kickInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
kickInput.BorderSizePixel = 1
kickInput.BorderColor3 = Color3.fromRGB(60, 60, 60)
kickInput.Text = kickMessage
kickInput.PlaceholderText = "введи текст ошибки"
kickInput.TextColor3 = Color3.fromRGB(230, 230, 230)
kickInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
kickInput.Font = Enum.Font.Gotham; kickInput.TextSize = 13
kickInput.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", kickInput).CornerRadius = UDim.new(0, 4)
local kickPad = Instance.new("UIPadding", kickInput)
kickPad.PaddingLeft = UDim.new(0, 8)
kickPad.PaddingRight = UDim.new(0, 8)
kickInput.FocusLost:Connect(function()
    if kickInput.Text ~= "" then
        kickMessage = kickInput.Text
    else
        kickInput.Text = "Kick :D"
        kickMessage = "Kick :D"
    end
end)

local kickBtn = Instance.new("TextButton", pages.Misc)
kickBtn.Size = UDim2.new(0, 160, 0, 32)
kickBtn.Position = UDim2.new(0, 0, 0, 290)
kickBtn.BackgroundColor3 = Color3.fromRGB(160, 45, 45); kickBtn.BorderSizePixel = 0
kickBtn.Text = "Kick Client"
kickBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
kickBtn.Font = Enum.Font.GothamMedium; kickBtn.TextSize = 13
Instance.new("UICorner", kickBtn).CornerRadius = UDim.new(0, 4)
kickBtn.MouseButton1Click:Connect(function() kickClient() end)

tabButtons["Exit"].MouseButton1Click:Connect(function() shutdown() end)

pages.General.Visible = true
tabButtons.General.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabButtons.General.TextColor3 = Color3.fromRGB(240, 240, 240)

for n, b in pairs(tabButtons) do
    if n ~= "Exit" then
        b.MouseButton1Click:Connect(function()
            for nn, bb in pairs(tabButtons) do
                if nn ~= "Exit" then
                    pages[nn].Visible = (nn == n)
                    bb.BackgroundColor3 = (nn == n) and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
                    bb.TextColor3 = (nn == n) and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(160, 160, 160)
                end
            end
        end)
    end
end

local function getRoot()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

function setFly(state)
    flyEnabled = state
    if state then
        local root = getRoot(); if not root then return end
        part = root
        bodyVel = Instance.new("BodyVelocity", root)
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVel.Velocity = Vector3.zero
        bodyGyro = Instance.new("BodyGyro", root)
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.Damping = 500; bodyGyro.P = 3500
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
    else
        if bodyVel then bodyVel:Destroy(); bodyVel = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        part = nil
    end
end

function setAA(state)
    aaEnabled = state
    if state then
        local root = getRoot(); if not root then return end
        if aaGyro then aaGyro:Destroy() end
        aaGyro = Instance.new("BodyGyro", root)
        aaGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
        aaGyro.Damping = 300; aaGyro.P = 8000
    else
        if aaGyro then aaGyro:Destroy(); aaGyro = nil end
    end
end

function setSpeedWalk(state)
    speedWalkEnabled = state
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then hum.WalkSpeed = speedWalkValue else hum.WalkSpeed = 16 end
end

function setJumpPower(state)
    jumpPowerEnabled = state
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then hum.UseJumpPower = true; hum.JumpPower = jumpPowerValue else hum.JumpPower = 50 end
end

RunService.Stepped:Connect(function()
    if not running then return end
    if noclipEnabled then
        local char = lp.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
    else
        local char = lp.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and not p.CanCollide and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end
            end
        end
    end
end)

local function createESP(plr)
    if plr == lp then return end
    local hl = Instance.new("Highlight")
    hl.Name = "blazarhub_esp"
    hl.FillColor = Color3.fromRGB(255, 60, 60)
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineTransparency = 0
    hl.Adornee = plr.Character
    hl.Parent = plr.Character
    espCache[plr] = hl
end

local function removeESP(plr)
    local hl = espCache[plr]; if hl then hl:Destroy() end
    espCache[plr] = nil
end

function clearESP()
    for plr in pairs(espCache) do removeESP(plr) end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if espEnabled then task.wait(0.2); createESP(plr) end
    end)
end)
Players.PlayerRemoving:Connect(removeESP)
task.spawn(function()
    while running do
        task.wait(1)
        if espEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character and not espCache[plr] then createESP(plr) end
            end
        end
    end
end)

local function getClosestTarget()
    local myHead = lp.Character and lp.Character:FindFirstChild("Head")
    if not myHead then return nil end
    local closest, closestAngle = nil, aimFov
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if head and hrp and hum and hum.Health > 0 then
                local sp, _ = cam:WorldToViewportPoint(head.Position)
                if sp.Z > 0 then
                    local screenCenter = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                    local dist = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                    if dist < closestAngle then
                        closestAngle = dist
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

function kickClient() lp:Kick(kickMessage) end

function shutdown()
    running = false
    setFly(false); setAA(false); clearESP()
    setSpeedWalk(false); setJumpPower(false)
    if gui then gui:Destroy() end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        setFly(not flyEnabled)
    elseif input.KeyCode == Enum.KeyCode.F8 then
        frame.Visible = not frame.Visible
    end
end)

local jitterT, jitterY = 0, 0
local spinAngle = 0
RunService.Heartbeat:Connect(function(dt)
    if not running then return end
    local root = getRoot()

    if flyEnabled and bodyVel and part and part.Parent and root then
        local x, y = 0, 0
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then y += 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then y -= 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then x += 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then x -= 1 end

        local cf = cam.CFrame
        local look = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
        local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
        if look.Magnitude > 0 then look = look.Unit end
        if right.Magnitude > 0 then right = right.Unit end

        local dir = look * y + right * x
        if dir.Magnitude > 1 then dir = dir.Unit end

        local v = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then v = -1 end

        bodyVel.Velocity = dir * speed + Vector3.new(0, v * speed, 0)
        bodyGyro.CFrame = CFrame.lookAt(part.Position, part.Position + look)
    end

    if aimEnabled then
        local target = getClosestTarget()
        if target then
            local currentCF = cam.CFrame
            local targetCF = CFrame.lookAt(currentCF.Position, target.Position)
            cam.CFrame = currentCF:Lerp(targetCF, math.clamp(aimSmooth, 0.02, 1))
        end
    end

    if aaEnabled and aaGyro and root then
        local camLook = cam.CFrame.LookVector
        local baseYaw = math.atan2(-camLook.X, -camLook.Z)
        local offset = 0
        if aaMode == "side" then offset = math.rad(90)
        elseif aaMode == "jitter" then
            jitterT += dt
            if jitterT >= 0.12 then jitterT = 0; jitterY = math.rad(math.random(-60, 60)) end
            offset = jitterY
        end
        aaGyro.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, baseYaw + math.pi + offset, 0)
    end

    if spinEnabled and root then
        spinAngle = (spinAngle + math.rad(spinSpeed * 60) * dt) % (math.pi * 2)
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, spinAngle, 0)
    end

    if flingEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                for _, p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Velocity = Vector3.new(math.random(-1e5, 1e5), math.random(-1e5, 1e5), math.random(-1e5, 1e5))
                    end
                end
            end
        end
    end
end)

lp.CharacterAdded:Connect(function()
    setFly(false)
    setSpeedWalk(false); setJumpPower(false)
    if aaEnabled then task.wait(0.3); setAA(true) end
    if espEnabled then task.wait(0.3); createESP(lp) end
end)
