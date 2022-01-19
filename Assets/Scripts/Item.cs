using System;
using UnityEngine;


public class Item : MonoBehaviour
{
    public ItemInfo itemInfo;

    public string itemName;
    public bool isStackable;
    public Sprite itemSprite;

    public int Amount = 1;

    private void Start()
    {
        itemName = itemInfo.itemName;
        isStackable = itemInfo.isStackable;
        itemSprite = itemInfo.itemSprite;
    }


    public Sprite GetSprite()
    {
        return itemSprite;
    }


    public bool IsStackable()
    {
        return isStackable;
    }



}

