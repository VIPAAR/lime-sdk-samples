using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using Android.Content.Res;
using HelpLightning.SDK;
using Newtonsoft.Json.Linq;

namespace SampleAndroid
{
    public class HLServer
    {
        private static HLServer instance;

        public static HLServer Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new HLServer();
                }
                return instance;
            }
        }

        private string mBaseUlr;

        public string BaseUrl
        {
            set
            {
                this.mBaseUlr = value;
            }
        }

        public string AuthUser(string email)
        {
            JObject json = RequestJsonData("/auth?email=" + email, "GET");
            return json["token"].ToString();
        }

        public JObject CreateCall(string userToken, string contactEmail, string userName = "user")
        {
            Console.WriteLine("JEDI CreateCall");
            Dictionary<string, string> headers = new Dictionary<string, string>();
            headers.Add("Authorization", userToken);
            string args = String.Format(@"{{""contact_email"":""{0}""}}", contactEmail);
            JObject json = RequestJsonData("/session", "POST", headers, args);
            Console.WriteLine("JEDI session id: " + json["session_id"].ToString());
            Console.WriteLine("JEDI session token: " + json["session_token"].ToString());
            Console.WriteLine("JEDI user token: " + json["user_token"].ToString());
            return json;
            //(
            //    json["session_id"].ToString(),
            //    json["session_token"].ToString(),
            //    json["user_token"].ToString(),
            //    json["url"].ToString(),
            //    userName,
            //    "https://www.securenvoy.com/sites/default/files/legacy-uploads/2013/10/pizza_hut_logo.jpg"
            //);
        }

        public JObject GetCall(string pinCode, string userToken, string userName = "user")
        {
            Console.WriteLine("JEDI GetCall");
            Dictionary<string, string> headers = new Dictionary<string, string>();
            headers.Add("Authorization", userToken);
            JObject json = RequestJsonData("/session?sid=" + pinCode, "GET", headers);
            Console.WriteLine("JEDI session id: " + json["session_id"].ToString());
            Console.WriteLine("JEDI session token: " + json["session_token"].ToString());
            Console.WriteLine("JEDI user token: " + json["user_token"].ToString());
            return json;
            //return new Call
            //(
            //    json["session_id"].ToString(),
            //    json["session_token"].ToString(),
            //    json["user_token"].ToString(),
            //    json["url"].ToString(),
            //    userName,
            //    "https://www.securenvoy.com/sites/default/files/legacy-uploads/2013/10/pizza_hut_logo.jpg"
            //);
        }

        protected JObject RequestJsonData(String path, String method, Dictionary<string, string> headers = null, string bodyArgs = "")
        {
            var httpWebRequest = (HttpWebRequest)WebRequest.Create(mBaseUlr + path);
            httpWebRequest.ContentType = "application/json; charset=utf-8";
            httpWebRequest.Method = method;

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
