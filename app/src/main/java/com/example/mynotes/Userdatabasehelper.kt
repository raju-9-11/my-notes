package com.example.mynotes


import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class Userdatabasehelper (context: Context) : SQLiteOpenHelper(context,"userdb",null , 1){
    override fun onCreate(db: SQLiteDatabase?) {
        db!!.execSQL("CREATE table user(email text primary key , password text)")
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
    }


}