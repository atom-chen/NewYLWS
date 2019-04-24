using System;

public enum GAME_PLATFORM
{
    TEST,
    TESTIOS,
#if UNITY_ANDROID
    ANHX,
#elif UNITY_IOS
    IOSHX,
#endif
}

public class PlatformConfig
{
    public static string GetPackageName(string platformName)
    {
        GAME_PLATFORM platName = (GAME_PLATFORM)Enum.Parse(typeof(GAME_PLATFORM), platformName);
        switch (platName)
        {
#if UNITY_ANDROID
            case GAME_PLATFORM.ANHX:
                return "com.haoxin.xylws";
            case GAME_PLATFORM.TEST:
                return "com.haoxin.xylws.antest";
#elif UNITY_IOS
            case GAME_PLATFORM.TESTIOS:
                return "com.haoxin.xylws.iostest";
            case GAME_PLATFORM.IOSHX:
                return "com.haoxin.ios.xylws";
#endif
            default:
                return string.Empty;
        }
    }

    public static string GetProductName(string platformName)
    {
        GAME_PLATFORM platName = (GAME_PLATFORM)Enum.Parse(typeof(GAME_PLATFORM), platformName);
        switch (platName)
        {
#if UNITY_ANDROID
            case GAME_PLATFORM.ANHX:
                return "新御龙";
            case GAME_PLATFORM.TEST:
                return "新御龙AT";
#elif UNITY_IOS
            case GAME_PLATFORM.TESTIOS:
                return "新御龙IT";
            case GAME_PLATFORM.IOSHX:
                return "新御龙无双";
#endif
            default:
                return "御龙";
        }
    }

    public static bool IsGooglePlay(string platformName)
    {
        GAME_PLATFORM platName = (GAME_PLATFORM)Enum.Parse(typeof(GAME_PLATFORM), platformName);
        return false;
    }
}
