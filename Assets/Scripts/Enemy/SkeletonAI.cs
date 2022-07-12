using System.Collections;
using UnityEngine;
using UnityEngine.AI;
public class SkeletonAI : MonoBehaviour
{
    [SerializeField] private Animator myAnim;
    [SerializeField] private Transform target;
    [SerializeField] private float speed;
    [SerializeField] private float maxRange;
    [SerializeField] private float minRange;
    [SerializeField] private float attackRange;
    [SerializeField] private int id;
    private bool dead = false;
    private Vector3 attackPos;
    [SerializeField] private float attackRadius = 1.2f;
    [SerializeField] private int attackDamage;
    private PatrolAI patrolAI;
    private NavMeshAgent navAgent;
    [SerializeField] private AudioSource enemyAttackSound;

    public float cooldown = 1f;

    private float nextAttack = 0f;

    // Start is called before the first frame update
    void Start()
    {
        myAnim = GetComponent<Animator>();
        target = FindObjectOfType<PlayerController>().transform;
        patrolAI = GetComponent<PatrolAI>();
        navAgent = GetComponent<NavMeshAgent>();
    }

    // Update is called once per frame
    void Update()
    {

        if (!dead)
        {
            if (Vector3.Distance(target.position, transform.position) <= attackRange)
            {  
                if (Time.time > nextAttack)
                {
                    
                    patrolAI.enabled = false;
                    navAgent.isStopped = true;
                    StartCoroutine(AttackPlayer());
                    enemyAttackSound.Play();
                    nextAttack = Time.time + cooldown;
                }
            }
            else if (Vector3.Distance(target.position, transform.position) <= maxRange && Vector3.Distance(target.position, transform.position) >= minRange)
            { 
                Debug.Log("patrol off");
                patrolAI.enabled = false;
                FollowPlayer();
            }
            else
            {
                //Debug.Log("patrol on");
                navAgent.isStopped = false;
                patrolAI.enabled = true;
            }
        }
        
        if (!navAgent.isStopped)
        {
            myAnim.SetBool("Moving", true);
            
            myAnim.SetFloat("MoveX", navAgent.velocity.x);
            myAnim.SetFloat("MoveY", navAgent.velocity.z);
        }
    }

    private IEnumerator AttackPlayer()
    {
        Debug.Log("Attacking Player");
        myAnim.SetBool("Moving", false);

        attackPos = (transform.position);

        myAnim.SetTrigger("Attack");
        Collider[] hitColliders = Physics.OverlapSphere(attackPos, attackRadius);
        foreach (var hitCollider in hitColliders)
        {
            if (hitCollider.tag == "Player")
            {
                hitCollider.transform.GetComponent<PlayerDamageHandler>().TakeDamage(attackDamage);
            }

        }

        yield return new WaitForSecondsRealtime(2f);
        //myAnim.ResetTrigger("Attack");

        yield return null;
    }

    public void FollowPlayer()
    {

        navAgent.SetDestination(target.transform.position);

        //transform.position = Vector3.MoveTowards(transform.position, target.transform.position, speed * Time.deltaTime);

    }
    public void IsDead()
    {
        dead = true;
    }
    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(attackPos, attackRadius);
    }
}