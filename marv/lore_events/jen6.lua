--Marvellous Inc.
--Copyright (C) 2017  MarvellousSoft
--See full license in file LICENSE.txt

local Mail = require "classes.tabs.email"

local jen = {}

jen.require_puzzles = {'liv7a', 'liv7b', at_least = 1}
jen.wait = 150

function jen.run()
    Mail.new('jen6')
end

return jen
