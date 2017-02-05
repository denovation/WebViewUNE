using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
#if UNITY_EDITOR || UNITY_STANDALONE_OSX
using System.IO;
using System.Text.RegularExpressions;
#endif

using Callback = System.Action<string>;

#if UNITY_EDITOR || UNITY_STANDALONE_OSX
public class UnitySendMessageDispatcher
{
	public static void Dispatch(string name, string method, string message)
	{
		GameObject obj = GameObject.Find(name);
		if (obj != null)
			obj.SendMessage(method, message);
	}
}
#endif


public class WebViewUNE : MonoBehaviour
{
	bool hidden;

	#if UNITY_WEBPLAYER
	#elif UNITY_EDITOR || UNITY_STANDALONE_OSX
	IntPtr webView;
	Rect rect;
	Texture2D texture;
	string inputString;
	bool hasFocus;
	#elif UNITY_IPHONE
	IntPtr webView;
	#elif UNITY_ANDROID
	//AndroidJavaObject webView;
	#endif

	#if UNITY_EDITOR || UNITY_STANDALONE_OSX
	[DllImport("WebView")]
	private static extern IntPtr _init (string gameObject);
	[DllImport("WebView")]
	private static extern void _loadRequest(IntPtr instance, string URLWithString);
	[DllImport("WebView")]
	private static extern void _setHidden(IntPtr instance, bool hidden);
	#elif UNITY_IOS
	[DllImport("__Internal")]
	private static extern IntPtr _init(string gameObject);
	[DllImport("__Internal")]
	private static extern void _loadRequest(IntPtr instance, string URLWithString);
	[DllImport("__Internal")]
	private static extern void _setHidden(IntPtr instance, bool hidden);
	#endif

	public void Init(Callback cb = null)
	{
	#if UNITY_WEBPLAYER
		//Application.ExternalCall("unityWebView.init", name);
	#elif UNITY_EDITOR || UNITY_STANDALONE_OSX
	#elif UNITY_IOS
		webView = _init(name);
	#elif UNITY_ANDROID
		//webView = new AndroidJavaObject("net.gree.unitywebview.CWebViewPlugin");
		//webView.Call("Init", name);
	#endif
	}

	public void LoadRequest(string URLWithString)
	{
	#if UNITY_WEBPLAYER
	#elif UNITY_EDITOR || UNITY_STANDALONE_OSX || UNITY_IOS
		if (webView == IntPtr.Zero)
			return;
		_loadRequest(webView, URLWithString);
	#elif UNITY_ANDROID
	#endif
	}

	public void SetHidden(bool hidden)
	{		
	#if UNITY_WEBPLAYER
	#elif UNITY_EDITOR || UNITY_STANDALONE_OSX
	#elif UNITY_IOS
		if (webView == IntPtr.Zero)
			return;
	_setHidden(webView, hidden);
	#elif UNITY_ANDROID
		if (webView == null)
			return;
		webView.Call("SetHidden", hidden);
	#endif
	}
}
