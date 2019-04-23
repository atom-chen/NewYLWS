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
    public class UnityEngineUILoopScrollPrefabSourceWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(UnityEngine.UI.LoopScrollPrefabSource);
			Utils.BeginObjectRegister(type, L, translator, 0, 3, 2, 2);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetObject", _m_GetObject);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "ReturnObject", _m_ReturnObject);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetCallBack", _m_SetCallBack);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "getGameObjectDel", _g_get_getGameObjectDel);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "returnObjectDel", _g_get_returnObjectDel);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "getGameObjectDel", _s_set_getGameObjectDel);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "returnObjectDel", _s_set_returnObjectDel);
            
			
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
					
					UnityEngine.UI.LoopScrollPrefabSource gen_ret = new UnityEngine.UI.LoopScrollPrefabSource();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.UI.LoopScrollPrefabSource constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetObject(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.UI.LoopScrollPrefabSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollPrefabSource)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        UnityEngine.GameObject gen_ret = gen_to_be_invoked.GetObject(  );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ReturnObject(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.UI.LoopScrollPrefabSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollPrefabSource)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Transform _go = (UnityEngine.Transform)translator.GetObject(L, 2, typeof(UnityEngine.Transform));
                    
                    gen_to_be_invoked.ReturnObject( _go );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetCallBack(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.UI.LoopScrollPrefabSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollPrefabSource)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.UI.LoopScrollPrefabSource.GetGameObjectDel _getGameObjectDel = translator.GetDelegate<UnityEngine.UI.LoopScrollPrefabSource.GetGameObjectDel>(L, 2);
                    UnityEngine.UI.LoopScrollPrefabSource.ReturnObjectDel _returnObjectDel = translator.GetDelegate<UnityEngine.UI.LoopScrollPrefabSource.ReturnObjectDel>(L, 3);
                    
                    gen_to_be_invoked.SetCallBack( _getGameObjectDel, _returnObjectDel );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_getGameObjectDel(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.UI.LoopScrollPrefabSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollPrefabSource)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.getGameObjectDel);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_returnObjectDel(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.UI.LoopScrollPrefabSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollPrefabSource)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.returnObjectDel);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_getGameObjectDel(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.UI.LoopScrollPrefabSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollPrefabSource)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.getGameObjectDel = translator.GetDelegate<UnityEngine.UI.LoopScrollPrefabSource.GetGameObjectDel>(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_returnObjectDel(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.UI.LoopScrollPrefabSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollPrefabSource)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.returnObjectDel = translator.GetDelegate<UnityEngine.UI.LoopScrollPrefabSource.ReturnObjectDel>(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
