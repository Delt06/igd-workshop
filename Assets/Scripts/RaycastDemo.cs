using System;
using UnityEngine;

namespace DefaultNamespace
{
	public class RaycastDemo : MonoBehaviour
	{
		private void Update()
		{
			var hit = Physics.Raycast(transform.position, Vector3.down, 0.6f);
			if (hit && Input.GetButton("Jump"))
				GetComponent<Rigidbody>().velocity = Vector3.up * 5f;
		}

		private void OnDrawGizmos()
		{
			Gizmos.DrawRay(transform.position, Vector3.down);
		}
	}
}