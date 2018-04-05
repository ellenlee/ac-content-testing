## 快速體驗自動化測試
> 理解自動化測試的運作方式

在這個單元裡，我們將用一個簡單的題目來快速體驗何謂「自動化測試」。

在使用本單元時，請依照教案將程式碼依序貼上並執行對應指令，仔細觀察結果；我們會在之後的章節裡詳細說明自動化測試的語法和使用方式。

### 題目說明：FizzBuzz

FizzBuzz 程式是經典的面試考題之一。你會撰寫一支程式，並將一個整數傳入該程式，程式會檢查該整數：
- 若該整數能被三整除，回傳 Fizz；
- 若該整數能被五整除，回傳 Buzz；
- 若該整數能被三和五同時整除，回傳 FizzBuzz；
- 若都不能整除，回傳該整數。

根據上述規則，我們將用以下資料來檢查程式的有效性：

| 傳入資料 | 預期結果   |
|----------|------------|
| 3        | "Fizz"     |
| 5        | "Buzz"     |
| 15       | "FizzBuzz" |
| 1        | 1          |

### irb 手動測試

在說明自動化測試之前，我們先使用傳統的手動測試方法，也就是寫好程式之後，進入 irb 來帶入對應的測試資料。

#### 撰寫 FizzBuzz 程式（第一版）

讓我們先簡單寫一個 FizzBuzz 的程式。

請創建一個檔案 **fizzbuzz.rb**，內容如下，以下內容有一些故意遺漏的細節：

```ruby
def fizzbuzz(int)
  if int % 3 == 0
   return "Fizz"
  end

  if int % 5 == 0
   return "Buzz"
  end

  if int % 3 == 0 && int % 5 == 0
   return "FizzBuzz"
  end
end
```

在終端執行 `irb` 输入指令，載入檔案之後，用我們設定的資料來進行測試：

```ruby
require_relative 'fizzbuzz.rb'
fizzbuzz(3)   # => 回傳 Fizz
fizzbuzz(5)   # => 回傳 Buzz
fizzbuzz(15)  # => 預期回傳 FizzBuzz，實際回傳 Fizz
fizzbuzz(1)   # => 預期回傳 1，實際沒有任何回傳結果
```

你的 irb 上結果是如何呢？讓我們繼續修改程式⋯⋯

#### 修改 FizzBuzz 程式（第二版）

修改 **fizzbuzz.rb**，改寫成：

```ruby
def fizzbuzz(int)
  if int % 3 == 0 && int % 5 == 0
   return "FizzBuzz"
  end

  if int % 5 == 0
   return "Buzz"
  end

  if int % 3 == 0
   return "Fizz"
  end
end
```

再次進入 `irb` 測試程式：

```ruby
require_relative 'fizzbuzz.rb'
fizzbuzz(3)   # => 回傳 Fizz
fizzbuzz(5)   # => 回傳 Buzz
fizzbuzz(15)  # => 回傳 FizzBuzz
fizzbuzz(1)   # => 預期回傳 1，實際沒有任何回傳結果
```

還是漏掉了 `1` 的特例，或者，你可能還會想再輸入幾個數字試試看。

這個往返檢查和修改程式的過程，相信大家一定都不陌生，自動化測試要達成的目的，就是把這個檢查過程給<span style="color:red">自動化</span>。


### 自動化測試

接下來，我們會使用一個叫 RSpec 的 Ruby 套件來進行測試，請你在本單元內先跟著執行，有了一次實作體驗後，在下個單元起，我們會詳細解釋 RSpec 的功能。

#### 安裝並設定 RSpec

請回到終端機，使用指令安裝 RSpec：
```bash
[~] $ gem install rspec
```

然後在 **fizzbuzz.rb** 同個資料夾內，新增一個 `.rspec` 檔，加入以下兩行設定：
```
--format documentation
--color
```

接着再新增一個檔案 `fizzbuzz_spec.rb`，內容如下：

```ruby
require_relative 'fizzbuzz.rb'

describe "FizzBuzz" do

  it "3 應該是 Fizz" do
    result = fizzbuzz(3)
    expect(result).to eq('Fizz')    # 傳入 3，預期結果為 Fizz
  end

  it "5 應該是 Buzz" do
    result = fizzbuzz(5)
    expect(result).to eq('Buzz')     # 傳入 5，預期結果為 Buzz
  end

  it "15 應該是 FizzBuzz" do
    result = fizzbuzz(15)
    expect(result).to eq('FizzBuzz') # 傳入 15，預期結果為 FizzBuzz
  end

  it "1 應該是 1" do
    result = fizzbuzz(1)
    expect(result).to eq(1)          # 傳入 1，預期結果為 1
  end

end
```

在這個檔案裡，每個 `it` 語法包起來的就是一個測試案例（Test Case），我們會在裡面用 `expect` 方法去檢查結果是否如我們所預期。

這裡除了測試 3、5、15 外，也多新增了 1 的測試案例，由於 1 不能被 3 或 5 整除，其結果應為 `1`。

#### 執行自動化測試

至此我們共有三個檔案：**.rspec**、**fizzbuzz.rb**、**fizzbuzz_rspec.rb**，請確認這三個檔案都在同一個資料夾裡，若不確定，可以參考[這裡](https://github.com/ALPHACamp/testing-demo/tree/master/fizzbuzz)。

接著在該資料夾下，使用 RSpec 指令進行自動化測試：
```bash
[~/fizzbuzz] $ rspec fizzbuzz_spec.rb
```

你會看見以下的測試結果：

![image](images/0102-1.png)

開頭的清單逐項列出了我們寫在 `it` 裡的測試案例：
- 3 應該是 Fizz (測試通過，亮綠燈)
- 5 應該是 Buzz (測試通過，亮綠燈)
- 15 應該是 FizzBuzz (測試通過，亮綠燈)
- 1 應該是 1 (測試失敗，紅燈)

綠色代表測試通過，而紅色訊息表示該測試案例沒有通過。然後針對失敗的案例，RSpec 進一步提供解說，它指出我們的數字為 1 的結果不正確，預期是 1 但卻得到 nil。

由於你就是程式的撰寫者，你應該知道，我們剛才撰寫的程式並沒有考量到整數不能被 3 或 5 整除的情況。

#### 修改 FizzBuzz 程式（完成版）

讓我們再次回去更動我們的程式，改寫成以下版本：
```ruby
def fizzbuzz(int)
  if int % 3 == 0 && int % 5 == 0
   return "FizzBuzz"
  end

  if int % 5 == 0
   return "Buzz"
  end

  if int % 3 == 0
   return "Fizz"
  end

  return int
end
```

再執行一次 `rspec fizzbuzz_spec.rb`，結果應如下所示：

![image](images/0102-2.png)

當你看到終端上都是綠色時，表示四個測試案例都通過了，如果你對程式還有疑慮，是否考慮得不夠完善，你也可以增加更多的測試資料來檢查。

### 重構 FizzBuzz 程式（最終版）

最後，雖然程式完成了，但程式碼本身不夠精簡，我們需要替 FizzBuzz 重構一下。

重構，即是在不影響程式功能的情況下讓程式碼變得「漂亮」，例如 FizzBuzz 程式可以修改成以下內容：


```ruby
def fizzbuzz(int)
  string = ""
  string += "Fizz" if int % 3 == 0
  string += "Buzz" if int % 5 == 0
  return string if string != ""
  return int
end
```

那要怎麼確認在重構程式碼時，沒有破壞到原有的邏輯呢？只要再執行一次 `rspec fizzbuzz_spec.rb` 指令檢查測試結果就行了！

![image](images/0102-2.png)

是不是很方便？！這就是自動化測試！一旦寫好測試程式，很容易就可以檢查程式有沒有寫對，大大減少除錯的時間，在熟悉測試程式的撰寫方法以後，整體而言，寫測試的時間，會小於手動除錯的時間。

下個單元，我們會一邊練習邊寫測試，邊解開一個 LeetCode 題目。


#### Quiz

#### Q1

```ruby
require_relative 'leetcode.rb'

describe "leetcode" do

  it "leet 結果為 code" do
    result = leetcode("leet")
    expect(result).to eq("code")
  end

  it "code 結果為 leet" do
    result = leetcode("code")
    expect(result).to eq("leet")
  end

  it "other 結果為 bug" do
    result = leetcode("other")
    expect(result).to eq("bug")
  end

end
```

以上是一個測試程式，請根據該測試程式從下面選出正確的選項（多選題）

- 要測試的程式檔名為 leetcode.rb
- 專案資料夾內至少有三個測試案例
- 如果輸入的不是 leet 或 code，預期結果為 bug
-  leetcode.rb 這支程式的目的，是要把字串 leet 和 code 進行切換

答：1、2、3、4
註記：我們會用 require_relative 把程式檔加入，因此 require_relative 旁的就是程式檔名。測試程式有三個 it，因此共有三個測試案例。第一和第二個測試案例會把 leet 和 code 切換，而第三個測試案例會把其他的字串轉換成 bug。

##### Q2

以下哪個是執行 fizzbuzz 的自動化測試的 RSpec 指令？（單選題）

- rspec fizzbuzz.rb
- rspec fizzbuzz_spec.rb
- fizzbuzz(4)
- gem install rspec

答：2
註記：內文有明確標記出 fizzbuzz 自動化測試的 RSpec 指令，指令要帶入測試程式，而不是要測試的程式。
