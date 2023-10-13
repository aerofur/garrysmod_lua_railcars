AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")
ENT.Type = "anim"
ENT.PrintName = "Railcars_Base"
ENT.Author = "Titus Studios"
ENT.Category = "Railcars"
ENT.RenderGroup	= RENDERGROUP_OPAQUE
ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:SetupDataTables()
    self:NetworkVar("Bool",0,"Debug",{KeyName = "Debug Mode", Edit = {type = "Boolean", order = 0}})
    self:NetworkVar("Bool",1,"CouplingEnable",{KeyName = "Auto Coupling", Edit = {type = "Boolean", order = 1}})
    self:NetworkVar("Bool",3,"HandbrakeEnable",{KeyName = "Handbrake Enable", Edit = {type = "Boolean", order = 2}})
    self:NetworkVar("Float",0,"CouplingRopePoint",{KeyName = "Coupling Rope Point", Edit = {type = "Float", order = 3, min = 0, max = 9999}})
    self:NetworkVar("Float",1,"CouplingOutofBounds",{KeyName = "Coupling Out of Bounds", Edit = {type = "Float", order = 4, min = 0, max = 9999}})
    self:NetworkVar("Float",2,"CoupleRopeWidth",{KeyName = "Width of the Auto Couple Rope", Edit = {type = "Float", order = 5, min = 0, max = 9999}})
    self:NetworkVar("String",0,"BrakeMaterial",{KeyName = "Handbrake Material", Edit = {type = "Generic", order = 6}})
    self:NetworkVar("Bool",4,"EnableSounds",{KeyName = "Enable Sounds", Edit = {type = "Boolean", order = 7}})
    self:NetworkVar("String",1,"Ambient",{KeyName = "Rolling Sound", Edit = {type = "Generic", order = 8, category = "Sounds"}})
    self:NetworkVar("String",2,"BrakeAmbient",{KeyName = "Brake Sound", Edit = {type = "Generic", order = 9, category = "Sounds"}})
    self:NetworkVar("String",3,"CoupleSound",{KeyName = "Couple Sound", Edit = {type = "Generic", order = 10, category = "Sounds"}})
end

local function SetEntityOwner(ply,entity)
    if not IsValid(entity) or not IsValid(ply) then return end

    if CPPI then
        if not IsEntity(ply) then return end

        if IsValid(ply) then
            entity:CPPISetOwner(ply)
        end
    end
end

local function ModelCreate(class,parent,model,position,angle,collisiongroup,rendermode,creator)
    local ent = ents.Create(class)
    ent:SetCreator(creator)
    ent:SetParent(parent)
    ent:SetModel(model)
    ent:SetLocalAngles(angle)
    ent:SetRenderMode(rendermode)
    ent:Spawn()
    ent:SetCollisionGroup(collisiongroup)
    ent:GetPhysicsObject():SetMaterial("friction_00")
    ent:SetNWBool("LuaRailcars",true)
    SetEntityOwner(creator,ent)


    if parent == nil then
        ent:SetPos(position)
    else
        ent:SetLocalPos(position)
    end

    ent:Activate()
    return ent
end

local function PlayerWithinBounds(ply,otherPly,dist)
    return ply:EyePos():DistToSqr(otherPly) < (dist * dist)
end

local function CreateAmbientSounds(Entity)
    Entity.AmbientTrack = CreateSound(Entity,Entity:GetAmbient())
    Entity.AmbientTrack:PlayEx(1,0)
    Entity.AmbientBrake = CreateSound(Entity,Entity:GetBrakeAmbient())
    Entity.AmbientBrake:PlayEx(1,0)
end

local function RemoveAmbientSounds(Entity)
    Entity.AmbientTrack:Stop()
    Entity.AmbientBrake:Stop()
end

if SERVER then
    function ENT:Initialize()
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetCollisionGroup(20)
        self:SetNWBool("LuaRailcar",true)
        self.HandBrake = 0
        self.CanCouple = 1
        self.CanCouple2 = 1
        self.GenerateBogies = true
        self.BogiesInit = false
        self.HaltCouplingDupe = false
        self:SetPos(self:GetPos() + Vector(0,0,35))
        self.Bogies = {}
        self.SoundsEnabled = self:GetEnableSounds()

        timer.Simple(0,function()
            self:SetSkin(math.random(0,self:SkinCount()))
            self:SetModel(self.Model)
            self:SetPos(self:GetPos() + Vector(0,0,35))
            self:SetNWString("DebugType",self.CarType)

            if self.SoundsEnabled == true then
                CreateAmbientSounds(self)
            end
        end)
    end

    function ENT:OnDuplicated()
        self.GenerateBogies = false
        self.HaltCouplingDupe = true
    end

    function ENT:Use(activator,caller,type,value)
        if self:GetHandbrakeEnable() == true then
            if not activator:IsPlayer() then return end
            if PlayerWithinBounds(activator,self:LocalToWorld(self.HandBrakePos),45) then
                self.HandBrake = self.HandBrake + 1
                if self.HandBrake > 1 then self.HandBrake = 0 end

                self.HandBrakeSound = CreateSound(self,self.HandBrakeChain[math.random(1,5)])
                self.HandBrakeSound:PlayEx(1,100)

                if self.HandBrake == 1 then
                    if IsValid(self.Bogies[1]) then
                        self.Bogies[1]:GetPhysicsObject():SetMaterial(self:GetBrakeMaterial())
                    end
                    if IsValid(self.Bogies[2]) then
                        self.Bogies[2]:GetPhysicsObject():SetMaterial(self:GetBrakeMaterial())
                    end
                else
                    if IsValid(self.Bogies[1]) then
                        self.Bogies[1]:GetPhysicsObject():SetMaterial("friction_00")
                    end
                    if IsValid(self.Bogies[2]) then
                        self.Bogies[2]:GetPhysicsObject():SetMaterial("friction_00")
                    end
                end
            end

            if self.DualHandbrake == true and PlayerWithinBounds(activator,self:LocalToWorld(self.HandBrakePos2),45) then
                if not activator:IsPlayer() then return end
                self.HandBrake = self.HandBrake + 1
                if self.HandBrake > 1 then self.HandBrake = 0 end

                self.HandBrakeSound = CreateSound(self,self.HandBrakeChain[math.random(1,5)])
                self.HandBrakeSound:PlayEx(1,100)

                if self.HandBrake == 1 then
                    if IsValid(self.Bogies[1]) then
                        self.Bogies[1]:GetPhysicsObject():SetMaterial(self:GetBrakeMaterial())
                    end
                    if IsValid(self.Bogies[2]) then
                        self.Bogies[2]:GetPhysicsObject():SetMaterial(self:GetBrakeMaterial())
                    end
                else
                    if IsValid(self.Bogies[1]) then
                        self.Bogies[1]:GetPhysicsObject():SetMaterial("friction_00")
                    end
                    if IsValid(self.Bogies[2]) then
                        self.Bogies[2]:GetPhysicsObject():SetMaterial("friction_00")
                    end
                end
            end
        end
    end

    function ENT:Think()
        if self.GenerateBogies == true and constraint.CanConstrain(self,0) then
            self.Bogie1 = ModelCreate("prop_physics",nil,self.BogieModel,self:LocalToWorld(self.Bogie1Pos),self:GetAngles() + self.BogieAngle,0,0,self:GetCreator())
            self.Bogie1:SetBodygroup(1,self.BogieBodygroup)
            constraint.Axis(self.Bogie1,self,0,0,Vector(0,0,0),Vector(0,0,0),0,0,0,1,Vector(0,0,1))

            self.Bogie2 = ModelCreate("prop_physics",nil,self.BogieModel,self:LocalToWorld(self.Bogie2Pos),self:GetAngles() + self.BogieAngle,0,0,self:GetCreator())
            self.Bogie2:SetBodygroup(1,self.BogieBodygroup)
            constraint.Axis(self.Bogie2,self,0,0,Vector(0,0,0),Vector(0,0,0),0,0,0,1,Vector(0,0,1))

            self:DeleteOnRemove(self.Bogie1)
            self:DeleteOnRemove(self.Bogie2)
            self.Bogies = {self.Bogie1,self.Bogie2}
            self.BogieSpawned1 = self.Bogie1
            self.BogieSpawned2 = self.Bogie2
            self.BogiesInit = true
            self.GenerateBogies = false
        elseif self.GenerateBogies == false and self.BogiesInit == false then
            local Cons = constraint.FindConstraints(self,"Axis")
            if Cons[1] ~= nil and Cons[2] ~= nil and IsValid(Cons[1].Ent1) and IsValid(Cons[2].Ent1) then
                local Coupler1 = self:LocalToWorld(self.CouplerPos):Distance(self:LocalToWorld(Cons[1].Ent1:GetPos()))
                local Coupler2 = self:LocalToWorld(self.CouplerPos):Distance(self:LocalToWorld(Cons[2].Ent1:GetPos()))

                if math.min(Coupler1,Coupler2) == Coupler1 then
                    self.Bogies = {Cons[1].Ent1,Cons[2].Ent1}
                else
                    self.Bogies = {Cons[2].Ent1,Cons[1].Ent1}
                end

                self.BogiesInit = true
            end
        end

        self.SoundsEnabled = self:GetEnableSounds()

        if self.SoundsEnabled == true then
            if IsValid(self.AmbientTrack) == false then -- Check if AmbientTrack has already been declared, this would be due to AdvDupe.
                CreateAmbientSounds(self)
            end

            local Velocity = self:GetPhysicsObject():GetVelocity():Length()
            local VelocityClamped = math.Clamp(Velocity / 5,0,250)
            self.AmbientTrack:ChangePitch(VelocityClamped)
            self.AmbientBrake:ChangePitch(VelocityClamped * self.HandBrake)
        else
            if IsValid(self.AmbientTrack) == true then
                RemoveAmbientSounds(self)
            end
        end

        local CouplerFind = ents.FindAlongRay(self:LocalToWorld(self.CouplerPos + Vector(0,0,18)),self:LocalToWorld(self.CouplerPos + Vector(100,0,18)))
        local CouplerFind2 = ents.FindAlongRay(self:LocalToWorld(self.CouplerPos2 + Vector(0,0,18)),self:LocalToWorld(self.CouplerPos2 + Vector(-100,0,18)))

        if self:GetCouplingEnable() == true and IsValid(self.Bogies[1]) and IsValid(self.Bogies[2]) and self.HaltCouplingDupe == false then
            for index,Entity in pairs(CouplerFind) do
                if Entity ~= self and Entity:GetClass() == "gmod_railcars_base" and IsValid(Entity.Bogies[1]) and IsValid(Entity.Bogies[2]) then
                    local ClosestCoupler1 = self:LocalToWorld(self.CouplerPos):Distance(Entity:GetPos())
                    local ClosestCoupler2 = self:LocalToWorld(self.CouplerPos2):Distance(Entity:GetPos())
                    local ClosestForeignCoupler1 = Entity:LocalToWorld(Entity.CouplerPos):Distance(self:GetPos())
                    local ClosestForeignCoupler2 = Entity:LocalToWorld(Entity.CouplerPos2):Distance(self:GetPos())

                    if math.min(ClosestCoupler1,ClosestCoupler2) == ClosestCoupler1 then
                        ClosestBogie = self.Bogies[1]
                        ClosestCoupler = self.CouplerPos
                    elseif math.min(ClosestCoupler1,ClosestCoupler2) == ClosestCoupler2 then
                        ClosestBogie = self.Bogies[2]
                        ClosestCoupler = self.CouplerPos2
                    end

                    if math.min(ClosestForeignCoupler1,ClosestForeignCoupler2) == ClosestForeignCoupler1 then
                        ClosestForeignBogie = Entity.Bogies[1]
                        ClosestForeignCoupler = Entity.CouplerPos
                    elseif math.min(ClosestForeignCoupler1,ClosestForeignCoupler2) == ClosestForeignCoupler2 then
                        ClosestForeignBogie = Entity.Bogies[2]
                        ClosestForeignCoupler = Entity.CouplerPos2
                    end

                    local CouplerDistance = self:LocalToWorld(ClosestCoupler):Distance(Entity:LocalToWorld(ClosestForeignCoupler))

                    if not IsValid(constraint.Find(ClosestBogie,ClosestForeignBogie,"Rope",0,0)) then
                        if CouplerDistance < self:GetCouplingRopePoint() and self.CanCouple == 1 then
                            constraint.Rope(ClosestBogie,ClosestForeignBogie,0,0,Vector(0,0,0),Vector(0,0,0),ClosestBogie:GetPos():Distance(ClosestForeignBogie:GetPos()),0,0,self:GetCoupleRopeWidth(),"cable/cable",true)
                            
                            self.CoupleSound = CreateSound(self,self:GetCoupleSound())
                            self.CoupleSound:PlayEx(1,100)

                            self.CanCouple = 0
                        elseif CouplerDistance > self:GetCouplingOutofBounds() and self.CanCouple == 0 then
                            self.CanCouple = 1
                        end
                    end
                end
            end

            for index,Entity in pairs(CouplerFind2) do
                if Entity ~= self and Entity:GetClass() == "gmod_railcars_base" and IsValid(Entity.Bogies[1]) and IsValid(Entity.Bogies[2]) then
                    local ClosestCoupler1 = self:LocalToWorld(self.CouplerPos):Distance(Entity:GetPos())
                    local ClosestCoupler2 = self:LocalToWorld(self.CouplerPos2):Distance(Entity:GetPos())
                    local ClosestForeignCoupler1 = Entity:LocalToWorld(Entity.CouplerPos):Distance(self:GetPos())
                    local ClosestForeignCoupler2 = Entity:LocalToWorld(Entity.CouplerPos2):Distance(self:GetPos())

                    if math.min(ClosestCoupler1,ClosestCoupler2) == ClosestCoupler1 then
                        ClosestBogie = self.Bogies[1]
                        ClosestCoupler = self.CouplerPos
                    elseif math.min(ClosestCoupler1,ClosestCoupler2) == ClosestCoupler2 then
                        ClosestBogie = self.Bogies[2]
                        ClosestCoupler = self.CouplerPos2
                    end

                    if math.min(ClosestForeignCoupler1,ClosestForeignCoupler2) == ClosestForeignCoupler1 then
                        ClosestForeignBogie = Entity.Bogies[1]
                        ClosestForeignCoupler = Entity.CouplerPos
                    elseif math.min(ClosestForeignCoupler1,ClosestForeignCoupler2) == ClosestForeignCoupler2 then
                        ClosestForeignBogie = Entity.Bogies[2]
                        ClosestForeignCoupler = Entity.CouplerPos2
                    end

                    local CouplerDistance = self:LocalToWorld(ClosestCoupler):Distance(Entity:LocalToWorld(ClosestForeignCoupler))

                    if not IsValid(constraint.Find(ClosestBogie,ClosestForeignBogie,"Rope",0,0)) then
                        if CouplerDistance < self:GetCouplingRopePoint() and self.CanCouple == 1 then
                            constraint.Rope(ClosestBogie,ClosestForeignBogie,0,0,Vector(0,0,0),Vector(0,0,0),ClosestBogie:GetPos():Distance(ClosestForeignBogie:GetPos()),0,0,self:GetCoupleRopeWidth(),"cable/cable",true)
                            
                            self.CoupleSound = CreateSound(self,self:GetCoupleSound())
                            self.CoupleSound:PlayEx(1,100)

                            self.CanCouple = 0
                        elseif CouplerDistance > self:GetCouplingOutofBounds() and self.CanCouple == 0 then
                            self.CanCouple = 1
                        end
                    end
                end
            end
        end

        local function DupeFinished()
            timer.Simple(5,function()
                self.HaltCouplingDupe = false
            end)
        end

        hook.Add("AdvDupe_FinishPasting", "luarailcars_dupefinished", DupeFinished)
    end

    function ENT:OnRemove()
        if self.SoundsEnabled == true then
            RemoveAmbientSounds(self)
        end
    end
else
    function ENT:Draw()
        self:DrawModel()

        local Config = list.Get("railcars")[self:GetNWString("DebugType",nil)]

        if self:GetDebug() == true then
            render.DrawWireframeBox(self:GetPos(),self:GetAngles(),self:OBBMins(),self:OBBMaxs(),Color(255,0,0),false) --car bounding
            render.DrawWireframeBox(self:LocalToWorld(Config.Bogie1Pos),self:GetAngles(),Vector(10,10,10),Vector(-10,-10,-10),Color(0,255,0),false) --bogie
            render.DrawWireframeBox(self:LocalToWorld(Config.Bogie2Pos),self:GetAngles(),Vector(10,10,10),Vector(-10,-10,-10),Color(0,255,0),false) --bogie
            render.DrawWireframeBox(self:LocalToWorld(Config.HandBrakePos),self:GetAngles(),Vector(4,12,12),Vector(-4,-12,-12),Color(0,255,0),false) --handbrake
            render.DrawWireframeBox(self:LocalToWorld(Config.CouplerPos),self:GetAngles(),Vector(10,10,8),Vector(-10,-10,-8),Color(0,0,255),false) --coupler
            render.DrawWireframeBox(self:LocalToWorld(Config.CouplerPos2),self:GetAngles(),Vector(10,10,8),Vector(-10,-10,-8),Color(0,0,255),false) --coupler
            render.DrawLine(self:LocalToWorld(Config.CouplerPos + Vector(0,0,18)),self:LocalToWorld(Config.CouplerPos + Vector(100,0,18)),Color(100,210,255)) --coupler finder
            render.DrawLine(self:LocalToWorld(Config.CouplerPos2 + Vector(0,0,18)),self:LocalToWorld(Config.CouplerPos2 + Vector(-100,0,18)),Color(10,132,255)) --coupler finder

            if Config.DualHandbrake == true then
                render.DrawWireframeBox(self:LocalToWorld(Config.HandBrakePos2),self:GetAngles(),Vector(4,12,12),Vector(-4,-12,-12),Color(0,255,0),false) --handbrake
            end
        end
    end
    return
end

duplicator.RegisterEntityClass("gmod_railcars_base", function(ply, data)
    return duplicator.GenericDuplicatorFunction(ply, data)
end, "Data", "CarType", "CoupleRopeWidth", "CouplingOutofBounds", "CouplingEnable", "HandbrakeEnable", "EnableSounds", "Ambient", "BrakeAmbient", "CoupleSound", "CouplingRopePoint", "BrakeMaterial",
"Model", "BogieModel", "BogieBodygroup", "BogieAngle", "Bogie1Pos", "Bogie2Pos", "HandBrakePos", "CouplerPos", "CouplerPos2", "HandBrakeChain", "GenerateBogies", "BogiesInit")
