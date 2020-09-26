using UnityEngine;

public class VisualAttributes : MonoBehaviour
{
	[Header("Im a header text")]
	public string ImportantData = "123";

	[Tooltip("Hi!")] public string HoverOverMe = "...";

	[TextArea] public string TextArea = "Your essay goes here.";
}