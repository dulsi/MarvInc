--[[
#####################################
Marvellous Inc.
Copyright (C) 2017  MarvellousSoft & USPGameDev
See full license in file LICENSE.txt
(https://github.com/MarvellousSoft/MarvInc/blob/dev/LICENSE.txt)
#####################################
]]--

local Mail = require 'classes.tabs.email'

return {
    title = "THEY USE PEOPLE",
    text = [[
DUDE I WAS RIGHT ALL ALONG THIS SHIT IS SO MESSED UP I KNEW I SHOULD HAV TRUSTED MY INSTINCTS. MY BROSTINCS. OR MAYBE INSBROS? WTF WHY ARE WE TALKING ABOUT THIS THERE SO MANY THINGS MORE IMPORTANT RIGHT NOW BRO, FOCUS MAN.

THE {red}FUCKING ROBOTS{end} DUDE. THEY ARE USING {red}PEOPLE{end} AS {red}FUCKING ROBOTS{end} MAN!! THIS SHIT AINT FUNNY SHIT. ITS SERIOUS SHIT MAN. ITS FUCKING CRAZY MOVIE SHIT. AND IM LIK FUCKIN KEANU REEVES OR SUMTHING. JESUS B. CHRIST MAN THEY WERE DOING THIS FUCKED UP SHIT RIGHT UNDER OUR NOSE THIS ENTIRE TIME. BUT WHAT THEY DIDN'T EXPECT WAS DIEGO FUCKING VEGA, BECAUSE I SMELLED THE {purple}STINK{end} FROM THE DISTANCE BRO. AND NOW THEY GOT ME ON {orange}FIRE{end} BABY. WE HAVE GOT TO DO SUMTHING BRO. THIS IS LEGIT SERIOUS. WE CANT LET THEM GET AWAY WITH STUFF LIKE THIS. WE GOTTA GO TERMINATOR 2 ON THERE ASSES.

LISTEN UP BRO, THEY PROLLY KNOW I KNOW THIS. BUT I KNOW YOU GOT MY BACK, SO NOW I GOTTA KNOW IF YOU THINK THEY KNOW YOU KNOW SOMETHING OR MAYBE YOU SOMETHING WE CAN DO?? BECAUSE LIKE IM REALLY FUCKING PUMPED BUT ALSO KINDA LOST. SHOULD WE LEAK THIS TO THE PRESS? MAYBE I SHOULD BLOG THIS ON MY DAILY BLOG?? FUCK MAN DO YOU THINK THEY WIL COME AFTR ME?? AM I COMPROMISED IN THIS SHIT? {blue}HOLY FUCK DUDE WHAT WOULD KEANU REEVS DO?!!!{end}

JESUS MAN I CAN HEAR STEPS THEY MUST BE LISTENING ME THE WALLS HAVE EYES AND EARS WTF IS HAPPENING THIS SHIT IS SO MACABRE FUCK MAN JUST READ THIS ASAP AND COME MEET ME AT MY DESK JESUS TRUST NOONE WE GOTTA HAVE A KEYWORD FUCK YEAH A KEYWORD THAT IS THE SHIT LIKE SPIES, SO WE KNO IF YOU ARE YOU AND I AM ME FUCK AM I ME AM I A ROBOT ALREADY??!!! WTF MAN IM GOING NUTS HERE COME HERE ALREADY WTF SHIT THE KEYOWORD IS FUCKING {purple}SHARK BALLS{end} START EVERY SENTENCE WITH {purple}SHRK BALLS{end} SO I KNOW YOU IS YOU OKAY??? DONT LET ME DOWN BRO {purple}SHARC BALZ{end} DONT FORGET DELETE THIS EMAIL RIGHT NOW THEY CANT KNWO WE KNOW THAT THEY FUCKING USE PEOPLE AS ROBOT WTF ARE WE IN NAIGH SHAMALAYMAN MOVIE RIGHT NOW HOLY SHIT MY BALLS ARE SO FUCKING TINGLY RIGHT NAW.
]],
    author = "Diego Lorenzo Vega (vega@rtd.marv.com)",
    open_func = function()
        MAIN_TIMER:after(5, function()
            require('classes.opened_email').close()
            Mail.deleteAuthor("Diego Lorenzo Vega (vega@rtd.marv.com)")
            FX.full_static()
            LoreManager.puzzle_done.diego_died = true
            LoreManager.check_all()
        end)
    end
}
