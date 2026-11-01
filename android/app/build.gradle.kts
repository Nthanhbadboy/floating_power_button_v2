plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
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
        versionCode = 2
        versionName = "2.0.0"

        // Size: ship only ARM ABIs (every real phone) instead of x86/x86_64 as well.
        // Skipped when Flutter already restricts ABIs (--split-per-abi / --target-platform),
        // because AGP forbids combining abiFilters with ABI splits.
        if (!project.hasProperty("split-per-abi") && !project.hasProperty("target-platform")) {
            ndk {
                abiFilters += listOf("arm64-v8a", "armeabi-v7a")
            }
        }
    }

    packaging {
        jniLibs {
            // Compress native libs inside the APK (libflutter.so / libapp.so are the
            // bulk of the file) -> much smaller APK download/sideload size.
            useLegacyPackaging = true
        }
        resources {
            excludes += setOf(
                "META-INF/*.version",
                "META-INF/LICENSE*",
                "META-INF/NOTICE*",
                "META-INF/DEPENDENCIES",
                "DebugProbesKt.bin"
            )
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
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
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.2.20")
    implementation("androidx.core:core-ktx:1.13.1")
}
