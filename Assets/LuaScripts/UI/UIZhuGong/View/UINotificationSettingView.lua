
local base = UIBaseView
local UINotificationSettingView = BaseClass("UINotificationSettingView",UIBaseView)

function UINotificationSettingView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UINotificationSettingView:InitView()



    self.m_closeBtn = UIUtil.GetChildTransforms(self.transform, {
        "closeBtn",
    })




    
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UINotificationSettingView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end


function UINotificationSettingView:OnClick(go, x, y)
    if go.name == "closeBtn" then
        self:CloseSelf()
    end
end

return UINotificationSettingView