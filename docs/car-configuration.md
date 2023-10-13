# Developer Documentation

<br>

## Section 1.0 - Installation of Lua Railcars
### Section 1.1 - Installation of Lua Railcars
1. Steam Workshop
    1. The addon can be downloaded from the [Steam workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2304547218)
3. Local Installation:
    1. See **Section 1.2**


### Section 1.2 - Developer Installation of Lua Railcars
1. Windows:
    1. Open Command Prompt
    2. Change directory to your Garry's Mod addon path: `cd "C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons"`
    3. Clone the Repo: `git clone https://github.com/aerofur/garrysmod_lua_railcars.git`
    4. Rename the cloned repo: `ren garrysmod_lua_railcars lua_railcars`
2. Linux/UNIX
    1. To be written

<br>

## Section 2.0 - Railcar Configuration
### Section 2.1 - Railcar configuration files
The config files for the railcars is located under `lua\luarailcars\config\`
1. `base.lua` Contains the base railcars included in the addon.
2. `base_phx.lua` Contains PHX versions of above.

### Section 2.2 - Getting Car Vectors/Positions
To be written.

### Section 2.3 - Car Data
Car data is stored in [Lists](https://wiki.facepunch.com/gmod/list), which contain a table of all the car data. These lists are accessed by the spawn menu, spawner code, and the railcar itself.

Here is an example of the config for Laz's Trinity 3230 PD:
```lua
local V = {
    Name = "Trinity 3230 PD",
    Model = "models/lazpack/freightcars/trinity_3230_pd.mdl",
    Class = "gmod_railcars_base",
    Category = "Hopper",
    BogieModel = "models/magtrains/trucks/barber_s2_rsg.mdl",
    BogieBodygroup = 2,
    BogieAngle = Angle(0, 90, 0),
    Bogie1Pos = Vector(201, 0, -0.5),
    Bogie2Pos = Vector(-201, 0, -0.5),
    HandBrakePos = Vector(267, -19, 65),
    HandBrakePos2 = Vector(0, 0, 0),
    DualHandbrake = false,
    CouplerPos = Vector(278, 0, 8),
    CouplerPos2 = Vector(-278, 0, 8),
    HandBrakeChain = {"titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain01.wav", "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain02.wav", "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain03.wav", "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain04.wav", "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain05.wav"},
    Debug = false,
    CoupleRopeWidth = 1.5,
    CouplingOutofBounds = 50,
    CouplingEnable = true,
    HandbrakeEnable = true,
    Ambient = "titus's locomotive sound expansion pack/resources/railvehicle/freightstock/resources/wheels/defective/s_freightdefectivewheel02.wav",
    BrakeAmbient = "titus's locomotive sound expansion pack/resources/railvehicle/freightstock/resources/brakes/s_freightbraking03.wav",
    CoupleSound = "opencontrol/misc/couple1.wav",
    CouplingRopePoint = 15,
    BrakeMaterial = "metal"
}

list.Set("railcars", "trinity_3230_pd", V)
```

Variable | Takes | Description
--- | --- | ---
Name | `string` | The nice name of the car, this is used by the spawnmenu.
Model | `string` | The railcar model path.
Class | `string` | Entity Class, Leave as `"gmod_railcars_base"`.
Category | `string` | The category used in the spawnmenu, eg; Hoppers, Bethgon, etc.
BogieModel | `string` | The bogie model path.
BogieBodygroup | `number` | The bodygroup the bogie spawns with, useful for bogie models with different types as bodygroups.
BogieAngle | `angle` | The spawn angle of the bogies.
Bogie1Pos | `vector` | Position of the bogie, realitive to the railcar entity.
Bogie2Pos | `vector` | Position of the second bogie, realitive to the railcar entity.
HandBrakePos | `vector` | Position of the handbrake, realitive to the railcar entity.
HandBrakePos2 | `vector` | Position of the second handbrake (if equipped), realitive to the railcar entity.
DualHandbrake | `boolean` | Set to `true` if the railcar has two handbrakes, mainly on cabooses.
CouplerPos | `vector` | Position of the coupler, realitive to the railcar entity.
CouplerPos2 | `vector` | Position of the second coupler, realitive to the railcar entity.
HandBrakeChain | `table` | Table of strings, these are the sounds that play when the handbrake is changed.
Debug | `boolean` | Debug mode, leave as `false`.
CoupleRopeWidth | `number` | The width of the automatic coupling rope.
CouplingOutofBounds | `number` | The distance which the car has to go to re-enable automatic coupling, this prevents the car from re-coupling the moment you uncouple it.
CouplingEnable | `boolean` | Automatic coupling enable (or disable)
HandbrakeEnable | `boolean` | Handbrake enable (or disable)
Ambient | `string` | The ambient sound played while the car is rolling, pitch changes on speed.
BrakeAmbient | `string` | Same as above, except this is the braking sound, eg: brake whine.
CoupleSound | `string` | Coupling sound.
CouplingRopePoint | `number` | How far away two couplers need to be to initiate a automatic couple
BrakeMaterial | `string` | The [physical material](https://wiki.facepunch.com/gmod/PhysObj:SetMaterial) given to the bogies when the handbrake is applied.

> **IMPORTANT:** Automatic Coupling is always being worked on and changed, it is highly recommended that you do not edit the automatic coupling settings, or change the `BrakeMaterial`.
The defaults are:

Variable | Takes | Value
--- | --- | ---
CoupleRopeWidth | `number` | 1.5
CouplingOutofBounds | `number` | 50
CouplingRopePoint | `number` | 15
BrakeMaterial | `string` | "metal"

### Section 2.4 - Setting the List

Now that the data is set, you need to push the table into the list.
1. The lists identifier is: `"railcars"`
2. The lists key is the name of the model from the model path. Eg, `models/lazpack/freightcars/trinity_3230_pd.mdl` = `trinity_3230_pd`
3. The item/data is the local variable that you put the car data on, should be `V`.
4. Example: `list.Set("railcars", "trinity_3230_pd", V)`

Read more here: [https://wiki.facepunch.com/gmod/list.Set](https://wiki.facepunch.com/gmod/list.Set)

### Section 2.5 - Testing

1. Reload the Garry's Mod map you are on by typing `reload` in console.
2. Spawn the car in from the railcars spawnmenu
3. When the car has spawned, open the context menu (by holding down the `C` key), right click on the car and click `Edit Properties..` 
4. In the properties menu, tick `Debug` to enter Debug mode, this allows you to see the positions of the Car Data.
5. Refine/Edit Car Data. The car data updates in realtime, if you edit a cars data table, and save your changes, you will be able to see them take affect immediately. This is very helpful for setting handbrake positions, and coupler positions. Refer to **Section 2.2** for positioning.
