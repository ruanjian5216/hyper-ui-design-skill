import org.jetbrains.kotlin.gradle.ExperimentalWasmDsl

plugins {
    alias(libs.plugins.kotlin.multiplatform)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.compose.multiplatform)
}

// GitHub Release 无法直连时，可把官方 Binaryen 压缩包放在本地目录并通过环境变量注入。
// 只接管 Binaryen 模块，其他依赖继续使用常规仓库；未设置变量时保持默认下载行为。
System.getenv("HYPER_UI_BINARYEN_ARCHIVE_DIR")?.takeIf { it.isNotBlank() }?.let { archivePath ->
    val archiveDirectory = file(archivePath)
    require(archiveDirectory.isDirectory) {
        "HYPER_UI_BINARYEN_ARCHIVE_DIR 不是已存在的目录：$archivePath"
    }
    repositories {
        exclusiveContent {
            forRepository {
                ivy {
                    name = "localBinaryenArchives"
                    url = uri(archiveDirectory)
                    patternLayout {
                        artifact("binaryen-version_[revision]-[classifier].[ext]")
                    }
                    metadataSources { artifact() }
                }
            }
            filter { includeModule("com.github.webassembly", "binaryen") }
        }
    }
}

kotlin {
    jvm("desktop")

    @OptIn(ExperimentalWasmDsl::class)
    wasmJs {
        outputModuleName = "hyper-ui-preview"
        browser {
            commonWebpackConfig {
                outputFileName = "hyper-ui-preview.js"
            }
        }
        binaries.executable()
    }

    sourceSets {
        getByName("commonMain") {
            // 组件和文档 UI 均为平台无关 Compose 源码，由 Desktop 与 Wasm 共同编译。
            kotlin.srcDir("../library/src/main/java")
            // Android 原生 Toast 由跨平台 Preview 使用交互模拟展示，避免引入 Android 编译链。
            kotlin.exclude("**/HyperToast.kt")
            // Android 电池状态读取由跨平台 Preview 使用交互模拟展示，避免引入 Android 编译链。
            kotlin.exclude("**/HyperBatteryState.kt")
            // Activity 全面屏入口仅属于 Android；预览通过主题安全区开关演示布局。
            kotlin.exclude("**/HyperEdgeToEdge.kt")
            // 正式应用读取 Android 方向；Preview 通过内部作用域模拟手机方向。
            kotlin.exclude("**/HyperSafeAreaOrientation.android.kt")
            // 更新工具的 HTTP、系统下载和生命周期只面向 Android；文档提供交互模拟。
            kotlin.exclude("**/tools/update/android/**")
            // Android Dialog 窗口动画配置由跨平台 Preview 使用同包宿主替代。
            kotlin.exclude("**/HyperDialogHost.kt")
            // Android RuntimeShader 后端由 Preview 的 Skia 实现替换，共用本地折射算法。
            kotlin.exclude("**/HyperGlassShader.android.kt")
            // 日期入口使用 Android 的 LocalDate；Preview 直接复用内部月历和面板。
            kotlin.exclude("**/HyperDatePicker.kt")
            kotlin.exclude("**/HyperCalendar.kt")
            dependencies {
                // Preview 与正式组件复用同一动画和背景模糊实现。
                implementation("org.jetbrains.compose.foundation:foundation:${libs.versions.composeMultiplatform.get()}")
                implementation(libs.lucide.icons)
                implementation("org.jetbrains.compose.components:components-resources:${libs.versions.composeMultiplatform.get()}")
                implementation("org.jetbrains.compose.runtime:runtime:${libs.versions.composeMultiplatform.get()}")
                implementation("org.jetbrains.compose.animation:animation-core:${libs.versions.composeMultiplatform.get()}")
                implementation("org.jetbrains.compose.ui:ui:${libs.versions.composeMultiplatform.get()}")
            }
        }

        getByName("desktopMain") {
            dependencies {
                implementation(compose.desktop.currentOs)
            }
        }

        getByName("wasmJsMain") {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-browser:${libs.versions.kotlinxBrowser.get()}")
            }
        }
    }
}

// VitePress Markdown 是 API 正文的唯一来源；Preview 只消费构建目录中的资源副本。
// 合并默认 composeResources（字体等）与 API 文档到统一的资源目录
val mergedResourcesDir = layout.buildDirectory.dir("generated/merged-compose-resources")
val prepareMergedResources = tasks.register<Sync>("prepareMergedResources") {
    // 首先复制默认的 composeResources（包含字体等）
    from(layout.projectDirectory.dir("src/commonMain/composeResources")) {
        // 字体生成输入不进入文档产物；只分发合并后的完整中英文字体。
        exclude("font/noto_sans_sc_wght.ttf", "font/roboto_regular.ttf")
    }
    // 然后复制 API 文档 markdown 文件
    from(layout.projectDirectory.dir("../vitepress/docs/components")) {
        into("files/api")
        include("**/*.md")
    }
    into(mergedResourcesDir)
}

compose.resources {
    packageOfResClass = "hyper_ui.docs.generated.resources"
    customDirectory(
        sourceSetName = "commonMain",
        directoryProvider = prepareMergedResources.map { mergedResourcesDir.get() }
    )
}

compose.desktop {
    application {
        mainClass = "hyper_ui.docs.MainKt"
    }
}

// 自动将 Wasm 静态产物复制到 VitePress 静态目录，省去手动复制的步骤
tasks.register<Copy>("publishWasmToVitePress") {
    dependsOn("wasmJsBrowserDistribution")
    outputs.upToDateWhen { false }
    from("build/dist/wasmJs/productionExecutable")
    into("../vitepress/public/wasm-preview")
    val outputDirectory = layout.projectDirectory.dir("../vitepress/public/wasm-preview")
    val readinessFile = outputDirectory.file("preview-ready.json").asFile
    doFirst {
        // 复制期间不向文档站声明旧产物可用。
        readinessFile.delete()
    }
    doLast {
        val output = outputDirectory.asFile
        check(output.resolve("index.html").isFile && output.resolve("hyper-ui-preview.js").isFile) {
            "Wasm 预览发布不完整：缺少 index.html 或 hyper-ui-preview.js"
        }
        readinessFile.writeText("{\"version\":\"${System.currentTimeMillis()}\"}\n")
        // 手动生成成功也要清除 watcher 的旧错误，避免完整新产物被错误遮罩挡住。
        output.resolve("preview-build-status.json").writeText(
            "{\"phase\":\"ready\",\"message\":\"组件预览已更新\",\"updatedAt\":${System.currentTimeMillis()}}\n"
        )
        println("Wasm 产物已复制到 vitepress/public/wasm-preview/")
        println("刷新 VitePress 页面即可在文档中看到交互预览")
    }
}
