package com.example.hello;

/**
 * Minimal Hello World application.
 *
 * <p>The version is read from the jar manifest ({@code Implementation-Version}),
 * which is populated at build time from the {@code appVersion} Gradle property
 * supplied by the semantic-versioning workflow. Falls back to the
 * {@code app.version} system property, then to {@code "dev"}.
 */
public final class App {

    private App() {
    }

    static String version() {
        String version = App.class.getPackage().getImplementationVersion();
        if (version == null || version.isBlank()) {
            version = System.getProperty("app.version", "dev");
        }
        return version;
    }

    static String greeting() {
        return "Hello, World! (version " + version() + ")";
    }

    public static void main(String[] args) {
        System.out.println(greeting());
    }
}
