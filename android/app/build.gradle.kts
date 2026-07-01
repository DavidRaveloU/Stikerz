import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    val hasReleaseKeystore = keystorePropertiesFile.exists()

    if (hasReleaseKeystore) {
        keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
    }

    namespace = "com.davidravelo.stikerz"
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
        applicationId = "com.davidravelo.stikerz"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Read AdMob App ID from gradle.properties; fallback to placeholder for safety
        val admobAppId = project.properties["ADMOB_APP_ID"]?.toString() ?: "ADMOB_APP_ID_PLACEHOLDER"
        resValue("string", "admob_app_id", admobAppId)
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                val storeFilePath = keystoreProperties["storeFile"] as String
                val storePasswordValue = keystoreProperties["storePassword"] as String
                val keyAliasValue = keystoreProperties["keyAlias"] as String
                val keyPasswordValue = keystoreProperties["keyPassword"] as String

                storeFile = file(storeFilePath)
                storePassword = storePasswordValue
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            }
        }
    }

    buildTypes {
        release {
            // evitar que rompa plugins
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
