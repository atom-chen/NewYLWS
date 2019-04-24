

local Vector3 = Vector3
local Quaternion = Quaternion
local IsEditor = CS.GameUtility.IsEditor()
local GameObject = CS.UnityEngine.GameObject
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local GameUtility = CS.GameUtility

local UIBaseItem = BaseClass("UIBaseItem")

function UIBaseItem:__init(go, parent, resPath)

    self.m_gameObject = go
    self.transform = go.transform
    self.m_resPath = resPath
    self.m_rectTransform = UIUtil.FindComponent(self.transform, Type_RectTransform)

    if parent then
        self.transform:SetParent(parent)
        -- self.transform.localPosition = Vector3.zero
        -- self.transform.localScale = Vector3.one

        GameUtility.SetLocalPosition(self.transform, 0, 0, 0)
        GameUtility.SetLocalScale(self.transform, 1, 1, 1)
    end

    self.m_activeSelf = go.activeSelf

    self.m_localScale = self.transform.localScale

    self:OnCreate()

    if self.m_activeSelf then
        self:OnEnable()
    end
end

function UIBaseItem:__delete()
    self:OnDestroy()
    
    self:PushSortingOrder()

    if not IsNull(self.m_gameObject) then 
        if not self.m_resPath then
            GameObject.DestroyImmediate(self.m_gameObject)
        else
            if self.m_resPath ~= '' then
                GameObjectPoolInst:RecycleGameObject(self.m_resPath, self.m_gameObject)
            end
        end
    end
    
    self.m_gameObject = nil
    self.transform = nil
    self.m_rectTransform = nil
end

function UIBaseItem:OnDestroy()
   --各种释放
end

function UIBaseItem:SetActive(bShow)
    if not IsNull(self.m_gameObject) then
        if bShow then
            self.m_gameObject:SetActive(true)
            self:OnEnable()
        else
            self:OnDisable()
            self.m_gameObject:SetActive(false)
        end
        
        self.m_activeSelf = bShow
    end
end

function UIBaseItem:OnCreate()

end

function UIBaseItem:SetParent(parent)
    if parent then
        self.transform:SetParent(parent)
    end
end

function UIBaseItem:SetLocalPosition(pos)
	if self.transform then
		-- self.transform.localPosition = pos
        GameUtility.SetLocalPosition(self.transform, pos.x, pos.y, pos.z)
	end
end

function UIBaseItem:SetAnchoredPosition(pos)
	if self.m_rectTransform then
		-- self.m_rectTransform.anchoredPosition = pos
        GameUtility.SetAnchoredPosition(self.m_rectTransform, pos.x, pos.y, pos.z)
	end
end

function UIBaseItem:SetAsFirstSibling()
    if self.transform then
        self.transform:SetAsFirstSibling()
    end
end

function UIBaseItem:GetLocalPosition()
    if self.transform then
		return self.transform.localPosition
	end
end

function UIBaseItem:SetLocalScale(scale)
	if self.transform then
        -- self.transform.localScale = scale
        
        GameUtility.SetLocalScale(self.transform, scale.x, scale.y, scale.z)
        self.m_localScale = scale
	end
end

function UIBaseItem:SetLocalEulerAngles(eulerAngles)
	if self.transform then
		self.transform.localEulerAngles = eulerAngles
	end
end

function UIBaseItem:GetGameObject()
    return self.m_gameObject
end

function UIBaseItem:GetTransform()
    return self.transform
end

function UIBaseItem:SetGameObjectName(name)
    if IsEditor then
        if not IsNull(self.m_gameObject) then
            self.m_gameObject.name = name
        end
    end
end

function UIBaseItem:GetActive()
    return self.m_activeSelf
end

function UIBaseItem:OnEnable()
	
end

function UIBaseItem:OnDisable()
	
end

function UIBaseItem:PopSortingOrder(count)
    if not self.m_layerName then
        self.m_layerName = UILogicUtil.FindLayerName(self.transform)
    end

    return UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName, count)
end

function UIBaseItem:PushSortingOrder(count)
    if self.m_layerName then
        return UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName, count)
    end
end

return UIBaseItem