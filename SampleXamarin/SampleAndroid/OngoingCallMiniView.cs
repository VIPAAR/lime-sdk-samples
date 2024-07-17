using Android.Content;
using Android.Util;
using Android.Views;
using Android.Widget;
using AndroidX.ConstraintLayout.Widget;
using System;

namespace HelpLightning.SDK.Sample.Android
{
    public class OngoingCallMiniView : ConstraintLayout
    {
        private TextView Label => FindViewById<TextView>(Resource.Id.label);
        private FrameLayout MiniViewContainer => FindViewById<FrameLayout>(Resource.Id.call_miniview);
        private View MaximizeCallButton => FindViewById<View>(Resource.Id.button_maximize);
        private View EndCallButton => FindViewById<View>(Resource.Id.button_end_call);

        public IOngoingCallListener OngoingCallListener { get; set; }

        public OngoingCallMiniView(Context context, IAttributeSet attrs) : base(context, attrs)
        {
            Inflate(context, Resource.Layout.session_minimized_view, this);
            Label.Selected = true;
            MaximizeCallButton.Click += (sender, e) => OngoingCallListener?.OnMaximizeCall();
            EndCallButton.Click += (sender, e) => OngoingCallListener?.OnEndCall();
        }

        public void SetCallInfo(View view, string title)
        {
            if (view == null)
            {
                Visibility = ViewStates.Gone;
            }
            else
            {
                Visibility = ViewStates.Visible;
                Label.Text = title;
                if (view.Parent != null)
                {
                    ((ViewGroup)view.Parent).RemoveView(view);
                }
                MiniViewContainer.RemoveAllViews();
                MiniViewContainer.AddView(view);
            }
        }
    }

    public interface IOngoingCallListener
    {
        void OnMaximizeCall();
        void OnEndCall();
    }
}
