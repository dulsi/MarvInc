--[[
#####################################
Marvellous Inc.
Copyright (C) 2017  MarvellousSoft & USPGameDev
See full license in file LICENSE.txt
(https://github.com/MarvellousSoft/MarvInc/blob/dev/LICENSE.txt)
#####################################
]]--

require "classes.primitive"
local Color = require "classes.color.color"

local parser = {}

local str_subchar = function(str, i, c)
    local n = str:len()
    if i < 1 or i > n then return str end
    if c == nil then return str.sub(1, i-1)..' '..str:sub(i+1) end
    return str:sub(1, i-1)..c..str:sub(i+1)
end

local init_map = function(c)
    c = c==nil and ' ' or c
    local M = ""
    for i = 1, ROWS*COLS do
        M = M..c
    end
    return M
end

local new_safe_env = function(...)
    local E = {}
    for _, v in pairs{...} do
        if type(v) == "string" then
            E[v] = _G[v]
        elseif type(v) == "table" then
            for _, u in pairs(v) do
                E[u] = {}
                local t = _G[u]
                for k, f in pairs(t) do
                    if type(f) == "function" then
                        E[u][k] = f
                    end
                end
            end
        end
    end
    return E
end

function parser.safe_env()
    local E = new_safe_env(
        "assert",
        "error",
        "ipairs",
        "next",
        "pairs",
        "pcall",
        "print",
        "select",
        "tonumber",
        "tostring",
        "type",
        "unpack",
        "_VERSION",
        "xpcall",
        { -- Special cases
            "string",
            "table",
            "math",
        }
    )
    return E
end

local retrieve_asset = function(key)
    if key == nil then return nil, "Expected reference key to asset. Got nil value!" end
    local a = CUST_SHEET_IMG[key]
    if a ~= nil then return a, "sprite" end
    a = CUST_OBJS_IMG[key]
    if a ~= nil then return a, "image" end
    a = SHEET_IMG[key]
    if a ~= nil then return a, "sprite" end
    a = OBJS_IMG[key]
    if a ~= nil then return a, "image" end
    return nil, "Asset "..key.." not found!"
end

function parser.prepare(puz_f, t)
    -- Functions and tables allowed by the environment (considered safe-ish).
    local _E = parser.safe_env()
    setfenv(puz_f, _E)
    if t == "level" then
        -- Constants
        _E.ROWS = ROWS
        _E.COLS = COLS

        -- Meta table
        _E.Meta = {
            Name = "Untitled",
            ID = "U.0",
            Lines = -1,
            Memory = 10,
            Info = "No info.",
        }

        -- Objective table
        _E.Objective = {
            Text = "No objectives listed.",
            Check = function() return false end,
        }

        -- Floor
        _E.Floor = {}
        _E.Floor.L = init_map()
        _E.Floor.__ref_table = {}
        _E.Floor.__iref_table = {}
        _E.Floor.Register = function(self, key, c)
            self.__ref_table[c] = key
            self.__iref_table[key] = c
        end
        _E.Floor.PlaceAt = function(self, key, i, j)
            local p = i+j*COLS + 1
            self.L = str_subchar(self.L, p, self.__iref_table[key])
        end

        -- Objects
        _E.Objects = {}
        _E.Objects.L = init_map()
        _E.Objects.__ref_table = {}
        _E.Objects.__iref_table = {}
        _E.Objects.Register = function(self, obj, c)
            self.__ref_table[c] = obj
            self.__iref_table[obj] = c
        end
        _E.Objects.PlaceAt = function(self, obj, i, j)
            local p = i+j*COLS + 1
            self.L = str_subchar(self.L, p, self.__iref_table[obj])
        end

        -- Invisible Wall
        _E.InvWall = {}
        _E.InvWall.L = init_map(0)
        _E.InvWall.Wall = function(self, i, j)
            local p = j*COLS+i+1
            str_subchar(self.L, p, 1)
        end
        _E.InvWall.NoWall = function(self, i, j)
            local p = j*COLS+i+1
            str_subchar(self.L, p, 0)
        end

        -- Importing assets
        _E.Import = {}
        _E.Import.__ref_imgs = {}
        _E.Import.__ref_sprites = {}
        _E.Import.__ref_tiles = {}
        _E.Import.Image = function(self, key, path)
            _E.Import.__ref_imgs[key] = path
        end
        _E.Import.Sprite = function(self, key, d, path)
            _E.Import.__ref_sprites[key] = {d, path}
        end
        _E.Import.Tile = function(self, key, path)
            _E.Import.__ref_tiles[key] = path
        end

        -- Constructors
        _E.Bucket = function(cnt, clr)
            return {id = "bucket", cnt = cnt, c = clr}
        end
        _E.Obstacle = function(bg, key, d, clr)
            return {id = "obstacle", bg = bg, key = key, d = d, c = clr}
        end
        _E.Dead = function(bg, key, bg, c, d)
            if d == nil then return {id = "dead", bg = bg, key = key, c = c} end
            return {id = "dead", bg = bg, c = c, key = key, d = d}
        end
        _E.DeadSwitch = function(bg, key_on, d, c, img_off, bckt)
            return {id = "dead_switch", key_on = key_on, d = d, c = c, img_off = img_off, bckt = bckt}
        end
        _E.Container = function(bg, key, d, c, cnt, cnt_c)
            return {id = "container", bg = bg, key = key, d = d, c = c, cnt = cnt, cnt_c = cnt_c}
        end
        _E.Emitter = function(img, bg, c, r_key, r_bg, r_d, r_c)
            return {id = "emitter", key = img, c = c, r = {key = r_key, bg = r_bg, d = r_d, c = r_c}}
        end
        _E.Lava = function()
            return {id = "dead_switch", key_on = "lava", d = 0.2, bg = true, c = "white", img_off = "solid_lava", bckt = true}
        end
        _E.Console = function(img, c, bg, data, n)
            return {id = "console", img = img, c = c, bg = bg, data = data, n = n}
        end

        -- Game
        _E.Game = {}
        _E.Game.OnStart = function() end
        _E.Game.OnEnd = function() end
        _E.Game.OnDeath = function() end
        _E.Game.OnTurn = function() end

        _E.Bot = {}
        _E.Bot.Position = {0, 0}
        _E.Bot.GetPosition = function()
            return ROOM.bot.pos.x, ROOM.bot.pos.y
        end
        _E.Bot.Orientation = "NORTH"

    elseif t == "email" then
        _E.__emails = {}
        _E.Email = {}
        _E.Email.New = function()
            local _e = {
                Title = "Untitled",
                Text = "Your email text here.",
                Attach = function(self, key) self.__img = key end,
                Authors = "Author Name (author@email.com)",
                Portrait = function(self, key) self.__portrait = key end,
                SetMain = function(self, b) self.__main = b end,
                SetDeletable = function(self, b) self.__deletable = b end,
            }
            table.insert(_E.__emails, _e)
            return _e
        end
        -- Importing assets
        _E.Import = {}
        _E.Import.__ref_imgs = {}
        _E.Import.Image = function(self, key, path)
            _E.Import.__ref_imgs[key] = path
        end
    end

    return _E
end

function parser.parse(id, noload)
    local f, err
    f, err = love.filesystem.load("custom/" .. id .. "/level.lua")
    if err then print(err) end
    local E = parser.prepare(f, "level")
    local s, err = pcall(f)
    if not s then
        print("Custom level "..id.." has failed to compile!")
        print(err)
        return nil
    end
    local P = Puzzle()
    P.name = E.Meta.Name
    P.id = id
    P.is_custom = true
    P.n = E.Meta.ID
    P.turn_handler = E.Game.OnTurn
    P.orient = E.Bot.Orientation
    P.init_pos = Vector(E.Bot.Position[1], E.Bot.Position[2])
    P.grid_floor = {}
    P.grid_obj = {}
    P.inv_wall = {}
    for i=1, ROWS do
        P.grid_floor[i] = {}
        P.grid_obj[i] = {}
        P.inv_wall[i] = {}
    end

    if E.Floor.L:len() ~= COLS*ROWS then
        print("Floor layer incomplete!")
        return nil
    end
    if E.Objects.L:len() ~= COLS*ROWS then
        print("Objects layer incomplete!")
        return nil
    end
    if E.InvWall.L:len() ~= 0 and E.InvWall.L:len() ~= COLS*ROWS then
        print("InvWall was not properly declared! May be incomplete.")
        return nil
    end

    local cpath = "custom/"..id.."/"
    for k, v in pairs(E.Import.__ref_imgs) do
        CUST_OBJS_IMG[k] = love.graphics.newImage(cpath .. v)
    end
    for k, v in pairs(E.Import.__ref_tiles) do
        CUST_TILES_IMG[k] = love.graphics.newImage(cpath .. v)
    end
    for k, v in pairs(E.Import.__ref_sprites) do
        CUST_SHEET_IMG[k] = {love.graphics.newImage(cpath .. v[2]), v[1]}
    end

    for i=1, COLS do
        for j=1, ROWS do
            local p = i+j*COLS
            local k = E.Floor.L:sub(p, p)
            P.grid_floor[i][j] = E.Floor.__ref_table[k]
        end
    end

    for i=1, COLS do
        for j=1, ROWS do
            local p = i+j*COLS
            local k = E.InvWall.L:sub(p, p)
            if k == "1" then
                P.inv_wall[i][j] = '1'
            end
        end
    end

    for i=1, COLS do
        for j=1, ROWS do
            local p = i+j*COLS
            local r = E.Objects.L:sub(p, p)
            local o = E.Objects.__ref_table[r]
            if o ~= nil then
                local id = o.id
                local O = nil
                if id == "bucket" then
                    O = Bucket(P.grid_obj, i, j, "bucket", true, nil, nil, nil,
                        {pickable=true, color=o.clr, content=o.cnt})
                elseif id == "obstacle" then
                    -- Implement safe onInventoryDrop and onWalk later?
                    O = Obstacle(P.grid_obj, i, j, o.key, o.bg, o.d, o.c, nil, nil)
                elseif id == "dead" then
                    O = Dead(P.grid_obj, i, j, o.key, o.bg, o.d, o.c)
                elseif id == "dead_switch" then
                    O = DeadSwitch(P.grid_obj, i, j, o.key, o.bg, o.d, o.c, o.img_off, {bucketable=o.bckt})
                elseif id == "container" then
                    O = Container(P.grid_obj, i, j, o.key, o.bg, o.d, o.c, nil, {content=o.cnt, content_color=o.cnt_c})
                elseif id == "emitter" then
                    O = Emitter(P.grid_obj, i, j, o.key, o.bg, o.c, nil, nil, {o.r.key, o.r.bg, o.r.d, o.r.c})
                elseif id == "console" then
                    local _d = (o.d == nil) and "output" or o.d
                    O = Console(P.grid_obj, i, j, o.img, o.bg, o.c, nil, nil, {vec=_d, show_nums=o.n})
                else
                    print("Unrecognized object "..tostring(id).." at position ("..tostring(j)..", "..tostring(i)..").")
                end
                o.Object = O
            end
        end
    end

    P.objective_text = E.Objective.Text
    P.objective_checker = E.Objective.Check
    P.lines_on_terminal = E.Meta.Lines <= 0 and 99 or E.Meta.Lines
    P.memory_slots = E.Meta.Memory
    P.extra_info = E.Meta.Info
    P.on_start = E.Game.OnStart
    P.on_end = E.Game.OnDeath
    P.custom_completed = function()
        local title, text, c, o1, c1, o2, c2 = E.Game.OnEnd()
        PopManager.new(title, text, c,
            {func = function() ROOM:disconnect() end, text = o1, clr = Color[c1]()},
            {func = function() ROOM:disconnect() end, text = o2, clr = Color[c2]()})
    end
    if not noload then
        P.code, P.renames = SaveManager.load_code(id, true)
    end

    return P
end

function parser.load_email(id)
    local f, err
    f, err = love.filesystem.load("custom/" .. id .. "/email.lua")
    if err then print(err) end
    local E = parser.prepare(f, "email")
    f()
    local me = nil
    for k, v in ipairs(E.__emails) do
        if v.__main then
            me = v
            break
        end
    end
    if me == nil and #E.__emails ~= 0 then
        print("There must be at least one main email!")
        return nil
    end
    local cpath = "custom/"..id.."/"
    for k, v in pairs(E.Import.__ref_imgs) do
        CUST_OBJS_IMG[k] = love.graphics.newImage(cpath .. v)
    end
    if me.__portrait then
        CUST_AUTHOR_IMG[me.Authors] = love.graphics.newImage(cpath .. E.Import.__ref_imgs[me.__portrait])
    end
    if not Mail.exists(me.Title) then
        return Mail.new_custom(false, id, me.Title, me.Text, me.Authors, me.__deletable, id, nil, nil, CUST_OBJS_IMG[me.__img])
    end
end

function parser.read(id)
    if love.filesystem.exists("custom/"..id.."/email.lua") then
        parser.load_email(id)
    end
    return parser.parse(id)
end

return parser