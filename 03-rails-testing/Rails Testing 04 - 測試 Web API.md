<hr style="border-top: 2px solid #eee">

在前面的單元，我們使用「餐廳論壇」結合 TDD 完成了基礎功能的實作。在這個單元，我們會展示如何測試登入登出的 API，透過這個比較完整的應用，讓大家更完整體驗 TDD 可能的應用方式。

<br>

### 準備專案

請你準備任一個你自己的專案來做練習，並依照前幾單元的介紹，安裝好 RSpec、載入 Devise 設定並準備假資料。

<br>

### 確認目標

了解運作機制之後，我們先把這次的目標列出來，我們的目標是開發以下兩支 API：

* `api_v1/login`
* `api_v1/logout`

接著我們先把登入的邏輯想清楚，可能的情境有兩種：

1. 使用者使用 email 登入，確認從客戶端來的帳號和密碼無誤後，回傳使用者認證碼
2. 使用者使用 Facebook 登入，透過 Facebook 個人資料 API 確認從客戶端帶來的 Facebook 權杖有效並取回個人資訊。如果個人資訊尚未登陸資料庫，則建立新的使用者，並回傳使用者認證碼。如果個人資訊已經存在於資料庫，則找到該名使用者並回傳使用者認證碼。

登出情境相對單純，只需要重設使用者認證碼，這樣下次客戶端帶著舊的認證碼進來時，就找不到使用者了。

<br>

### 準備路由

讓我們先把目標路由設定上去：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># config/routes.rb</span>

namespace <span style="color: #0000aa">:api</span>, <span style="color: #0000aa">defaults</span>: {<span style="color: #00aaaa">format</span>: <span style="color: #0000aa">:json</span>} <span style="color: #0000aa">do</span>
  namespace <span style="color: #0000aa">:v1</span> <span style="color: #0000aa">do</span>
    post <span style="color: #aa5500">&quot;/login&quot;</span> =&gt; <span style="color: #aa5500">&quot;auth#login&quot;</span>
    post <span style="color: #aa5500">&quot;/logout&quot;</span> =&gt; <span style="color: #aa5500">&quot;auth#logout&quot;</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

### 登入

#### 撰寫測試

首先我們嘗試撰寫 email 登入的測試：

<span style="color: #aaaaaa; font-style: italic"># spec/controllers/api_v1/auth_spec.rb</span>

<span style="color: #00aaaa">require</span> <span style="color: #aa5500">&#39;rails_helper&#39;</span>

<span style="color: #aa0000">RSpec</span>.describe <span style="color: #0000aa">Api</span>:<span style="color: #0000aa">:V1</span>::<span style="color: #aa0000">AuthController</span>, <span style="color: #0000aa">type</span>: <span style="color: #0000aa">:controller</span> <span style="color: #0000aa">do</span>
  it <span style="color: #aa5500">&quot;login via email and password&quot;</span> <span style="color: #0000aa">do</span>
    user = create(<span style="color: #0000aa">:user</span>, <span style="color: #0000aa">email</span>: <span style="color: #aa5500">&#39;123@gmail.com&#39;</span>, <span style="color: #0000aa">password</span>: <span style="color: #aa5500">&#39;123123&#39;</span>)
    post <span style="color: #aa5500">&quot;login&quot;</span>, <span style="color: #0000aa">params</span>: { <span style="color: #0000aa">email</span>: user.email, <span style="color: #0000aa">password</span>: <span style="color: #aa5500">&#39;123123&#39;</span> }
 
    expect(response).to have_http_status(<span style="color: #009999">200</span>)
    expect(<span style="color: #aa0000">JSON</span>.parse(response.body)).to eq({
      <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&#39;ok&#39;</span>,
      auth_token: user.auth_token,
    })
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

首先建立一個使用者，然後用這個使用者的帳號密碼當作參數去呼叫 `api/v1/login`，預期 response status 為 200，而 response body 應該會帶有使用者認證碼的相關資訊。這個時候透過 `bundle exec rspec` 執行測試，應該會出現 failure，因為我們還沒有開發任何功能。

<div style="width:100%"> <img style="max-width:800px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2537/login-red.png"></div>

<br>

#### 實作功能

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

### Facebook 登入

在進行這組測試練習前，你的專案需要先有 [Facebook 帳號登入](https://lighthouse.alphacamp.co/lessons/236/units/1154)的功能。

<br>

#### 撰寫測試

到目前為止已經完成 email 登入功能。接著我們試著加上 Facebook 登入的功能，先撰寫測試的部分：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/controllers/api_v1/auth_spec.rb</span>

it <span style="color: #aa5500">&quot;login via facebook access_token&quot;</span> <span style="color: #0000aa">do</span>
  user = create(<span style="color: #0000aa">:user</span>, <span style="color: #0000aa">email</span>: <span style="color: #aa5500">&#39;123@gmail.com&#39;</span>, <span style="color: #0000aa">password</span>: <span style="color: #aa5500">&#39;123123&#39;</span>)
  fb_data = { <span style="color: #aa5500">&quot;id&quot;</span> =&gt; <span style="color: #aa5500">&quot;123&quot;</span>, <span style="color: #aa5500">&quot;email&quot;</span> =&gt; <span style="color: #aa5500">&quot;123@gmail.com&quot;</span>, <span style="color: #aa5500">&quot;name&quot;</span> =&gt; <span style="color: #aa5500">&quot;fung&quot;</span> }
  fb_access_token = <span style="color: #aa5500">&#39;blablabla&#39;</span>
  auth_hash = double(<span style="color: #aa5500">&#39;OmniAuth::AuthHash&#39;</span>)
  allow(<span style="color: #aa0000">User</span>).to receive(<span style="color: #0000aa">:get_facebook_user_data</span>).with(fb_access_token).and_return(fb_data)

  allow(<span style="color: #0000aa">OmniAuth</span>:<span style="color: #0000aa">:AuthHash</span>).to receive(<span style="color: #0000aa">:new</span>).and_return(auth_hash)
  allow(<span style="color: #aa0000">User</span>).to receive(<span style="color: #0000aa">:from_omniauth</span>).with(auth_hash).and_return(user)

  post <span style="color: #aa5500">&quot;login&quot;</span>, <span style="color: #0000aa">params</span>: { access_token: fb_access_token }

  expect(response).to have_http_status(<span style="color: #009999">200</span>)
  expect(<span style="color: #aa0000">JSON</span>.parse(response.body)).to eq({
    <span style="color: #aa5500">&#39;message&#39;</span> =&gt; <span style="color: #aa5500">&#39;ok&#39;</span>,
    <span style="color: #aa5500">&#39;auth_token&#39;</span> =&gt; user.authentication_token
  })
<span style="color: #0000aa">end</span>
</pre>

<br>

說明如下：

<ul>
  <li>首先假造了 <code>fb_data</code> 做為透過客戶端來的權杖，進行身份確認的回傳資訊。</li>
  <li>接著偽造 <code>fb_access_token</code>，在這邊我們要做三個假設：
    <ul>
      <li>第一，預期 User 的 <code>get_facebook_user_data</code> 這個 class method 會被呼叫，並回傳我們假造的 <code>fb_data</code>；</li>
      <li>第二，我們會利用 <code>OmniAuth::AuthHash</code> 產生一個該類別下的 instance，並且回傳該 instance 定義為 auth_hash</li>
      <li>最後，User 類別下的 <code>from_omniauth</code> 應該會被呼叫並回傳該使用者。</li>
    </ul>
  </li>
</ul>

此時，透過 `bundle exec rspec` 執行測試，應該會出現紅燈：

<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2538/login-fb-red.png"></div>

<br>

#### 調整 login 功能

我們需要稍微調整 `ApiV1::AuthController` 裡面的 `login` 的邏輯，試著讓 email 登入與 facebook 登入能夠一起運作：

<pre style="background:#f9f9f9;color:#080808"><div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;"><span style="color: #aaaaaa; font-style: italic"># app/controllers/api/v1/auth_controller.rb</span></div>

<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">  <span style="color: #0000aa">def</span> <span style="color: #00aa00">login</span></div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">    success = <span style="color: #0000aa">false</span></div>

<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">    <span style="color: #0000aa">if</span> params[<span style="color: #0000aa">:email</span>] &amp;&amp; params[<span style="color: #0000aa">:password</span>]</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">      user = <span style="color: #aa0000">User</span>.find_by_email(params[<span style="color: #0000aa">:email</span>])</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">      success = user &amp;&amp; user.valid_password?(params[<span style="color: #0000aa">:password</span>])</div>
<div style="background: #ffdce0;color: #cb2431;display: inline-block;width: 3%;padding: 0 5px;">-</div><div style="background: #ffeef0;display: inline-block;width: 97%;padding-left: 5px;">    <span style="color: #0000aa">end</span></div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">    <span style="color: #0000aa">elsif</span> params[<span style="color: #0000aa">:access_token</span>]</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">      fb_data = <span style="color: #aa0000">User</span>.get_facebook_user_data(params[<span style="color: #0000aa">:access_token</span>])</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">      <span style="color: #0000aa">if</span> fb_data</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">          auth_hash = <span style="color: #0000aa">OmniAuth</span>:<span style="color: #0000aa">:AuthHash</span>.new({</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">            <span style="color: #0000aa">uid</span>: fb_data[<span style="color: #aa5500">&quot;id&quot;</span>],</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">            <span style="color: #0000aa">info</span>: { <span style="color: #0000aa">email</span>: fb_data[<span style="color: #aa5500">&quot;email&quot;</span>] },</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">            <span style="color: #0000aa">credentials</span>: {</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">             <span style="color: #0000aa">token</span>: params[<span style="color: #0000aa">:access_token</span>],</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">             expires_at: <span style="color: #aa0000">Time</span>.now + <span style="color: #009999">60</span>.days</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">           }</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">          })</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">        user = <span style="color: #aa0000">User</span>.from_omniauth(auth_hash)</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">      <span style="color: #0000aa">end</span></div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">      success = fb_data &amp;&amp; user.persisted?</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">    <span style="color: #0000aa">end</span></div>

<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">    <span style="color: #0000aa">if</span> success</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">      render <span style="color: #0000aa">json</span>: {</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">        <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&quot;ok&quot;</span>,</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">        auth_token: user.authentication_token</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">      }</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">    <span style="color: #0000aa">else</span></div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">      render <span style="color: #0000aa">json</span>: { <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&quot;failed&quot;</span> }, <span style="color: #0000aa">status</span>: <span style="color: #009999">401</span></div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">    <span style="color: #0000aa">end</span></div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">  <span style="color: #0000aa">end</span></div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;"><span style="color: #0000aa">end</span></div>
</pre>

<br>

在以上的程式碼中，我們透過 `User.get_facebook_user_data` 從 Facebook 取得 `params[:access_token]` 持有者的個人資訊存進 `fb_data` ，透過裡面的資訊判斷目前客戶端的使用者的身份。

接著我們把 auth_hash 當作參數丟進 `User.from_omniauth` 回傳對應的使用者，登入成功。重新執行一次測試，這時候預期會亮起綠燈。

到目前為止，我們已經成功使用 TDD 開發出 email 登入以及 Facebook 登入邏輯。

<br>

### 登出

登入完成之後，接下來是登出。登入的邏輯比較單純，我們只需要重新產生該使用者的 auth_token 就可以達到我們的目的。我們先寫測試：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/controllers/api_v1/auth_spec.rb</span>

it <span style="color: #aa5500">&quot;logout succesfully&quot;</span> <span style="color: #0000aa">do</span>
  user = create(<span style="color: #0000aa">:user</span>, <span style="color: #0000aa">email</span>: <span style="color: #aa5500">&#39;123@gmail.com&#39;</span>, <span style="color: #0000aa">password</span>: <span style="color: #aa5500">&#39;123123&#39;</span>)
  token = user.authentication_token

  post <span style="color: #aa5500">&quot;logout&quot;</span>, <span style="color: #0000aa">parmas</span>: { auth_token: user.authentication_token }

  user.reload
  expect(user.authentication_token).not_to eq(token)
<span style="color: #0000aa">end</span>
</pre>

<br>

接著完成登出功能的撰寫：

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

### 小結

這一章我們透過常見的情境 - Web API 登入登出，搭配前面兩章所學到的 TDD 的技巧做了一個相對來說較為完整的練習。下一章我們會討論外部 API 在測試裡面可能會遇到的問題，以及我們該如何處理。

