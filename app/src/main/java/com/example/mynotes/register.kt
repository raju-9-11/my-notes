package com.example.mynotes

import android.database.sqlite.SQLiteDatabase
import android.os.Bundle
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_register.*

class register : AppCompatActivity() {

    var db : SQLiteDatabase?=null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)

        button2.setOnClickListener{
            val em = editText4.text.toString()
            val pass1 = editText5.text.toString()
            val pass2 = editText6.text.toString()
            Toast.makeText(this,"Your pass is $pass1",Toast.LENGTH_SHORT).show()
        }
    }
}
