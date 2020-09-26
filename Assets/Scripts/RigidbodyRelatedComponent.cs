using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class RigidbodyRelatedComponent : MonoBehaviour
{
	private void Start()
	{
		var body = GetComponent<Rigidbody>();
		body.velocity = Vector3.up;
	}
}