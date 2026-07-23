package com.example.hello;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class AppTest {

    @Test
    void greetingContainsHelloWorld() {
        assertTrue(App.greeting().startsWith("Hello, World!"),
                "greeting should start with the Hello, World! message");
    }

    @Test
    void versionIsNeverNull() {
        assertNotNull(App.version(), "version must always resolve to a value");
    }
}
