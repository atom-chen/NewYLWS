
local table_insert = table.insert
local table_sort = table.sort
local Language = Language
local UIUtil = UIUtil
local GameObject = CS.UnityEngine.GameObject
local MountMgr = Player:GetInstance():GetMountMgr()
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local MountItem = require "UI.UIZuoQi.View.MountItem"
local mountObjPath = "UI/Prefabs/ZuoQi/MountObj.prefab"

local UIMountChoiceView = BaseClass("UIMountChoiceView", UIBaseView)
local base = UIBaseView

function UIMountChoiceView:OnCreate()
    base.OnCreate(self)
    local mountPos1, mountPos2, mountPos3 

    self.m_backBtn, self.m_mountItemPrefab, mountPos1, mountPos2, mountPos3 = UIUtil.GetChildTransforms(self.transform, {
        "Panel/backBtn",
        "mountItemPrefab",
        "mountPos1",
        "mountPos2",
        "mountPos3"
    })
    self.m_mountItemPrefab = self.m_mountItemPrefab.gameObject
    
    self.m_mountItemList = {}
    self.m_angleList = {158, 158, 158}
    self.m_mountPosList = {mountPos1, mountPos2, mountPos3}

    self.m_mountOneFromTr = false
    self.m_mountOneToTr = false
    self.m_mountTwoFromTr = false
    self.m_mountTwoToTr = false
    self.m_mountThreeFromTr = false
    self.m_mountThreeToTr = false

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
end

function UIMountChoiceView:OnClick(go)
    if go.name == "backBtn" then
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, self.winName)
        self:CloseSelf()
    end
end

function UIMountChoiceView:OnDestroy()
    
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    base.OnDestroy(self)
end

function UIMountChoiceView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_HUNT_RSP_HORSE_SHOW, self.UpdateData)
    self:AddUIListener(UIMessageNames.MN_HUNT_RSP_SELECT_HORSE, self.RspSelectHorse)
end

function UIMountChoiceView:OnRemoveListener()
    base.OnRemoveListener(self)

    self:RemoveUIListener(UIMessageNames.MN_HUNT_RSP_HORSE_SHOW, self.UpdateData)
    self:RemoveUIListener(UIMessageNames.MN_HUNT_RSP_SELECT_HORSE, self.RspSelectHorse)
end

function UIMountChoiceView:RspSelectHorse(awardList)
    if not awardList then
        return
    end

    for i, v in ipairs(self.m_mountItemList) do
        v:HideChoiceBtn()
        v:UpdateAttr()
    end
    local awardList2 = PBUtil.ParseAwardList(awardList)
    UIManagerInst:OpenWindow(UIWindowNames.UIMountChoiceSucc, awardList2)
end

function UIMountChoiceView:OnEnable(...)
    base.OnEnable(self, ...)
    self:CreateMountContainer()

    MountMgr:ReqHorseShow()
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.LieYuan_ID)
end

function UIMountChoiceView:UpdateData(mountList, randomseed)
    if not mountList then
        return 
    end

    math.randomseed(randomseed)
    local tempRandomSeed = math.random(1,999999)
    for i, v in pairs(mountList) do
        local mountItem = self.m_mountItemList[i]
        if not mountItem then
            local go = GameObject.Instantiate(self.m_mountItemPrefab)
            mountItem = MountItem.New(go, self.m_mountPosList[i])
            table_insert(self.m_mountItemList, mountItem)
            go.name = i
        end
        local realRandomSeed = tempRandomSeed % 100
        tempRandomSeed = math.floor(tempRandomSeed/100)
        if i == 1 then
            mountItem:SetData(v, realRandomSeed, self.m_angleList[i], self.m_mountOneFromTr, self.m_mountOneToTr, Bind(self, self.MountItemClick))
        elseif i == 2 then
            mountItem:SetData(v, realRandomSeed, self.m_angleList[i], self.m_mountTwoFromTr, self.m_mountTwoToTr, Bind(self, self.MountItemClick))
        elseif i == 3 then
            mountItem:SetData(v, realRandomSeed, self.m_angleList[i], self.m_mountThreeFromTr, self.m_mountThreeToTr, Bind(self, self.MountItemClick))
        end
    end
end

function UIMountChoiceView:CreateMountContainer()
    self.m_sceneSeq = UIGameObjectLoader:PrepareOneSeq()
    UIGameObjectLoader:GetGameObject(self.m_sceneSeq, mountObjPath, function(go)
        self.m_sceneSeq = 0
        if not IsNull(go) then
            self.m_mountObjGo = go
            local tr = self.m_mountObjGo.transform
            self.m_mountOneFromTr = tr:GetChild(0)
            self.m_mountOneToTr = tr:GetChild(1)
            self.m_mountTwoFromTr = tr:GetChild(2)
            self.m_mountTwoToTr = tr:GetChild(3)
            self.m_mountThreeFromTr = tr:GetChild(4)
            self.m_mountThreeToTr = tr:GetChild(5)
        end
    end)
end

function UIMountChoiceView:DestroyMountContainer()
    UIGameObjectLoader:CancelLoad(self.m_sceneSeq)
    self.m_sceneSeq = 0

    if not IsNull(self.m_mountObjGo) then
        UIGameObjectLoader:RecycleGameObject(mountObjPath, self.m_mountObjGo)
        self.m_mountObjGo = nil
    end
    self.m_mountOneFromTr = false
    self.m_mountOneToTr = false
    self.m_mountTwoFromTr = false
    self.m_mountTwoToTr = false
    self.m_mountThreeFromTr = false
    self.m_mountThreeToTr = false
end

function UIMountChoiceView:MountItemClick(mountIndex)

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "MountItemClick")
    MountMgr:ReqSelectHorse(mountIndex)
    if not Player:GetInstance():GetUserMgr():IsGuided(GuideEnum.GUIDE_LIEYUAN) then
        Player:GetInstance():GetUserMgr():ReqSetGuided(GuideEnum.GUIDE_LIEYUAN)
    end
end

function UIMountChoiceView:OnDisable()
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.Stamina_ID)
    for _, v in ipairs(self.m_mountItemList) do
        v:Delete()
    end
    self.m_mountItemList = {}

    self:DestroyMountContainer()
    base.OnDisable(self)
end

return UIMountChoiceView