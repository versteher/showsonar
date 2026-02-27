import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.neonvoyager.app.dev"
            resValue(type = "string", name = "app_name", value = "Neon Dev")
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.neonvoyager.app.staging"
            resValue(type = "string", name = "app_name", value = "Neon Stg")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.neonvoyager.app"
            resValue(type = "string", name = "app_name", value = "Neon Voyager")
        }
    }
}