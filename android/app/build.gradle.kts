plugins {
    id("com.android.application")
    id("kotlin-android")
    // O plugin do Flutter precisa ser aplicado depois dos plugins Android e Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase (Google Services) — adicionado pelo flutterfire configure.
    id("com.google.gms.google-services")
}

android {
    namespace = "br.com.guilhermeribeiro.tarefasgeo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "br.com.guilhermeribeiro.tarefasgeo"
        // minSdk 23: exigido pelos plugins Firebase (Firestore/Auth) e suficiente
        // para geolocator. targetSdk/compileSdk seguem o padrão do Flutter.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Assina com a chave de debug por enquanto, para `flutter run --release`
            // funcionar. Para publicar na loja, configure uma signing config real.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
