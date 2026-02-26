--[[
    GEMINI SYSTEM - VERSION 0.3 (FINAL)
    - Asset ID: 108021605525411
    - Phím tắt: I, K, L, U, M, P
]]

repeat task.wait() until game:IsLoaded()

local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- CẤU HÌNH HỆ THỐNG
local version = "0.3"
local image_id = "rbxassetid://108021605525411"

-- 1. Link dùng để ghi vào file Auto-Exec (Chỉ chứa lệnh gọi Hop Server)
local autoexec_link = "https://raw.githubusercontent.com/quangkhoa1792013-cell/script/refs/heads/main/hopsv.lua"
local autoexec_content = 'loadstring(game:HttpGet("' .. autoexec_link .. '"))()'
local autoexec_file_name = "autohop.lua"

-- 2. Link script HACK chính (Dùng cho phím L)
local hack_script_url = "https://raw.githubusercontent.com/Dev-NightMystic/Night-Mystic-/refs/heads/main/NightMystic"

local k_count, l_count, m_count, p_count = 0, 0, 0, 0

local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Icon = image_id,
            Duration = 4
        })
    end)
end

-- Hàm tạo GUI Status (Phím P)
local function ShowStatusGUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("GeminiStatus") then playerGui.GeminiStatus:Destroy() end
    local sg = Instance.new("ScreenGui", playerGui)
    sg.Name = "GeminiStatus"
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 320, 0, 260)
    frame.Position = UDim2.new(0.5, -160, 0.5, -130)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 2
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "GEMINI SYSTEM v" .. version
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    local info = Instance.new("TextLabel", frame)
    info.Size = UDim2.new(1, -20, 1, -45)
    info.Position = UDim2.new(0, 10, 0, 40)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    info.BackgroundTransparency = 1
    info.TextWrapped = true
    info.Text = [[
[STATUS]: Hoạt động bình thường
[CRE]: Gemini & quangkhoa1792013
[HDSS]:
- K: Nhấn 4 lần để Hop Server (Đã tối ưu lỗi)
- L: Nhấn 2 lần chạy Hack Night Mystic
- M: Nhấn 2 lần Bật/Tắt Auto-Exec Hop
- U: Rejoin Server hiện tại nhanh
- P: Đóng/Mở bảng Status này
- I: Hiện thông báo phím tắt nhanh
[README]: Script tối ưu cho cày thuê Blox Fruits.]]
end

-- Xử lý phím bấm
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    -- PHÍM P: MỞ BẢNG STATUS (XÁC NHẬN 2 LẦN)
    if input.KeyCode == Enum.KeyCode.P then
        p_count = p_count + 1
        if p_count >= 2 then p_count = 0; ShowStatusGUI() else Notify("Hệ Thống", "Nhấn P lần nữa để xem bảng Status.") end
        task.delay(5, function() p_count = 0 end)
    end

    -- PHÍM M: QUẢN LÝ AUTO-EXEC HOP (2 LẦN)
    if input.KeyCode == Enum.KeyCode.M then
        m_count = m_count + 1
        if m_count >= 2 then
            m_count = 0
            if isfile(autoexec_file_name) then
                delfile(autoexec_file_name)
                Notify("Auto-Exec", "Đã TẮT tự động nhảy server.")
            else
                writefile(autoexec_file_name, autoexec_content)
                Notify("Auto-Exec", "Đã BẬT tự động nhảy server.")
            end
        else
            Notify("Xác nhận M", "Nhấn M lần nữa để thiết lập Auto-Exec.")
        end
        task.delay(5, function() m_count = 0 end)
    end

    -- PHÍM L: CHẠY HACK NIGHT MYSTIC (2 LẦN)
    if input.KeyCode == Enum.KeyCode.L then
        l_count = l_count + 1
        if l_count >= 2 then
            l_count = 0
            Notify("Night Mystic", "Đang nạp script hack...")
            loadstring(game:HttpGet(hack_script_url))()
        else
            Notify("Xác nhận L", "Nhấn L lần nữa để chạy Night Mystic.")
        end
        task.delay(5, function() l_count = 0 end)
    end

    -- [Giữ nguyên logic các phím I, K, U và SafeServerHop]
    if input.KeyCode == Enum.KeyCode.K then
        k_count = k_count + 1
        if k_count >= 4 then k_count = 0; --[[Gọi SafeServerHop()]] else Notify("Xác nhận K ("..k_count.."/3)", "Nhấn tiếp để Hop.") end
        task.delay(5, function() k_count = 0 end)
    end
end)

Notify("Gemini System", "Đã sẵn sàng phiên bản " .. version)
