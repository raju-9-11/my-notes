package com.example.mynotes

import android.content.Intent
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.SimpleCursorAdapter
import com.example.mynotesZZ.notesSQLiteonlinehelper
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    var db : SQLiteDatabase? = null
    var cursor :Cursor?=null
    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        addnote.setOnClickListener{
            opennote(0)
        }
        notes.setOnItemClickListener { parent, view, position, id ->
            opennote(id)
        }


    }
    fun opennote(noteID:Long){
        val intent = Intent(this,notedetails::class.java)
        intent.putExtra("NOTE_ID",noteID)
        startActivity(intent)
    }

    override fun onStart() {
        super.onStart()

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
