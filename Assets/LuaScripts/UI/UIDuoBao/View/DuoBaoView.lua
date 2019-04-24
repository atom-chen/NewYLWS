local SceneObjPath = TheGameIds.DuoBaoSceneObjPrefab
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local actMgr = Player:GetInstance():GetActMgr()
local duobaoItemPrefab = "UI/Prefabs/DuoBao/DuoBaoItem.prefab"
local duobaoItemClass = require "UI.UIDuoBao.View.DuoBaoItem"
local WujiangRootPath = TheGameIds.CommonWujiangRootPath
local loaderInstance = UIGameObjectLoader:GetInstance()
local GameObject = CS.UnityEngine.GameObject
local BattleEnum = BattleEnum
local Time = Time
local GameUtility = CS.GameUtility
local SplitString = CUtil.SplitString
local string_split = string.split
local UIWuJiangDetailIconItem = require "UI.UIWuJiang.View.UIWuJiangDetailIconItem"
local UIWuJiangSkillDetailView = require("UI.UIWuJiang.View.UIWuJiangSkillDetailView")
local WuJiangMgr = Player:GetInstance():GetWujiangMgr()

local DuoBaoView = BaseClass("DuoBaoView", UIBaseView)
local base = UIBaseView 

local wujiangPos = Vector3.New(-16, 133, 41.5)
local wujiangAngle = Vector3.New(0, 198.2, 0)
local petOffset = 1.5

local cameraPos = Vector3.New(-15.7, 134.3, 39.25)
local cameraAngle = Vector3.New(2, 11.1, 0)
local cameraFOV = 40

local INTERVAL = 5

function DuoBaoView:OnCreate()
    base.OnCreate(self) 
    self.m_actID = 0
    self.m_wujiangID = 0
    self.m_awardList = nil
    self.m_recordList = nil

    self.m_awardItemList = {}
    self.m_activeAwardItemList = {}
    self.m_randomNumList = {} 
    self.m_beginDraw = false
    self.m_animateTime = 0

    self.m_tempIndex = 1
    self.m_tempTime = 0
    self.m_tempCtrl = true 

    self.m_roleBgGo = nil
    self.m_sceneSeq =  0 
    self.m_roleTr = nil 

    self:InitView()
    self:HandleClick()
end

function DuoBaoView:InitView()
    self.m_closeBtnTr,
    self.m_gridContainerTr,
    self.m_detailBtnTr,
    self.m_drawBtnTr,
    self.m_skillAndQYRootTr,
    self.m_skillItemPrefabTr = UIUtil.GetChildTransforms(self.transform, {
        "panel/CloseBtn",
        "Panel/RightPanel/GridContainer",
        "Panel/RightPanel/DetailContainer/DetailBtn",
        "Panel/RightPanel/DrawBtn",
        "panel/SkillQYCon/SkillAndQingYuanRoot",
        "SkillItemPrefab",
    })

    self.m_wujiangRareImg = UIUtil.AddComponent(UIImage, self,  "Panel/LeftPanel/NameContainer/RareImg", AtlasConfig.DynamicLoad)

    self.m_firstDetailDesTxt,
    self.m_drawBtnTxt,
    self.m_drawLeftCountTxt,
    self.m_totalValueTxt,
    self.m_actTimeDesTxt,
    self.m_actTimeTxt,
    self.m_actDesTxt,
    self.m_actDetailDesTxt,
    self.m_wujiangNameTxt = UIUtil.GetChildTexts(self.transform, {   
        "Panel/RightPanel/DetailContainer/DetailDes",
        "Panel/RightPanel/DrawBtn/Text",
        "Panel/RightPanel/DrawLeftCountTxt",
        "Panel/RightPanel/TotalValueTxt",
        "Panel/LeftPanel/Container/ActTimeDesTxt",
        "Panel/LeftPanel/Container/ActTimeTxt",
        "Panel/LeftPanel/Container/ActDesTxt",
        "Panel/LeftPanel/Container/ActDetailDesTxt",
        "Panel/LeftPanel/NameContainer/NameTxt", 
    })

    self.m_drawBtnTxt.text = Language.GetString(3851)
    self.m_actTimeDesTxt.text = Language.GetString(3857)
    self.m_actDesTxt.text = Language.GetString(3858)  
end

function DuoBaoView:OnEnable(...)
    base.OnEnable(self, ...)   
    local _, panelData, go = ...
    if not panelData then
        return
    end
    self.m_roleBgGo = go 

    self.m_actID = panelData.act_id
    
    -- self:CreateRoleContainer() 
    self.m_isShowOffPlayed = false
    self:CreateSceneObj()
    
    actMgr:ReqDuoBaoInterface(self.m_actID)

    local actStartTime = os.date("%Y.%m.%d", panelData.start_time)
    local actEndTime = os.date("%Y.%m.%d", panelData.end_time)
    local startTimeSplit = SplitString(actStartTime, '.')
    local endTimeSplit = SplitString(actEndTime, '.') 
    if startTimeSplit[3] >= endTimeSplit[3] then
        self.m_actTimeTxt.text = string.format(Language.GetString(3862), actStartTime)  
    else
        self.m_actTimeTxt.text = string.format(Language.GetString(3860), actStartTime, actEndTime)  
    end  

    self.m_actDetailDesTxt.text = panelData.act_content
end 

function DuoBaoView:OnInterfaceInfo(interfaceInfo) 
    self:UpdateData(interfaceInfo)
end

function DuoBaoView:OnAwardInfo(awardInfo)
    if not awardInfo then
        return
    end

    local tagIndex = awardInfo.tag_index 
    for i = 1,#self.m_awardItemList do 
        local index = self.m_awardItemList[i]:GetTagIndex()
        if index == tagIndex then
            self.m_awardItemList[i]:SetMaskImgActive(true)
            break
        end
    end

    local awardList = awardInfo.award_list
    local uiData = {
        titleMsg = Language.GetString(62),
        openType = 1,
        awardDataList = awardList,
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
end

function DuoBaoView:UpdateData(interfaceInfo)
    local firstRecordData = interfaceInfo.duobao_record_list[1]
    if firstRecordData then
        local time = os.date("%Y.%m.%d %H:%M", firstRecordData.time)
        local itemCfg = ConfigUtil.GetItemCfgByID(firstRecordData.item_id) 
        local itemName = ""
        if itemCfg then
            itemName = itemCfg.sName
        end
        self.m_firstDetailDesTxt.text = string.format(Language.GetString(3854), time, firstRecordData.user_name, itemName, firstRecordData.count)
    end
    self.m_drawLeftCountTxt.text = string.format(Language.GetString(3856), interfaceInfo.left_times)
    local leftTimes = interfaceInfo.left_times
    if leftTimes > 0 then
        local onClick = UILogicUtil.BindClick(self, self.OnClick)
        UIUtil.AddClickEvent(self.m_drawBtnTr.gameObject, onClick) 
        GameUtility.SetUIGray(self.m_drawBtnTr.gameObject, false) 
    else
        UIUtil.RemoveClickEvent(self.m_drawBtnTr.gameObject)  
        GameUtility.SetUIGray(self.m_drawBtnTr.gameObject, true) 
    end

    self.m_totalValueTxt.text = string.format(Language.GetString(3855), interfaceInfo.total_charge)  

    self.m_wujiangID = interfaceInfo.wujiang_id

    self.m_awardList = interfaceInfo.duobao_award_list

    self.m_recordList = interfaceInfo.duobao_record_list

    self:CreateItem()
    ----------------------------- 
    self.m_wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_wujiangID)
    if self.m_wujiangCfg then   
        UILogicUtil.SetWuJiangRareImage(self.m_wujiangRareImg, self.m_wujiangCfg.rare)
        self.m_wujiangNameTxt.text = self.m_wujiangCfg.sName
        self:CreateWuJiang()  
        self:UpdateSkillAndQingYuan()
    end 
end

function DuoBaoView:CreateItem()
    local itemCount = #self.m_awardList

    if #self.m_awardItemList <= 0 then
        local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(seq, duobaoItemPrefab, itemCount, function(objs)
            seq = 0
            if objs then
                for i = 1, #objs do
                    local duobaoItem = duobaoItemClass.New(objs[i], self.m_gridContainerTr, duobaoItemPrefab)
                    duobaoItem:UpdateData(self.m_awardList[i])

                    table.insert(self.m_awardItemList, duobaoItem) 
                end 
            end
        end)
    else 
        for i = 1,#self.m_awardItemList do
            self.m_awardItemList[i]:UpdateData(self.m_awardList[i])
        end
    end  
end

-- function DuoBaoView:CreateRoleContainer()
    -- if IsNull(self.m_roleContainerGo) then
    --     self.m_roleContainerGo = GameObject("RoleContainer")
    --     self.m_roleContainerTrans = self.m_roleContainerGo.transform


    --     self.m_sceneSeq = loaderInstance:PrepareOneSeq()
    --     loaderInstance:GetGameObject(self.m_sceneSeq, WujiangRootPath, function(go)
    --         self.m_sceneSeq = 0
    --         if not IsNull(go) then 
    --             self.m_roleBgGo = go
    --             self.m_roleContainerTrans:SetParent(self.m_roleBgGo.transform)
    --             self.m_roleCameraTrans = self.m_roleBgGo.transform:Find("RoleCamera")
    --         end

    --         self.m_roleCam = UIUtil.FindComponent(self.m_roleCameraTrans, typeof(CS.UnityEngine.Camera))  
    --     end)
    -- end 
    -- self.m_cacheCameraPos = self.m_roleCameraTrans.localPosition
    -- self.m_cacheCameraAngle = self.m_roleCameraTrans.localEulerAngles
    -- self.m_cacheCameraFOV = self.m_roleCam.fieldOfView
    -- self.m_roleCameraTrans.localPosition = cameraPos
    -- self.m_roleCameraTrans.localEulerAngles = cameraAngle
    -- self.m_roleCam.fieldOfView = cameraFOV
-- end  

function DuoBaoView:CreateSceneObj() 
    if not IsNull(self.m_roleBgGo) then
        local pos1 = UIUtil.GetChildTransforms(self.m_roleBgGo.transform, { 
            "p1",
        })

        self.m_roleTr = pos1
    else
        self.m_sceneSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_sceneSeq, SceneObjPath, function(go)
            self.m_sceneSeq = 0
            if not IsNull(go) then
                self.m_roleBgGo = go 

                local pos1 = UIUtil.GetChildTransforms(self.m_roleBgGo.transform, { 
                    "p1",
                }) 

                self.m_roleTr = pos1
            end
        end)  
    end
end

function DuoBaoView:CreateWuJiang() 
    local weaponLevel = UILogicUtil.GetWeaponMaxLevel(self.m_wujiangID)

    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end
    self.m_seq = ActorShowLoader:GetInstance():PrepareOneSeq()
    ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_seq, ActorShowLoader.MakeParam(self.m_wujiangID, weaponLevel), self.m_roleTr, function(actorShow)
        self.m_seq = 0
        self.m_actorShow = actorShow

        self.m_actorShow:SetPosition(Vector3.New(100000, 100000, 100000))

        local function loadCallBack()
            if self.m_actorShow:GetPetID() > 0 then 
            end

            self.m_actorShow:SetPosition(Vector3.zero) 
            self.m_actorShow:SetEulerAngles(Vector3.New(0, 0, 0))
            self.m_actorShow:SetLocalScale(Vector3.New(3.5, 3.5, 3.5))
        end 
 
        if self.m_isShowOffPlayed then 
            self.m_actorShow:PlayAnim(BattleEnum.ANIM_IDLE)

            loadCallBack()
        else
            self.m_actorShow:ShowShowoffEffect(loadCallBack)
            self.m_isShowOffPlayed = true
        end 
    end)
end

function DuoBaoView:UpdateSkillAndQingYuan()
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

function DuoBaoView:ShowSkillDetail(isShow, skillID, iconIndex, isQingYuan) 
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

function DuoBaoView:CheckSelectSkillIcon(isShow, iconIndex) 
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

function DuoBaoView:OnClick(go, x, y)
    if go.name == "CloseBtn" then
        self:CloseSelf()
        return
    elseif go.name == "DrawBtn" then
        if self.m_beginDraw then
            return
        end
        self:HandleDrawBtnClick()
    elseif go.name == "DetailBtn" then 
        UIManagerInst:OpenWindow(UIWindowNames.UIDuoBaoRecord, self.m_recordList)
    end
end

function DuoBaoView:HandleDrawBtnClick() 
    for i = 1,#self.m_awardItemList do 
        local item = self.m_awardItemList[i]
        item:SetMaskImgActive(false)
        local hasCount = item:GetHasCount()
        if hasCount then
            table.insert(self.m_activeAwardItemList, item)
        end
    end

    if #self.m_activeAwardItemList <= 0 then
        --数量小于等于0，代表没有可抽奖的物品的了
        UILogicUtil.FloatAlert(ErrorCode.GetString(751))
        return
    end
    
    if #self.m_activeAwardItemList <= 1 then
        --如果item的数量小于一个，则直接发起请求
        actMgr:ReqDuoBao(self.m_actID) 
        Player:GetInstance():GetUserMgr():InsertServerNoticeByType(5)
        return
    end 
    for i = 1,#self.m_activeAwardItemList do
        self.m_activeAwardItemList[i]:SetMaskImgActive(false)
    end
   
    local itemNum = #self.m_activeAwardItemList  
    self.m_randomNumList = self:CreateRanNum(itemNum)
    self.m_tempIndex = 1
    self.m_tempTime = 0
    self.m_tempCtrl = true    

    self.m_beginDraw = true
end  

function DuoBaoView:FillNum(maxNum)
    local tab = {}
    if not maxNum or type(maxNum) ~= "number" or not tostring(maxNum) then
        return tab
    end
    
    for i = 1, maxNum do
        table.insert(tab, i)
    end
    return tab
end

function DuoBaoView:CreateRanNum(maxNum)
    local tempTab = self:FillNum(maxNum)
    local tab = {}
    math.randomseed(os.time())
    local ran = 0
    local flagIndex = maxNum
    local count = 1
    while flagIndex > 0 do
        ran = math.random(1, maxNum - count + 1)
        table.insert(tab, tempTab[ran])
        table.remove(tempTab, ran)
        flagIndex = flagIndex - 1
        count = count + 1
    end
    return tab
end

function DuoBaoView:Update() 
    if self.m_beginDraw then
        local realIndex = self.m_randomNumList[self.m_tempIndex] 
        if self.m_tempCtrl then 
            self.m_activeAwardItemList[realIndex]:SetMaskImgActive(true)
            self.m_tempCtrl = false
        end
        if not self.m_tempCtrl then
            self.m_tempTime = self.m_tempTime + Time.deltaTime
            if self.m_tempTime >= 0.2 then
                self.m_activeAwardItemList[realIndex]:SetMaskImgActive(false)
                self.m_tempIndex = self.m_tempIndex + 1
                if self.m_tempIndex > #self.m_randomNumList then
                    self.m_tempIndex = 1
                end
                self.m_tempCtrl = true
                self.m_tempTime = 0
            end
        end

        self.m_animateTime = self.m_animateTime + Time.deltaTime
        if self.m_animateTime >= INTERVAL then
            actMgr:ReqDuoBao(self.m_actID)  
            Player:GetInstance():GetUserMgr():InsertServerNoticeByType(5) 
            self.m_beginDraw = false
            self.m_animateTime = 0
            for i = 1,#self.m_activeAwardItemList do
                self.m_activeAwardItemList[i]:SetMaskImgActive(false)
            end
            self.m_tempIndex = 1
            self.m_tempTime = 0
            self.m_tempCtrl = true 
        end
    end
end

function DuoBaoView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick) 

    UIUtil.AddClickEvent(self.m_closeBtnTr.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0)) 
    UIUtil.AddClickEvent(self.m_detailBtnTr.gameObject, onClick)  
end

function DuoBaoView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_RSP_DUOBAO_INTERFACE, self.OnInterfaceInfo) 
    self:AddUIListener(UIMessageNames.MN_RSP_DUOBAO, self.OnAwardInfo)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_SKILL_DETAIL_SHOW, self.ShowSkillDetail) 
end

function DuoBaoView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_RSP_DUOBAO_INTERFACE, self.OnInterfaceInfo) 
    self:RemoveUIListener(UIMessageNames.MN_RSP_DUOBAO, self.OnAwardInfo) 
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_SKILL_DETAIL_SHOW, self.ShowSkillDetail) 
end

-- function DuoBaoView:DestroyRoleContainer()
    -- if not self.m_roleCameraTrans then
    --     return
    -- end

    -- self.m_roleCameraTrans.localPosition = self.m_cacheCameraPos
    -- self.m_roleCameraTrans.localEulerAngles = self.m_cacheCameraAngle
    -- self.m_roleCam.fieldOfView = self.m_cacheCameraFOV
    
    -- if not IsNull(self.m_roleContainerGo) then
    --     GameObject.DestroyImmediate(self.m_roleContainerGo)
    -- end

    -- UIGameObjectLoader:CancelLoad(self.m_sceneSeq)
    -- self.m_sceneSeq = 0

    -- self.m_roleContainerGo = nil
    -- self.m_roleContainerTrans = nil
    -- self.m_roleCameraTrans = nil

    -- if not IsNull(self.m_roleBgGo) then
    --     UIGameObjectLoader:GetInstance():RecycleGameObject(WujiangRootPath, self.m_roleBgGo)
    --     self.m_roleBgGo = nil
    -- end 
-- end

function DuoBaoView:RecycleObj()
    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end
    ActorShowLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0 
end

function DuoBaoView:OnDisable()
    self:RecycleObj()
    -- self:DestroyRoleContainer() 

    if not IsNull(self.m_roleBgGo) then
        UIGameObjectLoaderInst:RecycleGameObject(SceneObjPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
    end  

    if #self.m_awardItemList > 0 then
        for i = 1,  #self.m_awardItemList do
            self.m_awardItemList[i]:Delete()
            self.m_awardItemList[i] = nil       
        end
    end
    self.m_awardItemList = {}
    self.m_activeAwardItemList = {}
    self.m_randomNumList = {} 

    self.m_beginDraw = false
    self.m_animateTime = 0

    base.OnDisable(self)
end


function DuoBaoView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtnTr.gameObject)   
    UIUtil.RemoveClickEvent(self.m_detailBtnTr.gameObject)  
    UIUtil.RemoveClickEvent(self.m_drawBtnTr.gameObject)  

    base.OnDestroy(self)
end


return DuoBaoView














