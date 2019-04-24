
local UIUtil = UIUtil
local math_ceil = math.ceil
local string_format = string.format
local ConfigUtil = ConfigUtil

local ShenBingSuccessItem = BaseClass("ShenBingSuccessItem", UIBaseItem)
local base = UIBaseItem

function ShenBingSuccessItem:OnCreate()
    base.OnCreate(self)
    self.m_curAdditionText, self.m_newAdditionText = UIUtil.GetChildTexts(self.transform, {
        "curAddition",
        "newAddition",
    })

    self.m_curMingwenBtn, self.m_newMingwenBtn = UIUtil.GetChildTransforms(self.transform, {
        "curMingwenImg",
        "newMingwenImg"
    })

    self.m_curMingwenImg = UIUtil.AddComponent(UIImage, self, "curMingwenImg")
    self.m_newMingwenImg = UIUtil.AddComponent(UIImage, self, "newMingwenImg")

    self.m_curData = false
    self.m_newMingwenList = false

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_curMingwenBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_newMingwenBtn.gameObject, onClick)
end

function ShenBingSuccessItem:OnClick(go)
    if go.name == "curMingwenImg" then
        local pos = self.m_curMingwenBtn.position
        local insCfg = ConfigUtil.GetShenbingInscriptionCfgByID(self.m_newMingwenList.mingwen_id)
        local text = self:UpdateInscription(self.m_curData.m_mingwen_list[insCfg.quality].mingwen_id)
        UIManagerInst:OpenWindow(UIWindowNames.UIIconTips, pos, text)
    elseif go.name == "newMingwenImg" then
        local pos = self.m_newMingwenBtn.position
        local text = self:UpdateInscription(self.m_newMingwenList.mingwen_id)
        UIManagerInst:OpenWindow(UIWindowNames.UIIconTips, pos, text)
    end
end

function ShenBingSuccessItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_curMingwenBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_newMingwenBtn.gameObject)
    base.OnDestroy(self)
end

function ShenBingSuccessItem:UpdateInscription(mingwenId)
    if mingwenId and mingwenId > 0 then
        local mingwenCfg = ConfigUtil.GetShenbingInscriptionCfgByID(mingwenId)
        if mingwenCfg then
            local quality = mingwenCfg.quality
            local attrStr = string_format("%s\n", mingwenCfg.name)
            local nameList = CommonDefine.mingwen_second_attr_name_list
            for _, name in ipairs(nameList) do
                local hasPercent = true
                local val = mingwenCfg[name]
                if val and val > 0 then
                    if name == "init_nuqi" then
                        hasPercent = false
                    end
                    local attrType = CommonDefine[name]
                    if attrType then
                        local tempStr = nil
                        if hasPercent then
                            tempStr = Language.GetString(2910)
                            if i == 2 then
                                tempStr = Language.GetString(2911)
                            elseif i == 3 then
                                tempStr = Language.GetString(2912)
                            end
                        else
                            tempStr = Language.GetString(2942)
                            if i == 2 then
                                tempStr = Language.GetString(2943)
                            elseif i == 3 then
                                tempStr = Language.GetString(2944)
                            end
                        end
                        attrStr = attrStr..string_format(tempStr, Language.GetString(attrType + 10), val)
                    end
                end
            end
            
            return attrStr
        end
    else
        return ''
    end

end

function ShenBingSuccessItem:SetData(data, mingwenList)
    if not data then
        return
    end
    self.m_curData = data
    self.m_newMingwenList = mingwenList
    local insCfg = ConfigUtil.GetShenbingInscriptionCfgByID(mingwenList.mingwen_id)
    local newWashTime = data.m_mingwen_list[insCfg.quality].wash_times
    local oldWashTime = newWashTime - mingwenList.wash_times
    if newWashTime >= 200 then
        oldWashTime = 200
    end
    self.m_curAdditionText.text = string_format("%d%%", math_ceil(oldWashTime)) 
    self.m_newAdditionText.text = string_format("%d%%", math_ceil(newWashTime))
    self.m_curMingwenImg:SetAtlasSprite(math_ceil(data.m_mingwen_list[insCfg.quality].mingwen_id)..".png", false, ImageConfig.MingWen)
    self.m_newMingwenImg:SetAtlasSprite(math_ceil(mingwenList.mingwen_id)..".png", false, ImageConfig.MingWen)
end

return ShenBingSuccessItem