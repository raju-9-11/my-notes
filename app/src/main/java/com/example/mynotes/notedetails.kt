package com.example.mynotes

import android.app.AlertDialog
import android.content.ContentValues
import android.content.DialogInterface
import android.content.Intent
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import com.example.mynotesZZ.notesSQLiteonlinehelper
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.activity_notedetails.*

class notedetails : AppCompatActivity() {

    var db:SQLiteDatabase? = null
    var noteId:Int =0
    var cursor:Cursor?=null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_notedetails)

        val myNotesDatabaseHelper = notesSQLiteonlinehelper(this)
        db = myNotesDatabaseHelper.writableDatabase

        noteId= intent.extras!!.get("NOTE_ID").toString().toInt()

        if(noteId!=0){
            cursor = db?.query("NOTES", arrayOf("TITLE","DESCRIPTION"),"_id=?", arrayOf(noteId.toString()),null,null,null)
            if(cursor!!.moveToFirst()){
                editText.setText(cursor!!.getString(0))
                editTextDEscription.setText(cursor!!.getString(1))
            }
        }

    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {


        if (item!!.itemId == R.id.save_note){

            val newvalues = ContentValues()
            newvalues.put("TITLE", editText.text.toString())
            newvalues.put("DESCRIPTION", editTextDEscription.text.toString())
            if (editText.text.isEmpty() ){
                Toast.makeText(
                    this,
                    "Enter Title",
                    Toast.LENGTH_LONG
                ).show()
            }else {
                if (noteId == 0) {
                    insertnote(newvalues)
                } else {
                    updatenote(newvalues)
                }
            }
            val intent = Intent(this, MainActivity::class.java)
            startActivity(intent)
        }else if(item!!.itemId==R.id.delete_note){
            deletenote()
        }
        return super.onOptionsItemSelected(item)
    }
    fun deletenote(){
        var dialog: AlertDialog
        var builder = AlertDialog.Builder(this)


        builder.setTitle("Deleting Node")

        builder.setMessage("The note '${editText.text}' will be deleted")
        builder.setPositiveButton("YES",dialogClickListener)
        builder.setNegativeButton("Cancel",dialogClickListener)
        dialog = builder.create()
        dialog.show()


    }
    val dialogClickListener = DialogInterface.OnClickListener { _, which ->
        if(which == DialogInterface.BUTTON_POSITIVE){
            db!!.delete("NOTES","_id=?", arrayOf(noteId.toString()))
            Toast.makeText(this,"Note Deleted",Toast.LENGTH_SHORT).show()
            val intent = Intent(this, MainActivity::class.java)
            startActivity(intent)
        }

    }
    fun updatenote(notevalues: ContentValues){
        try {
            db!!.update("NOTES", notevalues, "_id=?", arrayOf(noteId.toString()))
            Toast.makeText(this, "Note Updated", Toast.LENGTH_SHORT).show()
            val intent = Intent(this, MainActivity::class.java)
            startActivity(intent)
        }catch (e: Exception){
            Toast.makeText(this, "Update error $e",Toast.LENGTH_SHORT).show()
        }
    }

    private fun insertnote(newvalues:ContentValues) {


            db!!.insert("NOTES", null, newvalues)

            Toast.makeText(this, "Note Saved", Toast.LENGTH_LONG).show()

    }

    override fun onCreateOptionsMenu(menu: Menu?):Boolean {

        menuInflater.inflate(R.menu.note_detail_menu,menu)
        return super.onCreateOptionsMenu(menu)
    }

    override fun onDestroy() {
        super.onDestroy()

        db!!.close()
    }
}
