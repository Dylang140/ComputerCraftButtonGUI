# ComputerCraftButtonGUI
A simple button GUI for CC Tweaked

New Image:
![image](https://user-images.githubusercontent.com/98580719/154836004-8e7ccf7b-fa3c-4c2b-8bcf-563152720d99.png)

Old Image:
![image](https://user-images.githubusercontent.com/98580719/151685402-05fbaa1d-e21a-4c0b-9374-2dec577ff20d.png)

Features:

+ Buttons and Bar Graphs that are easy to add and move
+ Graphs automatically update based on given input (IE Accumulator, maybe others later)
+ Graphs automatically change colors based on thresholds (red < 10%, yellow < 25%, blue 25 - 100 %)
+ Buttons change colors based on output state
+ Alarms can be configured to go off when a certain value is over or under a specified threshold, these alarms display in the corner of the monitor and sound an audible alarm
+ Lines that can be used for creating live power maps, conencting indicators and graphs (a bit tedious to conigure, but looks really cool and worth the time to set up)
+ All current states are saved, so when relogging or restarting the in-game computer, the buttons and outputs reload to how they were last
+ Refreshes display, updates all GUI components, and saves data every second (can be configured)
+ Display does not blink (mostly) when it refreshes (All calculations are done and saved prior to the screen being cleared and redrawn)
+ Only one file to dowload (name file as "startup.lua" in the root directory to have it run automatically)

I am working on a simple lua program to add buttons (and hopefully bar graphs and indicators) to a CC tweaked computer. This should also be compatible with ComputerCraft maybe...

This is made to work with Immersive Engineering redstone wires, accumulators, and other machines. It may work with other mods with slight modification

I will add more info if I get it to a somewhat complete state, right now its a bit of a mess and is not complete. I decided to use tables rather than objects, so to add objects
to the screen, you just add another nested table to the appropriate table at the top of the file, and update the count (if you add a button, change the numButtons var)

The program automatically prints each button, checks if it was clicked, executes the button (toggles the 'control' var you set for each), and refreshes the screen

The program also saves all of the states of the buttons and outputs to a floppy of a drive connected to the computer. This means you can restart the computer,and all the 
redstone outputs that were onbefore will come back, and all the buttons will display themselves as the correct color (i.e not inverted, like button = red but output = on)

When I finish it up, I will remove all of the old commented out code and update the read me

Known Bugs:
-Bundled Output #1 (white) turns on when the program starts
