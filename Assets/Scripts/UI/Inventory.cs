using System;
using System.Collections.Generic;

public class Inventory
{
    public event EventHandler OnItemListChanged;

    public List<ItemWorld> itemList;
    public Inventory()
    {
        itemList = new List<ItemWorld>();
    }
    public void AddItem(ItemWorld item)
    {
        if (item.GetItem().isStackable)
        {
            bool itemAlreadyInInventory = false;
            foreach (ItemWorld i in itemList)
            {
                if (i.GetItem().itemName == item.GetItem().itemName)
                {
                    i.AddAmount (item.GetAmount());
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



    public List<ItemWorld> GetItemList()
    {
        return itemList;
    }
}


