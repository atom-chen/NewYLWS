


local UILayers = UILayers
local GameUtility = CS.GameUtility

local UISortOrderMgr = BaseClass("UISortOrderMgr", Singleton)

function UISortOrderMgr:__init()
    self.m_startSortingOrderList = {}
    self.m_currSortingOrderList = {}

    for k, v in pairs(UILayers) do 
        if v then
            self.m_startSortingOrderList[k] = v.OrderInLayer
            self.m_currSortingOrderList[k] = v.OrderInLayer
        end
    end
end

function UISortOrderMgr:__delete()
    self.m_startSortingOrderList = nil
    self.m_currSortingOrderList = nil
end

--用于设置Canvas
--[[ function UISortOrderMgr:SetSortingOrder(ref_tar, gameObject, layer_name, count)
    if IsNull(gameObject) or not ref_tar then
        Logger.Log("SetSortingOrder nil")
        return 
    end

    count = count or 1
    ref_tar.order_counter = ref_tar.order_counter or 0
    ref_tar.order_counter = ref_tar.order_counter + count

    self:AddCurrLayerSortOrder(layer_name, count)
    GameUtility.SetSortingOrder(gameObject, true, self:GetCurrLayerDepth(layer_name))
end
 ]]

function UISortOrderMgr:PopSortingOrder(ref_tar, layer_name, count)
    assert(ref_tar ~= nil)
    assert(layer_name ~= nil)

    count = count or 1
    ref_tar.order_counter = ref_tar.order_counter or 0
    ref_tar.order_counter = ref_tar.order_counter + count
    self:AddCurrLayerSortOrder(layer_name, count)
    return self:GetCurrLayerSortOrder(layer_name)
end

function UISortOrderMgr:PushSortingOrder(ref_tar, layer_name, count)
    assert(ref_tar ~= nil)
    assert(layer_name ~= nil)

    if ref_tar.order_counter and ref_tar.order_counter > 0 then
        if count then
            if count > 0 then
                self:DeleteCurrLayerSortOrder(layer_name, count)
                ref_tar.order_counter = ref_tar.order_counter - count
            end
        else
            self:DeleteCurrLayerSortOrder(layer_name, ref_tar.order_counter)
            ref_tar.order_counter = 0
        end
    end
end

function UISortOrderMgr:AddCurrLayerSortOrder(layer_name, count)
    if self.m_currSortingOrderList[layer_name] then
		self.m_currSortingOrderList[layer_name] = self.m_currSortingOrderList[layer_name] + (count or 1)
    end
end

function UISortOrderMgr:DeleteCurrLayerSortOrder(layer_name, count)
    if self.m_currSortingOrderList[layer_name] then
        self.m_currSortingOrderList[layer_name] = self.m_currSortingOrderList[layer_name]  - count
    end

	if self.m_startSortingOrderList[layer_name] then
	 	if self:GetCurrLayerSortOrder(layer_name) < self.m_startSortingOrderList[layer_name] then
			self.m_currSortingOrderList[layer_name] = self.m_startSortingOrderList[layer_name]
		end
	end
end

function UISortOrderMgr:GetCurrLayerSortOrder(layer_name)
	return self.m_currSortingOrderList[layer_name]
end

return UISortOrderMgr