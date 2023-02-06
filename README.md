# 3DSenpai

This documentation describes how the 3DSenpai engine works.

3DSenpai is a 2D (despite the name) engine that manages the logic and the GUI of Nintendo 3DS
homebrews that use [Lua Player Plus 3DS engine](https://github.com/Rinnegatamante/lpp-3ds) by [Rinnegatamante](https://rinnegatamante.it/).

Despite being tought for creating games, it is totally possible to use the engine to create
graphical applications (e.g. managing navigation, menus, etc).

## Attached Example

The attached example (index.lua) contains a demo application that shows how to use the engine.
Feel free to use it as a reference and a starting point for your applications.

## Global objects

To better manage the workflow of the game, some global objects are created at runtime and
are accessed during the game loop.

### Program

This object contains informations about the game such as author, version, title and so on.

### emptyElement

This object is a prototype of an empty element that is used to initialize an element and standardize its properties.

### Scene

This object contains the character object, the currentScene property, the imagesToDraw table
and the environment object.

#### Scene.environment

This is the most important object of the scene. It represents every pixel as a tile and is used to define, determine and manipulate the position and behavior of the elements in the scene.

It contains a size property with the width and height of the screen and the matrix table which is initialized by the setScene function as a 2D array representing every tile content. It is
accessed through:

    Scene.environment.matrix[x][y]

## initalLoad

This method is called just after all the variables have been initialized.
Normally, you would use it to set the first scene through setScene method and load
everything you need to start the game.

### setScene

This method accepts a scene method that is called to obtain the desired scene properties.
Additionally, it resets the Scene.environment.matrix property to the default values.
These properties are then assigned to the Scene.currentScene and Scene.imagesToDraw objects.

### Scene methods

These methods are to be created by the developer.
For setScene to be effective, the scene method should return a table containing two booleans
that define whether or not the background and the main character should be drawn, and a table containing every element that should be drawn.

## The main loop

The game engine revolves around a mainLoop function that keep calling
keyEvents and mainGUI functions.

## keyEvents

This function keep the inputs monitored for key events and react consequently.

## mainGUI

This function loads the Scene object and, if specified, draws both the background and
the main character.

Then, if any, it parses the Scene.imagesToDraw table and draws the elements images that
are specified in it.

## Elements methods

These methods are a set of functions that help the developer create, manage and inspect elements in the current scene.

### isElement

This function returns wheter or not an element covers the specified coordinates (x and y).
A boolean is returned.

### elementPosition

If an element is in the elementsTable table, it returns the element object. Else, it returns nil.

### placeElement

This function is used to place an element in the scene.
It checks whether the element is already placed and if the tiles that should be covered are free
or not.
It returns a boolean and a string containing the result of the operation.

### removeElement

This function removes an element from the scene by checking its existence and position through the elementsTable and the the scene environment.Matrix.

### checkTileCollision

Given a set of coordinates (x and y), this function checks whether there is an element that covers the specified coordinates and if the element has the Collision property set to true.
