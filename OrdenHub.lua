local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

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

    if scr.has_key then
        -- Здесь можно повесить твою систему ключей
        warn("[ROBScript Hub] Script requires key-system:", scr.title or "Unknown")
        return
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

local allPages = {
    {
        page_url = "https://robscript.com/spin-a-brainrot-scripts/",
        slug = "spin-a-brainrot-scripts",
        scripts = {
        },
    },
    {
        page_url = "https://robscript.com/meme-sea-scripts/",
        slug = "meme-sea-scripts",
        scripts = {
            {
                title = "KEYLESS Meme Sea script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZZINSWARE/ZZINSWARE-Script-Hub/refs/heads/main/ZZINSWARE\"))()",
            },
            {
                title = "FIXZ Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/X7iQpTVF\"))()",
            },
            {
                title = "Infinity X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gitlab.com/Lmy77/menu/-/raw/main/infinityx\"))()",
            },
            {
                title = "OMG Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Omgshit/Scripts/main/MainLoader.lua'))()",
            },
            {
                title = "CLT Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RHOFICIAL01/Projetos./refs/heads/main/CLT%20meme%20sea\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/devil-hunter-scripts/",
        slug = "devil-hunter-scripts",
        scripts = {
            {
                title = "Devil Hunter script",
                has_key = true,
                code = "script_key=\"YOUR KEY HERE\";\nloadstring(game:HttpGet(\"https://www.getcerberus.com/loader.lua\"))()",
            },
            {
                title = "Ravyneth hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ravyneth.space/main.lua\"))()",
            },
            {
                title = "gluuu3 hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gluuu3/DevilHunter/refs/heads/main/Devilhunter\"))()",
            },
            {
                title = "Rifton Hub",
                has_key = true,
                code = "local v0=\"https://api.luarmor.net/files/v3/loaders/1f6f65a554ba5d1583570b9dca5315e8.lua\";local v1=\"1f6f65a554ba5d1583570b9dca5315e8\";local v2=loadstring(game:HttpGet(\"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua\"))();local function v3() local v7,v8=pcall(function() loadstring(game:HttpGet(v0))();end);if  not v7 then warn(\"Failed to load script: \"   .. tostring(v8) );v2:Notify({Title=\"Script Error\",Content=\"Failed to load script. Check your key.\",Duration=5,Icon=\"alert-triangle\"});end end local function v4(v9) if ( not v9 or (v9==\"\")) then return false,\"Please enter a key\";end if ( #v9<20) then return false,\"Key is too short\";end getgenv().script_key=v9;return true,\"Key accepted! Loading script...\";end local function v5() task.spawn(function() task.wait(0.5);if Window then Window:Destroy();end v3();end);end local v6=v2:CreateWindow({Title=\"Rift Hub\",Icon=\"door-open\",Author=\"by alainyan.\",Folder=\"RiftHub\",Size=UDim2.fromOffset(580,460),MinSize=Vector2.new(560,350),MaxSize=Vector2.new(850,560),Transparent=true,Theme=\"Dark\",Resizable=true,SideBarWidth=200,BackgroundImageTransparency=0.42,HideSearchBar=true,ScrollBarEnabled=false,Background=\"rbxassetid://\",User={Enabled=true,Anonymous=true,Callback=function() print(\"clicked\");end},KeySystem={Title=\"Rift Hub - Key System\",Note=\"Get your key from the link below. Keys are free!\",URL=\"https://ads.luarmor.net/get_key?for=Devil_Hunter-zLWPYglOFkdD\",SaveKey=true,KeyValidator=function(v11) local v12,v13=v4(v11);if v12 then v2:Notify({Title=\"Key Accepted\",Content=v13,Duration=3,Icon=\"check\"});v5();return true;else v2:Notify({Title=\"Key Error\",Content=v13,Duration=5,Icon=\"x\"});return false;end end}});",
            },
        },
    },
    {
        page_url = "https://robscript.com/entrenched-scripts/",
        slug = "entrenched-scripts",
        scripts = {
            {
                title = "KEYLESS Entrenched script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/artas01/artas01/main/polybattle-esp'))()",
            },
            {
                title = "Sapi Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/land9678/VT/refs/heads/main/SapiHub.lua\"))()",
            },
            {
                title = "Vylera Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/vyleraentrenched.lua\"))()",
            },
            {
                title = "Entrenched open source script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/ENTRENCHED-WW1-MOBILE-AND-XENO-SOURCE-NO-BAN-AIM-ESP-RAGE-AND-MORE-75412\"))()",
            },
            {
                title = "Gnex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/55a483af88878dadf6f5d2c7c98cc45f7e144df787df5918a7b0f58f87f13fd0/download\"))()",
            },
            {
                title = "Aussie Prod",
                has_key = true,
                code = "loadstring(game:HttpGet(request({Url='https://aussie.productions/script'}).Body))()",
            },
            {
                title = "BaxMix",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://bakmix.pro/raw/loader.lua\")()",
            },
            {
                title = "Bloxhub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ArtChivegroup/Roblox/refs/heads/main/script/(key)entrenched%20ww1%20esp%2Baimbot.lua'))()",
            },
            {
                title = "Ash Labs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=Entranchedd-ww1.lua\", true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/arcane-odyssey-scripts/",
        slug = "arcane-odyssey-scripts",
        scripts = {
            {
                title = "KEYLESS Arcane Odyssey script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/Z49Tr9uw\"))()",
            },
            {
                title = "sirmemeSr",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/x7dJJ9vnFH23/Maintained-Fun/refs/heads/main/FUNC/Games/AO.lua\", true))()",
            },
            {
                title = "ACID Hub",
                has_key = true,
                code = "script_key=\"ENTER KEY HERE\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/5d26cf04934b60cb20b4f972ad2dc00d.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-crusaders-scripts/",
        slug = "anime-crusaders-scripts",
        scripts = {
            {
                title = "Anime Crusaders script",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/lifaiossama/errors/main/Intruders.html\")()",
            },
            {
                title = "PIA Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/djtmemaynha/bonngu/refs/heads/main/AC.lua'))()",
            },
            {
                title = "Lix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader\"))()",
            },
            {
                title = "Rebel Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rebelhub.pro/loader\"))()",
            },
            {
                title = "Goomba Hub",
                has_key = true,
                code = "getgenv().script_key = \"KEYHERE\";\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLevel/goombahub/main/goombahub.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/jujutsu-infinite-scripts/",
        slug = "jujutsu-infinite-scripts",
        scripts = {
            {
                title = "KEYLESS Jujutsu Infinite script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/mrqwenzy/QWENZY_HUB/refs/heads/main/JujutsuInfinite'))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Vexium Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/633e10d1252e3230100e133070ec66e9.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fate-trigger-scripts/",
        slug = "fate-trigger-scripts",
        scripts = {
            {
                title = "KEYLESS Fate Trigger script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/syznq/Roblox-Scripts/refs/heads/main/Games/Fate%20Trigger%20%5BFPS%5D.lua\"))()",
            },
            {
                title = "Chair Hub",
                has_key = false,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/ReWelp/ChairHub./refs/heads/main/universalaimbot.lua\", true))()",
            },
            {
                title = "IMP hub",
                has_key = true,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))()",
            },
            {
                title = "Prime Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/wendigo5414-cmyk/Fate-Trigger/refs/heads/main/main.lua\", true))()",
            },
            {
                title = "SFY Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/P8EPF8hG\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.getvoid.cc\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/jujutsu-zero-scripts/",
        slug = "jujutsu-zero-scripts",
        scripts = {
            {
                title = "Jujutsu Zero script – (Simca Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/3186a4f30fcd853ae613dcbee2534612.lua\"))()",
            },
            {
                title = "Instant Spin",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/snarix/AutoSpinZero/refs/heads/main/Main\"))()",
            },
            {
                title = "Ravyneth hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ravyneth.space/main.lua\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Draco Hub",
                has_key = true,
                code = "script_key = \"put your key here\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/cdc8ffd74b2c33f6c9f47b85f4b77c45.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/my-fishing-brainrots-scripts/",
        slug = "my-fishing-brainrots-scripts",
        scripts = {
            {
                title = "My Fishing Brainrots script – (IMP Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))()",
            },
            {
                title = "Astra Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/PdTW70Np'))()",
            },
            {
                title = "Nuarexsc Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nuarexsc/nuarexsc-HUB/refs/heads/main/loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-rails-scripts/",
        slug = "anime-rails-scripts",
        scripts = {
            {
                title = "KEYLESS Anime Rails script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/24H-Anime-Rails-Alpha-THE-ULTIMATE-SCRIPT-FOR-THE-GAME-KEYLESS-81305\"))()",
            },
            {
                title = "Spam All Abilities",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gwnrdt/Games/refs/heads/main/Anime-Rails.lua\"))()",
            },
            {
                title = "Polleser hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Thebestofhack123/2.0/refs/heads/main/Scripts/Loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/loot-up-scripts/",
        slug = "loot-up-scripts",
        scripts = {
            {
                title = "Loot Up script",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GomesPT7/meu-script/refs/heads/main/loot%20up.lua\", true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/one-of-us-scripts/",
        slug = "one-of-us-scripts",
        scripts = {
            {
                title = "One of Us script",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/kKRPNz4Y\"))()",
            },
            {
                title = "Bronk GG hub",
                has_key = true,
                code = "--easy Key here: https://link-hub.net/2645502/y3xztLMSNlW4\n--Discord: https://discord.gg/WZAjCTT7Zx\n\nloadstring(game:HttpGet('https://raw.githubusercontent.com/Bronk-GG/ROBLOX/refs/heads/main/OneofUs/v2.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/knife-arena-scripts/",
        slug = "knife-arena-scripts",
        scripts = {
            {
                title = "KEYLESS Knife Arena script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastefy.app/AFx9dPOv/raw'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/chop-your-tree-scripts/",
        slug = "chop-your-tree-scripts",
        scripts = {
            {
                title = "KEYLESS Chop Your Tree script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/osakaTP2/OsakaTP2/main/TreeV4.0\"))()",
            },
            {
                title = "FARM Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/AYCDU5q3/raw\"))()",
            },
            {
                title = "Chop Tree Auto – by Irfannnnn",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Chop-Your-Tree-Chop-Tree-Auto-by-leet-REMADE-GUI-by-ME-78694\"))()",
            },
            {
                title = "Chop Your Tree script – Open Source",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Chop-Your-Tree-MOBILE-XENO-AUTOCHOP-AUTO-TAP-AUTO-WATER-SPEED-MORE-SOURCE-75599\"))()",
            },
            {
                title = "Overflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://overflow.cx/loader.html\"))()",
            },
            {
                title = "Rich Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/lds1best-boop/SAVE/refs/heads/main/Chop%20Your%20Tree\"))()",
            },
            {
                title = "Johndoues",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/Z2xmPIct/raw\"))()",
            },
            {
                title = "Prime Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/wendigo5414-cmyk/Chop-your-tree-/refs/heads/main/main.lua\", true))()",
            },
            {
                title = "Soronice v4 Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Audinay/JKL1/refs/heads/main/SORONICEv4%20Hub/R.lua\"))();",
            },
            {
                title = "Zon hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://hub.zon.su/loader.lua\"))()",
            },
            {
                title = "Jamg Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jamg26/hub/refs/heads/main/main\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/bomb-chip-scripts/",
        slug = "bomb-chip-scripts",
        scripts = {
            {
                title = "KEYLESS Bomb Chip script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/antontohadenzel49/Bomb-Chip/main/Bomb Chip.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blox-fruits-codes/",
        slug = "blox-fruits-codes",
        scripts = {
        },
    },
    {
        page_url = "https://robscript.com/the-forge-codes/",
        slug = "the-forge-codes",
        scripts = {
        },
    },
    {
        page_url = "https://robscript.com/zombie-rng-scripts/",
        slug = "zombie-rng-scripts",
        scripts = {
            {
                title = "KEYLESS Zombie RNG script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/SurviveWaveZ'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/ground-war-scripts/",
        slug = "ground-war-scripts",
        scripts = {
            {
                title = "KEYLESS Ground War script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/rscripts_obfuscated_ground-war-script-or-eacscripts_1763486752835_PK1orzHbRs.txt\",true))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/coldena/voidhuba/refs/heads/main/voidhubload\",true))()",
            },
            {
                title = "Dendrite CC Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Dendrite-cc/Dendrite.cc/refs/heads/main/Loader\"))()",
            },
            {
                title = "Infalogger",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/infalogger/scripts/refs/heads/main/groundwar.luau\"))()",
            },
            {
                title = "Mikey Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RobloxScriptHub/MikeyHub-V2/main/Loader/Main\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/nft-battle-scripts/",
        slug = "nft-battle-scripts",
        scripts = {
            {
                title = "KEYLESS NFT Battle script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/volmaksDev/My-Scripts/refs/heads/main/nftbattle.lua\"))()",
            },
            {
                title = "KOBEH Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/355bec5d264a23b9ea640e7dc2d44b44d117ec0682f65e395ea4b45486ed72f6/download\"))()",
            },
            {
                title = "ScriptsForDays",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/ScriptsForDays/d1ef567540a598141768d28af425cfc8/raw/011002584947d8474aa1751148e6d7c08d21eaac/NFTBATTLE\"))()",
            },
            {
                title = "Why Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLuaDeveloper/WhyHub/refs/heads/main/Loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-advance-scripts/",
        slug = "anime-advance-scripts",
        scripts = {
            {
                title = "Anime Advance script – (Kaitun Hub)",
                has_key = true,
                code = "-- Join Discord for work: https://discord.gg/kn9MFKgWWX\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/khuyenbd8bb/RobloxKaitun/refs/heads/main/Anime%20Advance%20Simulator.lua\", true))(",
            },
            {
                title = "Moon Hub",
                has_key = true,
                code = "getgenv().SCRIPTKEY = \"\"\n\nloadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/fcef5e88349466d80f524cc610f4695e69e71d6153048167c52c59ea7e7e4167/download\"))()",
            },
            {
                title = "NS hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/ad/refs/heads/main/vance\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/survive-on-raft-scripts/",
        slug = "survive-on-raft-scripts",
        scripts = {
            {
                title = "Survive on Raft script – (Raxx Hub)",
                has_key = false,
                code = "getgenv().Settings = {\n    speedBoost = 23,\n}\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/raxscripts/LuaUscripts/refs/heads/main/SurviveOnARaft.lua\"))()",
            },
            {
                title = "nuarexsc",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8397bb3fc906109fe872edd4463510b30d881e75bdc41acfbd6be6c52f404e44/download\"))()",
            },
            {
                title = "HILENINKRALI",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/J4Xtu0Q8\",true))()",
            },
            {
                title = "Peachy Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/d37435894c260e0200d7c0cee1c5a4aea45602edb3ee1fa3c37726e2fe857ad5/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/garden-incremental-scripts/",
        slug = "garden-incremental-scripts",
        scripts = {
            {
                title = "KEYLESS Garden Incremental script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Hjgyhfyh/Scripts-roblox/refs/heads/main/%5BрџЋѓHALLOWEEN%5D%20Garden%20Incremental.txt'))()",
            },
            {
                title = "Visual Changer Stats",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/luminiarbx/lumi-scripts-public/refs/heads/main/scripts/Garden%20Incremental/Shop%20Visual%20Changer/latest.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/mad-road-scripts/",
        slug = "mad-road-scripts",
        scripts = {
            {
                title = "KEYLESS Mad Road script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Kaitofyp/Mad-Road/refs/heads/main/Protected_1487690414984317.lua.txt\"))()",
            },
            {
                title = "NuarexscDev",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8397bb3fc906109fe872edd4463510b30d881e75bdc41acfbd6be6c52f404e44/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/build-a-mining-machine-scripts/",
        slug = "build-a-mining-machine-scripts",
        scripts = {
            {
                title = "KEYLESS Build a Mining Machine script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/BuildAMiningMachine'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dig-grandmas-backyard-scripts/",
        slug = "dig-grandmas-backyard-scripts",
        scripts = {
            {
                title = "KEYLESS Dig Grandma’s Backyard script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/DigGrandmasBackyard'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/bake-or-die-scripts/",
        slug = "bake-or-die-scripts",
        scripts = {
            {
                title = "KEYLESS Bake Or Die script – (Bebo Mods)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://rawscripts.net/raw/Bake-or-Die-Kill-All-Bring-Items-Esp-etc-68463'))()",
            },
            {
                title = "Srany Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/ea4810920833228224663a55d11fc8f22a9e9cd8d317b4e9ae26142c08cc12c3/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/brainrot-slayers-scripts/",
        slug = "brainrot-slayers-scripts",
        scripts = {
            {
                title = "KEYLESS Brainrot Slayers script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/BrainrotSlayers\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/untitled-boxing-game-scripts/",
        slug = "untitled-boxing-game-scripts",
        scripts = {
            {
                title = "KEYLESS untitled boxing game script – (Mirage Hub)",
                has_key = false,
                code = "-- Join the discord for updates: https://discord.gg/V9kH4GqK8w\n\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/e84aac149960efeddc83453e4a856d9d.lua\"))()",
            },
            {
                title = "Beanz Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/pid4k/scripts/main/BeanzHub.lua\", true))()",
            },
            {
                title = "HILENINKRALI",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastefy.app/KtsF3Wq7/raw'))()",
            },
            {
                title = "Zeke Hub",
                has_key = true,
                code = "script_key=\"keyhere\" -- script can be bought from the website or discord zekehub.com\nloadstring(game:HttpGet(\"https://zekehub.com/scripts/Loader.lua\"))()",
            },
            {
                title = "Siffori Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NysaDanielle/loader/refs/heads/main/auth\"))()",
            },
            {
                title = "GOAT Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/RNhiXimN\"))()",
            },
            {
                title = "Pathos",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/th3-osc/Pathos/main/Pathos%20Key%20System.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blox-fruits-scripts/",
        slug = "blox-fruits-scripts",
        scripts = {
            {
                title = "KEYLESS Cat Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CatsScripts/CatsRobloxScripts/refs/heads/main/loader.luau\"))()",
            },
            {
                title = "Nat Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ArdyBotzz/NatHub/refs/heads/master/bf.lua\"))()",
            },
            {
                title = "Project Fru1t – LazyDevs",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://loader.lazydevs.lol\"))()",
            },
            {
                title = "Quantum Onyx Project",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/flazhy/QuantumOnyx/refs/heads/main/QuantumOnyx.lua\"))()",
            },
            {
                title = "Styxz Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ToshyWare/StyxzHub/main/Styxz.lua\"))()",
            },
            {
                title = "BEST KEYLESS Blox Fruits script – (Speed Hub X)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua\"))()",
            },
            {
                title = "Fast Chest Farm",
                has_key = false,
                code = "getgenv().mmb = {\n    setting = {\n        [\"Select Team\"] = \"Marines\", --// Select Pirates Or Marines\n        [\"TweenSpeed\"] = 200,\n        [\"Standing on the water\"] = true,  --// Standing on the water\n        [\"Remove Notify Game\"] = true, --// Turn off game notifications \n        [\"Rejoin When kicked\"] = true, --// Auto rejoin when you get kicked\n        [\"Anti-Afk\"] = true  --// Anti-AFK\n    },\n    ChestSettings = {\n        [\"Esp Chest\"] = true, --// ESP entire Chest        \n        [\"Start Farm Chest\"] = {\n            [\"Enable\"] = true, --// Turn On Farm Chest \n            [\"lock money\"] = 1000000000, --// Amount of Money To Stop\n            [\"Hop After Collected\"] = \"All\" --// Enter The Number of Chests You Want To Pick Up Like \"Number\" or \"All\"\n        },\n        [\"Stop When Have God's Chalice & Fist Of Darkness\"] = { \n            [\"Enable\"] = true, --// Stop when you have God's Chalice & Fist Of Darkness \n            [\"Automatically move to safety\"] = false --// Auto Move To Safe Place When Have Special Items\n        },\n    },\n    RaceCyborg = {\n        [\"Auto get race Cyborg\"] = false,  --// true If You Want Auto Get Cyborg Race\n        [\"Upgrade Race: V2/V3\"] = false  --// ⭐ New\n    },\n    Webhook = {\n        [\"send Webhook\"] = false, --// Send Webhook Auto Setup\n        [\"Url Webhook\"] = \"\", --// Link Url Webhook\n        [\"UserId\"] = \"\" --// Id Discord You\n    }\n}\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/NaruTeam/Abyss/refs/heads/main/AbyssChest.lua\"))()",
            },
            {
                title = "Vylera Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/VyleraBloxFruit.lua\"))()",
            },
            {
                title = "Blox Fruits script – (Fruit finder)",
                has_key = false,
                code = "_G.CatsFruitFinderV4 = {\n    Notify = true,\n    Webhook = \"Webhook REQUIRED\",\n    Mode = \"Teleport Fruit\", -- \"Teleport Fruit\" or \"Tween Fruit\"\n    AutoStore = true,\n    AutoJoinTeam = true,\n    Team = \"Pirates\", -- team to join\n    FruitList = {\n        \"Mammoth\",\n        \"Buddha\",\n        \"Dough\",\n        \"Leopard\",\n        \"Venom\",\n        \"Dragon\",\n        \"Gravity\",\n        \"Rumble\",\n        \"T-Rex\",\n        \"Control\",\n        \"Spirit\",\n        \"Gas\",\n        \"Shadow\",\n        \"Kitsune\",\n        \"West Dragon\",\n        \"East Dragon\" -- add more here if u want \n    },\n}\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/CatsScripts/CatsRobloxScripts/main/CatsBetterFruitFinder.luau?t=\" .. tick()))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
            {
                title = "Four Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/FHBloxFruits.lua\",true))()",
            },
            {
                title = "Solvex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Solvexxxx/Scripts/refs/heads/main/SolvexGUIBXF.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/99-nights-in-the-forest-scripts/",
        slug = "99-nights-in-the-forest-scripts",
        scripts = {
            {
                title = "KEYLESS 99 Nights in the Forest script – (FAST HUB)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/adibhub1/99-nighit-in-forest/refs/heads/main/99%20night%20in%20forest\"))()",
            },
            {
                title = "NO KEY Bring Items",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Bac0nHck/Scripts/refs/heads/main/bringitems.lua\"))()",
            },
            {
                title = "Vylera",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/99nightsforest.lua\"))()",
            },
            {
                title = "Voidware",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua\", true))()",
            },
            {
                title = "Cobra Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Backwoodsix/Cobra.gg-99-nights-in-the-Forrest-FREE-keyless-/refs/heads/main/.lua\", true))()",
            },
            {
                title = "Four Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/FourHub.lua\"))()",
            },
            {
                title = "Zexx Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zzxzsss/zxz/refs/heads/main/zelx%20x%2099nights\"))()",
            },
            {
                title = "IceWare",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Iceware-RBLX/Roblox/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "SkyArc – AI Auto Play",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://paste.rs/GeAFQ\"))()",
            },
            {
                title = "Sapphire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/KmtjbIBi/raw\", true))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/yoursvexyyy/VEX-OP/refs/heads/main/99%20nights%20in%20the%20forest\"))()",
            },
            {
                title = "Anon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sa435125/AnonHub/refs/heads/main/anonhub.lua\"))();",
            },
            {
                title = "Monkey Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MonkeyV2/loader/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "Starfall hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Severitysvc/Starfall/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "H4xScript hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/H4xScripts/Loader/refs/heads/main/loader.lua\", true))()",
            },
            {
                title = "Overflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OverflowBGSI/Overflow/refs/heads/main/loader.txt\"))()",
            },
            {
                title = "Nexis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/boringcat4646/Nexis-Hub/main/v2\"))()",
            },
            {
                title = "Stellar Universe",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/5eb08ffffc36b5fc8b948351cbe7b0ad.lua\"))()",
            },
            {
                title = "Greatness Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8a746f95472311bfa174697c6c67f8564ffc6deb7df5b19dc15b030a0ced13da/download\"))()",
            },
            {
                title = "BAR1S hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/kudM6uUs/raw\"))()",
            },
            {
                title = "Trixo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(('https://gist.githubusercontent.com/timprime837-sys/37a29b91d3729f93fe7115a6f5e6755c/raw/5bb8ed117bc2fa2a6b7ecddce9832950850e7004/TrixoBeste')))()",
            },
            {
                title = "Frag CC",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GabiPizdosu/MyScripts/refs/heads/main/Loader.lua\",true))()",
            },
            {
                title = "Why Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLuaDeveloper/WhyHub/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "Prestine Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PrestineScripts/Main/refs/heads/main/Loader\"))()",
            },
            {
                title = "Ziaan Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ziaanhub.github.io/main\"))()",
            },
            {
                title = "Toasty Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nouralddin-abdullah/ToastyHub-XD/refs/heads/main/hub-main.lua\"))()",
            },
            {
                title = "Gitan X",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GitanX/G1tan2_ikea/refs/heads/main/GitanX.lua\"))()",
            },
            {
                title = "Gec Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GEC0/gec/main/Gec.Loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/grow-a-garden-scripts/",
        slug = "grow-a-garden-scripts",
        scripts = {
            {
                title = "KEYLESS Grow a Garden script – (Nat Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/GrowaGarden\"))()",
            },
            {
                title = "Mimi Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Jstarzz/Grow-A-Garden/refs/heads/main/source/MimiHub.lua\", true))()",
            },
            {
                title = "Wet Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Night-Hub/WetHubReformed/refs/heads/main/Loadstring\"))()",
            },
            {
                title = "Than Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/thantzy/thanhub/refs/heads/main/thanv1\"))()",
            },
            {
                title = "Tiger X Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/BalintTheDevXBack/Games/refs/heads/main/GrowAGarden\"))()",
            },
            {
                title = "Lumin Hub",
                has_key = true,
                code = "if identifyexecutor and identifyexecutor():lower():find(\"delta\") then\n    loadstring(game:HttpGet(\"https://lumin-hub.lol/deltaloader.lua\", true))()\nelse\n    loadstring(game:HttpGet(\"https://lumin-hub.lol/loader.lua\", true))()\nend",
            },
            {
                title = "Black Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skibidiking123/Fisch1/refs/heads/main/FischMain\"))()",
            },
            {
                title = "ExploitingIsFun hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://cdn.exploitingis.fun/loader', true))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Monkey Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MonkeyV2/loader/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "Starfall Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Severitysvc/Starfall/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "Horizon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Momo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/msami223/Scripts/refs/heads/main/MomoHub%20Auto%20Buy.lua\"))()",
            },
            {
                title = "Why Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLuaDeveloper/WhyHub/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "Solvex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Solvexxxx/Scripts/refs/heads/main/SolvexGUIGAG.lua\"))()",
            },
            {
                title = "Project Infinity X",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Muhammad6196/Project-Infinity-X/refs/heads/main/main.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fish-it-scripts/",
        slug = "fish-it-scripts",
        scripts = {
            {
                title = "KEYLESS Fish It script – (Polluted Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/b9162d4ef4823b2af2f93664cf9ec393.lua\"))()",
            },
            {
                title = "Poop Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sylolua/PoopHub/refs/heads/main/Loader\",true))()",
            },
            {
                title = "Aurora Hex",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JScripter-Lua/Aorora_Hex/refs/heads/main/Fish_It.lua\"))()",
            },
            {
                title = "Sora Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/elainaceles/SoraHub/refs/heads/main/fishhit.lua\"))()",
            },
            {
                title = "Frxser Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/XeFrostz/freetrash/refs/heads/main/Fishit!.lua'))()",
            },
            {
                title = "Four Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/Premium.lua\",true))()",
            },
            {
                title = "Avantrix Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://avantrix.xyz/loader\"))()",
            },
            {
                title = "Cursed Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zxcursedsocute/CursedHub/refs/heads/main/lua\"))()",
            },
            {
                title = "Sakura Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/inosuke-creator/gna-gits/refs/heads/main/loader2.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "AshLabs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=fish-it.lua\", true))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Chiyo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kaisenlmao/loader/refs/heads/main/chiyo.lua\"))()",
            },
            {
                title = "nuarexsc",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8397bb3fc906109fe872edd4463510b30d881e75bdc41acfbd6be6c52f404e44/download\"))()",
            },
            {
                title = "Moon Hub",
                has_key = true,
                code = "script_key=\"YOUR KEY HERE\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/7d013cdc2230fd78880f73ff39370e40.lua\"))()",
            },
            {
                title = "Thunder Hub",
                has_key = true,
                code = "_G.AutoFishing = true\n_G.AutoPerfectCast = true\n_G.AutoSell = true\n_G.EquipBestBait = true\n_G.EquipBestRod = true\n_G.AutoEquipRod = true\n_G.AutoBuyBestBait = true\n_G.AutoBuyBestRod = true\n_G.AutoTP = true\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/NAVAAI098/Thunder-Hub/main/Kaitun.lua\"))()",
            },
            {
                title = "Da7Mu Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/f11dec38be134a051fe3de9538f83997b73cdf03d136c10262e62cfe97673ea6/download\"))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ago106/SpaceHub/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Ather Hub",
                has_key = true,
                code = "script_key = \"Add key here to auto verify\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua\"))()",
            },
            {
                title = "Neox Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hassanxzayn-lua/NEOXHUBMAIN/refs/heads/main/loader\", true))()",
            },
            {
                title = "Astra Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/PiscioDalGinocchio/Astra-Hubs/refs/heads/main/astrahub'))()",
            },
            {
                title = "Ez Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
            {
                title = "Fryzer Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FryzerHub/V/refs/heads/main/MainLoader\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "script_key=\"hKxZOpspagLxeEGwCdXGfSwqoKFEdPgI\";\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/forsaken-scripts/",
        slug = "forsaken-scripts",
        scripts = {
            {
                title = "KEYLESS Forsaken script – (Voidware Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/forsaken.lua\", true))()",
            },
            {
                title = "RX Forsakened",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Redexe19/RXGUIV1/refs/heads/main/RX%20Forsaken/RX_Forsakened\"))()",
            },
            {
                title = "Voidsaken hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/voidsaken-script/Voidsaken-Loader/refs/heads/main/main\"))()",
            },
            {
                title = "ESP Players",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PlutomasterAccount/Forsaken-ESP/refs/heads/main/Forsaken%20ESP%20Plutomaster.lua\"))()",
            },
            {
                title = "Rift Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rifton.top/loader.lua\"))()",
            },
            {
                title = "Sasaken Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ScriptCopilot32/Forsaken/refs/heads/main/Forsakenscript'))()",
            },
            {
                title = "Ringta Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/wefwef127382/forsakenloader.github.io/refs/heads/main/RINGTABUBLIK.lua\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/yoursvexyyy/VEX-OP/refs/heads/main/forsaken%20final\"))()",
            },
            {
                title = "FrostWare Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Snowie3310/Frostware/main/Forsaken.lua\"))()",
            },
            {
                title = "Lumin Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://lumin-hub.lol/loader.lua\",true))()",
            },
            {
                title = "Lazy Devs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://www.lazydevs.site/forsaken.script\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/hunty-zombie-scripts/",
        slug = "hunty-zombie-scripts",
        scripts = {
            {
                title = "KEYLESS Hunty Zombie script – (Polluted Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/7b5caf0fbbd276ba9747f231e47c0b1a.lua\"))()",
            },
            {
                title = "Siffori Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NysaDanielle/loader/refs/heads/main/auth\"))()",
            },
            {
                title = "Nexis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/boringcat4646/Nexis-Hub/refs/heads/main/Key%20System\"))()",
            },
            {
                title = "Astral Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PlayzlxD0tmatter/AstralHub/refs/heads/main/AstralHub\"))()",
            },
            {
                title = "yKCelestial Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Combo Wick Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "script_key = \"PASTEYOURKEYHERE\"\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Chiyo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kaisenlmao/loader/refs/heads/main/chiyo.lua\"))()",
            },
            {
                title = "Xtreme Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://cdn.authguard.org/virtual-file/836c860722ef4f0db67f5fcf21e13b07\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Chito Hub",
                has_key = true,
                code = "script_key=\"YOUR KEY HERE\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/f506b1e1bf8259b8178f83b65751dcf8.lua\"))()",
            },
            {
                title = "Napoleon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/raydjs/napoleonHub/refs/heads/main/src.lua\"))()",
            },
            {
                title = "090 Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/24124s1/loader/refs/heads/main/loader.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/ink-game-scripts/",
        slug = "ink-game-scripts",
        scripts = {
            {
                title = "KEYLESS Ink Game script – (Ringta Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/wefwef127382/inkgames.github.io/refs/heads/main/ringta.lua\"))()",
            },
            {
                title = "Voidware Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/windinkgame.lua\", true))()",
            },
            {
                title = "FrostWare",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Actualmrp/FWInkGame/refs/heads/main/FrostwareInkGameSource.txt\"))()",
            },
            {
                title = "ExploitingIsFun Hub",
                has_key = true,
                code = "-- make sure to put me in AUTO EXECUTE or else the bypass and emulation will NOT work\n\nloadstring(game:HttpGet('https://raw.githubusercontent.com/ExploitingisFUNN/12312312313/refs/heads/main/ushdfyfeuyetwfge3.lua'))() -- the emulation\ntask.wait(10)\nloadstring(game:HttpGet(\"https://cdn.exploitingis.fun/loader\"))()",
            },
            {
                title = "OwlHook hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/0785b4b8f41683be513badd57f6a71c0.lua\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/7d8a2a1a9a562a403b52532e58a14065.lua\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/steal-a-brainrot-scripts/",
        slug = "steal-a-brainrot-scripts",
        scripts = {
            {
                title = "KEYLESS Steal a Brainrot script – (FrostWare Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Jake-Brock/Scripts/main/Fw%20SAB.lua\",true))()",
            },
            {
                title = "Zon Hub – Desync (Anti hit)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://hub.zon.su/loader.lua\"))()",
            },
            {
                title = "Hydra hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fcc63f5f04efa9a6a85d6f16a179b870.lua\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/7d8a2a1a9a562a403b52532e58a14065.lua\"))()",
            },
            {
                title = "Neox Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hassanxzayn-lua/NEOXHUBMAIN/refs/heads/main/StealABrainrot\"))()",
            },
            {
                title = "Overflow Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OverflowBGSI/Overflow/refs/heads/main/loader.txt\"))()",
            },
            {
                title = "Rift Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rifton.top/loader.lua\"))()",
            },
            {
                title = "Moondiety Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/m00ndiety/99-nights-in-the-forest/refs/heads/main/Main\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Pulsar X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "Anon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sa435125/AnonHub/refs/heads/main/anonhub.lua\"))();",
            },
            {
                title = "JonhDoues",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/ksrdeKiK/raw\"))()",
            },
            {
                title = "Gitan X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/fddttttt/GitanX/refs/heads/main/GitanX.lua\"))()",
            },
            {
                title = "ComboChronicles Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Lumin Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://lumin-hub.lol/loader.lua\",true))()",
            },
            {
                title = "Greatness Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://greatnesssloader.vercel.app/api/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/rivals-scripts/",
        slug = "rivals-scripts",
        scripts = {
            {
                title = "KEYLESS Rivals script – (Lemon Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/c8c09494b048a1fc6a4dc43bec1f3713.lua\"))()",
            },
            {
                title = "VyleraScripts",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/vylerarivals.lua\"))()",
            },
            {
                title = "Pxntxrez Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Pxntxrez/NULL/refs/heads/main/obfuscated_script-1753991814596.lua\"))()",
            },
            {
                title = "Kiciahook Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kiciahook/kiciahook/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Duck Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/HexFG/duckhub/refs/heads/main/loader.lua'))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/solixloader/refs/heads/main/solix%20v2%20new%20loader.lua\"))()",
            },
            {
                title = "Nicky-Byte Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nicky-byte/0212hub/refs/heads/main/main.lua\"))()",
            },
            {
                title = "Nova Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vividx07/nova-softworks/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "Z3US Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/main.lua\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
            {
                title = "Zenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/LookP/Roblox/refs/heads/main/ZenithHUB%20%7C%20Rivals\"))()",
            },
            {
                title = "Ekuve Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ekuve/ekuvehub/main/main.lua\"))()",
            },
            {
                title = "Dark Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/25Dark25/Scripts/refs/heads/main/key-script\"))()",
            },
            {
                title = "Instakill hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/jopanegra87dancing/RIVALS/main/main.lua'))()",
            },
            {
                title = "booboo29rampageog",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/booboo29rampageog/RIVALS/main/main.lua'))()",
            },
            {
                title = "Ember Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/scripter66/EmberHub/refs/heads/main/Rivals.lua\"))()",
            },
            {
                title = "AntiGravity hub",
                has_key = true,
                code = "loadstring(game:HttpGet'https://antigravity.wtf/loader.lua')()",
            },
            {
                title = "W1Ite Game hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/W1lteGameYT/W1lteGame-Hub-Best-Rivals-Aimbot-Script-NO-KEY-/refs/heads/main/script\"))()",
            },
            {
                title = "Minirick Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Minirick0-0/MinirickHub/refs/heads/main/RivalsBETA'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-vanguards-scripts/",
        slug = "anime-vanguards-scripts",
        scripts = {
            {
                title = "KEYLESS Anime Vanguards script – (Speed Hub X)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AhmadV99/Script-Games/main/Anime%20Vanguards.lua\"))()",
            },
            {
                title = "NovaPatch Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CHASEAAAA/vanguard/refs/heads/main/.lua\",true))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "Ather Hub",
                has_key = true,
                code = "--DISCORD please join: https://discord.gg/n86w8P8Evx\n-- FOR SOLARA (ADD THIS, it is a safety measure so disable at your own risk): _G.SkipExecutorBypass = true\nscript_key = \"Add key here to auto verify\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua\"))()",
            },
            {
                title = "Godor Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/godor1010/godor/refs/heads/main/_anime_vanguards'))()",
            },
            {
                title = "Nousigi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nousigi.com/loader.lua\"))()",
            },
            {
                title = "Blue Red Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Alexcirer/Alexcirer/refs/heads/main/vs21\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/brainrot-evolution-scripts/",
        slug = "brainrot-evolution-scripts",
        scripts = {
            {
                title = "KEYLESS Brainrot Evolution script – (LDS Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/hUGqeR78'))()",
            },
            {
                title = "Jin Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://jinhub.my.id/scripts/BrainrotEvolution.lua\"))()",
            },
            {
                title = "JuHaNJIhub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/antontohadenzel49/Brainrot-Evolution/main/Brainrot Evolution.lua'))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Banana Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/diepedyt/bui/refs/heads/main/BananaHubLoader.lua\"))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ago106/SpaceHub/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "PulsarX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "Pulse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chavels123/Loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Rinny",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/RINNY-brainrot-evolution/refs/heads/main/RINNY%20brainrot%20evolution\"))()",
            },
            {
                title = "Nexis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/holdergit/Key-System/refs/heads/main/Nexis%20Hub\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/drill-digging-simulator-scripts/",
        slug = "drill-digging-simulator-scripts",
        scripts = {
            {
                title = "KEYLESS Drill Digging Simulator script – (Balta Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Baltazarexe/Drill-Digging-Simulator/main/Drill%20Digging%20Simulator.lua\"))()",
            },
            {
                title = "Drill Loop",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/script321321/scripts/main/125723653259639\"))()",
            },
            {
                title = "Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/DrillDigging\"))()",
            },
            {
                title = "Edit Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/editlt/scriptexploot/refs/heads/main/drill_digging_simulator.lua\"))()",
            },
            {
                title = "Drill Digging Simulator script – Open Source",
                has_key = false,
                code = "--[[\n	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!\n]]\nlocal Players = game:GetService(\"Players\")\nlocal ReplicatedStorage = game:GetService(\"ReplicatedStorage\")\nlocal RunService = game:GetService(\"RunService\")\nlocal Workspace = game:GetService(\"Workspace\")\n\nlocal player = Players.LocalPlayer\nlocal GiveCash = ReplicatedStorage:WaitForChild(\"GiveCash\")\n\nlocal Library = loadstring(Game:HttpGet(\"https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard\"))()\nlocal Window = Library:NewWindow(\"Unknown Hub\")\nlocal Section = Window:NewSection(\"Main\")\n\nlocal cashEnabled = false\nlocal winEnabled = false\n\nlocal RATE = 100\nlocal INTERVAL = 1 / RATE\nlocal cashAcc = 0\nlocal winAcc = 0\n\nlocal TelePart = Workspace\n	:WaitForChild(\"Worlds\")\n	:WaitForChild(\"Dragon\")\n	:WaitForChild(\"EndZone\")\n	:WaitForChild(\"EndCircle\")\n	:WaitForChild(\"Part\")\n\nlocal function equipAllTools()\n	local char = player.Character\n	local backpack = player:FindFirstChild(\"Backpack\")\n	if not char or not backpack then return end\n\n	local hum = char:FindFirstChild(\"Humanoid\")\n	if not hum then return end\n\n	for _, tool in ipairs(backpack:GetChildren()) do\n		if tool:IsA(\"Tool\") then\n			pcall(function()\n				hum:EquipTool(tool)\n			end)\n		end\n	end\nend\n\nlocal function fireAllTools()\n	local char = player.Character\n	if not char then return end\n\n	for _, tool in ipairs(char:GetChildren()) do\n		if tool:IsA(\"Tool\") then\n			pcall(function()\n				GiveCash:FireServer(tool)\n			end)\n		end\n	end\nend\n\nlocal function teleportWin()\n	local char = player.Character\n	if not char then return end\n\n	local hrp = char:FindFirstChild(\"HumanoidRootPart\")\n	local hum = char:FindFirstChild(\"Humanoid\")\n	if not hrp or not hum then return end\n\n	hrp.CFrame = TelePart.CFrame + Vector3.new(0, 3, 0)\n	hum:Move(Vector3.new(0.1, 0, 0), true)\n	hrp.AssemblyLinearVelocity = Vector3.new(0, 6, 0)\nend\n\nRunService.Heartbeat:Connect(function(dt)\n	if cashEnabled then\n		cashAcc += dt\n		while cashAcc >= INTERVAL do\n			cashAcc -= INTERVAL\n			equipAllTools()\n			fireAllTools()\n		end\n	end\n\n	if winEnabled then\n		winAcc += dt\n		while winAcc >= INTERVAL do\n			winAcc -= INTERVAL\n			teleportWin()\n		end\n	end\nend)\n\nSection:CreateToggle(\"Instant Cash\", function(v)\n	cashEnabled = v\nend)\n\nSection:CreateToggle(\"Auto Farm Win\", function(v)\n	winEnabled = v\nend)",
            },
            {
                title = "Digit Hub",
                has_key = false,
                code = "getgenv().AutoGetCash = true\ngetgenv().AutoGotoWin = true\ngetgenv().AutoBuyDrill = true\ngetgenv().AutoBuyPets = false -- very laggy and constantly tries to buy every pet egg\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/sulfu3r/Newer-Pentest-Projects/refs/heads/main/Shit%20Fun%20Projects/Drill%20Digging%20Simulator.luau\"))()",
            },
            {
                title = "PineCodeReborn",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Veyronxs/Drill-Digging-Simulator/refs/heads/main/Keyless\"))()",
            },
            {
                title = "Salvatore hub",
                has_key = false,
                code = "getgenv().AutoGetCash = true\ngetgenv().AutoGotoWin = true\ngetgenv().AutoBuyDrill = true\ngetgenv().AutoBuyPets = false -- very laggy and constantly tries to buy every pet egg\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/sulfu3r/Newer-Pentest-Projects/refs/heads/main/Shit%20Fun%20Projects/Drill%20Digging%20Simulator.luau\"))()",
            },
            {
                title = "Polleser Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Thebestofhack123/2.0/refs/heads/main/Scripts/DDS\", true))()",
            },
            {
                title = "Lumin Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://lumin-hub.lol/loader.lua\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/build-a-zoo-scripts/",
        slug = "build-a-zoo-scripts",
        scripts = {
            {
                title = "KEYLESS Build a Zoo script – (Elite Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/d787e0d3415663864c515bc513ed4637.lua\"))()",
            },
            {
                title = "Twvz Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZhangJunZ84/twvz/refs/heads/main/buildazoo.lua\"))()",
            },
            {
                title = "Zebux Hub",
                has_key = true,
                code = "-- https://discord.gg/ceAb3N7j5n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZebuxHub/Main/refs/heads/main/BuildAZoo.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Salvatore hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "DoDo hub",
                has_key = true,
                code = "script_key=\"put key here\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/a05bf6f6f0615db868a8d25c1f1c67b2.lua\"))()",
            },
            {
                title = "Venuz Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2Kotaro/Venuz-hub/main/Loader.lua'))()",
            },
            {
                title = "Demi Godz Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/4e4eb2403829fcabbc0c14f7dc3657d3.lua\"))()",
            },
            {
                title = "Celestine Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CelestineHub/C-Hub/refs/heads/main/BuildAZoo.lua\"))()",
            },
            {
                title = "Swag Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/IcantAffordSynapse/swaghub/refs/heads/main/swagmain.lua\"))()",
            },
            {
                title = "Peanut X",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TokyoYoo/gga2/refs/heads/main/Trst.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/build-ur-base-scripts/",
        slug = "build-ur-base-scripts",
        scripts = {
            {
                title = "KEYLESS Build ur Base script – (Auto Buy)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/user75335836/5f8292a553251dae4bd4276e9e7c79bb/raw/431f3225312f0f116f8722c16df0d6f791f2b295/gistfile1.txt\"))()",
            },
            {
                title = "Eco Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Ecohub-1/Ecohub-1/refs/heads/main/bab.lua\"))()",
            },
            {
                title = "Polluted Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/0f8751b134191b33890f77ac3be49dbc.lua\"))()",
            },
            {
                title = "Circus Auto Menu",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/duydai458/Build-ur-base/refs/heads/main/V1%20event\"))()",
            },
            {
                title = "ApocScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/B0QI1FIJ/raw\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Pulse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chavels123/Loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "EZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/coldena/voidhuba/refs/heads/main/voidhubload\",true))()",
            },
            {
                title = "Revenge hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/84ce633323527c6f8da9b8d37cbd11cc58251c5cbc284fd1af22a8c39c4cb1cd/download\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/make-a-army-scripts/",
        slug = "make-a-army-scripts",
        scripts = {
            {
                title = "KEYLESS Make a Army script – (INF money)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/MakeaArmy\"))()",
            },
            {
                title = "MB Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Matej1912/Make-a-Army-/refs/heads/main/Script\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/cut-trees-scripts/",
        slug = "cut-trees-scripts",
        scripts = {
            {
                title = "Cut Trees script – (Vikai Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vinxonez/ViKai-HUB/refs/heads/main/cuttrees\"))()",
            },
            {
                title = "Auto-Loot Chest Farm",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/blegbot1/-AutoFarm_CutTREES/refs/heads/main/auto%20farm%20v1'))()",
            },
            {
                title = "Pupsik Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/5aGYQ8VW\"))()",
            },
            {
                title = "ApocScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/uTS1ip5a/raw\"))()",
            },
            {
                title = "Lucky Winner hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MortyMo22/roblox-scripts/refs/heads/main/Cut%20Trees.lua\"))()",
            },
            {
                title = "INF Money",
                has_key = true,
                code = "script_key=\"yourkey\";\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/ArceusXArchivezx/Game/refs/heads/main/ArceusXArchive\"))()",
            },
            {
                title = "Konglomerate Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Konglomerate/Script/Main/Loader\"))()",
            },
            {
                title = "Wic1k Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Wic1k/Scripts/refs/heads/main/CutTrees.txt\"))()",
            },
            {
                title = "Rax Scripts",
                has_key = true,
                code = "getgenv().Settings = {\n	chopFrequency = 1.3, -- how long to wait for every tree to get chopped, make the time a little higher if lag is experienced.\n	chestESP = true,\n	autoCollectChests = true,\n    speedboost = 33,\n    jumpboost = 10,\n}\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/raxscripts/LuaUscripts/refs/heads/main/CutTrees.lua\"))()",
            },
            {
                title = "Ash Labs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=cut-tree.lua\", true))()	chopFrequency = 1.3, -- how long to wait for every tree to get chopped, make the time a little higher if lag is experienced.\n	chestESP = true,\n	autoCollectChests = true,\n    speedboost = 33,\n    jumpboost = 10,\n}\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/raxscripts/LuaUscripts/refs/heads/main/CutTrees.lua\"))()",
            },
            {
                title = "Why Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLuaDeveloper/WhyHub/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "ATG Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/cut-tree.lua\"))()",
            },
            {
                title = "Anubis",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/biokiller59/CutTrees/refs/heads/main/Trees.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/realistic-street-soccer-scripts/",
        slug = "realistic-street-soccer-scripts",
        scripts = {
            {
                title = "Realistic Street Soccer script – (Verbal hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VerbalHubz/Verbal-Hub/refs/heads/main/Realistic%20Street%20Soccer%20Op%20Script\",true))()",
            },
            {
                title = "CatHook",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZfpsGT1030/RealisticStreetSoccer/refs/heads/main/orbit167_69325\"))()",
            },
            {
                title = "Flash Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Gandalf312/RSS/refs/heads/main/RSS'))()",
            },
            {
                title = "971 Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/971amer7514/971/refs/heads/main/Realistic%20Street%20Soccer'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/case-paradise-scripts/",
        slug = "case-paradise-scripts",
        scripts = {
            {
                title = "KEYLESS Case Paradise script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/MQjidpK5/raw\"))()",
            },
            {
                title = "Money viewer in the head",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/iSxbeY7t/raw\"))()",
            },
            {
                title = "Full Auto Quests",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/3887467307793d650e41fc6fb2ea3e931ed330c6c5421503eeb95b4e7b533489/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fish-me-scripts/",
        slug = "fish-me-scripts",
        scripts = {
            {
                title = "KEYLESS Fish Me script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Cuhila/FishMe/refs/heads/main/FishMeSecret.lua'))()",
            },
            {
                title = "Mizukage",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gilangirchas/DB-discord-/refs/heads/main/Mizukage.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/slap-scripts/",
        slug = "slap-scripts",
        scripts = {
            {
                title = "KEYLESS Slap script – (Auto Parry)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GithubMagical/Slap-Auto-Parry/refs/heads/main/lua\", true))()",
            },
            {
                title = "Siff Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NysaDanielle/loader/refs/heads/main/auth\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/spear-fishing-scripts/",
        slug = "spear-fishing-scripts",
        scripts = {
            {
                title = "KEYLESS Spear Fishing script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/idixof-eng/forkthefish/refs/heads/main/.lua\"))()",
            },
            {
                title = "Jumal Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JumaNexus/Spear-Fishing/refs/heads/main/main.lua\"))()",
            },
            {
                title = "VibeCoding Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/SRkLx5hN'))()",
            },
            {
                title = "OP!UM Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/ce8ce4880452e53b2e5f770714dffacf.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/drill-block-simulator-scripts/",
        slug = "drill-block-simulator-scripts",
        scripts = {
            {
                title = "KEYLESS Drill Block Simulator script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/DrillBlockSimulator\"))()",
            },
            {
                title = "Combo Wick",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ\"))();",
            },
        },
    },
    {
        page_url = "https://robscript.com/brainrot-jumping-scripts/",
        slug = "brainrot-jumping-scripts",
        scripts = {
            {
                title = "KEYLESS Brainrot Jumping script – (Dinas Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Vovabro46/guard/refs/heads/main/Fuckgame\"))()",
            },
            {
                title = "1# INF Money – Open Source",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GomesPT7/brainrot/refs/heads/main/vv1\"))()",
            },
            {
                title = "2# INF Money – Open Source",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/SBCMRg7h\"))()",
            },
            {
                title = "KamScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EnesKam21/Brainrotjumping/refs/heads/main/brainrotjump.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/miami-streets-scripts/",
        slug = "miami-streets-scripts",
        scripts = {
            {
                title = "KEYLESS Miami Streets script – (Cobra GG)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Cobragg/ForknSpoon/refs/heads/main/Cheese.lua\"))()",
            },
            {
                title = "Chips Autofarm",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/T4Y2hs4B\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/peroxide-scripts/",
        slug = "peroxide-scripts",
        scripts = {
            {
                title = "KEYLESS Peroxide script – (UsedHuzuni Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kiwixcheat/000x999/refs/heads/main/KiwiX%20Hub%20X%20Solara%20.lua\", true))()",
            },
            {
                title = "Project Velvet",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Artem1093z/ScriptsGo/refs/heads/main/Peroxide\"))()",
            },
            {
                title = "Blydy Net",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/jjjjzjzjzzkk/main/refs/heads/main/loader.lua'))()",
            },
            {
                title = "Nythera V3",
                has_key = true,
                code = "loadstring(\n    game:HttpGet(\n        'https://raw.githubusercontent.com/Sicalelak/Sicalelak/refs/heads/main/Peroxide'\n    )\n)()",
            },
        },
    },
    {
        page_url = "https://robscript.com/bedwars-scripts/",
        slug = "bedwars-scripts",
        scripts = {
            {
                title = "KEYLESS BedWars script – (Lover lua)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/sstvskids/lover.lua/refs/heads/main/installer.lua', true))()",
            },
            {
                title = "VoidWare",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VapeVoidware/vapevoidware/main/NewMainScript.lua\", true))()",
            },
            {
                title = "Cat Vape v5",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/new-qwertyui/CatV5/refs/heads/main/init.lua'), 'init.lua')()",
            },
            {
                title = "Cloudware v2",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CloudwareV2/CloudWare-loadstringloadstring/refs/heads/main/mobileinit.lua\"))()",
            },
            {
                title = "AnimeWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KAJUU490/b4/refs/heads/main/summer_kaju\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/bubble-gum-simulator-infinity-scripts/",
        slug = "bubble-gum-simulator-infinity-scripts",
        scripts = {
            {
                title = "KEYLESS Bubble Gum Simulator INFINITY script – (Astra HUB – PC)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ASUJIFVsadvf/sigma/refs/heads/main/AstraBgsi\",true))()",
            },
            {
                title = "Astra HUB – Mobile",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ASUJIFVsadvf/sigma/refs/heads/main/mobile\",true))()",
            },
            {
                title = "LDS Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/49f02b0d8c1f60207c84ae76e12abc1e.lua'))()\nwhile task.wait(0.1) do\n    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)\n    task.wait() \n    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)\nend",
            },
            {
                title = "Shovel PROD",
                has_key = false,
                code = "local ld = loadstring or load\nlocal url = \"https://raw.githubusercontent.com/shvl00/shvled/refs/heads/main/l04d3r.bf\"\n\nld(game:HttpGet(url))()",
            },
            {
                title = "Smoke Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/etqjuyreal/smoke/refs/heads/main/bgsi.lua'))()",
            },
            {
                title = "Open Source BGSI script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/flamedev0/scripts/refs/heads/main/BGSI_os.lua\",true))()",
            },
            {
                title = "Ather Hub",
                has_key = true,
                code = "--Discord: https://discord.gg/x4ux7pUVJu\nscript_key = \"Add key here to auto verify\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua\"))()",
            },
            {
                title = "BCSI Christmas Event",
                has_key = true,
                code = "loadstring(game:HttpGet(('https://raw.githubusercontent.com/bright696/BGSIautotot/refs/heads/main/BGSIautotot.lua')))()",
            },
            {
                title = "Gandalf Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Gandalf312/BGSI/refs/heads/main/Loader'))()",
            },
            {
                title = "Overflow Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://overflow.cx/loader.html\"))()",
            },
            {
                title = "Smorgs Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MIKEDRIPZOWSKU/test/refs/heads/main/SmorgsHubBGSI.lua\", true))()",
            },
            {
                title = "0ne Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Discord0000/dontknow/refs/heads/main/Bubble%20Gum%20INFINITY/main.lua\"))()",
            },
            {
                title = "Space hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ago106/SpaceHub/refs/heads/main/Multi'))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/solixloader/refs/heads/main/solix%20v2%20new%20loader.lua\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/be/refs/heads/main/u\"))()",
            },
            {
                title = "NOSIGI hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nousigi.com/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/button-eternal-scripts/",
        slug = "button-eternal-scripts",
        scripts = {
            {
                title = "KEYLESS Button Eternal script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/lds1best-boop/SAVE/refs/heads/main/Who%20iam%3F\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/baboon-tag-x-scripts/",
        slug = "baboon-tag-x-scripts",
        scripts = {
            {
                title = "KEYLESS Baboon Tag X script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://rawscripts.net/raw/Baboon-Tag-X-Op-AutoFarm-Baboons-74369'))()",
            },
            {
                title = "Frannn",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/decentholograms/Roblox-Scripts/refs/heads/main/Scripts/BaBoonTagX\"))()",
            },
            {
                title = "ricxr hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RxcardDev/Roblox1/refs/heads/main/Script\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/tap-simulator-scripts/",
        slug = "tap-simulator-scripts",
        scripts = {
            {
                title = "KEYLESS Tap Simulator script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/bN3oTLuE/raw\"))()",
            },
            {
                title = "Ducky Scripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bigbeanscripts/TapSim/refs/heads/main/Main\"))()",
            },
            {
                title = "PusarX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "Intruders Hub",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/lifaiossama/errors/main/Intruders.html\")()",
            },
            {
                title = "Zenk Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://paste-webside.pages.dev/raw/ZenkOnTop\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/scroll-a-brainrot-scripts/",
        slug = "scroll-a-brainrot-scripts",
        scripts = {
            {
                title = "Scroll a Brainrot script – (Alternative Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/A1ternative-hub/script/refs/heads/main/tu'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/catch-and-tame-scripts/",
        slug = "catch-and-tame-scripts",
        scripts = {
            {
                title = "KEYLESS Catch And Tame script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/CatchAndTame\"))()",
            },
            {
                title = "Konglomerate Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Konglomerate/Script/Main/Loader\"))()",
            },
            {
                title = "KamScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EnesKam21/seneryolar/refs/heads/main/catchandtame.txt\"))()",
            },
            {
                title = "Nuarexsc",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8397bb3fc906109fe872edd4463510b30d881e75bdc41acfbd6be6c52f404e44/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/super-soldiers-scripts/",
        slug = "super-soldiers-scripts",
        scripts = {
            {
                title = "Super Soldiers script",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NatsumeMikuX/SuperSoldiers/refs/heads/main/main.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/immortal-cultivation-scripts/",
        slug = "immortal-cultivation-scripts",
        scripts = {
            {
                title = "KEYLESS Immortal Cultivation script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://rawscripts.net/raw/NEW-Immortal-Cultivation-Request-Script-71999'))()",
            },
            {
                title = "Techniques",
                has_key = false,
                code = "loadstring(game:HttpGet('https://rawscripts.net/raw/Immortal-Cultivation-got-bored-73303'))()",
            },
            {
                title = "Vichian Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/de2294cd9ea87fe860be7dba73e3d84c232fe8722ebba963c8bc13583cf6fcd9/download\"))()",
            },
            {
                title = "StarStream hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub\"))()",
            },
            {
                title = "Disabled Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CEN-Isme/DISABLEDHUB/refs/heads/main/main.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/build-a-store-scripts/",
        slug = "build-a-store-scripts",
        scripts = {
            {
                title = "KEYLESS Build a Store script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/BuildaStore'))()",
            },
            {
                title = "Open Sourced",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ovoch228/opensourcedscripts/refs/heads/main/buildastore\"))()",
            },
            {
                title = "IND Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Enzo-YTscript/IND-Hub/main/Loader.lua\"))()",
            },
            {
                title = "Royalthess Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/Z4QqsLj9\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/hard-time-scripts/",
        slug = "hard-time-scripts",
        scripts = {
            {
                title = "KEYLESS Hard Time script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/thewiiufan/b6138f1f74b0e6b5b5266d6ed9697878/raw/83459524aeb4104df16710ed0e13724cf953dc90/htsimpleautofarm\"))()",
            },
            {
                title = "Kanto Hub",
                has_key = false,
                code = "-- Kanto ; https://discord.gg/5Zcq8FayRA (join to get notified of updates, etc.)\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/dankiful/kanto/main/main.lua\"))();",
            },
            {
                title = "thewiiufan",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/thewiiufan/cef281e8393ec39f2ac9799f1c883914/raw/02d0920ff0dbf3f9bfafa07b960d5341fb2f50fc/assassinguiv1.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/crashouts-scripts/",
        slug = "crashouts-scripts",
        scripts = {
            {
                title = "KEYLESS Crashouts script – (Covet Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/3fa95877ff1aa80464a6941eb2e0f2f5.lua\"))()",
            },
            {
                title = "AR Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ARA8TW/Scripts/refs/heads/main/PVP-ARHUB\"))()",
            },
            {
                title = "A7xDev",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/40YJcHu4\"))()",
            },
            {
                title = "SaSware",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/centerepic/sasware/refs/heads/main/games/Crashouts/main.luau\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/universal-tower-defense-scripts/",
        slug = "universal-tower-defense-scripts",
        scripts = {
            {
                title = "KEYLESS Universal Tower Defense script",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ApelsinkaFr/ApelHub/refs/heads/main/ApelHub\"))()",
            },
            {
                title = "Lune Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/myrelune/luneLoader/refs/heads/main/utdLoader\"))()",
            },
            {
                title = "LixHub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader\"))()",
            },
            {
                title = "Grogster Hub",
                has_key = true,
                code = "https://discord.gg/vxWWF7Pe - For Script issues and recommendations\n\nloadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/39cf67ac94608d1c2734b8a4eadf76dd56055814ef8ef7ce76c311b02df87611/download\"))()",
            },
            {
                title = "Rollback your traits and stats",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.jnkie.com/api/v1/luascripts/public/001cce25ef51a49a0dbe80b99ee7f1d1f9e355b847b6357261033b3b4ea8758a/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/catch-a-monster-scripts/",
        slug = "catch-a-monster-scripts",
        scripts = {
            {
                title = "KEYLESS Catch a Monster script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/CatchaMonster'))()",
            },
            {
                title = "VibeCoding",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/E33yFd5w'))()",
            },
            {
                title = "NatsuHX",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NatsumeMikuX/CatchaMonster/refs/heads/main/Main.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blox-life-scripts/",
        slug = "blox-life-scripts",
        scripts = {
            {
                title = "KEYLESS Blox Life script – (Kali Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/uej2/ahhhhh/refs/heads/main/bloxlife.lua\"))()",
            },
            {
                title = "RBX Hook CC",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rbxhook.cc/LINE/bloxlife.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/rescue-animals-scripts/",
        slug = "rescue-animals-scripts",
        scripts = {
            {
                title = "KEYLESS Rescue Animals script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/RescueAnimals\"))()",
            },
            {
                title = "ValenHallow Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ValenHallow2/RescuePet/refs/heads/main/RescuePets\"))()",
            },
            {
                title = "goofyahhdudethe2nd",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/019dc21adf055d6fbf970f02203d62bd62fd4612261daef448e673e043b9a8b1/download\"))()",
            },
            {
                title = "SoftKillz",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/10fc7200dd134ce3cca42f3a031db69bbf16a90e5f144e4db6e7cab31b3ab1c3/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/boxing-battles-scripts/",
        slug = "boxing-battles-scripts",
        scripts = {
            {
                title = "KEYLESS Boxing Battles script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/BoxingBattles'))()",
            },
            {
                title = "807S hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/807dc/BoxingBattles/refs/heads/main/Boxing%20Battles\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/plant-evolution-scripts/",
        slug = "plant-evolution-scripts",
        scripts = {
            {
                title = "KEYLESS Plant Evolution script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/PlantEvolution'))()",
            },
            {
                title = "JUANKO MODS YT",
                has_key = false,
                code = "-- PvZ HUB\n-- Plantas Evolution\n-- JUANKO MODS YT \n\n\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Juanko-Scripts/Roblox-scripts/refs/heads/main/yPvZ%20HUB.txt\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/color-game-scripts/",
        slug = "color-game-scripts",
        scripts = {
            {
                title = "KEYLESS Color Game script – (fetchable)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ScriptRbx/ColorGame/refs/heads/main/real2.lua\"))()",
            },
            {
                title = "Libware hub",
                has_key = false,
                code = "loadstring(\n	game:HttpGet(\n		'https://raw.githubusercontent.com/DozeIsOkLol/LibWare/refs/heads/main/LibWareLoader.lua'\n	)\n)()",
            },
            {
                title = "Raxx scripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/raxscripts/LuaUscripts/refs/heads/main/ColorGameINF.lua\"))()",
            },
            {
                title = "Combo Wick",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
        },
    },
    {
        page_url = "https://robscript.com/classic-airplane-wars-scripts/",
        slug = "classic-airplane-wars-scripts",
        scripts = {
            {
                title = "KEYLESS Classic Airplane Wars script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KGuestCheatsJ2/Sc/refs/heads/main/CAPW\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/lift-everything-scripts/",
        slug = "lift-everything-scripts",
        scripts = {
            {
                title = "KEYLESS Lift Everything script – (Tora IsMe)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/LiftEverything'))()",
            },
            {
                title = "Danangori",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/danangori/LifeEverything/refs/heads/main/Ui\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/crash-bots-scripts/",
        slug = "crash-bots-scripts",
        scripts = {
            {
                title = "KEYLESS Crash Bots script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/CrashBots'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/strongman-simulator-scripts/",
        slug = "strongman-simulator-scripts",
        scripts = {
            {
                title = "KEYLESS Strongman Simulator script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/StrongmanSim\"))()",
            },
            {
                title = "Zezor Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zezor-scripts/no-wonder/refs/heads/main/Main.lua%20lover\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/peak-evolution-scripts/",
        slug = "peak-evolution-scripts",
        scripts = {
            {
                title = "KEYLESS Peak Evolution script",
                has_key = false,
                code = "--!strict\nlocal SCRIPT_VERSION = \"0.0.1\"\nlocal LIBRARY_ID = \"pe_pubmain\"\nlocal GAME_NAME = \"Peak Evolution\"\n-- local LOGS_FILE = `{GAME_NAME} Public Main.txt`\n-- writefile(LOGS_FILE, \"\")\nif getgenv()[LIBRARY_ID] then\n	pcall(function()\n		getgenv()[LIBRARY_ID]:Destroy()\n	end)\nend\n\nlocal players = game:GetService(\"Players\")\nlocal local_player = players.LocalPlayer\nlocal object_list\nlocal lp_object\n\nfor _, stage in getgc(true) do\n	if typeof(stage) ~= \"table\" or not rawget(stage, \"PlayerAttack\") then\n		continue\n	end\n	local instance_manager = getupvalue(stage.PlayerAttack, 1)\n	object_list = getupvalue(instance_manager.FindObject, 1)\n	lp_object = object_list[local_player]\nend\n\nlocal function load_url<A..., R...>(url: string): (A...) -> R...\n	local Callback, Error = loadstring(game:HttpGet(url))\n	if Error then\n		return error(Error, 2)\n	end\n	return (Callback :: any) :: (A...) -> R...\nend\nlocal empty_callback = function() end\n\nlocal library: AnkaUi = load_url(\"https://raw.githubusercontent.com/nfpw/XXSCRIPT/refs/heads/main/Library/Module.lua\")()\ngetgenv()[LIBRARY_ID] = library\nlocal window = library:CreateWindow({\n	WindowName = `Public Main {GAME_NAME} v{SCRIPT_VERSION}`,\n}, gethui())\n\nlocal main_tab = window:CreateTab(\"main\")\nlocal main_section = main_tab:CreateSection(\"main\")\nlocal stage = main_section:CreateDropdown(\n	\"stage\",\n	(function()\n		local out = workspace.Stage:GetChildren()\n		for k, v in out do\n			out[k] = v.Name\n		end\n		return out\n	end)(),\n	empty_callback,\n	workspace.Stage:GetChildren()[1].Name\n)\nlocal auto_farm = main_section:CreateToggle(\"auto farm\", false, empty_callback)\nlocal auto_farm_thread = task.spawn(function()\n	while task.wait() do\n		if not auto_farm:GetState() then\n			continue\n		end\n		local original = local_player.Character:GetPivot()\n		for _, monster in workspace.Stage[stage:GetOption()].monster:GetChildren() do\n			local monster_object = object_list[monster]\n			if not monster_object then\n				continue\n			end\n			local_player.Character:PivotTo(monster:GetPivot())\n			lp_object.sync_cmp:Add(\"player_attack_monster\", {\n				[\"player_guid\"] = lp_object.guid,\n				[\"monster_guid\"] = monster_object.guid,\n				[\"stage_id\"] = tonumber(stage:GetOption():gsub(\"stage\", \"\"), 10),\n			})\n			task.wait()\n		end\n		local_player.Character:PivotTo(original)\n	end\nend)\nmain_section:CreateButton(\"unload script\", function()\n	library:Destroy()\nend)\n\nlocal old = library.Destroy\nlibrary.Destroy = function(...)\n	task.cancel(auto_farm_thread)\n	return old(...)\nend\n\nif not lp_object then\n	return window:Notify(\"Script patched\", \"failed to get LocalPlayer data\")\nend",
            },
            {
                title = "Tora Is Me",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/PeakEvolution\"))()",
            },
            {
                title = "Kaitun Hub",
                has_key = false,
                code = "_G.Key = \"\" -- Get key --> Join Discord: https://discord.gg/kn9MFKgWWX\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/khuyenbd8bb/RobloxKaitun/refs/heads/main/Peak%20Evolution.lua\", true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/draw-me-scripts/",
        slug = "draw-me-scripts",
        scripts = {
            {
                title = "Draw Me script – (Lownas)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/3387bc2c06c6ab7e0606178d675e0ad46b29427c6a1f81e96a4c9d7a090eb68e/download\"))()",
            },
            {
                title = "Ancestrychanged",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://ancestrychanged.fun/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fruit-battlegrounds-scripts/",
        slug = "fruit-battlegrounds-scripts",
        scripts = {
            {
                title = "Fruit Battlegrounds script – (Xenith Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Qwenzy Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mrqwenzy/QWENZY_HUB/refs/heads/main/FruitBattlegrounds\"))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/064defa844d413e44319b04631c36357.lua\"))()",
            },
            {
                title = "Ice Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/IceDudez/TheIceCrew/refs/heads/main/Fruit%20Battlegrounds\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/meobeo8/a/a/a\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/unboxing-rng-scripts/",
        slug = "unboxing-rng-scripts",
        scripts = {
            {
                title = "Orbital",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/6434210aec8c6ab9bade380201c60daa6a4f105cf9a34ef6e22fd67115649da3/download\"))()",
            },
            {
                title = "Standart Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EnxivityYZX/Unboxing-Rng/367f85d822579cacdb5e9f4984508e775209dddc/Unboxing%20rng.lua\", true))()",
            },
            {
                title = "KOBEH hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/7ace980ea59881722bd6e806f23893c3525d558f9d2610e6b2fef3e8cfcc2c09/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/drive-world-scripts/",
        slug = "drive-world-scripts",
        scripts = {
            {
                title = "KEYLESS Drive World script – (Science cc)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/6RiJFRnc\"))()",
            },
            {
                title = "LeadMarker",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/LeadMarker/opensrc/main/Drive%20World/autofarm.lua'))()",
            },
            {
                title = "WiglyWare",
                has_key = false,
                code = "loadstring(game:HttpGet('https://gist.githubusercontent.com/broreallyplayingthisgame/bd9ba97100ede3afd0a52d4478e7bc92/raw/'))()",
            },
            {
                title = "Feather hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/feather-hub-or-auto-farm-or-keyless_1764614912884_qpzPpkmf1C.txt\",true))()",
            },
            {
                title = "Pepper hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/wsN67tAW/raw\"))()",
            },
            {
                title = "Fifteen Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fb040a626b795e0847ace2b53680052a.lua\"))()",
            },
            {
                title = "Apoc hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ApocHub/ApocHub/refs/heads/main/ApocHubMain\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/trident-survival-scripts/",
        slug = "trident-survival-scripts",
        scripts = {
            {
                title = "Trident Survival script – (Heaven V5 hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/fd97ed92f5599079021cb6cf381eecdc134163f7259587d4ba0fd35a789071dd/download\"))()",
            },
            {
                title = "Nova OPS",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TootWixx/Trident-Free-V.1.1/refs/heads/main/obfuscated_script-1765271668873.lua\"))()",
            },
            {
                title = "Magic Bullet",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hp6x/TridentSurvScriptbyhp6x/refs/heads/main/KeySystembyhp6x(TS)2.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Radium CC",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/48kk/Load/refs/heads/main/Main.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blockermans-minesweeper-scripts/",
        slug = "blockermans-minesweeper-scripts",
        scripts = {
            {
                title = "KEYLESS blockerman’s Minesweeper script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zadei/blockermanminesweeperscript/refs/heads/main/ms_script.lua\",true))()",
            },
            {
                title = "NovaSweep",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zadei/blockermanminesweeperscript/refs/heads/main/ms_script.lua\",true))()",
            },
            {
                title = "W3nted-Luau",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/W3nted-Luau/blockerman/refs/heads/main/blockerman.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/defuse-division-scripts/",
        slug = "defuse-division-scripts",
        scripts = {
            {
                title = "KEYLESS Defuse Division script – (EXPECTIONAL)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://expectional.dev/loadstring/Defuse-Division.lua\"))()",
            },
            {
                title = "Skin Changer",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://expectional.dev/loadstring/Defuse-Division-Skinchanger.lua\"))()",
            },
            {
                title = "2pacalypse",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/getallthreads/2pac/refs/heads/main/2pacalypse.luau\"))()",
            },
            {
                title = "Glitch Hub",
                has_key = true,
                code = "loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/AsyncAdmin/source/refs/heads/main/glitchhub'))()",
            },
            {
                title = "Greatnesss Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://greatnesssloader.vercel.app/api/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dandys-world-scripts/",
        slug = "dandys-world-scripts",
        scripts = {
            {
                title = "KEYLESS Dandy’s World script – (by Hex233222)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/H3u62n7D\"))()",
            },
            {
                title = "Noxious Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Boxten-Keyes/box-01/refs/heads/main/box%23%5Bboxten%20sex%20gui%5D/box%23%5Bmain%5D.lua'))()",
            },
            {
                title = "Yoxi Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Yomkaa/YOXI-HUB/refs/heads/main/loader\",true))()",
            },
            {
                title = "Hex Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/randomaccve/dandy-world/refs/heads/main/hex%20hub\"))()",
            },
            {
                title = "Bobby hub (KEY: YES)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/BobJunior1/Sup/refs/heads/main/Bobhub\"))()",
            },
            {
                title = "Johndoeee",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/JakeyJak/scripts/main/DandyWorld.lua'))();",
            },
            {
                title = "Maybepiet hub – Alina World",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/Y7uh3UZf\"))();",
            },
            {
                title = "BaconHack",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Bac0nHck/Scripts/main/Dandy's%20World\"))(\"t.me/arceusxscripts\")",
            },
            {
                title = "Pleiadex hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Dandy's-World-ALPHA-Auto-Skillcheck-And-More-58732\"))()",
            },
            {
                title = "deposible",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/deposible/deposible.github.io/refs/heads/main/Dandys%20World.lua\"))()",
            },
            {
                title = "Project Stark",
                has_key = true,
                code = "--[[\n  ____               _              _     ____   _                _    \n |  _ \\  _ __  ___  (_)  ___   ___ | |_  / ___| | |_  __ _  _ __ | | __\n | |_) || '__|/ _ \\ | | / _ \\ / __|| __| \\___ \\ | __|/ _` || '__|| |/ /\n |  __/ | |  | (_) || ||  __/| (__ | |_   ___) || |_| (_| || |   |   < \n |_|    |_|   \\___/_/ | \\___| \\___| \\__| |____/  \\__|\\__,_||_|   |_|\\_\\\n                  |__/                                                                               \n]]\n\nlocal __ = {\n    ['\\242'] = function(x) return loadstring(game:HttpGet(x))() end,\n    ['\\173'] = function(q)\n        local o, l = {}, 1\n        for i in q:gmatch('%d+') do\n            o[l], l = string.char(i + 0), l + 1\n        end\n        return table.concat(o)\n    end,\n    ['\\192'] = '104 116 116 112 115 58 47 47 114 97 119 46 103 105 116 104 117 98 117 115 101 114 99 111 110 116 101 110 116 46 99 111 109 47 85 114 98 97 110 115 116 111 114 109 109 47 80 114 111 106 101 99 116 45 83 116 97 114 107 47 109 97 105 110 47 77 97 105 110 46 108 117 97',\n    ['\\111'] = function(...)\n        local a = {...}\n        return a[1](a[2](a[3]))\n    end,\n    ['\\255'] = '\\242\\173\\192'\n}\n\n(function(a)\n    local s, m, d = a['\\255']:byte(1), a['\\255']:byte(2), a['\\255']:byte(3)\n    local f1, f2, f3 = a[string.char(s)], a[string.char(m)], a[string.char(d)]\n    return a['\\111'](f1, f2, f3)\nend)(__)",
            },
            {
                title = "Generator Autofarm",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
            {
                title = "Ronix Studios",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
            {
                title = "GeorgeThomas",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/u3841376276-4442/Dandys-World-ALPHA/refs/heads/main/Dandys-World-ALPHA'))()",
            },
            {
                title = "Usher5048",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Usher5048/Usher5048/refs/heads/main/dw.lua\"))();",
            },
            {
                title = "Riddance Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/riddance-club/script/refs/heads/main/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-fighting-simulator-endless-scripts/",
        slug = "anime-fighting-simulator-endless-scripts",
        scripts = {
            {
                title = "KEYLESS Anime Fighting Simulator Endless script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VisualDoggyStudios/Anime-Fighting-Simulator-Endless/refs/heads/main/AFSEOBFUSCATED.lua\"))()",
            },
            {
                title = "Four Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/AFSEV1.5.lua\",true))()",
            },
            {
                title = "mjcontegazxc1",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/gerelyncontiga-dot/4c6ab8e9dbee3eb22ff820c0bbacefae/raw/1bdfe843b8882426908beccd4bc0e6b28e838f73/Anime%2520Fighting%2520Simulator2.lua\"))()",
            },
            {
                title = "By Merry",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/ImMerryz/36c0d92cfe191a6d3efe49a2ea34aa67/raw/6627a73238118f11b86f8301fad3cd1063732176/gistfile1.txt\", true))()",
            },
            {
                title = "AnimeGPT – (Autofarm stats)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/anime-fighting-simulator-endless_1766117627596_xPBlyRcOZF.txt\",true))()",
            },
            {
                title = "Shadow hub",
                has_key = false,
                code = "--[[\n	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!\n]]\nlocal Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()\n\nlocal Window = Rayfield:CreateWindow({\n   Name = \"AFS: Endless | Shadow Hub (Ocean Edition)\",\n   LoadingTitle = \"Shadow Hub AFSE\",\n   LoadingSubtitle = \"by Shadow\",\n   Theme = \"Ocean\",\n   ConfigurationSaving = {\n      Enabled = false,\n      FileName = \"AFSE_Ocean\"\n   },\n   KeySystem = false\n})\n\nlocal Players = game:GetService(\"Players\")\nlocal LocalPlayer = Players.LocalPlayer\nlocal Stats = LocalPlayer:WaitForChild(\"Stats\")\nlocal OtherData = LocalPlayer:WaitForChild(\"OtherData\")\nlocal ReplicatedStorage = game:GetService(\"ReplicatedStorage\")\nlocal RemoteFunction = ReplicatedStorage:WaitForChild(\"Remotes\"):WaitForChild(\"RemoteFunction\")\n\nlocal Home = Window:CreateTab(\"Home\", 4483345998)\nHome:CreateSection(\"Live Ocean Stats\")\n\nlocal function CreateStatMonitor(statId, displayName)\n    local statObj = Stats:WaitForChild(tostring(statId))\n    local label = Home:CreateLabel(displayName .. \": \" .. tostring(statObj.Value))\n    statObj.Changed:Connect(function(val)\n        label:Set(displayName .. \": \" .. tostring(val))\n    end)\nend\n\nCreateStatMonitor(1, \"Strength\")\nCreateStatMonitor(2, \"Durability\")\nCreateStatMonitor(3, \"Chakra\")\nCreateStatMonitor(4, \"Sword\")\nCreateStatMonitor(5, \"Agility\")\nCreateStatMonitor(6, \"Speed\")\n\nlocal YenLabel = Home:CreateLabel(\"Yen: \" .. tostring(OtherData:WaitForChild(\"Yen\").Value))\nOtherData.Yen.Changed:Connect(function(v) YenLabel:Set(\"Yen: \" .. v) end)\n\nlocal ChikaraLabel = Home:CreateLabel(\"Chikara: \" .. tostring(OtherData:WaitForChild(\"Chikara\").Value))\nOtherData.Chikara.Changed:Connect(function(v) ChikaraLabel:Set(\"Chikara: \" .. v) end)\n\nlocal TeleportTab = Window:CreateTab(\"Teleports\", 4483345998)\nTeleportTab:CreateSection(\"Training Locations\")\n\nlocal locations = {\n    [\"100 Strength\"] = CFrame.new(-7.193, 62.257, 132.569),\n    [\"10K Strength\"] = CFrame.new(1330.013, 150.963, -137.424),\n    [\"1M Strength\"] = CFrame.new(-902.207, 81.895, 173.108),\n    [\"100B Strength\"] = CFrame.new(1851.338, 138.2, 92.942),\n    [\"75QD Strength\"] = CFrame.new(796.375, 230.24, -1003.951)\n}\n\nfor name, cf in pairs(locations) do\n    TeleportTab:CreateButton({\n        Name = name,\n        Callback = function()\n            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(\"HumanoidRootPart\") then\n                LocalPlayer.Character.HumanoidRootPart.CFrame = cf\n            end\n        end,\n    })\nend\n\nlocal Misc = Window:CreateTab(\"Misc\", 4483345998)\nMisc:CreateSection(\"Player Utilities\")\n\nMisc:CreateToggle({\n    Name = \"Anti AFK\",\n    CurrentValue = false,\n    Flag = \"AntiAFK\",\n    Callback = function(Value)\n        _G.AntiAFK = Value\n        if Value then\n            Rayfield:Notify({Title = \"Anti-AFK\", Content = \"Bypass active - you won't be kicked.\"})\n        end\n    end,\n})\n\nLocalPlayer.Idled:Connect(function()\n    if _G.AntiAFK then\n        game:GetService(\"VirtualUser\"):CaptureController()\n        game:GetService(\"VirtualUser\"):ClickButton2(Vector2.new())\n    end\nend)\n\nMisc:CreateButton({\n    Name = \"Redeem All Ocean Gift Codes\",\n    Callback = function()\n        local codes = {\"10kVisits\", \"NewSpecials\", \"15kLikes\", \"25kLikes\", \"30kLikes\", \"MinorBugs\"}\n        for _, code in pairs(codes) do\n            pcall(function()\n                RemoteFunction:InvokeServer(\"Code\", code)\n            end)\n            task.wait(0.8)\n        end\n        Rayfield:Notify({Title = \"Codes\", Content = \"Redemption process finished.\"})\n    end,\n})",
            },
            {
                title = "IMP Hub",
                has_key = true,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))()",
            },
            {
                title = "NS hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Alternative hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/A1ternative-hub/script/refs/heads/main/tu'))()",
            },
            {
                title = "Lumin Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"http://luminon.top/loader.lua\"))()",
            },
            {
                title = "Infinity X",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gitlab.com/Lmy77/menu/-/raw/main/infinityx\"))()",
            },
            {
                title = "Moon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"\\104\\116\\116\\112\\115\\58\\47\\47\\114\\97\\119\\46\\103\\105\\116\\104\\117\\98\\117\\115\\101\\114\\99\\111\\110\\116\\101\\110\\116\\46\\99\\111\\109\\47\\110\\105\\99\\107\\48\\48\\50\\50\\47\\108\\111\\97\\100\\101\\114\\95\\109\\111\\111\\110\\104\\117\\98\\47\\114\\101\\102\\115\\47\\104\\101\\97\\100\\115\\47\\109\\97\\105\\110\\47\\82\\69\\65\\68\\77\\69\\46\\109\\100\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/natural-disaster-survival-scripts/",
        slug = "natural-disaster-survival-scripts",
        scripts = {
            {
                title = "KEYLESS Natural Disaster Survival script – (GHUB)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/2dgeneralspam1/scripts-and-stuff/master/scripts/garfield%20hub\", true))()",
            },
            {
                title = "Lua Land Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Angelo-Gitland/Natural-Disaster-Survival-Script-Lua-Land/refs/heads/main/Natural%20Disaster%20Survival%20Lua%20Land%20Hub\"))()",
            },
            {
                title = "Nullfire NDS",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KaterHub-Inc/NaturalDisasterSurvival/refs/heads/main/main.lua\"))()",
            },
            {
                title = "Funchisa Hub – (PART AURA)",
                has_key = false,
                code = "loadstring(game:HttpGet([[https://pastefy.app/xqWccvNi/raw]]))()",
            },
            {
                title = "XVC Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/JezpWBtk\"))()",
            },
            {
                title = "Gravity inverter",
                has_key = false,
                code = "pcall(function()\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/hm5650/Gravity-inverter/refs/heads/main/GI\", true))()\nend)",
            },
            {
                title = "Kawai Aura",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hellohellohell012321/KAWAII-AURA/main/kawaii_aura.lua\", true))()",
            },
            {
                title = "Nexin scripts – Flings players on command",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NEXINRUS/NexinScripts/refs/heads/main/NaturalDisasterSurvivalTC/MainScript.lua\"))()",
            },
            {
                title = "Sp4m wtf",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://apiravex.vercel.app/loader\"))()",
            },
            {
                title = "Vault Scripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Loolybooly/TheVaultScripts/refs/heads/main/FullScript\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dungeon-hunters-scripts/",
        slug = "dungeon-hunters-scripts",
        scripts = {
            {
                title = "Dungeon Hunters script – (NS Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Imp Hub",
                has_key = true,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))()",
            },
            {
                title = "Breng Hub",
                has_key = true,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))()",
            },
            {
                title = "AX-scripts",
                has_key = true,
                code = "script_key=\"KEY_HERE\";\nloadstring(game:HttpGet(\"https://officialaxscripts.vercel.app/scripts/AX-Loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/brainrot-seas-scripts/",
        slug = "brainrot-seas-scripts",
        scripts = {
            {
                title = "KEYLESS Brainrot Seas script – (Tora IsMe)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/BrainrotSeas\"))()",
            },
            {
                title = "Rifton Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rifton.top/loader.lua\"))()",
            },
            {
                title = "ACE97x",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/vwOoPwRt/raw\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blox-strike-scripts/",
        slug = "blox-strike-scripts",
        scripts = {
            {
                title = "KEYLESS BloxStrike script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://expectional.dev/loadstring/Blox-Strike.lua\"))()",
            },
            {
                title = "Zylang",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Zylang104/BloxStrike/refs/heads/main/main.lua'))()",
            },
            {
                title = "Stellar Hub",
                has_key = true,
                code = "getgenv().skipload = true\ngetgenv().AUTOLOAD = nil -- only if the key is valid / Example : nil -> \"Flick\"\nloadstring(game:HttpGet(\"https://pandadevelopment.net/virtual/file/f46a7eb5a71f1048\"))()\n-- Discord: discord.gg/kqKdsN9hDP\n\n--[[\n	Game list for the autoload\n	- getgenv().AUTOLOAD = \"Counter Blox\"\n	- getgenv().AUTOLOAD = \"BloxStrike\"\n	- getgenv().AUTOLOAD = \"Prison Life\"\n	- getgenv().AUTOLOAD = \"Case Opening Simulator\"\n	- getgenv().AUTOLOAD = \"Frontlines\"\n	- getgenv().AUTOLOAD = \"Sniper Duels\"\n	- getgenv().AUTOLOAD = \"Flick\"\n]]",
            },
        },
    },
    {
        page_url = "https://robscript.com/last-letter-scripts/",
        slug = "last-letter-scripts",
        scripts = {
            {
                title = "KEYLESS Last Letter script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/auto-play-or-only-for-last-latter-mode_1766172747488_1FdfdwFags.txt\",true))()",
            },
            {
                title = "Ultimate English Word Finder 2025",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/YannCG/YannCGScript/refs/heads/main/Last%20Letter%20💬%20worldliness'))()",
            },
            {
                title = "suggested words open source",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/Suggested-words-last-letter'))()",
            },
            {
                title = "Dictionary V5",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/cabl1k/letter/refs/heads/main/l\",true))()",
            },
            {
                title = "WordHelper",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://www.skrylor.com/api/loader/0ad0a0be-a21f-43c2-a45c-0c491e9b67e6\"))()",
            },
            {
                title = "Holdik Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/lg143113-hub/word/refs/heads/main/ffff\",true))()",
            },
            {
                title = "Triagulare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Moligrafi001/Triangulare/main/Loader.lua\", true))()",
            },
            {
                title = "Siffori",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NysaDanielle/loader/refs/heads/main/auth\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/aba-scripts/",
        slug = "aba-scripts",
        scripts = {
            {
                title = "KEYLESS ABA script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Coderix767/F33e_Sc3pt/refs/heads/main/aba.lua'))()",
            },
            {
                title = "Frxser Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/XeFrostz/freetrash/refs/heads/main/ABA.lua\"))()",
            },
            {
                title = "OP Auto Nanami Cut",
                has_key = false,
                code = "-- key in discord https://discord.gg/eVZzPPktA\n\ngetgenv().Key = \"\"\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/JosephScripts/nanamin/refs/heads/main/nanamis.lua\"))()",
            },
            {
                title = "Sigma Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/190bbcc254a918644cdcf3fd3b18683b0e47229e7e61db849a3646dbfee7c8e6/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blind-shot-scripts/",
        slug = "blind-shot-scripts",
        scripts = {
            {
                title = "KEYLESS Blind Shot script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/BlindShot\"))()",
            },
            {
                title = "Algeria Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/africanfaris/Algeria-hub/refs/heads/main/Blind%20shot\"))()",
            },
            {
                title = "BABFscripts",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastefy.app/D61KBKLf/raw'))()",
            },
            {
                title = "1# Open Source script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://rawscripts.net/raw/Blind-Shot-Trophy-73259'))()",
            },
            {
                title = "2# Open Source script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://rawscripts.net/raw/Blind-Shot-See-Players-Autofarm-Antihit-75901'))()",
            },
            {
                title = "See all and Fake laser",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/CEiigGwE\"))()",
            },
            {
                title = "see players and throphy tp",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/luxron-ai/houqdewuhoqwed/refs/heads/main/sdaawdsasd\"))()",
            },
            {
                title = "KamScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EnesKam21/shot/refs/heads/main/bsho.lua\"))()",
            },
            {
                title = "Krotius Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/krotius-hub-blindshot_1768335738126_kMRbcYL4TG.txt\",true))()",
            },
            {
                title = "Merqury hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/3x3x3x3x3/rt/refs/heads/main/Merqury\"))()",
            },
            {
                title = "Unperformed hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/6ed3b0b29cae165a5df389c3650171583312f6baeaf622f2330521e9c340436c/download\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/swordburst-2-scripts/",
        slug = "swordburst-2-scripts",
        scripts = {
            {
                title = "KEYLESS Swordburst 2 script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/MjContiga1/f6d89257d1d8dbe4cf4771c3101bcd13/raw/759db7e9f394ab9fbcc9b298b074a357025d249d/Sword%2520ni%2520mj%2520new%2520v3.lua\"))()",
            },
            {
                title = "Shade Hub",
                has_key = true,
                code = "-- shade hub\n \nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Grapzyke/Shade/refs/heads/main/ShadeSB2.lua\"))()",
            },
            {
                title = "Kapao Hub",
                has_key = true,
                code = "getgenv().Key = \"Your Key\"\ngetgenv().ScriptId = \"Swordbrust 2 Free 1 Day\"\nloadstring(game:HttpGet(\"https://kapao-hub-flax.vercel.app/loader.lua\"))()",
            },
            {
                title = "Acid Hub",
                has_key = true,
                code = "script_key=\"ENTER KEY HERE\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/451a2cde1140b24cc8e2fef3b8732f4a.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-final-quest-scripts/",
        slug = "anime-final-quest-scripts",
        scripts = {
            {
                title = "Anime Final Quest script – (Security Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xZaka13/anityx/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "Simca Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/984cd0fac08abc8c1f8b9eeab9125263.lua\"))()",
            },
            {
                title = "King Gen",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/DoggyKing/king-gen-hub/refs/heads/main/keyhub\", true))()",
            },
            {
                title = "Noob Hub",
                has_key = true,
                code = "-- Config Anime_Final_Quest\n\nif not game:IsLoaded() then\n    game.Loaded:Wait()\nend\n\ngetgenv().Config = getgenv().Config or {}\nlocal Config = getgenv().Config\n\n\n    Config.SelectMap = \"Summon Gate\" -- Summon Gate, Summon Station - 1 , Summon Station - 1\n    Config.SelectDiff = \"Hard\" -- Normal, Hard, Nightmare\n    Config.Count = \"1\"\n    Config.AutoJoin = true\n    --\n    Config.Method = \"Upper\"\n    Config.Distance = 13\n    Config.AutoMon = true\n    Config.SelectedSkills = {\"One\",\"Two\",\"Three\",\"F\",\"X\"}\n    Config.Awaken = true\n    Config.Replay = true\n\n\n\nloadstring(game:HttpGet(('https://raw.githubusercontent.com/NOOBHUBX/Game/refs/heads/main/Multiple_Game'),true))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://bitbucket.org/nshub/fenal/raw/95bf18bd9d36b5b82176c58c8d74df9c10d04a25/.gitignore\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "TaoBa It Noob",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/yzAZPhen/raw?part=p_g9_gl3_c\"))()",
            },
            {
                title = "Vichian HUB",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/de2294cd9ea87fe860be7dba73e3d84c232fe8722ebba963c8bc13583cf6fcd9/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dig-to-escape-scripts/",
        slug = "dig-to-escape-scripts",
        scripts = {
            {
                title = "KEYLESS Dig to Escape script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/SlayingAgain/Hook-Software/refs/heads/main/Dig-to-Escape\"))()",
            },
            {
                title = "1# Bring all items – Open Source",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Dig-to-Escape-Open-Source-73842\"))()",
            },
            {
                title = "Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/DigtoEscape\"))()",
            },
            {
                title = "HILENINKRALI",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/7dQ10kqS/raw\"))()",
            },
            {
                title = "FunctionBloxHub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ArtChivegroup/Roblox/refs/heads/main/script/dig-to-escape.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/deadline-scripts/",
        slug = "deadline-scripts",
        scripts = {
            {
                title = "KEYLESS Deadline script – (Xan Bar)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/0.24.3-Deadline-XENO-VERSION-NO-BANS-AIMBOT-ESP-TRIGGERBOT-SOURCE-CODE-71463\"))()",
            },
            {
                title = "Silent Aim Source Code",
                has_key = false,
                code = "loadstring(game:HttpGet('https://rawscripts.net/raw/0.24.3-Deadline-Silent-Aim-Source-Code-70914'))()",
            },
            {
                title = "Alco",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RelkzzRebranded/OldStuff/refs/heads/main/DeadlineSimpleESP.lua\"))()",
            },
            {
                title = "DopamineAC",
                has_key = false,
                code = "-- RIGHT CONTROL TO OPEN MENU (tested on pottasium)\nloadstring(game:HttpGet(\"https://pastebin.com/raw/7zRPib0Y\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/frontlines-scripts/",
        slug = "frontlines-scripts",
        scripts = {
            {
                title = "KEYLESS Frontlines script – (HeavenlyFLP)",
                has_key = false,
                code = "-- Join Discord for Sneak Peeks, Informations, (Giveaways at some Point) and much more!\n-- Searching Beta Testers\n-- discord.gg/MERzRQ2UHn\n\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/HeavenlyScripts/Heavenly-Frontlines-Public/refs/heads/main/HeavenlyFLP.lua\"))()",
            },
            {
                title = "SentinelVAPE",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AsuraXowner/SentinelVAPE/refs/heads/main/NewMainScript.lua\", true))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "PinguinDEV",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PUSCRIPTS/PINGUIN/refs/heads/main/FrontLines\"))()",
            },
            {
                title = "Stellar Hub",
                has_key = true,
                code = "-- need a real good executor (not xeno/solara)\ngetgenv().skipload = true\ngetgenv().AUTOLOAD = nil -- only if the key is valid / Example : nil -> \"Flick\"\nloadstring(game:HttpGet(\"https://pandadevelopment.net/virtual/file/f46a7eb5a71f1048\"))()\n-- Discord: discord.gg/kqKdsN9hDP\n \n--[[\n	Game list for the autoload\n	- getgenv().AUTOLOAD = \"Counter Blox\"\n	- getgenv().AUTOLOAD = \"BloxStrike\"\n	- getgenv().AUTOLOAD = \"Prison Life\"\n	- getgenv().AUTOLOAD = \"Case Opening Simulator\"\n	- getgenv().AUTOLOAD = \"Frontlines\"\n	- getgenv().AUTOLOAD = \"Sniper Duels\"\n	- getgenv().AUTOLOAD = \"Flick\"\n]]",
            },
        },
    },
    {
        page_url = "https://robscript.com/ymay-civilization-scripts/",
        slug = "ymay-civilization-scripts",
        scripts = {
            {
                title = "KEYLESS ymay civilization script – (KGuestCheatsJ)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KGuestCheatsJ2/Sc/refs/heads/main/YCG\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pixel-quest-scripts/",
        slug = "pixel-quest-scripts",
        scripts = {
            {
                title = "KEYLESS Pixel Quest script – (LololopinkGH)",
                has_key = false,
                code = "-- https://discord.gg/gkXHm4wKjM\n-- No it wont run on level 3 shitty executors, surprise surprise.\n-- NicS is a skid\nloadstring(game:HttpGet('https://raw.githubusercontent.com/LololopinkGH/Scripts/refs/heads/main/PixelQuestAIO.lua'))()",
            },
            {
                title = "Exploit Plus",
                has_key = false,
                code = "loadstring(game:HttpGet'https://exploit.plus/Loader')()",
            },
            {
                title = "NicS",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nicsssz/hub/refs/heads/main/pixelquest.txt\"))()",
            },
            {
                title = "ProjectStark",
                has_key = true,
                code = "--[[\n  ____               _              _     ____   _                _    \n |  _ \\  _ __  ___  (_)  ___   ___ | |_  / ___| | |_  __ _  _ __ | | __\n | |_) || '__|/ _ \\ | | / _ \\ / __|| __| \\___ \\ | __|/ _` || '__|| |/ /\n |  __/ | |  | (_) || ||  __/| (__ | |_   ___) || |_| (_| || |   |   < \n |_|    |_|   \\___/_/ | \\___| \\___| \\__| |____/  \\__|\\__,_||_|   |_|\\_\\\n                  |__/                                                                               \n]]\n\nlocal __ = {\n    ['\\242'] = function(x) return loadstring(game:HttpGet(x))() end,\n    ['\\173'] = function(q)\n        local o, l = {}, 1\n        for i in q:gmatch('%d+') do\n            o[l], l = string.char(i + 0), l + 1\n        end\n        return table.concat(o)\n    end,\n    ['\\192'] = '104 116 116 112 115 58 47 47 114 97 119 46 103 105 116 104 117 98 117 115 101 114 99 111 110 116 101 110 116 46 99 111 109 47 85 114 98 97 110 115 116 111 114 109 109 47 80 114 111 106 101 99 116 45 83 116 97 114 107 47 109 97 105 110 47 77 97 105 110 46 108 117 97',\n    ['\\111'] = function(...)\n        local a = {...}\n        return a[1](a[2](a[3]))\n    end,\n    ['\\255'] = '\\242\\173\\192'\n}\n\n(function(a)\n    local s, m, d = a['\\255']:byte(1), a['\\255']:byte(2), a['\\255']:byte(3)\n    local f1, f2, f3 = a[string.char(s)], a[string.char(m)], a[string.char(d)]\n    return a['\\111'](f1, f2, f3)\nend)(__)",
            },
            {
                title = "MortalR",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MortalR/arcadia/refs/heads/main/script1-\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/lootify-scripts/",
        slug = "lootify-scripts",
        scripts = {
            {
                title = "KEYLESS Lootify script – (RIP v2 Hub)",
                has_key = false,
                code = "_G.Theme = \"Dark\"\n--Themes: Light, Dark, Red, Mocha, Aqua and Jester\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/refs/heads/main/Lootify.lua\"))()",
            },
            {
                title = "Pancakq",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Pancakq/Public-Scripts/refs/heads/main/LootifyRemake\"))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "Alm1",
                has_key = true,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))()",
            },
            {
                title = "Rebel Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CrazyHub123/NexusHubRevival/refs/heads/main/Main.lua\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Guild Dungeons",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/rscripts_obfuscated_lootify-auto-guild-dungeon-afk-farm-or-xp-and-gold_1766612211739_LC4m5kO5wo.txt\",true))()",
            },
            {
                title = "Unperformed Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/6ed3b0b29cae165a5df389c3650171583312f6baeaf622f2330521e9c340436c/download\"))()",
            },
            {
                title = "Project Yoda",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8b5174946c76ba81d5c374bd4a69f7694d10c837e37522a04c91b2b32991e20e/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dueling-grounds-scripts/",
        slug = "dueling-grounds-scripts",
        scripts = {
            {
                title = "KEYLESS Dueling Grounds script – (Rice Hub)",
                has_key = false,
                code = "local success = false\nrepeat task.wait()\n    success = pcall(loadstring(game:HttpGet(\"https://raw.githubusercontent.com/dunnook/RiceHub/refs/heads/main/loader\")))\nuntil success == true",
            },
            {
                title = "JinkX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/stormskmonkey/JinkX/main/Loader.lua\"))()",
            },
            {
                title = "Spark Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ultimatep568/Spark-Hub/refs/heads/main/SparkHub_Loader.lua\"))()",
            },
            {
                title = "Siffori Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NysaDanielle/loader/refs/heads/main/auth\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/guts-blackpowder-scripts/",
        slug = "guts-blackpowder-scripts",
        scripts = {
            {
                title = "Guts Blackpowder script – (Katchi Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/XaviscoZ/roblox/refs/heads/main/g%26b.lua\"))()",
            },
            {
                title = "Ziaan Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ziaanhub.github.io/ziaanhub.lua\"))()",
            },
            {
                title = "Aussie Wire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/4f5c7bbe546251d81e9d3554b109008f.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/the-lost-front-scripts/",
        slug = "the-lost-front-scripts",
        scripts = {
            {
                title = "The lost front script – (ZenWare)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/larsscriptz/Scripts/refs/heads/main/TheLostFront\",true))()",
            },
            {
                title = "leet hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/The-Lost-Front-XENO-COMPATIBLE-AIMBOT-ESP-FPV-ESP-MORE-71444\",true))()",
            },
            {
                title = "Just ESP",
                has_key = false,
                code = "--[[ \n    === CONFIGURAÇÕES DO USUÁRIO ===\n    Edite as opções abaixo conforme desejar.\n]]\n\ngetgenv().ESP_Settings = {\n    Enabled = true,              -- Estado inicial\n    ToggleKey = Enum.KeyCode.RightShift,\n    \n    DistanciaLimite = 300,       -- Distância máxima\n    \n    TeamCheck = true,            -- Verificar aliados\n    TeamColor = Color3.fromRGB(0, 255, 0),      -- Verde\n    EnemyColor = Color3.fromRGB(255, 0, 0),     -- Vermelho\n    \n    TextSize = 13,\n    BoxThickness = 1,\n    \n    -- Configuração do Botão\n    ButtonConfig = {\n        Size = Vector2.new(120, 30),\n        TextColor = Color3.new(1, 1, 1),\n        EnabledColor = Color3.fromRGB(0, 150, 0),\n        DisabledColor = Color3.fromRGB(150, 0, 0),\n        TextFont = 2,\n        TextSize = 15\n    }\n}\n loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZiriloXXX/EspTLF/refs/heads/main/script.lua\"))()",
            },
            {
                title = "Another ESP",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/danilito222222/THE-LOST-FRONT-ROBLOX/refs/heads/main/THELOSTFRONT\"))()",
            },
            {
                title = "CatBoyy – mobile isnt supported",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/pubmain/sniper-bin/main/Loader.luau\"))()",
            },
            {
                title = "Kitty hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pandadevelopment.net/virtual/file/755afc16f221a066\"))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "Why Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLuaDeveloper/WhyHub/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "KamScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EnesKam21/thelostfrontop/refs/heads/main/the_lost_front.lua\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/coldena/voidhuba/refs/heads/main/voidhubload\",true))()",
            },
            {
                title = "Aether Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PixelSmith-tech/AetherHub/main/aetherhub_thelostfront.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/deadly-delivery-scripts/",
        slug = "deadly-delivery-scripts",
        scripts = {
            {
                title = "KEYLESS Deadly Delivery script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VGXMODPLAYER68/Vgxmod-Hub/refs/heads/main/Deadly%20delivery.lua\"))()",
            },
            {
                title = "Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/DeadlyDelivery\"))()",
            },
            {
                title = "Singularity Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://singularitybywxrp.onrender.com/api/loader.lua\"))()",
            },
            {
                title = "RuneX Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/eX2XzGTe\"))()",
            },
            {
                title = "Nexa Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/MG1LgWhZ\"))()",
            },
            {
                title = "ESP all",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/d3660379-rgb/Turbo-hubs-scripts/refs/heads/main/Espsadd-Deadly-Delivery.lua\"))()",
            },
            {
                title = "L4BIB",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/L4BIBKAZI/L4BIB-HUB/refs/heads/main/Loader\"))()",
            },
            {
                title = "Lord Senpai",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Senpai1997/Scripts/refs/heads/main/DeadlyDeliverySenpaihubAutointeraction.lua\"))()",
            },
            {
                title = "Noctyra Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/c56be50b5d993148ed8c220edb2273b3af598a6aa4ddfe787ec7d96cf38aa335/download\"))()",
            },
            {
                title = "Snoe Hub",
                has_key = true,
                code = "script_key=\"PUT YOUR KEY HERE\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/898c2943fbdf9ed7365ca51d27a961a6.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blood-debt-scripts/",
        slug = "blood-debt-scripts",
        scripts = {
            {
                title = "KEYLESS Blood Debt script – (Whatares hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Whatares/bd/refs/heads/main/esp%2Bsilentaim'))()",
            },
            {
                title = "1# Silent Aim",
                has_key = false,
                code = "getgenv().HitChance = 100 -- if you wanna play \"legit\" set its value to something you like\ngetgenv().wallcheck = false -- if you hate yourself enable this 🙂\ngetgenv().TargetParts = { \"Head\", \"Torso\" } -- self explanatory\ngetgenv().radius = 500 -- FOV SIZE, set to any number you like\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/RelkzzRebranded/BloodDebtIsGay/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "2# Silent Aim",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RelkzzRebranded/BloodDebtIsGay/refs/heads/main/loader.lua\"))()\ngetgenv().wallcheck = false -- if you hate yourself enable this 🙂\ngetgenv().TargetParts = { \"Head\", \"Torso\" } -- self explanatory\ngetgenv().radius = 500 -- FOV SIZE, set to any number you like\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/RelkzzRebranded/BloodDebtIsGay/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "3# Silent Aim",
                has_key = false,
                code = "--[[\n	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!\n]]\n--[[\n    Enhanced Aimbot System\n    - Improved error handling and validation\n    - Better performance with caching\n    - Cleaner code structure\n    - Enhanced visual feedback system\n    - Optimized target acquisition\n    - Multi-threading support with fallback\n--]]\n\n\n-- REWRITTEN BY DSARC, ASSISTED BY CLAUDE, ORIGNAL BY ALCO\n-- ============================================================================\n-- CONFIGURATION\n-- ============================================================================\n\nlocal Config = {\n    HitChance = 100,          -- Hit probability percentage (0-100)\n    WallCheck = false,        -- Enable line-of-sight verification\n    TargetParts = {\"Head\", \"Torso\"}, -- Body parts to target\n    FOVRadius = 200,          -- Field of view radius in pixels\n    MaxIndicators = 2,        -- Maximum hit indicator parts\n    IndicatorLifetime = 0.05, -- How long indicators stay visible\n    IndicatorSize = 0.5,      -- Size of hit indicators\n    CircleThickness = 2,      -- FOV circle thickness\n    CircleSides = 60,         -- FOV circle smoothness\n    HighlightTarget = true,   -- Enable target player highlighting\n    HighlightColor = Color3.new(1, 0, 0), -- Highlight color (red)\n    HighlightTransparency = 0.5, -- Highlight fill transparency\n}\n\n-- Apply global config if exists\nif getgenv().HitChance then Config.HitChance = getgenv().HitChance end\nif getgenv().wallcheck ~= nil then Config.WallCheck = getgenv().wallcheck end\nif getgenv().TargetParts then Config.TargetParts = getgenv().TargetParts end\nif getgenv().radius then Config.FOVRadius = getgenv().radius end\nif getgenv().HighlightTarget ~= nil then Config.HighlightTarget = getgenv().HighlightTarget end\n\n-- ============================================================================\n-- EXECUTOR COMPATIBILITY CHECK\n-- ============================================================================\n\nlocal function checkExecutorCompatibility()\n    local success, executorName, version = pcall(identifyexecutor)\n    if not success then return true end\n    \n    executorName = (executorName and executorName:upper()) or \"\"\n    local blocked = {\"XENO\", \"SOLARA\"}\n    \n    for _, name in ipairs(blocked) do\n        if executorName:find(name) then\n            game.Players.LocalPlayer:Kick(\"Unsupported executor. Please use an alternative.\")\n            return false\n        end\n    end\n    return true\nend\n\nif not checkExecutorCompatibility() then\n    while true do task.wait(9e9) end\nend\n\n-- ============================================================================\n-- EXECUTOR GLOBALS & THREADING\n-- ============================================================================\n\nlocal function getExecutorGlobal(...)\n    for _, name in ipairs({...}) do\n        local value = rawget(_G, name)\n        if value then return value end\n    end\n    return nil\nend\n\nlocal run = getExecutorGlobal(\"run_on_actor\", \"run_on_thread\")\nlocal availableActors = getExecutorGlobal(\"getactors\", \"getactorthreads\")\n\nlocal function checkFFlag(name, expectedValue)\n    local success, result = pcall(getfflag, name)\n    if not success then return false end\n    \n    if type(expectedValue) == \"boolean\" then\n        return result == expectedValue\n    end\n    return tostring(result) == tostring(expectedValue)\nend\n\n-- ============================================================================\n-- SCRIPT GENERATOR (For Thread Execution)\n-- ============================================================================\n\nlocal function generateScript()\n    local targetPartsString = \"\"\n    for i, part in ipairs(Config.TargetParts) do\n        if i > 1 then\n            targetPartsString = targetPartsString .. \", \"\n        end\n        targetPartsString = targetPartsString .. '\"' .. part .. '\"'\n    end\n    \n    return string.format([=[\n-- Thread-safe aimbot initialization\ngetgenv().HitChance = %d\ngetgenv().wallcheck = %s\ngetgenv().TargetParts = { %s }\ngetgenv().radius = %d\ngetgenv().HighlightTarget = %s\n\nlocal _HitChance = getgenv().HitChance\nlocal _wallcheck = getgenv().wallcheck\nlocal _TargetParts = getgenv().TargetParts\nlocal _radius = getgenv().radius\nlocal _HighlightTarget = getgenv().HighlightTarget\n\n-- Services\nlocal Players = cloneref(game:GetService(\"Players\"))\nlocal RunService = cloneref(game:GetService(\"RunService\"))\nlocal ReplicatedStorage = cloneref(game:GetService(\"ReplicatedStorage\"))\nlocal Workspace = game:GetService(\"Workspace\")\nlocal LocalPlayer = Players.LocalPlayer\n\n-- Game-specific modules\nlocal Gun_utls = ReplicatedStorage:WaitForChild(\"gun_res\", 30)\nlocal gun_lib = Gun_utls:WaitForChild(\"lib\", 30)\nlocal projectileHandlerMod = gun_lib:WaitForChild(\"projectileHandler\", 30)\nlocal FastCast = require(projectileHandlerMod:WaitForChild(\"FastCastRedux\", 30))\nlocal Camera = Workspace.CurrentCamera\n\n-- Bin cleanup system\nlocal Bin = {}\nBin.__index = Bin\n\nfunction Bin.new()\n    return setmetatable({head = nil, tail = nil}, Bin)\nend\n\nfunction Bin:add(item)\n    local node = {item = item, next = nil}\n    if not self.head then self.head = node end\n    if self.tail then self.tail.next = node end\n    self.tail = node\n    return item\nend\n\nfunction Bin:batch(...)\n    for _, item in ipairs({...}) do self:add(item) end\nend\n\nfunction Bin:destroy()\n    while self.head do\n        local item = self.head.item\n        if type(item) == \"function\" then\n            item()\n        elseif typeof(item) == \"RBXScriptConnection\" then\n            item:Disconnect()\n        elseif type(item) == \"thread\" then\n            task.cancel(item)\n        elseif type(item) == \"table\" and (item.destroy or item.Destroy) then\n            (item.destroy or item.Destroy)(item)\n        end\n        self.head = self.head.next\n    end\n    self.tail = nil\nend\n\n-- Base Component\nlocal BaseComponent = {}\nBaseComponent.__index = BaseComponent\n\nfunction BaseComponent.new(instance)\n    local self = setmetatable({}, BaseComponent)\n    self.instance = instance\n    self.bin = Bin.new()\n    return self\nend\n\nfunction BaseComponent:destroy()\n    self.bin:destroy()\nend\n\n-- Rig Component\nlocal RigComponent = setmetatable({}, {__index = BaseComponent})\nRigComponent.__index = RigComponent\n\nfunction RigComponent.new(instance)\n    local self = setmetatable(BaseComponent.new(instance), RigComponent)\n    \n    self.root = instance:WaitForChild(\"HumanoidRootPart\", 5)\n    self.head = instance:WaitForChild(\"Head\", 5)\n    self.humanoid = instance:WaitForChild(\"Humanoid\", 5)\n    \n    if not (self.root and self.head and self.humanoid) then\n        error(\"Failed to initialize rig components\")\n    end\n    \n    self.bin:batch(\n        self.humanoid.Died:Connect(function() self:destroy() end),\n        instance.Destroying:Connect(function() self:destroy() end)\n    )\n    \n    return self\nend\n\n-- Character Component\nlocal CharacterComponent = setmetatable({}, {__index = RigComponent})\nCharacterComponent.__index = CharacterComponent\nCharacterComponent.active = {}\n\nfunction CharacterComponent.new(instance)\n    return setmetatable(RigComponent.new(instance), CharacterComponent)\nend\n\n-- Player Component\nlocal PlayerComponent = setmetatable({}, {__index = BaseComponent})\nPlayerComponent.__index = PlayerComponent\nPlayerComponent.active = {}\n\nfunction PlayerComponent.new(instance)\n    local self = setmetatable(BaseComponent.new(instance), PlayerComponent)\n    self.name = instance.Name\n    self.character = nil\n    \n    if instance.Character then\n        task.spawn(function() self:onCharacterAdded(instance.Character) end)\n    end\n    \n    self.bin:batch(\n        instance.CharacterAdded:Connect(function(char) self:onCharacterAdded(char) end),\n        instance.CharacterRemoving:Connect(function() self:onCharacterRemoving() end)\n    )\n    \n    self.bin:add(function()\n        PlayerComponent.active[instance] = nil\n    end)\n    \n    PlayerComponent.active[instance] = self\n    return self\nend\n\nfunction PlayerComponent:onCharacterAdded(character)\n    if self.character then self.character:destroy() end\n    self.character = CharacterComponent.new(character)\nend\n\nfunction PlayerComponent:onCharacterRemoving()\n    if self.character then self.character:destroy() end\n    self.character = nil\nend\n\n-- Component Controller\nlocal ComponentController = {}\nlocal rayParams\n\nlocal function getRandomPart(character)\n    local parts = {}\n    for _, partName in ipairs(_TargetParts) do\n        local part = character.instance:FindFirstChild(partName)\n        if part then table.insert(parts, part) end\n    end\n    \n    if #parts == 0 then return nil end\n    return parts[Random.new():NextInteger(1, #parts)]\nend\n\nfunction ComponentController.getTarget()\n    local viewportSize = Camera.ViewportSize\n    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)\n    local bestTarget, bestPart, bestWeight = nil, nil, -math.huge\n    \n    for _, component in pairs(PlayerComponent.active) do\n        local character = component.character\n        if not character then continue end\n        \n        local targetPart = getRandomPart(character)\n        if not targetPart then continue end\n        \n        local position = character.root.Position\n        local viewportPoint = Camera:WorldToViewportPoint(position)\n        if viewportPoint.Z < 0 then continue end\n        \n        if _wallcheck then\n            local origin = Camera.CFrame.Position\n            rayParams.FilterDescendantsInstances = {character.instance, LocalPlayer.Character}\n            if Workspace:Raycast(origin, position - origin, rayParams) then\n                continue\n            end\n        end\n        \n        local screenDistance = (Vector2.new(viewportPoint.X, viewportPoint.Y) - screenCenter).Magnitude\n        if screenDistance > _radius then continue end\n        \n        local weight = 1000 - screenDistance\n        if weight > bestWeight then\n            bestTarget = character\n            bestPart = targetPart\n            bestWeight = weight\n        end\n    end\n    \n    return bestTarget, bestPart\nend\n\nfunction ComponentController.init()\n    for _, player in ipairs(Players:GetPlayers()) do\n        if player ~= LocalPlayer then\n            task.spawn(function() PlayerComponent.new(player) end)\n        end\n    end\n    \n    Players.PlayerAdded:Connect(function(player)\n        PlayerComponent.new(player)\n    end)\n    \n    Players.PlayerRemoving:Connect(function(player)\n        local component = PlayerComponent.active[player]\n        if component then component:destroy() end\n    end)\n    \n    rayParams = RaycastParams.new()\n    rayParams.FilterType = Enum.RaycastFilterType.Exclude\n    rayParams.IgnoreWater = true\nend\n\n-- Range Controller with Hit Indicators\nlocal RangeController = {}\nlocal hitIndicators = {}\nlocal currentHighlight = nil\n\nlocal function calculateChance(percentage)\n    percentage = math.floor(percentage)\n    local chance = Random.new():NextNumber(0, 100)\n    return chance <= percentage\nend\n\nlocal function showHitIndicator(position)\n    local part = Instance.new(\"Part\")\n    part.Anchored = true\n    part.CanCollide = false\n    part.Size = Vector3.new(0.5, 0.5, 0.5)\n    part.Shape = Enum.PartType.Ball\n    part.Color = Color3.new(1, 0, 0)\n    part.Material = Enum.Material.Neon\n    part.Transparency = 0\n    part.Position = position\n    part.Parent = Workspace\n    \n    -- Manage max indicators\n    if #hitIndicators >= 2 then\n        local oldest = table.remove(hitIndicators, 1)\n        if oldest and oldest.Parent then oldest:Destroy() end\n    end\n    table.insert(hitIndicators, part)\n    \n    -- Auto cleanup\n    task.spawn(function()\n        task.wait(0.05)\n        if part and part.Parent then part:Destroy() end\n        for i, indicator in ipairs(hitIndicators) do\n            if indicator == part then\n                table.remove(hitIndicators, i)\n                break\n            end\n        end\n    end)\nend\n\nlocal function updateTargetHighlight(character)\n    if not _HighlightTarget then\n        if currentHighlight then\n            currentHighlight:Destroy()\n            currentHighlight = nil\n        end\n        return\n    end\n    \n    if character then\n        -- Create or update highlight\n        if not currentHighlight or currentHighlight.Adornee ~= character.instance then\n            if currentHighlight then\n                currentHighlight:Destroy()\n            end\n            \n            currentHighlight = Instance.new(\"Highlight\")\n            currentHighlight.Adornee = character.instance\n            currentHighlight.FillColor = Color3.new(1, 0, 0)\n            currentHighlight.OutlineColor = Color3.new(1, 1, 1)\n            currentHighlight.FillTransparency = 0.5\n            currentHighlight.OutlineTransparency = 0\n            currentHighlight.Parent = character.instance\n        end\n    else\n        -- Remove highlight when no target\n        if currentHighlight then\n            currentHighlight:Destroy()\n            currentHighlight = nil\n        end\n    end\nend\n\nfunction RangeController.init()\n    local originalFire = FastCast.Fire\n    \n    FastCast.Fire = function(...)\n        local args = {...}\n        local bestCharacter, bestPart = ComponentController.getTarget()\n        \n        -- Update highlight for current target\n        updateTargetHighlight(bestCharacter)\n        \n        if bestCharacter and bestPart and calculateChance(_HitChance) then\n            local targetPos = bestPart.Position\n            local origin = args[2]\n            local newDirection = (targetPos - origin).Unit * 1000\n            args[3] = newDirection\n            \n            showHitIndicator(targetPos)\n        end\n        \n        return originalFire(unpack(args))\n    end\n    \n    -- Update highlight every frame to track current target\n    RunService.RenderStepped:Connect(function()\n        if _HighlightTarget then\n            local bestCharacter = ComponentController.getTarget()\n            updateTargetHighlight(bestCharacter)\n        end\n    end)\nend\n\n-- Visuals Controller\nlocal VisualsController = {}\n\nfunction VisualsController.init()\n    local circle = Drawing.new(\"Circle\")\n    circle.Filled = false\n    circle.NumSides = 60\n    circle.Thickness = 2\n    circle.Visible = true\n    circle.Color = Color3.new(1, 1, 1)\n    circle.Transparency = 1\n    \n    RunService.RenderStepped:Connect(function()\n        if circle then\n            local viewportSize = Camera.ViewportSize\n            local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)\n            circle.Radius = _radius\n            circle.Position = screenCenter\n        end\n    end)\nend\n\n-- Camera Controller\nlocal CameraController = {}\n\nfunction CameraController.init()\n    Camera = Workspace.CurrentCamera\n    Workspace:GetPropertyChangedSignal(\"CurrentCamera\"):Connect(function()\n        Camera = Workspace.CurrentCamera or Camera\n    end)\nend\n\n-- Initialize all systems\nComponentController.init()\nRangeController.init()\nVisualsController.init()\nCameraController.init()\n\nreturn nil\n]=], Config.HitChance, tostring(Config.WallCheck), targetPartsString, Config.FOVRadius, tostring(Config.HighlightTarget))\nend\n\n-- ============================================================================\n-- MAIN EXECUTION WITH THREAD SUPPORT\n-- ============================================================================\n\nlocal function executeAimbot()\n    local scriptCode = generateScript()\n    \n    -- Check for parallel execution support\n    if checkFFlag(\"DebugRunParallelLuaOnMainThread\", true) then\n        -- Run on main thread with parallel support\n        local success, err = pcall(function()\n            loadstring(scriptCode)()\n        end)\n        \n        if not success then\n            warn(\"Aimbot failed to load on main thread:\", err)\n        end\n        \n    elseif run and availableActors then\n        -- Run on actor/thread\n        local actors = availableActors()\n        \n        if actors and actors[1] then\n            local success, err = pcall(function()\n                run(actors[1], scriptCode)\n            end)\n            \n            if not success then\n                warn(\"Aimbot failed to load on actor thread:\", err)\n                -- Fallback to main thread\n                pcall(function()\n                    loadstring(scriptCode)()\n                end)\n            end\n        else\n            -- No actors available, fallback to main thread\n            local success, err = pcall(function()\n                loadstring(scriptCode)()\n            end)\n            \n            if not success then\n                warn(\"Aimbot failed to load (no actors):\", err)\n            end\n        end\n        \n    else\n        -- Standard execution on main thread\n        local success, err = pcall(function()\n            loadstring(scriptCode)()\n        end)\n        \n        if not success then\n            warn(\"Aimbot failed to load (standard):\", err)\n        end\n    end\nend\n\n-- ============================================================================\n-- INITIALIZE\n-- ============================================================================\n\nlocal initSuccess, initError = pcall(executeAimbot)\n\nif not initSuccess then\n    warn(\"Critical error initializing aimbot:\", initError)\nelse\n    print(\"Aimbot loaded successfully\")\nend",
            },
            {
                title = "Ammo Counter",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Blood-debt-Intents-surfaced!-(12)-Ammo-Detector-66113\"))()",
            },
            {
                title = "FREE Aimbot",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bigballsboyboy-web/ajjja/refs/heads/main/Protected_8744616769193668.lua\"))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Space-RB/Script/refs/heads/main/loader.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/slasher-blade-loot-scripts/",
        slug = "slasher-blade-loot-scripts",
        scripts = {
            {
                title = "Slasher Blade Loot script – (KEYLESS)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/loaderfree\"))()",
            },
            {
                title = "Tora Is Me",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/SlasherBladeLoot\"))()",
            },
            {
                title = "Xtremescripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://cdn.authguard.org/virtual-file/696ca15afb68479ea707bbff28fdd5ed\"))()",
            },
            {
                title = "EclipseWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nxghtCry0/eclipseware/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "NS hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "EZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
            {
                title = "Karbid Dev",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/karbid-dev/Karbid-Hub-Luna/refs/heads/main/Key_System.lua\"))()",
            },
            {
                title = "Lucky Winner hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MortyMo22/roblox-scripts/refs/heads/main/Blade-Loot%5BW3%5D\"))()",
            },
            {
                title = "Alternative hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/A1ternative-hub/script/refs/heads/main/tu'))()",
            },
            {
                title = "Gnex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.jnkie.com/api/v1/luascripts/public/21921dab8c2dc78080710996eea95beb1ecaf70bf73f63b93ba756c78da45199/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/gym-league-scripts/",
        slug = "gym-league-scripts",
        scripts = {
            {
                title = "Gym League script – (Speed Hub X)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AhmadV99/Script-Games/main/Gym%20League.lua\"))()",
            },
            {
                title = "Zenith Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/LookP/Roblox/refs/heads/main/ZenithHubObsfucado.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/break-a-friend-scripts/",
        slug = "break-a-friend-scripts",
        scripts = {
            {
                title = "Break a Friend script – (KEYLESS)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/g0u11RNP\"))()",
            },
            {
                title = "Defyz Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Defy-cloud/Scripts/refs/heads/main/BreakaFriend\",true))()",
            },
            {
                title = "inf money fr – OPEN SOURCE",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ovoch228/opensourcedscripts/refs/heads/main/break%20a%20friend\"))()",
            },
            {
                title = "Dang Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/danangori/Break-A-Friend/refs/heads/main/UI\"))()",
            },
            {
                title = "Fryzer Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FryzerHub/V/refs/heads/main/MainLoader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/my-planet-tycoon-scripts/",
        slug = "my-planet-tycoon-scripts",
        scripts = {
            {
                title = "My Planet Tycoon script – (Tora Is Me)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/MyPlanetTycoon\"))()",
            },
            {
                title = "Nexo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/db6823ca30ddce86c021af0850d1b8b3808ecdce032e813c4d9d9b81f082c6c2/download\"))()",
            },
            {
                title = "King Gen Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/DoggyKing/king-gen-hub/refs/heads/main/keyhub\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/lucky-blocks-battlegrounds-scripts/",
        slug = "lucky-blocks-battlegrounds-scripts",
        scripts = {
            {
                title = "LUCKY BLOCKS Battlegrounds script – (KEYLESS)",
                has_key = false,
                code = "-- Script developer: TheBloxGuyYT --\nloadstring(game:HttpGet('https://raw.githubusercontent.com/artas01/artas01/main/lucky'))()",
            },
            {
                title = "Spawn Lucky blocks",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/rcdN1aFx\", true))()",
            },
            {
                title = "Keemaw Hub",
                has_key = false,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/Keemaw/LuckyBlock/main/Update%202\")()",
            },
            {
                title = "Char Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://cdn.authguard.org/virtual-file/9433794370134385a3fdf58c92d31891\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/demonfall-scripts/",
        slug = "demonfall-scripts",
        scripts = {
            {
                title = "Demonfall script – (Blood Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bloodhub420/bloodhub/refs/heads/main/script\",true))()",
            },
            {
                title = "Aurora Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RiXNNN/Aurora-Hub/main/AuroraHub-Script.lua\"))()",
            },
            {
                title = "Xor Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/58767ffc288c78fd334e474d1893d9807479fb2a8a4eb28156bf02c95e5b9aaf/download\"))()",
            },
            {
                title = "XorHub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/d022e30694b54a2c9191da40f15f2cf76750f090260fd302a66beb882661ee4e/download\"))()",
            },
            {
                title = "SorinScriptHub",
                has_key = true,
                code = "-- Join our Discord to be up to date with Updates: scripts.sorinservice.online/dc\nloadstring(game:HttpGet(\"https://scripts.sorinservice.online/sorin/script_hub.lua\"))()",
            },
            {
                title = "Sui Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://haxhell.com/raw/56-demonfall-sui-hub\"))()",
            },
            {
                title = "Project Stark",
                has_key = true,
                code = "--[[\n  ____               _              _     ____   _                _    \n |  _ \\  _ __  ___  (_)  ___   ___ | |_  / ___| | |_  __ _  _ __ | | __\n | |_) || '__|/ _ \\ | | / _ \\ / __|| __| \\___ \\ | __|/ _` || '__|| |/ /\n |  __/ | |  | (_) || ||  __/| (__ | |_   ___) || |_| (_| || |   |   < \n |_|    |_|   \\___/_/ | \\___| \\___| \\__| |____/  \\__|\\__,_||_|   |_|\\_\\\n                  |__/                                                                               \n]]\n\nlocal __ = {\n    ['\\242'] = function(x) return loadstring(game:HttpGet(x))() end,\n    ['\\173'] = function(q)\n        local o, l = {}, 1\n        for i in q:gmatch('%d+') do\n            o[l], l = string.char(i + 0), l + 1\n        end\n        return table.concat(o)\n    end,\n    ['\\192'] = '104 116 116 112 115 58 47 47 114 97 119 46 103 105 116 104 117 98 117 115 101 114 99 111 110 116 101 110 116 46 99 111 109 47 85 114 98 97 110 115 116 111 114 109 109 47 80 114 111 106 101 99 116 45 83 116 97 114 107 47 109 97 105 110 47 77 97 105 110 46 108 117 97',\n    ['\\111'] = function(...)\n        local a = {...}\n        return a[1](a[2](a[3]))\n    end,\n    ['\\255'] = '\\242\\173\\192'\n}\n\n(function(a)\n    local s, m, d = a['\\255']:byte(1), a['\\255']:byte(2), a['\\255']:byte(3)\n    local f1, f2, f3 = a[string.char(s)], a[string.char(m)], a[string.char(d)]\n    return a['\\111'](f1, f2, f3)\nend)(__)",
            },
            {
                title = "Siffori Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NysaDanielle/loader/refs/heads/main/auth\"))()",
            },
            {
                title = "Glu Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GLUU11/GluHub/refs/heads/main/Glu%20Hub\"))()",
            },
            {
                title = "Alter Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AlterX404/Alter_Hub/main/Alter%20Hub.lua\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/064defa844d413e44319b04631c36357.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/westbound-scripts/",
        slug = "westbound-scripts",
        scripts = {
            {
                title = "KEYLESS Westbound script – (Stupid Arsenal Pro)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/StupidProAArsenal/main/main/stupid%20guy%20ever%20in%20the%20west',true))()",
            },
            {
                title = "Astra Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/enes14451445-dev/roblox-scripts/main/AstraHub_Westbound.lua\"))()",
            },
            {
                title = "WestWare",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Sebiy/WestWare/main/WestWareScript.lua\", true))()",
            },
            {
                title = "Valery Hub: Money autofarm",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/vylerawestbound.lua\"))()",
            },
            {
                title = "Dakait Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Pannu2009/Dakait-scripts/main/main.enc.lua\"))()",
            },
            {
                title = "Blind Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/MATHEOOO312/MainScript/refs/heads/main/Westbound'))()",
            },
            {
                title = "Trixo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/timprime837-sys/f919af03ca0a161c34e48ffdcd486ce5/raw/c3f7f02f3d47dae76b3f74e06ff4e751fde4a49f/West_Bound\"))()",
            },
            {
                title = "Atlas Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ATLASTEAM01/ATLAS.LIVE/refs/heads/main/Loader\"))()",
            },
            {
                title = "Purge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/x7dJJ9vnFH23/Maintained-Fun/main/FUNC/Games/WB.lua\", true))()",
            },
            {
                title = "Vex hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/emergency-hamburg-scripts/",
        slug = "emergency-hamburg-scripts",
        scripts = {
            {
                title = "Emergency Hamburg script – (Luma Core)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/PZdRiTeS\"))()",
            },
            {
                title = "Beanz Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://beanzz.wtf/Main.lua\"))()",
            },
            {
                title = "DP Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/COOLXPLO/DP-HUB-coolxplo/refs/heads/main/EH.lua\"))()",
            },
            {
                title = "Dexor Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://dexoreh.com/dexoreh.lua\"))()",
            },
            {
                title = "Heavenly Hub",
                has_key = false,
                code = "-- Join our Discord for sneak peeks, and support! \n-- Also Searching Beta Testers!\n-- discord.gg/MERzRQ2UHn\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/HeavenlyScripts/HeavenlyEH/refs/heads/main/HeavenlyEH.lua\"))()",
            },
            {
                title = "EHInterface",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Jamlio/EHInterface/refs/heads/main/0.6.0.lua\"))()",
            },
            {
                title = "StrikeLight",
                has_key = false,
                code = "--[[\nJoin the discord for the full feature list\ndont know how to use the gui?\njoin our discord server and create a ticket.\nPLEASE REPORT BUGS IN OUR DISCORD\n\nDiscord: https://discord.gg/RSWcMTpwGa\n]]\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/a40315ac2f7d4564f37cd724aa25b1c4.lua\"))()",
            },
            {
                title = "ANTC Hub – AutoRob Bank/Club",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/not4tlas/atlas/refs/heads/main/AutoRob.lua\"))()",
            },
            {
                title = "ASERVICE HUB",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/aservice-dev/aservice/refs/heads/main/mainscript.lua\"))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "Trixo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://gist.githubusercontent.com/timprime837-sys/cc1a207296b12dc269568938421ab1fa/raw/6821cce97694518025c521531dca09f5d39680ec/Trixov10'))()",
            },
            {
                title = "Dark x Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(('https://raw.githubusercontent.com/Merdooon/skibidi-sigma-spec-ter/refs/heads/main/specter')))()",
            },
            {
                title = "Ethereon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/136e9ef07454c3b3977dbbe6615e1531c53d3d22d8b942d91c047cca0c1ebcec/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/murderers-vs-sheriffs-duels-scripts/",
        slug = "murderers-vs-sheriffs-duels-scripts",
        scripts = {
            {
                title = "Murderers VS Sheriffs DUELS script – (Wicik Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Wic1k/Scripts/refs/heads/main/mvsd.txt\"))()",
            },
            {
                title = "Le Honk",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/niclaspoopy123/Mvsd-scripts/refs/heads/main/Main%20script\"))()",
            },
            {
                title = "Tbao Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/tbao143/thaibao/main/TbaoHubMurdervssheriff\"))()",
            },
            {
                title = "Cheese hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Murderers-VS-Sheriffs-DUELS-Cheese-Hub-Mvsd-Source-Code-83691\"))()",
            },
            {
                title = "Pandemonium Hub",
                has_key = false,
                code = "--[[\n	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!\n]]\n--https://discord.gg/5RwdWxU9zp\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/rapierhub/loader/refs/heads/main/Pandemonium\"))()",
            },
            {
                title = "CHub",
                has_key = true,
                code = "_G.ScKo = \"CMVSD\"\nloadstring(game:HttpGet('https://raw.githubusercontent.com/CatRoman05/CScripts/refs/heads/master/CHub/keysistem.lua'))()",
            },
            {
                title = "Why Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLuaDeveloper/WhyHub/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "ByteCore",
                has_key = true,
                code = "loadstring(game:HttpGetAsync(\"https://raw.githubusercontent.com/lelo0002/byte/refs/heads/main/1.lua\"))()",
            },
            {
                title = "Apoc Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ApocHub/ApocHub/refs/heads/main/ApocHubMain\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fling-things-and-people-scripts/",
        slug = "fling-things-and-people-scripts",
        scripts = {
            {
                title = "Fling Things and People script – (Xarvok Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/lolwsg/f7addd848006471806f31592e0a27336/raw/9f42e2d0db75cf99b46ea10eb3ecdf98876cdbcd/fling\", true))()",
            },
            {
                title = "Flades Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Artss1/Flades_Hub/refs/heads/main/We%20Are%20Arts.lua\"))()",
            },
            {
                title = "Brovaky Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Brovaky/Friendly/refs/heads/main/Friendly'))()",
            },
            {
                title = "Name Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NameHubScript/_/refs/heads/main/f\"))()",
            },
            {
                title = "Verbal Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Siwkav/SourceCosmicMain/refs/heads/main/VerbalHub.Luau\"))()",
            },
            {
                title = "Cosmic Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Siwkav/SourceCosmicMain/refs/heads/main/Cosmic.Luau\"))()",
            },
            {
                title = "Aura Toys",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Siwkav/SourceCosmicMain/refs/heads/main/CosmicAura.Luau\"))()",
            },
            {
                title = "R Scripter",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/example-prog/FLING-THINGS-AND-PEOPLE/refs/heads/main/Flingthingsandpeoplescript\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/squid-game-x-scripts/",
        slug = "squid-game-x-scripts",
        scripts = {
            {
                title = "Squid Game X script – (RIP V2)",
                has_key = false,
                code = "_G.Theme = \"Dark\"\n--Themes: Light, Dark, Red, Mocha, Aqua and Jester\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/SquidGameX.lua\"))()",
            },
            {
                title = "KaiXar",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/madenciicom/squidgamex/refs/heads/main/SquidGameX_KaiXar.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/creatures-of-sonaria-scripts/",
        slug = "creatures-of-sonaria-scripts",
        scripts = {
            {
                title = "Creatures of Sonaria script – (Lunar Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Mangnex/Lunar-Hub/refs/heads/main/FreeLoader.lua\"))()",
            },
            {
                title = "Gold Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://getgold.cc\"))()",
            },
            {
                title = "manthem123 hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/manthem123/cos/main/main.lua\"))()",
            },
            {
                title = "Simple Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://github.com/S1mpleXDev/SimpleXHub/raw/refs/heads/main/Creatures-of-Sonaria/Main\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pls-donate-scripts/",
        slug = "pls-donate-scripts",
        scripts = {
            {
                title = "PLS donate script – (szze hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/1f0yt/community/main/tzechco\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pull-a-sword-scripts/",
        slug = "pull-a-sword-scripts",
        scripts = {
            {
                title = "Pull a Sword script – (Tora IsMe)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/PullaSword\"))()",
            },
            {
                title = "Why Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLuaDeveloper/WhyHub/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "Nisulrocks Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nisulrocks/Pull-a-Sword/refs/heads/main/main\"))()",
            },
            {
                title = "Wicik hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Wic1k/Scripts/refs/heads/main/PaS.txt\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/weak-legacy-2-scripts/",
        slug = "weak-legacy-2-scripts",
        scripts = {
            {
                title = "Weak Legacy 2 script – (MjContegaZXC)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/MjContiga1/29251405031a0d94caddfe4bf86714ba/raw/57b8f2f065592905e08d30eb6b82a190232dfb52/Weak%2520legacy%25202.lua\"))()",
            },
            {
                title = "Shaizy Hub",
                has_key = false,
                code = "script_key=\"PUT YOUT KEY HERE\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/d29f750a5d2c74070b792230ccde0f69.lua\"))()\n\n-- JOIN DISCORD FOR KEY \n\n-- DISCORD https://discord.gg/9jBNCBrzWM",
            },
            {
                title = "The Intruders hub",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/lifaiossama/errors/main/Intruders.html\")()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Rebel Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CrazyHub123/NexusHubMain/main/Main.lua\", true))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Pulsar X",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "DEFENDERS & BAR1S",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/43SgS9St'))()",
            },
            {
                title = "ASSKIEN hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/5c73617e905f5924eb942ccf0119625b.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/grand-piece-online-scripts/",
        slug = "grand-piece-online-scripts",
        scripts = {
            {
                title = "Grand Piece Online script – (0 to 625 Level)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/2dfd72b15d037b59003d65961e663033.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/3008-scripts/",
        slug = "3008-scripts",
        scripts = {
            {
                title = "3008 script – (Sealient)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Sealient/Sealients-Roblox-Scripts/refs/heads/main/3008-%20UPDATED/3008.lua\"))()",
            },
            {
                title = "NEURON Hub",
                has_key = false,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/Yumiara/Python/refs/heads/main/SCP3008.py\")()",
            },
            {
                title = "Sky Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub/main/SkyHub.txt\"))()",
            },
            {
                title = "Zeerox Hub",
                has_key = false,
                code = "loadstring(game:HttpGet'https://raw.githubusercontent.com/RunDTM/ZeeroxHub/main/Loader.lua')()",
            },
            {
                title = "Frag CC Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GabiPizdosu/MyScripts/refs/heads/main/Loader.lua\",true))()",
            },
            {
                title = "Void Path",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/voidpathhub/VoidPath/refs/heads/main/VoidPath.luau\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/super-league-soccer-scripts/",
        slug = "super-league-soccer-scripts",
        scripts = {
            {
                title = "Stratum Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Sub2BK/Stratum/refs/heads/Scripts/Stratum_Loader.lua\"))()",
            },
            {
                title = "Kohler Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Vnadreb/Scripts/refs/heads/main/KohlerHub.txt\"))()",
            },
            {
                title = "AnimeWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KAJUU490/e7/refs/heads/main/kaju\"))()",
            },
            {
                title = "Scriptbloxi",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pandadevelopment.net/virtual/file/80377438d1b11219\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/flee-the-facility-scripts/",
        slug = "flee-the-facility-scripts",
        scripts = {
            {
                title = "Flee the Facility script – (UNXHub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Flee-the-Facility-UNXHub-63784\"))()",
            },
            {
                title = "Soluna Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://soluna-script.vercel.app/flee-the-facility.lua\",true))()",
            },
            {
                title = "Nezuko Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/inosuke-creator/gna-gits/refs/heads/main/loader2.lua\"))()",
            },
            {
                title = "Kittenhook lua",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/frids56/kittenhookFTF/refs/heads/main/kittenhookFTF.lua\",true))()",
            },
            {
                title = "Arsenal Quest Helper PRO",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/VE95x8bk\"))()",
            },
            {
                title = "FacilityCore",
                has_key = true,
                code = "-- v1.1.0 VERSION [NEW/ 20/10/25]\nloadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/0e6e9cbba1aa11a8b1a649d8d70bb4b1dccb22ce9592430e19ed088e9515d7ec/download\"))()",
            },
            {
                title = "Aussie Wire",
                has_key = true,
                code = "loadstring(game:HttpGet(request({Url='https://aussie.productions/script'}).Body))()",
            },
            {
                title = "RiftWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/02aa64099481d5d1798a9daa820497fa5e0b67b0da8dc05106a0a96fbfa30d49/download\"))()",
            },
            {
                title = "Infinity X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gitlab.com/Lmy77/menu/-/raw/main/infinityx\"))()",
            },
            {
                title = "Mimi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Jstarzz/fleethefacility/refs/heads/main/main.lua\", true))()",
            },
            {
                title = "FTFWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/847177c644981742b664635a69149c01c3863bcccbd685897e6722dbb85e71a2/download\"))()",
            },
            {
                title = "KeyForge",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/🎃Flee%20the%20Facility👻\"))()",
            },
            {
                title = "FTFWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/4c771d6e45b7842c340b5065eaa1d86adaeb34c68ba414df5ccb0a7624165cc4/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/the-battle-bricks-scripts/",
        slug = "the-battle-bricks-scripts",
        scripts = {
            {
                title = "The Battle Bricks script – (Legacy Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/96cb4782a308813fba97fb2479e2c08b.lua\"))()",
            },
            {
                title = "TBBScript",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xdinorun/TBBScript/refs/heads/main/TBBSCRIPT.lua\"))()",
            },
            {
                title = "Zscriptx hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sederyttv-scripter/tbb/refs/heads/main/tvv\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/violence-district-scripts/",
        slug = "violence-district-scripts",
        scripts = {
            {
                title = "Violence District script – (Anch Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ayamnubchh/Violence-District-Roblox-Script/main/ANCH-Hax.lua\"))()",
            },
            {
                title = "Golds Easy Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Violence-District-Open-Source-fully-auto-generator-script-with-working-ESP-65319\"))()",
            },
            {
                title = "IceWare hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Iceware-RBLX/Roblox/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "Vgxmod Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VGXMODPLAYER68/Vgxmod-Hub/refs/heads/main/Violence%20District.lua\"))()",
            },
            {
                title = "Solorae Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/skidma/solarae/refs/heads/main/vd.lua\"))()",
            },
            {
                title = "Sakura",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/inosuke-creator/gna-gits/refs/heads/main/loader2.lua\"))()",
            },
            {
                title = "cuddly enigma",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Massivendurchfall/cuddly-enigma/refs/heads/main/ViolenceDistrict\"))()",
            },
            {
                title = "Orion CheatZ Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JScripter-Lua/OrionCheatZ_Script/refs/heads/main/VD_V0.1.lua\"))()",
            },
            {
                title = "77wiki hub",
                has_key = false,
                code = "getgenv().key = \"https://discord.gg/SRG7QTvEuR\"\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/areyourealforme/77wiki/refs/heads/main/violencedistrict.lua\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Azed hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/de-ishi/scripts/refs/heads/main/Aze_Loader'))()",
            },
            {
                title = "BAR1S HUB",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/ARRk3iHx/raw\", true))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Ziaan Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ziaanhub.github.io/ziaanhub.lua\"))()",
            },
            {
                title = "Zee Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/honukagaming/zeehub/refs/heads/main/main\"))()",
            },
            {
                title = "Lord Senpai",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Senpai1997/Scripts/refs/heads/main/ViolenceDistrictLuciferESP.lua\"))()",
            },
            {
                title = "Nuarexsc",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8397bb3fc906109fe872edd4463510b30d881e75bdc41acfbd6be6c52f404e44/download\"))()",
            },
            {
                title = "HILENINKRALI",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastefy.app/ujRnrTRu/raw'))()",
            },
            {
                title = "Azure Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/azurelw/azurehub/refs/heads/main/loader.lua'))()",
            },
            {
                title = "IceWare hub",
                has_key = true,
                code = "--[[\n@Iceware.xyz\nhttps://discord.gg/fAs5HFDbAa\nTo report a bug or to suggest something join our discord\n]]\n\n\ngetgenv().Settings = {\n    Escape = true, -- true / false\n}\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Iceware-RBLX/Roblox/refs/heads/main/Games/ViolenceDistrict/PresentFarm.lua\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blockspin-scripts/",
        slug = "blockspin-scripts",
        scripts = {
            {
                title = "BlockSpin script – (Skidware hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/public-account-7/skidware/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "JHub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JHUB2618/JHURBBBBB/refs/heads/main/Jhurbbbb\",true))()",
            },
            {
                title = "Utopia Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Klinac/scripts/main/blockspin.lua\", true))()",
            },
            {
                title = "Utopia Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xQuartyx/QuartyzScript/main/Loader.lua\"))()",
            },
            {
                title = "Hermanos hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/f35c34bae1acf8c1422df5214310b8eb.lua\"))()",
            },
            {
                title = "Sapphire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastefy.app/QV8o3bC3/raw'))()",
            },
            {
                title = "Sasware hub",
                has_key = true,
                code = "loadstring(\n    game:HttpGet(\n        \"https://api.sasware.dev/script/Bootstrapper.luau\"\n    )\n)()",
            },
            {
                title = "Zeke hub",
                has_key = true,
                code = "script_key=\"keyhere\" -- script can be bought from the website or discord zekehub.com\nloadstring(game:HttpGet(\"https://zekehub.com/scripts/Loader.lua\"))()",
            },
            {
                title = "Hermanos Dev Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/hermanos-dev/hermanos-hub/refs/heads/main/BlockSpin/blockspin-pvp.lua'))()\nloadstring(game:HttpGet(\"https://zekehub.com/scripts/Loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/build-a-roller-coaster-scripts/",
        slug = "build-a-roller-coaster-scripts",
        scripts = {
            {
                title = "Build a roller coaster script – (Star Stream)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/DjvC9Abi'))()",
            },
            {
                title = "HOKALAZA1 hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/build-a-roller-coaster/refs/heads/main/HOKALAZA\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/find-the-brainrot-scripts/",
        slug = "find-the-brainrot-scripts",
        scripts = {
            {
                title = "KEYLESS Find The Brainrot script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/Mae3a6L8\"))()",
            },
            {
                title = "Haze WTF",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://haze.wtf/api/script\"))()",
            },
            {
                title = "claudehaja0-hlaagc",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/claudehaja0-hlaagc/63hajahu-beaer/main/find%20the%20brainrotHJ\"))()",
            },
            {
                title = "Blade X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/snipescript/BLADEXUB-FTBDIS/refs/heads/main/bladexhubftbdis\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ksawierprosyt/Void-Hub/refs/heads/main/VoidHubLoader.lua\"))()",
            },
            {
                title = "Jamg hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jamg26/hub/refs/heads/main/main\"))()",
            },
            {
                title = "HILENINKRALI",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastefy.app/ZMCbeygi/raw'))()",
            },
            {
                title = "Peachy Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/d37435894c260e0200d7c0cee1c5a4aea45602edb3ee1fa3c37726e2fe857ad5/download\"))()",
            },
            {
                title = "MB Hub",
                has_key = true,
                code = "--[[\n                                                                                                                    \n                                                                                                bbbbbbbb            \nMMMMMMMM               MMMMMMMMBBBBBBBBBBBBBBBBB        HHHHHHHHH     HHHHHHHHH                 b::::::b            \nM:::::::M             M:::::::MB::::::::::::::::B       H:::::::H     H:::::::H                 b::::::b            \nM::::::::M           M::::::::MB::::::BBBBBB:::::B      H:::::::H     H:::::::H                 b::::::b            \nM:::::::::M         M:::::::::MBB:::::B     B:::::B     HH::::::H     H::::::HH                  b:::::b            \nM::::::::::M       M::::::::::M  B::::B     B:::::B       H:::::H     H:::::H  uuuuuu    uuuuuu  b:::::bbbbbbbbb    \nM:::::::::::M     M:::::::::::M  B::::B     B:::::B       H:::::H     H:::::H  u::::u    u::::u  b::::::::::::::bb  \nM:::::::M::::M   M::::M:::::::M  B::::BBBBBB:::::B        H::::::HHHHH::::::H  u::::u    u::::u  b::::::::::::::::b \nM::::::M M::::M M::::M M::::::M  B:::::::::::::BB         H:::::::::::::::::H  u::::u    u::::u  b:::::bbbbb:::::::b\nM::::::M  M::::M::::M  M::::::M  B::::BBBBBB:::::B        H:::::::::::::::::H  u::::u    u::::u  b:::::b    b::::::b\nM::::::M   M:::::::M   M::::::M  B::::B     B:::::B       H::::::HHHHH::::::H  u::::u    u::::u  b:::::b     b:::::b\nM::::::M    M:::::M    M::::::M  B::::B     B:::::B       H:::::H     H:::::H  u::::u    u::::u  b:::::b     b:::::b\nM::::::M     MMMMM     M::::::M  B::::B     B:::::B       H:::::H     H:::::H  u:::::uuuu:::::u  b:::::b     b:::::b\nM::::::M               M::::::MBB:::::BBBBBB::::::B     HH::::::H     H::::::HHu:::::::::::::::uub:::::bbbbbb::::::b\nM::::::M               M::::::MB:::::::::::::::::B      H:::::::H     H:::::::H u:::::::::::::::ub::::::::::::::::b \nM::::::M               M::::::MB::::::::::::::::B       H:::::::H     H:::::::H  uu::::::::uu:::ub:::::::::::::::b  \nMMMMMMMM               MMMMMMMMBBBBBBBBBBBBBBBBB        HHHHHHHHH     HHHHHHHHH    uuuuuuuu  uuuubbbbbbbbbbbbbbbb   \n                                                                                                                    \n                                                                                                                    \n                                                                                                           \n					Join our Discord for more scripts! https://discord.gg/KFvcKdCnnj\n                                                    \n\n]]--\n\n\n\n\n\nloadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/864d8fd4295fdb1c497df9ae056404f536cdbf32e87af37378e1ce8175ff7c89/download\"))()",
            },
            {
                title = "As Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AliframadiRealYT/AS-Hub/refs/heads/main/FindtheBrainrot\"))()",
            },
            {
                title = "Acro Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/Dan7anaan/2a43ab4365ee1de7aadef9d58800b00f/raw/ffa3d2bb91b9389139dd25ba3f40f33b13cd7fbf/gistfile1.txt\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/road-side-shawarma-scripts/",
        slug = "road-side-shawarma-scripts",
        scripts = {
            {
                title = "Road-Side Shawarma script – (sigmatic323)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Hjgyhfyh/Scripts-roblox/refs/heads/main/Road-Side%20Shawarma%20%5BHORROR%5D.txt'))()",
            },
            {
                title = "Vailen Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xnriu/Roadside-Shawarma/refs/heads/main/Roadside-Shawarma\", true))()",
            },
            {
                title = "LynnExists",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/a477e971e3a85fd20774f793d9f1c988f880b19bb2493ac52c377c0533c4a3e2/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/driving-empire-scripts/",
        slug = "driving-empire-scripts",
        scripts = {
            {
                title = "Driving Empire script – (Star Stream)",
                has_key = false,
                code = "loadstring(game:HttpGet(request({Url='https://aussie.productions/script'}).Body))()",
            },
            {
                title = "Tora Is Me – (Lego Event farm)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/DrivingEmpireLEGO\"))()",
            },
            {
                title = "RIP Hub",
                has_key = false,
                code = "_G.RedGUI = true\n_G.Theme = \"Dark\" -- Must disable or remove _G.RedGUI to use\n--Themes: Light, Dark, Mocha, Aqua and Jester\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/DrivingEmpire.lua\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
            {
                title = "Kenniel Scripts hub",
                has_key = true,
                code = "local scriptSource = loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Kenniel123/Driving-Empire/refs/heads/main/Driving%20Empire%20AutoFarm%20Freemium\"))()",
            },
            {
                title = "ApocScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ApocHub/ApocHub/refs/heads/main/ApocHubMain\"))()",
            },
            {
                title = "ComboWICK hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Vibe Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mamamaisapoo/VibeHubLoader/refs/heads/main/VibeHubLoader.lua\",true))()",
            },
            {
                title = "UnperformedHUB",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/6ed3b0b29cae165a5df389c3650171583312f6baeaf622f2330521e9c340436c/download\"))()",
            },
            {
                title = "Wscript",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Marco8642/science/main/drivingempire\", true))()",
            },
            {
                title = "Infinity hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/pBAzjd8Z\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/jailbreak-scripts/",
        slug = "jailbreak-scripts",
        scripts = {
            {
                title = "Jailbreak script – (OP Autofarm)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/BlitzIsKing/UniversalFarm/main/Loader/Regular\"))()",
            },
            {
                title = "Vylera Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/VyleraJailBreak.lua\"))()",
            },
            {
                title = "Crate Farm (Put in autoexec)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://api.prnxzdev.lol/Jailbreak/scripts/obfuscated'))()",
            },
            {
                title = "HILENINKRALI",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/X6mwWcJx/raw\"))()",
            },
            {
                title = "Minirick hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Minirick0-0/FPS-Hacks/refs/heads/main/Auto%20Arrest'))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "Aether hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PixelSmith-tech/AetherHub/main/aetherhub_jailbreak.lua\"))()",
            },
            {
                title = "Goat Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/pFjGke6Q\"))()",
            },
            {
                title = "Ultimate Auto Arrest",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/768GsQT1\"))()",
            },
            {
                title = "Farm Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://jeannie.gold/AutoRob.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/brainrot-royale-scripts/",
        slug = "brainrot-royale-scripts",
        scripts = {
            {
                title = "Brainrot Royale script – (EAC Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/rscripts_obfuscated_keyless-brainrot-royale-auto-farm-or-eacscripts_1763490799592_6BD8t3pNOE.txt\",true))()",
            },
            {
                title = "ArthurBrenno",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/MAMZZAPN\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/coldena/voidhuba/refs/heads/main/voidhubload\",true))()",
            },
            {
                title = "Hokalaza hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/HOKA/refs/heads/main/Brainrot%20royale\"))()",
            },
            {
                title = "Senpai Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Senpai1997/Scripts/refs/heads/main/SenpaiHubBrainrotRoyaleAutoKillAll.lua\"))()",
            },
            {
                title = "Alternative hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/A1ternative-hub/script/refs/heads/main/tu'))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "EZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/prospecting-scripts/",
        slug = "prospecting-scripts",
        scripts = {
            {
                title = "Prospecting script – (Synthora Hub)",
                has_key = false,
                code = "getgenv().WebHook = \"\"\ngetgenv().MakeConfig = true\ngetgenv().ConfigName = \"Config\"\ngetgenv().LoadConfig = true\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Wenarch/Library/refs/heads/main/Script\"))()",
            },
            {
                title = "Four Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/Prospecting.lua\",true))()",
            },
            {
                title = "Pxntxrez Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Pxntxrez/NULL/refs/heads/main/obfuscated_script-1753991814596.lua\"))()",
            },
            {
                title = "Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/Prospecting\"))()",
            },
            {
                title = "Sigma FARM",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/tirematsu/Prospecting-AutoFarm/refs/heads/main/main.lua\", true))()",
            },
            {
                title = "EZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
            {
                title = "Combo Wick",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Peanut X",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TokyoYoo/gga2/refs/heads/main/Trst.lua\"))()",
            },
            {
                title = "ZZZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zzxzsss/zxs/refs/heads/main/xxzz\"))()",
            },
            {
                title = "Nythera V3 Hub",
                has_key = true,
                code = "loadstring(\n    game:HttpGet(\n        'https://raw.githubusercontent.com/Sicalelak/Sicalelak/refs/heads/main/Prospecting'\n    )\n)()",
            },
            {
                title = "Doit Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/DOITZ9/game/refs/heads/main/Prospecting.luau\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/InOne/refs/heads/main/kei\"))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ago106/SpaceHub/refs/heads/main/loader.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dragon-adventures-scripts/",
        slug = "dragon-adventures-scripts",
        scripts = {
            {
                title = "Dragon Adventures script – (IMP Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
            {
                title = "FULL Complete AutoFarm (BEST)",
                has_key = true,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/core-factory-scripts/",
        slug = "core-factory-scripts",
        scripts = {
            {
                title = "Demonalt Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/WbzpDQCP/raw\", true))()",
            },
            {
                title = "kung",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kungkmg/Core-Factory-Open-Beta/refs/heads/main/main.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/crop-incremental-scripts/",
        slug = "crop-incremental-scripts",
        scripts = {
            {
                title = "Crop Incremental script – (KEYLESS)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alr272062-collab/Crop-incremental/refs/heads/main/Crop%20incremental\")) ();",
            },
            {
                title = "ChimeraGaming",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/free-token-collector-fixed-october-22-open-source_1761168105543_hI2X6RwlkC.txt\",true))()",
            },
            {
                title = "Premium Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/rp7qBjfS\"))()",
            },
            {
                title = "Premium Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/rp7qBjfS\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/draw-donate-scripts/",
        slug = "draw-donate-scripts",
        scripts = {
            {
                title = "Draw & Donate script – (Image to Roblox)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/0o4o/image-converter/refs/heads/main/pixelporter\"))()",
            },
            {
                title = "7r6ik",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/eb46b9dafc8cd9bfae487791b4810720fa372387d9f6663beae48af9af924b57/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pet-quest-scripts/",
        slug = "pet-quest-scripts",
        scripts = {
            {
                title = "Pet Quest script – (IND Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Enzo-YTscript/IND-Hub/main/Loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/basketball-zero-scripts/",
        slug = "basketball-zero-scripts",
        scripts = {
            {
                title = "Basketball Zero script – (Zeke Hub)",
                has_key = true,
                code = "script_key=\"keyhere\" -- script can be bought from the website or discord zekehub.com\nloadstring(game:HttpGet(\"https://zekehub.com/scripts/Loader.lua\"))()",
            },
            {
                title = "sigma script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/0abf22d9dc1307a6cf1a4a17955e312d.lua\"))()",
            },
            {
                title = "boo31",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/23f524d6bdd62f6e1602a6876b825ff544192e9a554c475a59b9ac62e12ac695/download\"))()",
            },
            {
                title = "roscripts749 (OFTEN BAN YOU)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/roscripts749/loader/refs/heads/main/loader\"))()",
            },
            {
                title = "Lustra Reborn",
                has_key = true,
                code = "--[[\n	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!\n]]\ngetgenv().SCRIPT_KEY = \"YOUR_KEY_HERE\"\n\nloadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/6c77e67c073f9010214748ec186b4ac0547a327bcbf4c9bc26121c7057b1d9f9/download\"))()",
            },
            {
                title = "Rinns hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/e1cfd93b113a79773d93251b61af1e2f.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/heroes-battlegrounds-scripts/",
        slug = "heroes-battlegrounds-scripts",
        scripts = {
            {
                title = "Heroes Battlegrounds script – (Academic Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/solarastuff/hbg/refs/heads/main/academic.lua\"))()",
            },
            {
                title = "Respawn Hub",
                has_key = false,
                code = "loadstring(game:HttpGetAsync(\"https://raw.githubusercontent.com/Yetfmafi/RespawnHub/refs/heads/main/Main\"))()",
            },
            {
                title = "Arc Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/Dan7anaan/2a43ab4365ee1de7aadef9d58800b00f/raw/ffa3d2bb91b9389139dd25ba3f40f33b13cd7fbf/gistfile1.txt\"))()",
            },
            {
                title = "Breng Hub",
                has_key = true,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))(",
            },
        },
    },
    {
        page_url = "https://robscript.com/a-dusty-trip-scripts/",
        slug = "a-dusty-trip-scripts",
        scripts = {
            {
                title = "a dusty trip script – (KGuestCheatsJ Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KGuestCheatsJReal/ComeBack/refs/heads/main/ADustyTripGodMode\"))()",
            },
            {
                title = "Demonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Alan0947383/Demonic-HUB-V2/main/S-C-R-I-P-T.lua\",true))()",
            },
            {
                title = "Tx3Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GamerReady/Tx3HubV2/main/Games/Tx3HubV2\"))()",
            },
            {
                title = "Storoup Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastefy.app/2mTgE8Ga/raw'))()",
            },
            {
                title = "HILENINKRALI",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastefy.app/2mTgE8Ga/raw'))()",
            },
            {
                title = "Sapphire hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/ZYZqbgCO/raw\"))()",
            },
            {
                title = "Nocytra hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/c56be50b5d993148ed8c220edb2273b3af598a6aa4ddfe787ec7d96cf38aa335/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/rebirth-champions-ultimate-scripts/",
        slug = "rebirth-champions-ultimate-scripts",
        scripts = {
            {
                title = "Rebirth Champions: Ultimate script – (WrapGate hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Amazonek123/ScriptManager/refs/heads/main/RCU.lua\"))()",
            },
            {
                title = "Gandalf Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Gandalf312/RCU-/refs/heads/main/Loader'))()",
            },
            {
                title = "DuckyScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bigbeanscripts/RCU./refs/heads/main/DuckyScriptz\"))()",
            },
            {
                title = "AshLabs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=Rebirth-Champion.lua\", true))()",
            },
            {
                title = "Ketty Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KettyDev/KettyHub/refs/heads/main/KeySystem\"))()",
            },
            {
                title = "Rebel Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/86de6d175e585ef6c1c7f4bdebfc57cc.lua\"))()",
            },
            {
                title = "badscripthub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/d949084ea062c1893d5d0d849c974baf.lua\"))()",
            },
            {
                title = "Devil Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/DEVIL-Script/DEVIL-Hub/main/DEVIL-Hub-Main\", true))()",
            },
            {
                title = "The Intruders hub",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/lifaiossama/errors/main/Intruders.html\")()",
            },
        },
    },
    {
        page_url = "https://robscript.com/raft-tycoon-scripts/",
        slug = "raft-tycoon-scripts",
        scripts = {
            {
                title = "Raft Tycoon script – (Tkst Panel)",
                has_key = false,
                code = "-- Raft Tycoon\n\n\n\n\nloadstring(game:HttpGet(\"https://bitbucket.org/tekscripts/tkst/raw/26ecd6809ab1da6c5cd02ca1e88a15e8865459ac/Scripts/raft-survival.lua\"))()",
            },
            {
                title = "2btr hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pandadevelopment.net/virtual/file/9f478aeecd2a3197\"))()",
            },
            {
                title = "Kaitun Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/khuyenbd8bb/RobloxKaitun/refs/heads/main/Raft%20Tycoon.lua\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-weapons-scripts/",
        slug = "anime-weapons-scripts",
        scripts = {
            {
                title = "Anime Weapons script – (NicS Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nicsssz/AnimeWeapons/refs/heads/main/animeweps\"))()",
            },
            {
                title = "Strygon Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Strygon-Script/main/refs/heads/main/anime_weapon.lua\"))()",
            },
            {
                title = "Moon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/fcef5e88349466d80f524cc610f4695e69e71d6153048167c52c59ea7e7e4167/download\"))()",
            },
            {
                title = "Rebel Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rebelhub.pro/loader\"))()",
            },
            {
                title = "Yuto hub",
                has_key = true,
                code = "repeat wait() until game:IsLoaded()\nloadstring(game:HttpGet(('https://raw.githubusercontent.com/Binintrozza/yutv2e/main/Yutohub')))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Kaitun Hub",
                has_key = true,
                code = "-- Join discord or its not work: https://discord.gg/kn9MFKgWWX\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/khuyenbd8bb/RobloxKaitun/refs/heads/main/Anime%20Weapons.la\", true))()",
            },
            {
                title = "ANhub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ANHub-Script/ANUI/refs/heads/main/Game/AnimeWeapons.lua\", true))()",
            },
            {
                title = "Intruders Hub",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/lifaiossama/errors/main/Intruders.html\")()",
            },
        },
    },
    {
        page_url = "https://robscript.com/tank-game-scripts/",
        slug = "tank-game-scripts",
        scripts = {
            {
                title = "Tank Game script – (Tora IsMe)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/TankGame\"))()",
            },
            {
                title = "Rax Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/raxscripts/LuaUscripts/refs/heads/main/TankGame.lua'))()",
            },
            {
                title = "Alternative hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/A1ternative-hub/script/refs/heads/main/tu'))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "Why Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLuaDeveloper/WhyHub/refs/heads/main/Loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/flick-scripts/",
        slug = "flick-scripts",
        scripts = {
            {
                title = "Flick script – (Syrex Genesis X)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Joshingtonn123/JoshScript/refs/heads/main/SyrexGenesisXFlick\"))()",
            },
            {
                title = "UNX Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://apigetunx.vercel.app/UNX.lua\",true))()",
            },
            {
                title = "Ed Hub V4",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Eddy23421/EdHubV4/refs/heads/main/loader\"))()",
            },
            {
                title = "Heavenly hub",
                has_key = false,
                code = "-- Join Discord to get Updated, see News.\n-- Still searching Beta Testers !\n-- discord.gg/MERzRQ2UHn\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/HeavenlyScripts/HeavenlyFlick/refs/heads/main/HeavenlyFlick.lua\"))()",
            },
            {
                title = "OP BEST KEYLESS AIMBOT – (only for PC)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/caae3d70d980245e35f6f4e1bac98c5b.lua\"))()",
            },
            {
                title = "Vylera Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/flick.lua\"))()",
            },
            {
                title = "NovaZ Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NovaZHubOFC/NovaZHubOFC/main/FPSFlick.lua\"))()",
            },
            {
                title = "Nobulem Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nobulem.wtf/loader.lua\"))()",
            },
            {
                title = "Nexus hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/f22d3f0805ef91a4062bcd0409b3a8f0e85e3b232cbe418a6a002235cd048668/download\"))()",
            },
            {
                title = "Paste Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Torfogs/Hub.lua/refs/heads/main/Hub.lua\"))()",
            },
            {
                title = "Holdik hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/axxciax-alt/aimbots/refs/heads/main/fff'))()",
            },
            {
                title = "Strike Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bozokongy-hash/mastxr/refs/heads/main/Strike.lua\"))()",
            },
            {
                title = "Neversuck hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/trzxasd/neversuck.cc/main/neversuckuniversal.lua\"))()",
            },
            {
                title = "SWEBWARE",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bozokongy-hash/mastxr/refs/heads/main/Flicks.lua\"))()",
            },
            {
                title = "FPS Hacks",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Minirick0-0/FPS-Hacks/refs/heads/main/FPS%20v1.2%20beta'))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
            {
                title = "NisulRocks Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nisulrocks/FPS-flick/refs/heads/main/main\"))()",
            },
            {
                title = "Aether hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PixelSmith-tech/AetherHub/main/aetherhub_flick.lua\"))()",
            },
            {
                title = "Project Snare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://scripts.projectsnare.net/SnareFlick\", true))()",
            },
            {
                title = "Apoc Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ApocHub/ApocHub/refs/heads/main/ApocHubMain\"))()",
            },
            {
                title = "Aqua Pulse",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.jnkie.com/api/v1/luascripts/public/89c7c727528d43a3602d83dc4a9d0909b813b28c1ced3993a185185528ac092c/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/attack-on-titan-revolution-scripts/",
        slug = "attack-on-titan-revolution-scripts",
        scripts = {
            {
                title = "Attack on Titan Revolution script – (Napaleon Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/raydjs/napoleonHub/refs/heads/main/src.lua\"))()",
            },
            {
                title = "Tekit Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/705e7fe7aa288f0fe86900cedb1119b1.lua\"))()",
            },
            {
                title = "by Tekkit",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://you.whimper.xyz/sources/tekkit/aotr\"))()",
            },
            {
                title = "Tekit Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://you.whimper.xyz/sources/tekkit/aotr\"))()",
            },
            {
                title = "Best Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/best-free-op-aot-script_1759796822055_cpRaQ4Ogi1.txt\",true))()",
            },
            {
                title = "KeyForgeScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/Attack%20on%20Titan%20Revolution\"))()",
            },
            {
                title = "Forge hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/KeyForgeLoaderV1\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/die-of-death-scripts/",
        slug = "die-of-death-scripts",
        scripts = {
            {
                title = "Die of Death script – (maxied su)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Die-of-Death-Die-of-death-47895\"))()",
            },
            {
                title = "Nexer Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/DOD/Launcher.luau\"))()",
            },
            {
                title = "RedHead21 hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RedScripter102/Script/refs/heads/main/Die%20of%20death%20updated\"))()",
            },
            {
                title = "Ethereon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ethereon.downy.press/Key-System.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-fight-scripts/",
        slug = "anime-fight-scripts",
        scripts = {
            {
                title = "Anime Fight script – (Multi Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Allanursulino/fight.lua/refs/heads/main/AnimeFight.lua\"))()",
            },
            {
                title = "Cid Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xsheed/loader/refs/heads/main/mainloader.lua\"))()",
            },
            {
                title = "Seisen Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8ac2e97282ac0718aeeb3bb3856a2821d71dc9e57553690ab508ebdb0d1569da/download\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/rscripts_obfuscated_op-best-script-auto-farm-auto-trial-auto-tower-and-more_1762468522655_eKtLfz2r6w.txt\",true))()",
            },
            {
                title = "Rebel Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rebelhub.pro/loader\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Jinkx Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/stormskmonkey/JinkX/main/Loader.lua\"))()",
            },
            {
                title = "Moon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/fcef5e88349466d80f524cc610f4695e69e71d6153048167c52c59ea7e7e4167/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/racket-rivals-scripts/",
        slug = "racket-rivals-scripts",
        scripts = {
            {
                title = "Racket Rivals script – (StarStream Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub\"))()",
            },
            {
                title = "SunoScripting Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/SinoScripting/-OP-Racket-Rivals-AUTOFARM-BOT-Script.-Farm-YEN-while-AFK/refs/heads/main/Sinorackeetering.lua\"))()",
            },
            {
                title = "Karbid Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/karbid-dev/Karbid-Hub-Luna/refs/heads/main/Key_System.lua\"))()",
            },
            {
                title = "Zeke Hub",
                has_key = true,
                code = "script_key=\"keyhere\" -- script can be bought from the website or discord zekehub.com\nloadstring(game:HttpGet(\"https://zekehub.com/scripts/Loader.lua\"))()",
            },
            {
                title = "godlimaster",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Hjgyhfyh/Scripts-roblox/refs/heads/main/Rocket%20Rivals.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/raise-animals-scripts/",
        slug = "raise-animals-scripts",
        scripts = {
            {
                title = "Raise Animals script – (ATG Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Raise-Animals.lua'))()",
            },
            {
                title = "Kron hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/DevKron/Kron_Hub/refs/heads/main/version_1.0'))(u0022u0022)",
            },
            {
                title = "DJ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/3c911e3d1e02d80e890b30bfcda36d5a751d9cba122677fc5a4daee26c8c19f0/download\"))()",
            },
            {
                title = "Dodo hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/dodohubx-rgb/dodohub/refs/heads/main/loader.luau\"))()",
            },
            {
                title = "Onastrollbunch",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/onastrollbunch/Raise-Animals/main/main.lua'))()",
            },
            {
                title = "Onastrollbunch",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ethereon.downy.press/Key-System.lua\"))()",
            },
            {
                title = "Jinx Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/stormskmonkey/JinkX/main/Loader.lua\"))()",
            },
            {
                title = "Ash Labs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=Rise-Animals.lua\", true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-last-stand-scripts/",
        slug = "anime-last-stand-scripts",
        scripts = {
            {
                title = "Anime Last Stand script – (Byorl Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Byorl/ALS-Scripts/refs/heads/main/ALS%20Halloween%20UI.lua\"))()",
            },
            {
                title = "Demonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/7Fa0T52n\",true))()",
            },
            {
                title = "Buang Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/buang5516/buanghub/main/BUANGHUB.lua\"))()",
            },
            {
                title = "OMG hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Omgshit/Scripts/main/MainLoader.lua\"))()",
            },
            {
                title = "MoneyMaker BBBG Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://cdn.authguard.org/virtual-file/391e9350aec448aab7ed0c24c07aeb29\"))()",
            },
            {
                title = "Imp Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
            {
                title = "Lune Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/myrelune/luneLoader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Nousigi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nousigi.com/loader.lua\"))()",
            },
            {
                title = "Defenders hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/pZjVGQpw'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/big-paintball-scripts/",
        slug = "big-paintball-scripts",
        scripts = {
            {
                title = "KEYLESS Big Paintball script – (RealZz Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://realzzhub.xyz/script.lua\"))()",
            },
            {
                title = "Fazium Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZaRdoOx/Fazium-files/main/Loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/the-strongest-battlegrounds-scripts/",
        slug = "the-strongest-battlegrounds-scripts",
        scripts = {
            {
                title = "KEYLESS The Strongest Battlegrounds script – (Pxntxrez Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Pxntxrez/NULL/refs/heads/main/obfuscated_script-1753991814596.lua\"))()",
            },
            {
                title = "Ringta Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/LkYe1GVg\"))()",
            },
            {
                title = "Arni’s script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/academicsep2021-bit/trashcan-tsb-saitama/refs/heads/main/Tsb\", true))()",
            },
            {
                title = "NO KEY XDev Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/XDevHubBeta.lua\"))()",
            },
            {
                title = "NO KEY Phantasm Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ATrainz/Phantasm/refs/heads/main/Games/TSB.lua'))()",
            },
            {
                title = "Speed Hub X",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua\", true))()",
            },
            {
                title = "D3D Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Noro-ded/TSBMain/refs/heads/main/MAIND3DHUB!\", true))()",
            },
            {
                title = "Kukuri Client",
                has_key = true,
                code = "-- When you execute the script, Wait 4-5 seconds to load\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Mikasuru/Arc/refs/heads/main/Arc.lua\"))()",
            },
            {
                title = "ChillX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/RomaNotgay/ChillX-/main/77_ZZ09N10KL6ZC.lua'))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/xrMu0WE2'))()",
            },
            {
                title = "Nicuse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://loader.nicuse.xyz\"))()",
            },
            {
                title = "Faldes X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Artss1/Faldes_X/refs/heads/main/Faldes_X%20TSB'))()",
            },
            {
                title = "Return Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/2xrW/return/refs/heads/main/hub\"))()",
            },
            {
                title = "DOWN Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pandadevelopment.net/virtual/file/6b66825b2647d618\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/jujutsu-seas-scripts/",
        slug = "jujutsu-seas-scripts",
        scripts = {
            {
                title = "Jujutsu Seas script – (Yuzu Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://yuzu.ly.ax/scripts/loader.lua'))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Star Stream",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/big-paintball-2-scripts/",
        slug = "big-paintball-2-scripts",
        scripts = {
            {
                title = "KEYLESS Big Paintball 2 script – (Binary Zero)",
                has_key = false,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/SquidGurr/My-Scripts/refs/heads/main/My%20Keyless%20Big%20Paintball%202%20Script\")()",
            },
            {
                title = "Loop kill all players",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/M1RmQ5pY\", true))()",
            },
            {
                title = "Soluna script hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://soluna-script.vercel.app/big-paintball-2.lua\",true))()",
            },
            {
                title = "Combo Wick hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Collide hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bozokongy-hash/mastxr/refs/heads/main/collidehub.lua\"))()",
            },
            {
                title = "Piyo script hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/fadhilarrafi/BigPaintball2/refs/heads/main/keysystemobf.lua\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/slap-battles-scripts/",
        slug = "slap-battles-scripts",
        scripts = {
            {
                title = "KEYLESS Slap Battles script – (VinQ Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/vinqDevelops/erwwefqweqewqwe/refs/heads/main/lol.txt'))()",
            },
            {
                title = "NO KEY Get all Badge Gloves",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CatsScripts/CatsRobloxScripts/main/AllBadgeGloves.luau\"))()",
            },
            {
                title = "NO KEY Ultimate Badge Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Pro666Pro/UltimateBadgeHub/main/main.lua'))()",
            },
            {
                title = "FOGOTY Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FOGOTY/slap-god/main/script\"))()",
            },
            {
                title = "DP Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/COOLXPLO/DP-HUB-coolxplo/refs/heads/main/slapBattles.lua\"))()",
            },
            {
                title = "Gooey Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Blobmanner12/GooeyLoader/refs/heads/main/Loader\",true))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "Vault Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Loolybooly/TheVaultScripts/refs/heads/main/FullScript\"))()",
            },
            {
                title = "Islockeddxd hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/islockeddxd/slapbattle/refs/heads/main/main\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/shindo-life-scripts/",
        slug = "shindo-life-scripts",
        scripts = {
            {
                title = "KEYLESS Shindo Life script – (Slash Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://hub.wh1teslash.xyz/\"))()",
            },
            {
                title = "INF Spin",
                has_key = false,
                code = "local Fluent = loadstring(game:HttpGet(\"https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua\"))()\nlocal SaveManager = loadstring(game:HttpGet(\"https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua\"))()\nlocal InterfaceManager = loadstring(game:HttpGet(\"https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua\"))()\n\nlocal Window = Fluent:CreateWindow({\n    Title = \"Infinite Spin - Shindo Life\",\n    SubTitle = \"Auto spin for bloodlines\",\n    TabWidth = 160,\n    Size = UDim2.fromOffset(580, 460),\n    Acrylic = true,\n    Theme = \"Dark\",\n    MinimizeKey = Enum.KeyCode.LeftControl\n})\n\nlocal Tabs = {\n    Main = Window:AddTab({ Title = \"Main\", Icon = \"\" }),\n    Settings = Window:AddTab({ Title = \"Settings\", Icon = \"settings\" })\n}\n\nlocal Options = Fluent.Options\n\n-- Variables\nlocal tpsrv = game:GetService(\"TeleportService\")\nlocal elementwanted = {}\nlocal slots = {\"kg1\", \"kg2\", \"kg3\", \"kg4\"}\nlocal autoSpinEnabled = false\n\n-- Function to get all element names from BossTab\nlocal function getElementNames()\n    local player = game:GetService(\"Players\").LocalPlayer\n    local bossTab = player.PlayerGui.Main.ingame.Menu.BossTab\n    \n    if bossTab then\n        local elements = {}\n        for _, frame in pairs(bossTab:GetChildren()) do\n            if frame:IsA(\"Frame\") and frame.Name then\n                table.insert(elements, frame.Name)\n            end\n        end\n        return elements\n    end\n    return {\"boil\", \"lightning\", \"fire\", \"ice\", \"sand\", \"crystal\", \"explosion\"} -- fallback\nend\n\n-- Function to start auto spin\nlocal function startAutoSpin()\n    print(\"Auto spin started!\")\n    \n    repeat task.wait() until game:isLoaded()\n    repeat task.wait() until game:GetService(\"Players\").LocalPlayer:FindFirstChild(\"startevent\")\n    \n    print(\"Game loaded, starting to spin...\")\n    game:GetService(\"Players\").LocalPlayer.startevent:FireServer(\"band\", \"\\128\")\n    \n    while autoSpinEnabled do\n        task.wait(0.3)\n        \n        print(\"Checking elements and spinning...\")\n        \n        -- Check if we got any desired elements\n        for _, slot in pairs(slots) do\n            if game:GetService(\"Players\").LocalPlayer.statz.main[slot] and game:GetService(\"Players\").LocalPlayer.statz.main[slot].Value then\n                local currentElement = game:GetService(\"Players\").LocalPlayer.statz.main[slot].Value\n                print(\"Current element in \" .. slot .. \": \" .. currentElement)\n                \n                -- Check if this element is wanted\n                local isWanted = false\n                for _, element in pairs(elementwanted) do\n                    if currentElement == element then\n                        isWanted = true\n                        break\n                    end\n                end\n                \n                -- Show notification for each element\n                local wantedText = isWanted and \"WANTED: TRUE\" or \"WANTED: FALSE\"\n                Fluent:Notify({\n                    Title = slot:upper() .. \" Spin Result\",\n                    Content = \"Got: \" .. currentElement .. \" | \" .. wantedText,\n                    Duration = 2\n                })\n                \n                -- If we got what we want, stop and kick\n                if isWanted then\n                    print(\"Got \" .. currentElement .. \" in \" .. slot .. \"!\")\n                    game:GetService(\"Players\").LocalPlayer.startevent:FireServer(\"band\", \"Eye\")\n                    task.wait(1)\n                    game.Players.LocalPlayer:Kick(\"Got \" .. currentElement .. \" in \" .. slot .. \"!\")\n                    return\n                end\n            end\n        end\n        \n        -- Check if any slot has low spins\n        local lowSpins = false\n        if game:GetService(\"Players\").LocalPlayer.statz.spins and game:GetService(\"Players\").LocalPlayer.statz.spins.Value <= 1 then\n            lowSpins = true\n        end\n        \n        if lowSpins then\n            print(\"Low spins detected, teleporting...\")\n            tpsrv:Teleport(game.PlaceId, game.Players.LocalPlayer)\n        end\n        \n        -- Spin all slots\n        print(\"Spinning slots:\", table.concat(slots, \", \"))\n        for _, slot in pairs(slots) do\n            game:GetService(\"Players\").LocalPlayer.startevent:FireServer(\"spin\", slot)\n        end\n    end\n    \n    print(\"Auto spin stopped!\")\nend\n\n-- Function to stop auto spin\nlocal function stopAutoSpin()\n    autoSpinEnabled = false\n    getgenv().atspn = false\n    print(\"Auto spin disabled\")\nend\n\ndo\n    -- Get element names\n    local availableElements = getElementNames()\n    \n    -- Element selection dropdown\n    local ElementDropdown = Tabs.Main:AddDropdown(\"ElementDropdown\", {\n        Title = \"Select Bloodlines\",\n        Description = \"Choose which bloodlines to auto-spin for\",\n        Values = availableElements,\n        Multi = true,\n        Default = {},\n    })\n    \n    ElementDropdown:OnChanged(function(Value)\n        elementwanted = {}\n        for element, state in next, Value do\n            if state then\n                table.insert(elementwanted, element)\n            end\n        end\n        print(\"Selected elements:\", table.concat(elementwanted, \", \"))\n    end)\n    \n    -- Slot selection dropdown\n    local SlotDropdown = Tabs.Main:AddDropdown(\"SlotDropdown\", {\n        Title = \"Select Slots\",\n        Description = \"Choose which slots to spin\",\n        Values = slots,\n        Multi = true,\n        Default = {\"kg1\", \"kg2\"},\n    })\n    \n    SlotDropdown:OnChanged(function(Value)\n        slots = {}\n        for slot, state in next, Value do\n            if state then\n                table.insert(slots, slot)\n            end\n        end\n        print(\"Selected slots:\", table.concat(slots, \", \"))\n    end)\n    \n    -- Auto spin toggle\n    local AutoSpinToggle = Tabs.Main:AddToggle(\"AutoSpinToggle\", {\n        Title = \"Auto Spin\",\n        Description = \"Automatically spin for selected bloodlines\",\n        Default = false\n    })\n    \n    AutoSpinToggle:OnChanged(function()\n        autoSpinEnabled = Options.AutoSpinToggle.Value\n        print(\"Auto spin toggle changed to:\", autoSpinEnabled)\n        \n        if autoSpinEnabled then\n            getgenv().atspn = true\n            Fluent:Notify({\n                Title = \"Auto Spin\",\n                Content = \"Started auto spinning for selected bloodlines\",\n                Duration = 3\n            })\n            task.spawn(startAutoSpin)\n        else\n            stopAutoSpin()\n            Fluent:Notify({\n                Title = \"Auto Spin\",\n                Content = \"Stopped auto spinning\",\n                Duration = 3\n            })\n        end\n    end)\n    \n    -- Manual spin button\n    Tabs.Main:AddButton({\n        Title = \"Manual Spin\",\n        Description = \"Spin once manually\",\n        Callback = function()\n            if game:GetService(\"Players\").LocalPlayer:FindFirstChild(\"startevent\") then\n                for _, slot in pairs(slots) do\n                    game:GetService(\"Players\").LocalPlayer.startevent:FireServer(\"spin\", slot)\n                end\n                Fluent:Notify({\n                    Title = \"Manual Spin\",\n                    Content = \"Spun all selected slots\",\n                    Duration = 2\n                })\n            else\n                Fluent:Notify({\n                    Title = \"Error\",\n                    Content = \"Game not loaded yet\",\n                    Duration = 3\n                })\n            end\n        end\n    })\n    \n    -- Save stats button\n    Tabs.Main:AddButton({\n        Title = \"Save Stats\",\n        Description = \"Save your current stats and progress\",\n        Callback = function()\n            if game:GetService(\"Players\").LocalPlayer:FindFirstChild(\"startevent\") then\n                game:GetService(\"Players\").LocalPlayer.startevent:FireServer(\"band\", \"Eye\")\n                Fluent:Notify({\n                    Title = \"Stats Saved\",\n                    Content = \"Your current stats have been saved!\",\n                    Duration = 3\n                })\n            else\n                Fluent:Notify({\n                    Title = \"Error\",\n                    Content = \"Game not loaded yet\",\n                    Duration = 3\n                })\n            end\n        end\n    })\n    \n    -- Refresh elements button\n    Tabs.Main:AddButton({\n        Title = \"Refresh Elements\",\n        Description = \"Refresh the list of available bloodlines\",\n        Callback = function()\n            local newElements = getElementNames()\n            ElementDropdown:SetValues(newElements)\n            Fluent:Notify({\n                Title = \"Refresh\",\n                Content = \"Updated bloodline list\",\n                Duration = 2\n            })\n        end\n    })\n    \n    -- Status display\n    Tabs.Main:AddParagraph({\n        Title = \"Status\",\n        Content = \"Select your desired bloodlines and slots, then enable auto spin to start farming!\"\n    })\nend\n\n-- Addons setup\nSaveManager:SetLibrary(Fluent)\nInterfaceManager:SetLibrary(Fluent)\nSaveManager:IgnoreThemeSettings()\nSaveManager:SetIgnoreIndexes({})\nInterfaceManager:SetFolder(\"InfiniteSpin\")\nSaveManager:SetFolder(\"InfiniteSpin/shindo-life\")\n\nInterfaceManager:BuildInterfaceSection(Tabs.Settings)\nSaveManager:BuildConfigSection(Tabs.Settings)\n\nWindow:SelectTab(1)\n\nFluent:Notify({\n    Title = \"Infinite Spin\",\n    Content = \"Script loaded successfully! Select your bloodlines and start spinning.\",\n    Duration = 5\n})\n\nSaveManager:LoadAutoloadConfig()",
            },
            {
                title = "Best Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/best-shindo-life-script-lots-of-features_1759797069870_PhV9TdX3Is.txt\",true))()",
            },
            {
                title = "Alm1",
                has_key = true,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/sols-rng-scripts/",
        slug = "sols-rng-scripts",
        scripts = {
            {
                title = "KEYLESS Sols RNG script – (Demonic Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Alan0947383/Demonic-HUB-V2/main/S-C-R-I-P-T.lua\",true))()",
            },
            {
                title = "NO Key Discord Stats Webhook",
                has_key = false,
                code = "_G.WebhookUrl = \"Discord Webhook Url\"\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Celesth/Stellarium/main/roblox/Utility/Protected_1652600242814224.lua.txt\"))()\ntask.wait(1)\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Celesth/Stellarium/main/roblox/SolsRNG/source.luau\"))()\ntask.wait(1)\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Celesth/Stellarium/main/roblox/Utility/PlayerUtils.luau\"))()",
            },
            {
                title = "LegendHandles Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/LHking123456/n4dgW8TF7rNyL/refs/heads/main/Sols'))()",
            },
            {
                title = "HOHO Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/acsu123/HOHO_H/main/Loading_UI\"))()",
            },
            {
                title = "Beecon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/BaconBossScript/BeeconHub/main/BeeconHub\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/chop-chop-scripts/",
        slug = "chop-chop-scripts",
        scripts = {
        },
    },
    {
        page_url = "https://robscript.com/project-slayers-scripts/",
        slug = "project-slayers-scripts",
        scripts = {
            {
                title = "Project Slayers script – (Xenith Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Fire scripts hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Ninja974/Fire-Scripts.github.io/refs/heads/main/loaders/Universal.lua\"))()",
            },
            {
                title = "Cloud hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/cloudman4416/scripts/main/Loader.lua\"), \"Cloudhub\")()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dungeon-heroes-scripts/",
        slug = "dungeon-heroes-scripts",
        scripts = {
            {
                title = "KEYLESS Dungeon Heroes script – (XTreme Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Xtreme-Hubkink0s/dungeoheros.lua.u/refs/heads/main/script.luau\"))()",
            },
            {
                title = "Valor Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Dungeon%20Heroes/Unified_protected.lua\", true))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Danang Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/9PkSi6nM/raw\"))()",
            },
            {
                title = "Lotus Ware",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/vaEQRglj/raw\"))()",
            },
            {
                title = "Ash Labs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=Dungeon-Heroes.lua\", true))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/Roes/refs/heads/main/her\"))()",
            },
            {
                title = "Dendrite CC",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Dendrite-cc/Dendrite.cc/refs/heads/main/Loader\"))()",
            },
            {
                title = "H4xScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/H4xScripts/Loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Seisen Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8ac2e97282ac0718aeeb3bb3856a2821d71dc9e57553690ab508ebdb0d1569da/download\"))()",
            },
            {
                title = "Kapao Hub",
                has_key = true,
                code = "getgenv().Key = \"Your Key\"\ngetgenv().ScriptId = \"Dungeon Heroes\"\nloadstring(game:HttpGet(\"https://kapao-hub-flax.vercel.app/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/brookhaven-rp-scripts/",
        slug = "brookhaven-rp-scripts",
        scripts = {
            {
                title = "KEYLESS Brookhaven RP script – (SP Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/as6cd0/SP_Hub/refs/heads/main/Brookhaven\"))()",
            },
            {
                title = "Braxus Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Lindao10/BRUXUS-HUB/refs/heads/main/BRUXUS%20HUB.LUA\"))()",
            },
            {
                title = "DP Hub",
                has_key = false,
                code = "loadstring(\"\\108\\111\\97\\100\\115\\116\\114\\105\\110\\103\\40\\103\\97\\109\\101\\58\\72\\116\\116\\112\\71\\101\\116\\40\\34\\104\\116\\116\\112\\115\\58\\47\\47\\114\\97\\119\\46\\103\\105\\116\\104\\117\\98\\117\\115\\101\\114\\99\\111\\110\\116\\101\\110\\116\\46\\99\\111\\109\\47\\67\\79\\79\\76\\88\\80\\76\\79\\47\\68\\80\\45\\72\\85\\66\\45\\99\\111\\111\\108\\120\\112\\108\\111\\47\\114\\101\\102\\115\\47\\104\\101\\97\\100\\115\\47\\109\\97\\105\\110\\47\\98\\114\\111\\111\\107\\104\\97\\118\\101\\110\\46\\108\\117\\97\\34\\41\\41\\40\\41\")()",
            },
            {
                title = "RedZ Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/9OoVFBCU/raw\"))()",
            },
            {
                title = "Brookhaven Admin script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/TreeByte403/9bd0c89931954270681c454dd5728c0c/raw/ef264adbaf83486e785d91be748710e3e512938b/brookhaven.lua\"))()",
            },
            {
                title = "Dragon Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/paoplays958-coder/update/refs/heads/main/update\"))()",
            },
            {
                title = "Laws Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/LAWSHUB-brookhaven/refs/heads/main/LAWSHUB%20Brookhaven\"))()",
            },
            {
                title = "Project Santerium",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ProjectSunterium/Project-Sunterium/refs/heads/main/Project%20Sunterium\"))()",
            },
            {
                title = "Salvatore hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RFR-R1CH4RD/Loader/main/Salvatore.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blox-loot-scripts/",
        slug = "blox-loot-scripts",
        scripts = {
            {
                title = "KEYLESS Blox Loot script – (Tora IsMe)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/BloxLoot\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "LuckyWinner hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MortyMo22/roblox-scripts/refs/heads/main/BloxLoot\"))()",
            },
            {
                title = "Karbid Dev Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/karbid-dev/Karbid-Hub-Luna/refs/heads/main/Key_System.lua\"))()",
            },
            {
                title = "Holdik Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Prarod/bloxloot/refs/heads/main/ffff'))()",
            },
            {
                title = "Standart Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EnxivityYZX/Blox-Loot/172184b3439f638e94a5e3ff5f4a1a424ac02082/Blox%20loot\", true))()",
            },
            {
                title = "Eclipseware",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nxghtCry0/eclipseware/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "Yuuki Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/4c8f73e2d9b25d0c53832cd6fad54b94.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/doors-scripts/",
        slug = "doors-scripts",
        scripts = {
            {
                title = "KEYLESS Doors script – (Saturn Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JScripter-Lua/Saturn_Hub_Products/refs/heads/main/Saturn_Hub_Doors.lua\"))()",
            },
            {
                title = "ZeScript",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/rssK4017/raw\"))()",
            },
            {
                title = "Four Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/Doors.lua\",true))()",
            },
            {
                title = "Knob farm",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/opaajhone-afk/roblox-vd/main/旋钮农场.lua\"))()",
            },
            {
                title = "DP hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/COOLXPLO/DP-HUB-coolxplo/refs/heads/main/Doors.lua\"))()",
            },
            {
                title = "ZeScript",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/DOORS-ZeScript-67246\"))()",
            },
            {
                title = "Cringles Workshop Auto Farm",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/ae83a9f6cf2eed1ea6bf09ff11659945.lua\"))()",
            },
            {
                title = "Nullfire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TeamNullFire/NullFire/main/loader.lua\"))()",
            },
            {
                title = "Aussie Wire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/4f5c7bbe546251d81e9d3554b109008f.lua\"))()",
            },
            {
                title = "Horizon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Starfall hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Severitysvc/Starfall/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "tigercubelite830 hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/tigercubelite830/DOORS/main/main.lua'))()",
            },
            {
                title = "Lemon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/yDM1sCp7\"))()",
            },
            {
                title = "Velocity X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://velocityloader.vercel.app/\"))()",
            },
            {
                title = "Sentrix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/12313112/scripts/refs/heads/main/doors.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-eternal-scripts/",
        slug = "anime-eternal-scripts",
        scripts = {
            {
                title = "KEYLESS Anime Eternal script – (AI Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AIHub091/AI-Hub/refs/heads/main/Anime-Eternal/Script.lua\"))()",
            },
            {
                title = "Four Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/FHAE.lua\",true))()",
            },
            {
                title = "DP Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/COOLXPLO/DP-HUB-coolxplo/refs/heads/main/Anime%20Eternal.lua\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Defenders Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/yRHbSXNt/raw\"))()",
            },
            {
                title = "NX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NX-Script/Nx_Hub/refs/heads/main/Anime_Eternal\"))()",
            },
            {
                title = "AnimeWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KAJUU490/jumapell/refs/heads/main/new\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Imp Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
            {
                title = "Macarrao Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/rystery/privatehub/refs/heads/main/README.md\"))()",
            },
            {
                title = "Crazy Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/HOKA-ANIME-ETERNAL/refs/heads/main/HOKALAZA\"))()",
            },
            {
                title = "JinkX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/stormskmonkey/JinkX/main/Loader.lua\"))()",
            },
            {
                title = "BAR1S Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/jnsphFRH\"))()",
            },
            {
                title = "Prestine Scripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PrestineScripts/Loader/refs/heads/main/Main-Loader\"))()",
            },
            {
                title = "FOUR Hub",
                has_key = true,
                code = "script_key = \"ENTER YOUR KEY HERE\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/37a6b3c1843f0ffb68b976fdb84259d4.lua\"))()",
            },
            {
                title = "Seisen Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8ac2e97282ac0718aeeb3bb3856a2821d71dc9e57553690ab508ebdb0d1569da/download\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dont-wake-the-brainrots-scripts/",
        slug = "dont-wake-the-brainrots-scripts",
        scripts = {
            {
                title = "KEYLESS Dont Wake the Brainrots script – Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/DontWaketheBrainrots\"))()",
            },
            {
                title = "Blankboii",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/LX06EJ5X/raw\",true))()",
            },
            {
                title = "Pulse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chavels123/Loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Sapphire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/uABi7rKf/raw\"))()",
            },
            {
                title = "Pulsar X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "KarbidDev hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/karbid-dev/Karbid/main/zpp0kogh0t\"))()",
            },
            {
                title = "StarStream hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/tls123account/StarStream/refs/heads/main/Hub\"))()",
            },
            {
                title = "Raxx hub",
                has_key = true,
                code = "getgenv().Settings = {\n    stealThreshold = 100, -- this is the minimum amount a brainrot must generate every second for it to be valid to steal\n	instantProximityPrompts = true, -- if true, proximity prompts will be activated instantly\n    speedboost = 33,\n    jumpboost = 12,\n    AutoCollect = true, -- if true, cash will be auto collected\n    AutoCollectInterval = 60, -- how often (in seconds) to auto collect cash\n}\n\nloadstring(game:HttpGet(\"https://pastebin.com/raw/WpkdiWGM\",true))()",
            },
            {
                title = "Crazy Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/DONT-WAKE-THE-BRAINROT-/refs/heads/main/HOKALAZA\"))()",
            },
            {
                title = "Mystrix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ummarxfarooq/mystrix-hub/refs/heads/main/dont%20wake%20the%20brainrots\"))()",
            },
            {
                title = "ATG Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Dont-Wake-the-Brainrots.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Ash Labs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=Dont-Wake-The-Brainrot.lua\", true))()",
            },
            {
                title = "Peachy hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/d37435894c260e0200d7c0cee1c5a4aea45602edb3ee1fa3c37726e2fe857ad5/download\"))()",
            },
            {
                title = "Mystrix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ummarxfarooq/mystrix-hub/refs/heads/main/dont%20wake%20the%20brainrots\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-card-clash-scripts/",
        slug = "anime-card-clash-scripts",
        scripts = {
            {
                title = "KEYLESS Anime Card Clash script – Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Threeeps/acc/main/script\"))()",
            },
            {
                title = "Rosel4k",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/rosel4k/scripts/refs/heads/main/AnimeCardClash.lua'))()",
            },
            {
                title = "Hina Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Threeeps/acc/main/script\"))()",
            },
            {
                title = "Ashlabs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=Anime-card-slash.lua\", true))()",
            },
            {
                title = "Grafeno Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TIOXSAN/ANIME-CARD-CLASH/refs/heads/main/scriptAUTO\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/cas/refs/heads/main/h\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/a-universal-time-scripts/",
        slug = "a-universal-time-scripts",
        scripts = {
            {
                title = "KEYLESS A Universal Time script – (Vellure Hub)",
                has_key = false,
                code = "loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/NyxaSylph/Vellure/refs/heads/main/AUT/Main.lua'))()",
            },
            {
                title = "NukeVsCity hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NukeVsCity/Scripts2025/refs/heads/main/AUniversalTim\"))()",
            },
            {
                title = "Star Stream hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub\"))()",
            },
            {
                title = "Akatsuki Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AkatsukiHub1/A-Universal-Time/refs/heads/main/README.md\"))()",
            },
            {
                title = "Imp Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fisch-scripts/",
        slug = "fisch-scripts",
        scripts = {
            {
                title = "KEYLESS Fisch script – (Rip V2 Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/Fisch.lua\"))()",
            },
            {
                title = "Soluna Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://soluna-script.vercel.app/fisch.lua\",true))()",
            },
            {
                title = "Desire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/welomenchaina/Desire-Hub./refs/heads/main/Desire%20Hub%20Fisch%20Script\",true))()",
            },
            {
                title = "Nat Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ArdyBotzz/NatHub/refs/heads/master/NatHub.lua\"))();",
            },
            {
                title = "Polleser Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Thebestofhack123/2.0/refs/heads/main/Scripts/Fisch\", true))()",
            },
            {
                title = "Moma Hub",
                has_key = true,
                code = "(loadstring or load)(game:HttpGet(\"https://raw.githubusercontent.com/n3xkxp3rl/Moma-Hub/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "21 Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://twentyonehub.vercel.app\"))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "Rail Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AZX0OZ/keyrh/refs/heads/main/RAILhub\"))()",
            },
            {
                title = "Fryzer hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FryzerHub/V/refs/heads/main/Fisch\"))()",
            },
            {
                title = "MadBuk hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nobody6969696969/Madbuk/refs/heads/main/loader.lua\", true))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/cde8084e2dd57e02d9cd8cb292d44a85.lua\"))()",
            },
            {
                title = "Arceny CC hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://arceney.cc/cdn/loader.luau\"))();",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
            {
                title = "Lord Senpai Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Senpai1997/Scripts/refs/heads/main/FischSenpaiHub.lua\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/cde8084e2dd57e02d9cd8cb292d44a85.lua\"))()",
            },
            {
                title = "Radeon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RadeonScripts/RadeonHubMain/main/MainRobloxExploit\"))()",
            },
            {
                title = "Pepehook",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GiftStein1/pepehook-loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "MaxComuk",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/141b6f42bae57e3f4a61b1727f47a724.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/work-at-pizza-place-scripts/",
        slug = "work-at-pizza-place-scripts",
        scripts = {
            {
                title = "KEYLESS Work At Pizza Place script – (7Sone)",
                has_key = false,
                code = "loadstring(game:HttpGet(('https://raw.githubusercontent.com/Hm5011/hussain/refs/heads/main/Work%20at%20a%20pizza%20place'),true))()",
            },
            {
                title = "Troll Gui",
                has_key = false,
                code = "loadstring(game:HttpGetAsync(\"https://raw.githubusercontent.com/blueEa1532/thechosenone/refs/heads/main/trollpizzagui\"))()",
            },
            {
                title = "Pizza Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ImARandom44/LoadingGui/refs/heads/main/Source\"))()",
            },
            {
                title = "TRHP Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RobloxHackingProject/HPHub/main/HPHub.lua\"))()",
            },
            {
                title = "Desire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/welomenchaina/Loader/refs/heads/main/ScriptLoader\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/king-legacy-scripts/",
        slug = "king-legacy-scripts",
        scripts = {
            {
                title = "KEYLESS King Legacy script – (Zee Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://zuwz.me/Ls-Zee-Hub-KL'))()",
            },
            {
                title = "Tsuo Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Tsuo7/TsuoHub/main/king%20legacy\"))()",
            },
            {
                title = "BTProject",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/OxyCoder32/prueba-script/refs/heads/main/BTProject'))()",
            },
            {
                title = "Nexor Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/NexorHub/Games/refs/heads/main/Universal/Scripts.lua'))()",
            },
            {
                title = "Auto Fish",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/042ab4ec0ef175451b3fd805ee7205ff95b1b5ca7541d4be9678087b58169ab3/download\"))()",
            },
            {
                title = "Fazium Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZaRdoOx/Fazium-files/main/Loader\"))()",
            },
            {
                title = "Hoho Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/acsu123/HOHO_H/main/Loading_UI'))()",
            },
            {
                title = "Legends Handles Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(('https://pastefy.app/3fQ9psgV/raw'),true))()",
            },
            {
                title = "Hyper Hub",
                has_key = true,
                code = "repeat wait() until game:IsLoaded()\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/DookDekDEE/Hyper/main/script.lua\"))()",
            },
            {
                title = "OMG Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Omgshit/Scripts/refs/heads/main/FarmingFlags\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/evade-scripts/",
        slug = "evade-scripts",
        scripts = {
            {
                title = "KEYLESS Evade script – (Mid-Journey hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JScripter-Lua/Mid-Journey_Open-Source/refs/heads/main/Evade%20Lag%20Free%20Test.lua\"))()",
            },
            {
                title = "CLY",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/9Strew/roblox/main/gamescripts/evade.lua'))()",
            },
            {
                title = "LightingWare",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/f3ed0bc1276c97a6404b78a360196d2d.lua\"))()",
            },
            {
                title = "DP Hub",
                has_key = false,
                code = "loadstring(\"\\108\\111\\97\\100\\115\\116\\114\\105\\110\\103\\40\\103\\97\\109\\101\\58\\72\\116\\116\\112\\71\\101\\116\\40\\34\\104\\116\\116\\112\\115\\58\\47\\47\\114\\97\\119\\46\\103\\105\\116\\104\\117\\98\\117\\115\\101\\114\\99\\111\\110\\116\\101\\110\\116\\46\\99\\111\\109\\47\\67\\79\\79\\76\\88\\80\\76\\79\\47\\68\\80\\45\\72\\85\\66\\45\\99\\111\\111\\108\\120\\112\\108\\111\\47\\114\\101\\102\\115\\47\\104\\101\\97\\100\\115\\47\\109\\97\\105\\110\\47\\69\\118\\97\\100\\101\\46\\108\\117\\97\\34\\41\\41\\40\\41\")()",
            },
            {
                title = "Bocchi The Cat hub",
                has_key = false,
                code = "-- settings\ngetgenv().farmTickets = true -- maybe works\ngetgenv().farmRevives = false\ngetgenv().noRender = false\ngetgenv().TrackMePlease = true -- optional tracking\n\nloadstring(game:HttpGet('https://raw.githubusercontent.com/bocchi-the-cat/rawr/refs/heads/main/evade.lua'))()",
            },
            {
                title = "Bagah Hub",
                has_key = false,
                code = "loadstring(game:HttpGetAsync(\"https://raw.githubusercontent.com/Bagah-Project/bagah-hub-public/refs/heads/main/mainloader.lua\"))()",
            },
            {
                title = "Monkey hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://monkeyhub.vercel.app/scripts/loader.lua\",true))()",
            },
            {
                title = "Auto Collect Gingerbread",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/e4e109f87eb14692e5ff4fb69818f4106e384b656b5b823809da1edc2f35aaa1/download\"))()",
            },
            {
                title = "SpeedHax",
                has_key = true,
                code = "--- Keybind: K\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/thesigmacorex/RobloxScripts/main/speedhax\"))()",
            },
            {
                title = "AussieWIRE",
                has_key = true,
                code = "loadstring(game:HttpGet(request({Url='https://aussie.productions/script'}).Body))()",
            },
            {
                title = "Imp Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua'))()",
            },
            {
                title = "Draconic Hub X",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Nyxarth910/Draconic-Hub-X/refs/heads/main/files/Evade/Overhaul.lua'))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "zReal-King",
                has_key = true,
                code = "pcall(loadstring(game:HttpGet('https://raw.githubusercontent.com/zReal-King/Evade/main/Main.lua')))",
            },
            {
                title = "Nex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CopyReal/NexHub/main/NexHubLoader\", true))()",
            },
            {
                title = "Forbidden Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Robloxhacker3/Forbidden-hub-Evade/refs/heads/main/Overhaul/evade.lua\",true))()",
            },
            {
                title = "Neox Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hassanxzayn-lua/NEOXHUBMAIN/refs/heads/main/loader\", true))()",
            },
            {
                title = "Whakizashi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/scv8contact-cpu/Whakizashi-hub-x/refs/heads/main/WhakizashiHubX-Evade\"))()",
            },
            {
                title = "Return Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/2xrW/return/refs/heads/main/hub\"))()",
            },
            {
                title = "Nuarexsc Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nuarexsc/nuarexsc-dev/refs/heads/main/mobile%26pc\"))()",
            },
            {
                title = "Azure Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/azurelw/azurehub/refs/heads/main/loader.lua'))()",
            },
            {
                title = "KamScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EnesKam21/evade/refs/heads/main/evade.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/tower-of-hell-scripts/",
        slug = "tower-of-hell-scripts",
        scripts = {
            {
                title = "KEYLESS Tower of Hell script – (Sprin Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/dqvh/dqvh/main/SprinHub\",true))()",
            },
            {
                title = "RB Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/yyeptech/thebighubs/refs/heads/main/toh.lua\"))()",
            },
            {
                title = "Proxima Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TrixAde/Proxima-Hub/main/Main.lua\"))()",
            },
            {
                title = "GHub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bleepis/AJ-HUB/refs/heads/main/main\", true))()",
            },
            {
                title = "JakeyJak",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/JakeyJak/scripts/main/TowerOfHell.lua'))();",
            },
        },
    },
    {
        page_url = "https://robscript.com/dead-rails-scripts/",
        slug = "dead-rails-scripts",
        scripts = {
            {
                title = "KEYLESS Dead Rails script – (Hutao Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Dead-Rails-Alpha-Hutao-hub-FREE-39131\"))()",
            },
            {
                title = "EasyScripts – autofarm bonds",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustKondzio0010/deadrailsbondfarm/refs/heads/main/dead\", true))()",
            },
            {
                title = "Vylera hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/vyleradeadrails.lua\"))()",
            },
            {
                title = "Nevliz Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ryanVictor123/Nevliz-Hub-dead-Rails/refs/heads/main/🎩%20Nevliz%20Hub%20🎩\"))()",
            },
            {
                title = "Ringta hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/erewe23/deadrailsring.github.io/refs/heads/main/ringta.lua\"))()",
            },
            {
                title = "Moondiety",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/m00ndiety/Moondiety/refs/heads/main/Loader'))()",
            },
            {
                title = "Taxus Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gettaxus.vercel.app/api/scripts?action=loader&id=e1efd57e1efbb86a\"))()",
            },
            {
                title = "Nuarexsc",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8397bb3fc906109fe872edd4463510b30d881e75bdc41acfbd6be6c52f404e44/download\"))()",
            },
            {
                title = "Neox Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hassanxzayn-lua/NEOXHUBMAIN/refs/heads/main/99NIFT\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "Rift hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rifton.top/loader.lua\"))()",
            },
            {
                title = "Nexor Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/NexorHub/Games/refs/heads/main/Universal/Scripts.lua'))()",
            },
            {
                title = "SpiderX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/SpiderScriptRB/Dead-Rails-SpiderXHub-Script/refs/heads/main/SpiderXHub%202.0.txt\"))()",
            },
            {
                title = "AussieWire hub",
                has_key = true,
                code = "loadstring(game:HttpGet(request({Url='https://aussie.productions/script'}).Body))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/255ac567ced3dcb9e69aa7e44c423f19.lua\"))()",
            },
            {
                title = "Norepinefrina Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://norepinefrina.com\"))()",
            },
            {
                title = "Kohler hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kohlerhub/Scripts/refs/heads/main/KohlerHub.txt\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/military-tycoon-scripts/",
        slug = "military-tycoon-scripts",
        scripts = {
            {
                title = "Military Tycoon script – (21 Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://twentyonehub.vercel.app\"))()",
            },
            {
                title = "ArnisRblxYt Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ArnisRblxYt/Aimbot-esp-universal-arnisrblxyt-/refs/heads/main/Aimbot%2C%20esp%20universal%20arnisrblxyt\"))()",
            },
            {
                title = "Lucky Winner Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MortyMo22/roblox-scripts/refs/heads/main/MilitaryTycoon\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/car-dealership-tycoon-scripts/",
        slug = "car-dealership-tycoon-scripts",
        scripts = {
            {
                title = "KEYLESS Car Dealership Tycoon script – (LDS Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/49f02b0d8c1f60207c84ae76e12abc1e.lua'))()",
            },
            {
                title = "Car Dupe (Visual Only)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/HEIST!-Car-Dealership-Tycoon-CDT-Car-Dup-For-Recording-71164\"))()",
            },
            {
                title = "Norefrina Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://norepinefrina.com\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blue-lock-rivals-scripts/",
        slug = "blue-lock-rivals-scripts",
        scripts = {
            {
                title = "KEYLESS Blue Lock Rivals script – (Nevan Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nevan32/BLUE-LOCK-RIVALS/refs/heads/main/Loader\"))()",
            },
            {
                title = "DP Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/COOLXPLO/DP-HUB-coolxplo/refs/heads/main/Bluelock.lua\"))()",
            },
            {
                title = "Ather Hub",
                has_key = true,
                code = "--Discord: https://discord.gg/x4ux7pUVJu\nscript_key = \"Add key here to auto verify\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua\"))()",
            },
            {
                title = "Nexus Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CrazyHub123/NexusHubRevival/refs/heads/main/Main.lua\"))()",
            },
            {
                title = "XZuyaX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/XZuuyaX/XZuyaX-s-Hub/refs/heads/main/Main.Lua\", true))()",
            },
            {
                title = "SOULS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/SPQT6v5J\"))()",
            },
            {
                title = "Kam Scripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EnesKam21/bluelock/refs/heads/main/obfuscated%20(2).lua\"))()",
            },
            {
                title = "IMP Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
            {
                title = "Crazy Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/HOKALAZA-BLR/refs/heads/main/BLR%20HOKALAZA\"))()",
            },
            {
                title = "Alchemy Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://scripts.alchemyhub.xyz\"))()",
            },
            {
                title = "Nicuse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nicuse.xyz/MainHub.lua\"))()",
            },
            {
                title = "Kohler hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kohlerhub/Scripts/refs/heads/main/KohlerHub.txt\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/prison-life-scripts/",
        slug = "prison-life-scripts",
        scripts = {
            {
                title = "KEYLESS Prison Life script – (PrisonWare)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Denverrz/scripts/master/PRISONWARE_v1.3.txt\"))();",
            },
            {
                title = "Flash Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/scripture2025/FlashHub/refs/heads/main/PrisonLife\"))()",
            },
            {
                title = "Nihilize h4x – Teleports",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/QLtH2v8i'))()",
            },
            {
                title = "DP Hub",
                has_key = false,
                code = "loadstring(\"\\108\\111\\97\\100\\115\\116\\114\\105\\110\\103\\40\\103\\97\\109\\101\\58\\72\\116\\116\\112\\71\\101\\116\\40\\34\\104\\116\\116\\112\\115\\58\\47\\47\\114\\97\\119\\46\\103\\105\\116\\104\\117\\98\\117\\115\\101\\114\\99\\111\\110\\116\\101\\110\\116\\46\\99\\111\\109\\47\\67\\79\\79\\76\\88\\80\\76\\79\\47\\68\\80\\45\\72\\85\\66\\45\\99\\111\\111\\108\\120\\112\\108\\111\\47\\114\\101\\102\\115\\47\\104\\101\\97\\100\\115\\47\\109\\97\\105\\110\\47\\80\\114\\105\\115\\111\\110\\108\\105\\102\\101\\46\\108\\117\\97\\34\\41\\41\\40\\41\")()",
            },
            {
                title = "Lightux Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(('https://raw.githubusercontent.com/rajrsansraowar/Lightux/main/README.md'),true))()",
            },
            {
                title = "Bowser Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/chriszrk/Bowser-Hub/main/BowserHubCool\", true))()",
            },
            {
                title = "Zee Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/decis1ve/prisonlifetuffscriptfree/refs/heads/main/prisonlife\"))()",
            },
            {
                title = "Tiger Admin command console",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/APIApple/Main/refs/heads/main/loadstring\"))()",
            },
            {
                title = "PS Admin",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/VYjdEsc5\"))()",
            },
            {
                title = "Prison GG",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kxtOnYT/prison.gg/refs/heads/main/private.lua\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/xwH4sux8\"))()",
            },
            {
                title = "Alternative hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/A1ternative-hub/script/refs/heads/main/tu'))()",
            },
            {
                title = "Ultra Sigma Hax V2",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/MMDKjn0A/raw\"))()",
            },
            {
                title = "Nuarexsc",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8397bb3fc906109fe872edd4463510b30d881e75bdc41acfbd6be6c52f404e44/download\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/da-hood-scripts/",
        slug = "da-hood-scripts",
        scripts = {
            {
                title = "KEYLESS Da Hood script – (Sylex Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bbbbbbbbbbbbbb121/Roblox/refs/heads/main/Sylex\", true))()",
            },
            {
                title = "UDHL Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sgysh3nka/UDHL/refs/heads/main/UDHL.lua\"))()",
            },
            {
                title = "Camlock / Aimbot",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/HomeMadeScripts/Camlock-aimlock/main/obf_Wxr6QgzF76G1y2Ch77KN4Zt5Nz0A6GIl61gitv3mRR2t3V103al5d0g26s4KY04r.lua.txt\"))()",
            },
            {
                title = "Zinc Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Zinzs/luascripting/main/canyoutellitsadahoodscriptornot.lua\"))()",
            },
            {
                title = "Headshots.cc",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/e1mor/xes3/refs/heads/main/headshots.cc\"))()",
            },
            {
                title = "Gots Hub da hood autofarm",
                has_key = true,
                code = "_G.AutofarmSettings = {\n    Fps = 60,\n    AttackMode = 2, -- 1 = Click, 2 = Hold\n    Webhook = '', --webhook for stat logging\n    LogInterval = 15,\n    CustomOffsets = { --atm offsets\n        ['atm12'] = CFrame.new(-2, 0, 0),\n        ['atm13'] = CFrame.new(2, 0, 0),\n    },\n    disableScreen = false --broken rn\n}\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/frvaunted/Main/refs/heads/main/DaHoodAutofarm\", true))()",
            },
            {
                title = "Mango Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/rogelioajax/lua/main/MangoHub\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/coldena/voidhuba/refs/heads/main/voidhubload\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/build-a-boat-for-treasure-scripts/",
        slug = "build-a-boat-for-treasure-scripts",
        scripts = {
            {
                title = "KEYLESS Build a Boat for Treasure script – (Rolly hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/XRoLLu/UWU/main/BUILD%20A%20BOAT%20FOR%20TREASURE.lua'))()",
            },
            {
                title = "W1lte Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/W1lteGameYT/W1lteGame-Hub-Best-Build-A-Boat-For-Treasure-Gold-Block-Farm-Script/refs/heads/main/script\"))()",
            },
            {
                title = "HiJabChq",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/sweetcheeks713/Build-A-Boat-For-Treasure/main/Build A Boat For Treasure.lua'))()",
            },
            {
                title = "Just autofarm",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/Lyy77rnr\",true))()",
            },
            {
                title = "Auto Builder",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/max2007killer/auto-build-not-limit/main/buildaboatv2obs.txt\"))()",
            },
            {
                title = "Vikai Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vinxonez/ViKai-HUB/refs/heads/main/babft\"))()",
            },
            {
                title = "ExyXyz hub – Morph characters",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ExyXyz/ExyGantenk/main/ExyBABFT\"))()",
            },
            {
                title = "Rinns hub",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/SkibidiCen/MainMenu/main/Code\")()",
            },
            {
                title = "Nov Boat",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/novakoolhub/Scripts/main/Scripts/NovBoatR1\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-rangers-x-scripts/",
        slug = "anime-rangers-x-scripts",
        scripts = {
            {
                title = "KEYLESS Anime Rangers X script – (L-hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Frxser Store",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/XeFrostz/ANM-Ranger-X/refs/heads/main/RangerX.lua'))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Seisen Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8ac2e97282ac0718aeeb3bb3856a2821d71dc9e57553690ab508ebdb0d1569da/download\"))()",
            },
            {
                title = "AnimeWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KAJUU490/c9/refs/heads/main/jumapell2\"))()",
            },
            {
                title = "Lix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader\"))()",
            },
            {
                title = "Beecon Hub",
                has_key = true,
                code = "script_key=\"YOUR KEY\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/323718949a0352c3f69d25f28c036222.lua\"))()",
            },
            {
                title = "Celestara",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KitsunaCh/Celestara-Hub/refs/heads/main/AnimeRangerX.lua\"))()",
            },
            {
                title = "WSJ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NhatMinhVNQ/nm.wsj/refs/heads/main/WSJ-HUB.TD.lua\"))()",
            },
            {
                title = "Nousigi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nousigi.com/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pet-simulator-x-scripts/",
        slug = "pet-simulator-x-scripts",
        scripts = {
            {
                title = "KEYLESS Pet Simulator X script – (Rafa Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Rafacasari/roblox-scripts/main/psx.lua\"))()",
            },
            {
                title = "Qwix Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/TSQ-new/QwiX_PSX/main/PSX_SCRIPT'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pet-simulator-99-scripts/",
        slug = "pet-simulator-99-scripts",
        scripts = {
            {
                title = "KEYLESS Pet Simulator 99 script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/PetSimGames\"))()",
            },
            {
                title = "INFINITYWARE",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/bubblescripts/scripts/refs/heads/main/PS99/psgo\")()",
            },
            {
                title = "Xrzdev",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/MdHWH64t\"))()",
            },
            {
                title = "SFG Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/ScriptsForDays/3cecbb45a61de41a748e2e23e0216b45/raw/25ecb40787d6058136217f0034c342763c50effa/obf%2520ps99%2520script\"))()",
            },
            {
                title = "Zap Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://zaphub.xyz/Exec'))()",
            },
            {
                title = "Despise Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RJ077SIUU/PS99/main/Gems\"))()",
            },
            {
                title = "Reaper Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AyoReaper/Reaper-Hub/refs/heads/main/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/arsenal-scripts/",
        slug = "arsenal-scripts",
        scripts = {
            {
                title = "KEYLESS Arsenal script – (Lithium Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Sempiller/Lithium/refs/heads/main/main.lua\"))()",
            },
            {
                title = "Vapa v2 hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nickyangtpe/Vapa-v2/refs/heads/main/Vapav2-Arsenal.lua\", true))()",
            },
            {
                title = "AdvanceTech hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/AdvanceFTeam/Our-Scripts/refs/heads/main/AdvanceTech/Arsenal.lua'))()",
            },
            {
                title = "Weed Client hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ex55/weed-client/refs/heads/main/main.lua\"))()",
            },
            {
                title = "BerTox Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/8ysy7ENG\",true))()",
            },
            {
                title = "Tbao Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/tbao143/thaibao/main/TbaoHubArsenal\"))()",
            },
            {
                title = "Stormware Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FurkUltra/UltraScripts/main/arsenal\",true))()",
            },
            {
                title = "Synergy hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/fDqbnBpN\"))()",
            },
            {
                title = "DP HUB – AI Bot",
                has_key = false,
                code = "loadstring(\"\\108\\111\\97\\100\\115\\116\\114\\105\\110\\103\\40\\103\\97\\109\\101\\58\\72\\116\\116\\112\\71\\101\\116\\40\\34\\104\\116\\116\\112\\115\\58\\47\\47\\114\\97\\119\\46\\103\\105\\116\\104\\117\\98\\117\\115\\101\\114\\99\\111\\110\\116\\101\\110\\116\\46\\99\\111\\109\\47\\67\\79\\79\\76\\88\\80\\76\\79\\47\\68\\80\\45\\72\\85\\66\\45\\99\\111\\111\\108\\120\\112\\108\\111\\47\\114\\101\\102\\115\\47\\104\\101\\97\\100\\115\\47\\109\\97\\105\\110\\47\\97\\114\\115\\101\\110\\97\\108\\46\\108\\117\\97\\34\\41\\41\\40\\41\")()",
            },
            {
                title = "DMON Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"http://dmonmods.xyz/loader.txt\"))()",
            },
            {
                title = "CATWARE XYZ",
                has_key = false,
                code = "local Library = loadstring(game:HttpGet('https://catware.xyz/catwarearsenal.lua'))()",
            },
            {
                title = "Unbound hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/samerop/unbound-hub/main/unbound-hub.lua\"))()",
            },
            {
                title = "Greatness hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://greatnesssloader.vercel.app/api/loader.lua\"))()",
            },
            {
                title = "Unbound hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
            {
                title = "ReCoded hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vsqzz/Exploits-2025/refs/heads/main/Arsenal.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/murder-mystery-2-scripts/",
        slug = "murder-mystery-2-scripts",
        scripts = {
            {
                title = "KEYLESS Murder Mystery 2 / MM2 script – (MoonWare)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/littl3prince/Moon/main/Moon_V1\"))()",
            },
            {
                title = "Flint MM2 ESP",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chxnged/2/refs/heads/main/hub.lua\"))()",
            },
            {
                title = "NO KEY Greasy Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/givemealuck1/GreasyScriptsFarm/refs/heads/main/GreasyFarmMM2\"))()",
            },
            {
                title = "Azure Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Aura-56/MurderMystery2/refs/heads/main/AzureHub.lua\", true))()",
            },
            {
                title = "Moondiety Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/m00ndiety/Moondiety/refs/heads/main/Loader'))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Koronis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://koronis.xyz/hub.lua\"))()",
            },
            {
                title = "Monkey Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://monkeyhub.vercel.app/scripts/loader.lua\",true))()",
            },
            {
                title = "Ather Hub",
                has_key = true,
                code = "--DISCORD please join: https://discord.gg/n86w8P8Evx\nscript_key = \"Add key here to auto verify\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "Project Infinity",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Muhammad6196/Project-Infinity-X/refs/heads/main/main.lua\"))()",
            },
            {
                title = "Gitan X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/fddttttt/GitanX/refs/heads/main/GitanX.lua\"))()",
            },
            {
                title = "Praixe Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/supernarkl/Praixe-hub-loader/refs/heads/main/Praixe%20hub\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/noob-army-tycoon-scripts/",
        slug = "noob-army-tycoon-scripts",
        scripts = {
            {
                title = "MGCactus Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MGCactus/myscripts/main/Noob%20Tycoon%20Army.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/case-rolling-rng-scripts/",
        slug = "case-rolling-rng-scripts",
        scripts = {
            {
                title = "KEYLESS Case Rolling RNG script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Case-Rolling-RNG-NEW-Auto-farm-and-auto-open-cases-45044\"))()",
            },
            {
                title = "Autofarm money, Insta open case",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/GomesPT7/Case-Rolling-RNG/refs/heads/main/v1'))()",
            },
            {
                title = "Fast Autofarm money",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MADMONEYDISTRO/feather-hub/refs/heads/main/case%20rng%20remake%20autofarm\"))()",
            },
            {
                title = "Kasumi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kasumichwan/scripts/refs/heads/main/kasumi-hub.lua\"))()",
            },
            {
                title = "Arch Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"http://site33927.web1.titanaxe.com/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/steal-a-drawed-brainrot-scripts/",
        slug = "steal-a-drawed-brainrot-scripts",
        scripts = {
            {
                title = "Steal a drawed Brainrot script",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/YA83Gsbs\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/the-forge-scripts/",
        slug = "the-forge-scripts",
        scripts = {
            {
                title = "KEYLESS The Forge script – (Polluted Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/ecfcccea43f60fa4c46009f854c06a52.lua\"))()",
            },
            {
                title = "Haze Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://haze.wtf/api/script\"))()",
            },
            {
                title = "Four Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/TheForgeFH.lua\",true))()",
            },
            {
                title = "Lazy Hub",
                has_key = false,
                code = "repeat wait() until game:IsLoaded()\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/LioK251/RbScripts/refs/heads/main/lazyuhub_theforge.lua\"))()",
            },
            {
                title = "Mirage hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/2075c39b9a5a2e4414c59c93fe8a5f06.lua\"))()",
            },
            {
                title = "Catraz Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nurvian/Catraz-HUB/refs/heads/main/Catraz/main.lua\"))()",
            },
            {
                title = "Ather hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/AKxW03nJ'))()",
            },
            {
                title = "Mirage Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/2075c39b9a5a2e4414c59c93fe8a5f06.lua\"))()",
            },
            {
                title = "Pepehook",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GiftStein1/pepehook-loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Rift hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rifton.top/loader.lua\"))()",
            },
            {
                title = "Sorin Hub",
                has_key = true,
                code = "-- Join our Discord to be up to date with Updates: scripts.sorinservice.online/dc\nloadstring(game:HttpGet(\"https://scripts.sorinservice.online/sorin/script_hub.lua\"))()",
            },
            {
                title = "Chiyo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/f2a0e49825fbd07bac79e7271c77e28c.lua\"))()",
            },
            {
                title = "Nousigi hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nousigi.com/loader.lua\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Exploiting is Fun",
                has_key = true,
                code = "loadstring(game:HttpGet('https://cdn.exploitingis.fun/loader', true))()",
            },
            {
                title = "DJ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/a2d3e230acd2e2d27608637b678d7cc480e468d09e8e29ef5cd3ea8af7ebb514/download\"))()",
            },
            {
                title = "Ash Labs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=the-forge.lua\", true))()",
            },
            {
                title = "BlackHub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skibidiking123/Fisch1/refs/heads/main/FischMain\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/meobeo8/a/a/a\"))()",
            },
            {
                title = "No1 Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/SkibidiHub111/No1I/refs/heads/main/Forge\"))()",
            },
            {
                title = "Kapao Hub",
                has_key = true,
                code = "getgenv().Key = \"Your Key\"\ngetgenv().ScriptId = \"The Forge Normal\"\nloadstring(game:HttpGet(\"https://kapao-hub.vercel.app/loader.lua\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Space-RB/Script/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Ego Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AbdouGG/NurkHub2/refs/heads/main/Games/The%20Forge/main\"))()",
            },
            {
                title = "Cerberus",
                has_key = true,
                code = "script_key=\"YOUR KEY HERE\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/c099643d9810bb9adacf1da415ae6d56.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/plants-vs-brainrots-scripts/",
        slug = "plants-vs-brainrots-scripts",
        scripts = {
            {
                title = "KEYLESS Plants Vs Brainrots script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gitlab.com/r_soft/main/-/raw/main/LoadUB.lua\"))()",
            },
            {
                title = "ED Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Eddy23421/EdHubV4/refs/heads/main/loader\"))()",
            },
            {
                title = "Haze WTF hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://haze.wtf/api/script\"))()",
            },
            {
                title = "Tora IsMe Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/PlantsVsBrainrots\"))()",
            },
            {
                title = "2xr hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/2xrW/return/refs/heads/main/hub\"))()",
            },
            {
                title = "Dupe",
                has_key = false,
                code = "script_key = \"xx\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fad2e1bf0ec73bd3cca1395400ee4fd0.lua\"))()",
            },
            {
                title = "Hokalaza Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/HOKALAZA-plants-vs-brainrot/refs/heads/main/Key\"))()",
            },
            {
                title = "Seisen hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8ac2e97282ac0718aeeb3bb3856a2821d71dc9e57553690ab508ebdb0d1569da/download\"))()",
            },
            {
                title = "Nexus Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/fdd07032179b5afeaa62b4da0b5dc8a87593047083898e6aa46ab1629c4ad16c/download\"))()",
            },
            {
                title = "Chiyo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ago106/SpaceHub/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "script_key=\"KEY\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/f6694685700f6fb4c09bb09771a50980.lua\"))()",
            },
            {
                title = "Pulse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chavels123/Loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Mad Buk Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nobody6969696969/Madbuk/refs/heads/main/loader.lua\", true))()",
            },
            {
                title = "Solvex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Solvexxxx/Scripts/refs/heads/main/SolvexGUI_PVB.lua\"))()",
            },
            {
                title = "Foggy hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://foggysoftworks.xyz/loader.lua\"))()",
            },
            {
                title = "Fryzer hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/CxxpT2sr\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/coldena/voidhuba/refs/heads/main/voidhubload\",true))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/d5ed1fbd4301b1d18d75153c5b47181d.lua\"))()",
            },
            {
                title = "Elite Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pandadevelopment.net/virtual/file/f0586f838f82a4b9\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/steal-a-fish-scripts/",
        slug = "steal-a-fish-scripts",
        scripts = {
            {
                title = "KEYLESS Steal A Fish script – (Tora IsMe Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/StealAFish\"))()",
            },
            {
                title = "Vylera hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/stealafish.lua\"))()",
            },
            {
                title = "Combo Wick",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "LAFOFISK",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pandadevelopment.net/virtual/file/f0586f838f82a4b9\"))()",
            },
            {
                title = "Klinac Hub",
                has_key = true,
                code = "local code = game:HttpGet(\n    'https://raw.githubusercontent.com/Klinac/scripts/main/steal_a_fish.lua'\n)\nloadstring(code)()",
            },
            {
                title = "Vault Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/pqdZNZJe\"))()",
            },
            {
                title = "Nexis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/basedgoons/Nexis-Hub-Initial/refs/heads/main/Initial%20Nexis%20Hub%20Redirect\"))()",
            },
            {
                title = "Ash Labs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=steal-a-fish.lua\", true))()",
            },
            {
                title = "Pulsar X hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "Sapphire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/2aktLkT3/raw\"))()",
            },
            {
                title = "Xenith hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vexalotl/Cybese/refs/heads/main/main\"))()",
            },
            {
                title = "Xenith hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vexalotl/Cybese/refs/heads/main/main\"))()",
            },
            {
                title = "Quniyx Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/a1jPSNuH\"))()",
            },
            {
                title = "Tx3hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://tx3hub.vercel.app/loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/jujutsu-shenanigans-scripts/",
        slug = "jujutsu-shenanigans-scripts",
        scripts = {
            {
                title = "KEYLESS Jujutsu Shenanigans script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/NotEnoughJack/localplayerscripts1/refs/heads/main/script'))()",
            },
            {
                title = "Aimlock",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/egehanqq/JujutsuW.I.P/refs/heads/main/Jujutsu\"))()",
            },
            {
                title = "Custom move set",
                has_key = false,
                code = "--[[\njoin discord server plss\ndiscord.gg/soulshatters\n--]]\ngetgenv().Rain = true\ngetgenv().Move5 = true \ngetgenv().Move6 = true \ngetgenv().Move7 = true\nloadstring(game:HttpGet('https://raw.githubusercontent.com/Reapvitalized/JJS/refs/heads/main/Lindwurm.lua'))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Xenon Hub",
                has_key = true,
                code = "script_key=\"put_key_here\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/eed1b8c86a83b71bf7e8ec398fc39401.lua\"))()",
            },
            {
                title = "Nexor Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/NexorHub/Games/refs/heads/main/Universal/Scripts.lua'))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/hypershot-scripts/",
        slug = "hypershot-scripts",
        scripts = {
            {
                title = "KEYLESS Hypershot script – (XVC Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/XVCHub/Games/main/HyperShot\"))()",
            },
            {
                title = "717 exe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/arcadeisreal/717exe_Hypershot/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "kiberking29",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/kiberking29/Hypershot-Script/main/main.lua'))()",
            },
            {
                title = "Danangori hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/danangori/Hypershots/refs/heads/main/V2-2025\"))()",
            },
            {
                title = "Nexis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/boringcat4646/Nexis-Hub/refs/heads/main/Key%20System\"))()",
            },
            {
                title = "ComboWick Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Haunt Hub",
                has_key = true,
                code = "local key = 'scriptkey'\n\nshared = shared or {}\nshared.__KEY_INPUT = key\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/n1hitt/haunt.lol/refs/heads/main/rewind\"))(",
            },
            {
                title = "Nexus Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/0adf652663b6cdbe51f56a5ca9d130252f226d8b7ddfdcf50386d1c8fab4a831/download\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Lord Senpai",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Senpai1997/Scripts/refs/heads/main/HypershotBasicAutofarm.lua\"))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "Op1um hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/ce8ce4880452e53b2e5f770714dffacf.lua\"))()",
            },
            {
                title = "ESP",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jamg26/hub/refs/heads/main/main\"))()",
            },
            {
                title = "Overflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://overflow.cx/loader.html\"))()",
            },
            {
                title = "KamScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EnesKam21/hypershoot/refs/heads/main/hypershoot.txt\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pixel-blade-scripts/",
        slug = "pixel-blade-scripts",
        scripts = {
            {
                title = "KEYLESS Pixel Blade script – (TexRBLX Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TexRBLX/Roblox-stuff/refs/heads/main/pixel%20blade/final.lua\"))()",
            },
            {
                title = "Kill all and auto room",
                has_key = false,
                code = "toclipboard([[\n    https://discord.gg/bKPRWatprk\n]])\nlocal player = game:GetService(\"Players\").LocalPlayer\nlocal replicatedStorage = game:GetService(\"ReplicatedStorage\")\nlocal runService = game:GetService(\"RunService\")\nlocal roomcheck = false\nlocal autofarm = false\nlocal autoupgrade = false\nlocal killall = false\nlocal library = loadstring(game:HttpGet((\"https://raw.githubusercontent.com/theneutral0ne/wally-modified/refs/heads/main/wally-modified.lua\")))()\nlocal window = library:CreateWindow('Credit: Neutral')\nwindow:Section('Auto Farm')\nwindow:Toggle(\"Auto Farm\",{},function(value)\nautofarm = value\nend)\nwindow:Section('Stuff')\nwindow:Toggle(\"Kill All\",{},function(value)\nkillall = value\nend)\nwindow:Button(\"Remove upgrade ui\",function(value)\nif player.PlayerGui.gameUI.upgradeFrame.Visible then player.PlayerGui.gameUI.upgradeFrame.Visible = false end\nif game.Lighting:FindFirstChild(\"deathBlur\") then game.Lighting.deathBlur:Destroy() end\nif game.Lighting:FindFirstChild(\"screenBlur\") then game.Lighting.screenBlur:Destroy() end\nend)\n\nlocal function room(character)\n    for _,v in workspace:GetDescendants() do\n        if v.ClassName == \"ProximityPrompt\" and v.Enabled then\n            character.HumanoidRootPart.CFrame = v.Parent.CFrame\n            fireproximityprompt(v)\n            task.wait(0.1)\n        end\n    end\n    for _,v in workspace:GetChildren() do   \n        if v:FindFirstChild(\"ExitZone\") then\n            character.HumanoidRootPart.CFrame = v.ExitZone.CFrame\n            task.wait(0.25)\n            character.HumanoidRootPart.CFrame = CFrame.new(v:GetPivot().Position)\n            task.wait(0.25)\n        end\n    end\n    roomcheck = false\nend\n\nrunService.RenderStepped:Connect(function(delta)\n    local character = player.Character\n    if character then\n        if autofarm then\n            if roomcheck == false then\n                roomcheck = true\n                room(character)\n            end\n        end\n        if killall then\n            for _,v in workspace:GetChildren() do   \n                if v:FindFirstChild(\"Humanoid\") or v:FindFirstChildWhichIsA(\"Model\") and v:FindFirstChildWhichIsA(\"Model\"):FindFirstChild(\"Humanoid\") then\n                    if v:GetAttribute(\"hadEntrance\") and v:FindFirstChild(\"Health\") then\n                        replicatedStorage.remotes.useAbility:FireServer(\"tornado\")\n                        replicatedStorage.remotes.abilityHit:FireServer(if v:FindFirstChild(\"Humanoid\") then v:FindFirstChild(\"Humanoid\") else v:FindFirstChildWhichIsA(\"Model\"):FindFirstChild(\"Humanoid\"),math.huge,{[\"stun\"] = {[\"dur\"] = 1}})\n                    end\n                end\n            end\n        end\n    end\nend)",
            },
            {
                title = "Rat Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Ratkinator/RatX/refs/heads/main/Loader.lua\",true))()",
            },
            {
                title = "Qween Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://qweenhub.netlify.app/loader/pixelblade.lua\"))()",
            },
            {
                title = "Kill Aura",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/op-kill-aura-auto-parry-no-speedstate-cracked_1763931729905_EKratgRnpe.txt\"))()",
            },
            {
                title = "Chiyo Hub",
                has_key = true,
                code = "script_key=\"KEY\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/f6694685700f6fb4c09bb09771a50980.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Unperformed Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/6ed3b0b29cae165a5df389c3650171583312f6baeaf622f2330521e9c340436c/download\"))()",
            },
            {
                title = "Gnex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/f83cd66025b98df9cbe5268951f8004fbd20be887ffa0b080b2a148c4e3aacc4/download\"))()",
            },
            {
                title = "UnperformedHUB",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/6ed3b0b29cae165a5df389c3650171583312f6baeaf622f2330521e9c340436c/download\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "script_key = \"PASTEYOURKEYHERE\"\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()\n-- https://discord.gg/mbyHbxAhhT\\",
            },
        },
    },
    {
        page_url = "https://robscript.com/adopt-me-scripts/",
        slug = "adopt-me-scripts",
        scripts = {
            {
                title = "KEYLESS Adopt Me script – Ragesploit",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Ragesploit-x/Ragesploit/refs/heads/main/MainScript/ShitVersion.lua\"))();",
            },
            {
                title = "Ringta Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/eeeiqjj876y/adoptme.github.io/refs/heads/main/ringta.lua\"))()",
            },
            {
                title = "GingerBreads",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jazzedd/JazradScript/refs/heads/main/Script\"))()",
            },
            {
                title = "GingerBreads farm – EZ hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
            {
                title = "Niburu Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Niburu52/hub/refs/heads/main/Adopt%20Me!'))()",
            },
            {
                title = "billieroblox",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/billieroblox/jimmer/main/77_HAJ07IP.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/something-evil-will-happen-scripts/",
        slug = "something-evil-will-happen-scripts",
        scripts = {
            {
                title = "KEYLESS something evil will happen script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/exodus-lua/scripts/refs/heads/main/sewhloader.lua\",true))()",
            },
            {
                title = "SEWH Win",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FOXTROXHACKS/Roblox-Scripts/refs/heads/main/SEWH-Win-AF.lua\"))()",
            },
            {
                title = "SEWH God",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Bac0nHck/Scripts/refs/heads/main/SEWH.lua\"))()",
            },
            {
                title = "ZZZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zzxzsss/zxs/refs/heads/main/xxzz\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/azure-latch-scripts/",
        slug = "azure-latch-scripts",
        scripts = {
            {
                title = "KEYLESS Azure Latch script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ghostofcelleron/Celeron/refs/heads/main/Azure%20Latch%20(OS)\",true))()",
            },
            {
                title = "Napoleon Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/raydjs/napoleonHub/refs/heads/main/src.lua\"))()",
            },
            {
                title = "SkibidiCen",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/SkibidiCen/MainMenu/main/Code\"))()",
            },
            {
                title = "Rinns Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/SkibidiCen/MainMenu/main/Code\"))()",
            },
            {
                title = "Fake Azure Latch Style VFX and Goalbound Style VFX",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/AlperPro/Roblox-Scripts/refs/heads/main/LloydHUBLoader.lua'))()",
            },
            {
                title = "mokaEZF hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/mokaEZF/Ez/refs/heads/main/aura'))()",
            },
            {
                title = "Apoc Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ApocHub/ApocHub/refs/heads/main/ApocHubMain\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/purgatory-scripts/",
        slug = "purgatory-scripts",
        scripts = {
            {
                title = "Purgatory script – (KEYLESS) L35 hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://protected-roblox-scripts.onrender.com/279ab5d3ec34b740d25c90968e9c6c5c\"))()",
            },
            {
                title = "Pancakq",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Pancakq/Public-Scripts/refs/heads/main/Purgatory\"))()",
            },
            {
                title = "S0ftKillz Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/10fc7200dd134ce3cca42f3a031db69bbf16a90e5f144e4db6e7cab31b3ab1c3/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/jump-showdown-scripts/",
        slug = "jump-showdown-scripts",
        scripts = {
            {
                title = "Jump Showdown script – (KEYLESS)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kaisred/JSD/refs/heads/main/Obsf\"))()",
            },
            {
                title = "Jumper v2 hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/solarastuff/sorryjimpee/refs/heads/main/Jumper.lua\"))()",
            },
            {
                title = "sho hub",
                has_key = true,
                code = "script_key=\"ur key here :3\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/01868f68b39e5d2e8e789d97b050ee07.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fish-go-scripts/",
        slug = "fish-go-scripts",
        scripts = {
            {
                title = "Fish Go script – (KEYLESS) Qween Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://qweenhub.netlify.app/loader/39a8c-secure-v3.lua\"))()",
            },
            {
                title = "KRIS HUB – Instant Fisch",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kristianoronaldo1911-bot/fish-instant/refs/heads/main/Instant-Fisch-KRIS-HUB-fisch-go-it.lua\"))()",
            },
            {
                title = "XiaoFan Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xiaofanbaik-afk/XiaofanFree/refs/heads/main/XiaofanFree\", true))()",
            },
            {
                title = "Begod666 – Auto Fishing",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/begod666/gabut/refs/heads/main/autofishing'))()",
            },
            {
                title = "Rey_ScriptHub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ALiF999015/Fish-go/refs/heads/main/Rey_ScriptHub\"))()",
            },
            {
                title = "Get Free Admin Products",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/832020cf3f12e28a0e9d8cdc6532ffb60c6553cebbba74882eae8b317e635660/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/my-dragon-island-scripts/",
        slug = "my-dragon-island-scripts",
        scripts = {
            {
                title = "My Dragon Island script – (KEYLESS) Brev Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/onepiecefan4422-del/Brev-Hub/refs/heads/main/My%20Dragon%20Island\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blade-spin-scripts/",
        slug = "blade-spin-scripts",
        scripts = {
            {
                title = "inf money – 2# OPEN SOURCE",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/CRXYUNCLE/D2/refs/heads/main/Bladespin.lua'))()",
            },
            {
                title = "Gitan X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/fddttttt/GitanX/refs/heads/main/baldespin.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/last-dawn-scripts/",
        slug = "last-dawn-scripts",
        scripts = {
            {
                title = "Last Dawn script – (Atlas Hub)",
                has_key = true,
                code = "-- https://discord.gg/6yUsE6mKgc   we discord\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/ATLASTEAM01/ATLAS.LIVE/refs/heads/main/Loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/waste-time-scripts/",
        slug = "waste-time-scripts",
        scripts = {
            {
                title = "Waste Time script – (KEYLESS) Cipher hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/chipet01/Cipher/refs/heads/main/Waste%20time\"))()",
            },
            {
                title = "Mental Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://mentalhub.me\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pull-brainrots-scripts/",
        slug = "pull-brainrots-scripts",
        scripts = {
            {
                title = "Pull Brainrots script – (KEYLESS) Brev Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/onepiecefan4422-del/Brev-Hub/refs/heads/main/Pull%20Brainrots\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pet-lab-scripts/",
        slug = "pet-lab-scripts",
        scripts = {
        },
    },
    {
        page_url = "https://robscript.com/anime-story-scripts/",
        slug = "anime-story-scripts",
        scripts = {
            {
                title = "Anime Story script – (KEYLESS)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"\\104\\116\\116\\112\\115\\58\\47\\47\\114\\97\\119\\46\\103\\105\\116\\104\\117\\98\\117\\115\\101\\114\\99\\111\\110\\116\\101\\110\\116\\46\\99\\111\\109\\47\\110\\105\\99\\107\\48\\48\\50\\50\\47\\108\\111\\97\\100\\101\\114\\95\\109\\111\\111\\110\\104\\117\\98\\47\\114\\101\\102\\115\\47\\104\\101\\97\\100\\115\\47\\109\\97\\105\\110\\47\\82\\69\\65\\68\\77\\69\\46\\109\\100\"))()",
            },
            {
                title = "by NhatVMinh",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.jnkie.com/api/v1/luascripts/public/294696ec5af738b0a0a774924943be916cbf33c9b74b6c3c89fbc3f87f5b0f9d/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/rogue-piece-scripts/",
        slug = "rogue-piece-scripts",
        scripts = {
            {
                title = "Rogue Piece script – (Imp Hub)",
                has_key = true,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))()",
            },
            {
                title = "JinkX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/stormskmonkey/JinkX/main/Loader.lua\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Benjaminz",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/BenJaMinZHub/Loader/refs/heads/main/GetKeyAllGame.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/my-farm-scripts/",
        slug = "my-farm-scripts",
        scripts = {
            {
                title = "My Farm script – (KEYLESS)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/6QmTz0MU/raw\", true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/my-solar-farm-scripts/",
        slug = "my-solar-farm-scripts",
        scripts = {
            {
                title = "My Solar Farm script – (KEYLESS)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/MySolarFarm\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-ball-scripts/",
        slug = "anime-ball-scripts",
        scripts = {
            {
                title = "Anime Ball script – (KEYLESS) Ocevia Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Jerry-r-c/OceviaHub/refs/heads/main/AnimeBall.lua\",true))()",
            },
            {
                title = "Auto Parry – by ltseverydayyou",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/AnimeBallParry.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/collect-a-keycap-scripts/",
        slug = "collect-a-keycap-scripts",
        scripts = {
            {
                title = "Collect a Keycap script – (KEYLESS) by Demonalt",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/5uYc3Efe/raw\"))()",
            },
            {
                title = "By Rainyybs & Yo_Ra7",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/RainyGH/Keycap/refs/heads/main/CollectAKeycapKeyless'))()",
            },
            {
                title = "By sillydudescripts",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sillydudescripts/collect-a-keycap-script/refs/heads/main/main.lua\"))()",
            },
            {
                title = "By Belka",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/e124817c0a3fce9c8ce0e082549c3bb1993e61b539268d55d2f4b7b8497ef768/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/overkill-scripts/",
        slug = "overkill-scripts",
        scripts = {
            {
                title = "Overkill script – (Rift hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/aea918d511c8f01173b739c987c29816.lua\"))()",
            },
            {
                title = "Nyxor Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nyxor.cc/loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/escape-tsunami-for-brainrots-scripts/",
        slug = "escape-tsunami-for-brainrots-scripts",
        scripts = {
            {
                title = "Escape Tsunami For Brainrots script – (KEYLESS)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mynamewendel-ctrl/Blessed-Hub-X-/refs/heads/main/Escape%20Tsunami%20For%20Brainrots.lua\"))()",
            },
            {
                title = "Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/EscapeTsunamiForBrainrots\"))()",
            },
            {
                title = "Rat Hub X",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Ratkinator/RatX/refs/heads/main/Loader.lua\",true))()",
            },
            {
                title = "Malawion Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/09RAs9Fi\"))()",
            },
            {
                title = "TBB Hub – Destroy Wave",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/toilabao23/TBB_Owner/refs/heads/main/scriptEscapeTsunamiForBrainrots!\"))()",
            },
            {
                title = "xNightBearYT",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nightxhub/Free-Script/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "Crystal Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/3f3c32e8d1ca1916dd7dc2fd6f489de8.lua\"))()",
            },
            {
                title = "Redyn Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/JAdLJQqo/raw\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
            {
                title = "Lumin hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"http://luminon.top/loader.lua\"))()",
            },
            {
                title = "Imp Hub X",
                has_key = true,
                code = "script_key = \"\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua\"))()",
            },
            {
                title = "Warp Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.jnkie.com/api/v1/luascripts/public/a575aec3ad36b120097b90111736b0df5afe083f56ad1bcca33ff31d5185f3af/download\"))()",
            },
            {
                title = "zReal-King",
                has_key = true,
                code = "pcall(loadstring(game:HttpGet('https://raw.githubusercontent.com/zReal-King/Escape-Tsunami-For-Brainrots/refs/heads/main/Main.lua')))",
            },
        },
    },
    {
        page_url = "https://robscript.com/spin-a-baddie-scripts/",
        slug = "spin-a-baddie-scripts",
        scripts = {
            {
                title = "Spin a Baddie script – (KEYLESS) by ywxoscripts",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ywxoscripts/lua/refs/heads/main/9319914497.lua\"))()",
            },
            {
                title = "Kuronoko",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/3CBCQanf\"))()",
            },
            {
                title = "Indra Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/XVp8zvZn\"))()",
            },
            {
                title = "Ez Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.jnkie.com/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
            {
                title = "Apoc Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ApocHub/ApocHub/refs/heads/main/ApocHubMain\"))()",
            },
            {
                title = "Fayintz Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FayintXhub/FayintExploit/refs/heads/main/Loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/one-shot-scripts/",
        slug = "one-shot-scripts",
        scripts = {
            {
                title = "one shot script – (KEYLESS) by m4sk3d",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/MBpq6mDj'))()",
            },
            {
                title = "Axeus Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/devshawy-hub/AxeusHub/refs/heads/main/OneShotV2\"))()",
            },
            {
                title = "Hitbox Simple – by Scyro",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/zt3KeFFk/raw\"))()",
            },
            {
                title = "EzHub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
            {
                title = "Apoc Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ApocHub/ApocHub/refs/heads/main/ApocHubMain\"))()",
            },
            {
                title = "DreamSolutions",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Haruzxkk/dreamsolutions/refs/heads/main/one%20shot.lua\"))()",
            },
            {
                title = "Nova Solutions",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NovaSoIutions/One-Shot/refs/heads/main/e\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/math-murder-scripts/",
        slug = "math-murder-scripts",
        scripts = {
            {
                title = "Math Murder script – (KEYLESS) by Preppy hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/vrn8CvEA/raw\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/bee-swarm-simulator-scripts/",
        slug = "bee-swarm-simulator-scripts",
        scripts = {
            {
                title = "KEYLESS Bee Swarm Simulator script – (Verbal Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VerbalHubz/Verbal-Hub/refs/heads/main/Bee%20Swarm%20Sim.Lua\",true))()",
            },
            {
                title = "Kron hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/DevKron/Kron_Hub/refs/heads/main/version_1.0'))(\"\")",
            },
            {
                title = "Histy Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Historia00012/HISTORIAHUB/main/BSS%20FREE\"))()",
            },
            {
                title = "Macro V4",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://scripts.macrov4.com/macrov3.lua\"))()",
            },
            {
                title = "Automatically Get Diamond Egg",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://cdn.authguard.org/virtual-file/bcb8fba589364a629316af85674cd1d1\"))()",
            },
            {
                title = "Atlas Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chris12089/atlasbss/main/script.lua\"))()",
            },
            {
                title = "Dp Hub",
                has_key = false,
                code = "loadstring(\"\\108\\111\\97\\100\\115\\116\\114\\105\\110\\103\\40\\103\\97\\109\\101\\58\\72\\116\\116\\112\\71\\101\\116\\40\\34\\104\\116\\116\\112\\115\\58\\47\\47\\114\\97\\119\\46\\103\\105\\116\\104\\117\\98\\117\\115\\101\\114\\99\\111\\110\\116\\101\\110\\116\\46\\99\\111\\109\\47\\67\\79\\79\\76\\88\\80\\76\\79\\47\\68\\80\\45\\72\\85\\66\\45\\99\\111\\111\\108\\120\\112\\108\\111\\47\\114\\101\\102\\115\\47\\104\\101\\97\\100\\115\\47\\109\\97\\105\\110\\47\\66\\83\\83\\46\\108\\117\\97\\34\\41\\41\\40\\41\")()",
            },
            {
                title = "Stinger Server Hop For BSS Keyless Searcher System",
                has_key = false,
                code = "-- join our discord server! discord.gg/BcnxDQa32N\n_G.hook = \"\" -- discord webhook url (optional)\n_G.uid = \"\" -- discord user id for ping (optional)\n_G.delay = \"0\" -- delay before server hop in seconds\n_G.minlvl = \"1\" -- minimum vic level to attack (1-12)\n_G.maxlvl = \"12\" -- maximum vic level to attack (1-12)\n_G.onlygifted = false -- true = only attack/find gifted vics, false = any\n_G.room = \"\" -- sync room name for searcher system (optional, any name)\n_G.mainuser = \"\" -- main user for auto searcher system (optional)\n_G.mainwait = true -- true = main user waits for searchers to find vics (5secs), false = main hops immediately if no vics in list\n\n_G.searcher = false -- true = searcher mode (finds and sends to webhook), false = killing vic\n_G.vic = false -- send discord notification when vic found\n_G.sprout = false -- send discord notification when sprout found\n_G.windy = false -- send discord notification when windy found\n\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/1toop/vichop/main/hop.lua\"))()",
            },
            {
                title = "rb_Code v2",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xxxrrxsds-art/losehubs/refs/heads/main/BSSBeta.lua\"))()",
            },
            {
                title = "Yoxi hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Yomkaa/YOXI-HUB/refs/heads/main/loader\",true))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua\"))()",
            },
        },
    },
}

if #allPages == 0 then
    warn("[ROBScript Hub] No pages embedded; UI will still show but be empty.")
end

local guiParent = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui") or localPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ROBScriptHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

-- Кнопка Toggle (чуть выше)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleHubButton"
toggleButton.Size = UDim2.new(0, 140, 0, 30)
toggleButton.AnchorPoint = Vector2.new(0.5, 0)
toggleButton.Position = UDim2.new(0.1, 0, 0, 2) -- было 0,6 → поднял выше
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.BackgroundTransparency = 0.3
toggleButton.BorderSizePixel = 1
toggleButton.BorderColor3 = Color3.fromRGB(90, 90, 90)
toggleButton.Text = "Toggle Hub"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 14
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Основное окно
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 400)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = mainFrame

local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 8)
uiCornerMain.Parent = mainFrame

local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Text = "ROBScript Hub"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 18
titleBar.Parent = mainFrame

local uiCornerTitle = Instance.new("UICorner")
uiCornerTitle.CornerRadius = UDim.new(0, 8)
uiCornerTitle.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -8, 0.5, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = titleBar

local uiCornerClose = Instance.new("UICorner")
uiCornerClose.CornerRadius = UDim.new(0, 6)
uiCornerClose.Parent = closeButton

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
contentFrame.Position = UDim2.new(0, 0, 0, 32)
contentFrame.Size = UDim2.new(1, 0, 1, -32)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Левая часть: список игр
local leftFrame = Instance.new("Frame")
leftFrame.Name = "GamesFrame"
leftFrame.Size = UDim2.new(0.4, -8, 1, -16)
leftFrame.Position = UDim2.new(0, 8, 0, 8)
leftFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
leftFrame.BorderSizePixel = 0
leftFrame.Parent = contentFrame

local uiCornerLeft = Instance.new("UICorner")
uiCornerLeft.CornerRadius = UDim.new(0, 8)
uiCornerLeft.Parent = leftFrame

local gameSearchBox = Instance.new("TextBox")
gameSearchBox.Name = "GameSearchBox"
gameSearchBox.Size = UDim2.new(1, -16, 0, 28)
gameSearchBox.Position = UDim2.new(0, 8, 0, 8)
gameSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
gameSearchBox.BorderSizePixel = 0
gameSearchBox.PlaceholderText = "Search games..."
gameSearchBox.Text = ""
gameSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
gameSearchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
gameSearchBox.Font = Enum.Font.Gotham
gameSearchBox.TextSize = 14
gameSearchBox.ClearTextOnFocus = false
gameSearchBox.Parent = leftFrame

local uiCornerGameSearch = Instance.new("UICorner")
uiCornerGameSearch.CornerRadius = UDim.new(0, 6)
uiCornerGameSearch.Parent = gameSearchBox

local gameList = Instance.new("ScrollingFrame")
gameList.Name = "GameList"
gameList.Size = UDim2.new(1, -16, 1, -52)
gameList.Position = UDim2.new(0, 8, 0, 44)
gameList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
gameList.BorderSizePixel = 0
gameList.CanvasSize = UDim2.new(0, 0, 0, 0)
gameList.ScrollBarThickness = 4
gameList.Parent = leftFrame

local uiCornerGameList = Instance.new("UICorner")
uiCornerGameList.CornerRadius = UDim.new(0, 6)
uiCornerGameList.Parent = gameList

local gameListLayout = Instance.new("UIListLayout")
gameListLayout.Padding = UDim.new(0, 4)
gameListLayout.FillDirection = Enum.FillDirection.Vertical
gameListLayout.SortOrder = Enum.SortOrder.LayoutOrder
gameListLayout.Parent = gameList

gameListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    gameList.CanvasSize = UDim2.new(0, 0, 0, gameListLayout.AbsoluteContentSize.Y + 8)
end)

-- Правая часть: список скриптов
local rightFrame = Instance.new("Frame")
rightFrame.Name = "ScriptsFrame"
rightFrame.Size = UDim2.new(0.6, -16, 1, -16)
rightFrame.Position = UDim2.new(0.4, 8, 0, 8)
rightFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
rightFrame.BorderSizePixel = 0
rightFrame.Parent = contentFrame

local uiCornerRight = Instance.new("UICorner")
uiCornerRight.CornerRadius = UDim.new(0, 8)
uiCornerRight.Parent = rightFrame

local scriptSearchBox = Instance.new("TextBox")
scriptSearchBox.Name = "ScriptSearchBox"
scriptSearchBox.Size = UDim2.new(1, -16, 0, 28)
scriptSearchBox.Position = UDim2.new(0, 8, 0, 8)
scriptSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
scriptSearchBox.BorderSizePixel = 0
scriptSearchBox.PlaceholderText = "Search scripts..."
scriptSearchBox.Text = ""
scriptSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
scriptSearchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
scriptSearchBox.Font = Enum.Font.Gotham
scriptSearchBox.TextSize = 14
scriptSearchBox.ClearTextOnFocus = false
scriptSearchBox.Parent = rightFrame

local uiCornerScriptSearch = Instance.new("UICorner")
uiCornerScriptSearch.CornerRadius = UDim.new(0, 6)
uiCornerScriptSearch.Parent = scriptSearchBox

local scriptList = Instance.new("ScrollingFrame")
scriptList.Name = "ScriptList"
scriptList.Size = UDim2.new(1, -16, 1, -52)
scriptList.Position = UDim2.new(0, 8, 0, 44)
scriptList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scriptList.BorderSizePixel = 0
scriptList.CanvasSize = UDim2.new(0, 0, 0, 0)
scriptList.ScrollBarThickness = 4
scriptList.Parent = rightFrame

local uiCornerScriptList = Instance.new("UICorner")
uiCornerScriptList.CornerRadius = UDim.new(0, 6)
uiCornerScriptList.Parent = scriptList

local scriptListLayout = Instance.new("UIListLayout")
scriptListLayout.Padding = UDim.new(0, 4)
scriptListLayout.FillDirection = Enum.FillDirection.Vertical
scriptListLayout.SortOrder = Enum.SortOrder.LayoutOrder
scriptListLayout.Parent = scriptList

scriptListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scriptList.CanvasSize = UDim2.new(0, 0, 0, scriptListLayout.AbsoluteContentSize.Y + 8)
end)

---------------------------------------------------------------------
-- DATA <-> UI
---------------------------------------------------------------------

local currentPage = nil
local currentPagesView = {}
local currentScriptsView = {}

local function createScriptButtonsForPage(page, query)
    clearChildren(scriptList)
    if not page then
        currentScriptsView = {}
        return
    end
    local filtered = filterScripts(page, query or "")
    currentScriptsView = filtered
    for _, scr in ipairs(filtered) do
        local sbtn = Instance.new("TextButton")
        sbtn.Name = "ScriptButton"
        sbtn.Size = UDim2.new(1, -8, 0, 28)
        sbtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sbtn.BorderSizePixel = 0
        sbtn.TextXAlignment = Enum.TextXAlignment.Left

        local keyLabel = scr.has_key and "[KEY] " or "[NO KEY] "
        sbtn.Text = keyLabel .. (scr.title or "Untitled")

        sbtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        sbtn.Font = Enum.Font.Gotham
        sbtn.TextSize = 14
        sbtn.Parent = scriptList

        local scorner = Instance.new("UICorner")
        scorner.CornerRadius = UDim.new(0, 6)
        scorner.Parent = sbtn

        sbtn.MouseButton1Click:Connect(function()
            runScript(scr)
        end)
    end
end

local function createGameButton(page)
    local btn = Instance.new("TextButton")
    btn.Name = "GameButton"
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = normalizeGameTitle(page)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = gameList

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        currentPage = page
        scriptSearchBox.Text = ""
        for _, child in ipairs(gameList:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
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
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function showMain()
    if isOpen then return end
    isOpen = true
    uiScale.Scale = 0.8
    mainFrame.Visible = true
    local tween = TweenService:Create(uiScale, tweenInfo, {Scale = 1})
    tween:Play()
end

local function hideMain()
    if not isOpen then return end
    isOpen = false
    local tween = TweenService:Create(uiScale, tweenInfo, {Scale = 0.8})
    tween:Play()
    tween.Completed:Connect(function()
        if not isOpen then
            mainFrame.Visible = false
        end
    end)
end

-- Крестик теперь просто скрывает окно, а не уничтожает весь GUI
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
    currentPage = allPages[1]
    createScriptButtonsForPage(currentPage, "")
end

print("[ROBScript Hub] Loaded with", #allPages, "pages from hub.json")
