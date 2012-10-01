---
layout: page

title: JUnit
---

## 概要

**JUnit**

<http://www.junit.org/>

## Unix

    % cd /path/to/project
    % mkdir test
    % cd test
    % vi HellWorldTest.java

    % javac -classpath /path/to/junit.jar:/path/to/classes HelloWorldTest.java
    # JUnit3
    % java -classpath /path/to/junit.jar:/path/to/classes junit.textui.TestRunner HelloWorldTest
    # JUnit4
    % java -classpath /path/to/junit.jar:/path/to/classes org.junit.runner.JUnitCore HelloWorldTest

## Eclipse

テストクラスを作成するソースフォルダを選択し

    File > New > JUnit Test Case

でテストクラスの作成ウィザードが起動します。

<dl>
<dt>SourceFolder</dt>
<dd><code>(Eclipse プロジェクト)/test</code></dd>
<dt>Package</dt>
<dd>作成するテストクラスの `package</code> 名</dd>
<dt>Name</dt>
<dd>作成するテストクラス名</dd>
<dt>Class under test</dt>
<dd>テスト対象クラス名</dd>
</dl>

作成したテストクラスのソースを選択し

    Run > Run As > JUnit Test

でテスト実行されます。


## JUnit4

テストメゾッドは `@Test` アノテーションをつけるだけです。

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


