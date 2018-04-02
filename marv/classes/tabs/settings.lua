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
require "classes.tabs.tab"
require "classes.button"

local ScrollWindow = require "classes.scroll_window"

local ToggleButton = Class { -- functions defined below
    __includes = {RECT}
}

SettingsTab = Class {
    __includes = {Tab},

    button_color = 70,

    init = function(self, eps, dy)
        Tab.init(self, eps, dy)

        self.w = self.w - 13 / 2

        self.true_h = self.h
        local obj = { -- scroll bar in case some day we have too many options
            pos = self.pos,
            getHeight = function() return self.true_h end,
            draw = function() self:trueDraw() end,
            mousePressed = function(obj, ...) self:trueMousePressed(...) end,
            mouseMoved = function(obj, ...) self:trueMouseMoved(...) end,
            mouseScroll = function(obj, ...) self:trueMouseScroll(...) end
        }
        self.box = ScrollWindow(self.w + 5, self.h, obj)
        self.box.sw = 13
        self.box.color = {12, 30, 10}

        self.options = {
            ["Background Music"] = ToggleButton(0, 0, 20, 20, function() print("on") end, function() print("off") end, true),
            ["Sound Effects"] = ToggleButton(0, 0, 20, 20, function() print("on") end, function() print("off") end, true),
            ["Robot Messages Popup"] = ToggleButton(0, 0, 20, 20, function() print("on") end, function() print("off") end, true),
        }

        self.title_font = FONTS.firaBold(50)
        self.options_font = FONTS.fira(30)

        self.text_color = {0, 0, 0}

        self.tp = "settings_tab"
        self:setId("settings_tab")
    end
}

local function wrap_height(font, txt, w)
    local _, wrap = font:getWrap(txt, w)
    return font:getHeight() * (#wrap)
end

function SettingsTab:trueDraw()
    -- Possible future improvement: Avoid calling Util.stylizeText all the time, since the output is always the same.
    love.graphics.setColor(self.text_color)

    local h = 0
    love.graphics.setFont(self.title_font)
    love.graphics.printf("Settings", self.pos.x, self.pos.y + self.title_font:getHeight() * .2, self.w, 'center')
    h = h + self.title_font:getHeight() * 2 -- title

    love.graphics.setFont(self.options_font)

    for name, but in pairs(self.options) do
        but.pos.x = self.pos.x + 60
        but.pos.y = self.pos.y + h
        but:draw()
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(name, but.pos.x + but.w + 20, but.pos.y + but.h / 2 - self.options_font:getHeight() / 2)
        h = h + but.h * 3
    end
end

function SettingsTab:trueMousePressed(x, y, but)
    for _, b in pairs(self.options) do
        b:mousePressed(x, y, but)
    end
end

function SettingsTab:trueMouseMoved(x, y)
    for _, b in pairs(self.options) do
        b:mouseMoved(x, y)
    end
end

function SettingsTab:trueMouseScroll(x, y)
end

function ToggleButton:init(x, y, w, h, on_callback, off_callback, is_on)
    RECT.init(self, x, y, w, h)
    self.on_callback = on_callback
    self.off_callback = off_callback
    self.on = is_on
    if self.on then
        self.square_mod = 1
    else
        self.square_mod = 0
    end
    self.hover = false
end

function ToggleButton:mousePressed(x, y, but)
    if but == 1 and Util.pointInRect(x, y, self.pos.x, self.pos.y, self.w, self.h) then
        if self.on then
            self:off_callback()
            MAIN_TIMER:tween(.1, self, { square_mod = 0 })
        else
            self:on_callback()
            MAIN_TIMER:tween(.1, self, { square_mod = 1 })
        end
        self.on = not self.on
    end
end

function ToggleButton:mouseMoved(x, y)
    self.hover = Util.pointInRect(x, y, self.pos.x, self.pos.y, self.w, self.h)
end

function ToggleButton:draw()
    love.graphics.setColor(10, 10, 70)
    love.graphics.setColor(30, 30, 30)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w, self.h)
    if self.square_mod > 0 then
        local sw = (self.w - 10) * self.square_mod
        local sh = (self.h - 10) * self.square_mod
        love.graphics.rectangle('fill', self.pos.x + self.w / 2 - sw / 2, self.pos.y + self.h / 2 - sh / 2, sw, sh)
    end
    if self.hover then
        love.graphics.setColor(200, 200, 200, 80)
        love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)
    end
end

function SettingsTab:mousePressed(x, y, but)
    self.box:mousePressed(x, y, but)
end

function SettingsTab:mouseMoved(x, y)
    self.box:mouseMoved(x, y)
end

function SettingsTab:mouseReleased(x, y, but)
    self.box:mouseReleased(x, y, but)
end

function SettingsTab:update(dt)
    self.box:update(dt)
end

function SettingsTab:mouseScroll(x, y)
    self.box:mouseScroll(x, y)
end

function SettingsTab:draw()
    self.box:draw()
end
