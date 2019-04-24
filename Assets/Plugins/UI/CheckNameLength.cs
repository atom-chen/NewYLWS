using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System;

public class CheckNameLength : MonoBehaviour
{
    public InputField input;
    public int CHARACTER_LIMIT = 10;

    public void Check()
    {
        input.text = GetSplitName();
    }

    public string GetSplitName()
    {
        string temp = input.text.Substring(0, (input.text.Length < CHARACTER_LIMIT + 1) ? input.text.Length : CHARACTER_LIMIT + 1);
        return SplitNameByUTF8(temp);
    }
    
    private string SplitNameByUTF8(string temp)
    {
        string outputStr = "";
        int count = 0;

        for (int i = 0; i < temp.Length; i++)
        {
            string tempStr = temp.Substring(i, 1);
            int byteCount = System.Text.ASCIIEncoding.UTF8.GetByteCount(tempStr);
            if (byteCount > 1)
            {
                count += 2;
            }
            else
            {
                count += 1;
            }
            if (count <= CHARACTER_LIMIT)
            {
                outputStr += tempStr;
            }
            else
            {
                break;
            }
        }
        return outputStr;
    }
}


