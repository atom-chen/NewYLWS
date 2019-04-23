public class Setting
{
    public static int FPS = 60;
    public static string[] CONFIGS = { "base.xml" };

    private static string resourceUrl = string.Empty;
    private static string loginUrl = string.Empty;
    private static string reportErrorUrl = "https://sgc.haoxingame.com/logs/report";
    private static string serverListUrl = string.Empty;
    private static string orderUrl = string.Empty;
    private static string reportLoginUrl = string.Empty;
    private static string appUrl = string.Empty;
    private static string notifyUrl = string.Empty;
    private static string notifyUrl1 = string.Empty;
    private static string ipaUrl = string.Empty;
    private static string payway = string.Empty;
    private static string sandboxId = string.Empty;
    private static string aborderUrl = string.Empty;
    private static string auto_login = string.Empty;// iOS自动登陆控制
    private static int startupConnectTimes = 0; //启动地址三次切换
    private static string wujiangEvaluateUrl = "http://cm.haoxingame.com/commentary";
    private static bool isWhiteList = false;
    private static bool isShowBindPhoneBtn = false;

    public static string START_UP_URL
    {
        get
        {
            if (startupConnectTimes > 6)
            {
                startupConnectTimes = 0;
            }

            startupConnectTimes++;
            if (startupConnectTimes <= 3)
            {
                return "http://sgc.haoxingame.com/startup";
            }
            else
            {
                return "http://sgc2.haoxingame.com/startup";
            }
        }
    }

    public static string SERVER_RESOURCE_ADDR
    {
        set
        {
            resourceUrl = value;
        }
        get
        {
            return resourceUrl;
        }
    }

    public static string APP_ADDR
    {
        set
        {
            appUrl = value;
        }
        get
        {
            return appUrl;
        }
    }

    public static string IPA_ADDR
    {
        set
        {
            ipaUrl = value;
        }
        get
        {
            return ipaUrl;
        }
    }

    public static string SANDBOX
    {
        set
        {
            sandboxId = value;
        }
        get
        {
            return sandboxId;
        }
    }

    public static string LOGIN_URL
    {
        set
        {
            loginUrl = value;
        }
        get
        {
            return loginUrl;
        }
    }

    public static string REPORT_ERROR_URL
    {
        set
        {
            reportErrorUrl = value;
        }
        get
        {
            return reportErrorUrl;
        }
    }

    public static string SERVER_LIST_URL
    {
        set
        {
            serverListUrl = value;
        }
        get
        {
            return serverListUrl;
        }
    }

    public static string APPPAY_WAY
    {
        set
        {
            payway = value;
        }
        get
        {
            return payway;
        }
    }
    
    public static string NOTIFY_URL
    {
        set
        {
            notifyUrl = value;
        }
        get
        {
            return notifyUrl;
        }
    }

    public static string NOTIFY_URL1
    {
        set
        {
            notifyUrl1 = value;
        }
        get
        {
            return notifyUrl1;
        }
    }

    public static string ORDER_URL
    {
        set
        {
            orderUrl = value;
        }
        get
        {
            return orderUrl;
        }
    }

    public static string ABORDER_URL
    {
        set
        {
            aborderUrl = value;
        }
        get
        {
            return aborderUrl;
        }
    }



    public static string REPORT_LOGIN_URL
    {
        set
        {
            reportLoginUrl = value;
        }
        get
        {
            return reportLoginUrl;
        }
    }

    public static string WUJIANG_EVALUATE_URL
    {
        set
        {
            wujiangEvaluateUrl = value;
        }
        get
        {
            return wujiangEvaluateUrl;
        }
    }

    public static bool IsShowBindPhoneBtn
    {
        set { isShowBindPhoneBtn = value; }
        get { return isShowBindPhoneBtn; }
    }
    
    public static string AUTO_LOGIN
    {
        set
        {
            auto_login = value;
        }
        get
        {
            return auto_login;
        }
    }
}
