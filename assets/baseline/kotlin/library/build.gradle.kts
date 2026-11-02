plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.compose)
    id("maven-publish")
}

android {
    namespace = "hyper_ui"
    compileSdk = 37

    defaultConfig {
        minSdk = 30
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    buildFeatures {
        compose = true
    }

    publishing {
        singleVariant("release") {
            withSourcesJar()
        }
    }
}

dependencies {
    // 动画和背景采样均保持在组件材质层。
    api(platform(libs.androidx.compose.bom))
    api("androidx.compose.foundation:foundation")
    api("androidx.compose.runtime:runtime")
    implementation("androidx.compose.animation:animation-core")
    api("androidx.compose.ui:ui")
    api("androidx.compose.ui:ui-graphics")
    // 正式组件与 Preview 直接使用同一套 Lucide ImageVector，不在项目内复制路径。
    implementation(libs.lucide.icons)
}

publishing {
    publications {
        register("release", MavenPublication::class) {
            groupId = "com.hyperui"
            artifactId = "hyper-ui"
            version = "1.0.0"

            afterEvaluate {
                from(components["release"])
            }
        }
    }
}
