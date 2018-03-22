## RSpec 練習（1）：Reverse Integer
> 能夠使用基本的 RSpec 語法撰寫測試案例

你已經在上個單元快速體驗了自動化測試，現在我們要用一個常見的題目 Prime Number 來進行自動化測試的練習，從實務中學習 RSpec 的基本語法。

### Reverse Integer  題目說明


Reverse Integer 是 LeetCode 上的一個題目，給一個整數，程式會將這個整數反轉過來，但若數字大於 Ruby 整數的最大值，則回傳 0：
- 如果整數為 1，結果為 1
- 如果整數為 123，結果為 321
- 如果整數為 -104，結果為 -401
- 如果整數為 4611686018427387906，回傳 0

請大家先自行嘗試撰寫 Reverse Integer 程式和測試程式，再接著往下閱讀教案提供的操作步驟與說明，這樣才能達到最好的學習效果。

### 撰寫 Reverse Integer 程式（第一版）

本題目有相當多不同的解法，因此若大家寫的 Reverse Integer 程式碼與教案不同，請不用擔心。

請先創建一個資料夾 `rspec_tutorial_1`，進入資料夾創建一個檔案 **reverse_integer.rb**，內容如下：
```ruby
def reverse_integer(int)
  result = 0
  while int != 0
    result *= 10
    result += (int % 10)
    int = int/10;
  end
  return result
end
```

### 設定測試結果的產出格式：.rspec

使用 RSpec 語法撰寫測試程式的第一步，要先新增一個 RSpec 設定檔，也就是 **.rspec** 檔，其內容如下：

請在 **rspec_tutorial_1** 資料夾內，新增一個 `.rspec` 檔，內容如下：
```diff .rspec
--format documentation
--color
```

以上設定分別是：
- `--format documentation`：讓我們在終端上能看到格式化的測試結果
- `--color`：讓我們在終端上看到有顏色的測試結果

### 撰寫測試程式

請創建自動化測試用的檔案：**reverse_integer_spec.rb**，慣例上在創建測試程式時，會在要測試的程式名稱後面加上 `_spec` 的字眼作命名。

接著，請在檔案最上方加上以下程式碼，將 **reverse_integer.rb** 加入測試程式：
```Ruby
require_relative './reverse_integer.rb'
```

#### 描述你要測試的程式：describe

我們會用 `describe` 語法描述要測試的程式，並在其範圍內撰寫測試案例，請在 **reverse_integer_spec.rb** 加入 `describe` 語法和描述要測試程式的文字：
```Ruby
require_relative './reverse_integer.rb'

describe "將整數反轉過來" do
  # 在這裡寫測試案例
end
```

#### 撰寫測試案例：it、expect、to eq

每一個 `it` 語法代表著一個測試案例，讓我們來為 reverse integer 新增以下四個測試案例：
```Ruby
require_relative './reverse_integer.rb'

describe "將整數反轉過來" do

  it "1 結果應為 1" do
    # 在這裡寫上輸入資料與預期結果
  end

  it "123 結果應為 321" do
    # 在這裡寫上輸入資料與預期結果
  end

  it "-104 結果應為 -401" do
    # 在這裡寫上輸入資料與預期結果
  end

  it "4611686018427387906 結果應為 0" do
    # 在這裡寫上輸入資料與預期結果
  end

end
```

接著，我們要使用 `expect` 、 `to eq` 語法來撰寫測試案例的內容：
- `expect`：帶入執行完程式的結果
- `to eq`：判斷是否等於預期的結果

請大家先自行嘗試完成測試案例的，或至少完成部分的測試案例，才往下查看程式碼是否相似，這樣學習效果會更好。

完成後的測試案例應如下所示：
```Ruby
require_relative './reverse_integer.rb'

describe "將整數反轉過來" do

  it "1 結果應為 1" do
    result = reverse_integer(1)
    expect(result).to eq(1)
  end

  it "123 結果應為 321" do
    result = reverse_integer(123)
    expect(result).to eq(321)
  end

  it "-104 結果應為 -401" do
    result = reverse_integer(-104)
    expect(result).to eq(-401)
  end

  it "4611686018427387906 結果應為 0" do
    result = reverse_integer(4611686018427387906)
    expect(result).to eq(0)
  end

end
```

### 進行測試

接著，請使用 `rspec` 指令進行測試，指令後要帶入測試程式的檔名：
```
rspec reverse_integer_spec.rb
```

你會發現到，前面兩個測試案例回傳綠色文字，表示測試通過，但卡在第三個測試案例久久沒有恢復，請用 control + c 中斷測試，接著會顯示說測試已中斷，正在產出測試報告，請再進行一次中斷。

![image](images/0103-1.png)
