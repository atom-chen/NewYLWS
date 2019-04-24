
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local QianYuanWujiangItemPrefab = "UI/Prefabs/WuJiang/QingYuan/QingYuanWujiangItem.prefab"
local QianYuanWujiangItemClass = require("UI.UIWuJiang.View.QingYuanWujiangItem")
local table_insert = table.insert
local ConfigUtil = ConfigUtil
local wujiangMgr = Player:GetInstance():GetWujiangMgr()

local UIWuJiangQingYuanView = BaseClass("UIWuJiangQingYuanView", UIBaseItem)
local base = UIBaseItem

function UIWuJiangQingYuanView:OnCreate()
    base.OnCreate(self)
    self.m_qyWujiangItemList = {}
    self.m_qyWujiangItemSeq = 0

    self.m_curSrcWujiangID = 0 
    self.m_localIntimacyCfg = {}

    self.m_removeAllItemClickEvent = false 
  
    self:InitView()
    self:HandleClick()
end

function UIWuJiangQingYuanView:InitView()
    self.m_backBtnTr, 
    self.m_upItemContainerTr,
    self.m_upLeftTr,
    self.m_upRightTr,
    self.m_downLeftTr,
    self.m_downRightTr =  UIUtil.GetChildTransforms(self.transform, { 
        "backBtn",  
        "Panel/OtherIcon/UpTwoItemContainer",
        "Panel/OtherIcon/UpTwoItemContainer/UpLeft",
        "Panel/OtherIcon/UpTwoItemContainer/UpRight",
        "Panel/OtherIcon/DownTwoItemContainer/DownLeft",
        "Panel/OtherIcon/DownTwoItemContainer/DownRight",
    })

    self.m_myFrameImg = UIUtil.AddComponent(UIImage, self, "Panel/MyIcon/ItemBg/Frame", AtlasConfig.DynamicLoad)
    self.m_myIconImg = UIUtil.AddComponent(UIImage, self, "Panel/MyIcon/ItemBg/HeadIcon", AtlasConfig.RoleIcon)

    self.m_titleTxt = UIUtil.GetChildTexts(self.transform, { 
        "Panel/TitleBg/TitleTxt",
    })

    self.m_titleTxt.text = Language.GetString(3650)
end

function UIWuJiangQingYuanView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtnTr.gameObject, onClick) 
end

function UIWuJiangQingYuanView:OnClick(go,x,y) 
    local goName = go.name 
    if goName == "backBtn" then
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_SKILL_DETAIL_SHOW, false)
    end 
end  

function UIWuJiangQingYuanView:SetData(curWujiangData)
    if not curWujiangData then
        return
    end
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(curWujiangData.id)
    self.m_curSrcWujiangID = wujiangCfg.id 

    self:UpdateData()
end 

function UIWuJiangQingYuanView:UpdateData() 
    local srcWujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_curSrcWujiangID) 

    if not srcWujiangCfg then
        return
    end
    UILogicUtil.SetWuJiangFrame(self.m_myFrameImg, srcWujiangCfg.rare)
    self.m_myIconImg:SetAtlasSprite(srcWujiangCfg.sIcon)
    
    self.m_localIntimacyCfg = wujiangMgr:GetLocalIntimacyCfg(self.m_curSrcWujiangID) 
    if not self.m_localIntimacyCfg then
        return
    end
    self:CreateQingYuanWujiangItem()

    if self.m_removeAllItemClickEvent then
        for i = 1, #self.m_qyWujiangItemList do
            self.m_qyWujiangItemList[i]:SetCanNotClick(false)
        end
    end
end 

function UIWuJiangQingYuanView:CreateQingYuanWujiangItem()
    if #self.m_qyWujiangItemList > 0 then
        for i = 1, #self.m_qyWujiangItemList do
            self.m_qyWujiangItemList[i]:UpdateData(self.m_localIntimacyCfg[i], self.m_curSrcWujiangID)  
        end
    else
        local itemCount = #self.m_localIntimacyCfg
        local parentTransList = self:GetItemParentsTr(itemCount) 

        self.m_qyWujiangItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_qyWujiangItemSeq, QianYuanWujiangItemPrefab,  itemCount, function(objs)
            self.m_qyWujiangItemSeq = 0
            if not objs then 
                return 
            end
            for i = 1, #objs do   
                local qyWujiangItem = QianYuanWujiangItemClass.New(objs[i], parentTransList[i], QianYuanWujiangItemPrefab) 
                qyWujiangItem:UpdateData(self.m_localIntimacyCfg[i], self.m_curSrcWujiangID)
                if self.m_removeAllItemClickEvent then
                    qyWujiangItem:SetCanNotClick(false)
                end
                table_insert(self.m_qyWujiangItemList, qyWujiangItem)
            end
        end)   
    end 
end

function UIWuJiangQingYuanView:RemoveAllItemClickEvent(isRemove)
    self.m_removeAllItemClickEvent = isRemove
end

function UIWuJiangQingYuanView:GetItemParentsTr(item_count)
    local parentTransList = {}
    self.m_upItemContainerTr.gameObject:SetActive(true)
    self.m_downRightTr.gameObject:SetActive(true)

    if item_count == 1 then
        parentTransList = {self.m_downLeftTr}
        self.m_downRightTr.gameObject:SetActive(false)
    elseif item_count <= 2 then
        parentTransList = {self.m_downLeftTr, self.m_downRightTr} 
        self.m_upItemContainerTr.gameObject:SetActive(false)
    elseif item_count == 3 then
        parentTransList = {self.m_upLeftTr, self.m_upRightTr, self.m_downLeftTr} 
        self.m_downRightTr.gameObject:SetActive(false)
    elseif item_count >= 4 then
        parentTransList = {self.m_upLeftTr, self.m_upRightTr, self.m_downLeftTr, self.m_downRightTr}
    end

    return parentTransList
end

function UIWuJiangQingYuanView:OnDisable() 
    UIGameObjectLoaderInst:CancelLoad(self.m_qyWujiangItemSeq)
    self.m_qyWujiangItemSeq = 0
    if #self.m_qyWujiangItemList > 0 then
        for _, v in ipairs(self.m_qyWujiangItemList) do
            v:Delete()
        end
    end
    self.m_qyWujiangItemList = {}

    AudioMgr:PlayAudio(105)
    base.OnDisable(self)  
end 

function UIWuJiangQingYuanView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtnTr.gameObject)
    
    base.OnDestroy(self)   
end

function UIWuJiangQingYuanView:IsQingYuan()
    return true
end 

return UIWuJiangQingYuanView

