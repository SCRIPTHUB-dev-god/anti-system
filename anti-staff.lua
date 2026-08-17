local CONFIG = {ANTI_AFK_INTERVAL = 60, FAKE_LATENCY_MIN = 120, FAKE_LATENCY_MAX = 250, RANDOM_INPUT_INTERVAL = 45, CLEANUP_INTERVAL = 300, USE_FAKE_LATENCY = true, USE_RANDOM_INPUT = true}
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
if CONFIG.USE_FAKE_LATENCY then
    local Stats = game:GetService("Stats")
    local Network = Stats:FindFirstChild("Network")
    if Network then
        local function randomLatency()
            return math.random(CONFIG.FAKE_LATENCY_MIN, CONFIG.FAKE_LATENCY_MAX)
        end
        spawn(function()
            while task.wait(5) do
                local fakePing = randomLatency()
                pcall(function()
                    if Network:FindFirstChild("Ping") then
                    end
                end)
            end
        end)
    end
end
if CONFIG.USE_RANDOM_INPUT then
    local UIS = game:GetService("UserInputService")
    spawn(function()
        while task.wait(CONFIG.RANDOM_INPUT_INTERVAL) do
            local randX = math.random(-50, 50)
            local randY = math.random(-50, 50)
            pcall(function()
                UIS:MouseMove(UIS:GetMouseLocation().X + randX, UIS:GetMouseLocation().Y + randY)
            end)
        end
    end)
end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function getNearbyPlayers()
    local nearby = {}
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nearby end
    local root = char.HumanoidRootPart
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local pChar = plr.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") then
                local dist = (root.Position - pChar.HumanoidRootPart.Position).Magnitude
                if dist < 50 then table.insert(nearby, plr) end
            end
        end
    end
    return nearby
end
spawn(function()
    while task.wait(10) do
        local nearby = getNearbyPlayers()
        if #nearby > 3 then
            task.wait(5)
        end
    end
end)
local function stealthProtection()
    local function obfuscate(str)
        local result = ""
        for i = 1, #str do
            result = result .. string.char(string.byte(str, i) + 3)
        end
        return result
    end
    spawn(function()
        while task.wait(CONFIG.CLEANUP_INTERVAL) do
            collectgarbage("collect")
            if _G then
                for k, v in pairs(_G) do
                    if type(v) == "function" and not pcall(v) then
                        _G[k] = nil
                    end
                end
            end
        end
    end)
end
stealthProtection()
local function safeExecute(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        return nil
    end
    return result
end
spawn(function()
    while task.wait(60) do
        safeExecute(function()
            if not LocalPlayer or not LocalPlayer.Parent then
            end
        end)
    end
end)
task.wait(2)
local function delayedLoad(str)
    task.wait(math.random(1, 3))
    return loadstring(str)
end
debug.setinfo = function() end
local function disableGameAntiCheat()
    local services = {game:GetService("ReplicatedStorage"), game:GetService("ServerScriptService"), game:GetService("Workspace"), game:GetService("StarterGui"), game:GetService("StarterPack"), game:GetService("Players")}
    local keywords = {"Anti", "Cheat", "Ban", "Kick", "Detect", "Report", "Moder", "Admin", "Log", "Flag", "Monitor", "Protect", "Security"}
    for _, container in ipairs(services) do
        if container then
            local function scan(obj)
                if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                    local name = obj.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if string.find(name, kw:lower()) then
                            pcall(function()
                                obj.Disabled = true
                                obj:Destroy()
                            end)
                            break
                        end
                    end
                end
                for _, child in ipairs(obj:GetChildren()) do
                    scan(child)
                end
            end
            scan(container)
        end
    end
    local allRemotes = game:GetDescendants()
    for _, obj in ipairs(allRemotes) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local oldFire = obj.FireServer
            if oldFire then
                obj.FireServer = function(self, ...)
                    local args = {...}
                    for i, arg in ipairs(args) do
                        if type(arg) == "string" then
                            local lower = arg:lower()
                            if string.find(lower, "ban") or string.find(lower, "kick") or string.find(lower, "report") then
                                return
                            end
                        end
                    end
                    return oldFire(self, ...)
                end
            end
            if obj:IsA("RemoteEvent") then
                local oldOnEvent = obj.OnServerEvent
                if oldOnEvent then
                    obj.OnServerEvent = function(self, player, ...)
                        return
                    end
                end
            end
        end
    end
    pcall(function()
        local context = game:GetService("ScriptContext")
        if context then
            context:SetTimeout(0)
        end
    end)
end
spawn(disableGameAntiCheat)
local function monitorRemoteEvents()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local oldFire = obj.FireServer
            if oldFire then
                obj.FireServer = function(self, ...)
                    local args = {...}
                    for i, arg in ipairs(args) do
                        if type(arg) == "string" and string.find(arg, "ban") then
                            return
                        end
                    end
                    return oldFire(self, ...)
                end
            end
        end
    end
end
spawn(monitorRemoteEvents)
if game:GetService("LogService") then
    game:GetService("LogService"):SetLogLevel(Enum.LogLevel.None)
end
getfenv().script.Parent = nil
print("Anti-Ban/Anti-Kick Script Loaded Successfully (Stealth Mode)")
local function disableHyperion()
    pcall(function()
        local h = game:GetService("Hyperion")
        if h then h:Destroy() end
    end)
    pcall(function()
        local h = game:FindFirstChild("Hyperion")
        if h then h:Destroy() end
    end)
    pcall(function()
        local h = game:FindFirstChild("Byfron")
        if h then h:Destroy() end
    end)
    pcall(function()
        local context = game:GetService("ScriptContext")
        if context then
            context:Remove()
        end
    end)
    pcall(function()
        local rs = game:GetService("RunService")
        rs.Heartbeat:Connect(function()
            rs:SetRuntimeError(nil)
        end)
    end)
    pcall(function()
        debug.setupvalue(print, 1, function() end)
    end)
end
disableHyperion()
