--[[
-- added by wsh @ 2017-12-13
-- Lua侧UI特效组件
--]]

local UIGameObjectLoader = UIGameObjectLoader
local Type_Renderer = typeof(CS.UnityEngine.Renderer)
local GameUtility = CS.GameUtility

local UIEffect = BaseClass("UIEffect", UIBaseComponent)
local base = UIBaseComponent


-- 创建
local function OnCreate(self, sortOrder, effectPath, create_callback)
	base.OnCreate(self)
	
	-- order
	self.sortOrder = sortOrder or 0
	self.m_seq = 0
	self.rectTrans = nil

	if effectPath then
		local res_path = PreloadHelper.GetEffectPath(effectPath)
		self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
		UIGameObjectLoader:GetInstance():GetGameObject(self.m_seq, res_path, function(go)
			self.m_seq = 0
			
			if not IsNull(go) then
				self.m_effect = BaseEffect.New(go, self.transform, effectPath)
				local trans = self.m_effect.transform
				local rectTransform = UIUtil.FindComponent(trans, typeof(CS.UnityEngine.RectTransform))
				
				if not IsNull(rectTransform) then
					-- 初始化RectTransform
					rectTransform.offsetMax = Vector2.zero
					rectTransform.offsetMin = Vector2.zero
					rectTransform.localScale = Vector3.one
					
					rectTransform.anchoredPosition3D = Vector3.zero

					self.rectTrans = rectTransform
				end
				self:SetOrder(self.sortOrder)
				if create_callback ~= nil then
					create_callback(self)
				end
			end
		end)
	end
	
	if effectPath == nil then
		self:SetOrder(self.sortOrder)
	end
end

-- 激活
local function OnEnable(self)
	base.OnEnable(self)
	self:SetOrder(self.sortOrder)
end

-- 获取层级内order
local function GetOrder(self)
	return self.sortOrder
end

-- 设置层级内order
local function SetOrder(self, sortOrder)
	assert(type(sortOrder) == "number", "Relative order must be nonnegative number!")
	assert(sortOrder >= 0, "Relative order must be nonnegative number!")
    
	self.sortOrder = sortOrder
	if self.m_effect then
		self.m_effect:SetSortingOrder(sortOrder)
		self.m_effect:SetSortingLayerName(SortingLayerNames.UI)
	end
end

--设置renderQueue
local function SetRenderQueue(self, renderQueue)
	assert(type(renderQueue) == "number", "Relative renderQueue must be nonnegative number!")
	assert(renderQueue >= 0, "Relative renderQueue must be nonnegative number!")
    
	if self.m_effect then
		self.m_effect:SetRenderQueue(renderQueue)
	end
end

-- 销毁
local function OnDestroy(self)
	UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)

	self.rectTrans = nil

	if self.m_effect then
		self.m_effect:Delete()
		self.m_effect = nil
	end
	
	base.OnDestroy(self)
end

local function SetLocalPosition(self, pos)
	if not IsNull(self.rectTrans) then
		self.rectTrans.anchoredPosition3D = pos
	else
		if self.m_effect and not IsNull(self.m_effect.transform) then
			-- self.m_effect.transform.localPosition = pos
			GameUtility.SetLocalPosition(self.m_effect.transform, pos.x, pos.y, pos.z)
		end
	end
end

local function SetLocalScale(self, localScale)
	if not IsNull(self.rectTrans) then
		self.rectTrans.localScale = localScale
	else
		if self.m_effect and not IsNull(self.m_effect.transform) then
			self.m_effect.transform.localScale = localScale
		end
	end
end

local function GetGameObject(self)
	if self.m_effect then
		return self.m_effect.gameObject
	end
end

local function Show(self, isShow)
	if self.m_effect then
		self.m_effect:Show(isShow)
	end
end

local function Play(self)
	if self.m_effect then
		self.m_effect:Play()
	end
end

local function ClipParticleWithBounds(self, clipRegion)
	if not self.m_effect then
		return
	end
	local renderList = self.m_effect.transform:GetComponentsInChildren(Type_Renderer)
	if renderList then
		for i = 0, renderList.Length - 1 do
			local matList = renderList[i].materials
			if matList then
				for i = 0, matList.Length - 1 do
					local mat = matList[i]
					if mat and mat:HasProperty("_ClipRegions") then
						mat:SetVector("_ClipRegions", clipRegion)
					end
				end
			end
		end
	end
end

UIEffect.OnCreate = OnCreate
UIEffect.OnEnable = OnEnable
UIEffect.GetOrder = GetOrder
UIEffect.SetOrder = SetOrder
UIEffect.OnDestroy = OnDestroy
UIEffect.SetLocalPosition = SetLocalPosition
UIEffect.SetLocalScale = SetLocalScale
UIEffect.Show = Show
UIEffect.Play = Play
UIEffect.ClipParticleWithBounds = ClipParticleWithBounds
UIEffect.SetRenderQueue = SetRenderQueue
UIEffect.GetGameObject = GetGameObject

return UIEffect