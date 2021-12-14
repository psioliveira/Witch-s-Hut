
using System;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Animator))]
public class PlayerAnimation : MonoBehaviour
{
    private Animator playerAnimator;
    private PlayerController playerController;
    [SerializeField] private List<Animation> animations;

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

    internal float AnimationLenght(string animName)
    {
        foreach (Animation anim in animations)
        {
            if (anim.name == animName)
            {
                return anim[animName].length * anim[animName].speed;
            }
        }

        return 0;
    }
}
