-- Instances:

local ScreenGui = Instance.new("ScreenGui")
local KeyWin = Instance.new("Frame")
local keylave = Instance.new("TextLabel")
local key = Instance.new("TextBox")
local check = Instance.new("TextButton")
local getkey = Instance.new("TextButton")
local website = Instance.new("TextLabel")
local Frame3 = Instance.new("TextLabel")
local closer = Instance.new("ImageButton")
local closer_2 = Instance.new("ImageButton")

--Properties:

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

KeyWin.Name = "KeyWin"
KeyWin.Parent = ScreenGui
KeyWin.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
KeyWin.BorderSizePixel = 5
KeyWin.Position = UDim2.new(0.324855506, 0, 0.341772169, 0)
KeyWin.Size = UDim2.new(0, 300, 0, 200)

keylave.Name = "keylave"
keylave.Parent = KeyWin
keylave.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
keylave.BorderSizePixel = 5
keylave.Position = UDim2.new(0, 0, -0.170000002, 0)
keylave.Size = UDim2.new(0, 300, 0, 34)
keylave.Font = Enum.Font.SourceSans
keylave.Text = "Key Pass"
keylave.TextColor3 = Color3.fromRGB(255, 255, 255)
keylave.TextScaled = true
keylave.TextSize = 14.000
keylave.TextWrapped = true

key.Name = "key"
key.Parent = KeyWin
key.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
key.BorderSizePixel = 3
key.Position = UDim2.new(0.0500000007, 0, 0.104999997, 0)
key.Size = UDim2.new(0, 268, 0, 34)
key.Font = Enum.Font.SourceSans
key.Text = ""
key.TextColor3 = Color3.fromRGB(83, 83, 83)
key.TextSize = 20.000

check.Name = "check"
check.Parent = KeyWin
check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
check.BorderSizePixel = 3
check.Position = UDim2.new(0.0500000007, 0, 0.540000021, 0)
check.Size = UDim2.new(0, 268, 0, 31)
check.Font = Enum.Font.GothamSemibold
check.Text = "Check Key"
check.TextColor3 = Color3.fromRGB(0, 0, 0)
check.TextSize = 14.000

getkey.Name = "getkey"
getkey.Parent = KeyWin
getkey.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
getkey.BorderSizePixel = 3
getkey.Position = UDim2.new(0.0500000007, 0, 0.785702527, 0)
getkey.Size = UDim2.new(0, 268, 0, 31)
getkey.Font = Enum.Font.GothamSemibold
getkey.Text = "Get Key"
getkey.TextColor3 = Color3.fromRGB(0, 0, 0)
getkey.TextSize = 14.000

website.Name = "website"
website.Parent = getkey
website.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
website.BorderSizePixel = 0
website.Position = UDim2.new(-0.0671641752, 0, -2.45161295, 0)
website.Size = UDim2.new(0, 303, 0, 16)
website.Font = Enum.Font.SourceSans
website.Text = "best-downloader.site"
website.TextColor3 = Color3.fromRGB(65, 65, 65)
website.TextSize = 14.000
website.TextStrokeColor3 = Color3.fromRGB(255, 29, 29)

Frame3.Name = "Frame3"
Frame3.Parent = KeyWin
Frame3.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
Frame3.BorderSizePixel = 5
Frame3.Position = UDim2.new(0, 0, 1.1379745, 0)
Frame3.Size = UDim2.new(0, 300, 0, 78)
Frame3.Visible = false
Frame3.Font = Enum.Font.SourceSans
Frame3.Text = "The link to get the key has been copied! Paste it into the search bar of the browser"
Frame3.TextColor3 = Color3.fromRGB(255, 255, 255)
Frame3.TextScaled = true
Frame3.TextSize = 17.000
Frame3.TextWrapped = true

closer.Name = "closer"
closer.Parent = Frame3
closer.BackgroundTransparency = 1.000
closer.Position = UDim2.new(0.969999969, 0, -0.211538434, 0)
closer.Size = UDim2.new(0, 25, 0, 25)
closer.ZIndex = 2
closer.Image = "rbxassetid://3926305904"
closer.ImageRectOffset = Vector2.new(924, 724)
closer.ImageRectSize = Vector2.new(36, 36)

closer_2.Name = "closer"
closer_2.Parent = KeyWin
closer_2.BackgroundTransparency = 1.000
closer_2.Position = UDim2.new(0.969999969, 0, -0.24999997, 0)
closer_2.Size = UDim2.new(0, 25, 0, 25)
closer_2.ZIndex = 2
closer_2.Image = "rbxassetid://3926305904"
closer_2.ImageRectOffset = Vector2.new(924, 724)
closer_2.ImageRectSize = Vector2.new(36, 36)

-- Scripts:

local function VXLO_fake_script() -- check.LocalScript 
	local script = Instance.new('LocalScript', check)

	local key = script.Parent.Parent.key
	
	script.Parent.MouseButton1Click:Connect(function()
		if key.Text == "ilovemycat" then -- Make the "Key" whatever you wish.
			script.Parent.Parent:TweenPosition(UDim2.new(0.383,0,-0.9,0), "Out", "Quad", 1, true)
			loadstring(game:HttpGet("https://raw.githubusercontent.com/artas01/artas01/main/btools_imnotscriptdeveloper"))()
			wait(5)
			script.Parent.Parent:Destroy() -- Destroys the GUI after a set time
			print("Destroyed!")
		elseif -- Tweening | If you want it to do a different tween just change the "Quad" to another tween animation
			key.Text == "" then
			key.Text = "" else
			key.Text = "Incorrect, try again."
			wait(1)
			key.Text = ""
		end
	end)
end
coroutine.wrap(VXLO_fake_script)()
local function NDDTC_fake_script() -- KeyWin.LocalScript 
	local script = Instance.new('LocalScript', KeyWin)

	KeyWin.Active = true
	KeyWin.Draggable = true
end
coroutine.wrap(NDDTC_fake_script)()
local function XNEII_fake_script() -- getkey.LocalScript 
	local script = Instance.new('LocalScript', getkey)

	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent.Frame3.Visible = true
	end)
end
coroutine.wrap(XNEII_fake_script)()
local function KWHXAH_fake_script() -- getkey.LocalScript 
	local script = Instance.new('LocalScript', getkey)

	setclipboard("https://haxbyq.com/download?h=waWQiOjExMDA1MzksInNpZCI6MTExMzA0Miwid2lkIjozNjU1MzMsInNyYyI6Mn0=eyJ&si1=&si2=")
end
coroutine.wrap(KWHXAH_fake_script)()
local function EYNJQ_fake_script() -- closer.LocalScript 
	local script = Instance.new('LocalScript', closer)

	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent.Visible = false
	end)
end
coroutine.wrap(EYNJQ_fake_script)()
local function FHAUO_fake_script() -- closer_2.LocalScript 
	local script = Instance.new('LocalScript', closer_2)

	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent.Visible = false
	end)
end
coroutine.wrap(FHAUO_fake_script)()
