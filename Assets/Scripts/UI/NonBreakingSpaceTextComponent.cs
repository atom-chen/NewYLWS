using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Text))]
public class NonBreakingSpaceTextComponent : MonoBehaviour
{
    public static readonly string no_breaking_space = "\u00A0";

    protected Text mytext;
    void Start()
    {
        mytext = this.GetComponent<Text>();
        mytext.RegisterDirtyVerticesCallback(SetMyText);
    }

    public void SetMyText()
    {
        if (mytext.text.Contains(" "))
        {
            mytext.text = mytext.text.Replace(" ", no_breaking_space);
        }
    }
}