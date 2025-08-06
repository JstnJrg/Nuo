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

## ⚙️ Design Principles & Language Decisions

- ✅ `super()` is **only valid as** `super().method()` – disallows returning or storing `super`
- ✅ **Signals** allow multiple connected callbacks – no signature validation at runtime
- ✅ **Inclusive ranges** – `1..3` includes `3`
- ✅ **No static methods** – simpler object model, avoids memory overhead
- ✅ **Invalid callbacks are silently skipped** – callback is responsible for correct usage

---

## ▶️ How to Run a Nuo Script

1. Create a file with the `.nuo` extension (e.g., `main.nuo`)
2. Open a terminal in the folder containing `Nuo.exe`
3. Run:

```sh
Nuo.exe path/to/your/script.nuo
