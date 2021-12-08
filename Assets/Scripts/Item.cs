using System;
using UnityEngine;

[Serializable]
public class Item
{
    public enum ItemType
    {
        Crystal,
        Fur,
        BatWing,
        Blood,
        Venom,
        Bone
    }

    public ItemType itemType;
    public int Amount = 1;

    public Sprite GetSprite()
    {
        switch (itemType)
        {
            default:
            case ItemType.Crystal: return ItemSprites.Instance.crystal;
            case ItemType.Fur: return ItemSprites.Instance.fur;
            case ItemType.BatWing: return ItemSprites.Instance.batWing;
            case ItemType.Blood: return ItemSprites.Instance.blood;
            case ItemType.Venom: return ItemSprites.Instance.venom;
            case ItemType.Bone: return ItemSprites.Instance.Bone;
        }
    }


    public bool IsStackable()
    {
        switch (itemType)
        {
            default:
            case ItemType.Crystal:
            case ItemType.BatWing:
            case ItemType.Blood:
            case ItemType.Venom:
            case ItemType.Bone:
                return true;
            case ItemType.Fur:
                return false;
        }

    }



}

