
using UnityEngine;


[CreateAssetMenu(fileName = "New item info", menuName = "Item info")]
public class ItemInfo : ScriptableObject
{
    
    public string itemName;
    public bool isStackable;
    public Sprite itemSprite;
    public int amount = 1;
}
