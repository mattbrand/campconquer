#define BEST_HTTP
#if BEST_HTTP

using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using BestHTTP;
using MiniJSON;

namespace gametheory.Utilities
{
    public class BestHTTPHelper : MonoBehaviour
	{
	    #region Constants
	    //http keys
	    const string CONTENT_TYPE = "application/json";
	    const string CONTENT_LENGTH = "Content-Length";
        #endregion

        #region Public Vars
        public static BestHTTPHelper Instance;
        #endregion

        #region Unity Methods
        void Awake()
        {
            enabled = false;

            if (Instance == null)
            {
                Instance = this;
            }
            else
            {
                Destroy(gameObject);
            }
        }

        void OnDestroy()
        {
            Instance = null;
        }
        #endregion

        #region Methods
        public static void AppendAuthenticationHeaders(ref HTTPRequest request, string token)
	    {
	        request.AddHeader("Authorization", "Bearer " + token);
	        AppendContentHeader(ref request);
	    }
	    public static void AppendContentHeader(ref HTTPRequest request)
	    {
	        request.AddHeader("Content-Type", CONTENT_TYPE);
	    }
	    public static void AppendBody(ref HTTPRequest request, string body)
	    {
	        byte[] data = System.Text.Encoding.UTF8.GetBytes(body);
	        request.AddHeader(CONTENT_LENGTH,data.Length.ToString());
	        request.RawData = data;
	    }
	    public static string AppendQueryParameter(string url, string paramName, object param,bool first=false)
	    {
	        if (first)
	            return url += "?" + paramName + "=" + param;
	        else
	            return url += "&" + paramName + "=" + param;
	    }
	    public static List<object> ParseGETList(string json, string key)
	    {
	        Dictionary<string,object> dict = Json.Deserialize(json) as Dictionary<string,object>;

	        if (dict.ContainsKey(key))
	            return dict[key] as List<object>;
	        else
	            return null;
	    }
	    public static JsonObject ParseResponse(string json)
	    {
	        if (!string.IsNullOrEmpty(json))
	            return new JsonObject(json);
	        else
	            return null;
	    }
        public IEnumerator CallToServer(string url, HTTPMethods method, Dictionary<string, string> dictParameters, WWWForm formParameters, List<HTTPTuple> tupleParameters, Action<Dictionary<string, object>> successCallback = null, Action<Dictionary<string, object>> requestNotOKCallback = null, Action<Dictionary<string, object>> failureCallback = null, Action requestFailureCallback = null)
        {
            HTTPRequest request = new HTTPRequest(new Uri(url), method);
            request.SetHeader("Accept", "application/json");
            if (dictParameters != null)
            {
                foreach (KeyValuePair<string, string> parameter in dictParameters)
                {
                    request.AddField(parameter.Key, parameter.Value);
                }
            }
            if (formParameters != null)
                request.SetFields(formParameters);
            if (tupleParameters != null)
            {
                for (int i = 0; i < tupleParameters.Count; i++)
                {
                    request.AddField(tupleParameters[i].Key, tupleParameters[i].Value);
                }
            }
            request.Send();
            yield return StartCoroutine(request);

            Dictionary<string, object> dict;
            if (request.State == HTTPRequestStates.Finished)
            {
                if (request.Response.IsSuccess)
                {
                    dict = Json.Deserialize(request.Response.DataAsText) as Dictionary<string, object>;
                    if (dict["status"].ToString() == "ok")
                    {
                        if (successCallback != null)
                            successCallback(dict);
                    }
                    else
                    {
                        if (requestNotOKCallback != null)
                            requestNotOKCallback(dict);
                    }
                }
                else
                {
                    dict = Json.Deserialize(request.Response.DataAsText) as Dictionary<string, object>;
                    if (failureCallback != null)
                        failureCallback(dict);
                }
            }
            else
            {
                if (requestFailureCallback != null)
                    requestFailureCallback();
            }
        }

        public IEnumerator CallToServerForJson(string url, HTTPMethods method, List<HTTPTuple> tupleParameters, Action<string> successCallback = null, Action<Dictionary<string, object>> requestNotOKCallback = null, Action<Dictionary<string, object>> failureCallback = null, Action requestFailureCallback = null)
        {
            //Debug.Log("CallToServerForJson");

            if (tupleParameters != null)
            {
                bool paramAdded = false;
                for (int i = 0; i < tupleParameters.Count; i++)
                {
                    if (method == HTTPMethods.Get)
                    {
                        if (!paramAdded)
                        {
                            url += "?";
                            paramAdded = true;
                        }
                        else
                        {
                            url += "&";
                        }
                        //Debug.Log(tupleParameters[i].Key + " /// " + tupleParameters[i].Value);
                        url += Uri.EscapeDataString(tupleParameters[i].Key) + "=" + Uri.EscapeDataString(tupleParameters[i].Value);
                    }
                }
                //Debug.Log("set tuple parameters - url = " + url);
            }

            HTTPRequest request = new HTTPRequest(new Uri(url), method);
            request.SetHeader("Accept", "application/json");
            if (tupleParameters != null)
            {
                for (int i = 0; i < tupleParameters.Count; i++)
                {
                    //Debug.Log("adding fields key = " + tupleParameters[i].Key);
                    //Debug.Log(tupleParameters[i].Value);
                    request.AddField(tupleParameters[i].Key, tupleParameters[i].Value);
                }
                //Debug.Log("set tuple parameters");
            }
            //Debug.Log("final sending request to " + url);
            //Debug.Log("sending request");
            request.Send();
            yield return StartCoroutine(request);

            //Debug.Log(request.State);

            if (request.State == HTTPRequestStates.Finished)
            {
                //Debug.Log("success = " + request.Response.IsSuccess);

                if (request.Response.IsSuccess)
                {
                    if (successCallback != null)
                        successCallback(request.Response.DataAsText);
                }
                else
                {
                    //Debug.Log("failure text = " + request.Response.DataAsText);
                    Dictionary<string, object> dict = Json.Deserialize(request.Response.DataAsText) as Dictionary<string, object>;
                    if (failureCallback != null)
                    {
                        //Debug.Log("failure callback");
                        failureCallback(dict);
                    }
                }
            }
            else
            {
                if (requestFailureCallback != null)
                {
                    //Debug.Log("request failure");
                    requestFailureCallback();
                }
            }
        }
        #endregion
    }

    #region HTTP Data Classes
    public class HTTPTuple
    {
        public string Key;
        public string Value;

        public HTTPTuple(string key, string value)
        {
            Key = key;
            Value = value;
        }
    }
    #endregion
}
#endif