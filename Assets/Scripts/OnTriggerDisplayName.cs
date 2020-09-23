using UnityEngine;

public sealed class OnTriggerDisplayName : MonoBehaviour
{
	private void OnTriggerEnter(Collider other)
	{
		Debug.Log(other);
	}
}