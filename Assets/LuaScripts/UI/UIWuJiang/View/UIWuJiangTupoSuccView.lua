
local math_ceil = math.ceil
local table_insert = table.insert
local string_format = string.format

local UIUtil = UIUtil
local GameObject = CS.UnityEngine.GameObject
local ConfigUtil = ConfigUtil
local CommonDefine = CommonDefine

local UIWuJiangCardItem = require "UI.UIWuJiang.View.UIWuJiangCardItem"

--skillItem
local SkillItem = BaseClass("SkillItem", UIBaseItem)
local baseItem = UIBaseItem

local CardItemPath = TheGameIds.CommonWujiangCardPrefab

function SkillItem:OnCreate()
    self.m_skillIconImage = UIUtil.AddComponent(UIImage, self, "SkillIconMask/SkillIcon", ImageConfig.SkillIcon)
    self.m_skillNameText, self.m_skillOldLevelText, self.m_skillNewLevelText = UIUtil.GetChildTexts(self.transform, {
        "skillNameText",
        "skillOldLevelText",
        "skillNewLevelText"
    })

    self.m_skillData = {  skill_level = 0 , skill_id = 0 }

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_gameObject, onClick)
end

function SkillItem:OnClick(go, x, y)
    if IsNull(go) then
        return
    end

    UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangSkillTipsView, go.transform.position, self.m_skillData)
end

function SkillItem:SetData(data)
    if not data then
        return
    end

    local skillCfg = ConfigUtil.GetSkillCfgByID(data.skillID)
    if skillCfg then
        self.m_skillNameText.text = skillCfg.name
        self.m_skillOldLevelText.text =  string_format(Language.GetString(78), data.oldLevel)
        self.m_skillNewLevelText.text = string_format(Language.GetString(78), data.newLevel)
        self.m_skillIconImage:SetAtlasSprite(skillCfg.sIcon..".png")

        self.m_skillData.skill_id = data.skillID
        self.m_skillData.skill_level = data.newLevel
    end
end

function SkillItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_gameObject)
    self.m_skillData = nil
    if self.m_skillIconImage then
        self.m_skillIconImage:Delete()
        self.m_skillIconImage = nil
    end

    baseItem.OnDestroy(self)
end


local UIWuJiangTupoSuccView = BaseClass("UIWuJiangTupoSuccView", UIBaseView)
local base = UIBaseView

function UIWuJiangTupoSuccView:OnCreate()
    base.OnCreate(self)
   
    self.m_attrTextPrefab, self.m_secondAttrParent, self.m_skillItemPrefab, 
    self.m_skillParent, self.m_containerTrans = UIUtil.GetChildTransforms(self.transform, {
        "AttrTextPrefab",
        "Container/SecondAttrList",
        "skillItemPrefab",
        "Container/SkillList",
        "Container"
    })

    self.m_closeBtn = UIUtil.GetChildTransforms(self.transform,{"CloseBtn"} )

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)

    self.m_attrTextPrefab = self.m_attrTextPrefab.gameObject
    self.m_skillItemPrefab = self.m_skillItemPrefab.gameObject

    self.m_attrGoList = {}
    self.m_skillItemList = {}

    self.m_seq = 0

    self.m_attrSortNameList = {
        "max_hp", "mingzhong", "shanbi", "phy_atk", "magic_atk", "phy_baoji", "magic_baoji", "baoji_hurt", "phy_def", "magic_def",
        "atk_speed", "move_speed", "hp_recover", "nuqi_recover", "init_nuqi", "phy_suckblood", "magic_suckblood", "reduce_cd" }
end

function UIWuJiangTupoSuccView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    end
end

function UIWuJiangTupoSuccView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function UIWuJiangTupoSuccView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, wujiangChgData = ...
    if not wujiangChgData then
        return
    end

  

    local wujiangBriefData = Player:GetInstance().WujiangMgr:GetWuJiangBriefData(wujiangChgData.index)
    if not wujiangBriefData then
        return
    end

    local wujiangData = Player:GetInstance().WujiangMgr:GetWuJiangData(wujiangChgData.index)
    if not wujiangData then
        return
    end

    local second_attr_chg = wujiangChgData.second_attr_chg
    local skillChgList = wujiangChgData.skill_chg
    if second_attr_chg then
        local wujiangBreakSecondAttrCfg = nil
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangData.id)
        if wujiangCfg then
            local breakID = wujiangCfg.rare * 100 + wujiangData.tupo
            wujiangBreakSecondAttrCfg = ConfigUtil.GetWuJiangBreakSecondAttrCfgById(breakID)
        end

        local index = 1
        for _, v in ipairs(self.m_attrSortNameList) do
            local val = second_attr_chg[v]
            if val ~= 0 then
                local check = true
                 --加个容错
                if wujiangBreakSecondAttrCfg and wujiangBreakSecondAttrCfg[v] and wujiangBreakSecondAttrCfg[v] == 0 then
                    check = false
                end
                if check then
                    local attrtype = CommonDefine[v]
                    if attrtype then
                        local go = GameObject.Instantiate(self.m_attrTextPrefab, self.m_secondAttrParent)
                        local trans = go.transform
                        trans.localPosition = Vector3.New(0, -35 * (index - 1), 0)
                        table_insert(self.m_attrGoList , go)
                        local attrText = UIUtil.FindText(trans)
                        attrText.text = Language.GetString(attrtype + 10).."+"..string_format("%s", UILogicUtil.GetWuJiangSecondAttrVal(v, val))
                        index = index + 1
                    end
                end
            end
        end
    end

    if skillChgList then
        for i = 1, #skillChgList do
            local go = GameObject.Instantiate(self.m_skillItemPrefab, self.m_skillParent)
            go.transform.localPosition = Vector3.New(0, -144 * (i - 1), 0)
            local skillItem = SkillItem.New(go)
            skillItem:SetData(skillChgList[i])
            table_insert(self.m_skillItemList , skillItem)
        end
    end

    if self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObject(self.m_seq, CardItemPath, function(obj)
            self.m_seq = 0
            
            if not IsNull(obj) then
                self.m_cardItem = UIWuJiangCardItem.New(obj, self.m_containerTrans)
                self.m_cardItem:SetLocalPosition(Vector3.New(-242.8, 32.5))
                self.m_cardItem:SetData(wujiangBriefData)
            end
        end)
    end
end

function UIWuJiangTupoSuccView:OnDisable()

    for i, v in ipairs(self.m_attrGoList) do
        GameObject.Destroy(v)
    end

    self.m_attrGoList = {}

    for i, v in ipairs(self.m_skillItemList) do
        v:Delete()
    end

    self.m_skillItemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    if self.m_cardItem then
        self.m_cardItem:Delete()
        self.m_cardItem = nil
    end

    base.OnDisable(self)
end




return UIWuJiangTupoSuccView
