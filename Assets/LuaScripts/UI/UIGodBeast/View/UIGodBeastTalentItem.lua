local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local string_format = string.format
local math_ceil = math.ceil
local string_split = CUtil.SplitString
local UIGodBeastTalentItem = BaseClass("UIGodBeastTalentItem", UIBaseItem)
local base = UIBaseItem

function UIGodBeastTalentItem:OnCreate()
    self.m_talentCaseImage = UIUtil.AddComponent(UIImage, self, "talentCaseImage", AtlasConfig.DynamicLoad)
    self.m_talentIconImage = UIUtil.AddComponent(UIImage, self, "talentCaseImage/talentIcon", ImageConfig.GodBeast)
    self.m_selectImage = UIUtil.GetChildTransforms(self.transform, { "talentCaseImage/SelectImage" })
    self.m_talentDesText, self.m_talentNameText, self.m_talentExplainText = UIUtil.GetChildTexts(self.transform, {
        "talentDesText",
        "talentDesText/talentNameText",
        "talentExplainText",
    })


    self.m_talentIcon = UIUtil.GetChildTransforms(self.transform, {
        "talentCaseImage/talentIcon",
    })

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_talentCaseImage.gameObject, onClick)

    self.m_talentIndex = 0
    self.m_talentInfo = nil
end

function UIGodBeastTalentItem:GetTalentIndex()
    return  self.m_talentIndex
end

function UIGodBeastTalentItem:GetTalentInfo()
    return self.m_talentInfo
end

function UIGodBeastTalentItem:GetTalentUnlocked()
    return self.m_unlocked
end

function UIGodBeastTalentItem:SetData(talentIndex, talentInfo, unlocked, selfOnClickCallback)
    self.m_talentIndex = talentIndex
    self.m_talentInfo = talentInfo
    self.m_unlocked = unlocked
    self.m_selfOnClickCallback = selfOnClickCallback

    local haveTalent = false

    if talentInfo then
        if talentInfo.talent_id ~= 0 then
            local talentCfg = ConfigUtil.GetGodBeastTalentCfgByID(self.m_talentInfo.talent_id)
            if talentCfg then
                local str = talentCfg.exdesc
                local x1 = talentCfg.x + talentCfg.ax * talentInfo.talent_level
                local x2 = math_ceil(x1)
                x1 = x1 == x2 and x2 or x1
                local y1 = talentCfg.y + talentCfg.ay * talentInfo.talent_level
                local y2 = math_ceil(y1)
                y1 = y1 == y2 and y2 or y1
                str = str:gsub("{(.-)}", {x=x1, y=y1})
                self.m_talentDesText.text = str

                self.m_talentNameText.text = string_format(string_split(Language.GetString(3630), ",")[talentInfo.talent_level],talentCfg.name)
            end
            self.m_talentIconImage:SetAtlasSprite(talentCfg.sIcon, false)
            haveTalent = true
        end
    end

    self.m_talentIcon.gameObject:SetActive(haveTalent)

    if unlocked then
        self.m_talentExplainText.text = Language.GetString(3612)
        self.m_talentCaseImage:SetAtlasSprite("talent01.png",false)
    else
        self.m_talentExplainText.text = string_format(Language.GetString(3613), talentIndex)
        self.m_talentCaseImage:SetAtlasSprite("talent02.png",false)
    end
    
    if haveTalent then
        self.m_talentExplainText.gameObject:SetActive(false)      
    else
        self.m_talentExplainText.gameObject:SetActive(true)
    end

    self.m_talentDesText.gameObject:SetActive(haveTalent)  
end

function UIGodBeastTalentItem:SetSelect(isSelect)
    self.m_selectImage.gameObject:SetActive(isSelect)
end

function UIGodBeastTalentItem:OnClick(go, x, y)
    if self.m_selfOnClickCallback then
        self.m_selfOnClickCallback(self)
    end
end

function UIGodBeastTalentItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_talentCaseImage.gameObject)
    self.m_talentCaseImage:Delete()
    self.m_talentCaseImage = nil
    self.m_talentIconImage:Delete()
    self.m_talentIconImage = nil    
    base.OnDestroy(self)
end

return UIGodBeastTalentItem