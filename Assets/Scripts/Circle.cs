using System;
using UnityEngine;

namespace DefaultNamespace
{
	public class Circle : MonoBehaviour
	{
		private void Update()
		{
			var x = Mathf.Cos(Time.time);
			var y = Mathf.Sin(Time.time);
			transform.position = new Vector3(x, y, 0f);
		}
	}
}