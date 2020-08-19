#dzPortals - Documentation

## [Installation](#installation)
Just download the project, unzip it and place the contents of the addons folder into the addons folder of your godot project directory.
Reload/load your project.
In godot goto project settings->addons and activate the dzPortals addon.
You're done.

## [Basic workings](#basics)
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

## [API](#api)
here
