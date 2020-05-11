package com.example.mynotes


import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class Userdatabasehelper (context: Context) : SQLiteOpenHelper(context,"userdb",null , 1){
    override fun onCreate(db: SQLiteDatabase?) {
        db!!.execSQL("CREATE table user(email text primary key , password text)")
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        db!!.execSQL("DROP table if exists user")
    }
    fun insert(email:String ,password:String): Boolean {
        var db = this.writableDatabase
        var content = ContentValues()
        content.put("email",email)
        content.put("password",password)
        val t=db!!.insert("user", null, content)
        return t >= 0
    }
    fun checkemail(email:String){
        var db = this.writableDatabase
        var Cursor = db!!.rawQuery("SELECT * from  user where email=?", arrayOf("email","password"))
    }

}