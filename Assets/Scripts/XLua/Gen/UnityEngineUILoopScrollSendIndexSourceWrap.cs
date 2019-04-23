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
    public class UnityEngineUILoopScrollSendIndexSourceWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(UnityEngine.UI.LoopScrollSendIndexSource);
			Utils.BeginObjectRegister(type, L, translator, 0, 2, 1, 1);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "ProvideData", _m_ProvideData);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetOnInitializeItem", _m_SetOnInitializeItem);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "onInitializeItem", _g_get_onInitializeItem);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "onInitializeItem", _s_set_onInitializeItem);
            
			
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
					
					UnityEngine.UI.LoopScrollSendIndexSource gen_ret = new UnityEngine.UI.LoopScrollSendIndexSource();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.UI.LoopScrollSendIndexSource constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ProvideData(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.UI.LoopScrollSendIndexSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollSendIndexSource)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Transform _transform = (UnityEngine.Transform)translator.GetObject(L, 2, typeof(UnityEngine.Transform));
                    int _idx = LuaAPI.xlua_tointeger(L, 3);
                    
                    gen_to_be_invoked.ProvideData( _transform, _idx );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetOnInitializeItem(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.UI.LoopScrollSendIndexSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollSendIndexSource)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.UI.LoopScrollSendIndexSource.OnInitializeItem _onInitializeItem = translator.GetDelegate<UnityEngine.UI.LoopScrollSendIndexSource.OnInitializeItem>(L, 2);
                    
                    gen_to_be_invoked.SetOnInitializeItem( _onInitializeItem );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_onInitializeItem(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.UI.LoopScrollSendIndexSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollSendIndexSource)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.onInitializeItem);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_onInitializeItem(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.UI.LoopScrollSendIndexSource gen_to_be_invoked = (UnityEngine.UI.LoopScrollSendIndexSource)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.onInitializeItem = translator.GetDelegate<UnityEngine.UI.LoopScrollSendIndexSource.OnInitializeItem>(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
