--Marvellous Inc.
--Copyright (C) 2017  MarvellousSoft
--See full license in file LICENSE.txt

local Mail = require "classes.tabs.email"

local franz = {}

franz.require_puzzles = {'diego_died'}
franz.wait = 13

function franz.run()
    Mail.new('franz1')
end

return franz
