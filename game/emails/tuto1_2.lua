local Info = require 'classes.tabs.info'

return {
    title = "First Puzzle",
    text = [[
There are many commands to control the test subjects. For now, you just need to know one: walk.

You can provide a cardinal direction (such as north or west) or a regular direction (such as up or left). If you don't, your robot will walk to the direction it is facing. This command will make the test subject walk until it encounters an obstacle.

Examples:
    - walk
    - walk east
    - walk down

We are assured you are an expert, so no more instructions are needed. Complete the following puzzle quickly.

Use the two buttons to the right of the play button to move your bot faster.

Reply this email to start the puzzle.

Best of Luck, and carry on.
]],
    author = "Automated Introduction System",
    puzzle_id = 'tuto1',
    open_func =
        function()
            Info.addCommand("walk")
            Info.addCommand("walk <direction>")
        end
}