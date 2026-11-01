plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// GitHub runners must use the existing Windows keystore, never a freshly
// generated debug key. Local builds keep the existing debug signing behavior.
val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")?.takeIf { it.isNotBlank() }
val keystorePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")?.takeIf { it.isNotBlank() }
val signingKeyAlias = System.getenv("ANDROID_KEY_ALIAS")?.takeIf { it.isNotBlank() }
val signingKeyPassword = System.getenv("ANDROID_KEY_PASSWORD")?.takeIf { it.isNotBlank() }
val signingValues = listOf(keystorePath, keystorePassword, signingKeyAlias, signingKeyPassword)
val hasExternalSigning = signingValues.all { it != null }
if (signingValues.any { it != null } && !hasExternalSigning) {
    throw GradleException("All ANDROID_KEYSTORE_* and ANDROID_KEY_* signing variables are required")
}
if (System.getenv("GITHUB_ACTIONS") == "true" && !hasExternalSigning) {
    throw GradleException("GitHub builds require the existing signing keystore")
}
if (hasExternalSigning && !file(keystorePath!!).isFile) {
    throw GradleException("Signing keystore does not exist")
}

android {
    namespace = "com.floatingbutton.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.floatingbutton.app"
        // API 28 is required for AccessibilityService.GLOBAL_ACTION_LOCK_SCREEN
        minSdk = 28
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasExternalSigning) {
            create("existingRelease") {
                storeFile = file(keystorePath!!)
                storePassword = keystorePassword
                this.keyAlias = signingKeyAlias
                this.keyPassword = signingKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(
                if (hasExternalSigning) "existingRelease" else "debug"
            )
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Petal Ads Prime supports Huawei and other Android devices with HMS Core.
    implementation("com.huawei.hms:ads-prime:3.4.90.300")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.2.20")
    implementation("androidx.core:core-ktx:1.13.1")
}
