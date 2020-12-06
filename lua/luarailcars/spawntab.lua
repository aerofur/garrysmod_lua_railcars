if CLIENT then
    hook.Add("PopulateMenu","AddEntityContent",function(pnlContent,tree,node)
        local Categorised = {}

        local Config = list.Get("railcars")
        if Config then
            for k, v in pairs(Config) do
                v.Category = v.Category or "Other"
                Categorised[v.Category] = Categorised[v.Category] or {}
                v.ClassName = k
                v.PrintName = v.Name
                v.ModelPath = v.Model
                table.insert(Categorised[v.Category],v)
            end
        end

        for CategoryName, v in SortedPairs(Categorised) do
            local node = tree:AddNode(CategoryName,"icon16/bricks.png")

            node.DoPopulate = function(self)
                if self.PropPanel then return end
                self.PropPanel = vgui.Create("ContentContainer",pnlContent)
                self.PropPanel:SetVisible(false)
                self.PropPanel:SetTriggerSpawnlistChange(false)
                
                for k, ent in SortedPairsByMemberValue(v,"PrintName") do
                    spawnmenu.CreateContentIcon("railcars",self.PropPanel,{
                        nicename = ent.PrintName or ent.ClassName,
                        spawnname = ent.ClassName,
                        material = "spawnicons/"..ent.ModelPath:match("(.+)%..+$")..".png",
                        admin = ent.AdminOnly
                    })
                end
            end

            node.DoClick = function(self)
                self:DoPopulate()
                pnlContent:SwitchPanel(self.PropPanel)
            end
        end

        local FirstNode = tree:Root():GetChildNode(0)

        if IsValid(FirstNode) then
            FirstNode:InternalDoClick()
        end
    end)

    spawnmenu.AddCreationTab("railcars",function()
        local ctrl = vgui.Create("SpawnmenuContentPanel")
        ctrl:CallPopulateHook("PopulateMenu")
        return ctrl
    end,"icon16/package.png",70)

    spawnmenu.AddContentType("railcars",function(container,obj)
        if not obj.material then return end
        if not obj.nicename then return end
        if not obj.spawnname then return end

        local icon = vgui.Create("ContentIcon",container)
        icon:SetContentType("railcars")
        icon:SetSpawnName(obj.spawnname)
        icon:SetName(obj.nicename)
        icon:SetMaterial(obj.material)
        icon:SetAdminOnly(obj.admin)
        icon:SetColor(Color(0,0,0,255))
        icon.DoClick = function()
            RunConsoleCommand("luarailcars_spawn",obj.spawnname)
            surface.PlaySound("ui/buttonclickrelease.wav")
        end

        icon.OpenMenu = function(icon)
            local menu = DermaMenu()
                menu:AddOption("Copy to Clipboard",function() SetClipboardText(obj.spawnname) end)
            menu:Open()
        end
        
        if IsValid(container) then
            container:Add(icon)
        end

        return icon
    end)
end
