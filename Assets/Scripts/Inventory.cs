using System;
using System.Collections.Generic;
using UnityEngine;

public class Inventory
{
    public event EventHandler OnItemListChanged;

    public List<Item> itemList;
    public Inventory()
    {
        itemList = new List<Item>();
    }
    public void AddItem(Item item)
    {
        if (item.IsStackable())
        {
            bool itemAlreadyInInventory = false;
            foreach(Item i in itemList)
            {
                if(i.itemType == item.itemType)
                {
                    i.Amount += item.Amount;
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



    public List<Item> GetItemList()
    {
        return itemList;
    }
}


