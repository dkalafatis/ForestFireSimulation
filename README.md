# Forest Fire NetLogo Simulation

This NetLogo project simulates a forest fire scenario with two types of agents: scouters and fire-fighting units.


The main components and functionalities of the simulation are: 

Scouters: Represented by white agents, scouters move randomly within the simulation environment. Their role is to detect fires within a certain radius (5 units). Upon detecting a fire (a red or orange patch), they record the fire's location and add it to a list of alerted fires.

Fire-Fighting Units: Represented by red agents and slightly larger in size, these units are responsible for extinguishing fires. They have a water-level attribute indicating the amount of water they carry, initialized based on a slider value (water-capacity). If their water level depletes, they return to the base (located at the center patch [0,0]) to refill.


Environment Setup:

Base: A central location at patch (0,0), marked in blue, where units can refill their water supply.

Trees: Represented by green patches, trees are placed in a circular area around the base, between distances of 5 and 25 units.

Initial Fire: The simulation starts with a randomly selected tree patch catching fire (turned red), indicating the starting point of the forest fire.

Wind Direction: The wind direction is randomly set to one of the four cardinal directions (0°, 90°, 180°, 270°) and influences the spread of the fire.


Fire Spread Mechanism:

Patches that are on fire (red) increase their burning-duration each tick. If a patch has been burning for more than 5 ticks, it turns orange, indicating prolonged burning. Fire spreads to neighboring green patches (trees) based on the wind direction. Patches in the direction of the wind have a higher chance (30%) of catching fire, while others have a lower chance (10%).


Agent Behaviors:

Scouters: Continuously move forward and detect fires within their vicinity. They communicate the locations of detected fires to the fire-fighting units by adding them to the alerted-fires list.

Fire-Fighting Units: Navigate towards the nearest alerted fire to extinguish it. They avoid collisions with other units by changing direction if another unit is within a radius of 1.5 units. If their water supply runs out, they return to the base to refill.

Extinguishing Fires: Units with water remaining can extinguish fires by turning red or orange patches back to green and resetting their burning-duration. Each extinguished fire reduces the unit's water level by 1.

### Dependencies

* NetLogo 6.4.0
