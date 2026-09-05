package com.murschol.launcher

import android.app.Activity
import android.content.Intent
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.widget.GridLayout
import android.widget.TextView
import java.util.Locale
import kotlin.math.max

class AppDrawerActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_app_drawer)

        findViewById<TextView>(R.id.backButton).setOnClickListener { finish() }

        val grid = findViewById<GridLayout>(R.id.appsGrid)
        val widthDp = resources.configuration.screenWidthDp
        grid.columnCount = max(3, widthDp / 150)

        val query = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val activities = packageManager.queryIntentActivities(query, 0)
            .filter { it.activityInfo.packageName != packageName }
            .distinctBy { it.activityInfo.packageName to it.activityInfo.name }
            .sortedBy { it.loadLabel(packageManager).toString().lowercase(Locale.getDefault()) }

        activities.forEach { info ->
            val label = info.loadLabel(packageManager).toString()
            val icon = info.loadIcon(packageManager)
            val item = TextView(this).apply {
                text = label
                gravity = Gravity.CENTER
                setTextColor(getColor(R.color.murschol_text))
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                background = getDrawable(R.drawable.tile_background)
                setPadding(dp(12), dp(14), dp(12), dp(14))
                minHeight = dp(112)
                isClickable = true
                isFocusable = true
                setCompoundDrawables(null, scaled(icon, dp(42)), null, null)
                compoundDrawablePadding = dp(10)
                setOnClickListener {
                    val launch = packageManager.getLaunchIntentForPackage(info.activityInfo.packageName)
                    if (launch != null) startActivity(launch)
                }
            }

            val lp = GridLayout.LayoutParams().apply {
                width = 0
                height = GridLayout.LayoutParams.WRAP_CONTENT
                columnSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f)
                setMargins(dp(6), dp(6), dp(6), dp(6))
            }
            grid.addView(item, lp)
        }
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    private fun scaled(drawable: Drawable, size: Int): Drawable {
        drawable.setBounds(0, 0, size, size)
        return drawable
    }
}
