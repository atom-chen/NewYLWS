#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using XLua;
using System.Collections.Generic;


namespace XLua.CSObjectWrap
{
    using Utils = XLua.Utils;
    public class TimelineWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(Timeline);
			Utils.BeginObjectRegister(type, L, translator, 0, 18, 0, 0);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Init", _m_Init);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Play", _m_Play);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Pause", _m_Pause);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Resume", _m_Resume);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "DialogClipStart", _m_DialogClipStart);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "PauseClipStart", _m_PauseClipStart);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SkipClipStart", _m_SkipClipStart);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "CommandClipStart", _m_CommandClipStart);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "DialogTrackInited", _m_DialogTrackInited);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "CommandTrackInited", _m_CommandTrackInited);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "InitCameraTrack", _m_InitCameraTrack);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "InitCinemachineClip", _m_InitCinemachineClip);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "InitEffectTrack", _m_InitEffectTrack);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "IsTimelineEnd", _m_IsTimelineEnd);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetTimelineBinding", _m_SetTimelineBinding);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetTimelineTrack", _m_GetTimelineTrack);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SkipTo", _m_SkipTo);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetCurTime", _m_GetCurTime);
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 1, 0, 0);
			
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					Timeline gen_ret = new Timeline();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to Timeline constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Init(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Playables.PlayableDirector _playableDirector = (UnityEngine.Playables.PlayableDirector)translator.GetObject(L, 2, typeof(UnityEngine.Playables.PlayableDirector));
                    
                    gen_to_be_invoked.Init( _playableDirector );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Play(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    Timeline.OnDirectorInited _onDirectorInited = translator.GetDelegate<Timeline.OnDirectorInited>(L, 2);
                    Timeline.OnDialogClipStart _onDialogClipStart = translator.GetDelegate<Timeline.OnDialogClipStart>(L, 3);
                    Timeline.OnPauseClipStart _onPauseClipStart = translator.GetDelegate<Timeline.OnPauseClipStart>(L, 4);
                    Timeline.OnSkipClipStart _onSkipClipStart = translator.GetDelegate<Timeline.OnSkipClipStart>(L, 5);
                    Timeline.OnCommandClipStart _onCommandClipStart = translator.GetDelegate<Timeline.OnCommandClipStart>(L, 6);
                    
                    gen_to_be_invoked.Play( _onDirectorInited, _onDialogClipStart, _onPauseClipStart, _onSkipClipStart, _onCommandClipStart );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Pause(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.Pause(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Resume(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.Resume(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DialogClipStart(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    int _index = LuaAPI.xlua_tointeger(L, 2);
                    double _startTime = LuaAPI.lua_tonumber(L, 3);
                    
                    gen_to_be_invoked.DialogClipStart( _index, _startTime );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PauseClipStart(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    int _waitWhatEvent = LuaAPI.xlua_tointeger(L, 2);
                    string _sParam1 = LuaAPI.lua_tostring(L, 3);
                    int _iParam1 = LuaAPI.xlua_tointeger(L, 4);
                    float _fParam1 = (float)LuaAPI.lua_tonumber(L, 5);
                    
                    gen_to_be_invoked.PauseClipStart( _waitWhatEvent, _sParam1, _iParam1, _fParam1 );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SkipClipStart(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    double _timeSkipTo = LuaAPI.lua_tonumber(L, 2);
                    
                    gen_to_be_invoked.SkipClipStart( _timeSkipTo );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CommandClipStart(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    int _index = LuaAPI.xlua_tointeger(L, 2);
                    double _startTime = LuaAPI.lua_tonumber(L, 3);
                    
                    gen_to_be_invoked.CommandClipStart( _index, _startTime );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DialogTrackInited(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    System.Collections.Generic.List<DialogClipData> _dataList = (System.Collections.Generic.List<DialogClipData>)translator.GetObject(L, 2, typeof(System.Collections.Generic.List<DialogClipData>));
                    
                    gen_to_be_invoked.DialogTrackInited( _dataList );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CommandTrackInited(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    System.Collections.Generic.List<CommandClipData> _dataList = (System.Collections.Generic.List<CommandClipData>)translator.GetObject(L, 2, typeof(System.Collections.Generic.List<CommandClipData>));
                    
                    gen_to_be_invoked.CommandTrackInited( _dataList );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_InitCameraTrack(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Object _trackObject = (UnityEngine.Object)translator.GetObject(L, 2, typeof(UnityEngine.Object));
                    
                    gen_to_be_invoked.InitCameraTrack( _trackObject );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_InitCinemachineClip(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Timeline.TimelineClip _clip = (UnityEngine.Timeline.TimelineClip)translator.GetObject(L, 2, typeof(UnityEngine.Timeline.TimelineClip));
                    
                    gen_to_be_invoked.InitCinemachineClip( _clip );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_InitEffectTrack(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Object _trackObject = (UnityEngine.Object)translator.GetObject(L, 2, typeof(UnityEngine.Object));
                    string _key = LuaAPI.lua_tostring(L, 3);
                    UnityEngine.GameObject _parent = (UnityEngine.GameObject)translator.GetObject(L, 4, typeof(UnityEngine.GameObject));
                    UnityEngine.GameObject _prefab = (UnityEngine.GameObject)translator.GetObject(L, 5, typeof(UnityEngine.GameObject));
                    
                    gen_to_be_invoked.InitEffectTrack( _trackObject, _key, _parent, _prefab );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsTimelineEnd(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        bool gen_ret = gen_to_be_invoked.IsTimelineEnd(  );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetTimelineBinding(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string _key = LuaAPI.lua_tostring(L, 2);
                    UnityEngine.Object _value = (UnityEngine.Object)translator.GetObject(L, 3, typeof(UnityEngine.Object));
                    
                        UnityEngine.Object gen_ret = gen_to_be_invoked.SetTimelineBinding( _key, _value );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetTimelineTrack(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string _key = LuaAPI.lua_tostring(L, 2);
                    
                        UnityEngine.Object gen_ret = gen_to_be_invoked.GetTimelineTrack( _key );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SkipTo(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    double _time = LuaAPI.lua_tonumber(L, 2);
                    bool _skipToEnd = LuaAPI.lua_toboolean(L, 3);
                    
                    gen_to_be_invoked.SkipTo( _time, _skipToEnd );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetCurTime(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Timeline gen_to_be_invoked = (Timeline)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        double gen_ret = gen_to_be_invoked.GetCurTime(  );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        
        
		
		
		
		
    }
}
