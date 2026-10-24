--Koder @b3stew
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local cam = Workspace.CurrentCamera

local running = true
local speed = 120
local flyEnabled = false
local espEnabled = false
local espTeamCheck = true
local espShowNames = true
local espShowDist = false
local espShowSkeleton = false
local espShowBox = false
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
local aimHeld = false
local aimKey = Enum.KeyCode.Q
local aimKeyName = "Q"
local aimFov = 120
local aimSmooth = 0.3
local teamCheck = true
local wallCheck = true
local selectedPlayer = nil

local bodyVel, bodyGyro, part
local espCache = {}

local gui = Instance.new("ScreenGui")
gui.Name = "blazarhub_menu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

local watermark = Instance.new("TextLabel", gui)
watermark.Size = UDim2.new(0, 200, 0, 30)
watermark.Position = UDim2.new(0.5, -100, 0, 50)
watermark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
watermark.BackgroundTransparency = 0.5
watermark.Text = "Blazar HUB | ~ fps"
watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 14
watermark.TextStrokeTransparency = 0.5
local wmCorner = Instance.new("UICorner", watermark)
wmCorner.CornerRadius = UDim.new(0, 4)
local wmStroke = Instance.new("UIStroke", watermark)
wmStroke.Color = Color3.fromRGB(60, 60, 70)

task.spawn(function()
    local frames = 0
    local lastTime = tick()
    while running do
        frames = frames + 1
        local now = tick()
        if now - lastTime >= 1 then
            watermark.Text = "Blazar HUB | " .. frames .. " fps"
            frames = 0
            lastTime = now
        end
        RunService.RenderStepped:Wait()
    end
end)

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 720, 0, 480)
mainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(25, 35, 50)
stroke.Thickness = 1

local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 160, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
sidebar.BorderSizePixel = 0
local sideStroke = Instance.new("UIStroke", sidebar)
sideStroke.Color = Color3.fromRGB(25, 35, 50)
sideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local logo = Instance.new("TextLabel", sidebar)
logo.Size = UDim2.new(1, -20, 0, 60)
logo.Position = UDim2.new(0, 10, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "BLAZAR HUB"
logo.TextColor3 = Color3.fromRGB(230, 235, 245)
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 18
logo.TextXAlignment = Enum.TextXAlignment.Left

local tabs = {"General", "Combat", "Visuals", "Misc", "Exit"}
local tabButtons = {}
local currentTab = "General"
for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.Position = UDim2.new(0, 5, 0, 60 + (i-1)*38)
    btn.BackgroundColor3 = (name == currentTab) and Color3.fromRGB(20, 30, 50) or Color3.fromRGB(8, 10, 16)
    btn.BorderSizePixel = 0
    btn.Text = "   " .. name
    btn.TextColor3 = (name == currentTab) and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(140, 140, 150)
    btn.Font = Enum.Font.GothamMedium; btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    if name == currentTab then
        local accent = Instance.new("Frame", btn)
        accent.Size = UDim2.new(0, 3, 1, 0)
        accent.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
        accent.BorderSizePixel = 0
    end
    tabButtons[name] = btn
end

local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, -160, 0, 40)
topBar.Position = UDim2.new(0, 160, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
topBar.BorderSizePixel = 0
local topStroke = Instance.new("UIStroke", topBar)
topStroke.Color = Color3.fromRGB(25, 35, 50)
topStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local topTitle = Instance.new("TextLabel", topBar)
topTitle.Size = UDim2.new(0, 200, 1, 0)
topTitle.Position = UDim2.new(0, 10, 0, 0)
topTitle.BackgroundTransparency = 1
topTitle.Text = "Blazar HUB"
topTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
topTitle.Font = Enum.Font.GothamMedium; topTitle.TextSize = 14
topTitle.TextXAlignment = Enum.TextXAlignment.Left

local subTitle = Instance.new("TextLabel", topBar)
subTitle.Size = UDim2.new(0, 200, 1, 0)
subTitle.Position = UDim2.new(0, 120, 0, 0)
subTitle.BackgroundTransparency = 1
subTitle.Text = "| Drone War"
subTitle.TextColor3 = Color3.fromRGB(90, 130, 180)
subTitle.Font = Enum.Font.Gotham; subTitle.TextSize = 12
subTitle.TextXAlignment = Enum.TextXAlignment.Left

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size = UDim2.new(1, -160, 1, -40)
contentArea.Position = UDim2.new(0, 160, 0, 40)
contentArea.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
contentArea.BorderSizePixel = 0
local contentStroke = Instance.new("UIStroke", contentArea)
contentStroke.Color = Color3.fromRGB(25, 35, 50)
contentStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local pages = {}
local function newPage()
    local p = Instance.new("Frame", contentArea)
    p.Size = UDim2.new(1, -20, 1, -20)
    p.Position = UDim2.new(0, 10, 0, 10)
    p.BackgroundTransparency = 1
    p.Visible = false
    
    local scroll = Instance.new("ScrollingFrame", p)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 10)
    
    p:SetAttribute("Scroll", scroll)
    return p
end
for _, name in ipairs({"General", "Combat", "Visuals", "Misc"}) do
    pages[name] = newPage()
end

local function createBox(parent, titleText)
    local scroll = parent:GetAttribute("Scroll")
    local box = Instance.new("Frame", scroll)
    box.Size = UDim2.new(1, -5, 0, 0)
    box.BackgroundTransparency = 1
    box.AutomaticSize = Enum.AutomaticSize.Y
    
    local title = Instance.new("TextLabel", box)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    title.Text = "  " .. titleText
    title.TextColor3 = Color3.fromRGB(200, 200, 210)
    title.Font = Enum.Font.GothamMedium; title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local line = Instance.new("Frame", box)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 24)
    line.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
    line.BorderSizePixel = 0
    
    local inner = Instance.new("Frame", box)
    inner.Size = UDim2.new(1, -20, 0, 0)
    inner.Position = UDim2.new(0, 10, 0, 30)
    inner.BackgroundTransparency = 1
    inner.AutomaticSize = Enum.AutomaticSize.Y
    
    local uiList = Instance.new("UIListLayout", inner)
    uiList.Padding = UDim.new(0, 8)
    return inner
end

local function addToggle(parent, labelText, callback, defaultValue)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 20)
    row.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 32, 0, 16)
    btn.Position = UDim2.new(1, -32, 0.5, -8)
    btn.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
    btn.BorderSizePixel = 0
    btn.Text = ""
    
    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 2, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    dot.BorderSizePixel = 0
    
    local state = defaultValue or false
    if state then
        dot.Position = UDim2.new(1, -14, 0.5, -6)
        dot.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
        btn.BackgroundColor3 = Color3.fromRGB(30, 50, 70)
    end
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        dot.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        dot.BackgroundColor3 = state and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(80, 80, 90)
        btn.BackgroundColor3 = state and Color3.fromRGB(30, 50, 70) or Color3.fromRGB(25, 35, 50)
        if callback then callback(state) end
    end)
end

local function addSlider(parent, labelText, minV, maxV, defaultV, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size = UDim2.new(0.3, 0, 0, 16)
    valLbl.Position = UDim2.new(0.7, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultV)
    valLbl.TextColor3 = Color3.fromRGB(140, 140, 150)
    valLbl.Font = Enum.Font.Gotham; valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    local bar = Instance.new("Frame", row)
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0, 24)
    bar.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
    bar.BorderSizePixel = 0
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((defaultV - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    fill.BorderSizePixel = 0
    
    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.new(0, 8, 0, 8)
    knob.Position = UDim2.new((defaultV - minV) / (maxV - minV), -4, 0.5, -4)
    knob.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    knob.BorderSizePixel = 0
    
    local drag = false
    local function update(mx)
        local rel = mx - bar.AbsolutePosition.X
        local pct = math.clamp(rel / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(minV + (maxV - minV) * pct)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -4, 0.5, -4)
        valLbl.Text = tostring(v)
        if callback then callback(v) end
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

local gBox1 = createBox(pages.General, "Flight")
addToggle(gBox1, "Enable Flight (F5)", function(s) setFly(s) end)
addSlider(gBox1, "Speed", 10, 2000, speed, function(v) speed = v end)

local cBox1 = createBox(pages.Combat, "Aimbot")
addToggle(cBox1, "Enable Aimbot", function(s) aimEnabled = s end)
addSlider(cBox1, "FOV", 20, 400, aimFov, function(v) aimFov = v end)
addSlider(cBox1, "Smoothness", 1, 100, math.floor(aimSmooth*100), function(v) aimSmooth = v/100 end)
addToggle(cBox1, "Team Check", function(s) teamCheck = s end, true)
addToggle(cBox1, "Wall Check", function(s) wallCheck = s end, true)

local bindRow = Instance.new("Frame", cBox1)
bindRow.Size = UDim2.new(1, 0, 0, 20)
bindRow.BackgroundTransparency = 1
local bindLbl = Instance.new("TextLabel", bindRow)
bindLbl.Size = UDim2.new(0.5, 0, 1, 0)
bindLbl.BackgroundTransparency = 1
bindLbl.Text = "Aim Key: " .. aimKeyName
bindLbl.TextColor3 = Color3.fromRGB(180, 180, 190)
bindLbl.Font = Enum.Font.Gotham; bindLbl.TextSize = 12
bindLbl.TextXAlignment = Enum.TextXAlignment.Left
local bindBtn = Instance.new("TextButton", bindRow)
bindBtn.Size = UDim2.new(0, 80, 0, 18)
bindBtn.Position = UDim2.new(1, -80, 0.5, -9)
bindBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
bindBtn.BorderSizePixel = 0
bindBtn.Text = "Set Bind"
bindBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
bindBtn.Font = Enum.Font.Gotham; bindBtn.TextSize = 11
local binding = false
bindBtn.MouseButton1Click:Connect(function()
    binding = true
    bindBtn.Text = "..."
end)

local cBox2 = createBox(pages.Combat, "Spinbot & Fling")
addToggle(cBox2, "Enable Spinbot", function(s) spinEnabled = s end)
addSlider(cBox2, "Spin Speed", 1, 60, spinSpeed, function(v) spinSpeed = v end)
addToggle(cBox2, "Fling (all)", function(s) flingEnabled = s end)

local vBox1 = createBox(pages.Visuals, "ESP Settings")
addToggle(vBox1, "Enable ESP", function(s) espEnabled = s; if not s then clearESP() end end)
addToggle(vBox1, "Team Check", function(s) espTeamCheck = s; if espEnabled then clearESP(); refreshESP() end end, true)
addToggle(vBox1, "Show Names", function(s) espShowNames = s; if espEnabled then clearESP(); refreshESP() end end, true)
addToggle(vBox1, "Show Distance", function(s) espShowDist = s; if espEnabled then clearESP(); refreshESP() end end, false)
addToggle(vBox1, "Show Skeleton", function(s) espShowSkeleton = s; if espEnabled then clearESP(); refreshESP() end end, false)
addToggle(vBox1, "Show Box", function(s) espShowBox = s; if espEnabled then clearESP(); refreshESP() end end, false)

local mBox1 = createBox(pages.Misc, "Movement")
addToggle(mBox1, "NoClip", function(s) noclipEnabled = s end)
addToggle(mBox1, "Speed Walk", function(s) setSpeedWalk(s) end)
addSlider(mBox1, "Walk Speed", 16, 200, speedWalkValue, function(v) speedWalkValue = v; if speedWalkEnabled then setSpeedWalk(true) end end)
addToggle(mBox1, "Jump Power", function(s) setJumpPower(s) end)
addSlider(mBox1, "Jump Power Value", 50, 500, jumpPowerValue, function(v) jumpPowerValue = v; if jumpPowerEnabled then setJumpPower(true) end end)

local mBox2 = createBox(pages.Misc, "Player Target")
local selLbl = Instance.new("TextLabel", mBox2)
selLbl.Size = UDim2.new(1, 0, 0, 20)
selLbl.BackgroundTransparency = 1
selLbl.Text = "Target: none"
selLbl.TextColor3 = Color3.fromRGB(180, 180, 190)
selLbl.Font = Enum.Font.Gotham; selLbl.TextSize = 12
selLbl.TextXAlignment = Enum.TextXAlignment.Left

local btnRow = Instance.new("Frame", mBox2)
btnRow.Size = UDim2.new(1, 0, 0, 20)
btnRow.BackgroundTransparency = 1

local function createSmallBtn(parent, text, xPos, w, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, w, 1, 0)
    b.Position = UDim2.new(0, xPos, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(180, 180, 190)
    b.Font = Enum.Font.Gotham; b.TextSize = 11
    b.MouseButton1Click:Connect(callback)
    return b
end

local listFrame = Instance.new("Frame", contentArea)
listFrame.Size = UDim2.new(0, 200, 0, 220)
listFrame.Position = UDim2.new(1, -220, 0, 10)
listFrame.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
listFrame.BorderSizePixel = 0
listFrame.Visible = false
local listStroke = Instance.new("UIStroke", listFrame)
listStroke.Color = Color3.fromRGB(25, 35, 50)

local listScroll = Instance.new("ScrollingFrame", listFrame)
listScroll.Size = UDim2.new(1, -10, 1, -10)
listScroll.Position = UDim2.new(0, 5, 0, 5)
listScroll.BackgroundTransparency = 1
listScroll.BorderSizePixel = 0
listScroll.ScrollBarThickness = 2
local listLayout = Instance.new("UIListLayout", listScroll)
listLayout.Padding = UDim.new(0, 2)

local function refreshList()
    for _, c in ipairs(listScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local b = Instance.new("TextButton", listScroll)
            b.Size = UDim2.new(1, 0, 0, 24)
            b.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
            b.BorderSizePixel = 0
            b.Text = "  " .. plr.Name
            b.TextColor3 = Color3.fromRGB(200, 200, 210)
            b.Font = Enum.Font.Gotham; b.TextSize = 12
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                selLbl.Text = "Target: " .. plr.Name
                listFrame.Visible = false
            end)
        end
    end
    listScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

createSmallBtn(btnRow, "Select", 0, 60, function()
    listFrame.Visible = not listFrame.Visible
    if listFrame.Visible then refreshList() end
end)
createSmallBtn(btnRow, "TP", 70, 40, function()
    if selectedPlayer and selectedPlayer.Character and lp.Character then
        local t = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local m = lp.Character:FindFirstChild("HumanoidRootPart")
        if t and m then m.CFrame = t.CFrame * CFrame.new(0, 3, 0) end
    end
end)
createSmallBtn(btnRow, "Fling", 120, 50, function()
    if selectedPlayer and selectedPlayer.Character then
        for _, p in ipairs(selectedPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.Velocity = Vector3.new(math.random(-1e5, 1e5), math.random(-1e5, 1e5), math.random(-1e5, 1e5)) end
        end
    end
end)

local mBox3 = createBox(pages.Misc, "Kick Client")
local kickInput = Instance.new("TextBox", mBox3)
kickInput.Size = UDim2.new(1, 0, 0, 24)
kickInput.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
kickInput.BorderSizePixel = 0
kickInput.Text = kickMessage
kickInput.TextColor3 = Color3.fromRGB(200, 200, 210)
kickInput.Font = Enum.Font.Gotham; kickInput.TextSize = 12
kickInput.TextXAlignment = Enum.TextXAlignment.Left
local pad = Instance.new("UIPadding", kickInput)
pad.PaddingLeft = UDim.new(0, 6)
kickInput.FocusLost:Connect(function()
    kickMessage = (kickInput.Text ~= "") and kickInput.Text or "Kick :D"
    kickInput.Text = kickMessage
end)
createSmallBtn(mBox3, "Kick", 0, 60, function() lp:Kick(kickMessage) end).Size = UDim2.new(0, 60, 0, 24)

tabButtons.Exit.MouseButton1Click:Connect(function() shutdown() end)
for n, b in pairs(tabButtons) do
    if n ~= "Exit" then
        b.MouseButton1Click:Connect(function()
            for nn, bb in pairs(tabButtons) do
                if nn ~= "Exit" then
                    pages[nn].Visible = (nn == n)
                    bb.BackgroundColor3 = (nn == n) and Color3.fromRGB(20, 30, 50) or Color3.fromRGB(8, 10, 16)
                    bb.TextColor3 = (nn == n) and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(140, 140, 150)
                    for _, c in ipairs(bb:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                    if nn == n then
                        local accent = Instance.new("Frame", bb)
                        accent.Size = UDim2.new(0, 3, 1, 0)
                        accent.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
                        accent.BorderSizePixel = 0
                    end
                end
            end
        end)
    end
end
pages.General.Visible = true

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

local function isSameTeamEsp(plr)
    if not espTeamCheck then return false end
    return lp.Team ~= nil and plr.Team == lp.Team
end

local function createESP(plr)
    if plr == lp then return end
    if isSameTeamEsp(plr) then return end
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
    local hl = espCache[plr]
    if hl then hl:Destroy() end
    espCache[plr] = nil
    local char = plr.Character
    if char then
        for _, c in ipairs(char:GetChildren()) do
            if c:IsA("BillboardGui") and c.Name == "esp_tag" then c:Destroy() end
        end
    end
end

function clearESP()
    for plr in pairs(espCache) do removeESP(plr) end
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            for _, c in ipairs(char:GetChildren()) do
                if c:IsA("BillboardGui") and (c.Name == "esp_tag" or c.Name == "esp_box") then c:Destroy() end
            end
        end
    end
end

local function refreshESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character and not espCache[plr] then
            if not isSameTeamEsp(plr) then
                createESP(plr)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if espEnabled then task.wait(0.2); refreshESP() end
    end)
end)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character and not isSameTeamEsp(plr) then
            local head = plr.Character:FindFirstChild("Head")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if head and hrp then
                local tag = head:FindFirstChild("esp_tag")
                if not tag and (espShowNames or espShowDist) then
                    tag = Instance.new("BillboardGui", head)
                    tag.Name = "esp_tag"
                    tag.Size = UDim2.new(0, 200, 0, 50)
                    tag.StudsOffset = Vector3.new(0, 2.5, 0)
                    tag.AlwaysOnTop = true
                    
                    local txt = Instance.new("TextLabel", tag)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.TextStrokeTransparency = 0
                    txt.Font = Enum.Font.GothamMedium
                    txt.TextSize = 12
                    txt.Name = "text"
                end
                if tag then
                    local txt = tag:FindFirstChild("text")
                    if txt then
                        local parts = {}
                        if espShowNames then table.insert(parts, plr.Name) end
                        if espShowDist and lp.Character and lp.Character:FindFirstChild("Head") then
                            local d = math.floor((head.Position - lp.Character.Head.Position).Magnitude)
                            table.insert(parts, "[" .. d .. "m]")
                        end
                        txt.Text = table.concat(parts, " ")
                    end
                end

                local box = hrp:FindFirstChild("esp_box")
                if espShowBox then
                    if not box then
                        box = Instance.new("BoxHandleAdornment", hrp)
                        box.Name = "esp_box"
                        box.Adornee = hrp
                        box.AlwaysOnTop = true
                        box.Color3 = Color3.fromRGB(255, 0, 0)
                        box.Transparency = 0.5
                        box.Size = Vector3.new(4, 6, 4)
                        box.ZIndex = 2
                    end
                elseif box then
                    box:Destroy()
                end
            end
        end
    end
end)

local function isSameTeam(plr)
    if not teamCheck then return false end
    local myTeam = lp.Team
    return myTeam ~= nil and plr.Team == myTeam
end

local function isVisible(head)
    if not wallCheck then return true end
    local myHead = lp.Character and lp.Character:FindFirstChild("Head")
    if not myHead then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {lp.Character, head.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(myHead.Position, head.Position - myHead.Position, params)
    return result == nil
end

local function getClosestTarget()
    local myHead = lp.Character and lp.Character:FindFirstChild("Head")
    if not myHead then return nil end
    local closest, closestAngle = nil, aimFov
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character and not isSameTeam(plr) then
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 and isVisible(head) then
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

function shutdown()
    running = false
    setFly(false); clearESP()
    setSpeedWalk(false); setJumpPower(false)
    if gui then gui:Destroy() end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if binding and input.KeyCode ~= Enum.KeyCode.Unknown then
        aimKey = input.KeyCode
        aimKeyName = input.KeyCode.Name
        bindLbl.Text = "Aim Key: " .. aimKeyName
        bindBtn.Text = "Set Bind"
        binding = false
        return
    end
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        setFly(not flyEnabled)
    elseif input.KeyCode == Enum.KeyCode.F8 then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == aimKey then aimHeld = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == aimKey then aimHeld = false end
end)

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

    if aimEnabled and aimHeld then
        local target = getClosestTarget()
        if target then
            local currentCF = cam.CFrame
            local targetCF = CFrame.lookAt(currentCF.Position, target.Position)
            cam.CFrame = currentCF:Lerp(targetCF, math.clamp(aimSmooth, 0.02, 1))
        end
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
    if espEnabled then task.wait(0.3); createESP(lp) end
end)
