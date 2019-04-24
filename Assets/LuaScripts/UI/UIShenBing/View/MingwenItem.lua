  
local string_format = string.format
local Language = Language
local CommonDefine = CommonDefine
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local ImageConfig = ImageConfig

local taskMgr = Player:GetInstance():GetTaskMgr()

local MingwenItem = BaseClass("MingwenItem", UIBaseItem)
local base = UIBaseItem

function MingwenItem:OnCreate()
    base.OnCreate(self)

    self.m_nameText,
    self.m_attrText = UIUtil.GetChildTexts(self.transform, {
         "Name",
         "AttrText"
    })

    self.m_mingwenImg = UIUtil.AddComponent(UIImage, self, "MingwenImg", ImageConfig.MingWen)
    
end

function MingwenItem:UpdateData(mingwenData)
    self.m_nameText.text = mingwenData.name
    self.m_mingwenImg:SetAtlasSprite(mingwenData.id..".png")
    
    local quality = mingwenData.quality
    local attrStr = ""
    local nameList = CommonDefine.mingwen_second_attr_name_list
    for _, name in ipairs(nameList) do
        local hasPercent = true
        local val = mingwenData[name]
        if val and val > 0 then
            if name == "init_nuqi" then
                hasPercent = false
            end
            local attrType = CommonDefine[name]
            if attrType then
                local tempStr = nil
                if hasPercent then
                    tempStr = Language.GetString(2938)
                    if i == 2 then
                        tempStr = Language.GetString(2939)
                    elseif i == 3 then
                        tempStr = Language.GetString(2940)
                    end
                else
                    tempStr = Language.GetString(2945)
                    if i == 2 then
                        tempStr = Language.GetString(2946)
                    elseif i == 3 then
                        tempStr = Language.GetString(2947)
                    end
                end
                attrStr = attrStr..string_format(tempStr, Language.GetString(attrType + 10), val)
            end
        end
    end
    self.m_attrText.text = attrStr
end

function MingwenItem:OnDestroy() 
    if self.m_mingwenImg then
        self.m_mingwenImg:Delete()
        self.m_mingwenImg = nil
    end

    base.OnDestroy(self)
end


return MingwenItem

