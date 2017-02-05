using UnityEngine;
using System.Collections;

public class MainScene : MonoBehaviour {
	public string url = "http://yahoo.co.jp";
	WebViewUNE webView;

	// for initialization
	IEnumerator Start () {
		webView = (new GameObject("WebViewUNE")).AddComponent<WebViewUNE>();
		webView.Init((msg) => {
			Debug.Log(msg);
		});
		webView.LoadRequest(url);
		webView.SetHidden(false);

		yield break;
	}
}
