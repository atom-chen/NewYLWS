local UIWuJiangCardItem = require "UI.UIWuJiang.View.UIWuJiangCardItem"
local CardItemPath = TheGameIds.CommonWujiangCardPrefab
local Vector3 = Vector3
local CampsRushWuJiangItem = BaseClass("CampsRushWuJiangItem", UIBaseItem)
local base = UIBaseItem

function CampsRushWuJiangItem:OnCreate()
    base.OnCreate(self)

    self.m_selectImage = UIUtil.AddComponent(UIImage, self, "selectImg", AtlasConfig.DynamicLoad)
    self.m_itemRoot = UIUtil.FindTrans(self.transform, "itemRoot")
    self.m_selectImgGO = self.m_selectImage.gameObject
    self.m_wujiangItem = nil
    self.m_seq = 0
end

function CampsRushWuJiangItem:OnDestroy()
    if self.m_wujiangItem then
        self.m_wujiangItem:Delete()
        self.m_wujiangItem = nil
    end

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    base.OnDestroy(self)
end


function CampsRushWuJiangItem:SetData(wujiangBriefData)
    if not self.m_wujiangItem and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObject(self.m_seq, CardItemPath, function(go)
            self.m_seq = 0
            if not IsNull(go) then
                self.m_wujiangItem = UIWuJiangCardItem.New(go, self.m_itemRoot, CardItemPath)
                self.m_wujiangItem:SetAnchoredPosition(Vector3.zero)
                self.m_wujiangItem:SetData(wujiangBriefData, true)
            end
        end)
    else
        self.m_wujiangItem:SetData(wujiangBriefData, true)
    end
end

function CampsRushWuJiangItem:DoSelect(bSelect, isBench)
    if bSelect == nil then
        self.m_bSelect = not self.m_bSelect
    else
        self.m_bSelect = bSelect
    end
    
    self.m_selectImgGO:SetActive(self.m_bSelect)
    if self.m_bSelect then
        self.m_selectImage:SetAtlasSprite(isBench and "cly05.png" or "cly06.png")
    end
end

return CampsRushWuJiangItem

