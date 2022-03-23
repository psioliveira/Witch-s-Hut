using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Quest 
{
    public bool isActive;
    public string title;
    public string description;
    public QuestGoal goal;
    public DoorTriggers q1Done;
    public ItemInfo itemInfo;

    public void Complete()
    {
        
        isActive = false;
        Debug.Log(title + "was completed!"); 
        q1Done.Q1Done();
                
    }
    
}
