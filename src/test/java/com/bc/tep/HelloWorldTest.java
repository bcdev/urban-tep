package com.bc.tep;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.core.IsEqual.equalTo;

import org.junit.*;

/**
 * @author hans
 */
public class HelloWorldTest {

    @Test
    public void testHello() throws Exception {
        HelloWorld helloWorld = new HelloWorld();
        assertThat(helloWorld.hello(), equalTo("HelloWorld!"));
    }
}