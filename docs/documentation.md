#dzPortals - Documentation

## Installation
Just download the project, unzip it and place the contents of the addons folder into the addons folder of your godot project directory.
Reload/load your project.
In godot goto project settings->addons and activate the dzPortals addon.
You're done.

## Basic workings
DzPortals works with 3 basic objects zones, areas and gates.

A zone defines a confined space that should be culled by the portals engine.
Areas define the volume of a zone. A zones volume can be defined by one or more areas.
Gates are the visual connections between zones.

### Zone
Zone should containe all visual instances of the defining space. If the zone is culled it gets hidden and so do all of its children nodes.

#### Properties:
* disabled: zone gets excluded from calculation. The zone will stay in its initial state until disabled = false is set
* blackList: Array of nodePath's. When the camera is in the zone ayy nodes defined in here will be immediately culled and excluded from any further processing.

### Area
Areas should enclose all of the visual instances in the zone. You can have as many areas linked to a zone as you like.

#### Properties:
* shape: shape defines the volumetric body of the area. So far there are box, sphere and cylindrical shapes available.
* dimensions: the spacial extends of the shape
* margin: an margin applied to the shape
* zone: the zone it is used for
* blackList: Array of nodePath's. When the camera is in this area any nodes defined in here will be immediately culled and excluded from any further processing.
* disabled: area gets excluded from calculation.


### Gate
Gates should cover doorways, portals, windows etc. completly or else you will have pop in effects when looking around.
Gates have two sides, a blue side and a red side. The sides should be connected with the corresponding zones.
Gates can connect two zones via setting them directly or can be defined as magnetic. Magnetic gates have only one side connected with a zone. If they come close to another magnetic portal with similar properties they can connect and act as one portal. This is espacially usefull when you are building your scene with modular subscenes. You can then define the openings in the subscene and when putting it together in the main scene they  connect automaticly.

#### Properties:
* dimensions: the sapcial extends of the portal
* do frustum check: uses anhanced visibility check with sligthly increased calculation effort
* blue zone: node Path to the zone on the blue side
* red zone: node Path to the zone on the red side
* is magnetic: this gate is magnetic and will connect to other magnetic gates. This option only apply when **only one** side is connected to a zone.
* auto magnetic: will automaticly connect to any nearby gate when moved in scene
* magnetic distance: the max distance for magnetic snapping
* magnetic angle: the max orientation offset for magnetic snapping
* magnetic dimension: the max difference of the gates dimensions for magnetic snapping
* magnetic gaze: the nodePath to the magnetic snapped gate
* disabled: gate gets excluded from calculation. The gate will not activate the zone connected to it. Usefull when a door, portal etc. is closed. When a visual instance is blocking the sight through the gate you can turn off the gate. This will prevent the zone behinde the gate to be rendered.

## dzPortals Inspector
On the bottom menu you find the dzPortlas Inspector with many usefull tools to help you build your portals  system.

### Stats
Here you see the impact of the portal optimisation.
* visible zones: zones that are visible, the others are not
* gates processed: the amount of gates that had to be calculated in the current frame
* clipped polys: the amount of polygons that are clipped through portals optimisation. This number shows only potential reduced polygons, this does not take in acount allready clipped polygons through frustum culling or any other culling/hiding optimization.
You have to hit "Refresh polygon count" first to aquire the total amount of scene polygons.
* processing time: the time it took to process all areas and gates

### Tools
### Visibility

## [API](#api)
here
