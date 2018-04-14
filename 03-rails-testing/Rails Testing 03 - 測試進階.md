<hr>

上一章我們一起練習了許多基礎的 RSpec 的方法，結合 TDD 一步步開發餐廳 app 的場景。這一章會展示如何用 TDD 的流程開發登入登出的 API，透過這個比較完整的應用，讓大家能夠更完整體驗 TDD 可能的應用方式。

<br>

### 登入 / 登出 API 概要

了解運作機制之後，我們先把這次的目標列出來，也就是 `api_v1/login` 以及 `api_v1/logout` 這兩隻 API。接著我們先了解登入的邏輯，可能的情境有兩種:

1. 使用者使用 email 登入，確認從客戶端來的帳號和密碼無誤後，回傳使用者認證碼
2. 使用者使用 Facebook 登入，透過 Facebook 個人資料 API 確認從客戶端帶來的 Facebook 權杖有效並取回個人資訊。如果個人資訊尚未登陸資料庫，則建立新的使用者，並回傳使用者認證碼。如果個人資訊已經存在於資料庫，則找到該名使用者並回傳使用者認證碼。

登出的情境就相對來說單純許多，只需要重設使用者認證碼，這樣下次客戶端帶舊的認證碼來的時候就找不到使用者了。

<br>

### TDD 開發登入

首先我們嘗試撰寫 email 登入的測試:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/controller/api_v1/auth_spec.rb</span>

it <span style="color: #aa5500">&quot;login via email and password&quot;</span> <span style="color: #0000aa">do</span>
  user = create(<span style="color: #0000aa">:user</span>, <span style="color: #0000aa">email</span>: <span style="color: #aa5500">&#39;123@gmail.com&#39;</span>, <span style="color: #0000aa">password</span>: <span style="color: #aa5500">&#39;123123&#39;</span>)
  post <span style="color: #aa5500">&quot;login&quot;</span>, <span style="color: #0000aa">params</span>: { <span style="color: #0000aa">email</span>: user.email, <span style="color: #0000aa">password</span>: <span style="color: #aa5500">&#39;123123&#39;</span> }
  
  expect(response).to have_http_status(<span style="color: #009999">200</span>)
  expect(<span style="color: #aa0000">JSON</span>.parse(response.body)).to eq({
    <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&#39;ok&#39;</span>,
    auth_token: user.auth_token,
  })
<span style="color: #0000aa">end</span>
</pre>

<br>

我們建立一個使用者，然後用這個使用者的帳號密碼當作參數去呼叫 `api/v1/login`，預期 response status 為 200，而 response body 應該會帶有使用者認證碼的相關資訊。這個時候透過 `bundle exec rspec` 執行測試，應該會出現 `1 example, 1 failure`
。接下來我們要開始撰寫 `ApiV1::AuthController` 裡面的 `login` 行為，試著讓測試通過:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># controllers/api_v1/auth_controller.rb</span>

...
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
</pre>

<br>

重新執行一次測試，應該會出現 `1 example, 1 success`，到目前為止已經完成 email 登入功能。接著我們試著加上 Facebook 登入的功能，先撰寫測試的部分:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/controller/api_v1/auth_spec.rb</span>

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
  expect(response.body).to eq({
    <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&#39;ok&#39;</span>,
    auth_token: user.authentication_token,
  })
<span style="color: #0000aa">end</span>
</pre>

<br>

假造 `fb_data` 做為我們透過客戶端來的權杖進行身份確認的回傳資訊，接著偽造 `fb_access_token`。在這邊我們要做三個假設，第一個是我們預期 User 的 `get_facebook_user_data` 這個 class method 會被呼叫，並回傳我們假造的 `fb_data`，第二是我們會利用 `OmniAuth::AuthHash` 產生一個該類別下的 instance，並且回傳該 instance 定義為 auth_hash。最後，User 類別下的 `from_omniauth` 應該會被呼叫並回傳該使用者。此時，透過 `bundle exec rspec` 執行測試，應該會出現 `2 example, 1 failure`。接著我們要稍微調整 `ApiV1::AuthController` 裡面的 `login` 的邏輯，試著讓 email 登入與 facebook 登入能夠一起運作:

<pre style="background:#f9f9f9;color:#080808"><div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;"><span style="color: #aaaaaa; font-style: italic"># controllers/api_v1/auth_controller.rb</span></div>

<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">...</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;"><span style="color: #0000aa">def</span> <span style="color: #00aa00">login</span></div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">  success = <span style="color: #0000aa">false</span></div>
  
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">  <span style="color: #0000aa">if</span> params[<span style="color: #0000aa">:email</span>] &amp;&amp; params[<span style="color: #0000aa">:password</span>]</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">    user = <span style="color: #aa0000">User</span>.find_by_email(params[<span style="color: #0000aa">:email</span>])</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">    success = user &amp;&amp; user.valid_password?(params[<span style="color: #0000aa">:password</span>])</div>
<div style="background: #ffdce0;color: #cb2431;display: inline-block;width: 3%;padding: 0 5px;">-</div><div style="background: #ffeef0;display: inline-block;width: 97%;padding-left: 5px;">  <span style="color: #0000aa">end</span></div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">  <span style="color: #0000aa">elsif</span> params[<span style="color: #0000aa">:access_token</span>]</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">    fb_data = <span style="color: #aa0000">User</span>.get_facebook_user_data(params[<span style="color: #0000aa">:access_token</span>])</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">    <span style="color: #0000aa">if</span> fb_data</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">      auth_hash = <span style="color: #0000aa">OmniAuth</span>:<span style="color: #0000aa">:AuthHash</span>.new({</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">        <span style="color: #0000aa">uid</span>: fb_data[<span style="color: #aa5500">&quot;id&quot;</span>],</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">        <span style="color: #0000aa">info</span>: {</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">          <span style="color: #0000aa">email</span>: fb_data[<span style="color: #aa5500">&quot;email&quot;</span>]</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">        },</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">        <span style="color: #0000aa">credentials</span>: {</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">          <span style="color: #0000aa">token</span>: params[<span style="color: #0000aa">:access_token</span>],</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">          expires_at: <span style="color: #aa0000">Time</span>.now + <span style="color: #009999">60</span>.days</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">        }</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">      })</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">      user = <span style="color: #aa0000">User</span>.from_omniauth(auth_hash)</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">    <span style="color: #0000aa">end</span></div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">    success = fb_data &amp;&amp; user.persisted?</div>
<div style="background: #cdffd8;color: #2cbe4e;display: inline-block;width: 3%;padding: 0 5px;">+</div><div style="background: #e6ffed;display: inline-block;width: 97%;padding-left: 5px;">  <span style="color: #0000aa">end</span></div>

<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">  <span style="color: #0000aa">if</span> success</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">    render <span style="color: #0000aa">json</span>: {</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">      <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&quot;ok&quot;</span>,</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">      auth_token: user.authentication_token</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">    }</div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">  <span style="color: #0000aa">else</span></div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">    render <span style="color: #0000aa">json</span>: { <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&quot;failed&quot;</span> }, <span style="color: #0000aa">status</span>: <span style="color: #009999">401</span></div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;">  <span style="color: #0000aa">end</span></div>
<div style="display: inline-block;width: 3%;padding: 0 5px;">&ensp;</div><div style="display: inline-block;width: 97%;padding-left: 5px;"><span style="color: #0000aa">end</span></div>
</pre>

<br>

我們透過 `User.get_facebook_user_data` 從 Facebook 取得 `params[:access_token]` 持有者的個人資訊存進 `fb_data` ，透過裡面的資訊判斷目前客戶端的使用者的身份。接著我們把 auth_hash 當作參數丟進 `User.from_omniauth` 回傳對應的使用者，登入成功。重新執行一次測試，應該會出現 `2 example, 2 success`。到目前為止，我們已經成功使用 TDD 開發出 email 登入以及 Facebook 登入邏輯。

<br>

### TDD 開發登出

登入完成之後，接下來是登入。登入的邏輯比較單純，我們只需要重新產生該使用者的 auth_token 就可以達到我們的目的。我們先從測試出發:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># spec/controller/api_v1/auth_spec.rb</span>

it <span style="color: #aa5500">&quot;logout succesfully&quot;</span> <span style="color: #0000aa">do</span>
  user = create(<span style="color: #0000aa">:user</span>, <span style="color: #0000aa">email</span>: <span style="color: #aa5500">&#39;123@gmail.com&#39;</span>, <span style="color: #0000aa">password</span>: <span style="color: #aa5500">&#39;123123&#39;</span>)
  token = user.authentication_token
  
  post <span style="color: #aa5500">&quot;logout&quot;</span>, <span style="color: #0000aa">parmas</span>: { auth_token: user.authentication_token }
  
  user.reload
  expect(user.authentication_token).not_to eq(token)
<span style="color: #0000aa">end</span>
</pre>

<br>

接著完成登出功能的撰寫:

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># controllers/api_v1/auth_controller.rb</span>

<span style="color: #0000aa">def</span> <span style="color: #00aa00">logout</span>
  current_user.generate_authentication_token
  current_user.save!

  render <span style="color: #0000aa">json</span>: { <span style="color: #0000aa">message</span>: <span style="color: #aa5500">&quot;ok&quot;</span> }
<span style="color: #0000aa">end</span>
</pre>

<br>

### 小結

這一章我們透過常見的情境 - Web API登入登出，搭配前面兩章所學到的 TDD 的技巧做了一個相對來說較為完整的練習。下一章我們會討論外部 API 在測試裡面可能會遇到的問題，以及我們該如何處理。