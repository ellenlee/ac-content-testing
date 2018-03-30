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
這個題目會請你使用 Google 搜尋相關的 RSpec 語法，清楚閱讀了該語法的使用方式後，請根據以下題目與測試案例選出最適合的答案。

題目說明：
有一支程式名 random_range，給 1 個數字，這個程式會從 0 到該數字（不包含）隨機挑選一個數字。

以下是該程式的測試案例：

```Ruby
require_relative "random_range.rb"

describe "random range" do
  it "100 應回傳介於 0 和 100 之間的數字" do
    # answer
  end
end
```

根據 `it` 內的測試案例說明，請問「# answer」應填上什麼？（單選題）

- expect(0..100).to cover(random_range(100))
- expect(random_range(100)).to cover(100)
- expect(random_range(100).to cover(89)
- expect(0).to cover(random_range(100))

答：1
註記：程式碼回傳的結果必須包含在 0 到 100 的範圍內，因此 random_range(100) 必須寫在 cover 裡，表示被包含，而 expect 則是帶入預期的範圍，因此答案是選項一。


Q5：

這個題目會請你使用 Google 搜尋相關的 RSpec 語法，清楚閱讀了該語法的使用方式後，請根據以下題目與測試案例選出最適合的答案。

題目說明：
`Person` 是一個類別，而 `Person` 的測試程式要確認 Person 的 new／init 方法可以正確執行，正常的宣告出物件和設置好其屬性。

以下是 Person 的程式碼：

```Ruby
class Person
  attr_accessor :name, :age, :role

  def initialize(name, age, role)
    @name = name
    @age = age
    @role = role
  end
end
```

以下是 Person 的測試案例：

```Ruby
require_relative "Person.rb"

describe "確認 Person 宣告成功" do
  it "Person init" do
    person = Person.new("Bernard",45,"admin")
    # answer
  end
end
```

如果我們要確認 `person` 的屬性都有設置好，請問「# answer」應填上什麼？（單選題）

- expect(person).to have_attributes(:name => "Big Ben", :age => 45, :role => "admin")
- expect(person).to have_attributes("Bernard",45,"admin")
- expect(person).to have_attribute(name: "Bernard", age: 45, role: "admin")
- expect(person).to have_attributes(:name => "Bernard", :age => 45, :role => "admin")

答：4
註記：要檢查物件裡是否有對應的屬性與內容，要用 have_attributes 帶入指定屬性名稱與對應的內容確認。
