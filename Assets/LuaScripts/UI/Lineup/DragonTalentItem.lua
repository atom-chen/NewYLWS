local SplitString = CUtil.SplitString
local math_ceil = math.ceil
local string_format = string.format
local DragonTalentItem = BaseClass("DragonTalentItem", UIBaseItem)
local base = UIBaseItem

function DragonTalentItem:OnCreate()
    self.m_talentData = nil
    self.m_talentIconRoot = UIUtil.GetChildTransforms(self.transform, {
        "talentBgImage/talentIconMask",
    })
    
    self.m_talnetNameText = UIUtil.GetChildTexts(self.transform, {
        "talentNameText",
    })

    self.m_iconImg = UIUtil.AddComponent(UIImage, self, "talentBgImage/talentIconMask/talentIcon", ImageConfig.GodBeast)
    self.m_talentIconRoot = self.m_talentIconRoot.gameObject
    self.m_LVNumList = SplitString(Language.GetString(3630), ",")

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_iconImg.gameObject, onClick)
end

function DragonTalentItem:SetData(talentData)
    self.m_talentData = talentData
    if talentData then
        self.m_talentIconRoot:SetActive(true)
        local talentCfg = ConfigUtil.GetGodBeastTalentCfgByID(talentData.talent_id)
        if talentCfg then
            self.m_talnetNameText.text = string_format(self.m_LVNumList[talentData.talent_level],talentCfg.name)
            self.m_iconImg:SetAtlasSprite(talentCfg.sIcon, false)
        end
    else
        self.m_talentIconRoot:SetActive(false)
        self.m_talnetNameText.text = ''
    end
end

function DragonTalentItem:OnClick(go, x, y)
    if go.name == "talentIcon" then
        if self.m_talentData then
            local talentCfg = ConfigUtil.GetGodBeastTalentCfgByID(self.m_talentData.talent_id)
            if talentCfg then
                local desText = talentCfg.exdesc
                local x1 = talentCfg.x + talentCfg.ax * self.m_talentData.talent_level
                local x2 = math_ceil(x1)
                x1 = x1 == x2 and x2 or x1
                local y1 = talentCfg.y + talentCfg.ay * self.m_talentData.talent_level
                local y2 = math_ceil(y1)
                y1 = y1 == y2 and y2 or y1
                desText = desText:gsub("{(.-)}", {x=x1, y=y1})

                local nameText = string_format(self.m_LVNumList[self.m_talentData.talent_level],talentCfg.name)


                local screenPoint = UIManagerInst.UICamera:WorldToScreenPoint(self.transform.position)
                UIManagerInst:OpenWindow(UIWindowNames.UITips, screenPoint, nameText, desText)
            end
        end
    end
end

function DragonTalentItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_iconImg.gameObject)
    base.OnDestroy(self)
end

return DragonTalentItem