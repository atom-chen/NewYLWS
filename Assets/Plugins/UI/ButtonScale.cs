using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using DG.Tweening;

public class ButtonScale : MonoBehaviour, IPointerClickHandler
{
    public Vector3 startSize = Vector3.one;
    public Vector3 scale = new Vector3(0.1f, 0.1f, 0.1f);
    public float duration = 0.3f;
    public int vibrato = 5;

    public void OnPointerClick(PointerEventData eventData)
    {
        transform.localScale = startSize;
        transform.DOKill();
        transform.DOPunchScale(scale, duration, vibrato);
    }
}
