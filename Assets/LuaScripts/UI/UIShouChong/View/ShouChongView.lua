local GameObject = CS.UnityEngine.GameObject 
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance() 
local ShouChongItemClass = require "UI.UIShouChong.View.ShouChongItem"
local ShouChongItemPrefab = "UI/Prefabs/ShouChong/ShouChongItem.prefab"
local shopMgr = Player:GetInstance():GetShopMgr()
local LoopScrollView = LoopScrowView
local UIWuJiangDetailIconItem = require "UI.UIWuJiang.View.UIWuJiangDetailIconItem"
local UIWuJiangSkillDetailView = require("UI.UIWuJiang.View.UIWuJiangSkillDetailView")
local UIWuJiangQingYuanView = require("UI.UIWuJiang.View.UIWuJiangQingYuanView") 
local BattleEnum = BattleEnum
local WujiangRootPath = TheGameIds.CommonWujiangRootPath
local loaderInstance = UIGameObjectLoader:GetInstance()

local ShouChongView = BaseClass("ShouChongView", UIBaseView)
local base = UIBaseView 

local CamOffset = Vector3.New(0, 0.5, 0) 
local TEMP_WUJIANG_ID = 1002

local wujiangPos = Vector3.New(-16, 133, 41.5)
local wujiangAngle = Vector3.New(0, 198.2, 0)
local petOffset = 1.5

local cameraPos = Vector3.New(-15.7, 134.3, 39.25)
local cameraAngle = Vector3.New(2, 11.1, 0)
local cameraFOV = 40


function ShouChongView:OnCreate()
    base.OnCreate(self) 
    self.m_itemList = {}
    self.m_posX = 0

    self.m_skillDetailItem = nil
    self.m_qingyuanView = nil
    self.m_cacheCameraPos = nil
    self.m_cacheCameraAngle = nil
    self.m_cacheCameraFOV = 0

    self.m_awardWuJiangID = 0
    self.m_sceneSeq = 0  
    
    self.m_draging = false
    self.m_startDraging = false
    
    self:InitView()
    self:HandleClick() 
    self:HandleDrag()
end

function ShouChongView:InitView()
    local itemOneTr, itemTwoTr

    self.m_closeBtnTr,
    self.m_goTopUpBtnTr, 
    self.m_actorAnchorTr,
    self.m_skillAndQYRootTr,
    self.m_actorBtnTr,
    self.m_skillItemPrefabTr,
    itemOneTr,
    itemTwoTr  = UIUtil.GetChildTransforms(self.transform, {
        "panel/CloseBtn",
        "Panel/RightPanel/GoTopUpBtn", 
        "Panel/LeftPanel/ActorAnchor",
        "panel/SkillQYCon/SkillAndQingYuanRoot",
        "Panel/LeftPanel/ActorBtn",
        "SkillItemPrefab", 
        "Panel/RightPanel/ItemOne", 
        "Panel/RightPanel/ItemTwo", 
    }) 

    self.m_goTopUpBtnTxt,
    self.m_wujiangNameTxt = UIUtil.GetChildTexts(self.transform, {  
        "Panel/RightPanel/GoTopUpBtn/Text",
        "Panel/LeftPanel/Bg/Container/NameTxt", 
    })

    self.m_wujiangRareImg = UIUtil.AddComponent(UIImage, self,  "Panel/LeftPanel/Bg/Container/RareImg", AtlasConfig.DynamicLoad) 
    self.m_goTopUpBtnTxt.text = Language.GetString(3800) 
    self.m_itemTrList = {itemOneTr, itemTwoTr}
end

function ShouChongView:OnEnable(...)
    base.OnEnable(self, ...)  

    self:CreateRoleContainer() 
    
    Player:GetInstance():GetShopMgr():ReqRechargeAwardInfo()
end

function ShouChongView:OnAwardInfo(awardInfoList)
    if not awardInfoList then
        return
    end

    self.m_awardInfoList = awardInfoList 
    self:UpdateData()
end

function ShouChongView:OnAwardInfoChg(awardInfoList)
    if not awardInfoList then
        return
    end

    self.m_awardInfoList = awardInfoList 
    self:UpdateData()
end

function ShouChongView:OnGetAward(data)
     for i = 1, #self.m_itemList do
        local takeType = self.m_itemList[i]:GetTakeAwardType()
        if takeType == data.take_type then 
            self.m_itemList[i]:SetStatus(data.btn_status)
        end
     end
     local awardList = data.award_list
     local uiData = {
        titleMsg = Language.GetString(62),
        openType = 1,
        awardDataList = awardList,
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
end

function  ShouChongView:SetAwardWuJiangID()
    local chargeAwardList = self.m_awardInfoList.charge_award_list
    local oneAwardInfo = nil
    if chargeAwardList then
        oneAwardInfo = chargeAwardList[1]
    end
    local isWuJiang = false
    local wujiangID = 0
    if oneAwardInfo then
        local awardList = oneAwardInfo.award_list
        for i = 1, #awardList do
            isWuJiang = Utils.IsWujiang(awardList[i].item_id)
            if isWuJiang then
                wujiangID = awardList[i].item_id 
                break
            end
        end 
    end 
    if isWuJiang then
        self.m_awardWuJiangID = wujiangID
    else
        self.m_awardWuJiangID = TEMP_WUJIANG_ID
    end
end

function ShouChongView:UpdateData() 
    self:CreateItem()
    self:SetAwardWuJiangID()
    
    self.m_isShowOffPlayed = false
    self.m_wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_awardWuJiangID)
    if self.m_wujiangCfg then 
        UILogicUtil.SetWuJiangRareImage(self.m_wujiangRareImg, self.m_wujiangCfg.rare)
        self.m_wujiangNameTxt.text = self.m_wujiangCfg.sName
        self:CreateWuJiang() 
        self:UpdateSkillAndQingYuan()
    end 
end

function ShouChongView:CreateItem() 
    local chargeAwardList = self.m_awardInfoList.charge_award_list
    if not chargeAwardList then
        return
    end
    if #self.m_itemList <= 0 then
        local seq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(seq, ShouChongItemPrefab, #chargeAwardList, function(objs) 
            if objs then
                for i = 1, #objs do
                    local item = ShouChongItemClass.New(objs[i], self.m_itemTrList[i], ShouChongItemPrefab)
                    table.insert(self.m_itemList, item)
                    item:UpdateData(chargeAwardList[i], self.m_awardWuJiangID)
                end
            end
             
        end)
    else 
        for i = 1, #self.m_itemList do
            self.m_itemList[i]:UpdateData(chargeAwardList[i], self.m_awardWuJiangID)
        end
    end
end  

function ShouChongView:CreateRoleContainer()
    if IsNull(self.m_roleContainerGo) then
        self.m_roleContainerGo = GameObject("RoleContainer")
        self.m_roleContainerTrans = self.m_roleContainerGo.transform


        self.m_sceneSeq = loaderInstance:PrepareOneSeq()
        loaderInstance:GetGameObject(self.m_sceneSeq, WujiangRootPath, function(go)
            self.m_sceneSeq = 0
            if not IsNull(go) then
                self.m_roleBgGo = go
                self.m_roleContainerTrans:SetParent(self.m_roleBgGo.transform)
                self.m_roleCameraTrans = self.m_roleBgGo.transform:Find("RoleCamera")
            end

            self.m_roleCam = UIUtil.FindComponent(self.m_roleCameraTrans, typeof(CS.UnityEngine.Camera))  
        end)
    end 
    self.m_cacheCameraPos = self.m_roleCameraTrans.localPosition
    self.m_cacheCameraAngle = self.m_roleCameraTrans.localEulerAngles
    self.m_cacheCameraFOV = self.m_roleCam.fieldOfView
    self.m_roleCameraTrans.localPosition = cameraPos
    self.m_roleCameraTrans.localEulerAngles = cameraAngle
    self.m_roleCam.fieldOfView = cameraFOV
end 

function ShouChongView:DestroyRoleContainer()
    self.m_roleCameraTrans.localPosition = self.m_cacheCameraPos
    self.m_roleCameraTrans.localEulerAngles = self.m_cacheCameraAngle
    self.m_roleCam.fieldOfView = self.m_cacheCameraFOV
    
    if not IsNull(self.m_roleContainerGo) then
        GameObject.DestroyImmediate(self.m_roleContainerGo)
    end

    UIGameObjectLoader:CancelLoad(self.m_sceneSeq)
    self.m_sceneSeq = 0

    self.m_roleContainerGo = nil
    self.m_roleContainerTrans = nil
    self.m_roleCameraTrans = nil

    if not IsNull(self.m_roleBgGo) then
        UIGameObjectLoader:GetInstance():RecycleGameObject(WujiangRootPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
    end
end  

function ShouChongView:CreateWuJiang() 
    local weaponLevel = UILogicUtil.GetWeaponMaxLevel(self.m_awardWuJiangID)

    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end
    self.m_seq = ActorShowLoader:GetInstance():PrepareOneSeq()
    ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_seq, ActorShowLoader.MakeParam(self.m_awardWuJiangID, weaponLevel), self.m_roleContainerTrans, function(actorShow)
        self.m_seq = 0
        self.m_actorShow = actorShow

        self.m_actorShow:SetPosition(Vector3.New(100000, 100000, 100000))

        local function loadCallBack()
 
            if self.m_actorShow:GetPetID() > 0 then
                self.m_actorShow:SetPosition(wujiangPos)
            else
                self.m_actorShow:SetPosition(wujiangPos)
            end
            
            self.m_actorShow:SetEulerAngles(Vector3.New(0, 198.2, 0))
        
             --正在播showOff,则播放出场音效
            if not self.m_isShowOffPlayed then
                self.m_actorShow:PlayStageAudio()
            end 
        end 
        if self.m_isShowOffPlayed then
            self.m_isShowOffPlayed = false
            self.m_actorShow:PlayAnim(BattleEnum.ANIM_IDLE)

            loadCallBack()
        else
            self.m_actorShow:ShowShowoffEffect(loadCallBack)
        end 
    end)
end

function ShouChongView:UpdateSkillAndQingYuan()
    local skill_list = self.m_wujiangCfg.skillList
    if not skill_list then
        return
    end

    local newSkillList = {}
    for i = 1, #skill_list do
        local oneSkill = {
            id = skill_list[i],
            skillLevel = 1,
        }
        table.insert(newSkillList, oneSkill)
    end
     
    local count = #newSkillList + 1
    if not self.m_skill_qingyuan_iconList then
        self.m_skill_qingyuan_iconList = {}
    end
    for i = 1, 3 do
        local iconItem = self.m_skill_qingyuan_iconList[i]
        if i <= count then
            if not iconItem then
                local go = GameObject.Instantiate(self.m_skillItemPrefabTr.gameObject)
                if not IsNull(go) then
                   local iconItem  = UIWuJiangDetailIconItem.New(go, self.m_skillAndQYRootTr)
                   table.insert(self.m_skill_qingyuan_iconList, iconItem)
                end
            end
        else
            if iconItem then
                table.remove(self.m_skill_qingyuan_iconList, i)
                iconItem:Delete()
            end
        end
    end
    local function ClickSkillItem(iconItem)
        if iconItem then 
            local iconIndex = iconItem:GetIconIndex() 
            self:ShowSkillDetail(true, iconItem:GetSkillID(), iconIndex, iconIndex == 4)
        end
    end
    for i = 1, #self.m_skill_qingyuan_iconList do
        if self.m_skill_qingyuan_iconList[i] then
            if i <= #newSkillList then
                self.m_skill_qingyuan_iconList[i]:SetData(newSkillList[i], nil, 0, i, ClickSkillItem)
            end

            self.m_skill_qingyuan_iconList[i]:SetSelect(false)
        end
    end

end

function ShouChongView:HandleDrag()
    local function DragBegin(go, x, y)
        self.m_startDraging = false
        self.m_draging = false
    end

    local function DragEnd(go, x, y)
        self.m_startDraging = false
        self.m_draging = false
    end

    local function Drag(go, x, y)
        if not self.m_startDraging then
            self.m_startDraging = true

            if x then
                self.m_posX = x
            end
            return
        end

        self.m_draging = true

        if x and self.m_posX then
            if self.m_actorShow then
                local deltaX = x - self.m_posX
                if deltaX > 0 then
                    self.m_actorShow:RolateUp(-12)
                else 
                    self.m_actorShow:RolateUp(12)
                end
            end

            self.m_posX = x 
        end
    end
   
    UIUtil.AddDragBeginEvent(self.m_actorBtnTr.gameObject, DragBegin)
    UIUtil.AddDragEndEvent(self.m_actorBtnTr.gameObject, DragEnd)
    UIUtil.AddDragEvent(self.m_actorBtnTr.gameObject, Drag)
end

function ShouChongView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_closeBtnTr.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_goTopUpBtnTr.gameObject, onClick)
end

function ShouChongView:OnClick(go, x, y)
    if go.name == "CloseBtn" then
        self:CloseSelf()
        UIManagerInst:OpenWindow(UIWindowNames.UIMain)
    elseif go.name == "GoTopUpBtn" then 
        UILogicUtil.SysShowUI(SysIDs.SHANG_CHENG)
    end
end

function ShouChongView:ShowSkillDetail(isShow, skillID, iconIndex, isQingYuan) 
    isQingYuan = false
    if isShow then 
        if isQingYuan then
            if not self.m_qingyuanView then  
                self.m_qingyuanView = UIWuJiangQingYuanView.New(self.m_qingyuanPrefabTr.gameObject, nil, nil)  
            end
        else
            if not self.m_skillDetailItem then
                self.m_skillDetailItem = UIWuJiangSkillDetailView.New(self.gameObject, "SkillDetail")
                self.m_skillDetailItem:OnCreate() 
            end
        end 
        if isQingYuan then  
            if self.m_skillDetailItem then
                self.m_skillDetailItem:SetActive(false)
            end 
           
            local curWuJiangData = {
                id = self.m_awardWuJiangID, 
            }
            self.m_qingyuanView:RemoveAllItemClickEvent(true)
            self.m_qingyuanView:SetData(curWuJiangData)
            self.m_qingyuanView:SetActive(true) 
        else
            if self.m_qingyuanView then
                self.m_qingyuanView:SetActive(false)
            end
            local skillList = self.m_wujiangCfg.skillList
            local newSkillList = {}
            for i = 1, #skillList do
                local oneSkill = {
                    id = skillList[i],
                    skillLevel = 1,
                }
                table.insert(newSkillList, oneSkill)
            end
            local wujiangData = {
                skill_list = newSkillList,
            }
            self.m_skillDetailItem:SetActive(true, -1, skillID, wujiangData)
        end
       
        self:CheckSelectSkillIcon(true, iconIndex)
    else 
        if self.m_skillDetailItem then
            self.m_skillDetailItem:SetActive(false)
        end
        if self.m_qingyuanView then
            self.m_qingyuanView:SetActive(false)
        end

        self:CheckSelectSkillIcon(false)
    end
end

function ShouChongView:CheckSelectSkillIcon(isShow, iconIndex) 
    if self.m_skill_qingyuan_iconList then
        for i = 1, #self.m_skill_qingyuan_iconList do
            if self.m_skill_qingyuan_iconList[i] then
                local isSelect = false
                
                if isShow then
                    isSelect = iconIndex == self.m_skill_qingyuan_iconList[i].iconIndex
                end
                self.m_skill_qingyuan_iconList[i]:SetSelect(isSelect)
            end
        end
    end
end 

function ShouChongView:OnAddListener()
	base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_SHOU_CHONG_GET_AWARD, self.OnGetAward) 
    self:AddUIListener(UIMessageNames.MN_WUJIANG_SKILL_DETAIL_SHOW, self.ShowSkillDetail) 
    self:AddUIListener(UIMessageNames.MN_RSP_SHOUCHONG_AWARD_INFO, self.OnAwardInfo) 
    self:AddUIListener(UIMessageNames.MN_NTF_SHOUCHONG_AWARD_INFO, self.OnAwardInfoChg) 
end

function ShouChongView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_SHOU_CHONG_GET_AWARD, self.OnGetAward) 
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_SKILL_DETAIL_SHOW, self.ShowSkillDetail) 
    self:RemoveUIListener(UIMessageNames.MN_RSP_SHOUCHONG_AWARD_INFO, self.OnAwardInfo) 
    self:RemoveUIListener(UIMessageNames.MN_NTF_SHOUCHONG_AWARD_INFO, self.OnAwardInfoChg) 
end

function ShouChongView:RecycleObj()
    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end
    ActorShowLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0
    self.m_petSeq = 0
end

function ShouChongView:OnDisable()
    self:RecycleObj() 
    self:DestroyRoleContainer()

    if self.m_skill_qingyuan_iconList then
        for i, v in ipairs(self.m_skill_qingyuan_iconList) do
            v:Delete()
        end
        self.m_skill_qingyuan_iconList = nil
    end
   
    base.OnDisable(self)
end

function ShouChongView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtnTr.gameObject)
    UIUtil.RemoveClickEvent(self.m_goTopUpBtnTr.gameObject)
    UIUtil.RemoveDragEvent(self.m_actorBtnTr.gameObject)

    base.OnDestroy(self)
end


return ShouChongView




