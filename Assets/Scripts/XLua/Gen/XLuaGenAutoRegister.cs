#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using System;
using System.Collections.Generic;
using System.Reflection;


namespace XLua.CSObjectWrap
{
    public class XLua_Gen_Initer_Register__
	{
        
        
        static void wrapInit0(LuaEnv luaenv, ObjectTranslator translator)
        {
        
            translator.DelayWrapLoader(typeof(object), SystemObjectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Object), UnityEngineObjectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Physics), UnityEnginePhysicsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Camera), UnityEngineCameraWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.GameObject), UnityEngineGameObjectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Component), UnityEngineComponentWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Behaviour), UnityEngineBehaviourWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Transform), UnityEngineTransformWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Resources), UnityEngineResourcesWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.TextAsset), UnityEngineTextAssetWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Keyframe), UnityEngineKeyframeWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.AnimationCurve), UnityEngineAnimationCurveWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.AnimationClip), UnityEngineAnimationClipWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.MonoBehaviour), UnityEngineMonoBehaviourWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.ParticleSystem), UnityEngineParticleSystemWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.SkinnedMeshRenderer), UnityEngineSkinnedMeshRendererWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Renderer), UnityEngineRendererWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.WWW), UnityEngineWWWWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.Collections.Generic.List<int>), SystemCollectionsGenericList_1_SystemInt32_Wrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Debug), UnityEngineDebugWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.Collections.Generic.Dictionary<string, UnityEngine.GameObject>), SystemCollectionsGenericDictionary_2_SystemStringUnityEngineGameObject_Wrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Input), UnityEngineInputWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.KeyCode), UnityEngineKeyCodeWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.AnimatorStateInfo), UnityEngineAnimatorStateInfoWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Animator), UnityEngineAnimatorWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Application), UnityEngineApplicationWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.AsyncOperation), UnityEngineAsyncOperationWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.AudioClip), UnityEngineAudioClipWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.AudioSource), UnityEngineAudioSourceWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.AssetBundleManifest), UnityEngineAssetBundleManifestWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.AssetBundle), UnityEngineAssetBundleWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.AssetBundleCreateRequest), UnityEngineAssetBundleCreateRequestWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Shader), UnityEngineShaderWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Material), UnityEngineMaterialWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UIBgTextureAdjustor), UIBgTextureAdjustorWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.SystemInfo), UnityEngineSystemInfoWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.BoxCollider), UnityEngineBoxColliderWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Bounds), UnityEngineBoundsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Color), UnityEngineColorWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.LayerMask), UnityEngineLayerMaskWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Mathf), UnityEngineMathfWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Plane), UnityEnginePlaneWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Quaternion), UnityEngineQuaternionWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Ray), UnityEngineRayWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.RaycastHit), UnityEngineRaycastHitWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Time), UnityEngineTimeWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Touch), UnityEngineTouchWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.TouchPhase), UnityEngineTouchPhaseWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Vector2), UnityEngineVector2Wrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Vector3), UnityEngineVector3Wrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Vector4), UnityEngineVector4Wrap.__Register);
        
        }
        
        static void wrapInit1(LuaEnv luaenv, ObjectTranslator translator)
        {
        
            translator.DelayWrapLoader(typeof(UnityEngine.RenderMode), UnityEngineRenderModeWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(GrayscaleEffect), GrayscaleEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Events.UnityEvent), UnityEngineEventsUnityEventWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.QualitySettings), UnityEngineQualitySettingsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Canvas), UnityEngineCanvasWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.CanvasGroup), UnityEngineCanvasGroupWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Rect), UnityEngineRectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.RectTransform), UnityEngineRectTransformWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.RectOffset), UnityEngineRectOffsetWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Sprite), UnityEngineSpriteWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.CanvasScaler), UnityEngineUICanvasScalerWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.CanvasScaler.ScaleMode), UnityEngineUICanvasScalerScaleModeWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.CanvasScaler.ScreenMatchMode), UnityEngineUICanvasScalerScreenMatchModeWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Screen), UnityEngineScreenWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.GraphicRaycaster), UnityEngineUIGraphicRaycasterWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.Text), UnityEngineUITextWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.InputField), UnityEngineUIInputFieldWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.Button), UnityEngineUIButtonWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.Image), UnityEngineUIImageWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.ScrollRect), UnityEngineUIScrollRectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.Scrollbar), UnityEngineUIScrollbarWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.Toggle), UnityEngineUIToggleWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.ToggleGroup), UnityEngineUIToggleGroupWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.Button.ButtonClickedEvent), UnityEngineUIButtonButtonClickedEventWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.ScrollRect.ScrollRectEvent), UnityEngineUIScrollRectScrollRectEventWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.LayoutGroup), UnityEngineUILayoutGroupWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.GridLayoutGroup), UnityEngineUIGridLayoutGroupWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.ContentSizeFitter), UnityEngineUIContentSizeFitterWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.Slider), UnityEngineUISliderWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.RectTransformUtility), UnityEngineRectTransformUtilityWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Texture2D), UnityEngineTexture2DWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.RectMask2D), UnityEngineUIRectMask2DWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UIEventListener), UIEventListenerWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UIDragListener), UIDragListenerWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UIClickListener), UIClickListenerWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.CameraClearFlags), UnityEngineCameraClearFlagsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(SpringContent), SpringContentWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(DOTween.DOTweenShortcut), DOTweenDOTweenShortcutWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(DOTween.DOTween), DOTweenDOTweenWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(DOTween.DOTweenSettings), DOTweenDOTweenSettingsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(DOTween.DOTweenExtensions), DOTweenDOTweenExtensionsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(TweenAlpha), TweenAlphaWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Logger), LoggerWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.ResourceRequest), UnityEngineResourceRequestWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.SceneManagement.SceneManager), UnityEngineSceneManagementSceneManagerWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.SceneManagement.LoadSceneMode), UnityEngineSceneManagementLoadSceneModeWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Battle_Actor.ActorColor), Battle_ActorActorColorWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Battle_Actor.ActorTranslucentColor), Battle_ActorActorTranslucentColorWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.PlayerPrefs), UnityEnginePlayerPrefsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.GC), SystemGCWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Cinemachine.CinemachineVirtualCamera), CinemachineCinemachineVirtualCameraWrap.__Register);
        
        }
        
        static void wrapInit2(LuaEnv luaenv, ObjectTranslator translator)
        {
        
            translator.DelayWrapLoader(typeof(UnityEngine.Playables.PlayableDirector), UnityEnginePlayablesPlayableDirectorWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.Playables.DirectorUpdateMode), UnityEnginePlayablesDirectorUpdateModeWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Cinemachine.CinemachineBrain), CinemachineCinemachineBrainWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Cinemachine.CinemachineTargetGroup), CinemachineCinemachineTargetGroupWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(TMPro.TMP_Text), TMProTMP_TextWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(TMPro.TMP_TextInfo), TMProTMP_TextInfoWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(TMPro.TMP_SubMeshUI), TMProTMP_SubMeshUIWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(TMPro.TextMeshPro), TMProTextMeshProWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(TMPro.TextMeshProUGUI), TMProTextMeshProUGUIWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(TMPro.VertexGradient), TMProVertexGradientWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.TextMesh), UnityEngineTextMeshWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(MatcapMaker), MatcapMakerWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(FlyCurve), FlyCurveWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(CustomDataStruct.StreamBufferPool), CustomDataStructStreamBufferPoolWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(CustomDataStruct.StreamBuffer), CustomDataStructStreamBufferWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.IO.MemoryStream), SystemIOMemoryStreamWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.IO.BinaryReader), SystemIOBinaryReaderWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.IO.BinaryWriter), SystemIOBinaryWriterWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(SimpleHttp), SimpleHttpWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(LoggerHelper), LoggerHelperWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(BuildUtils), BuildUtilsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(DataUtils), DataUtilsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(GameUtility), GameUtilityWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(CommandBehaviour), CommandBehaviourWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(CommandClip), CommandClipWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(CommandClipData), CommandClipDataWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(CommandTrack), CommandTrackWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(DialogClipData), DialogClipDataWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(DialogueBehaviour), DialogueBehaviourWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(DialogueClip), DialogueClipWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(DialogueTrack), DialogueTrackWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(SkipBehaviour), SkipBehaviourWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(SkipClip), SkipClipWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(SkipMixerBehaviour), SkipMixerBehaviourWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(SkipTrack), SkipTrackWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Timeline), TimelineWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(WaitEventBehaviour), WaitEventBehaviourWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(WaitEventClip), WaitEventClipWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(WaitEventTrack), WaitEventTrackWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(AssetBundles.AssetBundleMgr), AssetBundlesAssetBundleMgrWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(AssetBundles.AssetAsyncLoader), AssetBundlesAssetAsyncLoaderWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(AssetBundles.AssetBundleAsyncLoader), AssetBundlesAssetBundleAsyncLoaderWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(AssetBundles.ResourceWebRequester), AssetBundlesResourceWebRequesterWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(AssetBundles.AssetBundleConfig), AssetBundlesAssetBundleConfigWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(AssetBundles.AssetsPathMapping), AssetBundlesAssetsPathMappingWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(AssetBundles.Manifest), AssetBundlesManifestWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(AssetBundles.AssetBundleHelper), AssetBundlesAssetBundleHelperWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(AssetBundles.AssetBundleUtility), AssetBundlesAssetBundleUtilityWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Networks.HjTcpNetwork), NetworksHjTcpNetworkWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UINoticeTip), UINoticeTipWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(GameLaunch), GameLaunchWrap.__Register);
        
        }
        
        static void wrapInit3(LuaEnv luaenv, ObjectTranslator translator)
        {
        
            translator.DelayWrapLoader(typeof(LuaAssetbundleUpdater), LuaAssetbundleUpdaterWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(BgBlurEffect), BgBlurEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(CameraPostRender), CameraPostRenderWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(CloseUpEffect), CloseUpEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(ColorInvertEffect), ColorInvertEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(EyeBlinkEffect), EyeBlinkEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(EyeVisionEffect), EyeVisionEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(FogWithNoise), FogWithNoiseWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Ghosting), GhostingWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(GhostingEffect), GhostingEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(MotionBlurEffect), MotionBlurEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(NewCloseUpEffect), NewCloseUpEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(PostRenderEffectBase), PostRenderEffectBaseWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(RenderTextureMgr), RenderTextureMgrWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(ScreenColorEffect), ScreenColorEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(ScreenShotEffect), ScreenShotEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(ScreenSummonEffect), ScreenSummonEffectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(SDKHelper), SDKHelperWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.LoopHorizontalScrollRect), UnityEngineUILoopHorizontalScrollRectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.LoopScrollSendIndexSource), UnityEngineUILoopScrollSendIndexSourceWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.LoopScrollPrefabSource), UnityEngineUILoopScrollPrefabSourceWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.LoopScrollRect), UnityEngineUILoopScrollRectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.UI.LoopVerticalScrollRect), UnityEngineUILoopVerticalScrollRectWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(SetCanvasBounds), SetCanvasBoundsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UISliderHelper), UISliderHelperWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(BinaryWriterExtentions), BinaryWriterExtentionsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.WaitForSeconds), UnityEngineWaitForSecondsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.WaitForEndOfFrame), UnityEngineWaitForEndOfFrameWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngine.WaitForFixedUpdate), UnityEngineWaitForFixedUpdateWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(UnityEngineObjectExtention), UnityEngineObjectExtentionWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(XLuaHelper), XLuaHelperWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.Array), SystemArrayWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.Collections.IList), SystemCollectionsIListWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.Collections.IDictionary), SystemCollectionsIDictionaryWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.Activator), SystemActivatorWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.Type), SystemTypeWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(System.Reflection.BindingFlags), SystemReflectionBindingFlagsWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(XLuaMessenger), XLuaMessengerWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(MessageName), MessageNameWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(XLuaManager), XLuaManagerWrap.__Register);
        
        
        
        }
        
        static void Init(LuaEnv luaenv, ObjectTranslator translator)
        {
            
            wrapInit0(luaenv, translator);
            
            wrapInit1(luaenv, translator);
            
            wrapInit2(luaenv, translator);
            
            wrapInit3(luaenv, translator);
            
            
            translator.AddInterfaceBridgeCreator(typeof(System.Collections.IEnumerator), SystemCollectionsIEnumeratorBridge.__Create);
            
        }
        
	    static XLua_Gen_Initer_Register__()
        {
		    XLua.LuaEnv.AddIniter(Init);
		}
		
		
	}
	
}
namespace XLua
{
	public partial class ObjectTranslator
	{
		static XLua.CSObjectWrap.XLua_Gen_Initer_Register__ s_gen_reg_dumb_obj = new XLua.CSObjectWrap.XLua_Gen_Initer_Register__();
		static XLua.CSObjectWrap.XLua_Gen_Initer_Register__ gen_reg_dumb_obj {get{return s_gen_reg_dumb_obj;}}
	}
	
	internal partial class InternalGlobals
    {
	    
	    static InternalGlobals()
		{
		    extensionMethodMap = new Dictionary<Type, IEnumerable<MethodInfo>>()
			{
			    
			};
			
			genTryArrayGetPtr = StaticLuaCallbacks.__tryArrayGet;
            genTryArraySetPtr = StaticLuaCallbacks.__tryArraySet;
		}
	}
}
