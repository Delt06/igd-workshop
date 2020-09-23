using UnityEngine;

public sealed class InitialVelocity : MonoBehaviour
{
	[SerializeField]
	private Vector3 _velocity = Vector3.zero;

	private void Awake()
	{
		GetComponent<Rigidbody>().velocity = _velocity;
	}
}