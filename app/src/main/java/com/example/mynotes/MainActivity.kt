package com.example.mynotes

import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.SimpleCursorAdapter
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    var db : SQLiteDatabase? = null
    var cursor :Cursor?=null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        var objToCreateDB = notesSQLiteonlinehelper(this)
        db = objToCreateDB.readableDatabase
        cursor = db!!.query("NOTES" , arrayOf("_id","title"),
                null , null, null, null , null)

        val listAdapter = SimpleCursorAdapter(this,
                android.R.layout.simple_list_item_1,
                cursor,
                arrayOf("title"),
                intArrayOf(android.R.id.text1),
                0
        )
        notes.adapter = listAdapter
    }

    override fun onDestroy() {
        super.onDestroy()
        cursor!!.close()
        db!!.close()
    }
}
