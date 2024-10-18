breed [scouters scouter]
breed [units unit]

globals [wind-direction alerted-fires]

units-own [water-level]

patches-own [
  burning-duration
]

to setup
  clear-all
  set-default-shape scouters "person"
  set-default-shape units "person"
  setup-base
  setup-trees
  setup-scouters
  setup-units
  setup-wind
  setup-initial-fire
  set alerted-fires []
  reset-ticks
end

to setup-base
  ; Set the base at patch (0,0)
  ask patch 0 0 [ set pcolor blue ]
end

to setup-trees
  ; Create trees (green patches) in a circular area around the base
  ask patches [
    if (distance patch 0 0 > 5 and distance patch 0 0 < 25) [
      set pcolor green
      set burning-duration 0
    ]
  ]
end

to setup-scouters
  ; Create scouters and place them randomly
  create-scouters scouters-count [
    set color white
    setxy random-xcor random-ycor
  ]
end

to setup-units
  ; Create fire-fighting units and place them randomly
  create-units units-count [
    set color red
    setxy random-xcor random-ycor
    set size 1.5
    set water-level water-capacity
  ]
end

to setup-initial-fire
  ; Start with a random initial fire
  ask one-of patches with [pcolor = green] [
    set pcolor red
    set burning-duration 1
  ]
end

to setup-wind
  ; Randomly set the wind direction
  set wind-direction one-of [0 90 180 270]
end

to go
  move-scouters
  move-units
  spread-fire
  extinguish-fire
  tick
end

to move-scouters
  ask scouters [
    fd 1
    ; If within 5 units of a fire, record its location
    if any? patches in-radius 5 with [pcolor = red or pcolor = orange] [
      let fire-coords (list pxcor pycor)
      if not member? fire-coords alerted-fires [
        set alerted-fires lput fire-coords alerted-fires
      ]
    ]
  ]
end

to move-units
  ask units [
    ifelse water-level = 0
    [ move-to-base ]
    [
      move-towards-fire
      avoid-collisions
    ]
  ]
end

to move-to-base
  ; Return to base to refill water
  face patch 0 0
  fd 1
  if patch-here = patch 0 0 [
    set water-level water-capacity
  ]
end

to move-towards-fire
  ifelse length alerted-fires > 0
  [
    ; Move towards the closest alerted fire
    let closest-fire-coords reduce [ [a b] ->
      ifelse-value (distance (patch (item 0 a) (item 1 a)) < distance (patch (item 0 b) (item 1 b))) [a] [b]
    ] alerted-fires
    let target-x item 0 closest-fire-coords
    let target-y item 1 closest-fire-coords
    face patch target-x target-y
    fd 1
    ; Remove the fire from the alerted list if reached
    if distance patch target-x target-y < 1 [
      set alerted-fires remove-item (position closest-fire-coords alerted-fires) alerted-fires
    ]
  ]
  [
    ; If no fires are alerted, move slowly
    fd 0.5
  ]
end

to avoid-collisions
  ; Avoid collisions with other units
  if any? other units in-radius 1.5 [
    rt 90 + random-float 90
    fd 1
  ]
end

to spread-fire
  ; Fire spreads from burning patches to neighboring patches
  ask patches with [pcolor = red] [
    set burning-duration burning-duration + 1
    if burning-duration > 5 [
      set pcolor orange
    ]
    spread-to-neighbors
  ]
end

to spread-to-neighbors
  ask neighbors with [pcolor = green] [
    ; Try to ignite neighbor patches based on wind direction
    if wind-direction = 0 and pycor > [pycor] of myself [try-ignite]
    if wind-direction = 90 and pxcor > [pxcor] of myself [try-ignite]
    if wind-direction = 180 and pycor < [pycor] of myself [try-ignite]
    if wind-direction = 270 and pxcor < [pxcor] of myself [try-ignite]
    ; Lower chance to ignite if not in wind direction
    if not member? wind-direction [0 90 180 270] [try-ignite-lower-chance]
  ]
end

to try-ignite
  ; 30% chance to ignite
  if random-float 1 < 0.3 [
    set pcolor red
    set burning-duration 1
  ]
end

to try-ignite-lower-chance
  ; 10% chance to ignite
  if random-float 1 < 0.1 [
    set pcolor red
    set burning-duration 1
  ]
end

to extinguish-fire
  ; Units extinguish fires in their vicinity
  ask units with [water-level > 0] [
    if any? patches in-radius 1 with [pcolor = red or pcolor = orange] [
      ask one-of patches in-radius 1 with [pcolor = red or pcolor = orange] [
        set pcolor green
        set burning-duration 0
      ]
      set water-level water-level - 1
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
34
132
97
165
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
140
133
203
166
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
34
214
206
247
units-count
units-count
1
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
34
173
206
206
scouters-count
scouters-count
1
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
34
256
206
289
water-capacity
water-capacity
2
15
12.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
# Agents in a Forest Fire Scenario 

## What does the model simulate?

The model simulates a fire management scenario, it includes several elements such as fire scouts (scouters), firefighting units (units), wind-direction and the mechanism of fire spread.

**It seeks to simulate the dynamics of forest fire detection, management and suppression in a controlled environment**. It allows users to observe how various factors (such as the effectiveness of scouts in detecting fires, the effectiveness of units in managing the water they carry and their effectiveness in fighting fires, and the effect of wind direction on fire spread) can affect the overall success of suppression efforts.


## What are the entities in the simulation and their role in it:

**Scouters:** represent individuals responsible for locating and notifying units of new fire locations. They move around the simulation area and update a global list called 'alerted-fires' when they encounter a fire.

**Firefighting units:** are the firefighting agents, they are equipped with water to put out fires. They move to the notified fires to put them out or return to base to replenish their water levels when they are depleted.

**Patches:** the terrain in the simulation is divided into patches, some of which represent trees (green patches) that can catch fire. The patches have a 'burning-duration' property on them to track how long (ticks) they burn.


## Processes/mechanisms in the simulation:

**Fire detection and notification process:** as the detection agents move they detect fires within a certain radius and update the list and through this the fire units use it to locate the fires and move towards them to put them out.

**Firefighting and water management:** units give priority to moving towards fires to extinguish them but must manage their water resources carefully. When their water levels are depleted they return to base to replenish them.

**Fire spreading mechanism:** at the beginning of the simulation the initial fire is random, the spread of the fire is affected by the wind direction (which wind direction is also random), it is understood that it spreads more easily in the wind direction and the duration of burning of the pieces affects the appearance (if they burn for a long time the trees change colour from red to orange).

**Wind direction:** the wind direction as mentioned above affects how the fire spreads across the landscape. The model takes into account four directions (0°, 90°, 180° and 270°), with the fire having a higher probability of spreading in the wind direction.

## How do I use/run the model?

**(1) Scouters-count**: sets the number of scouters in the simulation, it is set before clicking the setup button, the minimum number of scouters is 1 and the maximum is 10. 

**(1) Number of units (units-count):** sets the number of firefighting units in the simulation, as with the previous setting it is done before clicking the setup button, the minimum number of these is 1 and the maximum is 10.

**(1) Water-capacity:** defines the initial water level of each fire unit, it is set first press the setup, the minimum number of capacity is 2 and the maximum is 15.

**(2) Setup button (setup):** pressing it initializes the simulation environment, clears the previous state and adjusts the base, trees, scooters, units, wind direction and sets a random initial fire. Any time you want to restart the simulation from the beginning you will need to click again.

**(3) Start button (go):** pressing it activates the main loop and starts or continues the simulation. Pressing it a second time pauses the simulation.

So first **(1)** we set the parameters we want, then **(2)** we press setup to initialize the environment based on the settings we made, to start the simulation **(3)** we press go and if we want to pause it or start it again we press it again.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
