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
    public class DOTweenDOTweenShortcutWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(DOTween.DOTweenShortcut);
			Utils.BeginObjectRegister(type, L, translator, 0, 0, 0, 0);
			
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 68, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "DOAspect", _m_DOAspect_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOBlendableColor", _m_DOBlendableColor_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOBlendableLocalMoveBy", _m_DOBlendableLocalMoveBy_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOBlendableLocalRotateBy", _m_DOBlendableLocalRotateBy_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOBlendableMoveBy", _m_DOBlendableMoveBy_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOBlendableRotateBy", _m_DOBlendableRotateBy_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOBlendableScaleBy", _m_DOBlendableScaleBy_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOColor", _m_DOColor_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOTextColor", _m_DOTextColor_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DoImgColor", _m_DoImgColor_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOComplete", _m_DOComplete_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOFade", _m_DOFade_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOFarClipPlane", _m_DOFarClipPlane_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOFieldOfView", _m_DOFieldOfView_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOFlip", _m_DOFlip_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOFloat", _m_DOFloat_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOGoto", _m_DOGoto_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOIntensity", _m_DOIntensity_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOJump", _m_DOJump_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOKill", _m_DOKill_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOLocalJump", _m_DOLocalJump_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOLocalMove", _m_DOLocalMove_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOLocalMoveX", _m_DOLocalMoveX_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOLocalMoveY", _m_DOLocalMoveY_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOLocalMoveZ", _m_DOLocalMoveZ_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOLocalPath", _m_DOLocalPath_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOLocalRotate", _m_DOLocalRotate_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOLocalRotateQuaternion", _m_DOLocalRotateQuaternion_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOLookAt", _m_DOLookAt_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOMove", _m_DOMove_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOMoveX", _m_DOMoveX_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOMoveY", _m_DOMoveY_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOMoveZ", _m_DOMoveZ_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DONearClipPlane", _m_DONearClipPlane_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOOffset", _m_DOOffset_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOOrthoSize", _m_DOOrthoSize_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOPath", _m_DOPath_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOPause", _m_DOPause_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOPitch", _m_DOPitch_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOPixelRect", _m_DOPixelRect_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOPlay", _m_DOPlay_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOPlayBackwards", _m_DOPlayBackwards_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOPlayForward", _m_DOPlayForward_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOPunchPosition", _m_DOPunchPosition_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOPunchRotation", _m_DOPunchRotation_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOPunchScale", _m_DOPunchScale_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DORect", _m_DORect_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOResize", _m_DOResize_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DORestart", _m_DORestart_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DORewind", _m_DORewind_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DORotate", _m_DORotate_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DORotateQuaternion", _m_DORotateQuaternion_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOScale", _m_DOScale_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOScaleX", _m_DOScaleX_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOScaleY", _m_DOScaleY_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOScaleZ", _m_DOScaleZ_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOShadowStrength", _m_DOShadowStrength_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOShakePosition", _m_DOShakePosition_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOShakeRotation", _m_DOShakeRotation_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOShakeScale", _m_DOShakeScale_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOSmoothRewind", _m_DOSmoothRewind_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOTiling", _m_DOTiling_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOTime", _m_DOTime_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOTimeScale", _m_DOTimeScale_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOTogglePause", _m_DOTogglePause_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOVector", _m_DOVector_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DOFillAmount", _m_DOFillAmount_xlua_st_);
            
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					DOTween.DOTweenShortcut gen_ret = new DOTween.DOTweenShortcut();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOAspect_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOAspect( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOBlendableColor_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Light>(L, 1)&& translator.Assignable<UnityEngine.Color>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Light _target = (UnityEngine.Light)translator.GetObject(L, 1, typeof(UnityEngine.Light));
                    UnityEngine.Color _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableColor( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Material>(L, 1)&& translator.Assignable<UnityEngine.Color>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    UnityEngine.Color _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableColor( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Material>(L, 1)&& translator.Assignable<UnityEngine.Color>(L, 2)&& (LuaAPI.lua_isnil(L, 3) || LuaAPI.lua_type(L, 3) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    UnityEngine.Color _endValue;translator.Get(L, 2, out _endValue);
                    string _property = LuaAPI.lua_tostring(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableColor( _target, _endValue, _property, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOBlendableColor!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOBlendableLocalMoveBy_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _byValue;translator.Get(L, 2, out _byValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableLocalMoveBy( _target, _byValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _byValue;translator.Get(L, 2, out _byValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableLocalMoveBy( _target, _byValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOBlendableLocalMoveBy!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOBlendableLocalRotateBy_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.RotateMode>(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _byValue;translator.Get(L, 2, out _byValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.RotateMode _mode;translator.Get(L, 4, out _mode);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableLocalRotateBy( _target, _byValue, _duration, _mode );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _byValue;translator.Get(L, 2, out _byValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableLocalRotateBy( _target, _byValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOBlendableLocalRotateBy!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOBlendableMoveBy_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _byValue;translator.Get(L, 2, out _byValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableMoveBy( _target, _byValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _byValue;translator.Get(L, 2, out _byValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableMoveBy( _target, _byValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOBlendableMoveBy!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOBlendableRotateBy_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.RotateMode>(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _byValue;translator.Get(L, 2, out _byValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.RotateMode _mode;translator.Get(L, 4, out _mode);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableRotateBy( _target, _byValue, _duration, _mode );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _byValue;translator.Get(L, 2, out _byValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableRotateBy( _target, _byValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOBlendableRotateBy!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOBlendableScaleBy_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _byValue;translator.Get(L, 2, out _byValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOBlendableScaleBy( _target, _byValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOColor_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Camera>(L, 1)&& translator.Assignable<UnityEngine.Color>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    UnityEngine.Color _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOColor( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Light>(L, 1)&& translator.Assignable<UnityEngine.Color>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Light _target = (UnityEngine.Light)translator.GetObject(L, 1, typeof(UnityEngine.Light));
                    UnityEngine.Color _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOColor( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Material>(L, 1)&& translator.Assignable<UnityEngine.Color>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    UnityEngine.Color _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOColor( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.LineRenderer>(L, 1)&& translator.Assignable<DG.Tweening.Color2>(L, 2)&& translator.Assignable<DG.Tweening.Color2>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.LineRenderer _target = (UnityEngine.LineRenderer)translator.GetObject(L, 1, typeof(UnityEngine.LineRenderer));
                    DG.Tweening.Color2 _startValue;translator.Get(L, 2, out _startValue);
                    DG.Tweening.Color2 _endValue;translator.Get(L, 3, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOColor( _target, _startValue, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Material>(L, 1)&& translator.Assignable<UnityEngine.Color>(L, 2)&& (LuaAPI.lua_isnil(L, 3) || LuaAPI.lua_type(L, 3) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    UnityEngine.Color _endValue;translator.Get(L, 2, out _endValue);
                    string _property = LuaAPI.lua_tostring(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOColor( _target, _endValue, _property, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOColor!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOTextColor_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.UI.Text _target = (UnityEngine.UI.Text)translator.GetObject(L, 1, typeof(UnityEngine.UI.Text));
                    UnityEngine.Color _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOTextColor( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DoImgColor_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.UI.Image _image = (UnityEngine.UI.Image)translator.GetObject(L, 1, typeof(UnityEngine.UI.Image));
                    UnityEngine.Color _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DoImgColor( _image, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOComplete_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Component>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    bool _withCallbacks = LuaAPI.lua_toboolean(L, 2);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOComplete( _target, _withCallbacks );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOComplete( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Material>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    bool _withCallbacks = LuaAPI.lua_toboolean(L, 2);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOComplete( _target, _withCallbacks );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOComplete( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOComplete!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOFade_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.AudioSource>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.AudioSource _target = (UnityEngine.AudioSource)translator.GetObject(L, 1, typeof(UnityEngine.AudioSource));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOFade( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Material>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOFade( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Material>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& (LuaAPI.lua_isnil(L, 3) || LuaAPI.lua_type(L, 3) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    string _property = LuaAPI.lua_tostring(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOFade( _target, _endValue, _property, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOFade!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOFarClipPlane_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOFarClipPlane( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOFieldOfView_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOFieldOfView( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOFlip_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOFlip( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOFlip( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOFlip!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOFloat_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    string _property = LuaAPI.lua_tostring(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOFloat( _target, _endValue, _property, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOGoto_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Component>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    float _to = (float)LuaAPI.lua_tonumber(L, 2);
                    bool _andPlay = LuaAPI.lua_toboolean(L, 3);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOGoto( _target, _to, _andPlay );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Component>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    float _to = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOGoto( _target, _to );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Material>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    float _to = (float)LuaAPI.lua_tonumber(L, 2);
                    bool _andPlay = LuaAPI.lua_toboolean(L, 3);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOGoto( _target, _to, _andPlay );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Material>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    float _to = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOGoto( _target, _to );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOGoto!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOIntensity_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Light _target = (UnityEngine.Light)translator.GetObject(L, 1, typeof(UnityEngine.Light));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOIntensity( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOJump_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _jumpPower = (float)LuaAPI.lua_tonumber(L, 3);
                    int _numJumps = LuaAPI.xlua_tointeger(L, 4);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _snapping = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Sequence gen_ret = DOTween.DOTweenShortcut.DOJump( _target, _endValue, _jumpPower, _numJumps, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _jumpPower = (float)LuaAPI.lua_tonumber(L, 3);
                    int _numJumps = LuaAPI.xlua_tointeger(L, 4);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Sequence gen_ret = DOTween.DOTweenShortcut.DOJump( _target, _endValue, _jumpPower, _numJumps, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _jumpPower = (float)LuaAPI.lua_tonumber(L, 3);
                    int _numJumps = LuaAPI.xlua_tointeger(L, 4);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _snapping = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Sequence gen_ret = DOTween.DOTweenShortcut.DOJump( _target, _endValue, _jumpPower, _numJumps, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _jumpPower = (float)LuaAPI.lua_tonumber(L, 3);
                    int _numJumps = LuaAPI.xlua_tointeger(L, 4);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Sequence gen_ret = DOTween.DOTweenShortcut.DOJump( _target, _endValue, _jumpPower, _numJumps, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOJump!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOKill_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Component>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    bool _complete = LuaAPI.lua_toboolean(L, 2);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOKill( _target, _complete );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOKill( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Material>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    bool _complete = LuaAPI.lua_toboolean(L, 2);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOKill( _target, _complete );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOKill( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOKill!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOLocalJump_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _jumpPower = (float)LuaAPI.lua_tonumber(L, 3);
                    int _numJumps = LuaAPI.xlua_tointeger(L, 4);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _snapping = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Sequence gen_ret = DOTween.DOTweenShortcut.DOLocalJump( _target, _endValue, _jumpPower, _numJumps, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _jumpPower = (float)LuaAPI.lua_tonumber(L, 3);
                    int _numJumps = LuaAPI.xlua_tointeger(L, 4);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Sequence gen_ret = DOTween.DOTweenShortcut.DOLocalJump( _target, _endValue, _jumpPower, _numJumps, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOLocalJump!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOLocalMove_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalMove( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalMove( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOLocalMove!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOLocalMoveX_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalMoveX( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalMoveX( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOLocalMoveX!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOLocalMoveY_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalMoveY( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalMoveY( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOLocalMoveY!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOLocalMoveZ_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalMoveZ( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalMoveZ( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOLocalMoveZ!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOLocalPath_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 7&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)&& translator.Assignable<System.Nullable<UnityEngine.Color>>(L, 7)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    int _resolution = LuaAPI.xlua_tointeger(L, 6);
                    System.Nullable<UnityEngine.Color> _gizmoColor;translator.Get(L, 7, out _gizmoColor);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOLocalPath( _target, _path, _duration, _pathType, _pathMode, _resolution, _gizmoColor );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    int _resolution = LuaAPI.xlua_tointeger(L, 6);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOLocalPath( _target, _path, _duration, _pathType, _pathMode, _resolution );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOLocalPath( _target, _path, _duration, _pathType, _pathMode );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOLocalPath( _target, _path, _duration, _pathType );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOLocalPath( _target, _path, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 7&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)&& translator.Assignable<System.Nullable<UnityEngine.Color>>(L, 7)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    int _resolution = LuaAPI.xlua_tointeger(L, 6);
                    System.Nullable<UnityEngine.Color> _gizmoColor;translator.Get(L, 7, out _gizmoColor);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOLocalPath( _target, _path, _duration, _pathType, _pathMode, _resolution, _gizmoColor );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    int _resolution = LuaAPI.xlua_tointeger(L, 6);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOLocalPath( _target, _path, _duration, _pathType, _pathMode, _resolution );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOLocalPath( _target, _path, _duration, _pathType, _pathMode );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOLocalPath( _target, _path, _duration, _pathType );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOLocalPath( _target, _path, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOLocalPath!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOLocalRotate_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.RotateMode>(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.RotateMode _mode;translator.Get(L, 4, out _mode);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalRotate( _target, _endValue, _duration, _mode );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalRotate( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOLocalRotate!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOLocalRotateQuaternion_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Quaternion _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLocalRotateQuaternion( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOLookAt_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.AxisConstraint>(L, 4)&& translator.Assignable<System.Nullable<UnityEngine.Vector3>>(L, 5)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3 _towards;translator.Get(L, 2, out _towards);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.AxisConstraint _axisConstraint;translator.Get(L, 4, out _axisConstraint);
                    System.Nullable<UnityEngine.Vector3> _up;translator.Get(L, 5, out _up);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLookAt( _target, _towards, _duration, _axisConstraint, _up );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.AxisConstraint>(L, 4)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3 _towards;translator.Get(L, 2, out _towards);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.AxisConstraint _axisConstraint;translator.Get(L, 4, out _axisConstraint);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLookAt( _target, _towards, _duration, _axisConstraint );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3 _towards;translator.Get(L, 2, out _towards);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLookAt( _target, _towards, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.AxisConstraint>(L, 4)&& translator.Assignable<System.Nullable<UnityEngine.Vector3>>(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _towards;translator.Get(L, 2, out _towards);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.AxisConstraint _axisConstraint;translator.Get(L, 4, out _axisConstraint);
                    System.Nullable<UnityEngine.Vector3> _up;translator.Get(L, 5, out _up);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLookAt( _target, _towards, _duration, _axisConstraint, _up );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.AxisConstraint>(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _towards;translator.Get(L, 2, out _towards);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.AxisConstraint _axisConstraint;translator.Get(L, 4, out _axisConstraint);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLookAt( _target, _towards, _duration, _axisConstraint );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _towards;translator.Get(L, 2, out _towards);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOLookAt( _target, _towards, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOLookAt!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOMove_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMove( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMove( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMove( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMove( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOMove!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOMoveX_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveX( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveX( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveX( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveX( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOMoveX!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOMoveY_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveY( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveY( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveY( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveY( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOMoveY!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOMoveZ_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveZ( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveZ( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    bool _snapping = LuaAPI.lua_toboolean(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveZ( _target, _endValue, _duration, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOMoveZ( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOMoveZ!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DONearClipPlane_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DONearClipPlane( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOOffset_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Material>(L, 1)&& translator.Assignable<UnityEngine.Vector2>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    UnityEngine.Vector2 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOOffset( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Material>(L, 1)&& translator.Assignable<UnityEngine.Vector2>(L, 2)&& (LuaAPI.lua_isnil(L, 3) || LuaAPI.lua_type(L, 3) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    UnityEngine.Vector2 _endValue;translator.Get(L, 2, out _endValue);
                    string _property = LuaAPI.lua_tostring(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOOffset( _target, _endValue, _property, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOOffset!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOOrthoSize_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOOrthoSize( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOPath_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 7&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)&& translator.Assignable<System.Nullable<UnityEngine.Color>>(L, 7)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    int _resolution = LuaAPI.xlua_tointeger(L, 6);
                    System.Nullable<UnityEngine.Color> _gizmoColor;translator.Get(L, 7, out _gizmoColor);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOPath( _target, _path, _duration, _pathType, _pathMode, _resolution, _gizmoColor );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    int _resolution = LuaAPI.xlua_tointeger(L, 6);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOPath( _target, _path, _duration, _pathType, _pathMode, _resolution );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOPath( _target, _path, _duration, _pathType, _pathMode );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOPath( _target, _path, _duration, _pathType );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOPath( _target, _path, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 7&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)&& translator.Assignable<System.Nullable<UnityEngine.Color>>(L, 7)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    int _resolution = LuaAPI.xlua_tointeger(L, 6);
                    System.Nullable<UnityEngine.Color> _gizmoColor;translator.Get(L, 7, out _gizmoColor);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOPath( _target, _path, _duration, _pathType, _pathMode, _resolution, _gizmoColor );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    int _resolution = LuaAPI.xlua_tointeger(L, 6);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOPath( _target, _path, _duration, _pathType, _pathMode, _resolution );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)&& translator.Assignable<DG.Tweening.PathMode>(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    DG.Tweening.PathMode _pathMode;translator.Get(L, 5, out _pathMode);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOPath( _target, _path, _duration, _pathType, _pathMode );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.PathType>(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.PathType _pathType;translator.Get(L, 4, out _pathType);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOPath( _target, _path, _duration, _pathType );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3[]>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3[] _path = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Core.TweenerCore<UnityEngine.Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> gen_ret = DOTween.DOTweenShortcut.DOPath( _target, _path, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOPath!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOPause_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOPause( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOPause( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOPause!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOPitch_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.AudioSource _target = (UnityEngine.AudioSource)translator.GetObject(L, 1, typeof(UnityEngine.AudioSource));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPitch( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOPixelRect_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    UnityEngine.Rect _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPixelRect( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOPlay_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOPlay( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOPlay( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOPlay!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOPlayBackwards_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOPlayBackwards( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOPlayBackwards( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOPlayBackwards!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOPlayForward_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOPlayForward( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOPlayForward( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOPlayForward!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOPunchPosition_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _punch;translator.Get(L, 2, out _punch);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _elasticity = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _snapping = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPunchPosition( _target, _punch, _duration, _vibrato, _elasticity, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _punch;translator.Get(L, 2, out _punch);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _elasticity = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPunchPosition( _target, _punch, _duration, _vibrato, _elasticity );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _punch;translator.Get(L, 2, out _punch);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPunchPosition( _target, _punch, _duration, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _punch;translator.Get(L, 2, out _punch);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPunchPosition( _target, _punch, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOPunchPosition!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOPunchRotation_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _punch;translator.Get(L, 2, out _punch);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _elasticity = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPunchRotation( _target, _punch, _duration, _vibrato, _elasticity );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _punch;translator.Get(L, 2, out _punch);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPunchRotation( _target, _punch, _duration, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _punch;translator.Get(L, 2, out _punch);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPunchRotation( _target, _punch, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOPunchRotation!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOPunchScale_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _punch;translator.Get(L, 2, out _punch);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _elasticity = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPunchScale( _target, _punch, _duration, _vibrato, _elasticity );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _punch;translator.Get(L, 2, out _punch);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPunchScale( _target, _punch, _duration, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _punch;translator.Get(L, 2, out _punch);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOPunchScale( _target, _punch, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOPunchScale!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DORect_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    UnityEngine.Rect _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DORect( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOResize_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.TrailRenderer _target = (UnityEngine.TrailRenderer)translator.GetObject(L, 1, typeof(UnityEngine.TrailRenderer));
                    float _toStartWidth = (float)LuaAPI.lua_tonumber(L, 2);
                    float _toEndWidth = (float)LuaAPI.lua_tonumber(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOResize( _target, _toStartWidth, _toEndWidth, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DORestart_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Component>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 2);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DORestart( _target, _includeDelay );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DORestart( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Material>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 2);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DORestart( _target, _includeDelay );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DORestart( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DORestart!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DORewind_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Component>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 2);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DORewind( _target, _includeDelay );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DORewind( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Material>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 2);
                    
                        int gen_ret = DOTween.DOTweenShortcut.DORewind( _target, _includeDelay );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DORewind( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DORewind!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DORotate_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.RotateMode>(L, 4)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.RotateMode _mode;translator.Get(L, 4, out _mode);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DORotate( _target, _endValue, _duration, _mode );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Rigidbody>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Rigidbody _target = (UnityEngine.Rigidbody)translator.GetObject(L, 1, typeof(UnityEngine.Rigidbody));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DORotate( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& translator.Assignable<DG.Tweening.RotateMode>(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    DG.Tweening.RotateMode _mode;translator.Get(L, 4, out _mode);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DORotate( _target, _endValue, _duration, _mode );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DORotate( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DORotate!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DORotateQuaternion_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Quaternion _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DORotateQuaternion( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOScale_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOScale( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOScale( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOScale!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOScaleX_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOScaleX( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOScaleY_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOScaleY( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOScaleZ_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOScaleZ( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOShadowStrength_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Light _target = (UnityEngine.Light)translator.GetObject(L, 1, typeof(UnityEngine.Light));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShadowStrength( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOShakePosition_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _fadeOut = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato, _randomness, _fadeOut );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato, _randomness );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 7&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 7)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _snapping = LuaAPI.lua_toboolean(L, 6);
                    bool _fadeOut = LuaAPI.lua_toboolean(L, 7);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato, _randomness, _snapping, _fadeOut );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _snapping = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato, _randomness, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato, _randomness );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    UnityEngine.Vector3 _strength;translator.Get(L, 3, out _strength);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _fadeOut = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato, _randomness, _fadeOut );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    UnityEngine.Vector3 _strength;translator.Get(L, 3, out _strength);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato, _randomness );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    UnityEngine.Vector3 _strength;translator.Get(L, 3, out _strength);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    UnityEngine.Vector3 _strength;translator.Get(L, 3, out _strength);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 7&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 7)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    UnityEngine.Vector3 _strength;translator.Get(L, 3, out _strength);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _snapping = LuaAPI.lua_toboolean(L, 6);
                    bool _fadeOut = LuaAPI.lua_toboolean(L, 7);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato, _randomness, _snapping, _fadeOut );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    UnityEngine.Vector3 _strength;translator.Get(L, 3, out _strength);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _snapping = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato, _randomness, _snapping );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    UnityEngine.Vector3 _strength;translator.Get(L, 3, out _strength);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato, _randomness );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    UnityEngine.Vector3 _strength;translator.Get(L, 3, out _strength);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Vector3>(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    UnityEngine.Vector3 _strength;translator.Get(L, 3, out _strength);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakePosition( _target, _duration, _strength );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOShakePosition!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOShakeRotation_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _fadeOut = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeRotation( _target, _duration, _strength, _vibrato, _randomness, _fadeOut );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeRotation( _target, _duration, _strength, _vibrato, _randomness );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeRotation( _target, _duration, _strength, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeRotation( _target, _duration, _strength );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Camera>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Camera _target = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeRotation( _target, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _fadeOut = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeRotation( _target, _duration, _strength, _vibrato, _randomness, _fadeOut );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeRotation( _target, _duration, _strength, _vibrato, _randomness );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeRotation( _target, _duration, _strength, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeRotation( _target, _duration, _strength );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeRotation( _target, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOShakeRotation!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOShakeScale_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    bool _fadeOut = LuaAPI.lua_toboolean(L, 6);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeScale( _target, _duration, _strength, _vibrato, _randomness, _fadeOut );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    float _randomness = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeScale( _target, _duration, _strength, _vibrato, _randomness );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    int _vibrato = LuaAPI.xlua_tointeger(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeScale( _target, _duration, _strength, _vibrato );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    float _strength = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeScale( _target, _duration, _strength );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Transform>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    UnityEngine.Transform _target = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _duration = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOShakeScale( _target, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOShakeScale!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOSmoothRewind_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOSmoothRewind( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOSmoothRewind( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOSmoothRewind!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOTiling_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Material>(L, 1)&& translator.Assignable<UnityEngine.Vector2>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    UnityEngine.Vector2 _endValue;translator.Get(L, 2, out _endValue);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOTiling( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Material>(L, 1)&& translator.Assignable<UnityEngine.Vector2>(L, 2)&& (LuaAPI.lua_isnil(L, 3) || LuaAPI.lua_type(L, 3) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    UnityEngine.Vector2 _endValue;translator.Get(L, 2, out _endValue);
                    string _property = LuaAPI.lua_tostring(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOTiling( _target, _endValue, _property, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOTiling!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOTime_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.TrailRenderer _target = (UnityEngine.TrailRenderer)translator.GetObject(L, 1, typeof(UnityEngine.TrailRenderer));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOTime( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOTimeScale_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _target = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOTimeScale( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOTogglePause_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Component>(L, 1)) 
                {
                    UnityEngine.Component _target = (UnityEngine.Component)translator.GetObject(L, 1, typeof(UnityEngine.Component));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOTogglePause( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<UnityEngine.Material>(L, 1)) 
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                        int gen_ret = DOTween.DOTweenShortcut.DOTogglePause( _target );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenShortcut.DOTogglePause!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOVector_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Material _target = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    UnityEngine.Vector4 _endValue;translator.Get(L, 2, out _endValue);
                    string _property = LuaAPI.lua_tostring(L, 3);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOVector( _target, _endValue, _property, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DOFillAmount_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.UI.Image _target = (UnityEngine.UI.Image)translator.GetObject(L, 1, typeof(UnityEngine.UI.Image));
                    float _endValue = (float)LuaAPI.lua_tonumber(L, 2);
                    float _duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        DG.Tweening.Tweener gen_ret = DOTween.DOTweenShortcut.DOFillAmount( _target, _endValue, _duration );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        
        
		
		
		
		
    }
}
