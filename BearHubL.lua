local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerMouse = Player:GetMouse()

local Bearlib = {
    Themes = {
        QuangHuy = {
            ["Color Hub 1"] = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0,0,0))
            }),
            ["Color Hub 2"] = Color3.fromRGB(255,255,255),
            ["Color Stroke"] = Color3.fromRGB(255,255,255),
            ["Color Theme"] = Color3.fromRGB(0,0,0),
            ["Color Text"] = Color3.fromRGB(0,0,0),
            ["Color Dark Text"] = Color3.fromRGB(0,0,0)
        }
    },
    Info = { Version = "1.1.0" },
    Save = { UISize = {550, 315}, TabSize = 160, Theme = "QuangHuy" },
    Settings = {}, Connection = {}, Instances = {}, Elements = {}, Options = {}, Flags = {}, Tabs = {},
    Icons = {
        ["sword"] = "rbxassetid://10734975486",
        ["swords"] = "rbxassetid://10734975692",
        ["moon"] = "rbxassetid://10734897102"
    }
}

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIScale = ViewportSize.Y / 450
local Settings = Bearlib.Settings
local Flags = Bearlib.Flags
local SetProps, SetChildren, InsertTheme, Create
do
    InsertTheme = function(Instance, Type) table.insert(Bearlib.Instances, {Instance = Instance, Type = Type}) return Instance end
    SetChildren = function(Instance, Children) if Children then table.foreach(Children, function(_,Child) Child.Parent = Instance end) end return Instance end
    SetProps = function(Instance, Props) if Props then table.foreach(Props, function(prop, value) Instance[prop] = value end) end return Instance end
    Create = function(...)
        local args = {...}
        local new = Instance.new(args[1])
        local Children = {}
        if type(args[2]) == "table" then SetProps(new, args[2]) SetChildren(new, args[3])
        elseif typeof(args[2]) == "Instance" then new.Parent = args[2] SetProps(new, args[3]) SetChildren(new, args[4]) end
        return new
    end
end

local ScreenGui = Create("ScreenGui", CoreGui, { Name = "Bear Library Main" }, { Create("UIScale", { Scale = UIScale, Name = "Scale" }) })
local ScreenFind = CoreGui:FindFirstChild(ScreenGui.Name)
if ScreenFind and ScreenFind ~= ScreenGui then ScreenFind:Destroy() end

function Bearlib:MakeWindow(Configs)
    local WTitle = Configs[1] or Configs.Name or Configs.Title or "Bear Hub V1"
    local WMiniText = Configs[2] or Configs.SubTitle or "by : Quang Huy"
    Settings.ScriptFile = Configs[3] or Configs.SaveFolder or false
    
    local UISizeX, UISizeY = unpack(Bearlib.Save.UISize)
    local MainFrame = InsertTheme(Create("ImageButton", ScreenGui, {
        Size = UDim2.fromOffset(UISizeX, UISizeY),
        Position = UDim2.new(0.5, -UISizeX/2, 0.5, -UISizeY/2),
        BackgroundTransparency = 1,
        Name = "Bear Hub"
    }), "Main")
    
    -- Tạo Gradient và Stroke
    local UIGradient = InsertTheme(Create("UIGradient", MainFrame, { Color = Bearlib.Themes.QuangHuy["Color Hub 1"], Rotation = 45 }), "Gradient")
    local UIStroke = InsertTheme(Create("UIStroke", MainFrame, { Color = Bearlib.Themes.QuangHuy["Color Stroke"], Thickness = 1.8, ApplyStrokeMode = "Border" }), "Stroke")
    local UICorner = Create("UICorner", MainFrame, { CornerRadius = UDim.new(0, 7) })

    -- Cho phép kéo thả (Drag)
    local Dragging, DragInput, DragStart, StartPos
    local function Update(input)
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then if Dragging then Update(input) end end end)

    local Components = Create("Folder", MainFrame, { Name = "Components" })
    local TopBar = Create("Frame", Components, { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Name = "Top Bar" })
    
    -- Tiêu đề
    InsertTheme(Create("TextLabel", TopBar, {
        Position = UDim2.new(0, 15, 0.5), AnchorPoint = Vector2.new(0, 0.5), AutomaticSize = "XY",
        Text = WTitle, TextXAlignment = "Left", TextSize = 12, TextColor3 = Bearlib.Themes.QuangHuy["Color Text"],
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Name = "Title"
    }, {
        InsertTheme(Create("TextLabel", {
            Size = UDim2.fromScale(0, 1), AutomaticSize = "X", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(1, 5, 0.9),
            Text = WMiniText, TextColor3 = Bearlib.Themes.QuangHuy["Color Dark Text"], BackgroundTransparency = 1,
            TextXAlignment = "Left", TextYAlignment = "Bottom", TextSize = 8, Font = Enum.Font.Gotham, Name = "SubTitle"
        }), "DarkText")
    }), "Text")

    local MainScroll = InsertTheme(Create("ScrollingFrame", Components, {
        Size = UDim2.new(0, Bearlib.Save.TabSize, 1, -TopBar.Size.Y.Offset),
        ScrollBarImageColor3 = Bearlib.Themes.QuangHuy["Color Theme"], Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1), ScrollBarThickness = 1.5, BackgroundTransparency = 1,
        ScrollBarImageTransparency = 0.2, CanvasSize = UDim2.new(), AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y", BorderSizePixel = 0, Name = "Tab Scroll"
    }, {
        Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
        Create("UIListLayout", { Padding = UDim.new(0, 5) })
    }), "ScrollBar")

    local Containers = Create("Frame", Components, {
        Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset),
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, ClipsDescendants = true, Name = "Containers"
    })

    -- Close Button
    local CloseButton = Create("ImageButton", TopBar, {
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -10, 0.5), AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1, Image = "rbxassetid://10747384394", Name = "Close"
    })
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local Window = {}
    
    function Window:Minimize()
        MainFrame.Visible = not MainFrame.Visible
    end

    function Window:MakeTab(Configs)
        local TName = Configs.Title or "Tab"
        local TIcon = Configs.Icon or ""
        
        local TabSelect = Create("TextButton", MainScroll, {
            Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Bearlib.Themes.QuangHuy["Color Hub 2"],
            BackgroundTransparency = 0.5, Text = ""
        })
        Create("UICorner", TabSelect, {CornerRadius = UDim.new(0, 6)})

        local LabelTitle = Create("TextLabel", TabSelect, {
            Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
            Text = TName, Font = Enum.Font.GothamMedium, TextXAlignment = "Left", TextSize = 10
        })

        local Container = Create("ScrollingFrame", Containers, {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2,
            AutomaticCanvasSize = "Y", Visible = false
        })
        Create("UIListLayout", Container, { Padding = UDim.new(0, 5) })
        Create("UIPadding", Container, { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10) })

        TabSelect.MouseButton1Click:Connect(function()
            for _, v in pairs(Containers:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            Container.Visible = true
        end)
        
        -- Mặc định hiện tab đầu tiên nếu chưa có
        if #Containers:GetChildren() == 1 then Container.Visible = true end

        local Tab = {}
        function Tab:AddButton(Configs)
            local BName = Configs.Name or "Button"
            local Callback = Configs.Callback or function() end

            local ButtonFrame = Create("TextButton", Container, {
                Size = UDim2.new(1, -20, 0, 30), BackgroundColor3 = Bearlib.Themes.QuangHuy["Color Hub 2"],
                Text = "", AutoButtonColor = false
            })
            Create("UICorner", ButtonFrame, {CornerRadius = UDim.new(0, 6)})
            
            local TitleL = Create("TextLabel", ButtonFrame, {
                Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, Text = BName, TextXAlignment = "Left",
                Font = Enum.Font.GothamBold, TextSize = 11
            })

            ButtonFrame.MouseButton1Click:Connect(Callback)
        end
            function Tab:AddSocialLink(Configs)
        local Title = Configs.Title or "Social"
        local Desc = Configs.Description or ""
        local Logo = Configs.Logo or "" 
        local Link = Configs.Link or ""

        local ContainerFrame = Create("Frame", Container, {
            Size = UDim2.new(1, -20, 0, 65),
            BackgroundTransparency = 1,
            Name = "SocialLink"
        })

        local MainFrame = Create("Frame", ContainerFrame, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Bearlib.Themes.QuangHuy["Color Hub 2"], 
        })
        Create("UICorner", MainFrame, {CornerRadius = UDim.new(0, 6)})

        local Icon = Create("ImageLabel", MainFrame, {
            Size = UDim2.new(0, 45, 0, 45),
            Position = UDim2.new(0, 10, 0.5),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Image = Logo
        })
        Create("UICorner", Icon, {CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", Icon, {Color = Bearlib.Themes.QuangHuy["Color Stroke"], Thickness = 1, ApplyStrokeMode = "Border"})

        Create("TextLabel", MainFrame, {
            Size = UDim2.new(1, -140, 0, 20),
            Position = UDim2.new(0, 65, 0, 12),
            BackgroundTransparency = 1,
            Text = Title,
            Font = Enum.Font.GothamBold,
            TextColor3 = Bearlib.Themes.QuangHuy["Color Text"],
            TextSize = 13,
            TextXAlignment = "Left"
        })

        Create("TextLabel", MainFrame, {
            Size = UDim2.new(1, -140, 0, 20),
            Position = UDim2.new(0, 65, 0, 32),
            BackgroundTransparency = 1,
            Text = Desc,
            Font = Enum.Font.Gotham,
            TextColor3 = Bearlib.Themes.QuangHuy["Color Dark Text"],
            TextSize = 11,
            TextXAlignment = "Left"
        })

        local CopyBtn = Create("TextButton", MainFrame, {
            Size = UDim2.new(0, 80, 0, 28),
            Position = UDim2.new(1, -10, 0.5),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(0, 255, 100),
            Text = "Copy Link",
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 11
        })
        Create("UICorner", CopyBtn, {CornerRadius = UDim.new(0, 6)})

        local ClickDelay = false
        CopyBtn.MouseButton1Click:Connect(function()
            setclipboard(Link)
            if ClickDelay then return end
            ClickDelay = true

            local OldText = CopyBtn.Text
            local OldColor = CopyBtn.BackgroundColor3

            CopyBtn.Text = "Copied!"
            CopyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            CopyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)

            task.wait(2)

            CopyBtn.Text = OldText
            CopyBtn.BackgroundColor3 = OldColor
            CopyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            ClickDelay = false
        end)
    end
        return Tab
    end
    return Window
end

--[[ 
    PHẦN 2: KEY SYSTEM & LOGIC MENU (ĐÃ CẬP NHẬT AUTO KEY)
]]

-- CẤU HÌNH KEY TẠI ĐÂY
local KeySettings = {
    -- Thêm bao nhiêu key tùy thích, ngăn cách bằng dấu phẩy
RealKey = {"hoanhobannhacthudo","daccauskid", "123"},  -- Đổi Key của bạn ở đây
    KeyLink = "https://discord.com/invite/V9xq5t5UhM", -- Đổi Link lấy key ở đây
    FileName = "DacCau_Key.txt" -- Tên file lưu key
}

-- Hàm chạy Menu Chính (Giữ nguyên logic cũ của bạn)
local function RunMenu()
    local Window = Bearlib:MakeWindow({
        Title = "Dac Cau Skid | Blox Fruits",
        SubTitle = "by Chat GPT",
        SaveFolder = "BearConfig.json"
    })
    
    -- Xóa GUI cũ nếu có
    if game.CoreGui:FindFirstChild("BearHub_Toggle_Square") then
        game.CoreGui:FindFirstChild("BearHub_Toggle_Square"):Destroy()
    end

    -- Tạo nút Toggle
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "BearHub_Toggle_Square"
    ToggleGui.Parent = game.CoreGui

    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Name = "ToggleButton"
    ToggleBtn.Size = UDim2.new(0, 25, 0, 25)
    ToggleBtn.Position = UDim2.new(0.10, 0, 0.10, 0)
    ToggleBtn.Image = "rbxassetid://102265533318728" 
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleBtn.BackgroundTransparency = 0.5
    ToggleBtn.Active = true 
    ToggleBtn.Draggable = true 
    ToggleBtn.Parent = ToggleGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.25, 0) 
    UICorner.Parent = ToggleBtn

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = ToggleBtn
    
    local TweenService = game:GetService("TweenService")
    local rainbowInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local rainbowTween = TweenService:Create(UIStroke, rainbowInfo, {Color = Color3.fromHSV(1, 1, 1)})
    rainbowTween:Play()

    ToggleBtn.MouseButton1Click:Connect(function()
        pcall(function()
            Window:Minimize()
        end)
    end)

    ------ Tabs
    local Tab1o = Window:MakeTab({ Title = "PvP", Icon = "Sword" })
    local Tab2o = Window:MakeTab({ Title = "Farm", Icon = "rbxassetid://10709769508" })
    local Tab3o = Window:MakeTab({ Title = "Redz face", Icon = "rbxassetid://10734944444" })
    local Tab4o = Window:MakeTab({ Title = "Banana fake", Icon = "rbxassetid://10709797985" })
    local Tab5o = Window:MakeTab({ Title = "Xeter hub", Icon = "rbxassetid://10709797985" })
    local Tab6o = Window:MakeTab({ Title = "Rubu", Icon = "rbxassetid://10709797985" })
    local Tab7o = Window:MakeTab({ Title = "Attack", Icon = "rbxassetid://10709797985" })
    local Tab8o = Window:MakeTab({ Title = "Shop", Icon = "rbxassetid://10709797985" })
    local Tab9o = Window:MakeTab({ Title = "Auto bounty", Icon = "rbxassetid://10709797985" })
    local Tab10o = Window:MakeTab({ Title = "Auto fruit", Icon = "rbxassetid://10709797985" })
    local Tab11o = Window:MakeTab({ Title = "Auto chest", Icon = "rbxassetid://10709797985" })
    local Tab12o = Window:MakeTab({ Title = "Hop sever", Icon = "rbxassetid://10709797985" })
    local TabMusic = Window:MakeTab({ Title = "Nhạc (Music)", Icon = "rbxassetid://4483345998" })
    local CurrentSound = nil
    local Tab6o = Window:MakeTab({ Title = "Update", Icon = "rbxassetid://10723407335" })
Tab1o:AddButton({
     Name = "CentuDox.xyz",
    Callback = function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Huylovemy/Pvp/refs/heads/main/PvPuinew"))()
  end
  })
Tab1o:AddButton({
     Name = "onion13",
    Callback = function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/onion132005-bit/esponion.lua/refs/heads/main/onion13v4.lua"))()
  end
  })
Tab1o:AddButton({
     Name = "Hermanos'Dev|PVP",
    Callback = function() 
    local script_mode = "PVP" -- PVP, FARM
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hermanos-dev/hermanos-hub/refs/heads/main/Loader.lua"))()
  end
  })
Tab1o:AddButton({
     Name = "Void Hub",
    Callback = function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/VoidDeveloper67/VoidHub/refs/heads/main/VoidHub"))()
  end
  })
Tab1o:AddButton({
     Name = "TOP_PVP",
    Callback = function() 
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Krovyn/KrovynHub/refs/heads/main/TOP_PVP"))()
  end
  })  
Tab1o:AddButton({
     Name = "MENU",
    Callback = function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Huylovemy/PvPvip/refs/heads/main/Pvp"))()
  end
  })  
Tab1o:AddButton({
     Name = "Menu 1",
    Callback = function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Huylovemy/Pvp/refs/heads/main/Huypvp"))()
  end
  })  
Tab1o:AddButton({
     Name = "Menu 2",
    Callback = function() 
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Huylovemy/Pvp/refs/heads/main/Huyz"))()
  end
  })  
Tab1o:AddButton({
     Name = "VanThanhIOS Hitbox",
    Callback = function() 
 loadstring(Game:HttpGet("https://raw.githubusercontent.com/VanThanhIOS/OniiChanVanThanhIOS/refs/heads/main/oniichanpakavanthanhios"))()
  end
  })  
Tab2o:AddButton({
     Name = "Rise-evo",
    Callback = function() 
 loadstring(game:HttpGet("https://rise-evo.xyz/apiv3/main.lua"))()
  end
  })  
Tab2o:AddButton({
     Name = "Quan Tum Onyx",
    Callback = function() 
       loadstring(game:HttpGet("https://raw.githubusercontent.com/flazhy/QuantumOnyx/refs/heads/main/QuantumOnyx.lua"))()
  end
  })
Tab2o:AddButton({
     Name = "Teddy Hud",
    Callback = function()
      repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
loadstring(game:HttpGet("https://raw.githubusercontent.com/Teddyseetink/Haidepzai/refs/heads/main/TeddyHub.lua"))()
  end
  })
Tab2o:AddButton({
     Name = "Anhdepzai hub",
    Callback = function() 
      loadstring(game:HttpGet("https://raw.githubusercontent.com/AnDepZaiHub/AnDepZaiHubBeta/refs/heads/main/AnDepZaiHubBeta.lua"))()
  end
  })
Tab2o:AddButton({
     Name = "Leaf hub",
    Callback = function() 
        repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
        loadstring(game:HttpGet("https://github.com/LeafHubAcademy/LeafHub/raw/refs/heads/main/Leaf.lua"))()
    end
  })
Tab2o:AddButton({
     Name = "Aurora",
    Callback = function() 
       loadstring(game:HttpGet("https://raw.githubusercontent.com/Jadelly261/BloxFruits/main/Aurora"))()
  end
  })
Tab2o:AddButton({
     Name = "NHT X hub",
    Callback = function() 
 loadstring(game:HttpGet("https://raw.githubusercontent.com/trongdeptraihucscript/Main/refs/heads/main/Hoangtrongdepzai.lua"))()
  end
  })  
Tab2o:AddButton({
     Name = "Bear hub",
    Callback = function() 
loadstring(game:HttpGet("https://raw.githubusercontent.com/Huylovemy/Huyscript/refs/heads/main/newscript.txt"))()
  end
  })  
Tab2o:AddButton({
     Name = "Night hud",
    Callback = function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/WhiteX1208/Scripts/refs/heads/main/BF-Beta.lua"))()
  end
  })
Tab2o:AddButton({
     Name = "Tuấn Anh IOS",
    Callback = function()
	  loadstring(game:HttpGet("https://raw.githubusercontent.com/AnhTuanDzai-Hub/TuanAnhIOS/refs/heads/main/TuanAnhIOS.lua"))()
  end
  })
Tab3o:AddButton({
     Name = "Gravity Hud",
    Callback = function() 
     loadstring(game:HttpGet("https://raw.githubusercontent.com/Devs-GravityHub/BloxFruit/refs/heads/main/Main.lua "))()
  end
  })
Tab3o:AddButton({
     Name = "Blue X Hud",
    Callback = function()
	  loadstring(game:HttpGet("https://raw.githubusercontent.com/Dev-BlueX/BlueX-Hub/refs/heads/main/Main.lua"))()
  end
  })
Tab3o:AddButton({
     Name = "King Rùa",
    Callback = function() 
       loadstring(game:HttpGet("https://raw.githubusercontent.com/shinichi-dz/phucshinyeuem/refs/heads/main/KingRuaHub.lua"))()
  end
  })
Tab3o:AddButton({
     Name = "Trẩu V8",
    Callback = function()
	  loadstring(game:HttpGet("https://raw.githubusercontent.com/traurobloxdeptrai/traukhoaito/refs/heads/main/traurobloxv8.lua"))()
  end
  })
Tab3o:AddButton({
     Name = "Bacon hub",
    Callback = function() 
    repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
getgenv().team = "Pirates" -- Pirates or Marines
loadstring(game:HttpGet("https://raw.githubusercontent.com/vinh129150/hack/refs/heads/main/BaconHub.lua"))()
  end
  })
Tab3o:AddButton({
     Name = "Đạt THG V3",
    Callback = function() 
       getgenv().Team = "Marines"
       loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaCrack/DatThg/refs/heads/main/DatThgV3Eng"))()
  end
  })
Tab3o:AddButton({
     Name = "Đạt THG V4",
    Callback = function() 
     loadstring(game:HttpGet("https://github.com/LuaCrack/DatThg/raw/refs/heads/main/DatThgVnV4"))()
  end
  })
Tab3o:AddButton({
     Name = "Bear hub",
    Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Huylovemy/Bearhudz/refs/heads/main/Bearhud.lua"))()
  end
  })
Tab3o:AddButton({
     Name = "Redz",
    Callback = function() 
 loadstring(game:HttpGet("https://raw.githubusercontent.com/huy384/redzHub/refs/heads/main/redzHub.lua"))()
  end
  })  
Tab3o:AddButton({
     Name = "Nana",
    Callback = function() 
 loadstring(game:HttpGet("https://raw.githubusercontent.com/NaNacuti/nanabeo/refs/heads/main/NaNaTVHub.lua"))()
  end
  })  
Tab4o:AddButton({
     Name = "Zis chuối EEG",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaCrack/Zis/refs/heads/main/ZisChuoiEng"))()
  end
  })
Tab4o:AddButton({
     Name = "Banana KaiTom",
    Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kaitofixlag-hub/Scriptkaito/refs/heads/main/bananahubkaito.txt"))()
  end
  })
Tab4o:AddButton({
     Name = "Banana Chiriku",
    Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Chiriku2013/BananaCatHub/refs/heads/main/BananaCatHub.lua"))()
  end
  })
Tab4o:AddButton({
     Name = "Abacaxi Hub",
    Callback = function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/real33ms/BloxFruits/refs/heads/main/AbacaxiHubOfc.lua"))()
  end
  })
Tab5o:AddButton({
     Name = "Xeter V1",
    Callback = function()
	  getgenv().Version = "V1"
getgenv().Team = "Marines"
loadstring(game:HttpGet("https://raw.githubusercontent.com/TlDinhKhoi/Xeter/refs/heads/main/Main.lua"))()
  end
  })
Tab5o:AddButton({
     Name = "Xeter V2",
    Callback = function()
	  getgenv().Version = "V2"
getgenv().Team = "Marines"
loadstring(game:HttpGet("https://raw.githubusercontent.com/TlDinhKhoi/Xeter/refs/heads/main/Main.lua"))()
  end
  })
Tab5o:AddButton({
     Name = "Xeter V3",
    Callback = function()
	  getgenv().Version = "V3"
getgenv().Team = "Marines"
loadstring(game:HttpGet("https://raw.githubusercontent.com/TlDinhKhoi/Xeter/refs/heads/main/Main.lua"))()
  end
  })
Tab5o:AddButton({
     Name = "Xeter V4",
    Callback = function()
	  getgenv().Version = "V4"
getgenv().Team = "Marines"
loadstring(game:HttpGet("https://raw.githubusercontent.com/TlDinhKhoi/Xeter/refs/heads/main/Main.lua"))()
  end
  })
Tab6o:AddButton({
     Name = "RubuV5",
    Callback = function() 
       loadstring(game:HttpGet("https://raw.githubusercontent.com/Bubu2k/Rubutv/refs/heads/main/rubuhubv5.lua"))()
  end
  })
Tab6o:AddButton({
     Name = "RubuV6",
    Callback = function() 
     repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
loadstring(game:HttpGet("https://raw.githubusercontent.com/Teddyseetink/RUBU/refs/heads/main/RUBUV6.lua"))()
  end
  })
Tab7o:AddButton({
     Name = "V1",
    Callback = function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Huylovemy/Attack-/refs/heads/main/Aura"))()
  end
  })
Tab7o:AddButton({
     Name = "V2",
    Callback = function() 
   loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/e9c206fd76482ee2"))()
  end
  })
Tab8o:AddButton({
     Name = "Bear hub",
    Callback = function() 
        loadstring(game:HttpGet("https://luacrack.site/index.php/Quanghuy/raw/Melle"))()
  end
  })
Tab9o:AddButton({
     Name = "3TOC(Melle+sword)",
    Callback = function() 
        repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
getgenv().Team = "Pirates" --// Marines
getgenv().Mode = "Auto Bounty"
getgenv().On_Ui = true
getgenv().Config = {
    ["Safe Health"] = {50, 70}, -- {health run, health kill}
    ["Custom Y Run"] = {
        Enabled = true,
        ["Y Run"] = 5000
    },
    ["Hunt Method"] = {
        ["Use Move Predict"] = false,
        ["Hit and Run"] = false,
        ["Aimbot"] = true,
        ["Hitbox"] = false,
        ["Hitbox-Size"] = Vector3.new(80, 80, 80),
        ["ESP Player"] = true,
        ["Skip Player"] = {"concac"},
        ["Skip Player High Bounty"] = nil,
        ["Max Attack Time"] = 60,
        ["Lock Bounty"] = {
            ["Enabled"] = false,
            ["Bounty"] = {0, 30000000}
        }
    },
    ["Stats"] = {
        ["Enable"] = false,
        ["Reset Stats"] = false,
        ["Point"] = {
            ["Points per lift"] = nil,
            ["Melee"] = nil,
            ["Defence"] = nil,
            ["Sword"] = nil,
            ["Gun"] = nil,
            ["Devil Fruit"] = nil
        }
    },
    ["Shop"] = {
        ["Random Fruit"] = false,
        ["Store Fruit"] = true,
        ["Zoro Sword"] = false
    },
    ["Theme"] = {
        Name = "Premium",
        UIUrl = "rbxassetid://131264767406496", -- rbxassetid://yourid hoặc link ảnh (github, imgur)
        Custom = {
            ["Enable"] = false,
            ["title_color"] = Color3.fromRGB(255, 221, 252),
            ["titleback_color"] = Color3.fromRGB(169, 20, 255),
            ["list_color"] = Color3.fromRGB(255, 221, 252),
            ["liststroke_color"] = Color3.fromRGB(151, 123, 207),
            ["button_color"] = Color3.fromRGB(255, 221, 252),
            ["title_font"] = Enum.Font.FredokaOne,
            ["text_font"] = Enum.Font.Gotham,
            ["title_size"] = 40,
            ["text_size"] = 24
        }
    },
    ["Setting"] = {
        ["World"] = 3,
        ["White Screen"] = false,
        ["Fast Delay"] = 0.45,
        ["FPS BOOSTER"] = false,
        ["Bypass Method"] = nil, --// Request 
        ["Url"] = "", -- có thể chỉnh thành {url, true} nếu muốn gửi webhook
        ["Lock Weapons"] = {
          ["Melee"] = "Godhuman", --// Hên xui vì game đã patched buy melee từ xa
          ["Sword"] = nil,
          ["Gun"] = nil
        },
        ["Server Hop"] = {
          ["Minimum player"] = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1} --// Số player tối thiểu để hop sang sv đó
        }
    },
    ["Skip"] = {
        ["Avoid V4"] = false,
        ["Fruit"] = {
            ["Enabled"] = true,
            ["Avoid Fruit"] = {
                "Portal-Portal",
                "Kitsune-Kitsune"
            }
        }
    },
    ["Spam All Skill On V4"] = {
        Enabled = true,
        ["Weapons"] = {"Melee", "Sword", "Gun", "Blox Fruit"}
    },
    ["Items"] = {
        ["Melee"] = {
            Enable = true,
            Delay = 0.4,
            Skills = {
                Z = {Enable = true, HoldTime = 0.3},
                X = {Enable = true, HoldTime = 0.2},
                C = {Enable = true, HoldTime = 0.5}
            }
        },
        ["Sword"] = {
            Enable = true,
            Delay = 0.5,
            Skills = {
                Z = {Enable = true, HoldTime = 1},
                X = {Enable = true, HoldTime = 0}
            }
        },
        ["Gun"] = {
            Enable = false,
            Delay = 0.3,
            Skills = {
                Z = {Enable = true, HoldTime = 0.1},
                X = {Enable = true, HoldTime = 0.1}
            }
        },
        ["Blox Fruit"] = {
            Enable = false,
            Delay = 0.4,
            Skills = {
                Z = {Enable = true, HoldTime = 0.1},
                X = {Enable = true, HoldTime = 0.1},
                C = {Enable = true, HoldTime = 0.15},
                V = {Enable = true, HoldTime = 0.2},
                F = {Enable = true, HoldTime = 0.1}
            }
        }
    }
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaAnarchist/3TOC-HUB/refs/heads/main/Auto_Bounty.luau"))()
  end
  })
Tab10o:AddButton({
     Name = "Void hub",
    Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VoidDeveloper67/VoidHub/refs/heads/main/FruitFarmer"))()
  end
  })
Tab10o:AddButton({
     Name = "Marit Hub",
    Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/marisdeptrai/Script-Free/main/FruitFinder.lua"))()
  end
  })
Tab11o:AddButton({
     Name = "TrongNguyen hub",
    Callback = function()
      repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
      getgenv().Team = "Marines"
	  loadstring(game:HttpGet("https://raw.githubusercontent.com/trongdeptraihucscript/Main/refs/heads/main/TN-Tp-Chest.lua"))()
  end
  })
Tab12o:AddButton({
     Name = "Teddy",
    Callback = function() 
       repeat task.wait() until game:IsLoaded() and game:GetService("Players") and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui")
loadstring(game:HttpGet("https://raw.githubusercontent.com/Teddyseetink/Haidepzai/refs/heads/main/TEDDYHUB-FREEMIUM"))()
  end
  })
Tab12o:AddButton({
     Name = "Night hub v1",
    Callback = function() 
        loadstring(game:HttpGet("https://github.com/WhiteX1208/Scripts/blob/main/HopScript.luau?raw=true"))()
  end
  })
Tab12o:AddButton({
     Name = "Night hub v2",
    Callback = function() 
       loadstring(game:HttpGet("https://raw.githubusercontent.com/WhiteX1208/Scripts/refs/heads/main/HopScript.luau"))()
  end
  })
Tab12o:AddButton({
     Name = "Bacon hub",
    Callback = function() 
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
getgenv().team = "Pirates" -- Pirates or Marines
loadstring(game:HttpGet("https://raw.githubusercontent.com/vinh129150/hack/refs/heads/main/HopBoss.lua"))()
  end
  })
Tab12o:AddButton({
     Name = "Rise-Evo",
    Callback = function() 
    loadstring(game:HttpGet("https://rise-evo.xyz/apiv3/ServerFinder.lua"))()
  end
  })
     -- 1. NÚT DỪNG NHẠC
    TabMusic:AddButton({ Name = "🔇 Dừng Nhạc (Stop)", Callback = function()
        if CurrentSound then 
            CurrentSound:Stop() 
            CurrentSound:Destroy() 
            CurrentSound = nil 
        end
    end })

    -- 2. NÚT NHẬP ID TÙY Ý (Sẽ hiện 1 bảng nhỏ để nhập)
    TabMusic:AddButton({ Name = "🎵 Nhập ID Nhạc (Custom)", Callback = function()
        -- Tạo GUI nhập ID nhanh
        if game.CoreGui:FindFirstChild("MusicPopup") then game.CoreGui.MusicPopup:Destroy() end
        local SG = Instance.new("ScreenGui", game.CoreGui)
        SG.Name = "MusicPopup"
        
        local Fr = Instance.new("Frame", SG)
        Fr.Size = UDim2.new(0, 300, 0, 140)
        Fr.Position = UDim2.new(0.5, -150, 0.5, -70)
        Fr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Fr.BorderSizePixel = 0
        Fr.Active = true; Fr.Draggable = true
        Instance.new("UICorner", Fr).CornerRadius = UDim.new(0, 8)
        
        -- Viền đẹp
        local Stroke = Instance.new("UIStroke", Fr)
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1
        
        local Title = Instance.new("TextLabel", Fr)
        Title.Text = "Nhập ID Nhạc (Roblox Audio)"
        Title.Size = UDim2.new(1, 0, 0, 30)
        Title.TextColor3 = Color3.fromRGB(255,255,255)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold; Title.TextSize = 14

        local Box = Instance.new("TextBox", Fr)
        Box.Size = UDim2.new(0.8, 0, 0, 40)
        Box.Position = UDim2.new(0.1, 0, 0.3, 0)
        Box.PlaceholderText = "Dán ID vào đây..."
        Box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Box.TextColor3 = Color3.fromRGB(255,255,255)
        Box.Font = Enum.Font.Gotham
        Instance.new("UICorner", Box)

        local PlayBtn = Instance.new("TextButton", Fr)
        PlayBtn.Size = UDim2.new(0.4, 0, 0, 30)
        PlayBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
        PlayBtn.Text = "PHÁT (PLAY)"
        PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        PlayBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", PlayBtn)

        local Close = Instance.new("TextButton", Fr)
        Close.Size = UDim2.new(0, 25, 0, 25)
        Close.Position = UDim2.new(1, -30, 0, 5)
        Close.Text = "X"
        Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        Instance.new("UICorner", Close)

        Close.MouseButton1Click:Connect(function() SG:Destroy() end)
        
        PlayBtn.MouseButton1Click:Connect(function()
            local id = Box.Text
            -- Xử lý ID nếu người dùng copy cả link
            if string.find(id, "rbxassetid://") then
                -- Đã đúng định dạng
            elseif tonumber(id) then
                id = "rbxassetid://" .. id
            end
            
            if CurrentSound then CurrentSound:Stop() CurrentSound:Destroy() end
            CurrentSound = Instance.new("Sound", workspace)
            CurrentSound.SoundId = id
            CurrentSound.Volume = 2
            CurrentSound.Looped = true
            CurrentSound:Play()
            SG:Destroy()
        end)
    end })

    -- 3. CÁC BÀI NHẠC CÓ SẴN (Bấm là nghe)
    TabMusic:AddButton({ Name = "🔥 Phonk Gaming (Mạnh)", Callback = function()
        if CurrentSound then CurrentSound:Stop() CurrentSound:Destroy() end
        CurrentSound = Instance.new("Sound", workspace)
        CurrentSound.SoundId = "rbxassetid://1837879082" -- ID Phonk
        CurrentSound.Looped = true; CurrentSound:Play()
    end })

    TabMusic:AddButton({ Name = "🌸 Chill Lofi (Nhẹ)", Callback = function()
        if CurrentSound then CurrentSound:Stop() CurrentSound:Destroy() end
        CurrentSound = Instance.new("Sound", workspace)
        CurrentSound.SoundId = "rbxassetid://9048375035" -- ID Chill
        CurrentSound.Looped = true; CurrentSound:Play()
    end })

    TabMusic:AddButton({ Name = "😂 Nhạc Xiếc (Troll)", Callback = function()
        if CurrentSound then CurrentSound:Stop() CurrentSound:Destroy() end
        CurrentSound = Instance.new("Sound", workspace)
        CurrentSound.SoundId = "rbxassetid://1848354536" 
        CurrentSound.Looped = true; CurrentSound:Play()
    end })
    
Tab6o:AddSocialLink({ 
    Title = "Follow TikTok", 
    Description = "huyscriptth",
    Logo = "rbxassetid://134852113716171", 
    Link = "https://www.tiktok.com/@huyscriptth?_r=1&_t=ZS-9384IhtjOUr"
})
Tab6o:AddSocialLink({ 
    Title = "Follow TikTok", 
    Description = "huyckvkne",
    Logo = "rbxassetid://125701776396252", 
    Link = "https://www.tiktok.com/@huyckvkne?_r=1&_t=ZS-93V91mgzcjR"
})

    -- Tab 6: Update
    Tab6o:AddButton({ Name = "Tb Update", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Huylovemy/Redz/refs/heads/main/Tb"))() end })
end
    
-- === KEY SYSTEM GIAO DIỆN & LOGIC ===
local function StartKeySystem()
    -- [AUTO KEY] Kiểm tra key đã lưu trước đó
    if isfile(KeySettings.FileName) then
        local SavedKey = readfile(KeySettings.FileName)
        if table.find(KeySettings.RealKey, SavedKey) then
            -- Nếu key đúng, bỏ qua bảng nhập và chạy menu luôn
            RunMenu()
            return
        end
    end

    -- Xóa GUI Key cũ nếu có
    if game.CoreGui:FindFirstChild("BearHubKeySystem") then
        game.CoreGui:FindFirstChild("BearHubKeySystem"):Destroy()
    end

    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "BearHubKeySystem"
    KeyGui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 180)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = KeyGui

    -- Trang trí
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Thickness = 1
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "Bear Hub - Key System"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = MainFrame

    local KeyInput = Instance.new("TextBox")
    KeyInput.PlaceholderText = "Nhập Key vào đây..."
    KeyInput.Text = ""
    KeyInput.Size = UDim2.new(0.8, 0, 0, 35)
    KeyInput.Position = UDim2.new(0.1, 0, 0.35, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.TextSize = 14
    KeyInput.Parent = MainFrame
    Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Text = "Kiểm tra Key"
    CheckBtn.Size = UDim2.new(0.35, 0, 0, 30)
    CheckBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
    CheckBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CheckBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    CheckBtn.Font = Enum.Font.GothamBold
    CheckBtn.TextSize = 12
    CheckBtn.Parent = MainFrame
    Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 6)

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Text = "Lấy Key (Copy Link)"
    GetKeyBtn.Size = UDim2.new(0.35, 0, 0, 30)
    GetKeyBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.TextSize = 12
    GetKeyBtn.Parent = MainFrame
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)

    local StatusText = Instance.new("TextLabel")
    StatusText.Text = ""
    StatusText.Size = UDim2.new(1, 0, 0, 20)
    StatusText.Position = UDim2.new(0, 0, 0.85, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 12
    StatusText.Parent = MainFrame

    -- Logic Nút
    GetKeyBtn.MouseButton1Click:Connect(function()
        setclipboard(KeySettings.KeyLink)
        StatusText.Text = "Đã copy link key vào bộ nhớ đệm!"
        StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)

    CheckBtn.MouseButton1Click:Connect(function()
        if table.find(KeySettings.RealKey, KeyInput.Text) then
            -- [AUTO KEY] Lưu Key khi nhập đúng
            writefile(KeySettings.FileName, KeyInput.Text)
            
            StatusText.Text = "Key chính xác! Đang tải..."
            StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
            wait(1)
            KeyGui:Destroy()
            RunMenu() -- Chạy Hub sau khi nhập đúng key
        else
            StatusText.Text = "Sai Key! Vui lòng thử lại."
            StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
end

-- Chạy Key System trước
if game:IsLoaded() then
    StartKeySystem()
else
    game.Loaded:Connect(StartKeySystem)
end
