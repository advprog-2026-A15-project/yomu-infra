plugins {
    java
}

group = "id.ac.ui.cs.advprog.yomu"
version = "0.0.1-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.11.4")
    testImplementation("org.seleniumhq.selenium:selenium-java:4.27.0")
    testImplementation("io.github.bonigarcia:webdrivermanager:5.9.2")
    testImplementation("org.assertj:assertj-core:3.27.3")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.test {
    useJUnitPlatform()
    // Override via -DAPP_URL=http://... when running against staging/prod
    systemProperty("APP_URL",        System.getProperty("APP_URL",        "http://localhost:5173"))
    systemProperty("HEADLESS",       System.getProperty("HEADLESS",       "true"))
    systemProperty("TEST_USERNAME",  System.getProperty("TEST_USERNAME",  "testuser"))
    systemProperty("TEST_PASSWORD",  System.getProperty("TEST_PASSWORD",  "testpassword123"))
    systemProperty("ADMIN_USERNAME", System.getProperty("ADMIN_USERNAME", "adminuser"))
    systemProperty("ADMIN_PASSWORD", System.getProperty("ADMIN_PASSWORD", "adminpassword123"))
    systemProperty("ADMIN_TOKEN",    System.getProperty("ADMIN_TOKEN",    ""))
    testLogging {
        events("passed", "skipped", "failed")
        showExceptions = true
        showStackTraces = true
    }
}
