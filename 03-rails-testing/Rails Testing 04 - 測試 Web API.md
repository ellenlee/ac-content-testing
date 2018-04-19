>**學習成果與目標**
>・能夠為 Devise 的登入、登出功能撰寫測試
>・能夠為 FB 登入功能撰寫測試

<hr style="border-top: 2px solid #eee">

在前面的單元，我們使用「餐廳論壇」結合測試完成了基礎功能的實作。在這個單元，我們會展示如何進行 Web API 的測試。

我們會用「Email 登入/登出」的功能做展示，功能實作的流程如同在【[Web API > 使用者認證](https://lighthouse.alphacamp.co/lessons/236/)】的設計，只是這次要在實作的同時加上 RSpec：

<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/1740/4.png"></div>

<br>

如果你在使用 Web API 課程時，有完成實作練習，你可以稍微複習一下，當時我們在做登入/登出 Web API 時，最後是怎麼用 Postman 做測試的？「自動化測試」就是要取代當時我們手動做測試的過程。

<br>

### 準備專案

由於本單元的內容會同時處理 Web API 的實作與測試，以下提供一個練習用的餐廳論壇專案，建議你先直接 `git clone` 示範專案來進行練習，有了完整的體驗之後，再回到自己的專案上進行 Web API 開發。

示範專案下載位址：[https://github.com/ALPHACamp/restaurant-forum-testing-base](https://github.com/ALPHACamp/restaurant-forum-testing-base)

你可以參看示範專案的 commit 記錄來理解專案現狀，除了完整延續【餐廳論壇】系列內容外，該專案預先做了以下事情：

<ul>
  <li>RSpec 環境設定：
    <ul>
      <li>已安裝[之前介紹](https://lighthouse.alphacamp.co/lessons/271/units/1288)的專案與工具</li>
      <li>已實作完成「測試 Model」和「測試 Controller」的內容</li>
    </ul>
  </li>
  <li>為 User model 新增 authentication_token 屬性
    <ul>
      <li>確保每個 User 物件都有</li>
      <li>完成 FactoryBot 測資設定</li>
    </ul>
  </li>
  <li>預先設好給 Web API 用的 login 和 logout 路由</li>
  <li>新增 ApiController，要求驗證 authentication_token 的值</li>  
</ul>

clone 示範專案後，需要先進行初始化，專案有事先準備好一組假資料 rake，rake 檔案在 **lib/tasks/dev.rake** 裡：

<div class='terminal-block'>
  <div class='terminal-block-head'>Terminal</div>
  <div class='terminal-block-body'>
    <div class='terminal-code-line'>
      <span class='terminal-path'>[~/restaurant_forum] </span><span class='terminal-command'>$ rails db:migrate</span><br>
      <span class='terminal-path'>[~/restaurant_forum] </span><span class='terminal-command'>$ rails dev:rebuild</span>  
    </div>
  </div>
</div>

<br>

### 確認目標

了解運作機制之後，我們先把這次的目標列出來，我們的目標是開發以下兩支 API：

* `api_v1/login`
* `api_v1/logout`

如果你 clone 示範專案，這兩支路由已經在 **config/routes.rb** 裡設定好了。

<br>

### Email 登入

#### 撰寫測試

首先我們嘗試撰寫 email 登入的測試：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/controllers/api_v1/auth_spec.rb</span>

<span style="color: #00aaaa">require</span> <span style="color: #aa5500">&#39;rails_helper&#39;</span>

<span style="color: #aa0000">RSpec</span>.describe <span style="color: #0000aa">Api</span>:<span style="color: #0000aa">:V1</span>::<span style="color: #aa0000">AuthController</span>, <span style="color: #0000aa">type</span>: <span style="color: #0000aa">:controller</span> <span style="color: #0000aa">do</span>
  it <span style="color: #aa5500">&quot;login via email and password&quot;</span> <span style="color: #0000aa">do</span>
    user = create(<span style="color: #0000aa">:user</span>, <span style="color: #0000aa">email</span>: <span style="color: #aa5500">&#39;123@gmail.com&#39;</span>, <span style="color: #0000aa">password</span>: <span style="color: #aa5500">&#39;123123&#39;</span>)
    post <span style="color: #aa5500">&quot;login&quot;</span>, <span style="color: #0000aa">params</span>: { <span style="color: #0000aa">email</span>: user.email, <span style="color: #0000aa">password</span>: <span style="color: #aa5500">&#39;123123&#39;</span> }

    expect(response).to have_http_status(<span style="color: #009999">200</span>)
    expect(<span style="color: #aa0000">JSON</span>.parse(response.body)).to eq({
      <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&#39;ok&#39;</span>,
      auth_token: user.authentication_token
    })
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

首先建立一個使用者，然後向 `api/v1/login` 發出 POST 請求，並傳入該使用者的帳號密碼。

我們預期得到的回應是 response status 200，而且 response body 是可以解析的 JSON，JSON 的內容會帶有使用者認證碼的相關資訊。

以上測試案例，其實就是取代了之前用 Postman 做的手動測試。

這個時候透過 `bundle exec rspec` 執行測試，應該會出現 failure，因為我們還沒有開發任何功能。

<br>

####實作功能

接下來我們要開始撰寫 `ApiV1::AuthController` 裡面的 `login` 行為，試著讓測試通過：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># app/controllers/api/v1/auth_controller.rb</span>

<span style="color: #0000aa">class</span> <span style="color: #00aa00; text-decoration: underline">Api</span>::<span style="color: #0000aa">V1</span>:<span style="color: #0000aa">:AuthController</span> &lt; <span style="color: #aa0000">ApiController</span>

  <span style="color: #aaaaaa; font-style: italic"># POST /api/v1/login</span>
  <span style="color: #0000aa">def</span> <span style="color: #00aa00">login</span>
    success = <span style="color: #0000aa">false</span>

    <span style="color: #0000aa">if</span> params[<span style="color: #0000aa">:email</span>] &amp;&amp; params[<span style="color: #0000aa">:password</span>]
      user = <span style="color: #aa0000">User</span>.find_by_email(params[<span style="color: #0000aa">:email</span>])
      success = user &amp;&amp; user.valid_password?(params[<span style="color: #0000aa">:password</span>])
    <span style="color: #0000aa">end</span>

    <span style="color: #0000aa">if</span> success
      render <span style="color: #0000aa">json</span>: {
        <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&quot;ok&quot;</span>,
        auth_token: user.authentication_token
      }
    <span style="color: #0000aa">else</span>
      render <span style="color: #0000aa">json</span>: { <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&quot;failed&quot;</span> }, <span style="color: #0000aa">status</span>: <span style="color: #009999">401</span>
    <span style="color: #0000aa">end</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

重新執行一次測試，此時預期會亮起綠燈。

<br> 

### 登出

登入完成之後，接下來是登出。在我們目前 token 機制的設計裡，「登出」的意思是該 user 的 token 刷新，因為刷新後的 token 無法通過 ApiController 裡的驗證：

<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/1741/3.png"></div>

<br>

因此，檢查的關鍵會是在登出前後的 `authentication_token` 屬性是否有改變。

<br>

####撰寫測試

根據上述邏輯，讓我們先寫測試：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/controllers/api_v1/auth_spec.rb</span>

it <span style="color: #aa5500">&quot;logout succesfully&quot;</span> <span style="color: #0000aa">do</span>
  user = create(<span style="color: #0000aa">:user</span>, <span style="color: #0000aa">email</span>: <span style="color: #aa5500">&#39;123@gmail.com&#39;</span>, <span style="color: #0000aa">password</span>: <span style="color: #aa5500">&#39;123123&#39;</span>)
  token = user.authentication_token

  post <span style="color: #aa5500">&quot;logout&quot;</span>, <span style="color: #0000aa">parmas</span>: { auth_token: user.authentication_token }

  expect(response).to have_http_status(<span style="color: #009999">200</span>)
  user.reload
  expect(user.authentication_token).not_to eq(token)
<span style="color: #0000aa">end</span>
</pre>

<br>

首先為測試案例新增一個 user，並取得 user 的 token（根據 User model 裡預先安準備好的 `generate_authentication_token`，在創建 user 物件時，會自動生成 token 的值。

在這裡，我們先宣告一個 `token` 變數把當下的 `user.authentication_token` 存下來，以便等一下做對照。

接著向 `api/v1/logout` 發出 POST 請求，並傳入 `auth_token` 參數，值是上述 user 的 token 值。

我們預期伺服器會回應 HTTP Status 200，代表成功。如果「成功登入」，意味著 `user.authentication_token` 應該要刷新，因此接下來的動作是檢查這個預期有沒有發生。

為避免 `user` 變數因快取而沒有反應到資料庫最新狀況，我們先做一次 `reload`，確保 `user` 去重新讀取資料庫裡的紀錄。做完確保動作後，我們把剛才存下的 `token` 叫出來對照，看看 `user.authentication_token` 屬性是不是已經刷新。

<br>

####實作功能

根據我們的預期，完成登出功能的撰寫：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># app/controllers/api/v1/auth_controller.rb</span>

before_action <span style="color: #0000aa">:authenticate_user!</span>, <span style="color: #0000aa">only</span>: <span style="color: #0000aa">:logout</span>

<span style="color: #0000aa">def</span> <span style="color: #00aa00">logout</span>
  current_user.generate_authentication_token
  current_user.save!

  render <span style="color: #0000aa">json</span>: { <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&quot;ok&quot;</span> }
<span style="color: #0000aa">end</span>
</pre>

<br>

到這裡，你可以再次執行測試，預期會看見綠燈亮起。

以上是「登入/登出」的 Web API 測試，透過這個例子的練習，希望你能感受到自動化測試的好處：

* 你不需要再開啟 Postman 去輸入一堆參數來測試 login 和 logout，這個例子裡，「自動化測試」相對於「手動測試」是真的省下了不少時間
* 像 login / logout 這樣稍微瑣碎的測試過程，時間久了回過頭來，可能會忘記細節，無法順利執行手動測試，寫成測試案例，也等於是規格文件化，只要閱讀 RSpec 的測試案例，就可以知道這些功能的預期結果是什麼。

在接下來的兩個單元，我們會討論「測試第三方 API」的眉角，內容會與實務上的考量接軌，期能讓同學更加了解寫測試的目的。

<br>

###參考程式碼

| Commit | GitHub |
|:----- | :----- |
| preparation | [LINK](https://github.com/ALPHACamp/restaurant-forum-testing/commit/32deae9987adb052f336c37109d7b7610adbd929) |
| implement email login with spec | [LINK](https://github.com/ALPHACamp/restaurant-forum-testing/commit/f311e7f211104044c82c77f9a6ab55e10cb9716b) |
| implement email logout with spec | [LINK](https://github.com/ALPHACamp/restaurant-forum-testing/commit/497c47b0c27f374a723f6a2ca2f9963212dae6ff) |
