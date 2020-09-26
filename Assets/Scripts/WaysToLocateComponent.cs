using System;
using UnityEngine;

public class WaysToLocateComponent : MonoBehaviour
{
	public Rigidbody Body1;
	[SerializeField] private Rigidbody _body2;

	private void Awake()
	{
		var localGameObject = GetComponent<Rigidbody>();
		var localOrParents = GetComponentInParent<Rigidbody>();
		var localOrChildren = GetComponentInChildren<Rigidbody>();
		var anywhere = FindObjectOfType<Rigidbody>();

		var manyLocal = GetComponentsInChildren<Rigidbody>();
		var includeInactive = GetComponentInChildren<Rigidbody>(true);
	}
}