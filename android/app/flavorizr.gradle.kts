import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.showsonar.app.dev"
            resValue(type = "string", name = "app_name", value = "ShowSonar Dev")
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.showsonar.app.staging"
            resValue(type = "string", name = "app_name", value = "ShowSonar Stg")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.showsonar.app"
            resValue(type = "string", name = "app_name", value = "ShowSonar")
        }
    }
}