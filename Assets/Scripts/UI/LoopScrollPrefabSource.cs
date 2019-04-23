using UnityEngine;
using System.Collections;
using XLua;

namespace UnityEngine.UI
{
    //[System.Serializable]
    [Hotfix]
    [LuaCallCSharp]
    public class LoopScrollPrefabSource 
    {
        [CSharpCallLua]
        public delegate GameObject GetGameObjectDel();
        [CSharpCallLua]
        public delegate void ReturnObjectDel(GameObject go);

        public GetGameObjectDel getGameObjectDel;
        public ReturnObjectDel returnObjectDel;

        public virtual GameObject GetObject()
        {
            if(getGameObjectDel != null)
            {
                return getGameObjectDel();
            }

            return null;
        }

        public virtual void ReturnObject(Transform go)
        {
            if(go != null)
            {
                returnObjectDel(go.gameObject);
            }
        }

        public void SetCallBack(GetGameObjectDel getGameObjectDel, ReturnObjectDel returnObjectDel)
        {
            this.getGameObjectDel = getGameObjectDel;
            this.returnObjectDel = returnObjectDel;
        }
    }
}
