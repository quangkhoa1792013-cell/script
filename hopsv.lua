-- ==========================================
-- SCRIPT VERSION: 0.2 (PHÍM TẮT ĐA CẤP)
-- ==========================================

repeat task.wait() until game:IsLoaded()

local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Biến lưu trạng thái
local k_count = 0
local l_count = 0
local version = "0.2"

-- 1. Hàm hiện thông báo
local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
end

-- 2. Hàm SafeServerHop (Dùng cho K)
local function SafeServerHop()
    local fileName = "VisitedServers.json"
    local visited = {}
    pcall(function() if isfile(fileName) then visited = HttpService:JSONDecode(readfile(fileName)) end end)

    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)

    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing <= (server.maxPlayers - 2) and server.id ~= game.JobId then
                local isVisited = false
                for _, id in ipairs(visited) do if id == server.id then isVisited = true break end end
                if not isVisited then
                    table.insert(visited, server.id)
                    writefile(fileName, HttpService:JSONEncode(visited))
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Players.LocalPlayer)
                    return
                end
            end
        end
        writefile(fileName, "[]")
        Notify("Hệ Thống", "Đã reset danh sách server!")
    end
end

-- 3. Xử lý Phím bấm
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    -- PHÍM I: KIỂM TRA PHIÊN BẢN & HƯỚNG DẪN
    if input.KeyCode == Enum.KeyCode.I then
        Notify("Version: " .. version, "Status: Hoạt động tốt\nK: Hop Server (3 bước)\nL: Load Script (2 bước)\nU: Rejoin Server hiện tại")
        print("--- HƯỚNG DẪN v" .. version .. " ---")
        print("K: Nhấn 4 lần để thực hiện nhảy server.")
        print("L: Nhấn 2 lần để chạy Night Mystic.")
        print("U: Thoát ra và vào lại đúng server này.")
    end

    -- PHÍM U: REJOIN (LƯU ID VÀ VÀO LẠI)
    if input.KeyCode == Enum.KeyCode.U then
        local currentJobId = game.JobId
        Notify("Rejoin", "Đang sao chép ID và kết nối lại...")
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, currentJobId, Players.LocalPlayer)
    end

    -- PHÍM K: NHẢY SERVER (XÁC NHẬN 3 LẦN)
    if input.KeyCode == Enum.KeyCode.K then
        k_count = k_count + 1
        if k_count == 1 then
            Notify("Xác nhận (1/3)", "Bạn có muốn hop server không? (Nhấn K tiếp)")
        elseif k_count == 2 then
            Notify("Xác nhận (2/3)", "Chắc chắn muốn hop chứ? (Nhấn K tiếp)")
        elseif k_count == 3 then
            Notify("Xác nhận (3/3)", "Ok, 1 lần cuối để nhảy!")
        elseif k_count >= 4 then
            k_count = 0 -- Reset count
            SafeServerHop()
        end
        -- Tự động reset count sau 5s nếu không nhấn tiếp
        task.delay(5, function() k_count = 0 end)
    end

    -- PHÍM L: CHẠY SCRIPT (XÁC NHẬN 2 LẦN)
    if input.KeyCode == Enum.KeyCode.L then
        l_count = l_count + 1
        if l_count == 1 then
            Notify("Xác nhận (1/2)", "Nhấn L lần nữa để chạy Script.")
        elseif l_count >= 2 then
            l_count = 0
            Notify("Night Mystic", "Đang nạp...")
            task.spawn(function()
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dev-NightMystic/Night-Mystic-/refs/heads/main/NightMystic"))()
                end)
            end)
        end
        task.delay(5, function() l_count = 0 end)
    end
end)

-- Đè lỗi Teleport (vẫn giữ logic siêu tốc của bạn)
TeleportService.TeleportInitFailed:Connect(function()
    SafeServerHop()
end) 
