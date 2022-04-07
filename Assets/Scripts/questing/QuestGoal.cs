using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class QuestGoal 
{
    public GoalType typeGoal;
    public int EnemyID { get; set; }
    public int requiredAmount;
    public int currentAmount;

    public bool IsReached()
    {
        return (currentAmount >= requiredAmount);
    }

    public void EnemyKilled()
    {
        if (typeGoal == GoalType.Killing)
            currentAmount++;
    }
}

public enum GoalType
{
    Gathering,
    Killing
}


