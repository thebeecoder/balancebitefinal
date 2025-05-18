package com.example.balancebite

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.realm.Realm
import io.realm.RealmConfiguration
import io.realm.mongodb.App
import io.realm.mongodb.AppConfiguration

class MainActivity: FlutterActivity() {

    // Define the App ID for MongoDB Realm
    private val appId = "balancebiteapp-ypqajni"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Realm
        Realm.init(this)  // Initializes the Realm library with the context

        // Initialize MongoDB Realm App using the App ID
        val app = App(AppConfiguration.Builder(appId).build())  // Initialize MongoDB Realm App with the App ID

        // Optionally, you can configure Realm with custom settings (e.g., schema version, migration, etc.)
        val config = RealmConfiguration.Builder().build()
        Realm.setDefaultConfiguration(config)
    }
}
