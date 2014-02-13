---
layout: page

title: JUnit
---

## Overview 

* <http://www.junit.org/>

### Unix

    % cd /path/to/project
    % mkdir test
    % cd test
    % vi HellWorldTest.java

    % javac -classpath /path/to/junit.jar:/path/to/classes HelloWorldTest.java
    # JUnit3
    % java -classpath /path/to/junit.jar:/path/to/classes junit.textui.TestRunner HelloWorldTest
    # JUnit4
    % java -classpath /path/to/junit.jar:/path/to/classes org.junit.runner.JUnitCore HelloWorldTest

## JUnit4

    import static org.junit.Assert.*;
    import org.junit.Test;

    public class PersonTest {
        @Test
        public void testGetName() {
            Person obj = new Person();
            obj.setName("Foo Bar");
            assertEquals(obj.getName(), "Foo Bar");
            assertTrue(obj.getName().equals("Foo Bar"));
        }

        @Test
        public void testGetAge() {
            Person obj = new Person();
            obj.setAge(28);
            assertEquals(obj.getAge(), 28);
        }

        @Test
        public void testCalcBirthYear() {
            Person obj = new Person();
            obj.setAge(28);
            assertEquals(obj.calcBirthYear(2012), 1984);
        }

        @Test
        public void testFail() {
            fail("Faiure message");
        }
    }

    public class Person {
        private String name;
        private int age;

        public Person() {
        }

        public String getName() {
            return this.name;
        }

        public void setName(String str) {
            this.name = str;
        }

        public int getAge() {
            return this.age;
        }

        public void setAge(int n) {
            this.age = n;
        }

        public int calcBirthYear(int year) {
            return year - this.age;
        }
    }

