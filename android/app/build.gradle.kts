plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.davidravelo.whaticker"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    androidResources {
        noCompress += "webp"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.davidravelo.whaticker"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Read AdMob App ID from gradle.properties; fallback to placeholder for safety
        val admobAppId = project.properties["ADMOB_APP_ID"]?.toString() ?: "ADMOB_APP_ID_PLACEHOLDER"
        resValue("string", "admob_app_id", admobAppId)
    }

    buildTypes {
        release {
            // evitar que rompa plugins
            isMinifyEnabled = false
            isShrinkResources = false

            // (lo dejamos como lo tienes)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}