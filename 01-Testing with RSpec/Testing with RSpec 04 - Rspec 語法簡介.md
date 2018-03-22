## RSpec

RSpec 是一套 Ruby 的測試 DSL（Domain-specific language）框架，他是一種可執行的規格文件，使用 RSpec 所寫的測試更容易描述測試的目的；還因此有非常多的 Ruby on Rails 專案採用 RSpec 作為測試框架。

### RSpec 的由來

RSpec 演化自 TDD，而後改稱為 BDD（Behavior-driven development），BDD 是一種測試框架，相較於 TDD 使用測試思維測試程式的結果，BDD 強調的是用 Spec（Specification、規格）思維，描述程式應該有什麼行為。

### 安裝 RSpec

請輸入以下指令安裝 RSpec

`gem install rspec`

#### 設定 RSpec 專案設定檔

請創建一個 **.rspec** 檔，或使用指令：
`rspec --init`

請使用指令下載 GitHub 專案：

```bash
[~] $ git clone
```
### 資料夾結構要自行建構？自行設定？下載？[需要討論]
在使用 RSpec 測試 Ruby 程式時，通常會開一個專案資料夾，在裡面建立不同的資料夾管理不同目的的檔案：
- **lib**
- **spec**
- **tmp**
- **.rspec**

### RSpec 物件導向[需要討論]

### RSpec 基本語法[需要討論]
- describe, context
- it, expect
- to eq ( others? )
- before, after
- let, let!
- pending

`describe` 和 `context` 是幫助組織分類，都是可以任意套疊的。它的參數可以是一個類別，或是一個字串描述：

```Ruby
describe Order do
  describe "#amount" do
    context "when user is vip" do
     # ...
    end

   context "when user is not vip" do
      # ...
    end
  end
end
```

通常最外層是我們想要測試的類別，然後下一層是哪一個方法，然後是不同的情境。

每个 `it` 包起来的程式碼就是一个要测试的案例，我们会在里面用 `expect` 方法去检查结果是否如我们所预期，最後使用 `to eq` 來判斷結果是否符合我們預期。

执行 `rspec leap_year_spec.rb` 就会自动测试这四个测试案例(test example)。


### 參考資料
- 如何寫出好的測試案例：http://www.betterspecs.org/
- 更多 matcher：https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
