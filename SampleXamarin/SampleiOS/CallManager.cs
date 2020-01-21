using System;
namespace HelpLightning.SDK.Sample.iOS
{
    public class CallManager
    {
        private static CallManager instance;

        public static CallManager Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new CallManager();
                }
                return instance;
            }
        }

        public CallManager()
        {
        }
        public string ServerURL = "";
        public string AuthToken = "";
        public string UserEmail = "";
        public string ContactEmail = "";
        public string UserName = "";
        public string UserAvatar = "";
        public string UserToken = "";
        public string SessionToken = "";
        public string SessionID = "";
        public string GssServerURL = "";
        public string SessionPIN = "";
    }
}
