using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Threading.Tasks;
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

        private string mBaseUlr;

        public string BaseUrl
        {
            set
            {
                this.mBaseUlr = value;
            }
        }

        public async Task<string> AuthUser(string email)
        {
            JObject json = await RequestJsonData("/auth?email=" + email, "GET");
            return json["token"].ToString();
        }

        public async Task<JObject> CreateCall(string userToken, string contactEmail, string userName = "user")
        {
            Console.WriteLine("JEDI CreateCall");
            Dictionary<string, string> headers = new Dictionary<string, string>();
            headers.Add("Authorization", userToken);
            string args = String.Format(@"{{""contact_email"":""{0}""}}", contactEmail);
            JObject json = await RequestJsonData("/session", "POST", headers, args);

            Console.WriteLine("JEDI session id: " + json["session_id"].ToString());
            Console.WriteLine("JEDI session token: " + json["session_token"].ToString());
            Console.WriteLine("JEDI user token: " + json["user_token"].ToString());
            return json;
        }

        public async Task<JObject> GetCall(string pinCode, string userToken, string userName = "user")
        {
            Console.WriteLine("JEDI GetCall");
            Dictionary<string, string> headers = new Dictionary<string, string>();
            headers.Add("Authorization", userToken);
            JObject json = await RequestJsonData("/session?sid=" + pinCode, "GET", headers);
            Console.WriteLine("JEDI session id: " + json["session_id"].ToString());
            Console.WriteLine("JEDI session token: " + json["session_token"].ToString());
            Console.WriteLine("JEDI user token: " + json["user_token"].ToString());
            return json;
        }

        protected async Task<JObject> RequestJsonData(String path, String method, Dictionary<string, string> headers = null, string bodyArgs = "")
        {
            var httpWebRequest = (HttpWebRequest)WebRequest.Create(mBaseUlr + path);
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
            using (var response = await httpWebRequest.GetResponseAsync())
            {
				if (response.StatusCode != HttpStatusCode.OK)
				{
					throw new Exception("Failed to perform the request. Failed code:" + response.StatusCode.ToString());
				}
				else
				{
					using (var streamReader = new StreamReader(response.GetResponseStream()))
					{
						var responseText = streamReader.ReadToEnd();
						return JObject.Parse(responseText);
					}
				}
			}
        }
    }
}
