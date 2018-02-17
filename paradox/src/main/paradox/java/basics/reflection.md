# Reflection

## Contructor

```java
try {
    Class<?> clazz = Class.forName("net.example.reflection.Foo");
    Foo foo = (Foo) clazz.newInstance();
} catch (ClassNotFoundException e) {
    throw e;
} catch (InstantiationException e) {
    throw e;
} catch (IllegalAccessException e) {
    throw e;
}
```

## Instance method

```java
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;

public class Calc {
    public int sum(int a, int b) {
        return a + b;
    }

    public static void main(String[] args) throws Exception {
        Calc obj = new Calc();
        try {
            Method m = obj.getClass().getMethod("sum", int.class, int.class);
            System.out.println(m.invoke(obj, 2, 3));
        } catch (InvocationTargetException e) {
            throw (Exception) e.getCause();
        } catch (NoSuchMethodException e) {
            throw e;
        }
    }
}
```

## Tips

### Getting the current class name statically

```java
public class MyClass {
    private static final String TAG = (new Throwable()).getStackTrace()[0].getClassName();
}
```
