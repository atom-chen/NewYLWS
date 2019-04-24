local Vector3 = Vector3
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local BattleEnum = BattleEnum
local table_insert = table.insert
local string_format = string.format
local typeRectTrans = typeof(CS.UnityEngine.RectTransform)
local yuanmenMgr = Player:GetInstance():GetYuanmenMgr()
local ConfigUtil = ConfigUtil
local YuanmenItem = BaseClass("YuanmenItem", UIBaseItem)
local base = UIBaseItem

function YuanmenItem:OnCreate()
    base.OnCreate(self)
    
    self.m_yuanmenID = -1 
    self.m_createWuJiangSeq = 0
    self.m_actorShow = nil

    self.m_roleParentTr = nil

    self.m_isPassed = false

    self:InitView()
    self:HandleClick()
end

function YuanmenItem:OnDestroy()
    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end
    if self.m_createWuJiangSeq > 0 then
        ActorShowLoader:GetInstance():CancelLoad(self.m_createWuJiangSeq)
        self.m_createWuJiangSeq = 0
    end
    self.m_roleParentTr = nil 

    if self.m_countryImg then
        self.m_countryImg:Delete()
        self.m_countryImg = nil
    end

    if self.m_evaluationImg then
        self.m_evaluationImg:Delete()
        self.m_evaluationImg = nil
    end
    UIUtil.RemoveClickEvent(self.m_modelAnchorTr.gameObject)
    UIUtil.RemoveClickEvent(self.m_challengeBtnTrans.gameObject)

    base.OnDestroy(self)
end

function YuanmenItem:InitView()
    local star1, star2, star3, star4, star5

    self.m_modelAnchorTr,
    self.m_defeatImgTrans, 
    self.m_challengeBtnTrans,
    self.m_levelScoreContainerTrans,
    self.m_levelScoreImgTrans,
    star1, star2, star3, star4, star5 = UIUtil.GetChildTransforms(self.transform, {
         "modelAnchor",
         "defeatImage", 
         "lineTwo/challengeButton",
         "lineTwo/levelScoreContainer",
         "lineTwo/levelScoreContainer/evaluationImage",
         "lineOne/stars/star1", "lineOne/stars/star2", "lineOne/stars/star3", "lineOne/stars/star4", "lineOne/stars/star5",
    }) 
    self.m_allStarsTransList = {star1, star2, star3, star4, star5}

    self.m_challengeBtnText, 
    self.m_scoreText = UIUtil.GetChildTexts(self.transform, {
        "lineTwo/challengeButton/Text", 
        "lineTwo/levelScoreContainer/evaluationImage/scoreText",
    }) 
    
    self.m_evaluationImg = UIUtil.AddComponent(UIImage, self, "lineTwo/levelScoreContainer/evaluationImage", AtlasConfig.DynamicLoad)
    self.m_countryImg = UIUtil.AddComponent(UIImage, self, "lineOne/countryImage", AtlasConfig.DynamicLoad)

    self.m_challengeBtnText.text = Language.GetString(3309) 
end 

function YuanmenItem:UpdateData(yuanmen_id, roleParentTr)     
    self.m_yuanmenID = yuanmen_id
    self.m_roleParentTr = roleParentTr

    local one_yuanmen = yuanmenMgr:GetOneYuanmenInfo(yuanmen_id) 
    if not one_yuanmen then
        return
    end

    self:SetCountrySprite(one_yuanmen)     
    self:UpdateStars(one_yuanmen.star_level)         
    
    self.m_isPassed = one_yuanmen.passed
    if self.m_isPassed then
        self.m_challengeBtnTrans.gameObject:SetActive(false)

        self.m_defeatImgTrans.localScale = Vector3.New(5, 5, 5)   
        self.m_defeatImgTrans.gameObject:SetActive(true)
        local tweener = DOTweenShortcut.DOScale(self.m_defeatImgTrans, 1, 0.5)
        DOTweenSettings.SetEase(tweener, DoTweenEaseType.OutBack)

        self.m_levelScoreContainerTrans.gameObject:SetActive(true)
        local spritePath = yuanmenMgr:GetEvaluationSpritePath(one_yuanmen.score)
        self.m_evaluationImg:SetAtlasSprite(spritePath,true)
        self.m_levelScoreImgTrans.localScale = Vector3.New(0.8,0.8,0.8)
        self.m_scoreText.text = string_format(Language.GetString(2614), one_yuanmen.score)  
    else
        self.m_challengeBtnTrans.gameObject:SetActive(true)
        self.m_defeatImgTrans.gameObject:SetActive(false)
        self.m_levelScoreContainerTrans.gameObject:SetActive(false) 
    end 

    self:CreateWujiang(one_yuanmen)

    coroutine.start(YuanmenItem.FixPos,self)
 
    UIManagerInst:Broadcast(UIMessageNames.MN_YUANMEN_REFRESH_CALLBACK, self.m_yuanmenID)
end

function YuanmenItem:FixPos()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_levelScoreImgTrans, self.m_levelScoreContainerTrans) 
end

function YuanmenItem:CreateWujiang(one_yuanmen) 
    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end

    if self.m_createWuJiangSeq > 0 then
        ActorShowLoader:GetInstance():CancelLoad(self.m_createWuJiangSeq)
        self.m_createWuJiangSeq = 0
    end
    local monsterCfg = ConfigUtil.GetMonsterCfgByID(one_yuanmen.right_wujiang_info_list[1].monster_id)  
    local firstWujiangID = 0
    if monsterCfg then
        firstWujiangID = monsterCfg.role_id
    end

    if firstWujiangID and firstWujiangID > 0 then
        self.m_createWuJiangSeq = ActorShowLoader:GetInstance():PrepareOneSeq() 
        ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_createWuJiangSeq, ActorShowLoader.MakeParam(firstWujiangID, 1), self.m_roleParentTr, function(actorShow)
            self.m_createWuJiangSeq = 0
            self.m_actorShow = actorShow
           
            self.m_actorShow:PlayAnim(BattleEnum.ANIM_IDLE)
            self.m_actorShow:SetPosition(Vector3.zero)
            self.m_actorShow:SetEulerAngles(Vector3.New(0,0,0))
        end)
    end 
end

function YuanmenItem:SetCountrySprite(one_yuanmen)  
    local wujiangCfg = yuanmenMgr:GetWujiangCfgByMonsterID(one_yuanmen.right_wujiang_info_list[1].monster_id)
    if wujiangCfg then 
        UILogicUtil.SetWuJiangCountryImage(self.m_countryImg, wujiangCfg.country)
    end 
end

function YuanmenItem:UpdateStars(star_level)
    if not star_level or star_level == 0 then
        for i=1,#self.m_allStarsTransList do
            self.m_allStarsTransList[i].gameObject:SetActive(false)
        end
        return
    end

    for i = 1,star_level do
        self.m_allStarsTransList[i].gameObject:SetActive(true)
    end
    for i = star_level + 1, #self.m_allStarsTransList do
        self.m_allStarsTransList[i].gameObject:SetActive(false)
    end
end  

function YuanmenItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick) 

    UIUtil.AddClickEvent(self.m_modelAnchorTr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_challengeBtnTrans.gameObject, onClick)
end

function YuanmenItem:OnClick(go,x,y)
    if self.m_isPassed then
        return
    end
    local goName = go.name
    if goName == "challengeButton" or goName == "modelAnchor" then  
        UIManagerInst:OpenWindow(UIWindowNames.UIYuanmenDetail, self.m_yuanmenID)        
    end 
end 
return YuanmenItem