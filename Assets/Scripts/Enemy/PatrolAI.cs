using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class PatrolAI : MonoBehaviour
{
    [SerializeField] private Animator myAnim;
    NavMeshAgent agent;
    public Transform[] waypoints;
    int waypointIndex;
    Vector3 target;
    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        UpdateDestination();
    }
    void Update()
    {
        if (Vector3.Distance(transform.position,target) < 1)
        {
            IterateIndex();
            UpdateDestination();
        }
    }
    void OnEnable()
    {
        UpdateDestination();
    }

    void UpdateDestination()
    {
        target = waypoints[waypointIndex].position;
        agent.SetDestination(target);
    }
    void IterateIndex()
    {
        waypointIndex++;
        if (waypointIndex == waypoints.Length)
        {
            waypointIndex = 0;
        }
    }

}
