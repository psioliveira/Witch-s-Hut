using System;
using System.Collections.Generic;
using UnityEngine;

public class Inventory
{
    public event EventHandler OnItemListChanged;

    public List<ItemInfo> itemList;
    public Inventory()
    {
        itemList = new List<ItemInfo>();
    }
    public void AddItem(ItemInfo item)
    {
        if (item.isStackable)
        {
            bool itemAlreadyInInventory = false;
            foreach (ItemInfo i in itemList)
            {
                if (i.itemName == item.itemName)
                {
                    i.amount += item.amount;
                    itemAlreadyInInventory = true;
                }
            }
            if (!itemAlreadyInInventory)
            {
                itemList.Add(item);
            }
        }
        else
        {
            itemList.Add(item);
        }


        OnItemListChanged?.Invoke(this, EventArgs.Empty);
    }



    public List<ItemInfo> GetItemList()
    {
        return itemList;
    }
}


