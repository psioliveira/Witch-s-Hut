using PlayerControl;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{

    private PlayerControls playerControl;

    [SerializeField] private float acceleration = 0.6f;
    [SerializeField] private float maxSpeed = 30;
    [SerializeField] private float speed = 0;
    private Vector3 rawInput;
    private bool move;

    private void Awake()
    {
        playerControl = new PlayerControls();
    }


    private void OnEnable()
    {
        playerControl.Enable();
    }

    private void OnDisable()
    {
        playerControl.Disable();
    }

    private void Update()
    {
        PlayerMovement();

    }


    public void OnDash(InputAction.CallbackContext ctx)
    {

    }
    public void OnAttack(InputAction.CallbackContext ctx)
    {

    }


    public void OnMovement(InputAction.CallbackContext ctx)
    {
        rawInput = new Vector3(ctx.ReadValue<Vector2>().x, 0, ctx.ReadValue<Vector2>().y);
        move = true;
    }

    private void PlayerMovement()
    {
        if (rawInput.x != 0 || rawInput.z != 0)
        {
            speed = speed > maxSpeed ? maxSpeed : speed += acceleration * Time.deltaTime;
            transform.position += rawInput * speed * Time.deltaTime;
        }
        else
        {
            speed = 0;
        }

    }
}
