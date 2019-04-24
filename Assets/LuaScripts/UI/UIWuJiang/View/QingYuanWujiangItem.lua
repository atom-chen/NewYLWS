
local ConfigUtil = ConfigUtil
local wujiangMgr = Player:GetInstance().WujiangMgr
local GameUtility = CS.GameUtility 
local DOTweenShortcut = CS.DOTween.DOTweenShortcut 


local QingYuanWujiangItem = BaseClass("QingYuanWujiangItem", UIBaseItem)
local base = UIBaseItem 
 
function QingYuanWujiangItem:OnCreate()
    base.OnCreate(self)
    self.m_curSrcWujiangID = 0
    self.m_curDstWujiangID = 0 

    self.m_canClickSelf = true
 
    self.m_iconClickBtnTr,
    self.m_hasContainerTr,
    self.m_hasNotContainerTr = UIUtil.GetChildTransforms(self.transform, { 
         "IconClickBtn",
         "HasContainer",
         "HasNotContainer",  
    }) 

    self.m_hasDesTxt,
    self.m_levelTxt,
    self.m_attrValueTxt,
    self.m_hasNotDesTxt = UIUtil.GetChildTexts(self.transform, { 
        "HasContainer/HasDes",
        "HasContainer/Level",
        "HasContainer/AttrValue",
        "HasNotContainer/HasNotDes",
    }) 
  
    self.m_myFrameImg = UIUtil.AddComponent(UIImage, self, "IconClickBtn/HeadIcon/Frame", AtlasConfig.DynamicLoad)
    self.m_myIconImg = UIUtil.AddComponent(UIImage, self, "IconClickBtn/HeadIcon", AtlasConfig.RoleIcon)

    self.m_hasDesTxt.text = Language.GetString(3654) 

    self:SetClickScaleChg()
end  

function QingYuanWujiangItem:UpdateData(one_wujiang_info, cur_src_id)
    if not one_wujiang_info or not cur_src_id then
        return
    end 
    self.m_curSrcWujiangID = cur_src_id
    self.m_curDstWujiangID = one_wujiang_info.wujiang_id  
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_curDstWujiangID)  
    if not wujiangCfg then
        return
    end

    UILogicUtil.SetWuJiangFrame(self.m_myFrameImg, wujiangCfg.rare)
    self.m_myIconImg:SetAtlasSprite(wujiangCfg.sIcon)
     
    local isWuJiangActive, oneIntimacyInfo = wujiangMgr:IsWuJiangActive(self.m_curSrcWujiangID, self.m_curDstWujiangID) 

    local intimacyLevelCfg = nil
    if oneIntimacyInfo then
        local level = oneIntimacyInfo.intimacy_level  
        local dstId = oneIntimacyInfo.dst_wujiang_id 
        local comcatId = math.floor(self.m_curSrcWujiangID * 1000000 + dstId * 100 + level)  
        intimacyLevelCfg = ConfigUtil.GetIntimacyLevelCfgByComcatID(comcatId)
    end 

    if isWuJiangActive and intimacyLevelCfg then
        self.m_hasContainerTr.gameObject:SetActive(true)
        self.m_hasNotContainerTr.gameObject:SetActive(false) 

        local attrName, attrValue = wujiangMgr:GetAttr(intimacyLevelCfg)
        self.m_attrValueTxt.text = string.format(Language.GetString(3653), attrName, attrValue) 
        self.m_levelTxt.text = string.format(Language.GetString(3651), level)  
        
        GameUtility.SetUIGray(self.m_iconClickBtnTr.gameObject, false) 

    else
        self.m_hasContainerTr.gameObject:SetActive(false)
        self.m_hasNotContainerTr.gameObject:SetActive(true)

        local tempLevel = one_wujiang_info.wujiang_star
        local name = wujiangCfg.sName
        local color = self:GetNameColor(wujiangCfg.rare)     
        self.m_hasNotDesTxt.text = string.format(Language.GetString(3661),tempLevel, color, name)
      
        GameUtility.SetUIGray(self.m_iconClickBtnTr.gameObject, true) 
    end  

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_iconClickBtnTr.gameObject, onClick)
end 

function QingYuanWujiangItem:SetCanNotClick(canClick)
    self.m_canClickSelf = canClick
    if not canClick then
        UIUtil.RemoveClickEvent(self.m_iconClickBtnTr.gameObject)
        self.m_hasContainerTr.gameObject:SetActive(false)
        self.m_hasNotContainerTr.gameObject:SetActive(false)
    end
end 

function QingYuanWujiangItem:SetClickScaleChg()
    local clickBegin = function(go,x,y)
        DOTweenShortcut.DOScale(self.m_iconClickBtnTr, 1.2, 0.5)
    end

    local clickeEnd = function(go,x,y)
        DOTweenShortcut.DOScale(self.m_iconClickBtnTr, 1, 0.5)
    end

    UIUtil.AddDownEvent(self.m_iconClickBtnTr.gameObject, clickBegin)
    UIUtil.AddUpEvent(self.m_iconClickBtnTr.gameObject, clickeEnd)
end

function QingYuanWujiangItem:OnClick(go, x, y)
    if not self.m_canClickSelf then
        return
    end
    local goName = go.name
    if goName == "IconClickBtn" then  
        UIManagerInst:OpenWindow(UIWindowNames.UIQingYuanGiftView, self.m_curSrcWujiangID, self.m_curDstWujiangID) 
    end
end

function QingYuanWujiangItem:GetNameColor(rare)
    local color = ""
    if rare == 1 then
        color = "ffffff"
    elseif rare == 2 then
        color = "00a8ff"
    elseif rare == 3 then
        color = "ee00ee"
    elseif rare == 4 then 
        color = "ffb400"
    else
        color = "ffffff"
    end
    return color
end 

function QingYuanWujiangItem:OnDestroy() 
    if self.m_iconClickBtnTr then
        GameUtility.SetUIGray(self.m_iconClickBtnTr.gameObject, false) 
        UIUtil.RemoveClickEvent(self.m_iconClickBtnTr.gameObject) 
    end

    base.OnDestroy(self)
end

return QingYuanWujiangItem




