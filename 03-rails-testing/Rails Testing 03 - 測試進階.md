## Rails 測試進階

上一章我們一起練習了許多基礎的 RSpec 的方法，結合 TDD 一步步開發餐廳 app 的場景。這一章會把重點放在第三方 API 的測試方法，一開始我們會分析為什麼第三方 API 會需要獨立出來，接著我們會依序介紹常使用的兩種技法，最後讓讀者們依照自己的程式風格去搭配不同的情境使用。

### 為什麼第三方 API 需要特別處理

仔細觀察近年來建立的網站，很容易就發現大量使用第三方 API 的現象。從社群登入（Google、Facebook 登入），到金流串接或是網路購物店到店時選取小七全台門市的頁面，都屬於第三方 API 的範疇。然而，在跑測試的時候，每次遇到第三方 API 都去呼叫是一件沒有效率，甚至是相當麻煩的事:

- 測試可能會因為各種網路問題不穩導致結果失敗
- 測試完成的速度大幅下降
- 測試的過程無意間超過第三方 API 提供者所訂製的使用頻率限制

...

根據上述這些可能的原因，我們應該確保我們的測試在執行的過程中並不會真的發送請求至第三方 API 的伺服器。兩種常見的技法分別是 **假造** 和 **錄製**，接下來我們會依序介紹這兩個觀念如何跟 TDD 在實務上結合。

### 第三方 API 假造

第一個技巧是 **第三方 API 假造**。這個部分一共有三個步驟，首先，我們創造一組假的回應（response），規格應該要跟真的第三方 API 回應類似。接著，我們阻擋所有的 API 真的發送。最後，回傳我們第一步驟創造的假的回應。

我們安裝 [Webmock](https://github.com/bblimke/webmock) 這個 gem 來幫助我們完成接下來的任務，

```
# Gemfile
gem 'webmock'
```

在 `spec_helper.rb` 裡面阻擋所有的 API 發送:

```
# spec/spec_helper.rb
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
```


### 第三方 API 錄製

第二個技巧是 **第三方 API 錄製**，我們將透過 `vcr` 這個 gem 幫我們達成任務。

```
# Gemfile
gem 'vcr'
```

在 `spec_helper.rb` 設定:

```
require 'vcr'

VCR.configure do |config|
  # 設定儲存 API 檔案的目錄位置
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end
```

### 小結

這個章節我們介紹兩種在測試中處理 API 的方法，彼此分別適合不同的情境，相信聰明的讀者已經發現什麼時候該用哪一種方式解決了。
