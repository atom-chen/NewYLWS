local Vector2 = Vector2

local UIQuestionsMarkTipsView = BaseClass("UIQuestionsMarkTipsView", UIBaseView)
base = UIBaseView  

function UIQuestionsMarkTipsView:OnCreate()
    base.OnCreate(self)

    self.m_descTxt = UIUtil.GetChildTexts(self.transform, { 
        "Panel/ScrollViewPanel/Viewport/Content/DescTxt",
    })

    self.m_closeBtnTr,
    self.m_scrollViewPanelTr,
    self.m_scrollContentTr,
    self.m_descTxtTr = UIUtil.GetChildTransforms(self.transform, {
        "CloseBtn",
        "Panel/ScrollViewPanel",
        "Panel/ScrollViewPanel/Viewport/Content", 
        "Panel/ScrollViewPanel/Viewport/Content/DescTxt",
    })

    self:HandleClick()
end

function UIQuestionsMarkTipsView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, tips_id = ...

    if not tips_id then
        return
    end
    self.m_tipsId = tips_id
    self:ResetMin()
    self:UpdateData()
end

function UIQuestionsMarkTipsView:ResetMin()
    self.m_scrollViewPanelTr.sizeDelta = Vector2.New(1000, 200)
    self.m_descTxtTr.sizeDelta = Vector2.New(960, 160)
    self.m_descTxt.text = ""
    local oriSize = self.m_scrollContentTr.sizeDelta
    self.m_scrollContentTr.sizeDelta = Vector2.New(oriSize.x, 160)
    self.m_scrollContentTr.anchoredPosition = Vector2.New(0, 0)
end

function UIQuestionsMarkTipsView:UpdateData()
    local cfg = ConfigUtil.GetTipsDescCfg(self.m_tipsId)
    if not cfg then
        return
    end
    local str = cfg.desc   
    local size = cfg.size
    local width = 1000
    local height = 200
    if size then 
        local resStrList = self:SplitStr(size, '|') 
        if resStrList[1] and resStrList[2] then
            local w = tonumber(resStrList[1])
            local h = tonumber(resStrList[2])
            if type(w) == "number" and type(h) == "number" then
                width = w
                height = h
            end
        end
    end

    self.m_scrollViewPanelTr.sizeDelta = Vector2.New(width, height) 
    local svPanelSizeX = self.m_scrollViewPanelTr.sizeDelta.x
    self.m_descTxtTr.sizeDelta = Vector2.New(svPanelSizeX - 40, 0)  

    self.m_descTxt.text = str 

    coroutine.start(self.DelaySet, self)
end  

function UIQuestionsMarkTipsView:SplitStr(str, delimiter)
    str = tostring(str)
    local resStrList = {}
    if tostring(delimiter) == '' then
        return resStrList
    end 
    local pos = 0
    local func = function() 
                    return string.find(str, delimiter, pos, true)
                 end
    for st, sp in func do
        table.insert(resStrList, string.sub(str, pos, st - 1)) 
        pos = sp + 1 
    end
    table.insert(resStrList, string.sub(str, pos)) 
    return resStrList
end

function UIQuestionsMarkTipsView:DelaySet()
    coroutine.waitforseconds(0.05)

    local svPanelSizeX = self.m_scrollViewPanelTr.sizeDelta.x
    local txtSize = self.m_descTxtTr.sizeDelta 

    self.m_scrollContentTr.anchoredPosition = Vector2.New(-((svPanelSizeX - 40) / 2), 0)
    self.m_scrollContentTr.sizeDelta = Vector2.New((svPanelSizeX - 40) + 4, txtSize.y + 4) 
    local contentSize = self.m_scrollContentTr.sizeDelta  
end

function UIQuestionsMarkTipsView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
   
    UIUtil.AddClickEvent(self.m_closeBtnTr.gameObject, onClick)
end

function UIQuestionsMarkTipsView:OnClick(go, x, y)
    self:CloseSelf()
end

function UIQuestionsMarkTipsView:OnDestory()
    UIUtil.RemoveClickEvent(self.m_closeBtnTr.gameObject)
    base.OnDestory(self)
end

return UIQuestionsMarkTipsView