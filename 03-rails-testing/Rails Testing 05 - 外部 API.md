<hr style="border-top: 2px solid #eee">

到目前為止，我們透過了基礎的功能練習了許多 RSpec 的寫法。這一章會把重點放在第三方 API 的測試方法，一開始我們會分析為什麼第三方 API 會需要獨立出來，接著我們會依序介紹常使用的兩種技法，最後讓讀者們依照自己的程式風格去搭配不同的情境使用。

<br>

### 為什麼第三方 API 需要處理

仔細觀察近年來建立的網站，很容易就發現大量使用第三方 API 的現象。從社群登入（Google、Facebook 登入），到金流串接都屬於第三方 API 的範疇。然而，在跑測試的時候，每次遇到第三方 API 都去呼叫是一件沒有效率，甚至是相當麻煩的事:

* 測試可能會因為各種網路問題不穩導致結果失敗
* 測試完成的速度大幅下降
* 測試的過程無意間超過第三方 API 提供者所訂製的使用頻率限制

根據上述這些可能的原因，我們應該確保我們的測試在執行的過程中並不會真的發送請求至第三方 API 的伺服器。兩種常見的技法分別是 **假造** 和 **錄製**，接下來我們會依序介紹這兩個觀念如何跟 TDD 在實務上結合，我們會選擇在上一章我們自製用於跟 Facebook 確認使用者資料的 API (https://graph.facebook.com/me) 當作範例，程式碼片段位於 `models/users.rb`。 

<br>

### 第三方 API 假造

第一個技巧是 **第三方 API 假造**。這個部分一共有三個步驟，首先，我們創造一組假回應（fake response），規格應該要跟真的第三方 API 回應類似。第二步，我們阻擋相關的 API 發送。最後，回傳我們在第一步創造的假回應。

我們安裝 [Webmock](https://github.com/bblimke/webmock) 這個 gem 來幫助我們完成接下來的任務:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># Gemfile</span>
gem <span style="color: #aa5500">&#39;webmock&#39;</span>
</pre>

<br>

在 `spec_helper.rb` 裡面阻擋 API 發送:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/spec_helper.rb</span>

<span style="color: #00aaaa">require</span> <span style="color: #aa5500">&#39;webmock/rspec&#39;</span>
<span style="color: #aa0000">WebMock</span>.disable_net_connect!(allow_localhost: <span style="color: #0000aa">true</span>)
</pre>

<br>

撰寫 `models/user.rb` 裡面其中關於 `self.get_facebook_user_data` 的測試:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/model/user.rb</span>

<span style="color: #aa0000">RSpec</span>.describe <span style="color: #aa0000">User</span>, <span style="color: #0000aa">type</span>: <span style="color: #0000aa">:model</span> <span style="color: #0000aa">do</span>
  it <span style="color: #aa5500">&quot;should get_facebook_user_data work(webmock version)&quot;</span> <span style="color: #0000aa">do</span>
    expect(<span style="color: #aa0000">User</span>.get_facebook_user_data(<span style="color: #aa0000">ACCESS_TOKEN</span>)).to eq({
      <span style="color: #aa5500">&quot;id&quot;</span> =&gt; <span style="color: #aa5500">&quot;FB_UID&quot;</span>,
      <span style="color: #aa5500">&quot;name&quot;</span> =&gt; <span style="color: #aa5500">&quot;FB_NAME&quot;</span> 
    })
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

在跑這個測試之前，我們必須先前往 Facebook 的圖形 API 測試工具，產生授權的權杖，前往 `https://developers.facebook.com/tools/explorer/?method=GET&path=me%3Ffields%3Did%2Cname&version=v2.12`
網址，登入 Facebook 就可以看到自己的權杖，它會是個由大小寫英文以及數字組成、長達 200 個字左右的字串。把 `ACCESS_TOKEN` 用剛剛拿到的權杖替換，接者我們執行 `bundle exec rspec` 跑測試，會看到類似以下的錯誤訊息:

<pre style="background:#000;color:#fff;font-size:15px;line-height:1.6">  Failure/Error: response = conn.get "/me", { access_token: access_token }

  WebMock::NetConnectNotAllowedError:
    Real HTTP connections are disabled. Unregistered request: GET https://graph.facebook.com/me?access_token=access_token with headers {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.12.2'}

    You can stub this request with the following snippet:

    stub_request(:get, "https://graph.facebook.com/me?access_token=access_token").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.12.2'}).
      to_return(:status => 200, :body => "", :headers => {})
</pre>

<br>

這段錯誤訊息嘗試告訴我們，我們想要發送的請求已經被 webmock 擋下來沒有真的發送。接著我們要偽造假回應，你會發現 webmock 已經把假造的格式幫我們準備好了。看到上面錯誤訊息的下半部，從 `You can stub this request with the following snippet:` 這行開始，接著我們需要調整 response body ，換成我們自己的 `FB_UID` 和 `FB_NAME`。

原本的格式應該是 `to_return(:status => 200, :body => "", :headers => {})`

把 body 換成實際回傳的內容 `to_return(status: 200, body: '{"id":"FB_UID", "name": "FB_NAME"}', headers: {})`

假回應就完成了，接著我們把假回應放在測試的設定檔案中:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/spec_helper.rb</span>

  config.before(<span style="color: #0000aa">:each</span>) <span style="color: #0000aa">do</span>
    stub_request(<span style="color: #0000aa">:get</span>, <span style="color: #aa5500">&quot;https://graph.facebook.com/me?access_token=access_token&quot;</span>).
      with(<span style="color: #0000aa">headers</span>: {<span style="color: #aa5500">&#39;Accept&#39;</span>=&gt;<span style="color: #aa5500">&#39;*/*&#39;</span>, <span style="color: #aa5500">&#39;Accept-Encoding&#39;</span>=&gt;<span style="color: #aa5500">&#39;gzip;q=1.0,deflate;q=0.6,identity;q=0.3&#39;</span>, <span style="color: #aa5500">&#39;User-Agent&#39;</span>=&gt;<span style="color: #aa5500">&#39;Faraday v0.12.2&#39;</span>}).
      to_return(<span style="color: #0000aa">status</span>: <span style="color: #009999">200</span>, <span style="color: #0000aa">body</span>: <span style="color: #aa5500">&#39;{&quot;id&quot;:&quot;FB_UID&quot;, &quot;name&quot;: &quot;FB_NAME&quot;}&#39;</span>, <span style="color: #0000aa">headers</span>: {})
  <span style="color: #0000aa">end</span>
</pre>

<br>

再執行一次測試，通過！

<br>

### 第三方 API 錄製

第二個技巧是 **第三方 API 錄製**，我們將透過 [vcr](https://github.com/vcr/vcr) 這個 gem 幫我們完成錄製的任務。第一次我們會真的發送請求到實際的伺服器，而這時 VCR 會幫我們把回傳的結果紀錄在一隻 yml 檔案裡面，之後針對同樣的網址和參數的請求就不會真的發送請求，而是用之前紀錄的 yml 檔案。

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># Gemfile</span>
gem <span style="color: #aa5500">&#39;vcr&#39;</span>
</pre>

<br>

在 `spec/support/vcr_setup.rb` 撰寫設定檔:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aa0000">VCR</span>.configure <span style="color: #0000aa">do</span> |config|
  <span style="color: #aaaaaa; font-style: italic"># 設定儲存 API 檔案的目錄位置</span>
  config.cassette_library_dir = <span style="color: #aa5500">&quot;fixtures/vcr&quot;</span>
  <span style="color: #aaaaaa; font-style: italic"># 設定假造 API 的函式庫</span>
  config.hook_into <span style="color: #0000aa">:webmock</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

在 `spec/rails_helper.rb` 導入 `vcr` 設定檔:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #00aaaa">require</span> <span style="color: #aa5500">&#39;support/vcr_setup&#39;</span>
</pre>

<br>

然後撰寫錄製的測試檔:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aa0000">RSpec</span>.describe <span style="color: #aa0000">User</span>, <span style="color: #0000aa">type</span>: <span style="color: #0000aa">:model</span> <span style="color: #0000aa">do</span>
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

跑完測試可以發現在 `spec/vcr` 這個資料夾下面多了一隻名為 `get_facebook_user_data.yml` 的檔案，裡面的內容大概會是這樣，記錄了一切重製這個請求所需要的資訊:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #00aaaa;">---</span>
http_interactions:
- request:
    method: get
    uri: https://graph.facebook.com/me?access_token=EAACEdEose0cBAOnZBPUb0EuX8xgnHpoa9JKpeCLAWqdLQGrMjn1X2eaiZCFVOnveXrd4LY8F3JBK5zIsFu3inllfTs54MCiz5NRAIxlZCOLJU9SEQxBSh6gtSbKT5hG15A1WtsgZBiqOhvnFDVwUKxDz6Qf7mc17OPuh437qPXyZBf7fEX4cihDm5EJtD6mQZD&amp;fields=email
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
      string: <span style="color: #aa5500">&#39;{&quot;email&quot;:&quot;frozenfung\u0040gmail.com&quot;,&quot;id&quot;:&quot;962045113809238&quot;}&#39;</span>
    http_version: 
  recorded_at: Tue, 03 Apr 2018 05:41:45 GMT
recorded_with: VCR 3.0.3
</pre>

<br>

### 小結

這個章節我們介紹兩種在測試中處理 API 的方法，彼此分別適合不同的情境，各有彼此的優缺點。第一種技巧我們需要手動撰寫請求以及回傳的 header 以及 body，雖然說較為麻煩，但是對於假造內容的掌握度較高。第二種技巧會直接幫我們記錄下來整個請求以及回傳構通的過程，開發起來很快，但很多時候我們其實只是需要比對 body 而已，大多數的資訊其實不需要用到。