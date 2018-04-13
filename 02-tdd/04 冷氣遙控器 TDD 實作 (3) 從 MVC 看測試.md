## 從 MVC 角度理解
> 理解 MVC 不同的測試要點

在前兩個單元，我們為冷氣遙控器開發了「打開冷氣」功能，以此理解了 TDD 概念。在這個單元裡，我們要進一步加入 MVC 的概念來拆解程式架構。

寫測試的時候，通常會依照 MVC 的架構分別撰寫不同層級的測試，重要性依序是 model >  controller > view。原因是 model 是邏輯上最不容易改變，卻又最關鍵的地方，而 view 比較常會改變，而且改變的內容通常不會太重要。

|          |  改動頻率  |  重要度  |  難易度   |  撰寫詳細度 |
|----------|----------|----------|----------|-----------|
|view      |    高    |    低    |    低     |    低     |
|model     |    低    |    高    |    中     |    中     |
|controller|    中    |    中    |    中     |    高     |

### Model

在上個單元最後，我們將「判斷冷氣是否開啟」這個方法移到 `冷氣` model 裡。若我們要針對這個方法來寫測試，可能會有以下的思考步驟。

首先，我們要先確認這個方法的用途和格式，這是一個 model instance level 的方法，當我們呼叫 `冷氣.是否開啟` 的時候，我們預期回傳值是 boolean。

再來我們要把呼叫這個方法的預期結果也列出來：
- 如果冷氣開啟，預期呼叫這個方法會回傳 `True`
- 如果冷氣關閉，預期呼叫這個方法會回傳 `False`

組合起來，組成 model 的完整測試：

```ruby
# spec/air_conditioner_spec.rb

require 'air_conditioner'

RSpec.describe AirConditioner, "ac" do
  before do
    選出要進行測試的冷氣機
  end

  it "若冷氣開啟 -> 「判斷是否開啟」回傳值應為 True" do
    打開冷氣
    呼叫紅外線發射器
    假設發送指令給冷氣的回傳值是 True
    預期(冷氣.是否開啟(設定紅外線)) == True
  end

  it "若冷氣關閉 -> 「判斷是否開啟」回傳值應為 False" do
    關閉冷氣
    呼叫紅外線發射器
    假設發送指令給冷氣的回傳值是 False
    預期(冷氣.是否開啟(設定紅外線)) == False
  end
end
```

在上述的測試例子裡面，由我們自己定義「發送指令給冷氣」的回傳結果，以免測試的正確性受到外部因素影響。舉例來說，假設今天冷氣機的發射系統故障，而我們對於冷氣機的回傳結果不是我們自己定義，而是真的去跟冷氣機溝通，那麼我們將無法確定，跑測試的時候看見的紅燈，究竟是來自於冷氣機的第三方問題，還是我們寫的程式有錯。

### Controller

接著我們來試試看 controller 的測試。`冷氣遙控器` 對應到 controller，而 `打開冷氣` 是其中的 action。

如同上面的步驟，第一步我們要確認 `打開冷氣` 這個 action 的用途和格式，這是一個 controller action，我們預期這個 action 能把 `冷氣` 打開。

也就是說，我們預期呼叫 `冷氣遙控器.打開冷氣()` 時，`冷氣開啟狀態 == 打開`

組合起來，組成 controller 的完整測試：

```ruby
require 'air_conditioner_controller'

RSpec.describe AirConditionerController, "acc" do
  before do
    選出要進行測試的冷氣機和遙控器
  end

  # 其他測試案例

  it "should controller open work" do
    設定「冷氣開啟狀態」 -> 關機
    設定「冷氣插電狀態」 -> 有插電
    冷氣遙控器.打開冷氣()
    預期(冷氣狀態) == 運作中
  end
end
```

## View

view 在冷氣遙控器裡面對應到儀表板 (dashboard)，負責顯示目前冷氣的狀態。

第一步我們要確認這次要測試的 view 範圍，針對「顯示開關機狀態」的區域，我們希望這個區域能正確顯示開關機的狀態，也就是：

- 當冷氣打開時，儀表板上負責顯示開關區域會顯示 on
- 當冷氣關閉時，儀表板上負責顯示開關區域會顯示 off

我們會在測試裡去呼叫模板，判斷實際結果是否等於預期結果。

以下為 view 的測試案例：

```ruby
require 'air_conditioner_controller'

RSpec.describe AirConditionerController, "acc" do
  before do
    選出要進行測試的冷氣機和遙控器
  end

  # 其他測試案例

  測試 "儀表板上負責顯示開關的區塊正確顯示" do
    設定「冷氣開啟狀態」 -> 關機
    冷氣遙控器.打開冷氣()
    預期(冷氣遙控器儀表板) 有 "on" 的訊息
  end
```

以上我們對 model、controller、view 三個層級，分別舉出了一個測試案例，希望有助於讓你體會到 MVC 不同的測試重點。

### 參考程式碼

以下附上對應到 Pseudocode 的程式碼，請你確保你已經充分了解上述案例的邏輯之後，再開啟程式碼來研究：


| 項目 | GitHub |
| ----- | ----- |
| Model 測試案例 | LINK |
| Controller 測試案例 | LINK |
| View 測試案例 | LINK |
