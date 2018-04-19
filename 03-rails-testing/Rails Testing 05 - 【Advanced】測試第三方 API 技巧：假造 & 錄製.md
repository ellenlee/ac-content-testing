>**學習成果與目標**
>・認識測試第三方 API 時會遇到的問題
>・理解如何使用「假造」和「錄製」技巧來測試第三方 API 

<hr style="border-top: 2px solid #eee">

到目前為止，我們透過了基礎的功能練習了許多 RSpec 的寫法。這個單元，我們將針對第三方 API 的測試，討論在處理第三方 API 時，會遇到什麼特殊的問題，又有什麼對應的解法。

<br>

### 為什麼第三方 API 需要刻意處理

仔細觀察近年來建立的網站，你會發現大量使用第三方 API 的現象，從社群登入（Google、Facebook 登入），到金流串接都屬於第三方 API 的範疇。

然而，在跑測試的時候，實務上會避免在測試中真正去呼叫第三方 API，理由是：

* 呼叫外部 API 時，可能會因為網路問題導致測試結果失敗
* 呼叫外部 API 會讓測試完成的速度大幅下降
* 因為執行測試，無意間超過第三方 API 提供者的使用頻率限制

根據上述這些可能的原因，我們應該確保我們在執行測試的過程中，並不會真的發送請求至第三方 API 的伺服器，但又可以模擬測試。因此就有了以下兩種常見的技法：

* **假造**
* **錄製**

接下來我們會延續上個單元的「Facebook 登入」，示範這兩個觀念的實作。

<br>

### 第三方 API 假造

第一個技巧是 **第三方 API 假造**。假造會有三個步驟：

1. 創造一組假回應（fake response），規格應該要跟真的第三方 API 回應類似。
2. 阻擋相關的 API 發送。
3. 回傳我們在第一步創造的假回應。

<br>

#### 安裝與設定

我們需要安裝 [Webmock](https://github.com/bblimke/webmock) 這個 gem 來幫助我們完成接下來的任務：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># Gemfile</span>
gem <span style="color: #aa5500">&#39;webmock&#39;</span>
</pre>

<br>

在 `spec_helper.rb` 裡面設定阻擋 API 發送：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/spec_helper.rb</span>

<span style="color: #00aaaa">require</span> <span style="color: #aa5500">&#39;webmock/rspec&#39;</span>
<span style="color: #aa0000">WebMock</span>.disable_net_connect!(allow_localhost: <span style="color: #0000aa">true</span>)
</pre>

<br>

#### 補完 get_facebook_user_data 實作

補完上個單元沒有寫完的 `User.get_facebook_user_data()`，內容是向 Facebook Graph API 發出請求，以權杖來要求回傳臉書的使用者資訊，若請求成功，此方法會回傳臉書資訊內容，否則回傳 `nil`：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># app/models/user.rb</span>

<span style="color: #0000aa">def</span> <span style="color: #00aa00; text-decoration: underline">self</span>.<span style="color: #00aa00">get_facebook_user_data</span>(access_token)
  conn = <span style="color: #aa0000">Faraday</span>.new(<span style="color: #0000aa">url</span>: <span style="color: #aa5500">&#39;https://graph.facebook.com&#39;</span>)
  response = conn.get <span style="color: #aa5500">&quot;/me&quot;</span>, { access_token: access_token }
  data = <span style="color: #aa0000">JSON</span>.parse(response.body)

  <span style="color: #0000aa">if</span> response.status == <span style="color: #009999">200</span>
    data
  <span style="color: #0000aa">else</span>
    <span style="color: #aa0000">Rails</span>.logger.warn(data)
    <span style="color: #0000aa">nil</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

[Faraday](https://github.com/lostisland/faraday#api-documentation) 為筆者習慣用來發送 Request 的 HTTP Client。

<br>

####撰寫測試

接著我們撰寫關於 `self.get_facebook_user_data` 的測試：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/models/user_spec.rb</span>

<span style="color: #aa0000">RSpec</span>.describe <span style="color: #aa0000">User</span>, <span style="color: #0000aa">type</span>: <span style="color: #0000aa">:model</span> <span style="color: #0000aa">do</span>
  it <span style="color: #aa5500">&quot;should get_facebook_user_data work(webmock version)&quot;</span> <span style="color: #0000aa">do</span>
    <span style="color: #aaaaaa; font-style: italic"># need to replace ACCESS_TOKEN to you fb access token</span>
    expect(<span style="color: #aa0000">User</span>.get_facebook_user_data(<span style="color: #aa5500">&quot;ACCESS_TOKEN&quot;</span>)).to eq({
      <span style="color: #aa5500">&quot;id&quot;</span> =&gt; <span style="color: #aa5500">&quot;FB_UID&quot;</span>,
      <span style="color: #aa5500">&quot;name&quot;</span> =&gt; <span style="color: #aa5500">&quot;FB_NAME&quot;</span>
    })
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

此時你需要將權仗加入程式碼，建立你直接建立 **config/facebook.yml** 來管理權杖資訊，並將該檔案加入 **.gitignore**，避免之後不小心把權杖寫進 GitHub。至於權杖的取得方法，請前往 facebook for developers 的[圖形 API 測試工具](https://developers.facebook.com/tools/explorer/?method=GET&path=me%3Ffields%3Did%2Cname&version=v2.12)，登入後取得權杖。

另外，預期回傳的資訊是 `"id"` 和 `"name"`，這也是來自[圖形 API 測試工具](https://developers.facebook.com/tools/explorer/?method=GET&path=me%3Ffields%3Did%2Cname&version=v2.12)頁面上的設定。

<div style="width:100%"> <img style="max-width:1000px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2541/fb-token.png"></div>

<br>

處理好權杖以後，執行 `bundle exec rspec` 跑測試，預期會看到類似以下的錯誤訊息：

<div style="width:100%"> <img style="max-width:800px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2542/webmock-red.png"></div>

<br>

這段錯誤訊息嘗試告訴我們，我們想要發送的請求已經被 webmock 擋下來，沒有真的發送。接著我們要偽造假回應，你會發現 webmock 已經把假造的格式幫我們準備好了。

請在錯誤訊息的下半部找到 `You can stub this request with the following snippet:` 這句話，這句話之後是 webmock 幫你做好的假回應，請你去 **spec/spec_helper.rb** 新增設定：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/spec_helper.rb</span>

  config.before(<span style="color: #0000aa">:each</span>) <span style="color: #0000aa">do</span>
    <span style="color: #aaaaaa; font-style: italic"># need to replace ACCESS_TOKEN to you fb access token</span>
    stub_request(<span style="color: #0000aa">:get</span>, <span style="color: #aa5500">&quot;https://graph.facebook.com/me?access_token=ACCESS_TOKEN&quot;</span>).
      with(<span style="color: #0000aa">headers</span>: {<span style="color: #aa5500">&#39;Accept&#39;</span>=&gt;<span style="color: #aa5500">&#39;*/*&#39;</span>, <span style="color: #aa5500">&#39;Accept-Encoding&#39;</span>=&gt;<span style="color: #aa5500">&#39;gzip;q=1.0,deflate;q=0.6,identity;q=0.3&#39;</span>, <span style="color: #aa5500">&#39;User-Agent&#39;</span>=&gt;<span style="color: #aa5500">&#39;Faraday v0.12.2&#39;</span>}).
      to_return(<span style="color: #0000aa">status</span>: <span style="color: #009999">200</span>, <span style="color: #0000aa">body</span>: <span style="color: #aa5500">&#39;{&quot;id&quot;:&quot;FB_UID&quot;, &quot;name&quot;: &quot;FB_NAME&quot;}&#39;</span>, <span style="color: #0000aa">headers</span>: {})
  <span style="color: #0000aa">end</span>
</pre>

<br>

唯一需要調整的地方是，webmock 訊息裡原本是 `to_return(:status => 200, :body => "", :headers => {})`，需要把 `body` 的內容換成和測試案例裡一致的內容： `to_return(status: 200, body: '{"id":"FB_UID", "name": "FB_NAME"}', headers: {})`。

如此一來，假回應就完成了！此時可以再執行一次測試 `bundle exec rspec`，預期會看見綠燈通過！

<br>

### 第三方 API 錄製

第二個技巧是 **第三方 API 錄製**，我們將透過 [vcr](https://github.com/vcr/vcr) 這個 gem 幫我們完成錄製的任務。

使用錄製技巧時，第一次會真的發送請求到第三方 API 的伺服器，此時 VCR 把回傳結果錄製下來，存成一支 yml 檔案，之後，要針對同樣的網址和參數進行請求，就不再需要發送請求，而可以引用這支 yml 檔案的內容。

「假造」和「錄製」技巧不會同時使用，因此，在練習本內容時，你需要清掉上一步驟的實作內容。

過程中會用到 vcr gem 和 webmock gem：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># Gemfile</span>
gem <span style="color: #aa5500">&#39;vcr&#39;</span>
gem <span style="color: #aa5500">&#39;webmock&#39;</span>
</pre>

<br>

<div class='terminal-block'>
  <div class='terminal-block-head'>Terminal</div>
  <div class='terminal-block-body'>
    <div class='terminal-code-line'>
      <span class='terminal-path'>[~/restaurant_forum] </span><span class='terminal-command'>$ bundle install</span>
    </div>
  </div>
</div>

<br>

撰寫設定檔：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/support/vcr_setup.rb</span>

<span style="color: #aa0000">VCR</span>.configure <span style="color: #0000aa">do</span> |config|
  <span style="color: #aaaaaa; font-style: italic"># 設定儲存 API 檔案的目錄位置</span>
  config.cassette_library_dir = <span style="color: #aa5500">&quot;spec/fixtures/vcr&quot;</span>
  <span style="color: #aaaaaa; font-style: italic"># 設定假造 API 的函式庫</span>
  config.hook_into <span style="color: #0000aa">:webmock</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

導入 `vcr` 設定檔：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/rails_helper.rb</span>
<span style="color: #00aaaa">require</span> <span style="color: #aa5500">&#39;support/vcr_setup&#39;</span>
</pre>

<br>

然後撰寫錄製的測試檔，請注意你需要把 webmock version 的測試替換掉：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/models/user_spec.rb</span>

<span style="color: #aa0000">RSpec</span>.describe <span style="color: #aa0000">User</span>, <span style="color: #0000aa">type</span>: <span style="color: #0000aa">:model</span> <span style="color: #0000aa">do</span>
  <span style="color: #aaaaaa; font-style: italic"># other examples</span>

  it <span style="color: #aa5500">&quot;should get_facebook_user_data work(vcr version)&quot;</span> <span style="color: #0000aa">do</span>
    <span style="color: #aa0000">VCR</span>.use_cassette <span style="color: #aa5500">&#39;get facebook user data&#39;</span> <span style="color: #0000aa">do</span>
      expect(<span style="color: #aa0000">User</span>.get_facebook_user_data(<span style="color: #aa5500">&#39;ACCESS_TOKEN&#39;</span>)).to eq({
        <span style="color: #aa5500">&quot;name&quot;</span> =&gt; <span style="color: #aa5500">&quot;FB_NAME&quot;</span>,
        <span style="color: #aa5500">&quot;id&quot;</span> =&gt; <span style="color: #aa5500">&quot;FB_ID&quot;</span>
      })
    <span style="color: #0000aa">end</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

執行 `bundle exec rspec` 跑測試，預期會出現 Failure，但同時跑完測試後，你會在 `spec/vcr` 資料夾裡發現多了一隻名為 `get_facebook_user_data.yml` 的檔案，裡面的內容大概會是這樣，記錄了一切重製這個請求所需要的資訊：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #00aaaa;">---</span>
http_interactions:
- request:
    method: get
    uri: https://graph.facebook.com/me?access_token=ACCESS_TOKEN
    body:
      encoding: US-ASCII
      string: <span style="color: #aa5500">&#39;&#39;</span>
    headers:
      User-Agent:
      - Faraday v0.12.2
      Accept-Encoding:
      - gzip;q=1.0,deflate;q=0.6,identity;q=0.3
      Accept:
      - <span style="color: #aa5500">&quot;*/*&quot;</span>
  response:
    status:
      code: 200
      message: OK
    headers:
      X-App-Usage:
      - <span style="color: #aa5500">&#39;{&quot;call_count&quot;:3,&quot;total_cputime&quot;:4,&quot;total_time&quot;:3}&#39;</span>
      Etag:
      - <span style="color: #aa5500">&#39;&quot;1951a445ed3d35b8ed9189ed52fb3b3a6f579c80&quot;&#39;</span>
      Strict-Transport-Security:
      - max-age=15552000; preload
      X-Fb-Trace-Id:
      - AEDfjs2s2g1
      X-Fb-Rev:
      - <span style="color: #aa5500">&#39;3775614&#39;</span>
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
      - <span style="color: #aa5500">&quot;*&quot;</span>
      X-Fb-Debug:
      - zkDHFUAjqH9lJ8gAJdeAVbf6EnXro0ApeWYV8YyG0BAJwuyILYuHONEoy01oUvLO6EyAdTFGt+pvvY8dDA/tWQ==
      Date:
      - Tue, 03 Apr 2018 05:41:45 GMT
      Connection:
      - keep-alive
      Content-Length:
      - <span style="color: #aa5500">&#39;60&#39;</span>
    body:
      encoding: UTF-8
      string: <span style="color: #aa5500">&#39;{&quot;email&quot;:&quot;YOUR_FB_EMAIL&quot;,&quot;id&quot;:&quot;YOUR_FB_ID&quot;}&#39;</span>
    http_version:
  recorded_at: Tue, 03 Apr 2018 05:41:45 GMT
recorded_with: VCR 3.0.3
</pre>

<br>

如果成功看見這個檔案，就表示你成功完成了錄製的任務，之後要針對同樣的網址和參數進行請求，就可以引用這支 yml 檔案的內容。

<br>

### 小結

在這個單元裡，我們介紹了兩種在測試中處理 API 的方法，彼此分別適合不同的情境，各有彼此的優缺點：

* 假造：需要手動撰寫請求以及回傳的 header 以及 body，雖然說較為麻煩，但是對於假造內容的掌握度較高。
* 錄製：直接幫我們記錄下來整個請求以及回傳構通的過程，開發起來很快，但很多時候我們其實只是需要比對 body 而已，大多數的資訊其實不需要用到。

<br>

### 參考程式碼

| 主題 | 說明 |
| :----- | :----- |
| 假造|[LINK](https://github.com/ALPHACamp/restaurant-forum-testing/commit/3190433586073d8a35234118ca2e4593c8617775)|
|錄製|[LINK](https://github.com/ALPHACamp/restaurant-forum-testing/commit/cfe13419088881ab80b2e98cc4d9f9329a4c6dd4)|
