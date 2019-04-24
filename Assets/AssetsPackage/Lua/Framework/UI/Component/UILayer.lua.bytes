--[[
-- added by wsh @ 2017-12-08
-- Lua侧UILayer
--]]

local Screen = CS.UnityEngine.Screen
local Canvas = CS.UnityEngine.Canvas
local CanvasScaler = CS.UnityEngine.UI.CanvasScaler
local GraphicRaycaster = CS.UnityEngine.UI.GraphicRaycaster
local UIUtil = UIUtil

local UILayer = BaseClass("UILayer", UIBaseComponent)
local base = UIBaseComponent

-- 创建
local function OnCreate(self, layer)
	base.OnCreate(self)
	-- Unity侧原生组件
	self.unity_canvas = nil
	self.unity_canvas_scaler = nil
	self.unity_graphic_raycaster = nil
	
	-- ui layer
	self.gameObject.layer = Layers.UI
	self.LayerName = layer.Name
    
	-- canvas
	local Type_Canvas = typeof(Canvas)
	self.unity_canvas = UIUtil.FindComponent(self.transform, Type_Canvas)
	if IsNull(self.unity_canvas) then
		self.unity_canvas = self.gameObject:AddComponent(Type_Canvas)
		-- 说明：很坑爹，这里添加UI组件以后transform会Unity被替换掉，必须重新获取
		self.transform = self.unity_canvas.transform
		self.gameObject = self.unity_canvas.gameObject
	end
	self.unity_canvas.renderMode = CS.UnityEngine.RenderMode.ScreenSpaceCamera
	self.unity_canvas.worldCamera = UIManager:GetInstance().UICamera
	self.unity_canvas.planeDistance = layer.PlaneDistance
	self.unity_canvas.sortingLayerName = SortingLayerNames.UI
	self.unity_canvas.sortingOrder = layer.OrderInLayer
	
	-- scaler
	local Type_CanvasScaler = typeof(CanvasScaler)
	self.unity_canvas_scaler = UIUtil.FindComponent(self.transform, Type_CanvasScaler)
	if IsNull(self.unity_canvas_scaler) then
		self.unity_canvas_scaler = self.gameObject:AddComponent(Type_CanvasScaler)
	end
	self.unity_canvas_scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize
	self.unity_canvas_scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.Expand
	self.unity_canvas_scaler.referenceResolution = UIManager:GetInstance().Resolution
	
	-- raycaster
	local Type_GraphicRaycaster = typeof(CS.UnityEngine.UI.GraphicRaycaster)
	self.unity_graphic_raycaster = UIUtil.FindComponent(self.transform, Type_GraphicRaycaster)
	if IsNull(self.unity_graphic_raycaster) then
		self.unity_graphic_raycaster = self.gameObject:AddComponent(Type_GraphicRaycaster)
	end
	
	-- window order
	self.top_window_order = layer.OrderInLayer
	self.min_window_order = layer.OrderInLayer
	
	local referenceResolution = UIManager:GetInstance().Resolution
	local rateX = referenceResolution.x / Screen.width
	local rateY = referenceResolution.y / Screen.height
	self.m_scaleRate =  rateX > rateY and rateX or rateY

	
end

-- pop window order
local function PopWindowOder(self)
	local cur = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.LayerName, UIManagerInst.MaxOderPerWindow)
	return cur
end

-- push window order
local function PushWindowOrder(self)
	UISortOrderMgr:GetInstance():PushSortingOrder(self, self.LayerName, UIManagerInst.MaxOderPerWindow) 
end

local function ScaleRate(self)
	return self.m_scaleRate 
end

-- 销毁
local function OnDestroy(self)
	self.unity_canvas = nil
	self.unity_canvas_scaler = nil
	self.unity_graphic_raycaster = nil
	base.OnDestroy(self)
end


UILayer.OnCreate = OnCreate
UILayer.PopWindowOder = PopWindowOder
UILayer.PushWindowOrder = PushWindowOrder
UILayer.ScaleRate = ScaleRate
UILayer.OnDestroy = OnDestroy

return UILayer