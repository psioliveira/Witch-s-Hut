using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class QuestGoal 
{
    public GatherGoal gatherGoal;

    public int requiredAmount;
    public int currentAmount;
    public bool IsReached()
    {
        return (currentAmount >= requiredAmount);
    }

    public void ItemCollected()
    {
        if (gatherGoal == GatherGoal.Gathering)
            currentAmount++;
    }
}

public enum GatherGoal
{
    Gathering
}


