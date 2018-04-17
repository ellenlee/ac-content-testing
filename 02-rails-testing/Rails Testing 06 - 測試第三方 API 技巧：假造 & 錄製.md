## 測試第三方 API 技巧：假造 & 錄製
> 認識測試第三方 API 時會遇到的問題
> 理解如何使用「假造」和「錄製」技巧來測試第三方 API 

到目前為止，我們透過了基礎的功能練習了許多 RSpec 的寫法。這個單元，我們將針對第三方 API 的測試，討論在處理第三方 API 時，會遇到什麼特殊的問題，又有什麼對應的解法。

### 為什麼第三方 API 需要處理

仔細觀察近年來建立的網站，你會發現大量使用第三方 API 的現象，從社群登入（Google、Facebook 登入），到金流串接都屬於第三方 API 的範疇。

然而，在跑測試的時候，實務上會避免在測試中真正去呼叫第三方 API，理由是：

- 呼叫外部 API 時，可能會因為網路問題導致測試結果失敗
- 呼叫外部 API 會讓測試完成的速度大幅下降
- 因為執行測試，無意間超過第三方 API 提供者的使用頻率限制

根據上述這些可能的原因，我們應該確保我們在執行測試的過程中，並不會真的發送請求至第三方 API 的伺服器，但又可以模擬測試。因此就有了以下兩種常見的技法：
- **假造**
- **錄製**

接下來我們會示範這兩個觀念的實作，我們會使用「Facebook 登入」做為第三方 API 的例子。

### 第三方 API 假造

第一個技巧是 **第三方 API 假造**。假造會有三個步驟：
1. 創造一組假回應（fake response），規格應該要跟真的第三方 API 回應類似。
2. 阻擋相關的 API 發送。
3. 回傳我們在第一步創造的假回應。

我們需要安裝 [Webmock](https://github.com/bblimke/webmock) 這個 gem 來幫助我們完成接下來的任務：

```ruby
# Gemfile
gem 'webmock'
```

並且在 `spec_helper.rb` 裡面阻擋 API 發送：

```ruby
# spec/spec_helper.rb

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
```

撰寫 `models/user.rb`，在安裝 FB 裡面其中關於 `self.get_facebook_user_data` 的測試：

```ruby
# spec/models/user_spec.rb

RSpec.describe User, type: :model do
  it "should get_facebook_user_data work(webmock version)" do
    expect(User.get_facebook_user_data(ACCESS_TOKEN)).to eq({
      "id" => "FB_UID",
      "name" => "FB_NAME"
    })
  end
end
```

在跑這個測試之前，我們必須先前往 Facebook 的圖形 API 測試工具，產生授權的權杖，請你前往 facebook for developers 的[圖形 API 測試工具](https://developers.facebook.com/tools/explorer/?method=GET&path=me%3Ffields%3Did%2Cname&version=v2.12) ，登入 Facebook 就可以看到自己的權杖：

![img](images/fb-token.png)

權杖是一組由大小寫英文以及數字組成、長達 200 個字左右的字串。請你把上文程式碼裡的 `ACCESS_TOKEN` 用剛剛拿到的權杖替換，接者我們執行 `bundle exec rspec` 跑測試，會看到類似以下的錯誤訊息:

```
 Failure/Error: response = conn.get "/me", { access_token: access_token }

 WebMock::NetConnectNotAllowedError:
   Real HTTP connections are disabled. Unregistered request: GET https://graph.facebook.com/me?access_token=access_token with headers {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.12.2'}

   You can stub this request with the following snippet:

   stub_request(:get, "https://graph.facebook.com/me?access_token=access_token").
     with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.12.2'}).
     to_return(:status => 200, :body => "", :headers => {})
```

這段錯誤訊息嘗試告訴我們，我們想要發送的請求已經被 webmock 擋下來沒有真的發送。接著我們要偽造假回應，你會發現 webmock 已經把假造的格式幫我們準備好了。看到上面錯誤訊息的下半部，從 `You can stub this request with the following snippet:` 這行開始，接著我們需要調整 response body ，換成我們自己的 `FB_UID` 和 `FB_NAME`。

原本的格式應該是
`to_return(:status => 200, :body => "", :headers => {})`

把 body 換成實際回傳的內容
`to_return(status: 200, body: '{"id":"FB_UID", "name": "FB_NAME"}', headers: {})`

假回應就完成了，接著我們把假回應放在測試的設定檔案中:

```
# spec/spec_helper.rb

  config.before(:each) do
    stub_request(:get, "https://graph.facebook.com/me?access_token=access_token").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.12.2'}).
      to_return(status: 200, body: '{"id":"FB_UID", "name": "FB_NAME"}', headers: {})
  end
```

再執行一次測試，通過！


### 第三方 API 錄製

第二個技巧是 **第三方 API 錄製**，我們將透過 [vcr](https://github.com/vcr/vcr) 這個 gem 幫我們完成錄製的任務。第一次我們會真的發送請求到實際的伺服器，而這時 VCR 會幫我們把回傳的結果紀錄在一隻 yml 檔案裡面，之後針對同樣的網址和參數的請求就不會真的發送請求，而是用之前紀錄的 yml 檔案。

你需要先安裝 vcr gem：

```ruby
# Gemfile
gem 'vcr'
```

在 `spec/support/vcr_setup.rb` 撰寫設定檔：

```ruby
VCR.configure do |config|
  # 設定儲存 API 檔案的目錄位置
  config.cassette_library_dir = "spec/fixtures/vcr"
  # 設定假造 API 的函式庫
  config.hook_into :webmock
end
```

在 `spec/rails_helper.rb` 導入 `vcr` 設定檔：

```ruby
require 'support/vcr_setup'
```

然後撰寫錄製的測試檔：

```ruby
RSpec.describe User, type: :model do
  it "should get_facebook_user_data work(vcr version)" do
    VCR.use_cassette 'get facebook user data' do
      expect(User.get_facebook_user_data('ACCESS_TOKEN')).to eq({
        "name" => "FB_NAME",
        "id" => "FB_ID"
      })
    end
  end
end
```

跑完測試後，可以發現在 `spec/vcr` 這個資料夾下面多了一隻名為 `get_facebook_user_data.yml` 的檔案，裡面的內容大概會是這樣，記錄了一切重製這個請求所需要的資訊：

```
---
http_interactions:
- request:
    method: get
    uri: https://graph.facebook.com/me?access_token=EAACEdEose0cBAOnZBPUb0EuX8xgnHpoa9JKpeCLAWqdLQGrMjn1X2eaiZCFVOnveXrd4LY8F3JBK5zIsFu3inllfTs54MCiz5NRAIxlZCOLJU9SEQxBSh6gtSbKT5hG15A1WtsgZBiqOhvnFDVwUKxDz6Qf7mc17OPuh437qPXyZBf7fEX4cihDm5EJtD6mQZD&fields=email
    body:
      encoding: US-ASCII
      string: ''
    headers:
      User-Agent:
      - Faraday v0.12.2
      Accept-Encoding:
      - gzip;q=1.0,deflate;q=0.6,identity;q=0.3
      Accept:
      - "*/*"
  response:
    status:
      code: 200
      message: OK
    headers:
      X-App-Usage:
      - '{"call_count":3,"total_cputime":4,"total_time":3}'
      Etag:
      - '"1951a445ed3d35b8ed9189ed52fb3b3a6f579c80"'
      Strict-Transport-Security:
      - max-age=15552000; preload
      X-Fb-Trace-Id:
      - AEDfjs2s2g1
      X-Fb-Rev:
      - '3775614'
      Expires:
      - Sat, 01 Jan 2000 00:00:00 GMT
      Content-Type:
      - application/json; charset=UTF-8
      Facebook-Api-Version:
      - v2.5
      Cache-Control:
      - private, no-cache, no-store, must-revalidate
      Pragma:
      - no-cache
      Access-Control-Allow-Origin:
      - "*"
      X-Fb-Debug:
      - zkDHFUAjqH9lJ8gAJdeAVbf6EnXro0ApeWYV8YyG0BAJwuyILYuHONEoy01oUvLO6EyAdTFGt+pvvY8dDA/tWQ==
      Date:
      - Tue, 03 Apr 2018 05:41:45 GMT
      Connection:
      - keep-alive
      Content-Length:
      - '60'
    body:
      encoding: UTF-8
      string: '{"email":"frozenfung\u0040gmail.com","id":"962045113809238"}'
    http_version:
  recorded_at: Tue, 03 Apr 2018 05:41:45 GMT
recorded_with: VCR 3.0.3
```
如果成功看見這個檔案，就表示你成功完成了錄製的任務。

### 小結

在這個單元裡，我們介紹了兩種在測試中處理 API 的方法，彼此分別適合不同的情境，各有彼此的優缺點：
- 假造：需要手動撰寫請求以及回傳的 header 以及 body，雖然說較為麻煩，但是對於假造內容的掌握度較高。
- 錄製：直接幫我們記錄下來整個請求以及回傳構通的過程，開發起來很快，但很多時候我們其實只是需要比對 body 而已，大多數的資訊其實不需要用到。

### 參考程式碼

| 主題 | 說明 |
| ----- | ----- |
| 假造|[LINK](https://github.com/ALPHACamp/photo-album-testing/commit/10b260e702842f1228cf2890c123740eb29f6ff5)|
|錄製|[LINK](https://github.com/ALPHACamp/photo-album-testing/commit/61de9112d8b43634579c4137f3082e60b8b4d825)|
