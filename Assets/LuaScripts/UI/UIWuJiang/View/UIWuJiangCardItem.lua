local table_insert = table.insert
local math_ceil = math.ceil
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local tostring = tostring
local string_format = string.format

local Shader = CS.UnityEngine.Shader
local GameUtility = CS.GameUtility
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local GroupHerosMgr = Player:GetInstance():GetGroupHerosMgr()

local FarPos = Vector3.New(100000, 100000, 0)

--多个预设共用，保持节点一致
local UIWuJiangCardItem = BaseClass("UIWuJiangCardItem", UIBaseItem)

function UIWuJiangCardItem:OnCreate()

    self.m_frameImage = UIUtil.AddComponent(UIImage, self, "frame", AtlasConfig.DynamicLoad)
    self.m_iconImage = UIUtil.AddComponent(UIImage, self, "icon", AtlasConfig.RoleIcon)
    self.m_countryImage = UIUtil.AddComponent(UIImage, self, "Other/CountryImage", AtlasConfig.DynamicLoad)
    self.m_jobImage = UIUtil.AddComponent(UIImage, self, "Other/NameBG/JobImage", AtlasConfig.DynamicLoad)
    self.m_lockImage = UIUtil.AddComponent(UIImage, self, "Other/LockSpt", AtlasConfig.DynamicLoad)

    self.m_iconGo = self.m_iconImage.gameObject
    self.m_frameGo = self.m_frameImage.gameObject

    self.m_levelText,self.m_nameText, self.m_tipsText, self.m_winTimeText1, self.m_winTimeText2 = UIUtil.GetChildTexts(self.transform, {
        "Other/Level/LevelText",
        "Other/NameBG/NameText",
        "Other/TipsText",
        "Other/WinTime/Count2",
        "Other/WinTime/Count",
    })
    
    local star1_trans, star2_trans, star3_trans,star4_trans,star5_trans,star6_trans
    star1_trans, star2_trans, star3_trans,star4_trans,star5_trans,star6_trans, 
    self.m_other, self.m_nameRoot, self.m_CheckGo, self.m_winTimeTr,
    self.m_redPointImgTr = UIUtil.GetChildTransforms(self.transform, {
        "Other/startList/star1",
        "Other/startList/star2",
        "Other/startList/star3",
        "Other/startList/star4",
        "Other/startList/star5",
        "Other/startList/star6",
        "Other", 
        "Other/NameBG",
        "Other/SelectImage",
        "Other/WinTime",
        "Other/RedPointImg",

    })
    
    self.m_winTimeGo = self.m_winTimeTr.gameObject
    self.m_CheckGo = self.m_CheckGo.gameObject
    self.m_CheckGo:SetActive(false)

    self.m_other = self.m_other.gameObject
    self.m_nameRoot = self.m_nameRoot.gameObject
    self.m_starList = { star1_trans, star2_trans, star3_trans,star4_trans,star5_trans,star6_trans }

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_frameImage.gameObject, onClick)

    self.m_bSelect = false  --是否选中
    self.WujiangIndex = 0
    self.m_callBack = nil
    self.m_redPointImgTr.gameObject:SetActive(false)

    self:Reset()
end

function UIWuJiangCardItem:Reset()
    self.m_nameRoot:SetActive(true)
    self.m_frameImage:EnableRaycastTarget(true)
    self.m_countryImage.gameObject:SetActive(true)
    self:ShowTips(false)
end

function UIWuJiangCardItem:OnDestroy()
    self:SetIconColor(Color.white)

    UIUtil.RemoveClickEvent(self.m_frameImage.gameObject)
    self.m_callBack = nil

    if self.m_frameImage then
        self.m_frameImage:Delete()
        self.m_frameImage = nil
    end

    if self.m_iconImage then
        self.m_iconImage:Delete()
        self.m_iconImage = nil
    end

    if self.m_countryImage then
        self.m_countryImage:Delete()
        self.m_countryImage = nil
    end

    if self.m_jobImage then
        self.m_jobImage:Delete()
        self.m_jobImage = nil
    end

    self:SetRedPointStatus(false)
    self.transform.localScale = self.m_localScale
end

function UIWuJiangCardItem:GetIndex()
    return self.WujiangIndex
end

function UIWuJiangCardItem:SetData(wujiangBriefData, canClick, isScaleClick, callBack, showLock, clickScale, showWinTime, showRedPoint)

    self.m_callBack = callBack
    self.WujiangIndex = 0
   
    if not wujiangBriefData then
        return
    end 

    self.m_wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangBriefData.id)
    if not self.m_wujiangCfg then
        return
    end

    self.WujiangIndex = wujiangBriefData.index
    self.m_canClick = canClick or false
    self.m_isScaleClick = isScaleClick or false

    UILogicUtil.SetWuJiangFrame(self.m_frameImage, self.m_wujiangCfg.rare)
    UILogicUtil.SetWuJiangCountryImage(self.m_countryImage, self.m_wujiangCfg.country)
    UILogicUtil.SetWuJiangJobImage(self.m_jobImage, self.m_wujiangCfg.nTypeJob)
        
    local wujiangStarCfg = ConfigUtil.GetWuJiangStarCfgByID(wujiangBriefData.star)
    if wujiangStarCfg then
       if wujiangStarCfg.level_limit == wujiangBriefData.level then
            self.m_levelText.text = Language.GetString(700)
       else
            self.m_levelText.text = math_ceil(wujiangBriefData.level)
       end
    end
    
    local tupo = wujiangBriefData.tupo
    if tupo == 0 then
        self.m_nameText.text = self.m_wujiangCfg.sName
    else
        self.m_nameText.text = self.m_wujiangCfg.sName.."+"..math_ceil(tupo)
    end

    if wujiangBriefData.star ~= self.m_lastStar then
        self:SetStarListPos(wujiangBriefData.star)
        self.m_lastStar = wujiangBriefData.star
    end

    self.m_iconImage:SetAtlasSprite(self.m_wujiangCfg.sIcon)

    if showLock and wujiangBriefData.isLock == 1 then
        self.m_lockImage:SetAtlasSprite("ty81.png")
    else
        self.m_lockImage:SetAtlasSprite("realempty.tga", false, AtlasConfig.DynamicLoad)
    end

    self.m_clickScale = clickScale or 0.9

    local winCount = 0
    for i, v in ipairs(GroupHerosMgr.WujiangWinTimeList) do
        if v.wujiang_index == wujiangBriefData.index then
            winCount = v.win_times
            break
        end
    end
    local maxWinTime = Player:GetInstance():GetGroupHerosMgr().MaxWinTime
    if winCount == maxWinTime then
        self.m_winTimeText2.text = math_ceil(winCount)
        self.m_winTimeText1.text = ""
    elseif winCount < maxWinTime then
        self.m_winTimeText1.text = math_ceil(winCount)
        self.m_winTimeText2.text = ""
    end
    showWinTime = showWinTime or false
    self.m_winTimeGo:SetActive(showWinTime)

    if wujiangBriefData.m_redPointStatus and showRedPoint then
        self.m_redPointImgTr.gameObject:SetActive(true)
    else
        self.m_redPointImgTr.gameObject:SetActive(false)
    end
end 

function UIWuJiangCardItem:GetInfo()
    return self.m_wujiangDefendInfo
end

function UIWuJiangCardItem:SetDefendData(wujiangDefendInfo)
   
    self.WujiangIndex = 0
   
    if not wujiangDefendInfo then
        return
    end
    self.m_wujiangDefendInfo = wujiangDefendInfo

    self.m_wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangDefendInfo.id)
    if not self.m_wujiangCfg then
        return
    end

    UILogicUtil.SetWuJiangFrame(self.m_frameImage, self.m_wujiangCfg.rare)
    UILogicUtil.SetWuJiangCountryImage(self.m_countryImage, self.m_wujiangCfg.country)
    UILogicUtil.SetWuJiangJobImage(self.m_jobImage, self.m_wujiangCfg.nTypeJob)
        
    self.m_nameText.text = self.m_wujiangCfg.sName
    self.m_levelText.text = math_ceil(wujiangDefendInfo.level)

    if wujiangBriefData.star ~= self.m_lastStar then
        self:SetStarListPos(wujiangBriefData.star)
        self.m_lastStar = wujiangBriefData.star
    end

    self.m_iconImage:SetAtlasSprite(math_ceil(wujiangDefendInfo.id)..".jpg")
end

function UIWuJiangCardItem:OnClick(go, x, y)
    if go == self.m_frameImage.gameObject then
        if self.m_canClick then
            if self.m_isScaleClick then
                
                self.transform.localScale = self.m_localScale
                DOTweenShortcut.DOKill(self.transform, true)
                local tweener = DOTweenShortcut.DOScale(self.transform, self.m_clickScale, 0.2)
                DOTweenSettings.SetLoops(tweener, 2, 1)
             end
             if self.m_callBack then
                self.m_callBack(self)
             else
                UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_DEV_CARD_ITEM_SELECT, self.WujiangIndex, not self.m_bSelect)
             end
        end

        
    end
end

function UIWuJiangCardItem:DoSelect(bSelect)
    if not IsNull(self.m_CheckGo) then
        if bSelect == nil then
            self.m_bSelect = not self.m_bSelect
        else
            self.m_bSelect = bSelect
        end
        
        self.m_CheckGo:SetActive(self.m_bSelect)
    end
end

function UIWuJiangCardItem:HideCountry()
    self.m_countryImage.gameObject:SetActive(false)
end

function UIWuJiangCardItem:HideName()
    self.m_nameRoot:SetActive(false)
end

function UIWuJiangCardItem:SetNameActive(bShow)
    self.m_nameRoot:SetActive(bShow)
end

function UIWuJiangCardItem:EnableRaycast(enabled)
    self.m_frameImage:EnableRaycastTarget(enabled)
end

function UIWuJiangCardItem:SetClickScale(isScaleClick)
    self.m_isScaleClick = isScaleClick
end

function UIWuJiangCardItem:ShowTips(isShow, tipsText)
    tipsText = tipsText or ""
    self.m_tipsText.gameObject:SetActive(isShow)
    self.m_tipsText.text = tipsText
end

function UIWuJiangCardItem:SetIconColor(color)
    self.m_iconImage:SetColor(color)
end

function UIWuJiangCardItem:ChangeLock(lock)
    if showLock and lock == 1 then
        self.m_lockImage:SetAtlasSprite("ty81.png")
    else
        self.m_lockImage:SetAtlasSprite("realempty.tga", false, AtlasConfig.DynamicLoad)
    end
end

function UIWuJiangCardItem:SetStarListPos(star)
    local width = star * 47.5
    local pos_x = -width / 2 + 47.5 / 2
    for i = 1, #self.m_starList do
        if self.m_starList[i] then
            if i <= star then
                GameUtility.SetLocalPosition(self.m_starList[i], pos_x, 0, 0)
                pos_x = pos_x + 47.5
            else
                GameUtility.SetLocalPosition(self.m_starList[i], 1000000, 0, 0)
            end
        end
    end
end

function UIWuJiangCardItem:SetRedPointStatus(status)
    status = status or false
    self.m_redPointImgTr.gameObject:SetActive(status)
end

return UIWuJiangCardItem