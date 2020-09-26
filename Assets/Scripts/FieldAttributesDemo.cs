using System;
using UnityEngine;

public class FieldAttributesDemo : MonoBehaviour
{
	public GameObject _field1; // visible, serialized

	private GameObject _field2; // invisible, not serialized

	[SerializeField] private GameObject _field3; // visible, serialized

	[HideInInspector]
	public GameObject _field4; // invisible, serialized
}