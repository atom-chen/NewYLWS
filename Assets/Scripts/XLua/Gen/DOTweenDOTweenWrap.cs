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
    public class DOTweenDOTweenWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(DOTween.DOTween);
			Utils.BeginObjectRegister(type, L, translator, 0, 0, 0, 0);
			
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 34, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "Clear", _m_Clear_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Kill", _m_Kill_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "KillAll", _m_KillAll_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ClearCachedTweens", _m_ClearCachedTweens_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CompleteAll", _m_CompleteAll_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Pause", _m_Pause_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "PauseAll", _m_PauseAll_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "PlayAll", _m_PlayAll_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Punch", _m_Punch_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Restart", _m_Restart_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "RestartAll", _m_RestartAll_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetTweensCapacity", _m_SetTweensCapacity_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Shake", _m_Shake_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToColorValue", _m_ToColorValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToDoubleValue", _m_ToDoubleValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToFloatValue", _m_ToFloatValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "To", _m_To_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToIntValue", _m_ToIntValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToLongValue", _m_ToLongValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToQuaternionValue", _m_ToQuaternionValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToRectValue", _m_ToRectValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToRectOffsetValue", _m_ToRectOffsetValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToStringValue", _m_ToStringValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToUintValue", _m_ToUintValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToUlongValue", _m_ToUlongValue_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToVector2Value", _m_ToVector2Value_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToVector3Value", _m_ToVector3Value_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToVector4Value", _m_ToVector4Value_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToFloatValue2", _m_ToFloatValue2_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToAlpha", _m_ToAlpha_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToArray", _m_ToArray_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ToAxis", _m_ToAxis_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "NewSequence", _m_NewSequence_xlua_st_);
            
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					DOTween.DOTween gen_ret = new DOTween.DOTween();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTween constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Clear_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 1)) 
                {
                    bool _destroy = LuaAPI.lua_toboolean(L, 1);
                    
                    DOTween.DOTween.Clear( _destroy );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 0) 
                {
                    
                    DOTween.DOTween.Clear(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTween.Clear!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Kill_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<object>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    object _targetOrId = translator.GetObject(L, 1, typeof(object));
                    bool _complete = LuaAPI.lua_toboolean(L, 2);
                    
                    DOTween.DOTween.Kill( _targetOrId, _complete );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 1&& translator.Assignable<object>(L, 1)) 
                {
                    object _targetOrId = translator.GetObject(L, 1, typeof(object));
                    
                    DOTween.DOTween.Kill( _targetOrId );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTween.Kill!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_KillAll_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 1)) 
                {
                    bool _complete = LuaAPI.lua_toboolean(L, 1);
                    
                        int gen_ret = DOTween.DOTween.KillAll( _complete );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 0) 
                {
                    
                        int gen_ret = DOTween.DOTween.KillAll(  );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTween.KillAll!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ClearCachedTweens_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    
                    DOTween.DOTween.ClearCachedTweens(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CompleteAll_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 1)) 
                {
                    bool _withCallbacks = LuaAPI.lua_toboolean(L, 1);
                    
                        int gen_ret = DOTween.DOTween.CompleteAll( _withCallbacks );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 0) 
                {
                    
                        int gen_ret = DOTween.DOTween.CompleteAll(  );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTween.CompleteAll!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Pause_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    object _targetOrId = translator.GetObject(L, 1, typeof(object));
                    
                        int gen_ret = DOTween.DOTween.Pause( _targetOrId );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PauseAll_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    
                        int gen_ret = DOTween.DOTween.PauseAll(  );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PlayAll_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    
                        int gen_ret = DOTween.DOTween.PlayAll(  );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Punch_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 6&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    UnityEngine.Vector3 _direction;translator.Get(L, 3, out _direction);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 5);
                    float _elasticity = (float)LuaAPI.lua_tonumber(L, 6);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Punch( _getter, _setter, _direction, _duration, _vibrato, _elasticity );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    UnityEngine.Vector3 _direction;translator.Get(L, 3, out _direction);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 5);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Punch( _getter, _setter, _direction, _duration, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    UnityEngine.Vector3 _direction;translator.Get(L, 3, out _direction);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Punch( _getter, _setter, _direction, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTween.Punch!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Restart_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<object>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    object _targetOrId = translator.GetObject(L, 1, typeof(object));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 2);
                    float _changeDelayTo = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        int gen_ret = DOTween.DOTween.Restart( _targetOrId, _includeDelay, _changeDelayTo );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<object>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    object _targetOrId = translator.GetObject(L, 1, typeof(object));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 2);
                    
                        int gen_ret = DOTween.DOTween.Restart( _targetOrId, _includeDelay );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<object>(L, 1)) 
                {
                    object _targetOrId = translator.GetObject(L, 1, typeof(object));
                    
                        int gen_ret = DOTween.DOTween.Restart( _targetOrId );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<object>(L, 1)&& translator.Assignable<object>(L, 2)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    object _target = translator.GetObject(L, 1, typeof(object));
                    object _id = translator.GetObject(L, 2, typeof(object));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 3);
                    float _changeDelayTo = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        int gen_ret = DOTween.DOTween.Restart( _target, _id, _includeDelay, _changeDelayTo );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<object>(L, 1)&& translator.Assignable<object>(L, 2)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)) 
                {
                    object _target = translator.GetObject(L, 1, typeof(object));
                    object _id = translator.GetObject(L, 2, typeof(object));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 3);
                    
                        int gen_ret = DOTween.DOTween.Restart( _target, _id, _includeDelay );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<object>(L, 1)&& translator.Assignable<object>(L, 2)) 
                {
                    object _target = translator.GetObject(L, 1, typeof(object));
                    object _id = translator.GetObject(L, 2, typeof(object));
                    
                        int gen_ret = DOTween.DOTween.Restart( _target, _id );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTween.Restart!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RestartAll_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 1)) 
                {
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 1);
                    
                        int gen_ret = DOTween.DOTween.RestartAll( _includeDelay );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 0) 
                {
                    
                        int gen_ret = DOTween.DOTween.RestartAll(  );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTween.RestartAll!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetTweensCapacity_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    int _tweenersCapacity = LuaAPI.xlua_tointeger(L, 1);
                    int _sequencesCapacity = LuaAPI.xlua_tointeger(L, 2);
                    
                    DOTween.DOTween.SetTweensCapacity( _tweenersCapacity, _sequencesCapacity );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Shake_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 8&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 7)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 8)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 4);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 5);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 6);
                    bool _ignoreZAxis = LuaAPI.lua_toboolean(L, 7);
                    bool _fadeOut = LuaAPI.lua_toboolean(L, 8);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Shake( _getter, _setter, _duration, _strength, _vibrato, _randomness, _ignoreZAxis, _fadeOut );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 7&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 7)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 4);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 5);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 6);
                    bool _ignoreZAxis = LuaAPI.lua_toboolean(L, 7);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Shake( _getter, _setter, _duration, _strength, _vibrato, _randomness, _ignoreZAxis );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 4);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 5);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 6);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Shake( _getter, _setter, _duration, _strength, _vibrato, _randomness );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 4);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 5);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Shake( _getter, _setter, _duration, _strength, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Shake( _getter, _setter, _duration, _strength );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Shake( _getter, _setter, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 7&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<UnityEngine.Vector3>(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 7)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    UnityEngine.Vector3 _strength;translator.Get(L, 4, out _strength);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 5);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 6);
                    bool _fadeOut = LuaAPI.lua_toboolean(L, 7);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Shake( _getter, _setter, _duration, _strength, _vibrato, _randomness, _fadeOut );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<UnityEngine.Vector3>(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    UnityEngine.Vector3 _strength;translator.Get(L, 4, out _strength);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 5);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 6);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Shake( _getter, _setter, _duration, _strength, _vibrato, _randomness );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<UnityEngine.Vector3>(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    UnityEngine.Vector3 _strength;translator.Get(L, 4, out _strength);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 5);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Shake( _getter, _setter, _duration, _strength, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<UnityEngine.Vector3>(L, 4)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    UnityEngine.Vector3 _strength;translator.Get(L, 4, out _strength);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.Shake( _getter, _setter, _duration, _strength );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTween.Shake!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToColorValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Color> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Color>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Color> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Color>>(L, 2);
                    UnityEngine.Color _endValue;translator.Get(L, 3, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Color, UnityEngine.Color, DG.Tweening.Plugins.Options.ColorOptions> gen_ret = DOTween.DOTween.ToColorValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToDoubleValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<double> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<double>>(L, 1);
                    DG.Tweening.Core.DOSetter<double> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<double>>(L, 2);
                    double _endValue = LuaAPI.lua_tonumber(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<double, double, DG.Tweening.Plugins.Options.NoOptions> gen_ret = DOTween.DOTween.ToDoubleValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToFloatValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<float> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<float>>(L, 1);
                    DG.Tweening.Core.DOSetter<float> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<float>>(L, 2);
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<float, float, DG.Tweening.Plugins.Options.FloatOptions> gen_ret = DOTween.DOTween.ToFloatValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_To_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOSetter<float> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<float>>(L, 1);
                    float _startValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTween.To( _setter, _startValue, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToIntValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<int> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<int>>(L, 1);
                    DG.Tweening.Core.DOSetter<int> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<int>>(L, 2);
                    int _endValue = LuaAPI.xlua_tointeger(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTween.ToIntValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToLongValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<long> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<long>>(L, 1);
                    DG.Tweening.Core.DOSetter<long> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<long>>(L, 2);
                    long _endValue = LuaAPI.lua_toint64(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTween.ToLongValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToQuaternionValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Quaternion> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Quaternion>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Quaternion> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Quaternion>>(L, 2);
                    UnityEngine.Vector3 _endValue;translator.Get(L, 3, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Quaternion, UnityEngine.Vector3, DG.Tweening.Plugins.Options.QuaternionOptions> gen_ret = DOTween.DOTween.ToQuaternionValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToRectValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Rect> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Rect>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Rect> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Rect>>(L, 2);
                    UnityEngine.Rect _endValue;translator.Get(L, 3, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Rect, UnityEngine.Rect, DG.Tweening.Plugins.Options.RectOptions> gen_ret = DOTween.DOTween.ToRectValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToRectOffsetValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.RectOffset> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.RectOffset>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.RectOffset> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.RectOffset>>(L, 2);
                    UnityEngine.RectOffset _endValue = (UnityEngine.RectOffset)translator.GetObject(L, 3, typeof(UnityEngine.RectOffset));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTween.ToRectOffsetValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToStringValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<string> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<string>>(L, 1);
                    DG.Tweening.Core.DOSetter<string> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<string>>(L, 2);
                    string _endValue = LuaAPI.lua_tostring(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<string, string, DG.Tweening.Plugins.Options.StringOptions> gen_ret = DOTween.DOTween.ToStringValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToUintValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<uint> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<uint>>(L, 1);
                    DG.Tweening.Core.DOSetter<uint> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<uint>>(L, 2);
                    uint _endValue = LuaAPI.xlua_touint(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTween.ToUintValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToUlongValue_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<ulong> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<ulong>>(L, 1);
                    DG.Tweening.Core.DOSetter<ulong> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<ulong>>(L, 2);
                    ulong _endValue = LuaAPI.lua_touint64(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTween.ToUlongValue( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToVector2Value_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector2> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector2>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector2> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector2>>(L, 2);
                    UnityEngine.Vector2 _endValue;translator.Get(L, 3, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector2, UnityEngine.Vector2, DG.Tweening.Plugins.Options.VectorOptions> gen_ret = DOTween.DOTween.ToVector2Value( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToVector3Value_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    UnityEngine.Vector3 _endValue;translator.Get(L, 3, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3, DG.Tweening.Plugins.Options.VectorOptions> gen_ret = DOTween.DOTween.ToVector3Value( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToVector4Value_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector4> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector4>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector4> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector4>>(L, 2);
                    UnityEngine.Vector4 _endValue;translator.Get(L, 3, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector4, UnityEngine.Vector4, DG.Tweening.Plugins.Options.VectorOptions> gen_ret = DOTween.DOTween.ToVector4Value( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToFloatValue2_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOSetter<float> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<float>>(L, 1);
                    float _startValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTween.ToFloatValue2( _setter, _startValue, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToAlpha_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Color> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Color>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Color> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Color>>(L, 2);
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTween.ToAlpha( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToArray_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    UnityEngine.Vector3[] _endValues = (UnityEngine.Vector3[])translator.GetObject(L, 3, typeof(UnityEngine.Vector3[]));
                    float[] _durations = (float[])translator.GetObject(L, 4, typeof(float[]));
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> gen_ret = DOTween.DOTween.ToArray( _getter, _setter, _endValues, _durations );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ToAxis_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 5&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& translator.Assignable<DG.Tweening.AxisConstraint>(L, 5)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    DG.Tweening.AxisConstraint _axisConstraint;translator.Get(L, 5, out _axisConstraint);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3, DG.Tweening.Plugins.Options.VectorOptions> gen_ret = DOTween.DOTween.ToAxis( _getter, _setter, _endValue, _duration, _axisConstraint );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1)&& translator.Assignable<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    DG.Tweening.Core.DOGetter<UnityEngine.Vector3> _getter = translator.GetDelegate<DG.Tweening.Core.DOGetter<UnityEngine.Vector3>>(L, 1);
                    DG.Tweening.Core.DOSetter<UnityEngine.Vector3> _setter = translator.GetDelegate<DG.Tweening.Core.DOSetter<UnityEngine.Vector3>>(L, 2);
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, UnityEngine.Vector3, DG.Tweening.Plugins.Options.VectorOptions> gen_ret = DOTween.DOTween.ToAxis( _getter, _setter, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTween.ToAxis!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_NewSequence_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    
                        DG.Tweening.Sequence gen_ret = DOTween.DOTween.NewSequence(  );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        
        
		
		
		
		
    }
}
