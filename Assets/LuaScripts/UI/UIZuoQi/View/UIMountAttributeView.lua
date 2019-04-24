
local table_insert = table.insert
local string_format = string.format
local table_sort = table.sort
local Language = Language
local UIUtil = UIUtil
local CommonDefine = CommonDefine
local ConfigUtil = ConfigUtil
local AtlasConfig = AtlasConfig
local GameObject = CS.UnityEngine.GameObject
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local MountMgr = Player:GetInstance():GetMountMgr()
local wujiangMgr = Player:GetInstance().WujiangMgr
local ImproveItemPath = "UI/Prefabs/ZuoQi/ImproveItem.prefab"
local improveItem = require "UI.UIZuoQi.View.ImproveItem"

local Tab_Attr = 1
local Tab_Attr_Improve = 2

local UIMountAttributeView = BaseClass("UIMountAttributeView", UIBaseView)
local base = UIBaseView

function UIMountAttributeView:OnCreate()
    base.OnCreate(self)
    local mountAttrText, improveAttrText
    self.m_titleText, mountAttrText, improveAttrText = UIUtil.GetChildTexts(self.transform, {
        "Container/mountAttr/bg/top/Text",
        "Container/mountAttr/bg/mid/btnGrid/MountAttrBtn/Text",
        "Container/mountAttr/bg/mid/btnGrid/PromoteAttrBtn/Text"
    })

    self.m_backBtn, self.m_ruleBtn, self.m_mountAttrBtn, self.m_promoteAttrBtn,
    self.m_attrItemPrefab, self.m_attrGo, self.m_scrollViewGo, self.m_leftBtn, self.m_rightBtn,
    self.m_viewContent, self.m_attrGrid1, self.m_attrGrid2 = UIUtil.GetChildTransforms(self.transform, {
        "backBtn",
        "Container/mountAttr/bg/top/ruleButton",
        "Container/mountAttr/bg/mid/btnGrid/MountAttrBtn",
        "Container/mountAttr/bg/mid/btnGrid/PromoteAttrBtn",
        "Container/mountAttr/bg/AttrItemPrefab",
        "Container/mountAttr/bg/Attr",
        "Container/mountAttr/bg/ItemScrollView",
        "Container/Btn/leftBtn",
        "Container/Btn/rightBtn",
        "Container/mountAttr/bg/ItemScrollView/Viewport/ItemContent",
        "Container/mountAttr/bg/Attr/AttrGird1",
        "Container/mountAttr/bg/Attr/AttrGird2"

    })

    mountAttrText.text = Language.GetString(3548)
    improveAttrText.text = Language.GetString(3560)
    self.m_attrItemPrefab = self.m_attrItemPrefab.gameObject
    self.m_scrollViewGo = self.m_scrollViewGo.gameObject
    self.m_attrGo = self.m_attrGo.gameObject

    self.m_mountAttrImg = self:AddComponent(UIImage, "Container/mountAttr/bg/mid/btnGrid/MountAttrBtn", AtlasConfig.DynamicLoad)
    self.m_promoteAttrImg = self:AddComponent(UIImage, "Container/mountAttr/bg/mid/btnGrid/PromoteAttrBtn", AtlasConfig.DynamicLoad)
    self.m_scrollView = self:AddComponent(LoopScrowView, "Container/mountAttr/bg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateAttr))

    self.m_huntId = 0
    self.m_huntLevel = 0
    self.m_attrOneGoList = {}
    self.m_attrTwoGoList = {}
    self.m_improveAttrList = {}
    self.m_seq = 0
    self.m_currTab = false

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_leftBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 116))
    UIUtil.AddClickEvent(self.m_rightBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 116))
    UIUtil.AddClickEvent(self.m_mountAttrBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_promoteAttrBtn.gameObject, onClick)
end

function UIMountAttributeView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_leftBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rightBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_mountAttrBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_promoteAttrBtn.gameObject)
    base.OnDestroy(self)
end

function UIMountAttributeView:OnClick(go, x, y)
    if go.name == "backBtn" then
        self:CloseSelf()
    elseif go.name == "ruleButton" then
        --tipsbtndw
    elseif go.name == "MountAttrBtn" then
        self:TabChg(Tab_Attr)
    elseif go.name == "PromoteAttrBtn" then
        self:TabChg(Tab_Attr_Improve)
    elseif go.name == "leftBtn" then
        self.m_huntId = self.m_huntId - 1
        if self.m_huntId < CommonDefine.MOUNT_TYPE_YELLOWHORSE - 23000 then
            self.m_huntId = MountMgr.UnLockHuntCount
        end
        for i, v in pairs(MountMgr.HuntList) do
            if self.m_huntId == v.id then
                self.m_huntLevel = v.level
            end 
        end
        local huntCfg = ConfigUtil.GetHuntCfgByID(self.m_huntId)
        self.m_titleText.text = string_format(Language.GetString(3561), huntCfg.name, self.m_huntLevel)
        self.m_currTab = false
        self:TabChg(Tab_Attr)
    elseif go.name == "rightBtn" then
        self.m_huntId = self.m_huntId + 1
        if self.m_huntId > MountMgr.UnLockHuntCount then
            self.m_huntId = CommonDefine.MOUNT_TYPE_YELLOWHORSE - 23000
        end
        for i, v in pairs(MountMgr.HuntList) do
            if self.m_huntId == v.id then
                self.m_huntLevel = v.level
            end
        end
        local huntCfg = ConfigUtil.GetHuntCfgByID(self.m_huntId)
        self.m_titleText.text = string_format(Language.GetString(3561), huntCfg.name, self.m_huntLevel)
        self.m_currTab = false
        self:TabChg(Tab_Attr)
    end
end

function UIMountAttributeView:TabChg(tabType)
    if self.m_currTab ~= tabType then
        self.m_currTab = tabType

        if self.m_currTab == Tab_Attr then
            self.m_mountAttrImg:SetAtlasSprite("ty32.png")
            self.m_promoteAttrImg:SetAtlasSprite("ty31.png")
            self.m_attrGo:SetActive(true)
            self.m_scrollViewGo:SetActive(false)
            MountMgr:ReqFirstAttrDetail(self.m_huntId)

        elseif self.m_currTab == Tab_Attr_Improve then
            self.m_mountAttrImg:SetAtlasSprite("ty31.png")
            self.m_promoteAttrImg:SetAtlasSprite("ty32.png")
            self.m_attrGo:SetActive(false)
            self.m_scrollViewGo:SetActive(true)
            MountMgr:ReqGroundFirstAttr(self.m_huntId)

        end
    end
end

function UIMountAttributeView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_HUNT_RSP_GROUND_FIRST_ATTR, self.RspGroundFirstAttr)
    self:AddUIListener(UIMessageNames.MN_HUNT_RSP_FIRST_ATTR_DETAIL, self.RspFirstAttrDetail)
end

function UIMountAttributeView:OnRemoveListener()
    base.OnRemoveListener(self)

    self:RemoveUIListener(UIMessageNames.MN_HUNT_RSP_GROUND_FIRST_ATTR, self.RspGroundFirstAttr)
    self:RemoveUIListener(UIMessageNames.MN_HUNT_RSP_FIRST_ATTR_DETAIL, self.RspFirstAttrDetail)
end

function UIMountAttributeView:RspGroundFirstAttr(levelAttrList)
    if #self.m_improveAttrList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_seq, ImproveItemPath, 4, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local item = improveItem.New(objs[i], self.m_viewContent, ImproveItemPath)
                    table_insert(self.m_improveAttrList, item)
                end
            end
            self.m_scrollView:UpdateView(true, self.m_improveAttrList, levelAttrList)
        end)
    else
        self.m_scrollView:UpdateView(false, self.m_improveAttrList, levelAttrList)
    end
end

function UIMountAttributeView:UpdateAttr(item, realIndex)
    local levelAttrList = MountMgr.LevelAttrList
    if levelAttrList then
        if item and realIndex > 0 and realIndex <= #levelAttrList then
            local oneLevelAttr = levelAttrList[realIndex]
            item:SetData(self.m_huntId, self.m_huntLevel, oneLevelAttr.level, oneLevelAttr.attr_list)
        end
    end
end

function UIMountAttributeView:RspFirstAttrDetail(msg)
    local baseAttrMax = wujiangMgr:ToFirstAttrData(msg.base_first_attr_max)
    local extraAttrMax = wujiangMgr:ToFirstAttrData(msg.extra_first_attr_max)
    if baseAttrMax and extraAttrMax then
        local attrNameList = CommonDefine.first_attr_name_list
        local attrStr = ""
        for i, v in pairs(attrNameList) do
            local val = baseAttrMax[v]
            local val2 = extraAttrMax[v]
            if val and val2 then
                local attrType = CommonDefine[v]
                if attrType then
                    attrStr = string_format(Language.GetString(3555), Language.GetString(attrType + 10).."加成上限", val, val2)
                end
            end
            local attrGo = self.m_attrOneGoList[i]
            if not attrGo then
                attrGo = GameObject.Instantiate(self.m_attrItemPrefab, self.m_attrGrid1)
                table_insert(self.m_attrOneGoList, attrGo)
            end
            local attrLimitText = UIUtil.FindText(attrGo.transform, "attrLimit")
            local attrImg = UIUtil.AddComponent(UIImage, attrGo.transform, "attrBg/attrImg")
            attrLimitText.text = attrStr
            attrImg:SetAtlasSprite("ly"..i..".png", false, AtlasConfig.DynamicLoad)
        end
    end

    local baseAttrMin = wujiangMgr:ToFirstAttrData(msg.base_first_attr_min)
    local extraAttrMin = wujiangMgr:ToFirstAttrData(msg.extra_first_attr_min)
    if baseAttrMin and extraAttrMin then
        local attrNameList = CommonDefine.first_attr_name_list
        local attrStr = ""
        for i, v in pairs(attrNameList) do
            local val = baseAttrMin[v]
            local val2 = extraAttrMin[v]
            if val and val2 then
                local attrType = CommonDefine[v]
                if attrType then
                    attrStr = string_format(Language.GetString(3555), Language.GetString(attrType + 10).."加成下限", val, val2)
                end
            end
            local attrGo = self.m_attrTwoGoList[i]
            if not attrGo then
                attrGo = GameObject.Instantiate(self.m_attrItemPrefab, self.m_attrGrid2)
                table_insert(self.m_attrTwoGoList, attrGo)
            end
            local attrLimitText = UIUtil.FindText(attrGo.transform, "attrLimit")
            local attrImg = UIUtil.AddComponent(UIImage, attrGo.transform, "attrBg/attrImg")
            attrLimitText.text = attrStr
            attrImg:SetAtlasSprite("ly"..i..".png", false, AtlasConfig.DynamicLoad)
        end
    end                
end

function UIMountAttributeView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, id, level = ...

    if not id then
        return
    end

    self.m_huntId = id
    self.m_huntLevel = level or 0
    local huntCfg = ConfigUtil.GetHuntCfgByID(self.m_huntId)
    self.m_titleText.text = string_format(Language.GetString(3561), huntCfg.name, self.m_huntLevel)
    self.m_currTab = false
    self:TabChg(Tab_Attr)
    self:CheckBtnMove()
end

function UIMountAttributeView:CheckBtnMove()
    if MountMgr.UnLockHuntCount <= 1 then
        self.m_leftBtn.gameObject:SetActive(false)
        self.m_rightBtn.gameObject:SetActive(false)
    else
        self.m_leftBtn.gameObject:SetActive(true)
        self.m_rightBtn.gameObject:SetActive(true)
    end
    UIUtil.LoopMoveLocalX(self.m_leftBtn, -666, -626, 0.6)
    UIUtil.LoopMoveLocalX(self.m_rightBtn, 681, 641, 0.6)
end

function UIMountAttributeView:OnDisable()
    UIGameObjectLoader:CancelLoad(self.m_seq)
    self.m_seq = 0
    
    for _, v in ipairs(self.m_attrOneGoList) do
        GameObject.DestroyImmediate(v)
    end
    self.m_attrOneGoList = {}
    
    for _, v in ipairs(self.m_attrTwoGoList) do
        GameObject.DestroyImmediate(v)
    end
    self.m_attrTwoGoList = {}

    for _, v in ipairs(self.m_improveAttrList) do
        v:Delete()
    end
    self.m_improveAttrList = {}

    base.OnDisable(self)
end

return UIMountAttributeView