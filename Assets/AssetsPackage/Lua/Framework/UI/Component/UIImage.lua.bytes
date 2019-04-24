--[[
-- added by wsh @ 2017-12-08
-- Lua侧UIImage
-- 使用方式：
-- self.xxx_img = self:AddComponent(UIImage, var_arg)--添加孩子，各种重载方式查看UIBaseContainer
--]]

local UIImage = BaseClass("UIImage", UIBaseComponent)
local base = UIBaseComponent
local Sprite = CS.UnityEngine.Sprite
local Rect = CS.UnityEngine.Rect
local Type_Sprite = typeof(Sprite)
local Vector2Point = Vector2.New(0.5,0.5)
local GameUtility = CS.GameUtility

-- 创建
local function OnCreate(self, atlas_config, original_sprite_name)
	base.OnCreate(self)
	-- Unity侧原生组件
	self.unity_uiimage = UIUtil.FindImage(self.transform)
	self.m_atlas_config = atlas_config
	self.sprite_name = original_sprite_name
	
	if IsNull(self.unity_uiimage) and not IsNull(self.gameObject) then
		self.gameObject = self.unity_uiimage.gameObject
		self.transform = self.unity_uiimage.transform
	end
end

-- 获取Sprite名称
local function GetSpriteName(self)
	return self.sprite_name
end

-- 设置Sprite名称
local function SetAtlasSprite(self, sprite_name, setNativeSize, atlas_config)
	self.m_atlas_config = atlas_config or self.m_atlas_config
	self.sprite_name = sprite_name
	if IsNull(self.unity_uiimage) then
		return
	end
	if not self.m_atlas_config then
		Logger.LogError("No atlas config for : " .. sprite_name)
		return
	end
	
	AtlasManager:GetInstance():LoadImageAsync(self.m_atlas_config, sprite_name, function(sprite, sprite_name)
		-- 预设已经被销毁
		if IsNull(self.unity_uiimage) then
			return
		end
		
		-- 被加载的Sprite不是当前想要的Sprite：可能预设被复用，之前的加载操作就要作废
		if sprite_name ~= self.sprite_name then
			return
		end
		
		if not IsNull(sprite) then
			if Type_Sprite == sprite:GetType() then
				self.unity_uiimage.sprite = sprite
			else
				self.unity_uiimage.sprite = GameUtility.CreateSpriteFromTexture(sprite)	
				-- Sprite.Create(sprite, Rect(0,0,sprite.width, sprite.height), Vector2Point, 100)
			end

			if setNativeSize then
				self.unity_uiimage:SetNativeSize()
			end
		end
	end, self.sprite_name)
end

local function SetFillAmount(self, val)
	if not IsNull(self.unity_uiimage) then
		self.unity_uiimage.fillAmount = val
	end
	
end

local function SetSizeDelta(self, sizeDelta)
	self.rectTransform.sizeDelta = sizeDelta
end

local function EnableRaycastTarget(self, enabled)
	if not IsNull(self.unity_uiimage) then		
		GameUtility.SetRaycastTarget(self.unity_uiimage, enabled)
	end
end

local function SetColor(self, color)
	if not IsNull(self.unity_uiimage) then
		self.unity_uiimage.color = color
	end
end

local function GetImage(self)
	return self.unity_uiimage
end

-- 销毁
local function OnDestroy(self)
	self.unity_uiimage = nil
	base.OnDestroy(self)
end

UIImage.OnCreate = OnCreate
UIImage.GetSpriteName = GetSpriteName
UIImage.SetAtlasSprite = SetAtlasSprite
UIImage.SetFillAmount = SetFillAmount
UIImage.SetSizeDelta = SetSizeDelta
UIImage.EnableRaycastTarget = EnableRaycastTarget
UIImage.SetColor = SetColor
UIImage.GetImage = GetImage
UIImage.OnDestroy = OnDestroy

return UIImage