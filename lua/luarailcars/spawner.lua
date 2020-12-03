local function SetEntityOwner(ply,entity)
    if not IsValid(entity) or not IsValid(ply) then return end
    
    if CPPI then
        if not IsEntity(ply) then return end
        
        if IsValid(ply) then
            entity:CPPISetOwner(ply)
        end
    end
end

local function SpawnCar(ply,args)
    tr = ply:GetEyeTraceNoCursor()
    if ( !tr.Hit ) then return end

    local SpawnPos = tr.HitPos + tr.HitNormal * 10
    local SpawnAng = ply:EyeAngles()
    SpawnAng.p = 0
    SpawnAng.y = SpawnAng.y + 180

    local Config = list.Get("railcars")[args]

    local ent = ents.Create("gmod_railcars_base")
    ent:SetModel(Config.Model)
    ent:SetCreator(ply)
    ent:SetPos(SpawnPos)
    ent:SetAngles(SpawnAng)
    ent:Spawn()
    ent:Activate()
    ent:DropToFloor()
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetSolid(SOLID_VPHYSICS)
    ent:SetUseType(SIMPLE_USE)
    ent:SetCollisionGroup(20)

    ent.CarType = args
    SetEntityOwner(ply,ent)
    
    ent:SetDebug(Config.Debug)
    ent:SetCoupleRopeWidth(Config.CoupleRopeWidth)
    ent:SetCouplingOutofBounds(Config.CouplingOutofBounds)
    ent:SetCouplingEnable(Config.CouplingEnable)
    ent:SetAmbient(Config.Ambient)
    ent:SetBrakeAmbient(Config.BrakeAmbient)
    ent:SetCoupleSound(Config.CoupleSound)
    ent:SetCouplingRopePoint(Config.CouplingRopePoint)
    ent:SetBrakeMaterial(Config.BrakeMaterial)

    ent.Model = Config.Model
    ent.BogieModel = Config.BogieModel
    ent.BogieBodygroup = Config.BogieBodygroup
    ent.BogieAngle = Config.BogieAngle
    ent.Bogie1Pos = Config.Bogie1Pos
    ent.Bogie2Pos = Config.Bogie2Pos
    ent.HandBrakePos = Config.HandBrakePos
    ent.CouplerPos = Config.CouplerPos
    ent.CouplerPos2 = Config.CouplerPos2
    ent.HandBrakeChain = Config.HandBrakeChain

	undo.Create("Railcar")
		undo.SetPlayer(ply)
		undo.AddEntity(ent)
	undo.Finish("Railcar")
end

concommand.Add("luarailcars_spawn",function(ply,cmd,args) SpawnCar(ply,args[1]) end)
