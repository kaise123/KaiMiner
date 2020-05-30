--[[
This version: 4.11
30/05/2020

Changelog:
- 4.00 - Total reformat/redone code.
- 4.01 - Working release - Fix spelling mistakes, typos, etc
- 4.10 - Add in blacklisting option to mine all blocks NOT on a list, rather than whitelist (ONLY mine blocks that are on a list)
- 4.11 - Drop items before return trip. Thought I had already implemented this but apparently not.

To-Do List:
- Use advanced turtle monitor to constantly show certain stats on screen
- Persistent logging (Save stats to disk)
- Check the CORRECT item is in each slot before starting, rather than just checking that any item is there.

Known Bugs:
- ?

--]] 

-- Variables:

local stripDistance = 0                         -- How Far Did User Pick
local torchSpace = 0                            -- When to Place Torch
local slotItemTorch = turtle.getItemCount(1)    -- How many items are in slot 1 (torch)
local slotTorchChest = turtle.getItemCount(2)   -- Is there a chest in slot 2 (Torches EnderChest)
local slotDumpChest = turtle.getItemCount(3)    -- How many items are in slot 3 (chest)
local slotItemFuel = turtle.getItemCount(4)     -- How many items are in slot 4 (Fuel)
local slotItemCobble = turtle.getItemCount(5)   -- How much cobble is in slot 5 (Filling Slot)
local mineSpacing = 3                           -- Number of blocks from one strip to the next
local mineCount = 0                             -- If Multi Mines Are ON then This will keep Count
local Fuel = 0                                  -- if 2 then it is unlimited no fuel needed
local NeedFuel = 0                              -- If Fuel Need Then 1 if not Then 0
local Error = 0                                 -- 0 = No Error and 1 = Error
local direction = 0                             -- 0 = Left and 1 = Right
local oresMined = 0                             -- Pre-Define that no ores have been found yet.
local useBlacklist = 0                             -- 0 = Whitelist and 1 = Blacklist mode.

-- Whitelist of blocks to mine out of walls/ceiling/floor when in whitelist mode:
local mineWhitelist = {
	["minecraft:coal_ore"] = true,
	["minecraft:diamond_ore"] = true,
	["minecraft:gold_ore"] = true,
	["minecraft:iron_ore"] = true,
	["minecraft:lapis_ore"] = true,
	["thermalfoundation:ore"] = true,
}

-- Blacklist of blocks to NOT mine out of walls/ceiling/floor when in blacklist mode:
local mineBlacklist = {
	["minecraft:stone"] = true,
    ["minecraft:dirt"] = true,
    ["minecraft:cobblestone"] = true,
}

local function reFuel()
    repeat
        if turtle.getFuelLevel() == "unlimited" then 
            term.setTextColor(colors.purple)
            print("INFO: Fuel not needed (Unlimited)")
            term.setTextColor(colors.white)
			Needfuel = 0
        elseif turtle.getFuelLevel() < 200 then
            CurrentFuelLevel = turtle.getFuelLevel()
            term.setTextColor(colors.purple)
            print("INFO: Refuelling. Fuel level was:", CurrentFuelLevel)
            term.setTextColor(colors.white)
            turtle.select(4)
            CoalRemaining = turtle.getItemCount(4) -- Count remaining Coal in slot 4
            CoalToUse = CoalRemaining - 1 -- Take one away - We want to leave one coal in slot 4 so future Coal we mine is collected here first.
			turtle.refuel(CoalToUse) -- Refuel with all the coal in the slot minus one.
			CurrentFuelLevel = turtle.getFuelLevel()
            term.setTextColor(colors.purple)
            print("INFO: Refueled. Level is now:", CurrentFuelLevel)
            term.setTextColor(colors.white)
			Needfuel = 1
		elseif NeedFuel == 1 then
			Needfuel = 0
		end
    until NeedFuel == 0
end

-- Check the appropriate item is in each slot, refuel, etc
local function checkSlots()
    if slotItemTorch == 0 then
        term.setTextColor(colors.red)
        print("Slot 1: Missing torches.")
        Error = 1
    else
        term.setTextColor(colors.lime)
        print("Slot 1: Torches found!")
    end
    if slotTorchChest == 0 then
        term.setTextColor(colors.red)
        print("Slot 2: Missing torches EnderChest")
        Error = 1
    else
        term.setTextColor(colors.lime)
        print("Slot 2: Torches EnderChest found!")
    end
    if slotDumpChest == 0 then
        term.setTextColor(colors.red)
        print("Slot 3: Missing item dump EnderChest")
        Error = 1
    else
        term.setTextColor(colors.lime)
        print("Slot 3: Item dump EnderChest found!")
    end
    if slotItemFuel == 0 then
        term.setTextColor(colors.red)
        print("Slot 4: Missing Coal")
        Error = 1
    else
        term.setTextColor(colors.lime)
        print("Slot 4: Coal found!")
    end
    if slotItemCobble == 0 then
        term.setTextColor(colors.red)
        print("Slot 5: missing Cobblestone")
        Error = 1
    else
        term.setTextColor(colors.lime)
        print("Slot 5: Cobblestone found!")
    end
    term.setTextColor(colors.white) -- Reset terminal colour to white.
end

-- Re-Check slots when called to update stored values of items in each slot.
local function reCheckSlots()
    slotItemTorch = turtle.getItemCount(1)    -- How many items are in slot 1 (torch)
    slotTorchChest = turtle.getItemCount(2)   -- Is there a chest in slot 2 (Torches EnderChest)
    slotDumpChest = turtle.getItemCount(3)    -- How many items are in slot 3 (chest)
    slotItemFuel = turtle.getItemCount(4)     -- How many items are in slot 4 (Fuel)
    slotItemCobble = turtle.getItemCount(5)   -- How much cobble is in slot 5 (Filling Slot)
    Error = 0 -- Reset 'Error' state to 0 - so that the checkSlots function can re-run and set error if needed.
end

-- Fill infront of turtle with item in slot 5:
local function fill()
	turtle.select(5)
	RemainingCobble = turtle.getItemCount(5)
	if RemainingCobble >= 2 then
		turtle.place()
		turtle.select(4)
    else
        term.setTextColor(colors.orange)
        print("WARN: Out of Cobblestone")
        term.setTextColor(colors.white)
	end
end

-- Fill above turtle with item in slot 5:
local function fillUp()
	turtle.select(5)
	RemainingCobble = turtle.getItemCount(5)
	if RemainingCobble >= 2 then
		turtle.placeUp()
		turtle.select(4)
	else
        term.setTextColor(colors.orange)
        print("WARN: Out of Cobblestone")
        term.setTextColor(colors.white)
	end
end

-- Fill below turtle with item in slot 5:
local function fillDown()
	turtle.select(5)
	RemainingCobble = turtle.getItemCount(5)
	if RemainingCobble >= 2 then
		turtle.placeDown()
		turtle.select(4)
	else
        term.setTextColor(colors.orange)
        print("WARN: Out of Cobblestone")
        term.setTextColor(colors.white)
	end
end

-- Ore Detection
-- Detects if facing an ore present in the mineWhitelist table.
local function detectOres()
    local blockPresent,blockInfo = turtle.inspect() -- Check the block we are facing. Store if there is a block (blockPresent) and the details of the block (blockInfo)
    if useBlacklist == 0 and blockPresent and mineWhitelist[blockInfo.name] then -- If not using the blacklisting function, there IS a block there, and it is on the whitelist table
        oresMined = oresMined + 1
        term.setTextColor(colors.purple)
        print("INFO: Found", oresMined, "ores so far")
        term.setTextColor(colors.white)
        turtle.select(4)
		turtle.dig()
		fill() -- Fill in the hole we just dug.
    elseif useBlacklist == 1 and blockPresent and mineBlacklist[blockInfo.name] then -- If we ARE using the blacklisting function, there IS a block there, and it IS on the blacklist
        -- Do nothing - We don't want blacklisted blocks.
        fill() -- We will place cobble anyway - in case there is lava/water to fill in.
    elseif useBlacklist == 1 and blockPresent then -- If we ARE using the blacklisting function, there IS a block there, and it is NOT on the blacklist
        oresMined = oresMined + 1
        term.setTextColor(colors.purple)
        print("INFO: Found", oresMined, "ores so far")
        term.setTextColor(colors.white)
        turtle.select(4)
		turtle.dig()
		fill() -- Fill in the hole we just dug.
    else
        -- No block is present - Fill the hole with Cobblestone.
        fill()
    end
end

local function detectOresDown()
    local blockPresent,blockInfo = turtle.inspectDown() -- Check the block we are facing. Store if there is a block (blockPresent) and the details of the block (blockInfo)
    if useBlacklist == 0 and blockPresent and mineWhitelist[blockInfo.name] then -- If not using the blacklisting function, there IS a block there, and it is on the whitelist table
        oresMined = oresMined + 1
        term.setTextColor(colors.purple)
        print("INFO: Found", oresMined, "ores so far")
        term.setTextColor(colors.white)
        turtle.select(4)
		turtle.digDown()
		fillDown() -- Fill in the hole we just dug.
    elseif useBlacklist == 1 and blockPresent and mineBlacklist[blockInfo.name] then -- If we ARE using the blacklisting function, there IS a block there, and it IS on the blacklist
        -- Do nothing - We don't want blacklisted blocks.
        fillDown() -- We will place cobble anyway - in case there is lava/water to fill in.
    elseif useBlacklist == 1 and blockPresent then -- If we ARE using the blacklisting function, there IS a block there, and it is NOT on the blacklist
        oresMined = oresMined + 1
        term.setTextColor(colors.purple)
        print("INFO: Found", oresMined, "ores so far")
        term.setTextColor(colors.white)
        turtle.select(4)
		turtle.digDown()
		fillDown() -- Fill in the hole we just dug.
    else
        -- No block is present - Fill the hole with Cobblestone.
        fillDown()
    end
end

local function detectOresUp()
    local blockPresent,blockInfo = turtle.inspectUp() -- Check the block we are facing. Store if there is a block (blockPresent) and the details of the block (blockInfo)
    if useBlacklist == 0 and blockPresent and mineWhitelist[blockInfo.name] then -- If not using the blacklisting function, there IS a block there, and it is on the whitelist table
        oresMined = oresMined + 1
        term.setTextColor(colors.purple)
        print("INFO: Found", oresMined, "ores so far")
        term.setTextColor(colors.white)
        turtle.select(4)
		turtle.digUp()
		fillUp() -- Fill in the hole we just dug.
    elseif useBlacklist == 1 and blockPresent and mineBlacklist[blockInfo.name] then -- If we ARE using the blacklisting function, there IS a block there, and it IS on the blacklist
        -- Do nothing - We don't want blacklisted blocks.
        fillUp() -- We will place cobble anyway - in case there is lava/water to fill in.
    elseif useBlacklist == 1 and blockPresent then -- If we ARE using the blacklisting function, there IS a block there, and it is NOT on the blacklist
        oresMined = oresMined + 1
        term.setTextColor(colors.purple)
        print("INFO: Found", oresMined, "ores so far")
        term.setTextColor(colors.white)
        turtle.select(4)
		turtle.digUp()
		fillUp() -- Fill in the hole we just dug.
    else
        -- No block is present - Fill the hole with Cobblestone.
        fillUp()
    end
end

-- Physically check above, below, left and right for blocks to mine.
local function checkSides()
    detectOresDown()
    turtle.turnLeft()
    detectOres()
    turtle.turnRight()
    turtle.turnRight()
    detectOres()
    turtle.turnLeft()
    turtle.select(4)
end

-- Physically check above, left and right for blocks to mine. Used when on return strip through top of mine.
local function checkSidesBack()
    detectOresUp()
    turtle.turnLeft()
    detectOres()
    turtle.turnRight()
    turtle.turnRight()
    detectOres()
    turtle.turnLeft()
    turtle.select(4)
end

local function dropAndCollect()
    if slotDumpChest > 0 then -- If we still have a dump chest to fill
        turtle.select(3)
        turtle.digDown()
        term.setTextColor(colors.purple)
        print("INFO: Inventory full. Dropping into chest.")
        term.setTextColor(colors.white)
        turtle.placeDown()
        for slot = 6, 16 do
            turtle.select(slot)
            ItemDetails = turtle.getItemDetail()
                if ItemDetails.name == "minecraft:cobblestone" then 
                    turtle.drop() -- If the slot contains cobble, drop it on the ground.
                else
                    turtle.dropDown() -- Drop all non-cobblestone items into the chest below me.
                    sleep(1.5)
            end
        end
        turtle.select(3)  -- Reselect the empty slot to put the EnderChest back into.
        turtle.digDown()  -- Dig the EnderChest back up.
        sleep(2)
        term.setTextColor(colors.purple)
        print("INFO: Collecting torches")
        term.setTextColor(colors.white)
        torchesNeeded = 0 -- Reset torches needed to 0
        turtle.select(2) -- Select slot 2, this should contain the crate or EnderChest full of only torches.
        turtle.placeDown()
        turtle.select(1) -- Select slot for torches...
        torchesNeeded = 64 - turtle.getItemCount(1) -- Count how many torches are left and subtract from 64, so we know how many to collect.
        turtle.suckDown(torchesNeeded) -- Pull only enough torches to refill slot 1.
        term.setTextColor(colors.purple)
        print("INFO: Finished. Collected", torchesNeeded, "torches.")
        term.setTextColor(colors.white)
        turtle.select(2) -- Select empty slot for Torch storage EnderChest
        turtle.digDown()  -- And pick the Torch Storage EnderChest back up again.
        turtle.select(5)
        turtle.placeDown()
        turtle.select(4)
    else
        error("Turtle run out of Chests. Quitting")
    end
end

-- Main program mining forward through each strip
local function mineForward()
    repeat
        if turtle.detect() then -- If there is a block infront
			turtle.dig()        -- Then mine it.
		end
		if turtle.forward() then -- If we moved forward
			turtleForward = turtleForward - 1 -- Then take one away from the distance left to travel down the shaft
            torchSpace = torchSpace + 1 -- and add one to the distance since we last placed a torch.
		end
        if turtle.detectUp() then -- If there is a block above
			turtle.digUp()        -- Then mine it.
        end
        checkSides()
		if torchSpace == 13 then -- Place a torch behind us every ~14 blocks.
			if slotItemTorch > 1 then
				turtle.turnLeft()
				turtle.turnLeft()
				turtle.select(1)
				turtle.place()
				turtle.turnLeft()
				turtle.turnLeft()
				torchSpace = torchSpace - 13
				turtle.select(4)
			else
				error("Ran out of torches. Quitting")
			end
        end
        if turtle.getItemCount(16) > 0 then -- If slot 16 contains an item, the turtle is full. Drop slots 6 to 16 into chest.
            dropAndCollect()
        end
        reFuel()
	until turtleForward == 0
end

-- Turn around and go up 1 level in preperation for returning down the strip to the original hallway.
local function prepareForReturn()
    dropAndCollect() -- Drop items into chest - To keep inventory room for items found on return trip.
    checkSides()
    turtle.up()
    checkSidesBack()
    turtle.turnLeft()
    turtle.turnLeft()
end

-- Return down strip.
local function returnBack()
	repeat
		if turtle.forward() then -- If we moved forward
			turtleBack = turtleBack - 1
            checkSidesBack()
	    end
		if turtle.detect() then -- Sometimes sand and gravel can happen and this will fix it
			if turtleBack ~= 0 then
                turtle.dig()
			end
		end
	until turtleBack == 0
end

-- Dig along hall and prepare to start next strip - Or finish if the variable mineCount is 0.
local function nextMine()
	if direction == 1 then
		turtle.turnRight()
		turtle.dig()
		turtle.select(1)
		turtle.place()
		turtle.select(4)
		turtle.turnLeft()
		turtle.turnLeft()
	else
		turtle.turnLeft()
		turtle.dig()
		turtle.select(1)
		turtle.place()
		turtle.select(4)
		turtle.turnRight()
		turtle.turnRight()
	end
	repeat
		if turtle.detect() then
			turtle.dig()
		end
		if turtle.forward() then
			fillUp()
			turtle.turnLeft()
			fill()
			turtle.turnRight()
			turtle.turnRight()
			fill()
			turtle.turnLeft()
			turtle.digDown()
			turtle.down()
			fillDown()
			turtle.turnLeft()
			fill()
			turtle.turnRight()
			turtle.turnRight()
			fill()
			turtle.turnLeft()
			turtle.up()
			mineSpacing = mineSpacing - 1
		end
		if turtle.detectDown() then
			turtle.digDown()
		end
	until mineSpacing == 0
	if direction == 1 then
		turtle.turnLeft()
        turtle.down()
        term.setTextColor(colors.purple)
        print("INFO: Remaining Strips: ", mineCount)
        term.setTextColor(colors.white)
	else
		turtle.turnRight()
		turtle.down()
        term.setTextColor(colors.purple)
        print("INFO: Remaining Strips:", mineCount)
        term.setTextColor(colors.white)
	end
	if mineCount == 0 then
        term.setTextColor(colors.lime)
        print("INFO: Mining complete!")
        term.setTextColor(colors.white)
	else
		mineCount = mineCount - 1
	end
end

-- Reset counter variables to 0 in order to start next strip
local function resetCounters()
	turtleForward = distance
	turtleBack = distance
	mineSpacing = 3
	torchSpace = 0
end

function begin()
    repeat
        reFuel()
        mineForward()
        prepareForReturn()
        returnBack()
        nextMine()
        resetCounters()
    until mineCount == 0
    if mineCount == 0 then
        term.setTextColor(colors.blue)
        print("INFO: Mining complete!")
        term.setTextColor(colors.white)
    end
end

-- Run each step in the program:
print("Begin Program.")
print("= = =")
term.setTextColor(colors.lightBlue)
print("Please fill the inventory as follows:")
print("Slot 1: ~10+ Torches")
print("Slot 2: Torches Enderchest")
print("Slot 3: Item output EnderChest")
print("Slot 4: ~64 Coal")
print("Slot 5: ~64 Cobblestone")
term.setTextColor(colors.white)
print("= = =")
term.setTextColor(colors.lightGray)
print("How long should each shaft be?")
input = io.read()
distance = tonumber(input)
turtleForward = distance
turtleBack = distance
print("Do you want to mine left or right?")
print("0 = Left and 1 = Right")
input2 = io.read()
direction = tonumber(input2)
print("How many shafts to dig?")
input3 = io.read()
mineCount = tonumber(input3)
print("Blacklist or Whitelist? 0 = WL, 1 = BL")
input4 = io.read()
useBlacklist = tonumber(input4)
term.setTextColor(colors.purple)
print("INFO: Digging", input3, "shafts")
print("Each will be", input, "long")
term.setTextColor(colors.white)
checkSlots()
if Error == 1 then 
	repeat
		sleep(10)
		reCheckSlots()
        checkSlots()
        print(" ")
	until Error == 0
end
begin()