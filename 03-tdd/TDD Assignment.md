# Assignment

### 簡答題

1. 模仿本文使用的 Pseudocode 形式，在冷氣遙控器的情境之下，設計一個「調高溫度」的測試案例，以及「調高溫度」功能的 Pseudocode。

2. 在冷氣遙控器的情境之下，嘗試用 TDD 開發另一個功能，請附上測試案例，以及對應功能的 Pseudocode。（hint: 把家裡的冷氣遙控器拿來看一看，除了開關機、調高溫度之外還有什麼功能？）

### 選擇題

在重構的過程中，我們可能會將部分邏輯包成 private method，請問，你覺得應該要為 private method寫測試嗎？
- 應該要為 private method 寫測試
- 不需要為 private method 寫測試

ans: 不需要為 private method 寫測試
hint: private method 經常被各個 public method 所運用，通常我們會直接在 public method 裡面呼叫，當我們測試 public method 的時候也同時在測試 private method 了，不需要特別為 private method 寫測試。
