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

local Model = "models/lazpack/freightcars/trinity_3230_pd.mdl"
local BogieModel = "models/magtrains/trucks/barber_s2_rsg.mdl"
local Bogie1Pos = Vector(201,0,-0.5)
local Bogie2Pos = Vector(-201,0,-0.5)
local HandBrakePos = Vector(267,-19,65)
local CouplerPos = Vector(278,0,8)
local CouplerPos2 = Vector(-278,0,8)
local Ambient = "titus's locomotive sound expansion pack/resources/railvehicle/freightstock/resources/wheels/defective/s_freightdefectivewheel02.wav"
local BrakeAmbient = "titus's locomotive sound expansion pack/resources/railvehicle/freightstock/resources/brakes/s_freightbraking03.wav"
local HandBrakeChain = {"titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain01.wav",
                        "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain02.wav",
                        "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain03.wav",
                        "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain04.wav",
                        "titus's locomotive sound expansion pack/plugins/dlc/coalhopperbethogonii/content/view/audio/resources/handbrake/s_bethgonhandbrakechain05.wav"}
local HandBrake = 0 --Don't Change
local CanCouple = 1 --Don't Change
local CanCouple2 = 1 --Don't Change
local CouplerRopePoint = 170


local function ModelCreate(class,parent,model,position,angle,collisiongroup,rendermode,creator)
    local ent = ents.Create(class)
    ent:SetCreator(creator) --why does this not work???
    ent:SetParent(parent)
    ent:SetModel(model)
    ent:SetLocalAngles(angle)
    ent:SetRenderMode(rendermode)
    ent:Spawn()
    ent:SetCollisionGroup(collisiongroup)
    ent:GetPhysicsObject():SetMaterial("friction_00")
    ent:SetNWBool("LuaRailcars",true) 


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

local function EntityWithinBounds(ply,otherPly,dist)
	return ply:GetPos():DistToSqr(otherPly:GetPos()) < (dist*dist)
end

local function EntityOutsideBounds(ply,otherPly,dist)
	return ply:GetPos():DistToSqr(otherPly:GetPos()) > (dist*dist)
end


if SERVER then
    function ENT:SpawnFunction(ply,tr,ClassName)
        if ( !tr.Hit ) then return end

        local SpawnPos = tr.HitPos + tr.HitNormal * 10
        local SpawnAng = ply:EyeAngles()
        SpawnAng.p = 0
        SpawnAng.y = SpawnAng.y + 180

        local ent = ents.Create(ClassName)
        ent:SetCreator(ply) --why does this not work?????!?!?1?!?
        ent:SetPos(SpawnPos+Vector(0,0,50))
        ent:SetAngles(SpawnAng)
        ent:Spawn()
        ent:Activate()
        ent:DropToFloor()

        return ent
    end

    function ENT:Initialize()
        self:SetModel(Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetCollisionGroup(20)
        self:SetNWBool("LuaRailcar", true) 
        HandBrake = 0 --Don't Change
        CanCouple = 1 --Don't Change
        CanCouple2 = 1 --Don't Change

        if constraint.CanConstrain(self,0) then
            Bogie1 = ModelCreate("prop_physics",nil,BogieModel,self:LocalToWorld(Bogie1Pos),self:GetAngles()+Angle(0,90,0),0,0,self:GetCreator())
            Bogie1:SetBodygroup(1,2)
            Bogie1:SetSubMaterial(0,"models/proppertextures/wheel")
            Bogie1:SetSubMaterial(7,"models/proppertextures/wheel")
            constraint.Axis(Bogie1,self,0,0,Vector(0,0,0),Vector(0,0,0),0,0,0,1,Vector(0,0,1))

            Bogie2 = ModelCreate("prop_physics",nil,BogieModel,self:LocalToWorld(Bogie2Pos),self:GetAngles()+Angle(0,90,0),0,0,self:GetCreator())
            Bogie2:SetBodygroup(1,2)
            Bogie2:SetSubMaterial(0,"models/proppertextures/wheel")
            Bogie2:SetSubMaterial(7,"models/proppertextures/wheel")
            constraint.Axis(Bogie2,self,0,0,Vector(0,0,0),Vector(0,0,0),0,0,0,1,Vector(0,0,1))

            self:DeleteOnRemove(Bogie1)
            self:DeleteOnRemove(Bogie2)
            self.Bogies = {Bogie1,Bogie2}
        end

        self.AmbientTrack = CreateSound(self,Ambient)
        self.AmbientTrack:PlayEx(1,0)
        self.AmbientBrake = CreateSound(self,BrakeAmbient)
        self.AmbientBrake:PlayEx(1,0)

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

            if HandBrake == 1 then
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
        local CouplerFind = ents.FindInSphere(self:LocalToWorld(CouplerPos),100)
        local CouplerFind2 = ents.FindInSphere(self:LocalToWorld(CouplerPos2),100)
        local Velocity = self:GetPhysicsObject():GetVelocity():Length()
        local VelocityClamped = math.Clamp(Velocity/5,0,250)
        self.AmbientTrack:ChangePitch(VelocityClamped)
        self.AmbientBrake:ChangePitch(VelocityClamped*HandBrake)

        for index,Entity in pairs(CouplerFind) do
            if Entity:GetClass() == "prop_physics" then
                if Entity:GetNWBool("LuaRailcars",false) ~= false then
                    if constraint.Find(self,Entity,"Axis",0,0) == nil then
                        if constraint.Find(self.Bogies[1],Entity,"Rope",0,0) then return end
                        
                        if CanCouple == 1 then
                            if EntityWithinBounds(self.Bogies[1],Entity,CouplerRopePoint) then
                                timer.Simple(0,function()
                                    constraint.Rope(self.Bogies[1],Entity,0,0,Vector(0,0,0),Vector(0,0,0),self.Bogies[1]:GetPos():Distance(Entity:GetPos()),0,0,1.5,"cable/cable",true)
                                    self.CoupleSound = CreateSound(self,"opencontrol/misc/couple1.wav")
                                    self.CoupleSound:PlayEx(1,100)
                                    CanCouple = 0
                                end)
                            end
                        else
                            if EntityOutsideBounds(self.Bogies[1],Entity,200) then
                                CanCouple = 1
                            end
                        end
                    end
                end
            end
        end

        for index,Entity in pairs(CouplerFind2) do
            if Entity:GetClass() == "prop_physics" then
                if Entity:GetNWBool("LuaRailcars",false) ~= false then
                    if constraint.Find(self,Entity,"Axis",0,0) == nil then
                        if constraint.Find(self.Bogies[2],Entity,"Rope",0,0) then return end
                        
                        if CanCouple == 1 then
                            if EntityWithinBounds(self.Bogies[2],Entity,CouplerRopePoint) then
                                timer.Simple(0,function()
                                    constraint.Rope(self.Bogies[2],Entity,0,0,Vector(0,0,0),Vector(0,0,0),self.Bogies[2]:GetPos():Distance(Entity:GetPos()),0,0,1.5,"cable/cable",true)
                                    self.CoupleSound = CreateSound(self,"opencontrol/misc/couple1.wav")
                                    self.CoupleSound:PlayEx(1,100)
                                    CanCouple = 0
                                end)
                            end
                        else
                            if EntityOutsideBounds(self.Bogies[2],Entity,200) then
                                CanCouple = 1
                            end
                        end
                    end
                end
            end
        end
    end

    function ENT:OnRemove()
        self.AmbientTrack:Stop()
        self.AmbientBrake:Stop()
    end
else
    function ENT:Draw()
        self:DrawModel()
        render.DrawWireframeBox(self:GetPos(),self:GetAngles(),self:OBBMins(),self:OBBMaxs(),Color(255,0,0),false) --car bounding
        render.DrawWireframeBox(self:LocalToWorld(Bogie1Pos),self:GetAngles(),Vector(10,10,10),Vector(-10,-10,-10),Color(0,255,0),false) --bogie
        render.DrawWireframeBox(self:LocalToWorld(Bogie2Pos),self:GetAngles(),Vector(10,10,10),Vector(-10,-10,-10),Color(0,255,0),false) --bogie
        render.DrawWireframeBox(self:LocalToWorld(HandBrakePos),self:GetAngles(),Vector(4,12,12),Vector(-4,-12,-12),Color(0,255,0),false) --handbrake
        render.DrawWireframeBox(self:LocalToWorld(CouplerPos),self:GetAngles(),Vector(10,10,8),Vector(-10,-10,-8),Color(0,0,255),false) --coupler
        render.DrawWireframeBox(self:LocalToWorld(CouplerPos2),self:GetAngles(),Vector(10,10,8),Vector(-10,-10,-8),Color(0,0,255),false) --coupler
        render.DrawWireframeSphere(self:LocalToWorld(CouplerPos),100,10,10,Color(100,210,255)) --coupler finder
        render.DrawWireframeSphere(self:LocalToWorld(CouplerPos2),100,10,10,Color(100,210,255)) --coupler finder
    end
    return
end
