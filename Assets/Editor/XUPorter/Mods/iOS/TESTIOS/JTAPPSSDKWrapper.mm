//
//  PPSDKWrapper.m
//  Unity-iPhone
//
//  Created by haoxin on 15/6/1.
//
//

#if defined(__cplusplus)
extern "C"{
#endif
	void APPSInit(const char *aibei_appid,const char *aibei_siyao,const char *aibei_gongyao)
    {
      
    }
    
    void APPSLogin(const char *packageName, const char *payNotifyUrl)
    {
    }
    
    void APPSLogout()
    {
    }
    
    void APPSPay(const char *payway, const char *appProuductId, const char *abProuductId, const char *abNotifyurl, const int productPrice, const char *order)
    {

    }
    
    void APPSDownloadGame(const char *downloadUrl)
    {
    }
    
	void HXXGInit(const char* uid)
    {
    }

    BOOL APPIsPaying(const char*productID)
    {
        return false;
    }

    void APPSSubmitUserGameData(const char * roleID ,const char * roleName, const char * serverID, const char * serverName, const char * level ,const char * vipLevel ,const char *behavior)
    {
        
    }
    
#if defined(__cplusplus)
}
#endif

