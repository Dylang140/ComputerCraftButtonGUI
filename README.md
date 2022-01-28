# ComputerCraftButtonGUI
A simple button GUI for CC Tweaked

I am working on a simple lua program to add buttons (and hopefully bar graphs and indicators) to a CC tweaked computer. This should also be compatible with ComputerCraft

This is made to work with Immersive Engineering redstone wires, accumulators, and other machines. It may work with other mods with slight modification

I will add more info if I get it to a somewhat complete state, right now its a bit of a mess and is not complete. I decided to use tables rather than objects, so to add objects
to the screen, you just add another nested table to the appropriate table at the top of the file, and update the count (if you add a button, change the numButtons var)

The program automatically prints each button, checks if it was clicked, executes the button (toggles the 'control' var you set for each), and refreshes the screen

The program also saves all of the states of the buttons and outputs to a floppy of a drive connected to the computer. This means you can restart the computer,and all the 
redstone outputs that were onbefore will come back, and all the buttons will display themselves as the correct color (i.e not inverted, like button = red but output = on)

When I finish it up, I will remove all of the old commented out code and update the read me
