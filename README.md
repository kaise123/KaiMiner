# KaiMiner
This is a project to create simple but efficient mining program.

The code was originally based upon @johnneijzen's 'John Turtle Programs' strip miner, but I have basically completely re-written the code since then.

Notable features:

1.) Fast. Due to the turtle moving along the bottom of the strip, and then coming back along the top, the turtle is able to complete strips faster and with less fuel due to less movement.
  The downside of this feature is that torches may be knocked off of the floor if Lava or Water is encoutered.
  
2.) Fills Walls/Ceiling/Floor - Will fill in holes, lava and water effectively (Provided there is enough remaining Cobblestone in slot 5, leaving clean mines.

3.) Orefinding - Includes a basic 'Orefinder' function to mine blocks of interest out of the walls, floor and ceiling of each strip. This can be configured to work one of the following ways:
  - Blacklist will mine EVERYTHING from walls/ceiling/floor except items explicitly blacklisted (EG Stone).
  - Whitelist will mine ONLY the blocks in the whitelist from walls/ceiling/floor.
  
  The blacklist and whitelist are set in code - but can be modified easily. There is a simple table for each in the first 50 lines of code where additional blocks can easily be added.
  
4.) Enderchests - This program is designed to use 2 Enderchests from the Ender Storage mod (Is in most FTB packs). The first EnderChest will be used to output all mined items when the inventory is full - the turtle will place the chest down, empty it's inventory into the chest, then pick it back up again - negating the need to return 'home' when the inventory is full. You can then extract items from a matching EnderChest at another location however you wish.

The second EnderChest is designed to be filled with torches - so the turtle can continue doing many, many strips without running out of torches.

Either of these chests could also be replaced with storage containers that allow being picked up without losing their inventory contents.

The turtle will begin by informing you of the inventory layout and wait for you to place the items correctly. It will also query the length, quantity and direction of the strips it will mine.

This is the first time I have used Lua - but I have tried to keep the code relatively well formatted and leave detailed comments so others can easily understand how it works.
