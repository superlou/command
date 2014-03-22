Command
=======
A high-level war games simulator based on real-world data that needs a catchier name.

Development
-----------
To test the current (depressing) state of the game, start `game_server.rb` and `web_server.rb` files in seperate terminals.

Time Acceleration
-----------------
The original idea was that one hour of game play is one year of simulation, but that would make 1 second 2.5 hours, allowing large troop movements across the country in less than a minute.  The new plan is that it should take 1 minute to drive from Philadelphia to New York, which is about 300 times faster than real-time.  This makes each hour of gameplay 12.5 days.