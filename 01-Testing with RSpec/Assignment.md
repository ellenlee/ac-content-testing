Q1:

請延續波特買書（Potter Kata）的題目，完成「三本不同集的書打 10% 折扣」的測試案例與測試程式。在進行本練習前，你應該已完成了教案裡「買兩本書打 5% 折扣」的程式碼。

- Cover 請放上執行完 rspec 指令後，全部測試案例通過的截圖。
- 請分享 GitHub 的 commit，該 commit 內容恰恰好是本題目的內容。
- 請在 Description 裡描述你如何設計你的測試案例。

Q2:

承上題，請延續波特買書（Potter Kata）的題目，完成「四本不同集的書打 15% 折扣」的測試案例與測試程式。

- Cover 請放上執行完 rspec 指令後，全部測試案例通過的截圖。
- 請分享 GitHub 的 commit，該 commit 內容恰恰好是本題目的內容。
- 請在 Description 裡描述你如何設計你的測試案例。

Q3:

承上題，請延續波特買書（Potter Kata）的題目，完成「五本不同集的書打 20% 折扣」的測試案例與測試程式：

- Cover 請放上執行完 rspec 指令後，全部測試案例通過的截圖。
- 請分享 GitHub 的 commit，該 commit 內容恰恰好是本題目的內容。
- 請在 Description 裡描述你如何設計你的測試案例。

Q4:
有一支程式名 random_range，給 1 個數字，這個程式會從 0 到該數字（不包含）隨機挑選一個數字。

以下是這支程式的測試案例，請問 expect 和 cover 裡應填上什麼？

```Ruby
require_relative "random_range.rb"

describe "random range" do
  it "100 應回傳介於 0 和 100 的數字" do
    expect( ____ ).to cover( ____ )
  end
end
```


提示：你可以透過 Relish 查詢以上 RSpec 語法的格式與範例

- 請在欄位裡貼上完整的測試案例的完整程式碼。

Q5：

以下是 Person 類別的程式碼：

```Ruby
class Person
  def init(name, age, role)
    @name = name
    @age = age
    @role = role
  end
end
```

以下是 Person 類別的測試案例：

```Ruby
require_relative "Person.rb"

describe "確認 Person 宣告成功" do
  it "Person " do
    person = Person.new("Bernard",45,"admin")
    expect(person). ______________
  end
end
```

請問底線的位置該填上什麼？

提示：你可以透過 Relish 查詢以上 RSpec 語法的格式與範例。

- 請在欄位裡貼上完整的測試案例的完整程式碼。
