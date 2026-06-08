local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer


-- If true, scripts tagged as KEY SYSTEM will still run (tag is treated as a label only).
local ALLOW_KEY_TAG_SCRIPTS = true

---------------------------------------------------------------------
-- HTTP / DATA UTILITIES
---------------------------------------------------------------------

local function safeHttpGet(url)
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not ok then
        warn("[ROBScript Hub] HttpGet failed:", res)
        return nil
    end
    return res
end

local function slugFromUrl(url)
    local path = url:match("https?://[^/]+/(.+)") or ""
    path = path:gsub("[/?#].*$", "")
    path = path:gsub("/+$", "")
    if path == "" then
        return "index"
    end
    return path
end

local function normalizeGameTitle(page)
    if page.title and type(page.title) == "string" and page.title ~= "" then
        return page.title
    end
    if page.slug and type(page.slug) == "string" and page.slug ~= "" then
        local s = page.slug
        s = s:gsub("%-scripts$", "")
        s = s:gsub("%-", " ")
        return s
    end
    if page.page_url and type(page.page_url) == "string" then
        local s = slugFromUrl(page.page_url)
        s = s:gsub("%-scripts$", "")
        s = s:gsub("%-", " ")
        return s
    end
    return "Unknown Game"
end

local function filterPages(pages, query)
    query = string.lower(query or "")
    if query == "" then
        return pages
    end
    local result = {}
    for _, page in ipairs(pages) do
        local title = normalizeGameTitle(page)
        if string.find(string.lower(title), query, 1, true) then
            table.insert(result, page)
        end
    end
    return result
end

local function filterScripts(page, query)
    if not page or type(page.scripts) ~= "table" then
        return {}
    end
    query = string.lower(query or "")
    if query == "" then
        return page.scripts
    end
    local result = {}
    for _, scr in ipairs(page.scripts) do
        local t = string.lower(scr.title or "")
        if string.find(t, query, 1, true) then
            table.insert(result, scr)
        end
    end
    return result
end

---------------------------------------------------------------------
-- SCRIPT EXECUTION
---------------------------------------------------------------------

local function runScript(scr)
    if not scr or type(scr.code) ~= "string" then
        warn("[ROBScript Hub] Invalid script data")
        return
    end
    if scr.has_key and not ALLOW_KEY_TAG_SCRIPTS then
        warn("[ROBScript Hub] Script requires key-system:", scr.title or "Unknown")
        return
    elseif scr.has_key then
        warn("[ROBScript Hub] Script tagged as KEY SYSTEM (loader is configured to allow it):", scr.title or "Unknown")
    end
    local fn, err = loadstring(scr.code)
    if not fn then
        warn("[ROBScript Hub] loadstring error for", scr.title or "Unknown", ":", err)
        return
    end

    local ok, runtimeErr = pcall(fn)
    if not ok then
        warn("[ROBScript Hub] runtime error for", scr.title or "Unknown", ":", runtimeErr)
    end
end

local function clearChildren(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end


---------------------------------------------------------------------
-- VISUAL THEME / UI HELPERS
---------------------------------------------------------------------

local THEME = {
    bg = Color3.fromRGB(10, 12, 20),
    bg2 = Color3.fromRGB(18, 21, 34),
    panel = Color3.fromRGB(20, 24, 38),
    panel2 = Color3.fromRGB(15, 18, 29),
    input = Color3.fromRGB(28, 33, 50),
    button = Color3.fromRGB(35, 41, 62),
    buttonHover = Color3.fromRGB(47, 56, 82),
    buttonPressed = Color3.fromRGB(35, 126, 190),
    buttonSelected = Color3.fromRGB(41, 120, 190),
    accent = Color3.fromRGB(80, 170, 255),
    accent2 = Color3.fromRGB(145, 95, 255),
    danger = Color3.fromRGB(205, 75, 85),
    dangerHover = Color3.fromRGB(225, 95, 105),
    text = Color3.fromRGB(245, 248, 255),
    textMuted = Color3.fromRGB(155, 165, 188),
    stroke = Color3.fromRGB(135, 155, 200),

    mainTransparency = 0.16,
    panelTransparency = 0.28,
    listTransparency = 0.34,
    inputTransparency = 0.22,
    buttonTransparency = 0.18,
    selectedTransparency = 0.08,

    radiusLarge = 16,
    radius = 12,
    radiusSmall = 9,
}

local TWEEN_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenGui(object, props, info)
    local tween = TweenService:Create(object, info or TWEEN_FAST, props)
    tween:Play()
    return tween
end

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or THEME.radius)
    corner.Parent = parent
    return corner
end

local function makeStroke(parent, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or THEME.stroke
    stroke.Transparency = transparency or 0.74
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function makeGradient(parent, colorA, colorB, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB),
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function makePadding(parent, left, right, top, bottom)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.Parent = parent
    return padding
end

local function styleInput(box)
    box.BackgroundColor3 = THEME.input
    box.BackgroundTransparency = THEME.inputTransparency
    box.BorderSizePixel = 0
    box.TextColor3 = THEME.text
    box.PlaceholderColor3 = THEME.textMuted
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false
    makeCorner(box, THEME.radiusSmall)
    local stroke = makeStroke(box, THEME.stroke, 0.84, 1)
    makePadding(box, 10, 10, 0, 0)

    box.Focused:Connect(function()
        tweenGui(box, {BackgroundTransparency = 0.12})
        tweenGui(stroke, {Transparency = 0.32})
    end)

    box.FocusLost:Connect(function()
        tweenGui(box, {BackgroundTransparency = THEME.inputTransparency})
        tweenGui(stroke, {Transparency = 0.84})
    end)
end

local function styleList(list)
    list.BackgroundColor3 = THEME.panel2
    list.BackgroundTransparency = THEME.listTransparency
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ScrollBarThickness = 4
    list.ScrollBarImageColor3 = THEME.accent
    list.ScrollBarImageTransparency = 0.4
    list.ScrollingDirection = Enum.ScrollingDirection.Y
    list.ClipsDescendants = true
    makeCorner(list, THEME.radiusSmall)
    makeStroke(list, THEME.stroke, 0.9, 1)
end

local function styleSoftButton(button, options)
    options = options or {}
    local base = options.base or THEME.button
    local hover = options.hover or THEME.buttonHover
    local pressed = options.pressed or THEME.buttonPressed
    local selected = options.selected or THEME.buttonSelected
    local baseTransparency = options.baseTransparency or THEME.buttonTransparency
    local hoverTransparency = options.hoverTransparency or 0.1
    local pressedTransparency = options.pressedTransparency or 0.02
    local selectedTransparency = options.selectedTransparency or THEME.selectedTransparency

    button.AutoButtonColor = false
    button.BackgroundColor3 = base
    button.BackgroundTransparency = baseTransparency
    button.BorderSizePixel = 0
    button.TextColor3 = THEME.text
    button.Font = options.font or Enum.Font.GothamMedium
    button.TextSize = options.textSize or 14
    button.TextXAlignment = options.textXAlignment or Enum.TextXAlignment.Left
    button.TextTruncate = Enum.TextTruncate.AtEnd

    makeCorner(button, options.radius or THEME.radiusSmall)
    local stroke = makeStroke(button, options.stroke or THEME.stroke, options.strokeTransparency or 0.86, 1)
    makePadding(button, options.paddingLeft or 10, options.paddingRight or 10, 0, 0)

    if button:GetAttribute("Selected") == nil then
        button:SetAttribute("Selected", false)
    end

    local function settle()
        if button:GetAttribute("Selected") then
            tweenGui(button, {BackgroundColor3 = selected, BackgroundTransparency = selectedTransparency})
            tweenGui(stroke, {Color = THEME.accent, Transparency = 0.34})
        else
            tweenGui(button, {BackgroundColor3 = base, BackgroundTransparency = baseTransparency})
            tweenGui(stroke, {Color = options.stroke or THEME.stroke, Transparency = options.strokeTransparency or 0.86})
        end
    end

    button.MouseEnter:Connect(function()
        if button:GetAttribute("Selected") then
            tweenGui(button, {BackgroundColor3 = selected, BackgroundTransparency = selectedTransparency})
        else
            tweenGui(button, {BackgroundColor3 = hover, BackgroundTransparency = hoverTransparency})
        end
        tweenGui(stroke, {Transparency = 0.42})
    end)

    button.MouseLeave:Connect(function()
        settle()
    end)

    button.MouseButton1Down:Connect(function()
        tweenGui(button, {BackgroundColor3 = pressed, BackgroundTransparency = pressedTransparency})
    end)

    button.MouseButton1Up:Connect(function()
        settle()
    end)

    button:GetAttributeChangedSignal("Selected"):Connect(settle)
    settle()
end

local function createEmptyState(parent, text)
    local label = Instance.new("TextLabel")
    label.Name = "EmptyState"
    label.Size = UDim2.new(1, -8, 0, 34)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = THEME.textMuted
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = parent
    return label
end

---------------------------------------------------------------------
-- LOAD HUB DATA (embedded, no HTTP)
---------------------------------------------------------------------

local allpagesтут

if #allPages == 0 then
    warn("[ROBScript Hub] No pages embedded; UI will still show but be empty.")
end

local guiParent = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui") or localPlayer:WaitForChild("PlayerGui")

local oldGui = guiParent:FindFirstChild("ROBScriptHub")
if oldGui then
    oldGui:Destroy()
end

local oldBlur = Lighting:FindFirstChild("ROBScriptHubBlur")
if oldBlur then
    oldBlur:Destroy()
end

local hubBlur = Instance.new("BlurEffect")
hubBlur.Name = "ROBScriptHubBlur"
hubBlur.Size = 8
hubBlur.Parent = Lighting

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ROBScriptHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

-- Compact glass toggle
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleHubButton"
toggleButton.Size = UDim2.new(0, 132, 0, 34)
toggleButton.Position = UDim2.new(0, 14, 0, 12)
toggleButton.BackgroundColor3 = THEME.bg2
toggleButton.BackgroundTransparency = 0.16
toggleButton.Text = "Hide Hub"
toggleButton.TextColor3 = THEME.text
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 13
toggleButton.Parent = screenGui
makeCorner(toggleButton, 999)
makeStroke(toggleButton, THEME.accent, 0.5, 1)
makeGradient(toggleButton, Color3.fromRGB(29, 36, 58), Color3.fromRGB(20, 24, 38), 0)
styleSoftButton(toggleButton, {
    base = THEME.bg2,
    hover = Color3.fromRGB(32, 43, 67),
    pressed = THEME.buttonPressed,
    radius = 999,
    textXAlignment = Enum.TextXAlignment.Center,
    paddingLeft = 0,
    paddingRight = 0,
    stroke = THEME.accent,
    strokeTransparency = 0.52,
})

-- Main glass window
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 720, 0, 430)
mainFrame.Position = UDim2.new(0.5, -360, 0.5, -215)
mainFrame.BackgroundColor3 = THEME.bg
mainFrame.BackgroundTransparency = THEME.mainTransparency
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
makeCorner(mainFrame, THEME.radiusLarge)
makeStroke(mainFrame, THEME.stroke, 0.62, 1)
makeGradient(mainFrame, Color3.fromRGB(18, 22, 36), Color3.fromRGB(8, 10, 17), 90)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = mainFrame

local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 46)
titleBar.BackgroundColor3 = THEME.bg2
titleBar.BackgroundTransparency = 0.08
titleBar.BorderSizePixel = 0
titleBar.Text = "ROBScript Hub"
titleBar.TextColor3 = THEME.text
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 18
titleBar.Active = true
titleBar.Parent = mainFrame
makePadding(titleBar, 18, 54, 0, 0)
makeGradient(titleBar, Color3.fromRGB(30, 38, 61), Color3.fromRGB(18, 22, 36), 0)

local titleAccent = Instance.new("Frame")
titleAccent.Name = "TitleAccent"
titleAccent.Size = UDim2.new(1, 0, 0, 1)
titleAccent.Position = UDim2.new(0, 0, 1, -1)
titleAccent.BackgroundColor3 = THEME.accent
titleAccent.BackgroundTransparency = 0.2
titleAccent.BorderSizePixel = 0
titleAccent.Parent = titleBar
makeGradient(titleAccent, THEME.accent, THEME.accent2, 0)

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -10, 0.5, 0)
closeButton.BackgroundColor3 = THEME.danger
closeButton.BackgroundTransparency = 0.2
closeButton.Text = "×"
closeButton.TextColor3 = THEME.text
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = titleBar
styleSoftButton(closeButton, {
    base = THEME.danger,
    hover = THEME.dangerHover,
    pressed = Color3.fromRGB(180, 55, 65),
    radius = 10,
    textXAlignment = Enum.TextXAlignment.Center,
    paddingLeft = 0,
    paddingRight = 0,
    stroke = Color3.fromRGB(255, 170, 175),
    strokeTransparency = 0.68,
})

---------------------------------------------------------------------
-- DRAGGING MAIN WINDOW (по titleBar)
---------------------------------------------------------------------

do
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

---------------------------------------------------------------------
-- LAYOUT
---------------------------------------------------------------------

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Position = UDim2.new(0, 0, 0, 46)
contentFrame.Size = UDim2.new(1, 0, 1, -46)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local function createPanel(name, size, position, parent)
    local panel = Instance.new("Frame")
    panel.Name = name
    panel.Size = size
    panel.Position = position
    panel.BackgroundColor3 = THEME.panel
    panel.BackgroundTransparency = THEME.panelTransparency
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = parent
    makeCorner(panel, THEME.radius)
    makeStroke(panel, THEME.stroke, 0.84, 1)
    makeGradient(panel, Color3.fromRGB(24, 29, 45), Color3.fromRGB(15, 18, 29), 90)
    return panel
end

local function createSectionTitle(parent, text)
    local label = Instance.new("TextLabel")
    label.Name = "SectionTitle"
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = THEME.textMuted
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

-- Left: games
local leftFrame = createPanel("GamesFrame", UDim2.new(0.38, -12, 1, -20), UDim2.new(0, 10, 0, 10), contentFrame)
createSectionTitle(leftFrame, "GAMES")

local gameSearchBox = Instance.new("TextBox")
gameSearchBox.Name = "GameSearchBox"
gameSearchBox.Size = UDim2.new(1, -20, 0, 34)
gameSearchBox.Position = UDim2.new(0, 10, 0, 34)
gameSearchBox.PlaceholderText = "Search games..."
gameSearchBox.Text = ""
gameSearchBox.Parent = leftFrame
styleInput(gameSearchBox)

local gameList = Instance.new("ScrollingFrame")
gameList.Name = "GameList"
gameList.Size = UDim2.new(1, -20, 1, -80)
gameList.Position = UDim2.new(0, 10, 0, 72)
gameList.Parent = leftFrame
styleList(gameList)

local gameListLayout = Instance.new("UIListLayout")
gameListLayout.Padding = UDim.new(0, 6)
gameListLayout.FillDirection = Enum.FillDirection.Vertical
gameListLayout.SortOrder = Enum.SortOrder.LayoutOrder
gameListLayout.Parent = gameList

local gameListPadding = Instance.new("UIPadding")
gameListPadding.PaddingTop = UDim.new(0, 6)
gameListPadding.PaddingBottom = UDim.new(0, 6)
gameListPadding.Parent = gameList

gameListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    gameList.CanvasSize = UDim2.new(0, 0, 0, gameListLayout.AbsoluteContentSize.Y + 14)
end)

-- Right: scripts
local rightFrame = createPanel("ScriptsFrame", UDim2.new(0.62, -18, 1, -20), UDim2.new(0.38, 8, 0, 10), contentFrame)
createSectionTitle(rightFrame, "SCRIPTS")

local scriptSearchBox = Instance.new("TextBox")
scriptSearchBox.Name = "ScriptSearchBox"
scriptSearchBox.Size = UDim2.new(1, -20, 0, 34)
scriptSearchBox.Position = UDim2.new(0, 10, 0, 34)
scriptSearchBox.PlaceholderText = "Search scripts..."
scriptSearchBox.Text = ""
scriptSearchBox.Parent = rightFrame
styleInput(scriptSearchBox)

local scriptList = Instance.new("ScrollingFrame")
scriptList.Name = "ScriptList"
scriptList.Size = UDim2.new(1, -20, 1, -80)
scriptList.Position = UDim2.new(0, 10, 0, 72)
scriptList.Parent = rightFrame
styleList(scriptList)

local scriptListLayout = Instance.new("UIListLayout")
scriptListLayout.Padding = UDim.new(0, 6)
scriptListLayout.FillDirection = Enum.FillDirection.Vertical
scriptListLayout.SortOrder = Enum.SortOrder.LayoutOrder
scriptListLayout.Parent = scriptList

local scriptListPadding = Instance.new("UIPadding")
scriptListPadding.PaddingTop = UDim.new(0, 6)
scriptListPadding.PaddingBottom = UDim.new(0, 6)
scriptListPadding.Parent = scriptList

scriptListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scriptList.CanvasSize = UDim2.new(0, 0, 0, scriptListLayout.AbsoluteContentSize.Y + 14)
end)

---------------------------------------------------------------------
-- DATA <-> UI
---------------------------------------------------------------------

local currentPage = nil
local currentPagesView = {}
local currentScriptsView = {}

local function createScriptButtonsForPage(page, query)
    clearChildren(scriptList)
    if not page then
        currentScriptsView = {}
        createEmptyState(scriptList, "Select a game first")
        return
    end

    local filtered = filterScripts(page, query or "")
    currentScriptsView = filtered

    if #filtered == 0 then
        createEmptyState(scriptList, "No scripts found")
        return
    end

    for _, scr in ipairs(filtered) do
        local sbtn = Instance.new("TextButton")
        sbtn.Name = "ScriptButton"
        sbtn.Size = UDim2.new(1, -8, 0, 34)
        sbtn.TextXAlignment = Enum.TextXAlignment.Left

        local keyLabel = scr.has_key and "[KEY] " or "[NO KEY] "
        sbtn.Text = keyLabel .. (scr.title or "Untitled")
        sbtn.Parent = scriptList

        styleSoftButton(sbtn, {
            base = scr.has_key and Color3.fromRGB(54, 42, 38) or THEME.button,
            hover = scr.has_key and Color3.fromRGB(70, 52, 46) or THEME.buttonHover,
            pressed = THEME.buttonPressed,
            paddingLeft = 12,
            paddingRight = 12,
        })

        sbtn.MouseButton1Click:Connect(function()
            runScript(scr)
        end)
    end
end

local function createGameButton(page)
    local btn = Instance.new("TextButton")
    btn.Name = "GameButton"
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = normalizeGameTitle(page)
    btn.Parent = gameList

    styleSoftButton(btn, {
        base = THEME.button,
        hover = THEME.buttonHover,
        selected = THEME.buttonSelected,
        paddingLeft = 12,
        paddingRight = 12,
    })

    if page == currentPage then
        btn:SetAttribute("Selected", true)
    end

    btn.MouseButton1Click:Connect(function()
        currentPage = page
        scriptSearchBox.Text = ""
        for _, child in ipairs(gameList:GetChildren()) do
            if child:IsA("TextButton") then
                child:SetAttribute("Selected", false)
            end
        end
        btn:SetAttribute("Selected", true)
        createScriptButtonsForPage(currentPage, "")
    end)

    return btn
end

local function renderGames(query)
    currentPagesView = filterPages(allPages, query)
    clearChildren(gameList)

    if #currentPagesView == 0 then
        createEmptyState(gameList, "No games found")
        return
    end

    for _, page in ipairs(currentPagesView) do
        createGameButton(page)
    end
end

---------------------------------------------------------------------
-- SEARCH HANDLERS
---------------------------------------------------------------------

gameSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = gameSearchBox.Text or ""
    currentPage = nil
    renderGames(q)
    clearChildren(scriptList)
    createEmptyState(scriptList, "Select a game first")
end)

scriptSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = scriptSearchBox.Text or ""
    createScriptButtonsForPage(currentPage, q)
end)

---------------------------------------------------------------------
-- TOGGLE SHOW / HIDE ANIMATION
---------------------------------------------------------------------

local isOpen = true
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function showMain()
    if isOpen then return end
    isOpen = true
    mainFrame.Visible = true
    uiScale.Scale = 0.92
    mainFrame.BackgroundTransparency = 0.48
    toggleButton.Text = "Hide Hub"
    tweenGui(uiScale, {Scale = 1}, tweenInfo)
    tweenGui(mainFrame, {BackgroundTransparency = THEME.mainTransparency}, tweenInfo)
    tweenGui(hubBlur, {Size = 8}, tweenInfo)
end

local function hideMain()
    if not isOpen then return end
    isOpen = false
    toggleButton.Text = "Open Hub"
    local tween = tweenGui(uiScale, {Scale = 0.92}, tweenInfo)
    tweenGui(mainFrame, {BackgroundTransparency = 0.48}, tweenInfo)
    tweenGui(hubBlur, {Size = 0}, tweenInfo)
    tween.Completed:Connect(function()
        if not isOpen then
            mainFrame.Visible = false
        end
    end)
end

closeButton.MouseButton1Click:Connect(function()
    hideMain()
end)

toggleButton.MouseButton1Click:Connect(function()
    if isOpen then
        hideMain()
    else
        showMain()
    end
end)

---------------------------------------------------------------------
-- INITIAL RENDER
---------------------------------------------------------------------

if #allPages > 0 then
    currentPage = allPages[1]
end

renderGames("")

if currentPage then
    createScriptButtonsForPage(currentPage, "")
else
    createEmptyState(scriptList, "No embedded pages")
end

print("[ROBScript Hub] Loaded with", #allPages, "pages from hub.json")
