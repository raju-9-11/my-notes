package com.example.mynotes

import android.content.Intent
import android.media.MediaPlayer
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.webkit.WebView
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.activity_main2.*

class Main2Activity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main2)

        val mediaPlayer = MediaPlayer.create(
            this,
            R.raw.home
        )
        val web:WebView = findViewById(R.id.webview)
        web.loadUrl("https://www.google.com/")
        play.setOnClickListener{
            if(mediaPlayer.isPlaying){
                mediaPlayer.pause()
            }else {
                mediaPlayer.start()
            }
        }
        button.setOnClickListener {
            val user= editText2.text.toString()
            val pass = editText3.text.toString()
            if (user.length > 4 && pass.length > 4) {
                Toast.makeText(this,"Hello $user",Toast.LENGTH_SHORT).show()
                val intent = Intent(this, MainActivity::class.java)
                startActivity(intent)

            } else {
                Toast.makeText(
                    this,
                    "Username and password should be atleast 5 characters long",
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
        button3.setOnClickListener{
            Snackbar.make(findViewById(android.R.id.content),"Under Construction",Snackbar.LENGTH_SHORT).show()
        }
    }
}
