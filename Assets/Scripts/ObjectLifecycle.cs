using UnityEngine;

public class ObjectLifecycle : MonoBehaviour
{
	private void OnCollisionEnter(Collision other)
	{
		//Destroy(this); // destroy this component only
		Destroy(gameObject); // destroy game object completely
	}
}