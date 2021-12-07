using PlayerControl;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{

    private PlayerControls playerControl;

    [SerializeField] private float acceleration = 0.6f;
    [SerializeField] private float maxSpeed = 30;
    [SerializeField] private float speed = 0;



    private void Awake()
    {
        playerControl = new PlayerControls();
    }


    private void OnEnable()
    {
    }

    private void OnDisable()
    {
        playerControl.Disable();
    }
    private void Start()
    {
        speed = speed < 0 ? 0 : speed -= acceleration * Time.deltaTime;

    }



    public void OnDash(InputAction.CallbackContext ctx)
    {

    }
    public void OnAttack(InputAction.CallbackContext ctx)
    {

    }


    public void OnMovement(InputAction.CallbackContext ctx)
    {

        speed = speed > maxSpeed ? maxSpeed : speed += acceleration * Time.deltaTime;

        transform.position = new Vector3(
        transform.position.x + ctx.ReadValue<Vector2>().normalized.x * speed * Time.deltaTime,
        transform.position.y,
        transform.position.z + ctx.ReadValue<Vector2>().normalized.y * speed * Time.deltaTime);
    }


}
