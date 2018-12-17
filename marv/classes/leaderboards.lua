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

-- Leaderboards class
local funcs = {}

Leaderboards = Class{
    __includes = {RECT},
    init = function(self, x, y, title)
        RECT.init(self, x, y, 350, 480, Color.white())

        self.loading = true --If its loading stats
        self.error = false --If has reached some error trying to get stats

        self.handles = {}

        self.title = title

        self.graph = {}

        self.friends_scores = {}

        --Graphics stuff
        self.h_margin = 25
        self.graph_w = self.w - 2*self.h_margin
        self.graph_h = 140
        self.graph_bg_color = Color.new(120, 30, 50)
        self.graph_border_color = Color.white()

        self.bar_h = {}
        self.max_bar_h = self.graph_h - 20

        self.bar_border_color = self.graph_border_color
        self.bar_border_width = 3
        self.bar_bg_color = Color.new(0, 15, 60)

        self.division_font = FONTS.fira(15)
        self.division_h = 8

        self.player_line_font = FONTS.robotoBold(19)
        self.player_line_color = Color.new(0, 240, 180)
        self.player_line_h = 0

        self.bg_color = Color.new(120, 30, 40)
        self.border_color = Color.black()

        self.title_font = FONTS.fira(30)
        self.title_bg_color = Color.new(0, 30, 10)
        self.title_color = Color.white()

        self.loading_font = FONTS.fira(30)
        self.loading_color = Color.white()
        self.loading_text = "Loading stats..."

        self.error_font = FONTS.fira(30)
        self.error_color = Color.red()
        self.error_text = "ERROR LOADING STATS"

        self.headline_font = FONTS.robotoBold(20)
        self.headline_color = Color.white()
        self.rank_font = FONTS.fira(18)
        self.max_name_size = 16
        self.friends_font = FONTS.fira(17)
        self.friends_color = Color.white()
        self.friends_division_line_color = Color.new(120, 30, 60)
        self.friends_division_line_width = 2

        self.rank_headline = "RANK"
        self.rank_x = self.pos.x + self.h_margin
        self.name_headline = "NAME"
        self.name_x = self.rank_x + self.headline_font:getWidth(self.rank_headline) + 20
        self.score_headline = "SCORE"
        self.score_x = self.pos.x + self.w - self.h_margin - self.headline_font:getWidth(self.name_headline)
    end
}

function Leaderboards:draw()
    local g = love.graphics
    local l = self

    --Draw window
    Color.set(l.bg_color)
    g.rectangle("fill", l.pos.x, l.pos.y, l.w, l.h, 5)
    g.setLineWidth(3)
    Color.set(l.border_color)
    g.rectangle("line", l.pos.x, l.pos.y, l.w, l.h, 5)
    local title_margin = 15
    local th = l.title_font:getHeight(l.title)
    local tw = l.title_font:getWidth(l.title)
    Color.set(l.title_bg_color)
    g.rectangle("fill", l.pos.x, l.pos.y, l.w, th + 2*title_margin)
    Color.set(l.border_color)
    g.rectangle("line", l.pos.x, l.pos.y, l.w, th + 2*title_margin)

    --Draw title
    Color.set(l.title_color)
    love.graphics.setFont(l.title_font)
    love.graphics.print(l.title, l.pos.x + l.w/2 - tw/2, l.pos.y + title_margin)

    --Draw graph bg
    local x = l.pos.x + l.h_margin
    local y = l.pos.y + 3*title_margin + th
    Color.set(l.graph_bg_color)
    g.rectangle("fill", x, y, l.graph_w, l.graph_h)
    g.setLineWidth(3)
    Color.set(l.graph_border_color)
    g.rectangle("line", x, y, l.graph_w, l.graph_h)

    if self.error then
        local text = l.error_text
        Color.set(l.error_color)
        g.setFont(l.error_font)
        local tx = x + l.graph_w/2 - l.error_font:getWidth(text)/2
        local ty = y + l.graph_h/2 - l.error_font:getHeight(text)/2
        g.print(text, tx, ty)
    elseif self.loading then
        local text = l.loading_text
        Color.set(l.loading_color)
        g.setFont(l.loading_font)
        local tx = x + l.graph_w/2 - l.loading_font:getWidth(text)/2
        local ty = y + l.graph_h/2 - l.loading_font:getHeight(text)/2
        g.print(text, tx, ty)
    else
        --Draw bars
        y = y + l.graph_h
        for i = 1, l.divisions do
            Color.set(l.bar_bg_color)
            g.rectangle("fill", x, y - l.bar_h[i], l.bar_w, l.bar_h[i])
            Color.set(l.bar_border_color)
            g.rectangle("line", x, y - l.bar_h[i], l.bar_w, l.bar_h[i])
            x = x + l.bar_w
        end

        --Draw division
        g.setFont(l.division_font)
        Color.set(l.graph_border_color)
        g.setLineWidth(3)
        y = y + 1
        if self.step == 1 then
            --Draw numbers
            x = l.pos.x + l.h_margin + l.bar_w/2
            for i = 1, l.divisions do
                local value = self.min + (i-1)*self.step
                g.print(value, x - l.division_font:getWidth(value)/2, y + self.division_h + 2)
                x = x + l.bar_w
            end
            --Draw lines
            x = l.pos.x + l.h_margin
            for i = 0, l.divisions do
                g.line(x,y,x,y+self.division_h)
                x = x + l.bar_w
            end
        else
            --Draw numbers and lines
            x = l.pos.x + l.h_margin
            for i = 0, l.divisions do
                g.line(x,y,x,y+self.division_h)
                local value = self.min + i*self.step
                g.print(value, x - l.division_font:getWidth(value)/2, y + self.division_h + 2)
                x = x + l.bar_w
            end
        end

        --Draw player score line
        y = y - 3
        if l.player_score then
            if self.step > 1 then
                x = l.pos.x + l.h_margin + l.graph_w * ((l.player_score - l.min)/(l.max - l.min))
            else
                x = l.pos.x + l.h_margin + l.bar_w/2 + l.bar_w * (l.player_score - l.min)
            end
            local margin = 2
            local text = 'YOU'
            local tw = l.player_line_font:getWidth(text)
            local th = l.player_line_font:getHeight(text)
            local tx = x - tw/2
            local ty = y - l.player_line_h - th - 4
            --Draw bg
            g.setColor(255,255,255,235)
            g.rectangle("fill",tx-margin,ty-margin,tw+2*margin,th+2*margin,5)
            --Draw text
            Color.set(l.player_line_color)
            g.setFont(l.player_line_font)
            g.print(text, tx, ty)
            g.setLineWidth(5)
            --Draw line
            g.line(x, y, x, y - l.player_line_h)
        end

        --Draw friends score headlines
        y = y + 40
        Color.set(l.headline_color)
        g.setFont(l.headline_font)
        g.print(l.rank_headline,self.rank_x, y)
        g.print(l.name_headline,self.name_x, y)
        g.print(l.score_headline,self.score_x, y)

        --Draw friends scores
        y = y + 30
        local gap = 30
        g.setLineWidth(l.friends_division_line_width)
        for i, data in ipairs(self.friends_scores) do
            Color.set(l.friends_color)
            g.setFont(l.rank_font)
            g.print(data.rank..'.',self.rank_x, y)
            g.setFont(l.friends_font)
            g.print(data.name,self.name_x, y)
            g.print(data.score,self.score_x, y)
            Color.set(l.friends_division_line_color)
            y = y + gap
            g.line(l.pos.x + l.h_margin, y - 3, l.pos.x + l.w - l.h_margin, y - 3)
        end

    end
end

function Leaderboards:kill()
    for _,h in pairs(self.handles) do
        MAIN_TIMER:cancel(h) --Stops any timers this object has
    end
    self.death = true
end

function Leaderboards:gotError()
    self.error = true
end

function Leaderboards:showResults(scores, player_score, friends_scores)
    --Get min and max value from scores
    self.min = scores[1]
    self.max = scores[1]
    for _, score in pairs(scores) do
        if score < self.min then
            self.min = score
        end
        if score > self.max then
            self.max = score
        end
    end

    --Set divisions
    self.divisions = math.min(10, self.max - self.min + 1)
    self.step = math.ceil((self.max - self.min + 1)/self.divisions)

    --Init graph
    for i = 1, self.divisions do
        self.graph[i] = 0
    end

    --Populate with scores
    local max_value = 0
    for _, score in pairs(scores) do
        local i = math.floor((score-self.min)/self.step) + 1
        i = math.min(i, self.divisions)
        self.graph[i] = self.graph[i] + 1
        if self.graph[i] > max_value then
            max_value = self.graph[i]
        end
    end

    --Initialize bars
    self.bar_w = self.graph_w/self.divisions
    for i = 1, self.divisions do
        self.bar_h[i] = 0
        local target = self.max_bar_h * self.graph[i]/max_value
        local h = MAIN_TIMER:tween(1, self.bar_h, {[i] = target}, 'out-quad')
        table.insert(self.handles, h)
    end

    --Initialize player score
    table.insert(self.handles, MAIN_TIMER:after(.8, function()
        self.player_score = player_score
        self.player_line_h = 0
        local h = MAIN_TIMER:tween(1, self, {player_line_h = self.max_bar_h}, 'out-quad')
        table.insert(self.handles, h)
    end))

    --Get friends scores
    self.friends_scores = friends_scores
    table.sort(self.friends_scores, function(a,b) return a.rank < b.rank end)
    --Fix names of players to fit inside the window
    for _, data in ipairs(self.friends_scores) do
        if #data.name > self.max_name_size then
            data.name = data.name:sub(1,self.max_name_size-3) .. "..."
        end
    end

    self.loading = false
end

function funcs.create(x, y, title)
    local l = Leaderboards(x,y,title)
    l:addElement(DRAW_TABLE.L2u, "leaderboard")

    return l
end
return funcs
