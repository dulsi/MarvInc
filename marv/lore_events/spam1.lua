--Marvellous Inc.
--Copyright (C) 2017  MarvellousSoft
--See full license in file LICENSE.txt

local Mail = require "classes.tabs.email"

local spam = {}

spam.require_puzzles = {'liv2'}
spam.wait = 30

function spam.run()
    Mail.new('spam1')
end

return spam
