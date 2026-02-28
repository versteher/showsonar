import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.streamscout.app.dev"
            resValue(type = "string", name = "app_name", value = "StreamScout Dev")
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.streamscout.app.staging"
            resValue(type = "string", name = "app_name", value = "StreamScout Stg")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.streamscout.app"
            resValue(type = "string", name = "app_name", value = "StreamScout")
        }
    }
}