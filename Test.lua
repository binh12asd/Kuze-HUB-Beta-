repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

getgenv().SettingFarm = getgenv().SettingFarm or {
    ["Fast Attack"] = {
        ["Speed Attack"] = 0.035,
        ["Attack Duration"] = 7,
        ["Speed Attack if Cooldown"] = 0.18,
        ["Attack Cooldown"] = 9,
    },
    ["Lock FPS"] = {
        ["Enabled"] = false,
        ["FPS"] = 60,
    },
    ["Auto Awaken Fruit"] = true,
    ["GodHuman"] = true,
    ["Priority Get Melee Sea 3"] = true,
    ["Auto Saber"] = true,
    ["Auto Pole"] = true,
    ["Cursed Dual Katana"] = true,
    ["SoulGuitar"] = true,
    ["Shark Anchor"] = true,
    ["Farm Mastery Fruit If Lvl Max"] = true,
    ["Hop Fruit 1M Quest Third Sea"] = true,
    ["White Screen"] = false,
    ["Hop if Near Farm Area"] = false,
    ["Auto Race V2-V3"] = true,
    ["Auto Pull Lever"] = true,
    ["Auto Get Mirror Fractal"] = true,
    ["Lock Fragment"] = {
        ["Enabled"] = true,
        ["Fragments"] = 25000
    },
    ["Buy Haki Color Legendary"] = true,
    ["Select Hop"] = {
        ["Hop Find Full Moon Soul Guitar"] = true,
        ["Hop Find Rip Indra Get Tushita"] = true,
        ["Hop Find Raids Castle [CDK]"] = true,
        ["Hop Find Cake Queen [CDK]"] = true,
    },
    ["Race"] = {
        ["Enabled"] = true,
        ["Auto Roll Race"] = true,
        ["Select Race"] = "Mink",
    },
    ["Buy Haki"] = {
        ["Enhancement"] = true,
        ["Skyjump"] = true,
        ["Flash Step"] = true,
        ["Observation"] = true,
    },
    ["Blox Fruit Sniper"] = { },
    ["Lock Fruit"] = { },
    ["Webhook"] = {
        ["Enabled"] = false,
        ["WebhookUrl"] = "",
    }
}

local function safe(fn, fb)
    local ok, r = pcall(fn)
    if ok then return r end
    return fb
end

local function char()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function hrp()
    local c = char()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function hum()
    local c = char()
    return c and c:FindFirstChildWhichIsA("Humanoid")
end

local function mag(a, b)
    return (a - b).Magnitude
end

local function now()
    return tick()
end

local function debounce(sec)
    local last = 0
    return function()
        local t = now()
        if t - last >= sec then
            last = t
            return true
        end
        return false
    end
end

local function jitterVec(v, r)
    return Vector3.new(
        v.X + (math.random() - 0.5) * 2 * r,
        v.Y + (math.random() - 0.5) * 2 * r,
        v.Z + (math.random() - 0.5) * 2 * r
    )
end

local function tweenTo(cf, t)
    local H = hrp()
    if not H then return end
    local tw = TweenService:Create(H, TweenInfo.new(t or 0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = cf})
    tw:Play()
    tw.Completed:Wait()
end

local function equipToolContains(part)
    local bp = LP:FindFirstChild("Backpack")
    local c = char()
    if not bp or not c then return false end
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), string.lower(part)) then
            tool.Parent = c
            return true
        end
    end
    return false
end

local function equipPreferred()
    local cfg = getgenv().SettingFarm
    if cfg["GodHuman"] then
        if not equipToolContains("combat") then
            if not equipToolContains("melee") then
                equipToolContains("sword")
            end
        end
    else
        if not equipToolContains("sword") then
            equipToolContains("combat")
        end
    end
end

local function clickOnce()
    VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(math.random(5, 10) / 100)
    VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end

local function getData()
    return LP:FindFirstChild("Data")
end

local function getLevel()
    local d = getData()
    if not d then return 1 end
    local lv = d:FindFirstChild("Level")
    return lv and lv.Value or 1
end

local function getQuestName()
    local d = getData()
    local q = d and d:FindFirstChild("Quest")
    return q and q.Value or ""
end

local function hasQuest()
    return getQuestName() ~= ""
end

local function enemiesFolder()
    return workspace:FindFirstChild("Enemies")
end

local function findMobContains(nameContains)
    local folder = enemiesFolder()
    if not folder then return nil end
    local H = hrp()
    if not H then return nil end
    local closest, best = nil, math.huge
    for _, mob in ipairs(folder:GetChildren()) do
        local mh = mob:FindFirstChildWhichIsA("Humanoid")
        local mhrp = mob:FindFirstChild("HumanoidRootPart")
        if mh and mhrp and mh.Health > 0 then
            if string.find(string.lower(mob.Name), string.lower(nameContains)) then
                local d = mag(mhrp.Position, H.Position)
                if d < best then
                    closest, best = mob, d
                end
            end
        end
    end
    return closest
end

local function hoverAboveMob(mob)
    local H = hrp()
    local M = mob and mob:FindFirstChild("HumanoidRootPart")
    if not H or not M then return end
    local offset = Vector3.new(0, math.random(24, 32), 0)
    local jittered = M.CFrame * CFrame.new(jitterVec(offset, 1.25))
    tweenTo(jittered, math.random(12, 18) / 100)
end

local function keepHover(mob)
    task.spawn(function()
        local mh = mob and mob:FindFirstChildWhichIsA("Humanoid")
        while mob and mob.Parent and mh and mh.Health > 0 do
            hoverAboveMob(mob)
            task.wait(math.random(12, 20) / 100)
        end
    end)
end

local function fastAttackLoop(mob)
    task.spawn(function()
        local mh = mob and mob:FindFirstChildWhichIsA("Humanoid")
        while mh and mh.Health > 0 do
            clickOnce()
            task.wait(math.random(15, 40) / 1000)
        end
    end)
end

local function combatMob(mob)
    equipPreferred()
    keepHover(mob)
    fastAttackLoop(mob)
end

local function recoverIfStuck()
    local H = hrp()
    local HU = hum()
    if not H or not HU then return end
    local lastPos = H.Position
    local t0 = now()
    task.wait(8)
    local H2 = hrp()
    if not H2 then return end
    local d = mag(H2.Position, lastPos)
    if d < 0.5 and now() - t0 >= 7.9 then
        H2.CFrame = H2.CFrame * CFrame.new(0, 6, 0)
    end
end

local function fragmentCount()
    local d = getData()
    local f = d and d:FindFirstChild("Fragments")
    return f and f.Value or 0
end

local function lockFragmentsEnabled()
    local cfg = getgenv().SettingFarm
    local LF = cfg["Lock Fragment"]
    return LF and LF["Enabled"] and LF["Fragments"] and fragmentCount() >= LF["Fragments"]
end

local function whiteScreen(enable)
    if enable then
        Lighting.Brightness = 0
        Lighting.FogEnd = 10
        Lighting.FogColor = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
    end
end

if getgenv().SettingFarm["White Screen"] then
    whiteScreen(true)
end

local QuestDB = {
    {min=1,max=9,npc="BanditQuest",quest="Bandit",key="bandit"},
    {min=10,max=14,npc="MonkeyQuest",quest="Monkey",key="monkey"},
    {min=15,max=29,npc="GorillaQuest",quest="Gorilla",key="gorilla"},
    {min=30,max=59,npc="PirateQuest",quest="Pirate",key="pirate"},
    {min=60,max=99,npc="DesertQuest",quest="Desert Bandit",key="desert"},
    {min=100,max=119,npc="SnowQuest",quest="Snow Bandit",key="snow"},
    {min=120,max=149,npc="SnowQuest",quest="Snowman",key="snowman"},
    {min=150,max=174,npc="MarineQuest",quest="Chief Petty Officer",key="chief"},
    {min=175,max=189,npc="MarineQuest2",quest="Sky Bandit",key="sky"},
    {min=190,max=209,npc="SkyQuest",quest="Dark Master",key="dark"},
    {min=210,max=249,npc="PrisonQuest",quest="Prisoner",key="prisoner"},
    {min=250,max=299,npc="PrisonQuest2",quest="Dangerous Prisoner",key="dangerous"},
    {min=300,max=324,npc="ColosseumQuest",quest="Toga Warrior",key="toga"},
    {min=325,max=374,npc="ColosseumQuest",quest="Gladiator",key="gladiator"},
    {min=375,max=399,npc="MagmaQuest",quest="Military Soldier",key="military"},
    {min=400,max=449,npc="MagmaQuest",quest="Military Spy",key="spy"},
    {min=450,max=474,npc="FishmanQuest",quest="Fishman Warrior",key="fishman w"},
    {min=475,max=524,npc="FishmanQuest",quest="Fishman Commando",key="fishman c"},
    {min=525,max=549,npc="SkyExp1Quest",quest="God's Guard",key="guard"},
    {min=550,max=624,npc="SkyExp2Quest",quest="Shanda",key="shanda"},
    {min=625,max=674,npc="SkyExp2Quest",quest="Royal Squad",key="royal squad"},
    {min=675,max=700,npc="SkyExp2Quest",quest="Royal Soldier",key="royal soldier"},
    {min=700,max=724,npc="FountainQuest",quest="Galley Pirate",key="galley pirate"},
    {min=725,max=800,npc="FountainQuest",quest="Galley Captain",key="galley captain"},

    {min=800,max=874,npc="Area1Quest",quest="Swan Pirate",key="swan pirate"},
    {min=875,max=899,npc="Area1Quest",quest="Factory Staff",key="factory staff"},
    {min=900,max=949,npc="Area2Quest",quest="Marine Recruit",key="marine recruit"},
    {min=950,max=999,npc="Area2Quest",quest="Marine Lieutenant",key="lieutenant"},
    {min=1000,max=1024,npc="Area3Quest",quest="Zombie",key="zombie"},
    {min=1025,max=1050,npc="Area3Quest",quest="Vampire",key="vampire"},
    {min=1050,max=1100,npc="Area4Quest",quest="Snow Trooper",key="snow trooper"},
    {min=1100,max=1150,npc="Area4Quest",quest="Winter Warrior",key="winter warrior"},
    {min=1150,max=1200,npc="Area5Quest",quest="Lab Subordinate",key="lab subordinate"},
    {min=1200,max=1250,npc="Area5Quest",quest="Horned Warrior",key="horned warrior"},
    {min=1250,max=1300,npc="Area6Quest",quest="Magma Ninja",key="magma ninja"},
    {min=1300,max=1350,npc="Area6Quest",quest="Magma Samurai",key="magma samurai"},
    {min=1350,max=1400,npc="Area7Quest",quest="Arctic Warrior",key="arctic warrior"},
    {min=1400,max=1450,npc="Area7Quest",quest="Snow Lurker",key="snow lurker"},
    {min=1450,max=1500,npc="Area8Quest",quest="Forest Pirate",key="forest pirate"},
    {min=1500,max=1550,npc="Area8Quest",quest="Forest Hunter",key="forest hunter"},

    {min=1550,max=1600,npc="CakeQuest1",quest="Cookie Crafter",key="cookie"},
    {min=1600,max=1650,npc="CakeQuest1",quest="Cake Guard",key="guard"},
    {min=1650,max=1700,npc="CakeQuest2",quest="Head Baker",key="baker"},
    {min=1700,max=1750,npc="CakeQuest2",quest="Baking Staff",key="baking"},
    {min=1750,max=1800,npc="TikiQuest1",quest="Island Trainee",key="trainee"},
    {min=1800,max=1850,npc="TikiQuest1",quest="Island Warrior",key="warrior"},
    {min=1850,max=1900,npc="TikiQuest2",quest="Islander Chief",key="chief tiki"},
    {min=1900,max=1975,npc="TikiQuest2",quest="Islander Veteran",key="veteran tiki"},
    {min=1976,max=2025,npc="GraveQuest1",quest="Graveyard Sinner",key="sinner"},
    {min=2026,max=2075,npc="GraveQuest1",quest="Graveyard Watcher",key="watcher"},
    {min=2076,max=2125,npc="GraveQuest2",quest="Catacomb Stalker",key="stalker"},
    {min=2126,max=2175,npc="GraveQuest2",quest="Catacomb Keeper",key="keeper"},
    {min=2176,max=2225,npc="CoralQuest1",quest="Coral Diver",key="diver"},
    {min=2226,max=2275,npc="CoralQuest1",quest="Coral Bruiser",key="bruise"},
    {min=2276,max=2325,npc="CoralQuest2",quest="Coral Guardian",key="guardian"},
    {min=2326,max=2375,npc="CoralQuest2",quest="Coral Enforcer",key="enforcer"},
    {min=2376,max=2425,npc="VolcanoQuest1",quest="Ash Warrior",key="ash"},
    {min=2426,max=2475,npc="VolcanoQuest1",quest="Ash Brute",key="brute"},
    {min=2476,max=2525,npc="VolcanoQuest2",quest="Ember Sorcerer",key="ember"},
    {min=2526,max=2550,npc="VolcanoQuest2",quest="Ember Champion",key="champion"},
}

local function questForLevel(level)
    for _, q in ipairs(QuestDB) do
        if level >= q.min and level <= q.max then
            return q
        end
    end
    return nil
end

local function fireQuestRemote(npc, quest)
    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    if rem and rem:FindFirstChild("Quest") then
        rem.Quest:FireServer(npc, quest)
    end
end

local reqQuestDeb = debounce(1.0)
local function ensureQuest()
    local level = getLevel()
    local q = questForLevel(level)
    if not q then return end
    if not hasQuest() and reqQuestDeb() then
        fireQuestRemote(q.npc, q.quest)
    end
end

local function buyHakiEnhancement()
end
local function buyHakiSkyjump()
end
local function buyHakiFlashStep()
end
local function buyHakiObservation()
end

if getgenv().SettingFarm["Buy Haki"]["Enhancement"] then buyHakiEnhancement() end
if getgenv().SettingFarm["Buy Haki"]["Skyjump"] then buyHakiSkyjump() end
if getgenv().SettingFarm["Buy Haki"]["Flash Step"] then buyHakiFlashStep() end
if getgenv().SettingFarm["Buy Haki"]["Observation"] then buyHakiObservation() end

local function doSaber()
end
local function doPole()
end
local function doCDK()
end
local function doSoulGuitar()
end
local function doSharkAnchor()
end

if getgenv().SettingFarm["Auto Saber"] then doSaber() end
if getgenv().SettingFarm["Auto Pole"] then doPole() end
if getgenv().SettingFarm["Cursed Dual Katana"] then doCDK() end
if getgenv().SettingFarm["SoulGuitar"] then doSoulGuitar() end
if getgenv().SettingFarm["Shark Anchor"] then doSharkAnchor() end

local function doPullLever()
end
local function getMirrorFractal()
end

if getgenv().SettingFarm["Auto Pull Lever"] then doPullLever() end
if getgenv().SettingFarm["Auto Get Mirror Fractal"] then getMirrorFractal() end

local function awakenFruitIfAllowed()
    if not getgenv().SettingFarm["Auto Awaken Fruit"] then return end
    if lockFragmentsEnabled() then return end
end

local function masteryOf(typeName)
    local d = getData()
    local s = d and d:FindFirstChild("Stats")
    if not s then return 0 end
    local map = {Melee="Melee", Sword="Sword", Gun="Gun", Fruit="DemonFruit"}
    local key = map[typeName]
    if not key then return 0 end
    local stat = s:FindFirstChild(key)
    return stat and stat.Value or 0
end

local masteryPlan = {"Melee","Sword","Gun","Fruit"}
local masteryIndex = 1
local function ensureMasteryCycle()
    local current = masteryPlan[masteryIndex]
    if not current then return end
    local threshold = 600
    local val = masteryOf(current)
    if val >= threshold then
        masteryIndex = math.min(masteryIndex + 1, #masteryPlan)
    end
end

local function sendWebhook(msg)
    local wb = getgenv().SettingFarm["Webhook"]
    if not wb["Enabled"] or wb["WebhookUrl"] == "" then return end
    local url = wb["WebhookUrl"]
    local data = { content = msg }
    local body = HttpService:JSONEncode(data)
    pcall(function()
        HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson, false)
    end)
end

local fastCfg = getgenv().SettingFarm["Fast Attack"]
local fastActive = false
local function fastAttackScheduler(mob)
    if fastActive then return end
    fastActive = true
    local duration = fastCfg["Attack Duration"]
    local cooldown = fastCfg["Attack Cooldown"]
    local speedIfCD = fastCfg["Speed Attack if Cooldown"]
    local startT = now()
    while now() - startT <= duration do
        local mh = mob and mob:FindFirstChildWhichIsA("Humanoid")
        if not mh or mh.Health <= 0 then break end
        clickOnce()
        task.wait(fastCfg["Speed Attack"])
    end
    local cdStart = now()
    while now() - cdStart <= cooldown do
        local mh = mob and mob:FindFirstChildWhichIsA("Humanoid")
        if not mh or mh.Health <= 0 then break end
        clickOnce()
        task.wait(speedIfCD)
    end
    fastActive = false
end

local function rollRaceIfEnabled()
    local r = getgenv().SettingFarm["Race"]
    if not r then return end
    if r["Enabled"] and r["Auto Roll Race"] then
    end
end

local function autoRaceV2V3()
    if not getgenv().SettingFarm["Auto Race V2-V3"] then return end
end

local function hopToNewServer()
    TeleportService:Teleport(game.PlaceId, LP)
end

local function hopSelect()
    local sel = getgenv().SettingFarm["Select Hop"]
    if sel["Hop Find Cake Queen [CDK]"] then end
    if sel["Hop Find Raids Castle [CDK]"] then end
    if sel["Hop Find Full Moon Soul Guitar"] then end
    if sel["Hop Find Rip Indra Get Tushita"] then end
end

local function eatRandomFruitIfNeeded()
    local sniper = getgenv().SettingFarm["Blox Fruit Sniper"]
    local lock = getgenv().SettingFarm["Lock Fruit"]
end

local running = true

local function farmStep()
    ensureQuest()
    local level = getLevel()
    local q = questForLevel(level)
    if q then
        local mob = findMobContains(q.key)
        if mob then
            hoverAboveMob(mob)
            equipPreferred()
            combatMob(mob)
            fastAttackScheduler(mob)
        end
    end
    recoverIfStuck()
    awakenFruitIfAllowed()
    ensureMasteryCycle()
    eatRandomFruitIfNeeded()
end

task.spawn(function()
    while running do
        farmStep()
        task.wait(0.1)
    end
end)

task.delay(8*3600, function()
    running = false
    sendWebhook("Stopped after 8h, hopping server.")
    hopToNewServer()
end)

autoRaceV2V3()
rollRaceIfEnabled()
hopSelect()

do
    local function setFpsCapIfEnabled()
        local cfg = getgenv().SettingFarm
        local lf = cfg["Lock FPS"]
        if lf and lf["Enabled"] and typeof(lf["FPS"]) == "number" and _G.__setfpscap ~= true then
            _G.__setfpscap = true
            local ok = pcall(function()
                if setfpscap then setfpscap(lf["FPS"]) end
            end)
            if not ok then _G.__setfpscap = false end
        end
    end

    local function antiIdle()
        LP.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end

    local function isNearFarmArea()
        local H = hrp()
        if not H then return false end
        local near = false
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                local d = (pl.Character.HumanoidRootPart.Position - H.Position).Magnitude
                if d < 120 then near = true break end
            end
        end
        return near
    end

    local function hopIfNear()
        local cfg = getgenv().SettingFarm
        if cfg["Hop if Near Farm Area"] and isNearFarmArea() then
            hopToNewServer()
        end
    end

    local function raceV4Progress()
        local cfg = getgenv().SettingFarm
        if not (cfg["Race"] and cfg["Race"]["Enabled"]) then return end
        local d = LP:FindFirstChild("Data")
        local stage = d and d:FindFirstChild("RaceStage")
        local cur = stage and stage.Value or "V3"
        if cur ~= "V4" then
            local ok = false
            local rem = ReplicatedStorage:FindFirstChild("Remotes")
            if rem and rem:FindFirstChild("Race") then
                rem.Race:FireServer("Upgrade", "V4")
                ok = true
            end
            if not ok then
                local temple = workspace:FindFirstChild("Temple") or workspace:FindFirstChild("RaceTemple") or workspace
                local H = hrp()
                if H and temple then
                    local target = nil
                    for _, obj in ipairs(temple:GetDescendants()) do
                        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                            if string.find(string.lower(obj.Name), "gear") or string.find(string.lower(obj.Name), "dial") then
                                target = obj
                                break
                            end
                        end
                    end
                    if target then
                        local cf = CFrame.new(target.HumanoidRootPart.Position + Vector3.new(0, 4, 0))
                        TweenService:Create(H, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = cf}):Play()
                        task.wait(0.5)
                    end
                end
            end
        end
    end

    local function fruitInBackpack()
        local bp = LP:FindFirstChild("Backpack")
        if not bp then return nil end
        for _, v in ipairs(bp:GetChildren()) do
            if v:IsA("Tool") then
                local n = string.lower(v.Name)
                if string.find(n, "fruit") or string.find(n, "blox fruit") then
                    return v
                end
            end
        end
        return nil
    end

    local function eatFruit(tool)
        local c = char()
        if not c or not tool then return false end
        tool.Parent = c
        local ok = pcall(function()
            if tool:FindFirstChild("RemoteEvent") then
                tool.RemoteEvent:FireServer("Eat")
            elseif tool:FindFirstChild("Events") and tool.Events:FindFirstChild("Eat") then
                tool.Events.Eat:FireServer()
            end
        end)
        return ok
    end

    local function randomFruit()
        local rem = ReplicatedStorage:FindFirstChild("Remotes")
        local shop = ReplicatedStorage:FindFirstChild("FruitShop") or (rem and rem:FindFirstChild("Fruit"))
        if shop then
            pcall(function()
                if shop:IsA("RemoteEvent") then
                    shop:FireServer("Random")
                elseif shop:IsA("RemoteFunction") then
                    shop:InvokeServer("Random")
                end
            end)
        end
    end

    local function shouldAwaken(name)
        local n = string.lower(name or "")
        if string.find(n, "dough") or string.find(n, "phoenix") then
            return false
        end
        return true
    end

    local function awakenCurrentFruit()
        if lockFragmentsEnabled() then return end
        local c = char()
        if not c then return end
        local tool = nil
        for _, v in ipairs(c:GetChildren()) do
            if v:IsA("Tool") then
                local n = string.lower(v.Name)
                if string.find(n, "fruit") or string.find(n, "blox fruit") then
                    tool = v
                    break
                end
            end
        end
        if not tool then return end
        if not shouldAwaken(tool.Name) then return end
        local rem = ReplicatedStorage:FindFirstChild("Remotes")
        local awaken = rem and rem:FindFirstChild("Awaken")
        if awaken then
            awaken:FireServer("AwakenAll")
        end
    end

    local function fruitRoutine()
        local cfg = getgenv().SettingFarm
        if cfg["Auto Awaken Fruit"] then
            awakenCurrentFruit()
        end
        local d = getData()
        local lvl = d and d:FindFirstChild("Level") and d.Level.Value or 1
        if cfg["Farm Mastery Fruit If Lvl Max"] and lvl >= 2550 then
            local f = fruitInBackpack()
            if f then eatFruit(f) else randomFruit() end
        end
    end

    local function buyLegendaryColor()
        local cfg = getgenv().SettingFarm
        if not cfg["Buy Haki Color Legendary"] then return end
        local rem = ReplicatedStorage:FindFirstChild("Remotes")
        local color = rem and rem:FindFirstChild("HakiColor")
        if color then
            pcall(function() color:FireServer("BuyLegendary") end)
        end
    end

    local function itemRoutine()
        local cfg = getgenv().SettingFarm
        if cfg["Auto Saber"] then pcall(function() doSaber() end) end
        if cfg["Auto Pole"] then pcall(function() doPole() end) end
        if cfg["Cursed Dual Katana"] then pcall(function() doCDK() end) end
        if cfg["SoulGuitar"] then pcall(function() doSoulGuitar() end) end
        if cfg["Shark Anchor"] then pcall(function() doSharkAnchor() end) end
        if cfg["Auto Pull Lever"] then pcall(function() doPullLever() end) end
        if cfg["Auto Get Mirror Fractal"] then pcall(function() getMirrorFractal() end) end
        buyLegendaryColor()
    end

    local function noclipStepped()
        RunService.Stepped:Connect(function()
            local c = char()
            if not c then return end
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    end

    antiIdle()
    noclipStepped()
    setFpsCapIfEnabled()

    task.spawn(function()
    while running do
        raceV4Progress()
        fruitRoutine()
        itemRoutine()
        hopIfNear()
        task.wait(1.0)
    end
end)

-- MAIN LOOP FARM + RACE + FRUIT + ITEM
task.spawn(function()
    while running do
        ensureQuest()
        local level = getLevel()
        local q = questForLevel(level)
        if q then
            local mob = findMobContains(q.key)
            if mob then
                hoverAboveMob(mob)
                equipPreferred()
                combatMob(mob)
                fastAttackScheduler(mob)
            end
        end
        recoverIfStuck()
        awakenFruitIfAllowed()
        ensureMasteryCycle()
        eatRandomFruitIfNeeded()
        task.wait(0.1)
    end
end)

-- FINAL SAFETY LOOP
task.spawn(function()
    while running do
        setFpsCapIfEnabled()
        antiIdle()
        hopSelect()
        task.wait(5.0)
    end
end)

-- END OF FULL SCRIPT


