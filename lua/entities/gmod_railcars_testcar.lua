AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity") 
ENT.Type = "anim"
ENT.PrintName = "Test Car"
ENT.Author = "Titus Studios"
ENT.Category = "Railcars"
ENT.RenderGroup	= RENDERGROUP_OPAQUE
ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
--ENT.DisableDuplicator = true
--ENT.DoNotDuplicate = true

local Model = "models/hanksabutt/rollingstock/bethgon_coalporter/bethgon_coalporter_irlskins.mdl"
local BogieModel = "models/gsgtrainprops/parts/trucks/barber_s2hd_36in_phx.mdl"
local Bogie1Pos = Vector(245.8,0,1.4)
local Bogie2Pos = Vector(-245.8,0,1.4)
local HandBrakePos = Vector(-300,16.55,50.9)
local CouplerPos = Vector(-320,0,8)
local CouplerPos2 = Vector(320,0,8)
local Ambient = "titus's locomotive sound expansion pack/resources/railvehicle/freightstock/resources/wheels/defective/s_freightdefectivewheel02.wav"
local BrakeAmbient = "titus's locomotive sound expansion pack/resources/railvehicle/freightstock/resources/brakes/s_freightbraking03.wav"
local HandBrakeChain = {"titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain01.wav",
                        "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain02.wav",
                        "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain03.wav",
                        "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain04.wav",
                        "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain05.wav"}
local HandBrake = 0 --Don't Change
local SpawnHeight = 35 --temp


local function ModelCreate(self,class,parent,model,position,angle,collisiongroup,rendermode)
    local ent = ents.Create(class)
    ent:SetParent(parent)
    ent:SetModel(model)
    ent:SetLocalAngles(angle)
    ent:SetRenderMode(rendermode)
    ent:SetOwner(self:GetOwner())
    ent:Spawn()
    ent:SetCollisionGroup(collisiongroup)
    ent:GetPhysicsObject():SetMaterial("friction_00")
    ent:PhysWake()

    if parent == nil then
        ent:SetPos(position)
    else
        ent:SetLocalPos(position)
    end

    ent:Activate()
    return ent
end

local function PlayerWithinBounds(ply,otherPly,dist)
	return ply:EyePos():DistToSqr(otherPly) < (dist*dist)
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetPos(self:GetPos()+Vector(0,0,35))
        self:SetCollisionGroup(20)

        if constraint.CanConstrain(self,0) then
            Bogie1 = ModelCreate(self,"prop_physics",nil,BogieModel,self:LocalToWorld(Bogie1Pos),self:GetAngles(),0,0)
            constraint.Axis(Bogie1,self,0,0,Vector(0,0,0),Vector(0,0,0),0,0,0,1,Vector(0,0,1))
            Bogie2 = ModelCreate(self,"prop_physics",nil,BogieModel,self:LocalToWorld(Bogie2Pos),self:GetAngles(),0,0)
            constraint.Axis(Bogie2,self,0,0,Vector(0,0,0),Vector(0,0,0),0,0,0,1,Vector(0,0,1))
            self:DeleteOnRemove(Bogie1)
            self:DeleteOnRemove(Bogie2)
        end

        self.AmbientTrack = CreateSound(self,Ambient)
        self.AmbientTrack:PlayEx(1,0)
        self:CallOnRemove("stoptracksound",function(self) self.AmbientTrack:Stop() end)

        self.AmbientBrake = CreateSound(self,BrakeAmbient)
        self.AmbientBrake:PlayEx(1,0)
        self:CallOnRemove("stopbrakesound",function(self) self.AmbientBrake:Stop() end)

        if WireLib then
            --self.Inputs = WireLib.CreateSpecialInputs(self,{"Handbrake"},{"NORMAL"})
            self.Outputs = WireLib.CreateSpecialOutputs(self,{"Handbrake"},{"NORMAL"})
            self.WireDebugName = "railcar"
        end
    end

    function ENT:PostEntityPaste(ply,ent,createdEntities)
        if IsValid(Bogie1) then
            Bogie1:Remove()
        end
        if IsValid(Bogie2) then
            Bogie2:Remove()
        end
    end

    function ENT:Use(activator,caller,type,value)
        if (!activator:IsPlayer()) then return end	
        if PlayerWithinBounds(activator,self:LocalToWorld(HandBrakePos),45) then
            HandBrake = HandBrake+1
            if(HandBrake > 1) then HandBrake = 0 end

            self.HandBrakeSound = CreateSound(self,HandBrakeChain[math.random(1,5)])
            self.HandBrakeSound:PlayEx(1,100)

            if HandBrake then
                if IsValid(Bogie1) then
                    Bogie1:GetPhysicsObject():SetMaterial("metal")
                end
                if IsValid(Bogie2) then
                    Bogie2:GetPhysicsObject():SetMaterial("metal")
                end
            else
                if IsValid(Bogie1) then
                    Bogie1:GetPhysicsObject():SetMaterial("friction_00")
                end
                if IsValid(Bogie2) then
                    Bogie2:GetPhysicsObject():SetMaterial("friction_00")
                end
            end

            if WireLib then
                WireLib.TriggerOutput(self,"Handbrake",HandBrake)
            end
        end
    end

    function ENT:Think()
        local velocity = self:GetPhysicsObject():GetVelocity():Length()
        local velocityclamped = math.Clamp(velocity/5,0,250)
        self.AmbientTrack:ChangePitch(velocityclamped)
        self.AmbientBrake:ChangePitch(velocityclamped*HandBrake)
    end
else
    function ENT:Draw()
        self:DrawModel()
        render.DrawWireframeBox(self:GetPos(),self:GetAngles(),self:OBBMins(),self:OBBMaxs(),Color(255,0,0),false) --car bounding
        --render.DrawWireframeBox(self:LocalToWorld(Bogie1Pos),Bogie1:GetAngles(),Bogie1:OBBMins(),Bogie1:OBBMaxs(),Color(255,0,0),false) --bogie bounding
        --render.DrawWireframeBox(self:LocalToWorld(Bogie2Pos),Bogie2:GetAngles(),Bogie2:OBBMins(),Bogie2:OBBMaxs(),Color(255,0,0),false) --bogie bounding
        render.DrawWireframeBox(self:LocalToWorld(Bogie1Pos),self:GetAngles(),Vector(10,10,10),Vector(-10,-10,-10),Color(0,255,0),false) --bogie
        render.DrawWireframeBox(self:LocalToWorld(Bogie2Pos),self:GetAngles(),Vector(10,10,10),Vector(-10,-10,-10),Color(0,255,0),false) --bogie
        render.DrawWireframeBox(self:LocalToWorld(HandBrakePos),self:GetAngles(),Vector(4,12,12),Vector(-4,-12,-12),Color(0,255,0),false) --handbrake
        render.DrawWireframeBox(self:LocalToWorld(CouplerPos),self:GetAngles(),Vector(10,10,8),Vector(-10,-10,-8),Color(0,0,255),false) --coupler
        render.DrawWireframeBox(self:LocalToWorld(CouplerPos2),self:GetAngles(),Vector(10,10,8),Vector(-10,-10,-8),Color(0,0,255),false) --coupler
    end
    return
end
