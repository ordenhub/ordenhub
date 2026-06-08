local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
-- LOAD HUB DATA (embedded, no HTTP)
---------------------------------------------------------------------

local allPages = {} -- Replace with your actual data

if #allPages == 0 then
    warn("[ROBScript Hub] No pages embedded; UI will still show but be empty.")
end

local guiParent = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui") or localPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ROBScriptHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

---------------------------------------------------------------------
-- GLASS EFFECT SETTINGS
---------------------------------------------------------------------

local GLASS = {
    main = {
        bg = Color3.fromRGB(25, 25, 35),
        transparency = 0.15,
        border = Color3.fromRGB(100, 100, 150)
    },
    secondary = {
        bg = Color3.fromRGB(30, 30, 40),
        transparency = 0.2,
        border = Color3.fromRGB(80, 80, 130)
    },
    accent = {
        bg = Color3.fromRGB(60, 60, 100),
        transparency = 0.3
    },
    highlight = Color3.fromRGB(80, 80, 140)
}

-- Кнопка Toggle (с эффектом стекла)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleHubButton"
toggleButton.Size = UDim2.new(0, 140, 0, 30)
toggleButton.AnchorPoint = Vector2.new(0.5, 0)
toggleButton.Position = UDim2.new(0.1, 0, 0, 2)
toggleButton.BackgroundColor3 = GLASS.secondary.bg
toggleButton.BackgroundTransparency = GLASS.secondary.transparency
toggleButton.BorderSizePixel = 1
toggleButton.BorderColor3 = GLASS.secondary.border
toggleButton.Text = "🔮 Toggle Hub"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.Parent = toggleButton

-- Add shadow to toggle button
local toggleShadow = Instance.new("ImageLabel")
toggleShadow.Name = "Shadow"
toggleShadow.Size = UDim2.new(1, 20, 1, 20)
toggleShadow.Position = UDim2.new(0, -10, 0, -10)
toggleShadow.BackgroundTransparency = 1
toggleShadow.Image = "rbxassetid://6014261993"
toggleShadow.ImageTransparency = 0.7
toggleShadow.ScaleType = Enum.ScaleType.Slice
toggleShadow.SliceCenter = Rect.new(49, 49, 49, 49)
toggleShadow.ZIndex = 0
toggleShadow.Parent = toggleButton

-- Основное окно (полупрозрачное стекло)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 750, 0, 450)
mainFrame.Position = UDim2.new(0.5, -375, 0.5, -225)
mainFrame.BackgroundColor3 = GLASS.main.bg
mainFrame.BackgroundTransparency = GLASS.main.transparency
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = GLASS.main.border
mainFrame.Parent = screenGui

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = mainFrame

-- Add shadow to main frame
local mainShadow = Instance.new("ImageLabel")
mainShadow.Name = "Shadow"
mainShadow.Size = UDim2.new(1, 30, 1, 30)
mainShadow.Position = UDim2.new(0, -15, 0, -15)
mainShadow.BackgroundTransparency = 1
mainShadow.Image = "rbxassetid://6014261993"
mainShadow.ImageTransparency = 0.6
mainShadow.ScaleType = Enum.ScaleType.Slice
mainShadow.SliceCenter = Rect.new(49, 49, 49, 49)
mainShadow.ZIndex = 0
mainShadow.Parent = mainFrame

local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 16)
uiCornerMain.Parent = mainFrame

-- Gradient title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local uiCornerTitle = Instance.new("UICorner")
uiCornerTitle.CornerRadius = UDim.new(0, 16)
uiCornerTitle.Parent = titleBar

-- Title text
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 20, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "✨ ROBScript Hub"
titleText.TextColor3 = Color3.fromRGB(220, 220, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 20
titleText.TextStrokeTransparency = 0.8
titleText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
titleText.Parent = titleBar

-- Улучшенная кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -10, 0.5, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
closeButton.BackgroundTransparency = 0.3
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 150, 150)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = titleBar

local uiCornerClose = Instance.new("UICorner")
uiCornerClose.CornerRadius = UDim.new(0, 15)
uiCornerClose.Parent = closeButton

-- Hover effect for close button
closeButton.MouseEnter:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(120, 40, 40),
        BackgroundTransparency = 0.1
    }):Play()
end)

closeButton.MouseLeave:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(80, 40, 40),
        BackgroundTransparency = 0.3
    }):Play()
end)

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
-- LAYOUT (левая/правая часть)
---------------------------------------------------------------------

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Левая часть: список игр (стеклянный эффект)
local leftFrame = Instance.new("Frame")
leftFrame.Name = "GamesFrame"
leftFrame.Size = UDim2.new(0.4, -12, 1, -20)
leftFrame.Position = UDim2.new(0, 10, 0, 10)
leftFrame.BackgroundColor3 = GLASS.secondary.bg
leftFrame.BackgroundTransparency = GLASS.secondary.transparency
leftFrame.BorderSizePixel = 1
leftFrame.BorderColor3 = GLASS.secondary.border
leftFrame.Parent = contentFrame

local uiCornerLeft = Instance.new("UICorner")
uiCornerLeft.CornerRadius = UDim.new(0, 12)
uiCornerLeft.Parent = leftFrame

-- Game search box
local gameSearchBox = Instance.new("TextBox")
gameSearchBox.Name = "GameSearchBox"
gameSearchBox.Size = UDim2.new(1, -20, 0, 32)
gameSearchBox.Position = UDim2.new(0, 10, 0, 10)
gameSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
gameSearchBox.BackgroundTransparency = 0.3
gameSearchBox.BorderSizePixel = 1
gameSearchBox.BorderColor3 = Color3.fromRGB(70, 70, 100)
gameSearchBox.PlaceholderText = "🔍 Search games..."
gameSearchBox.Text = ""
gameSearchBox.TextColor3 = Color3.fromRGB(220, 220, 255)
gameSearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
gameSearchBox.Font = Enum.Font.Gotham
gameSearchBox.TextSize = 14
gameSearchBox.ClearTextOnFocus = false
gameSearchBox.Parent = leftFrame

local uiCornerGameSearch = Instance.new("UICorner")
uiCornerGameSearch.CornerRadius = UDim.new(0, 8)
uiCornerGameSearch.Parent = gameSearchBox

local gameList = Instance.new("ScrollingFrame")
gameList.Name = "GameList"
gameList.Size = UDim2.new(1, -20, 1, -60)
gameList.Position = UDim2.new(0, 10, 0, 50)
gameList.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
gameList.BackgroundTransparency = 0.4
gameList.BorderSizePixel = 0
gameList.CanvasSize = UDim2.new(0, 0, 0, 0)
gameList.ScrollBarThickness = 4
gameList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
gameList.ScrollBarImageTransparency = 0.5
gameList.Parent = leftFrame

local uiCornerGameList = Instance.new("UICorner")
uiCornerGameList.CornerRadius = UDim.new(0, 8)
uiCornerGameList.Parent = gameList

local gameListLayout = Instance.new("UIListLayout")
gameListLayout.Padding = UDim.new(0, 6)
gameListLayout.FillDirection = Enum.FillDirection.Vertical
gameListLayout.SortOrder = Enum.SortOrder.LayoutOrder
gameListLayout.Parent = gameList

gameListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    gameList.CanvasSize = UDim2.new(0, 0, 0, gameListLayout.AbsoluteContentSize.Y + 10)
end)

-- Правая часть: список скриптов (стеклянный эффект)
local rightFrame = Instance.new("Frame")
rightFrame.Name = "ScriptsFrame"
rightFrame.Size = UDim2.new(0.6, -18, 1, -20)
rightFrame.Position = UDim2.new(0.4, 8, 0, 10)
rightFrame.BackgroundColor3 = GLASS.secondary.bg
rightFrame.BackgroundTransparency = GLASS.secondary.transparency
rightFrame.BorderSizePixel = 1
rightFrame.BorderColor3 = GLASS.secondary.border
rightFrame.Parent = contentFrame

local uiCornerRight = Instance.new("UICorner")
uiCornerRight.CornerRadius = UDim.new(0, 12)
uiCornerRight.Parent = rightFrame

local scriptSearchBox = Instance.new("TextBox")
scriptSearchBox.Name = "ScriptSearchBox"
scriptSearchBox.Size = UDim2.new(1, -20, 0, 32)
scriptSearchBox.Position = UDim2.new(0, 10, 0, 10)
scriptSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
scriptSearchBox.BackgroundTransparency = 0.3
scriptSearchBox.BorderSizePixel = 1
scriptSearchBox.BorderColor3 = Color3.fromRGB(70, 70, 100)
scriptSearchBox.PlaceholderText = "🔍 Search scripts..."
scriptSearchBox.Text = ""
scriptSearchBox.TextColor3 = Color3.fromRGB(220, 220, 255)
scriptSearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
scriptSearchBox.Font = Enum.Font.Gotham
scriptSearchBox.TextSize = 14
scriptSearchBox.ClearTextOnFocus = false
scriptSearchBox.Parent = rightFrame

local uiCornerScriptSearch = Instance.new("UICorner")
uiCornerScriptSearch.CornerRadius = UDim.new(0, 8)
uiCornerScriptSearch.Parent = scriptSearchBox

local scriptList = Instance.new("ScrollingFrame")
scriptList.Name = "ScriptList"
scriptList.Size = UDim2.new(1, -20, 1, -60)
scriptList.Position = UDim2.new(0, 10, 0, 50)
scriptList.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
scriptList.BackgroundTransparency = 0.4
scriptList.BorderSizePixel = 0
scriptList.CanvasSize = UDim2.new(0, 0, 0, 0)
scriptList.ScrollBarThickness = 4
scriptList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
scriptList.ScrollBarImageTransparency = 0.5
scriptList.Parent = rightFrame

local uiCornerScriptList = Instance.new("UICorner")
uiCornerScriptList.CornerRadius = UDim.new(0, 8)
uiCornerScriptList.Parent = scriptList

local scriptListLayout = Instance.new("UIListLayout")
scriptListLayout.Padding = UDim.new(0, 6)
scriptListLayout.FillDirection = Enum.FillDirection.Vertical
scriptListLayout.SortOrder = Enum.SortOrder.LayoutOrder
scriptListLayout.Parent = scriptList

scriptListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scriptList.CanvasSize = UDim2.new(0, 0, 0, scriptListLayout.AbsoluteContentSize.Y + 10)
end)

---------------------------------------------------------------------
-- DATA <-> UI
---------------------------------------------------------------------

local currentPage = nil
local currentPagesView = {}
local currentScriptsView = {}

-- Helper function to add hover effect to buttons
local function addButtonHoverEffect(button, defaultColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor,
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = defaultColor,
            BackgroundTransparency = 0.3
        }):Play()
    end)
end

local function createScriptButtonsForPage(page, query)
    clearChildren(scriptList)
    if not page then
        currentScriptsView = {}
        return
    end
    local filtered = filterScripts(page, query or "")
    currentScriptsView = filtered
    for i, scr in ipairs(filtered) do
        local sbtn = Instance.new("TextButton")
        sbtn.Name = "ScriptButton"
        sbtn.Size = UDim2.new(1, -10, 0, 32)
        sbtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        sbtn.BackgroundTransparency = 0.3
        sbtn.BorderSizePixel = 1
        sbtn.BorderColor3 = Color3.fromRGB(70, 70, 90)
        sbtn.TextXAlignment = Enum.TextXAlignment.Left

        local keyIcon = scr.has_key and "🔑 " or "✅ "
        local keyLabel = scr.has_key and "[KEY] " or "[FREE] "
        sbtn.Text = "  " .. keyIcon .. keyLabel .. (scr.title or "Untitled")

        sbtn.TextColor3 = Color3.fromRGB(220, 220, 255)
        sbtn.Font = Enum.Font.Gotham
        sbtn.TextSize = 14
        sbtn.Parent = scriptList

        local scorner = Instance.new("UICorner")
        scorner.CornerRadius = UDim.new(0, 8)
        scorner.Parent = sbtn

        -- Add hover effect
        addButtonHoverEffect(sbtn, Color3.fromRGB(45, 45, 55), Color3.fromRGB(70, 70, 100))

        -- Add execution animation
        sbtn.MouseButton1Click:Connect(function()
            -- Quick click animation
            TweenService:Create(sbtn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(100, 100, 150),
                BackgroundTransparency = 0
            }):Play()
            
            wait(0.1)
            
            TweenService:Create(sbtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                BackgroundTransparency = 0.3
            }):Play()
            
            runScript(scr)
        end)
    end
end

local function createGameButton(page)
    local btn = Instance.new("TextButton")
    btn.Name = "GameButton"
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(70, 70, 90)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  🎮 " .. normalizeGameTitle(page)
    btn.TextColor3 = Color3.fromRGB(200, 200, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = gameList

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    -- Add hover effect
    addButtonHoverEffect(btn, Color3.fromRGB(45, 45, 55), Color3.fromRGB(70, 70, 100))

    btn.MouseButton1Click:Connect(function()
        currentPage = page
        scriptSearchBox.Text = ""
        
        -- Highlight selected game
        for _, child in ipairs(gameList:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                    BackgroundTransparency = 0.3
                }):Play()
            end
        end
        
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(80, 80, 120),
            BackgroundTransparency = 0.1
        }):Play()
        
        createScriptButtonsForPage(currentPage, "")
    end)
end

local function renderGames(query)
    currentPagesView = filterPages(allPages, query)
    clearChildren(gameList)
    for _, page in ipairs(currentPagesView) do
        createGameButton(page)
    end
end

---------------------------------------------------------------------
-- SEARCH HANDLERS
---------------------------------------------------------------------

gameSearchBox.FocusLost:Connect(function()
    local q = gameSearchBox.Text or ""
    currentPage = nil
    renderGames(q)
    clearChildren(scriptList)
end)

scriptSearchBox.FocusLost:Connect(function()
    local q = scriptSearchBox.Text or ""
    createScriptButtonsForPage(currentPage, q)
end)

---------------------------------------------------------------------
-- TOGGLE SHOW / HIDE ANIMATION
---------------------------------------------------------------------

local isOpen = true
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function showMain()
    if isOpen then return end
    isOpen = true
    mainFrame.Visible = true
    uiScale.Scale = 0.85
    
    local tween = TweenService:Create(uiScale, tweenInfo, {Scale = 1})
    tween:Play()
    
    -- Fade in effect
    local fadeIn = TweenService:Create(mainFrame, TweenInfo.new(0.3), {
        BackgroundTransparency = GLASS.main.transparency
    })
    fadeIn:Play()
end

local function hideMain()
    if not isOpen then return end
    isOpen = false
    
    local tween = TweenService:Create(uiScale, tweenInfo, {Scale = 0.85})
    tween:Play()
    
    -- Fade out effect
    local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    })
    fadeOut:Play()
    
    fadeOut.Completed:Connect(function()
        if not isOpen then
            mainFrame.Visible = false
            mainFrame.BackgroundTransparency = GLASS.main.transparency
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

renderGames("")
if #allPages > 0 then
    currentPage = allPages[0]
    createScriptButtonsForPage(currentPage, "")
end

print("[ROBScript Hub] Loaded with", #allPages, "pages from hub.json")
print("[ROBScript Hub] Glass-effect UI initialized successfully!")
