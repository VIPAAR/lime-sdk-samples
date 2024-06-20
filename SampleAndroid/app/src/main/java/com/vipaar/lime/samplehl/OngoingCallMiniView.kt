package com.vipaar.lime.samplehl

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout

class OngoingCallMiniView(context: Context, attrs: AttributeSet?) : ConstraintLayout(context, attrs) {

    private val label: TextView
        get() = findViewById(R.id.label)
    private val miniViewContainer: FrameLayout
        get() = findViewById(R.id.call_miniview)
    private val maximizeCallButton: View
        get() = findViewById(R.id.button_maximize)
    private val endCallButton: View
        get() = findViewById(R.id.button_end_call)

    var ongoingCallListener: OngoingCallListener? = null

    init {
        inflate(context, R.layout.session_minimized_view, this)
        label.isSelected = true
        maximizeCallButton.setOnClickListener {
            ongoingCallListener?.onMaximizeCall()
        }
        endCallButton.setOnClickListener {
            ongoingCallListener?.onEndCall()
        }
    }

    fun setCallInfo(view: View?, title: String?) {
        if (view == null) {
            visibility = View.GONE
        } else {
            visibility = View.VISIBLE
            label.text = title
            view.parent?.let { parent ->
                (parent as ViewGroup).removeView(view)
            }
            miniViewContainer.removeAllViews()
            miniViewContainer.addView(view)
        }
    }
}
