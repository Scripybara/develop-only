local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna", true))()
local Window = Luna:CreateWindow({
    Name = "Swiftbara Hub | Midnight Chasers | PREMIUM VERSION 1.5", -- This Is Title Of Your Window
    Subtitle = nil, -- A Gray Subtitle next To the main title.
    LogoID = "82795327169782", -- The Asset ID of your logo. Set to nil if you do not have a logo for Luna to use.
    LoadingEnabled = true, -- Whether to enable the loading animation. Set to false if you do not want the loading screen or have your own custom one.
    LoadingTitle = "Swiftbara Premium is loading...", -- Header for loading screen
    LoadingSubtitle = "by Scripybara", -- Subtitle for loading screen

    ConfigSettings = {
        RootFolder = nil, -- The Root Folder Is Only If You Have A Hub With Multiple Game Scripts and u may remove it. DO NOT ADD A SLASH
        ConfigFolder = "Swiftbara Hub" -- The Name Of The Folder Where Luna Will Store Configs For This Script. DO NOT ADD A SLASH
    },

    KeySystem = false, -- As Of Beta 6, Luna Has officially Implemented A Key System!
    KeySettings = {
        Title = "Swiftbara Hub -- Key System",
        Subtitle = "Copy Get Key and Get Key",
        Note = "Best Key System Ever! Also, Please Use A HWID Keysystem like Pelican, Luarmor etc. that provide key strings based on your HWID since putting a simple string is very easy to bypass",
        SaveInRoot = false, -- Enabling will save the key in your RootFolder (YOU MUST HAVE ONE BEFORE ENABLING THIS OPTION)
        SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
        Key = {"KEY_SWIFTBARA2025_TESTER"}, -- List of keys that will be accepted by the system, please use a system like Pelican or Luarmor that provide key strings based on your HWID since putting a simple string is very easy to bypass
        SecondAction = {
            Enabled = true, -- Set to false if you do not want a second action,
            Type = "swiftbarahub-key.vercel.app", -- Link / Discord.
            Parameter = "" -- If Type is Discord, then put your invite link (DO NOT PUT DISCORD.GG/). Else, put the full link of your key system here.
        }
    }
})

--Tabs
local Racing = Window:CreateTab({
    Name = "Racing", -- Title Of Your Tab
    Icon = "directions_car",
    ImageSource = "Material",
    ShowTitle = true -- This will determine whether the big header text in the tab will show
})



--Raccing Tab
local Toggle = Racing:CreateToggle({
    Name = "Delete NPCVehicles",
    Description = "Delete All NPCVehicles On Map",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            -- Bật auto delete
            print("🔄 Bật Auto Delete NPCVehicles")
            
            -- Biến để lưu connection
            if not _G.NPCVehiclesAutoDelete then
                _G.NPCVehiclesAutoDelete = true
            end
            
            -- Hàm xóa tất cả NPCVehicles
            local function deleteAllNPCVehicles()
                local count = 0
                
                -- 1. Xóa workspace.NPCVehicles
                if workspace:FindFirstChild("NPCVehicles") then
                    workspace.NPCVehicles:Destroy()
                    count = count + 1
                end
                
                -- 2. Xóa ReplicatedStorage.Modules.Shared.NPCVehicles
                local RS = game:GetService("ReplicatedStorage")
                if RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Shared") and RS.Modules.Shared:FindFirstChild("NPCVehicles") then
                    RS.Modules.Shared.NPCVehicles:Destroy()
                    count = count + 1
                end
                
                -- 3. Xóa ReplicatedStorage.CreateNPCVehicle
                if RS:FindFirstChild("CreateNPCVehicle") then
                    RS.CreateNPCVehicle:Destroy()
                    count = count + 1
                end
                
                if count > 0 then
                    print("✅ Đã xóa " .. count .. " files NPCVehicles")
                end
                
                return count
            end
            
            -- Xóa ngay lập tức khi bật
            deleteAllNPCVehicles()
            
            -- Lặp kiểm tra mỗi giây
            spawn(function()
                while _G.NPCVehiclesAutoDelete and Value do
                    wait(1)
                    deleteAllNPCVehicles()
                end
            end)
            
        else
            -- Tắt auto delete
            print("⏹️ Tắt Auto Delete NPCVehicles")
            _G.NPCVehiclesAutoDelete = false
        end
    end
}, "AutoDeleteNPCVehicles")

-- Biến cho Rubble toggle
local rubbleAutoDelete = false
local rubbleConnection = nil

-- Thêm toggle mới cho Rubble
local RubbleToggle = Racing:CreateToggle({
    Name = "Delete Rubble",
    Description = "Delete All Rubble On Map",
    CurrentValue = false,
    Callback = function(Value)
        rubbleAutoDelete = Value
        
        if Value then
            -- BẬT
            print("🔄 Bật auto delete Rubble")
            
            -- Hàm xóa Rubble
            local function deleteRubble()
                -- Workspace.Rubble
                if workspace:FindFirstChild("Rubble") then
                    workspace.Rubble:Destroy()
                end
                
                -- ReplicatedStorage.Storage.Rubble
                local RS = game:GetService("ReplicatedStorage")
                if RS:FindFirstChild("Storage") and RS.Storage:FindFirstChild("Rubble") then
                    RS.Storage.Rubble:Destroy()
                end
            end
            
            -- Xóa ngay lập tức
            deleteRubble()
            
            -- Auto delete mỗi giây
            rubbleConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if rubbleAutoDelete then
                    deleteRubble()
                else
                    rubbleConnection:Disconnect()
                end
            end)
            
        else
            -- TẮT
            print("⏹️ Tắt auto delete Rubble")
            if rubbleConnection then
                rubbleConnection:Disconnect()
            end
        end
    end
}, "RubbleToggle")

local TeleportSection = Racing:CreateSection("Race Teleport")

-- Biến toàn cục
local isTeleporting = false
local currentCheckpoint = 1
local currentRace = "Race8"
local totalCheckpoints = 109

-- Hiển thị progress (BÊN TRONG UI)
local ProgressLabel = Racing:CreateSection("Tiến trình: Chưa bắt đầu")

-- Dropdown chọn race
local RaceDropdown = Racing:CreateDropdown({
    Name = "Choose Race",
    Description = "Chọn đường đua để teleport",
    Options = {"City Highway Race", "Salt Flats Grand Prix"},
    CurrentOption = "City Highway Race",
    MultipleOptions = false,
    Callback = function(SelectedOption)
        print("🎯 Đã chọn: " .. SelectedOption)
        
        if SelectedOption == "City Highway Race" then
            currentRace = "City Highway Race"
            totalCheckpoints = 40
        else
            currentRace = "Salt Flats Grand Prix" 
            totalCheckpoints = 109
        end
        
        currentCheckpoint = 1
        updateProgress()
    end
})

-- Toggle auto teleport
local TeleportToggle = Racing:CreateToggle({
    Name = "🚀 Auto Teleport TẤT CẢ Checkpoints",
    Description = "Tự động teleport qua " .. totalCheckpoints .. " checkpoint theo thứ tự",
    CurrentValue = false,
    Callback = function(Value)
        isTeleporting = Value
        if Value then
            print("🔄 Bắt đầu auto teleport qua " .. totalCheckpoints .. " checkpoint...")
            currentCheckpoint = 1
            updateProgress()
            startAllCheckpointsTeleport()
        else
            print("⏹️ Dừng auto teleport")
            updateProgress()
        end
    end
})

-- Hàm lấy vehicle của player
function getPlayerVehicle()
    return workspace:FindFirstChild("sangduoc10's Car") or
           workspace:FindFirstChild("MC_OK9's Car")
end

-- Hàm teleport đơn giản
function safeVehicleTeleport(targetPosition)
    local vehicle = getPlayerVehicle()
    if not vehicle then 
        print("❌ Không tìm thấy vehicle")
        return false 
    end

    local mainPart = vehicle:FindFirstChild("PrimaryPart") or vehicle:FindFirstChildWhichIsA("BasePart")
    if not mainPart then
        print("❌ Không tìm thấy part nào trong vehicle")
        return false
    end

    local newPosition = Vector3.new(
        targetPosition.X,
        targetPosition.Y + 3,
        targetPosition.Z
    )
    
    if vehicle:IsA("Model") and vehicle.PrimaryPart then
        vehicle:SetPrimaryPartCFrame(CFrame.new(newPosition))
    else
        mainPart.CFrame = CFrame.new(newPosition)
    end
    
    wait(0.05)
    return true
end

-- Hàm lấy checkpoint part
function getCheckpointPart(checkpointNumberOrName)
    local checkpointName = tostring(checkpointNumberOrName)
    local racesFolder = workspace:FindFirstChild("Races")
    if not racesFolder then return nil end
    
    local raceFolder = racesFolder:FindFirstChild(currentRace)
    if not raceFolder then return nil end
    
    local checkpoints = raceFolder:FindFirstChild("Checkpoints")
    if not checkpoints then return nil end
    
    local checkpoint = checkpoints:FindFirstChild(checkpointName)
    if checkpoint then
        return checkpoint:FindFirstChild("Part") or checkpoint:FindFirstChildWhichIsA("BasePart")
    end
    
    return nil
end

-- Hàm cập nhật tiến trình
function updateProgress()
    if isTeleporting then
        ProgressLabel:Set("Process: " .. currentCheckpoint .. "/" .. totalCheckpoints .. " (" .. currentRace .. ")")
    else
        ProgressLabel:Set("Process: Not started yet | " .. currentRace .. " | Checkpoint: " .. currentCheckpoint)
    end
end

-- Hàm teleport qua tất cả checkpoint
function startAllCheckpointsTeleport()
    spawn(function()
        while isTeleporting and currentCheckpoint <= totalCheckpoints do
            local checkpointPart = getCheckpointPart(currentCheckpoint)
            
            if checkpointPart then
                print("🎯 Đang đến checkpoint " .. currentCheckpoint .. " (" .. currentRace .. ")")
                
                local success = safeVehicleTeleport(checkpointPart.Position)
                
                if success then
                    print("✅ Đã đến checkpoint " .. currentCheckpoint)
                    currentCheckpoint = currentCheckpoint + 1
                    updateProgress()
                    
                    if isTeleporting then
                        wait(0.3)
                    end
                else
                    print("❌ Lỗi tại checkpoint " .. currentCheckpoint)
                    wait(0.5)
                end
            else
                print("❌ Không tìm thấy checkpoint " .. currentCheckpoint)
                currentCheckpoint = currentCheckpoint + 1
                updateProgress()
            end
        end
        
        if isTeleporting and currentCheckpoint > totalCheckpoints then
            local finishPart = getCheckpointPart("Finish")
            if finishPart then
                print("🏁 Đang đến Finish...")
                safeVehicleTeleport(finishPart.Position)
                print("🎉 Hoàn thành tất cả " .. totalCheckpoints .. " checkpoint + Finish!")
            end
            
            isTeleporting = false
            TeleportToggle:Set(false)
            updateProgress()
        end
    end)
end

-- Button reset tiến trình
local ResetButton = Racing:CreateButton({
    Name = "🔄 Reset Tiến Trình",
    Description = "Reset về checkpoint 1",
    Callback = function()
        currentCheckpoint = 1
        updateProgress()
        print("🔄 Đã reset về checkpoint 1")
    end
})

-- Button teleport đến Finish
local FinishButton = Racing:CreateButton({
    Name = "🏁 Nhảy đến Finish",
    Description = "Teleport thẳng đến vạch đích",
    Callback = function()
        local finishPart = getCheckpointPart("Finish")
        if finishPart then
            safeVehicleTeleport(finishPart.Position)
            currentCheckpoint = totalCheckpoints + 1
            updateProgress()
            print("🏁 Đã nhảy đến Finish!")
        else
            print("❌ Không tìm thấy Finish")
        end
    end
})

-- Kết nối để cập nhật tiến trình
spawn(function()
    while true do
        updateProgress()
        wait(0.5)
    end
end)

print("✅ Đã tải script Multi-Race Teleport")
