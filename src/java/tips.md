---
layout: page

title: Tips 
---

## Raising a number to a power

Use `Math.pow`. The operator `^` means XOR in Java.

    System.out.println(Math.pow(10, 3)); // 1000.0 
    System.out.println(10 ^ 3); // 9 -> 1010 XOR 0011 = 1001 

Consider to use `x * x` instead of `Math.pow(x, 2)`.

## Getting the current class name statically 

    public class MyClass {
        private static final String TAG = (new Throwable()).getStackTrace()[0].getClassName();
    }

