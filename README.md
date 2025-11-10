# Nuo

**Nuo** is a dynamically typed, object-oriented scripting language built in **Odin**, designed for **performance**, **simplicity**, and **productivity**.  
Created for embedding in game engines and real-time applications, Nuo is lightweight and fast, enabling expressive scripting with minimal overhead.

---

## ✨ Features

- 🔹 **Dynamic typing** – write flexible and concise code
- 🧠 **Object-oriented** – supports classes, inheritance, and `super()`
- ♻️ **Reference counting garbage collection** – fast and deterministic memory management
- 🚀 **High performance** – interpreter written in Odin
- 📦 **Modules and imports** – organize and reuse code easily
- 🔧 **Native binding support** – integrate seamlessly with C/Odin
- 📡 **Signals (event system)** – connect multiple callbacks with no signature checking

---

Nuo Language Documentation (User Guide)

Introduction

Nuo is a fast, dynamic, object-oriented scripting language designed for simplicity, productivity, and performance. It allows concise scripting for games, applications, and general tasks, while being easy to learn and understand.


---

Table of Contents

1. Getting Started


2. Basic Syntax


3. Variables


4. Functions


5. Classes and Objects


6. Inheritance


7. Operators and Expressions


8. Control Flow


9. Collections


10. Signals


11. Ranges


12. Special Types


13. With Statement


14. Anonymous Scopes


15. Methods and Static Utilities


16. Standard Libraries


17. Advanced Examples


18. Tips and Best Practices




---

Getting Started

Nuo.print("Hello, Nuo!")


---

Basic Syntax

Statements are separated by newlines.

Comments start with #:


# This is a comment
set x = 10


---

Variables

Declared with set:


set name = "Alice"
set score = 42

All types have methods available for manipulation.



---

Functions

Define global functions with fn:

fn greet(name) {
    Nuo.print("Hello, " + name)
}

greet("Bob")

Callables must be named functions. Inline anonymous functions are not allowed.



---

Classes and Objects

Fields can be declared in the class definition:

class Circle {
    set radius = 100
    set center = Vec2.ONE * radius

    _init(other_radius) {
        this.radius = other_radius
    }

    area() {
        return Math.PI * this.radius * this.radius
    }
}

set c = Circle.new(50)
Nuo.print(c.area())

this refers to the current instance.

_init is the constructor.

Objects are created using new.



---

Inheritance

class HiperCircle extends Circle {
    set hiper_radius  # starts as null

    _init() {
        this.hiper_radius *= this.radius
    }
}

set h = HiperCircle.new()

extends defines inheritance.

super() can only be used immediately before a method call.



---

Operators and Expressions

Arithmetic

+, -, *, /, **, %

Strings can be concatenated with +


Bitwise (integers only)

&, |, ^, <<, >>, ~


Comparison

==, !=, >, <, >=, <=


Logical

not, and, or


Ternary

set result = true ? 1 : 0
set result2 = 1 if true else 0


---

Control Flow

if score > 50 {
    Nuo.print("Great!")
} elif score > 30 {
    Nuo.print("Good")
} else {
    Nuo.print("Try again")
}

for i in 1..5 {
    Nuo.print(i)
}

while condition {
    # do something
}

for loops are inclusive (1..5 includes 5).

Use break and continue inside loops.



---

Collections

Arrays and dictionaries are indexable and iterable:


set fruits = ["apple", "banana", "cherry"]
Nuo.print(fruits[0])  # apple

for fruit in fruits {
    Nuo.print(fruit)
}

set person = {"name": "Alice", "age": 30}
Nuo.print(person["name"])

for key, value in person {
    Nuo.print(key + ": " + value)
}


---

Signals

button.clicked.connect(callback_function)

Callbacks must be named.

Signals do not check arguments.



---

Ranges

Primitive type, inclusive and iterable:


set myrange = 1..10

for i in myrange {
    Nuo.print(i)
}


---

Special Types

Vector2: created via Vec2(x, y):


set pos = Vec2(-100, 100)
pos.dot(Vec2.UP)

Color: RGBA or named constants

Complex: complex numbers

Signals: events



---

With Statement

with circle_instance {
    .radius = 100    # set property
    .radius          # get property
    .area()          # call method
}


---

Anonymous Scopes

{
    set temp = 100
    Nuo.print(temp)
}  # temp no longer exists here


---

Methods and Static Utilities

String

set s = "Hello"
Nuo.print(s.repeat(2))          # "HelloHello"
Nuo.print(String.stringfy(123)) # "123"

Vector2

set v = Vec2(10, 20)
Nuo.print(v.dot(Vec2.UP))           # dot product
set u = Vec2.from_circle(10, 30)   # static factory

Color

Nuo.print(Color.WHITE)              # predefined constant

Array

set arr = [1,2,3]
arr.push(4)
arr.pop()

Complex

set z = complex(3,4)
Nuo.print(z.abs())    # magnitude

Notes:

Methods may belong to an instance or be static on the class.

Primitive classes with static methods/constants: String, Array, Vec2, Complex, Color.



---

Standard Libraries

Nuo: core functions

Time: timing, delays, timestamps

Math: arithmetic, trigonometry

DirAccess: directory operations

FileAccess: file read/write



---

Advanced Examples

import Time
import Math

set name = "Nuo"

fn main() {
    Nuo.print(name.repeat(2))  # "NuoNuo"
    set start = Time.get_tick_ms()

    for i in 0..1_000_000 {
        set sin = Math.sin(i) + Math.cos(2*i)
        if i % 500_000 == 0 { break }
        else { continue }
    }

    Nuo.print("I took: ", (Time.get_tick_ms() - start), "ms")

    match Nuo.typeof(2) {
        case Nuo.TYPE_INT: Nuo.print("I'm Integer")
        _: Nuo.print("Who am I?")
    }

    # Static methods and constants
    Nuo.print(String.stringfy(2))
    Nuo.print(Color.WHITE)
    set v = Vec2.from_circle(10,30)
    Nuo.print(v)
}

