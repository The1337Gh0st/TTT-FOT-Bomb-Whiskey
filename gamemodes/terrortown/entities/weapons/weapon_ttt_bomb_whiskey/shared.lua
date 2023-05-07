if SERVER then
   AddCSLuaFile( "shared.lua" )
  -- resource.AddWorkshop("712675840")
   resource.AddFile("vgui/ttt/bomb_whiskey")
end

SWEP.HoldType = "normal"

if CLIENT then
   SWEP.PrintName = "Bomb Whiskey"
   SWEP.Slot = 6
   SWEP.ViewModelFOV = 10

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[
When innocents use this whiskey, it will 
beep before exploding.
Traitors will simply deplete the fake charge.]]
   };

   
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel          = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel         = "models/props/cs_office/microwave.mdl"

SWEP.Icon = "vgui/ttt/bomb_whiskey"

SWEP.DrawCrosshair      = false
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 1.0

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.0




SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} 
SWEP.LimitedStock = true
SWEP.WeaponID = AMMO_HEALTHSTATION

SWEP.AllowDrop = false

SWEP.NoSights = true

function SWEP:OnDrop()
   self:Remove()
end

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self:BombDrop()
end
function SWEP:SecondaryAttack()
   self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
   self:BombDrop()
end

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )


function SWEP:BombDrop()
   if SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end

      if self.Planted then return end

      local vsrc = ply:GetShootPos()
      local vang = ply:GetAimVector()
      local vvel = ply:GetVelocity()
      
      local vthrow = vvel + vang * 200

      local bomb = ents.Create("ttt_bomb_whiskey")
      if IsValid(bomb) then
         bomb:SetPos(vsrc + vang * 10)
         bomb:Spawn()
		 
		 bomb.fingerprints = { ply }

         bomb:SetPlacer(ply)

         bomb:PhysWake()
         local phys = bomb:GetPhysicsObject()
         if IsValid(phys) then
            phys:SetVelocity(vthrow)
         end   
         self:Remove()

         self.Planted = true
		 
		 if DMG_LOG then
			AddToDamageLog({DMG_LOG.BOMBSTATION, "PLANT", ply:Nick(), ply:GetRoleString(), {ply:SteamID()}})
		 end
      end
   end

   self.Weapon:EmitSound(throwsound)
end


function SWEP:Reload()
   return false
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end

if CLIENT then
   function SWEP:Initialize()
	  LANG.AddToLanguage("english", "bombwhiskey_help", "{primaryfire} places the Bomb Whiskey.")
      self:AddHUDHelp("bombwhiskey_help", nil, true)

      return self.BaseClass.Initialize(self)
   end
end

function SWEP:Deploy()
   if SERVER and IsValid(self.Owner) then
      self.Owner:DrawViewModel(false)
   end
   return true
end

function SWEP:DrawWorldModel()
end

function SWEP:DrawWorldModelTranslucent()
end

