local UIUtil = UIUtil

local UIWuJiangXiaoZhuanItem = BaseClass("UIWuJiangXiaoZhuanItem", UIBaseItem)
local base = UIBaseItem

function UIWuJiangXiaoZhuanItem:__delete()
    self.m_comentText = false
    self.m_titleText = false
    self.m_zhuanjiBg = false
end

function UIWuJiangXiaoZhuanItem:OnCreate()
    base.OnCreate(self)

    self.m_titleText = UIUtil.GetChildTexts(self.transform, {
        "titleImage/titleText",
    })

    self.m_zhuanjiBg = UIUtil.GetChildRectTrans(self.transform, {
        "zhuanjiBg",
    })

    self.m_descText = UIUtil.FindText(self.transform)
    self.m_trans = UIUtil.FindTrans(self.transform)
end

function UIWuJiangXiaoZhuanItem:UpdateData(titleText, comentText, hideline)
    self.m_titleText.text = titleText
    self.m_descText.text = "\n\n\n"..comentText.."\n"
    if hideline == false then
    coroutine.start(self.FitPos, self)
    else
        self.m_zhuanjiBg.transform.localPosition = Vector3.New(10000,10000,0) 
    end
end

function UIWuJiangXiaoZhuanItem:FitPos()
    coroutine.waitforframes(1)
    local y = 5 -self.m_descText.rectTransform.sizeDelta.y
    self.m_zhuanjiBg.transform.localPosition = Vector3.New(514,y,0) 
end   

return UIWuJiangXiaoZhuanItem