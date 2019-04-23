using UnityEngine;
using System.Collections;
using TMPro;
using XLua;

namespace UnityEngine.UI
{
    public abstract class LoopScrollDataSource
    {
        public abstract void ProvideData(Transform transform, int idx);
    }

    [Hotfix]
    [LuaCallCSharp]
    public class LoopScrollSendIndexSource : LoopScrollDataSource
    {
		//public static readonly LoopScrollSendIndexSource Instance = new LoopScrollSendIndexSource();

        // public List<string> msgList = new List<string>();

        [CSharpCallLua]
        public delegate void OnInitializeItem(Transform transform, int realIndex);
        public OnInitializeItem onInitializeItem;

        public LoopScrollSendIndexSource(){}

        public override void ProvideData(Transform transform, int idx)
        {
            if (onInitializeItem != null)
            {
                onInitializeItem(transform, idx);
            }
        }

        public void SetOnInitializeItem(OnInitializeItem onInitializeItem)
        {
            this.onInitializeItem = onInitializeItem;
        }
    }

//public class LoopScrollArraySource<T> : LoopScrollDataSource
 //   {
 //       T[] objectsToFill;

 //	      public LoopScrollArraySource(T[] objectsToFill)
 //       {
 //           this.objectsToFill = objectsToFill;
 //       }

 //       public override void ProvideData(Transform transform, int idx)
 //       {
 //           transform.SendMessage("ScrollCellContent", objectsToFill[idx]);
 //       }
 //   }
}