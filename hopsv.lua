--[[ 
    KHOADZ HOP SERVER - VERSION 0.4 (STABLE FIX)
    - Fix M: Ghi file autoexec chuẩn xác
    - Fix P: Nhấn là lên, nhấn lại là tắt
    - Status: Siêu dài, đầy đủ thông tin
]]

repeat task.wait() until game:IsLoaded()

local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- CẤU HÌNH
local version = "0.4"
local image_id = "rbxassetid://108021605525411"
local is_hack_running = false
local hack_link = "https://raw.githubusercontent.com/Dev-NightMystic/Night-Mystic-/refs/heads/main/NightMystic"
local autoexec_link = "https://raw.githubusercontent.com/quangkhoa1792013-cell/script/refs/heads/main/hopsv.lua"

local l_cnt, m_cnt = 0, 0

local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Icon = image_id, Duration = 4
        })
    end)
end

-- 1. GUI STATUS DÀI (PHÍM P - NHẤN LÀ LÊN)
local function ToggleStatus()
    local pGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local old = pGui:FindFirstChild("ScriptStatus")
    if old then old:Destroy() return end
    
    local sg = Instance.new("ScreenGui", pGui); sg.Name = "ScriptStatus"
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 380, 0, 300); f.Position = UDim2.new(0.5, -190, 0.5, -150)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15); f.BorderSizePixel = 0
    Instance.new("UICorner", f)

    local sf = Instance.new("ScrollingFrame", f)
    sf.Size = UDim2.new(1, -20, 1, -20); sf.Position = UDim2.new(0, 10, 0, 10)
    sf.BackgroundTransparency = 1; sf.CanvasSize = UDim2.new(0, 0, 2.5, 0) -- Rất dài
    sf.ScrollBarThickness = 4

    local txt = Instance.new("TextLabel", sf)
    txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1, 1, 1); txt.TextXAlignment = 0; txt.TextYAlignment = 0
    txt.TextWrapped = true; txt.TextSize = 14
    txt.Text = string.format([[
[TRẠNG THÁI HỆ THỐNG]
- Phiên bản: %s
- Status: Hoạt động tốt
- Night Mystic: %s
- Asset ID: %s

--------------------------------------------
[HƯỚNG DẪN SỬ DỤNG - HDSS]
- Phím P: Mở hoặc Đóng bảng thông tin này (Nhấn 1 lần).
- Phím I: Hiện thông báo nhanh góc màn hình.
- Phím K: Nhảy Server (Xác nhận 4 bước chống bấm nhầm).
- Phím L: Chạy Night Mystic (Xác nhận 2 bước).
- Phím M: Bật/Tắt Auto-Exec. Tạo file trong máy.
- Phím U: Rejoin server hiện tại ngay lập tức.

--------------------------------------------
[THÔNG TIN CHI TIẾT - README]
Script này được thiết kế để tối ưu hóa việc cày thuê.
Tự động lưu trạng thái nhảy server vào file JSON.
Khi sử dụng phím M, script sẽ tạo một file 'autohop.lua'
trong folder autoexec của bản hack. Lần sau vào game 
nó sẽ tự chạy script nhảy server của bạn.

--------------------------------------------
[CREDITS - TÁC GIẢ]
- Developer: Khoathichlaptrinh
--------------------------------------------
Chúc bạn cày thuê vui vẻ!
]], version, is_hack_running and "ĐÃ BẬT" or "CHƯA BẬT", version, image_id)
end

-- 2. XỬ LÝ PHÍM TẮT
UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end

    -- P: NHẤN PHÁT LÊN LUÔN
    if input.KeyCode == Enum.KeyCode.P then
        ToggleStatus()
    end

    -- M: AUTO-EXEC (FIXED)
    if input.KeyCode == Enum.KeyCode.M then
        m_cnt = m_cnt + 1
        if m_cnt >= 2 then
            m_cnt = 0
            local success, err = pcall(function()
                if isfile("autohop.lua") then
                    delfile("autohop.lua")
                    Notify("Hệ Thống", "Đã XÓA file Auto-Exec.")
                else
                    writefile("autohop.lua", 'loadstring(game:HttpGet("'..autoexec_link..'"))()')
                    Notify("Hệ Thống", "Đã TẠO file autohop.lua thành công!")
                end
            end)
            if not success then Notify("Lỗi", "Executor không hỗ trợ ghi file!") end
        else
            Notify("Xác nhận M", "Nhấn M lần nữa để thiết lập Auto-Exec.")
        end
        task.delay(3, function() m_cnt = 0 end)
    end

    -- L: CHẠY HACK (XÁC NHẬN 2 LẦN)
    if input.KeyCode == Enum.KeyCode.L then
        l_cnt = l_cnt + 1
        if l_cnt >= 2 then
            l_cnt = 0; is_hack_running = true
            Notify("Night Mystic", "Đang nạp script...")
            loadstring(game:HttpGet(hack_link))()
        else
            Notify("Xác nhận L", "Nhấn L lần nữa để chạy Night Mystic.")
        end
        task.delay(3, function() l_cnt = 0 end)
    end

    -- U: REJOIN (NHẤN PHÁT CHẠY LUÔN)
    if input.KeyCode == Enum.KeyCode.U then
        Notify("Hệ Thống", "Đang Rejoin...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
    end
end)

Notify("KhoaDZ", "Phiên bản 0.4 đã sẵn sàng! Nhấn P để xem HDSS.")
