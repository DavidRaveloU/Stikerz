import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Mantienes tu configuración de buildDir
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

// Ajuste de buildDir por subproyecto
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// FIX GLOBAL REAL
subprojects {

    afterEvaluate {

        // Para apps Android
        plugins.withId("com.android.application") {
            extensions.configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(36)
            }
        }

        // Para librerías Android (como isar_flutter_libs)
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(36)
            }
        }
    }

    project.evaluationDependsOn(":app")
}

// Limpieza
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}