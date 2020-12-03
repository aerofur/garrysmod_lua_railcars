local V = {
	Name = "Trinity 3230 PD",
	Model = "models/lazpack/freightcars/trinity_3230_pd.mdl",
	Class = "gmod_railcars_base",
	Category = "Base",
    BogieModel = "models/magtrains/trucks/barber_s2_rsg.mdl",
    BogieBodygroup = 2,
    BogieAngle = Angle(0,90,0),
    Bogie1Pos = Vector(201,0,-0.5),
    Bogie2Pos = Vector(-201,0,-0.5),
    HandBrakePos = Vector(267,-19,65),
    CouplerPos = Vector(278,0,8),
    CouplerPos2 = Vector(-278,0,8),
    HandBrakeChain = {"titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain01.wav",
    "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain02.wav",
    "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain03.wav",
    "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain04.wav",
    "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain05.wav"},
    Debug = false,
    CoupleRopeWidth = 1.5,
    CouplingOutofBounds = 200,
    CouplingEnable = true,
    HandbrakeEnable = true,
    Ambient = "titus's locomotive sound expansion pack/resources/railvehicle/freightstock/resources/wheels/defective/s_freightdefectivewheel02.wav",
    BrakeAmbient = "titus's locomotive sound expansion pack/resources/railvehicle/freightstock/resources/brakes/s_freightbraking03.wav",
    CoupleSound = "opencontrol/misc/couple1.wav",
    CouplingRopePoint = 170,
    BrakeMaterial = "metal"
}
list.Set("railcars","trinity_3230_pd",V)

local V = {
	Name = "Bethgon Coal",
	Model = "models/hanksabutt/rollingstock/bethgon_coalporter/bethgon_coalporter_irlskins.mdl",
	Class = "gmod_railcars_base",
	Category = "Base",
    BogieModel = "models/gsgtrainprops/parts/trucks/barber_s2hd_36in_phx.mdl",
    BogieBodygroup = 0,
    BogieAngle = Angle(0,0,0),
    Bogie1Pos = Vector(245.8,0,1.4),
    Bogie2Pos = Vector(-245.8,0,1.4),
    HandBrakePos = Vector(-300,16.55,50.9),
    CouplerPos = Vector(320,0,8),
    CouplerPos2 = Vector(-320,0,8),
    HandBrakeChain = {"titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain01.wav",
    "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain02.wav",
    "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain03.wav",
    "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain04.wav",
    "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain05.wav"},
    Debug = false,
    CoupleRopeWidth = 1.5,
    CouplingOutofBounds = 200,
    CouplingEnable = true,
    HandbrakeEnable = true,
    Ambient = "titus's locomotive sound expansion pack/resources/railvehicle/freightstock/resources/wheels/defective/s_freightdefectivewheel02.wav",
    BrakeAmbient = "titus's locomotive sound expansion pack/resources/railvehicle/freightstock/resources/brakes/s_freightbraking03.wav",
    CoupleSound = "opencontrol/misc/couple1.wav",
    CouplingRopePoint = 170,
    BrakeMaterial = "metal"
}
list.Set("railcars","bethgon_coalporter_irlskins",V)
