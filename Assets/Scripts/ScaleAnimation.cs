using UnityEngine;

public sealed class ScaleAnimation : MonoBehaviour
{
	private void Update()
	{
		var x = Mathf.Cos(Time.time) + 0.5f;
		var y = Mathf.Sin(Time.time + 0.3f) + 0.5f;
		transform.localScale = new Vector3(x, y, 1f);
	}
}