using System;
using System.Reflection.Emit;
using Android.App;
using Android.Runtime;
using HelpLightning.SDK.Android.Binding;

namespace HelpLightning.SDK.Sample.Android
{
    /*
     * <application android:allowBackup="true" tools:replace="android:allowBackup" android:icon="@mipmap/ic_launcher"
     * android:label="@string/app_name" android:supportsRtl="true" android:theme="@style/AppTheme">
	 *     <meta-data android:name="com.google.ar.core" android:value="optional" />
	 * </application>
     */
    [Application]
    public class SampleApplication : Application
    {
        protected SampleApplication(IntPtr javaReference, JniHandleOwnership transfer)
            : base(javaReference, transfer)
        {
        }


        public override void OnCreate()
        {
            base.OnCreate();

            HLClient.Instance.Init(ApplicationContext);
        }
    }
}

