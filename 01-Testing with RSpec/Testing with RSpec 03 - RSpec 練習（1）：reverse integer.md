## RSpec 與實作（1）：Reverse Integer
> 能夠使用基本的 RSpec 語法撰寫測試案例
> 能夠使用 Red-Green-Refractor 循環完成程式

在上個單元，透過一個 FizzBuzz 程式，你快速體驗了何謂自動化測試，在這個單元，我們將來實作一個 LeetCode 題目 —— Reverse Integer，我們將一邊實作，一邊解釋 RSpec 的基本語法。

### 定義問題

#### Reverse Integer 題目說明

給一個 32-bit 大小的整數，即從 -2147483647 到 2147483647 中挑出一個整數，程式會將這個整數反轉過來，反轉時不會改變正負數，負整數反轉後依然會是負整數，正整數亦然。

然而，如果反轉後該整數超出 -2147483647 到 2147483647 的範圍，則回傳 0。

#### 分析測試情境

請先停下思考，根據題目的說明，Reverse Integer 會有哪幾種類型的資料輸入？

我們能確定輸入的資料會是一個整數，而整數有分成正整數和負整數。

因此，我們至少會有兩種情境：
- 輸入正整數，輸出結果會是一個反轉的正整數
- 輸入負整數，輸出結果會是一個反轉的負整數，負數符號的位置不變

而最後還有一個例外狀況，也就是反轉後超出範圍 (-2147483647~2147483647) 的整數，輸出結果會是 0。

#### 依情境設計測試案例

根據以上三種情境，定義測試案例如下：

| 情境     | 傳入值     | 輸出值 |
|----------|------------|--------|
| 正整數   | 123        | 321    |
| 負整數   | -104       | -401   |
| 超出範圍 | 2147483650 | 0      |


### 準備目錄與設定檔

請你先準備一個目錄，用來放置相關檔案，在目錄下將有三支檔案：
- 主程式：**reverse_integer.rb**
- 測試程式：**reverse_integer_spec.rb**
- 設定檔：**.rspec**

讓我們先準備 **.rspec** 檔，這個檔案可以定義測試結果的輸出格式，請你設定這兩行指令：

```plain
--format documentation
--color
```
_Path: reverse_integer/.rspec_

其中 `--format documentation` 是設定在終端機看到格式化的測試結果，而 `--color` 是為測試結果上色。

### 撰寫測試

接著我們來撰寫測試程式 **reverse_integer_spec.rb**，慣例上在替測試程式命名時，會以原本的程式名稱加上 `_spec` 的後綴。

#### 描述你要測試的程式：describe

`describe` 是用來組織測試案例的語法，不會影響到測試的邏輯，但會影響輸出格式。通常我們會用 `describe` 描述被測試的程式：


，並在其範圍內撰寫測試案例，請在 **reverse_integer_spec.rb** 加入 `describe` 語法和描述要測試程式的文字：
```Ruby
describe "將整數反轉過來" do
  # 在這裡寫測試案例
end
```
_Path: reverse_integer/reverse_integer_spec.rb_

#### 撰寫測試案例：it、expect、to eq

`it` 代表一個測試案例，請將測試案例逐個寫入，慣例上一個案例只處理一個變因：
```Ruby
describe "將整數反轉過來" do

  it "123 結果應為 321" do
    # 在這裡寫上輸入資料與預期結果
  end

  it "-104 結果應為 -401" do
    # 在這裡寫上輸入資料與預期結果
  end

  it "2147483650 結果應為 0" do
    # 在這裡寫上輸入資料與預期結果
  end
end
```
_Path: reverse_integer_spec.rb_

接著，我們要撰寫測試案例的內容：
- `expect`：帶入結果
- `to eq`：帶入預期的結果，判斷結果是否等於符合預期


完成後的測試案例應如下所示：
```Ruby
describe "將整數反轉過來" do

  it "123 結果應為 321" do
    result = reverse_integer(123)
    expect(result).to eq(321)
  end

  it "-104 結果應為 -401" do
    result = reverse_integer(-104)
    expect(result).to eq(-401)
  end

  it "2147483650 結果應為 0" do
    result = reverse_integer(2147483650)
    expect(result).to eq(0)
  end

end
```
_Path: reverse_integer_spec.rb_

#### 連結測試與測試用程式

最後，請載入主程式的檔名，使用 `require_relative` 來連結檔案，在程式最上方加入：
```Ruby
require_relative './reverse_integer.rb'
```
_Path: reverse_integer_spec.rb_

到這裡我們還沒有撰寫主程式，請你先自行嘗試完成程式功能，確認能通過 4 組測試（或者，也可以加更多組）。

如果順利完成，再往下看結果...

.
.
.
.
.
.
.
.
.
.
.
.
.
.
.
.
.

### 實作程式：反轉正整數

請打開 **reverse_integer.rb** 檔，讓我們針對第一個情境，將正整數反轉，撰寫程式碼：
```ruby
def reverse_integer(int)
  string = int.to_s     # 將整數轉換成字串
  string.reverse!       # 將字串反轉
  return string.to_i    # 將字串轉換成數字，並回傳
end
```
_Path: reverse_integer.rb_

接著，請使用 `rspec` 指令進行測試，指令後要帶入測試程式的檔名：
```bash
[~] $ rspec reverse_integer_spec.rb
```
結果應如下所示：
![image](images/0103-2.png)

綠色的 `123 結果應為 321` 表示第一個測試案例通過了！

請仔細觀察第二個測試案例的產出結果，我們期望 -104 反轉後會成為 -401，但結果卻是 401，這是字串和數字在轉換之間引發的錯誤。


### 撰寫程式功能：反轉負整數

讓我們針對情境二，將負整數反轉，新增處理負整數的功能，再重構程式碼：
```ruby
def reverse_integer(int)
  string = int.to_s         # 將整數轉換成字串
  string.reverse!           # 將字串反轉
  result = string.to_i      # 將字串轉換成數字，存入 result
  result *= -1 if int < 0   # 如果原來的整數是負數，result 變成負數
  return result
end
```
_Path: reverse_integer.rb_

請使用 `rspec reverse_integer_spec.rb` 指令進行測試，結果應如下所示：

![image](images/0103-3.png)

這次我們多了一個綠色的 `-104 結果應為 -401` 表示第二個測試案例也通過了！

### 撰寫程式功能：限制整數範圍

我們只剩下最後一個程式功能要完成，即將輸入的整數限縮在範圍內（ -2147483647 到 2147483647 ），超過這個範圍就回傳 0。

新增限制整數範圍的功能後，程式碼應如下所示：
```ruby
def reverse_integer(int)
  return 0 if int > 2147483647 || int < -2147483647 # 超出範圍回傳 0
  string = int.to_s         # 將整數轉換成字串
  string.reverse!           # 將字串反轉
  result = string.to_i      # 將字串轉換成數字，存入 result
  result *= -1 if int < 0   # 如果原來的整數是負數，result 變成負數
  return result
end
```
_Path: reverse_integer.rb_

請使用 `rspec reverse_integer_spec.rb` 指令進行測試：

![image](images/0103-4.png)

全部都是綠色的文字！表示所有測試案例都通過了！

### 重構你的程式碼

最後讓我們在保持測試案例都通過的情況下，進行程式碼的重構，讓程式碼更精簡，重構方式有很多種，這裡提供一種讓大家參考：

```ruby
def reverse_integer(int)
  return 0 if int > 2147483647 || int < -2147483647
  result = int.to_s.reverse!.to_i     # 整數轉換成字串，反轉後再變回整數
  result *= -1 if int < 0
  return result
end
```
_Path: reverse_integer.rb_

### 小結

恭喜！你使用自動化測試完成了一個 leetcode 練習！請你利用剛才的練習，體會一些撰寫自動化測試的練習要訣：

- 一個 `it` 裡面盡可能只有一個測試案例，也最好只有一個預期結果
- 先從測試失敗的案例開始修改
- 確保每個測試都有效益，不會發生砍掉實作卻沒有造成任何測試失敗
- 一開始的實作不一定要先直攻一般解，可以一步一步在循環中進行思考和重構
- 測試程式碼的可讀性比 DRY 更重要
- 無論是改實作或是改測試碼，已經通過的案例應該要維持綠燈通過的狀態


#### Quiz

關於 RSpec 語法，以下何者是正確的？（多選題）

- 紅色代表失敗
- expect 要帶入執行程式的結果
- to eq 要帶入預期的結果
- describe 用於描述要進行測試的程式

答：1、2、3、4
註記：所有選項都是正確的，都可以在內文找到。
