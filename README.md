# BattleshipGame_project

## Project Description:

The "Vaporase" program generates random positions for ships in an N x M matrix and displays an empty matrix to the user. After each click on an empty cell within the matrix, it will color the cell blue if it was clicked on a water area or red if it "hit" a ship. After each step, the program displays the number of cells with undiscovered ship parts remaining, the number of successful hits, and the number of misses.

## Project Structure:

1. **Declarations and Initializations:**
   - Define and initialize variables to store necessary game data, such as ship coordinates, their status, and the number of undiscovered ships, hits, and sunk ships.

2. **External Functions:**
   - Import necessary functions from external libraries for basic operations, such as exit, malloc, printf, scanf, srand, rand, time, and BeginDrawing.

3. **Macros:**
   - Define macros for various useful operations, such as drawing lines, squares, and coloring them, displaying text, and other game-related actions.

4. **Draw Function:**
   - This function is called to draw the current state of the game, either at initialization or following an event (click or timer expiration). It also performs checks to determine the click position and interaction with the ships.

5. **Random Macro:**
   - Generates random ship positions on the grid.

6. **Start Function:**
   - This is the starting point of the program, where ship positions are generated, and the drawing window is initialized.

## Game Description:

- The player's objective is to discover ships hidden on a grid.
- Ships are represented by colored squares on the grid.
- Each click on an uncolored space of the grid aims to discover a possible ship.
- If the click intersects with a ship's position, it is sunk, and the count of sunk ships increases.
- The goal of the game is to discover all the ships.
- The game ends when all ships are discovered.

## Purpose:

This project is a simple implementation of a strategy and attention game, utilizing assembly language programming concepts to create an interactive user experience.
