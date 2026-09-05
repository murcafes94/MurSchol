package com.murschol.launcher

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.TextView
import android.widget.Toast
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : Activity() {

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var timeText: TextView
    private lateinit var dateText: TextView

    private val clockTask = object : Runnable {
        override fun run() {
            updateClock()
            handler.postDelayed(this, 30_000)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        timeText = findViewById(R.id.timeText)
        dateText = findViewById(R.id.dateText)

        findViewById<TextView>(R.id.tileMoodle).setOnClickListener {
            launchByLabels("moodle", "aula virtual")
        }
        findViewById<TextView>(R.id.tileLibrary).setOnClickListener {
            launchByLabels("moon+", "moon reader", "kindle", "readera", "librera")
        }
        findViewById<TextView>(R.id.tileNotes).setOnClickListener {
            launchByLabels("notas", "notes", "keep", "joplin", "obsidian")
        }
        findViewById<TextView>(R.id.tileInternet).setOnClickListener {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://www.google.com")))
        }
        findViewById<TextView>(R.id.tileFiles).setOnClickListener {
            try {
                startActivity(Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "*/*"
                })
            } catch (_: Exception) {
                Toast.makeText(this, "No encontré un gestor de archivos.", Toast.LENGTH_SHORT).show()
            }
        }
        findViewById<TextView>(R.id.tileYoutube).setOnClickListener {
            if (!launchByLabels("youtube", "morphe", "revanced")) {
                startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com")))
            }
        }
        findViewById<TextView>(R.id.appsButton).setOnClickListener {
            startActivity(Intent(this, AppDrawerActivity::class.java))
        }
    }

    override fun onResume() {
        super.onResume()
        handler.removeCallbacks(clockTask)
        handler.post(clockTask)
    }

    override fun onPause() {
        handler.removeCallbacks(clockTask)
        super.onPause()
    }

    private fun updateClock() {
        val locale = Locale("es", "EC")
        val now = Date()
        timeText.text = SimpleDateFormat("HH:mm", locale).format(now)
        dateText.text = SimpleDateFormat("EEEE, d 'de' MMMM", locale).format(now)
            .replaceFirstChar { if (it.isLowerCase()) it.titlecase(locale) else it.toString() }
    }

    private fun launchByLabels(vararg needles: String): Boolean {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val activities = packageManager.queryIntentActivities(intent, 0)
        val lowered = needles.map { it.lowercase(Locale.getDefault()) }

        val match = activities.firstOrNull { info ->
            val label = info.loadLabel(packageManager).toString().lowercase(Locale.getDefault())
            info.activityInfo.packageName != packageName && lowered.any { it in label }
        }

        if (match != null) {
            val launchIntent = packageManager.getLaunchIntentForPackage(match.activityInfo.packageName)
            if (launchIntent != null) {
                startActivity(launchIntent)
                return true
            }
        }

        Toast.makeText(this, "No encontré esa aplicación instalada.", Toast.LENGTH_SHORT).show()
        return false
    }
}
