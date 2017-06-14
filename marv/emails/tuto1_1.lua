local tuto1 = require 'lore_events.tuto1'

return {
    title = "Welcome Employee #" .. EMPLOYEE_NUMBER,
    text = [[
Greetings and Salutations!

We at %blue% MARVELLOUS INC. %end% are happy to welcome one more member in our ever expanding AI company. We are all about %red% Big Data %end% , %purple% Internet of Things %end% , %blue% Deep Data Mining Learning (DDML) %end% , %green% real-time networks for cutting-edge technology %end% and %orange% benchmarking cloud apps (built for scalability of course) %end% . We hope you can meet our standards, %cyan% end-to-end %end% .

As you know, your assignment will be to test our newly developed Artificial Inteligence Humanoids, or %red% robots %end% . You will have to program their behaviour with simple commands so they can fulfill complex tasks. On the right part of screen you have direct access to a camera filming a room. Test subjects (the %red% "robots" %end% of course) will be placed inside the room, but you can only control them via your %blue% <code> %end% .

This Automated System will guide you if you feel disoriented.

Most importantly, have fun and carry on :)
]],
    author = "Automated Introduction System",
    --puzzle_id = 'tuto8', -- TODO: REMOVE IN RELEASE
    open_func = tuto1.after_intro_email
}