
using UnityEngine;

[RequireComponent(typeof(Animator))]
public class Animation : MonoBehaviour
{
    private Animator playerAnimator;
    private PlayerController playerController;


    void Start()
    {
        playerAnimator = GetComponent<Animator>();
        playerController = GetComponent<PlayerController>();
    }



    private void Update()
    {
        UpdateAnimatorVariables();
    }

    private void UpdateAnimatorVariables()
    {
        playerAnimator.SetFloat("Velocity up down", playerController.GetRawInput().z);
        playerAnimator.SetFloat("Velocity left right", playerController.GetRawInput().x);
    }


    public void AttackAnimation()
    {
        playerAnimator.SetTrigger("Attack");
    }

}
