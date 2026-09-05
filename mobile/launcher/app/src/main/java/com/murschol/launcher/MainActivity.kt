package com.murschol.launcher

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : Activity() {

    private lateinit var dateText: TextView
    private lateinit var greetingText: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        dateText = findViewById(R.id.dateText)
        greetingText = findViewById(R.id.greetingText)
        updateHeader()

        bind(R.id.tileMoodle, R.id.dockMoodle) { launchByLabels("moodle", "aula virtual") }
        bind(R.id.tileLibrary, R.id.dockLibrary) { showLibraryChooser() }
        bind(R.id.tileNotes, R.id.dockNotes, R.id.continueNotCan) { launchNotCan() }
        bind(R.id.tileInternet, R.id.dockInternet) {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://www.google.com")))
        }
        bind(R.id.tileFiles) { openFiles() }
        bind(R.id.tileYoutube, R.id.dockYoutube) { openYouTube() }
        bind(R.id.appsButton, R.id.searchButton) {
            startActivity(Intent(this, AppDrawerActivity::class.java))
        }

        findViewById<View>(R.id.homeButton).setOnClickListener {
            findViewById<ScrollView>(R.id.homeScroll).smoothScrollTo(0, 0)
        }
    }

    override fun onResume() {
        super.onResume()
        updateHeader()
    }

    private fun bind(vararg ids: Int, action: () -> Unit) {
        ids.forEach { id -> findViewById<View>(id).setOnClickListener { action() } }
    }

    private fun updateHeader() {
        val locale = Locale("es", "EC")
        val now = Date()
        dateText.text = SimpleDateFormat("EEEE, d 'de' MMMM", locale).format(now)
            .replaceFirstChar { if (it.isLowerCase()) it.titlecase(locale) else it.toString() }

        val hour = SimpleDateFormat("H", locale).format(now).toIntOrNull() ?: 12
        greetingText.text = when (hour) {
            in 5..11 -> "Buenos días"
            in 12..18 -> "Buenas tardes"
            else -> "Buenas noches"
        }
    }

    private fun launchNotCan() {
        if (!launchPackages(arrayOf("com.notcan.app"))) {
            if (!launchByLabels("notcan")) {
                Toast.makeText(this, "No encontré NotCan instalada.", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun showLibraryChooser() {
        val options = arrayOf("Moon+ Reader", "Kindle")
        AlertDialog.Builder(this)
            .setTitle("Abrir Biblioteca con")
            .setItems(options) { _, which ->
                when (which) {
                    0 -> {
                        if (!launchPackages(arrayOf("com.flyersoft.moonreaderp", "com.flyersoft.moonreader")) &&
                            !launchByLabels("moon+", "moon reader")) {
                            Toast.makeText(this, "No encontré Moon+ Reader instalada.", Toast.LENGTH_SHORT).show()
                        }
                    }
                    1 -> {
                        if (!launchPackages(arrayOf("com.amazon.kindle")) && !launchByLabels("kindle")) {
                            Toast.makeText(this, "No encontré Kindle instalada.", Toast.LENGTH_SHORT).show()
                        }
                    }
                }
            }
            .setNegativeButton("Cancelar", null)
            .show()
    }

    private fun openFiles() {
        try {
            startActivity(Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "*/*"
            })
        } catch (_: Exception) {
            Toast.makeText(this, "No encontré un gestor de archivos.", Toast.LENGTH_SHORT).show()
        }
    }

    private fun openYouTube() {
        if (!launchByLabels("youtube", "morphe", "revanced")) {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com")))
        }
    }

    private fun launchPackages(packages: Array<String>): Boolean {
        packages.forEach { packageName ->
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                startActivity(intent)
                return true
            }
        }
        return false
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
        return false
    }
}
