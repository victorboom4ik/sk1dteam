local module = {}

local GameIDs = {
    [6137321701] = "fa4e49b11535d5a034b51e9bfd716abf",
    [6348640020] = "fa4e49b11535d5a034b51e9bfd716abf",
    [18199615050] = "f94ef2b233e95b8ff359b6b089d46f48",
    [18794863104] = "f94ef2b233e95b8ff359b6b089d46f48",
    [142823291] = "8cd48d4ae8ca2c6da70cd1a3092efdc6",
    [2768379856] = "877b22f6944965a8f352ff8980d055ee",
    [83704201064817] = "cf15315e9b55371d845882b79058fbc7",
    [109652885385286] = "cf15315e9b55371d845882b79058fbc7",
    [13772394625] = "9fc1f4535785382f9cac4ef8c8739f08",
    [8260276694] = "963cec62def32b2419a935d99b45f1cc",
    [126884695634066] = "2a27087a4236ede80a0fbc75648ca547",
    [14518422161] = "a3212006bcc8e4564322d37c24adb8ed",
    [17487136170] = "a3212006bcc8e4564322d37c24adb8ed",
    [15000687579] = "a3212006bcc8e4564322d37c24adb8ed",
    [15443524647] = "a3212006bcc8e4564322d37c24adb8ed",
    [16390384148] = "a3212006bcc8e4564322d37c24adb8ed",
    [15514734207] = "a3212006bcc8e4564322d37c24adb8ed",
    [15514727567] = "a3212006bcc8e4564322d37c24adb8ed",
    [8267733039] = "2aefe36cb593d0ea8ddf85c9a163df2f",
    [8417221956] = "2aefe36cb593d0ea8ddf85c9a163df2f",
    [79546208627805] = "0bc73c28f738300dbd3d4b99e5daf4f3",
    [126509999114328] = "0bc73c28f738300dbd3d4b99e5daf4f3",
    [111989938562194] = "2653400a353d057c2bb96eb410da97a9",
    [137925884276740] = "d5303a44f03092e85c5c809e4d342062",
    [121864768012064] = "cad060e1266ef84e026f173a4390923e",
    [75366259315586] = "a0727c43f0dd57a073842dfc9b39129b",
    [127742093697776] = "95585b9f228c4196cd7fe052f58166d9",
    [9285238704] = "cb439c95118674c780459b6b38d7cfaa",
    [118915549367482] = "7aa2d71ef4905fd1afdc4c7efbb48bc8",
    [71360925634781] = "3a1e586e3314de7c9f459d67b2775031",
    [90462358603255] = "cb5be29a7f23aa6505eacf57aa4727ee",
    [122826953758426] = "2c66d3cdb661cea72af18120b3ed3edf",
    [121864768012064] = "e676c2fab406736432841359a7564754",
    [123557829667240] = "4fe957c9971dffc43056b4932c8a21fc",
}

module.ScriptID = GameIDs[game.PlaceId] or "e875a9abc2005dd220616ad2d265e2b9"
module.MainWindow = nil
module.Notify = nil

local StatusMessages = {
    KEY_VALID = "Key is valid. Access granted!",
    KEY_EXPIRED = "Your key has expired. Please get a new one.",
    KEY_BANNED = "This key has been blacklisted. Please get a new one.",
    KEY_HWID_LOCKED = "Key is locked to a different device. Please reset your key.",
    KEY_INCORRECT = "Invalid key! The key doesn't exist or has been deleted.",
    KEY_INVALID = "Key format is invalid. Please check and try again.",
    SCRIPT_ID_INCORRECT = "Script ID error. Please contact the developers.",
    SCRIPT_ID_INVALID = "Script ID format error. Please contact the developers.",
    INVALID_EXECUTOR = "Your executor is not supported. Please use a different one.",
    SECURITY_ERROR = "Security validation failed. Please try again.",
    TIME_ERROR = "Time validation error. Please check your system clock.",
    UNKNOWN_ERROR = "An unknown error occurred. Please try again later."
}

function module.SaveKey(key)
    if key and key ~= "" then
        pcall(function()
            if writefile then
                writefile("PulseHubKey.txt", key)
            end
        end)
    end
end

function module.LoadSavedKey()
    local success, result = pcall(function()
        if isfile and isfile("PulseHubKey.txt") then
            return readfile("PulseHubKey.txt")
        end
        return nil
    end)
    
    if success and result then
        return result
    end
    return nil
end

function module.DeleteSavedKey()
    pcall(function()
        if isfile and isfile("PulseHubKey.txt") then
            delfile("PulseHubKey.txt")
        end
    end)
end

function module.FormatTime(timestamp)
    if not timestamp or timestamp <= 0 then
        return "Lifetime"
    end
    
    local timeLeft = timestamp - os.time()
    if timeLeft <= 0 then
        return "Expired"
    end
    
    local days = math.floor(timeLeft / 86400)
    local hours = math.floor((timeLeft % 86400) / 3600)
    local minutes = math.floor((timeLeft % 3600) / 60)
    
    if days > 0 then
        return string.format("%d days, %d hours", days, hours)
    elseif hours > 0 then
        return string.format("%d hours, %d minutes", hours, minutes)
    else
        return string.format("%d minutes", minutes)
    end
end

function module.CheckKey(key)
    -- === НАЧАЛО ОБХОДА ===
    if key == "sk1d" then
        module.SaveKey(key)
        if module.Notify then
            module.Notify({
                Title = "Success",
                Content = "Key is valid. Access granted! (Local Bypass)",
                Duration = 5
            })
        end
        
        local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
        api.script_id = module.ScriptID
        getgenv().script_key = key
        module._api = api
        
        return true
    end
    -- === КОНЕЦ ОБХОДА ===

    if not key or key == "" then
        if module.Notify then
            module.Notify({
                Title = "Error",
                Content = "Please enter a key",
                Duration = 5
            })
        end
        return false
    end

    getgenv().script_key = key

    local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
    api.script_id = module.ScriptID
    
    local success, status = pcall(function()
        return api.check_key(getgenv().script_key)
    end)
    
    if not success then
        if module.Notify then
            module.Notify({
                Title = "Error",
                Content = "Failed to validate key. Please try again.",
                Duration = 5
            })
        end
        return false
    end
    
    if status.code == "KEY_VALID" then
        module.SaveKey(key)
        
        if module.Notify then
            local timeInfo = ""
            if status.data and status.data.auth_expire then
                if status.data.auth_expire <= 0 then
                    timeInfo = " (Lifetime access)"
                else
                    timeInfo = " (Expires in: " .. module.FormatTime(status.data.auth_expire) .. ")"
                end
            end
            
            module.Notify({
                Title = "Success",
                Content = status.message .. timeInfo,
                Duration = 5
            })
        end

        module._api = api
        
        return true
    else
        module.DeleteSavedKey()
        
        if module.Notify then
            module.Notify({
                Title = "Error",
                Content = status.message or StatusMessages[status.code] or "Key validation failed",
                Duration = 5
            })
        end
        
        return false
    end
end

function module.LoadScript()
    if module._api then
        task.wait(0.1)
        pcall(function()
            module._api.load_script()
        end)
        
        if module.MainWindow then
            task.delay(1, function()
                module.MainWindow:Destroy()
            end)
        end
        
        return true
    end
    return false
end

function module.GetKeyLink()
    return "https://ads.luarmor.net/get_key?for=Pulse_Hub_Checkpoint-TxLYDUUMfNao"
end

return module
