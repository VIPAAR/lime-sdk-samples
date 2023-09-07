package com.vipaar.lime.samplehl

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import com.vipaar.lime.hlsdk.client.HLClient
import com.vipaar.lime.hlsdk.events.KnowledgeType

class ImageSelectActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_photo_select)
        findViewById<Button>(R.id.select_image_button).setOnClickListener {
            val i = Intent(Intent.ACTION_GET_CONTENT)
            i.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*")
            startActivityForResult(i, intent.getIntExtra("mode", MODE_QUICK_KNOWLEDGE))
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if ((requestCode == MODE_QUICK_KNOWLEDGE || requestCode == MODE_QUICK_KNOWLEDGE_OVERLAY) && resultCode == RESULT_OK) {
            processSelectedImageUri(data?.data, requestCode)
            finish()
        }
    }

    private fun processSelectedImageUri(localUri: Uri?, requestCode: Int) {
        localUri?.let {
            if (requestCode == MODE_QUICK_KNOWLEDGE) {
                HLClient.getInstance().onKnowledgeSelected(it, KnowledgeType.IMAGE)
            } else if (requestCode == MODE_QUICK_KNOWLEDGE_OVERLAY) {
                HLClient.getInstance().onQuickKnowledgeOverlaySelected(it)
            }
        }
    }

    companion object {
        const val MODE_QUICK_KNOWLEDGE = 1
        const val MODE_QUICK_KNOWLEDGE_OVERLAY = 2
    }
}