---
layout: page

title: Cheat Sheet 
---

## Reflection 

### Instance method

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

## Tips 

### Raising a number to a power

Use `Math.pow`. The operator `^` means XOR in Java.

    System.out.println(Math.pow(10, 3)); // 1000.0 
    System.out.println(10 ^ 3); // 9 -> 1010 XOR 0011 = 1001 

Consider to use `x * x` instead of `Math.pow(x, 2)`.

### Getting the current class name statically 

    public class MyClass {
        private static final String TAG = (new Throwable()).getStackTrace()[0].getClassName();
    }

