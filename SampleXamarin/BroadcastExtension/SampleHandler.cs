using System;
using Foundation;

namespace BroadcastExtension
{
    // To handle samples with a subclass of RPBroadcastSampleHandler set the following in the extension's Info.plist file:
    // - RPBroadcastProcessMode should be set to RPBroadcastProcessModeSampleBuffer
    // - NSExtensionPrincipalClass should be set to this class
    [Register("SampleHandler")]
    public class SampleHandler : HelpLightning.SDK.iOS.Binding.ScreenSharing.HLScreenSharingBroadcastSampleHandler
    {
		protected SampleHandler (IntPtr handle) : base (handle)
		{
		}
        public override string AppGroupName => "group.com.helplightning.sdk.sample.xamarin.ios.BroadcastExtension";
    }
}

