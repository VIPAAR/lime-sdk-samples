using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using Newtonsoft.Json.Linq;

namespace HelpLightning.SDK.Sample
{
    public class HLServerClient
    {
        private static HLServerClient instance;

        public static HLServerClient Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new HLServerClient();
                }
                return instance;
            }
        }

        public string ServerURL;

        public string AuthUser(string email)
        {
            JObject json = RequestJsonData("/auth?email=" + email, "GET");
            return json["token"].ToString();
        }

        public JObject CreateCall(string userToken, string contactEmail, string userName = "user")
        {
            Console.WriteLine("CreateCall");
            Dictionary<string, string> headers = new Dictionary<string, string>();
            headers.Add("Authorization", userToken);
            string args = String.Format(@"{{""contact_email"":""{0}""}}", contactEmail);
            JObject json = RequestJsonData("/session", "POST", headers, args);
           
            Console.WriteLine("Session id: " + json["session_id"].ToString());
            Console.WriteLine("Session token: " + json["session_token"].ToString());
            Console.WriteLine("User token: " + json["user_token"].ToString());
            return json;
        }

        public JObject GetCall(string pinCode, string userToken, string userName = "user")
        {
            Console.WriteLine("GetCall");
            Dictionary<string, string> headers = new Dictionary<string, string>();
            headers.Add("Authorization", userToken);
            JObject json = RequestJsonData("/session?sid=" + pinCode, "GET", headers);
            Console.WriteLine("Session id: " + json["session_id"].ToString());
            Console.WriteLine("Session token: " + json["session_token"].ToString());
            Console.WriteLine("User token: " + json["user_token"].ToString());
            return json;
        }

        protected JObject RequestJsonData(String path, String method, Dictionary<string, string> headers = null, string bodyArgs = "")
        {
            var httpWebRequest = (HttpWebRequest)WebRequest.Create(ServerURL + path);
            httpWebRequest.ContentType = "application/json; charset=utf-8";
            httpWebRequest.Method = method;
            httpWebRequest.Timeout = 60000;
            httpWebRequest.ReadWriteTimeout = 60000;

            if (headers != null)
            {
                foreach (var item in headers)
                {
                    httpWebRequest.Headers.Add(item.Key, item.Value);
                }
            }

            if (!bodyArgs.Equals(""))
            {
                using (var stream = httpWebRequest.GetRequestStream())
                {
                    using (var streamWriter = new StreamWriter(stream))
                    {
                        streamWriter.Write(bodyArgs);
                        streamWriter.Flush();
                        streamWriter.Close();
                    }
                }
            }
            using (var streamReader = new StreamReader(httpWebRequest.GetResponse().GetResponseStream()))
            {
                var responseText = streamReader.ReadToEnd();
                return JObject.Parse(responseText);
            }
        }
    }
}
