using UnityEngine;

public class InstantiatePrefab : MonoBehaviour
{
	public GameObject GameObject;

	private void Start()
	{
		for (var i = 0; i < 10; i++)
		{
			var position = transform.position + Vector3.forward * i;
			Instantiate(GameObject, position, Quaternion.identity);
		}
	}
}