Cirrus.ogg belongs to A-Zu-Ra, taken from the Dropbox Assets folder for the Game Dev Club.
Stolen.ogg belongs to Bibio, stolen from YouTube, only a temporary track.


#Map API

---
##Global
This is a special object that can be accessed with the name "global". You cannot spawn it and you cannot access it's properties, but you can call methods on it.
#####Methods
`global:swapCollision(  )`  
`global:changeMap( string )`  
`global:playMusic( name, volume) )`  
`global:playSound( name[, volume] )`

##Player
#####Methods
`activator:multiplyVelocity( x, y )`  
`activator:addVelocity( x, y )`  
`activator:setVelocity( x, y )`  
`activator:applyImpulse( x, y )`  
`activator:setFriction( number )` 
`activator:teleportTo( object )`  

##Self
You can use the `self` keyword.

##Everything Else
#####Events:
`onSpawn`
#####Methods
`setVelocity( x, y )`  
`setVisible( boolean )`  
`setFrozen( boolean )`  
`teleportTo( object )`  
`destroy(  )`

##PhysBox
A box that's used for testing and stuff.
Everything is secretly derived from it for no good reason.
#####Attributes:
`collisiongroup` : `shared / blue / green`
#####Events:
`onSpawn`
#####Methods
`setVelocity( x, y )`  
`setVisible( boolean )`
`setFrozen( boolean )`  
`teleportTo( object )`  
`teleportTo( object )`  
`destroy(  )`

##Toggle
Toggles a button on and off.
#####Events:
`onToggle`
`onPress`
`onRelease`

##Button
Activates only when player is touching button
#####Events:
`onPress`
`onRelease`

##Trigger
A rectangle that activates then the player enters.
#####Attributes:
`filter` : `PLAYER, PHYSBOX, TILE`
#####Events:
`onTrigger` : will trigger only when the object starts touching it
`onBothPlayers`
`onTriggerEnd`
`onBothPlayersEnd`
`onTouching` : will trigger every second an object is touching it.

##Camera
Moves the camera to a position on the map.
#####Methods
`setActivated( boolean )`

##Timer
#####Attributes:
`time` : `the time it takes for the timer to end`
#####Methods
`start(  )`
#####Events
`onEnd`

##Text
Draws a text.
#####Attributes:
`string` : `the text you want to put here`
#####Methods
`type( )` types out the text you put in
`setString( string )` useful for dialogue

##Trampoline
#####Attributes:
`power` : `how much power it should push the player by`  
`goal` : `name of a goal. it could be anything`  

##Prop
#####Attributes:
`sprite` : `sprite relative to the sprite folder`   
`spritewidth` : `sprite width`  
`spriteheight` : `sprite height`  
#####Methods
`loopAnimation( y, xfrom, xto, speed )`  
`playAnimation( y, xfrom, xto, duration )`

##Slider
It constraints an object to move only in one axis.
It disables angle movement though.
#####Attributes:
`angle` : `angle of the axis the object can move in`
`object` : `name of the object to constrain`

##Weld
Glues two objects together
Make sure you set the property "phystype" to "dynamic"
before using this, or else the object might not move!
#####Attributes:
`object1` : `name of the object to constrain`
`object2` : `name of the second object to constrain`