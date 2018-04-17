## 測試第三方 API：臉書登入
> 認識測試第三方 API 時會遇到的問題
> 理解如何使用「假造」和「錄製」技巧來測試第三方 API

### 開始前的準備

#### 事前必讀

我們在 Web API 的章節有講解過 Facebook 登入功能的實作，由於等下要示範「假造」和「錄製」，所以不會真的需要把呼叫 Facebook API 的過程都寫好，但是我們假設你已經完成【[OAuth 第三方認證：Facebook 帳號登入](https://lighthouse.alphacamp.co/lessons/236/units/1154)】，並能夠：
- 知道如何取得 FB 提供的 API 金鑰
- 能夠解釋 OmniAuth、Facebook 以及 Devise 之間的關係

#### 準備練習用專案

至於練習用的專案，會需要整合上個單元的登入/登出程式碼，請你先確保上個單元已順利完成，或是可以直接下載[這個專案](https://github.com/ALPHACamp/restaurant-forum-fb-login)來進行練習。

#### 安裝 OmniAuth 套件

準備好專案之後，我們先進行最小必要的功能實作，請你先安裝 OmniAuth 提供的套件:
```ruby
# Gemfile
gem 'omniauth-facebook'
```
```bash
bundle install
```

#### 準備 method 介面

請你在 User model 裡準備以下兩個 method，這兩個 method 是臉書登入流程中需要處理的兩件事情，但我們的重點不在真的去登入，請你理解以下 method 的作用，但只需要準備介面，不需要撰寫方法內容。

```ruby
# app/models/user.rb

def self.get_facebook_user_data(access_token)
  # 需要傳入你在 Facebook for developers 平台上取得的 API Key
  # 使用 API key 向 Facebook 發送 Request，請求回傳使用者的臉書資料
end

def self.from_omniauth(auth_hash)
  # Facebook 回傳的資訊，會再以 Hash 的形式傳入此方法做後續處理
  # 由於 Facebook 回傳資訊未必能和你的資料庫相容，要在這個方法裡制定標準
  # 透過你制定的標準，把 Hash 整理成能和 User model 相容的資料
end
```

### 撰寫「臉書登入」測試

接著我們先撰寫 Facebook 登入的測試，你可以透過閱讀以下測試案例，理解登入臉書的處理程序：

```ruby
# spec/controllers/api_v1/auth_spec.rb

RSpec.describe Api::V1::AuthController, type: :controller do

  it "login via email and password" do
    # skip
  end

  it "login via facebook access_token" do
    # 準備測試資料
    # 產生測試用的 User 物件
    user = create(:user, email: '123@gmail.com', password: '123123')
    # 偽造 FB 的使用者資訊
    fb_data = { "id" => "123", "email" => "123@gmail.com", "name" => "fung" }
    # 偽造 FB 權仗與臉書回傳資料 auth_hash
    fb_access_token = 'blablabla'
    auth_hash = double('OmniAuth::AuthHash')

    # 定義呼叫相關方法後的期待回傳值
    allow(User).to receive(:get_facebook_user_data).with(fb_access_token).and_return(fb_data)

    allow(OmniAuth::AuthHash).to receive(:new).and_return(auth_hash)
    allow(User).to receive(:from_omniauth).with(auth_hash).and_return(user)

    # 以偽造的 FB 權仗發出登入請求，預期登入成功，取得 auth_token
    post "login", params: { access_token: fb_access_token }

    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)).to eq({
      'message' => 'ok',
      'auth_token' => user.authentication_token
    })
  end

  it "logout succesfully" do
    # skip
  end
end
```
以下是程式碼的細部說明：

#### 準備測試資料
測試案例的前半主要是在準備測試資料，我們做了以下事情：
1. **產生測試用的 User 物件**
2. **偽造 FB 的使用者資訊**
準備偽造的臉書資料，在這裡我們假造了 `fb_data` 做為客戶端傳來的權杖，之後將以此進行身份確認的回傳資訊，透過「假造」的技巧，這組偽造資料仍然能通過測試
3. **偽造 FB 權仗與臉書回傳資料 auth_hash**
我們沒有去 Facebook for developers 取得真實的權仗，而是偽造一組假的。至於 `auth_hash` 是臉書的回傳值，理論上會由 `OmniAuth::AuthHash` 函式庫來產生，但測試階段我們不想處理繁瑣的參數，所以直接使用 RSpec 的 `double()` 技巧產生一個 instance 當作替身。

#### 定義呼叫相關方法後的期待回傳值
`allow(A).to receive(B).with(C).and_return(D)` 是表達「預期 A 物件會收到 B 方法與 C 參數，然後 A 物件會回傳 D」，在這個段落裡，我們做了以下三個假設：
1. 預期 User 的 `get_facebook_user_data` 這個 class method 會被呼叫，並回傳我們假造的 `fb_data`；
2. 利用 `OmniAuth::AuthHash` 創建一個該類別下的 instance，並且將回傳的 instance 定義為 auth_hash
3. 假設 User 類別下的 `from_omniauth` 應該會被呼叫，並回傳 `user`。

#### 發出登入請求，預期成功取得 auth_token

最後我們預期使用偽造的 fb_access_token 向 `api/v1/login` 發出 POST 請求，可以成功登入，並取得通過 ApiController 需要的 `auth_token` 參數。

測試寫完以後，你可以先試著執行 `bundle exec rspec`，由於還沒有修改 `api/v1/login`，理應出現 Failure。

### auth#login 整合臉書登入

現在我們需要稍微調整 `ApiV1::AuthController` 裡面的 `login` 的邏輯，試著讓 email 登入與 facebook 登入能夠一起運作，主要的修改邏輯是：
1. 如果傳進來的 request 攜帶的參數不是帳號密碼，而是臉書的權仗，就去呼叫 `User.get_facebook_user_data` 取得臉書資訊；
2. 把臉書資訊整理成 Hash 的形式，送進 `User.from_omniauth` 方法，比對出資料庫中的 User 紀錄。
3. 若成功取得臉書資訊與資料庫的 User 紀錄，就認定可成功登入。

```diff
# app/controllers/api/v1/auth_controller.rb

  def login
    success = false

    if params[:email] && params[:password]
      user = User.find_by_email(params[:email])
      success = user && user.valid_password?(params[:password])
-   end
+   elsif params[:access_token]
+     fb_data = User.get_facebook_user_data(params[:access_token])
+     if fb_data
+         auth_hash = OmniAuth::AuthHash.new({
+           uid: fb_data["id"],
+           info: { email: fb_data["email"] },
+           credentials: {
+            token: params[:access_token],
+            expires_at: Time.now + 60.days
+          }
+         })
+       user = User.from_omniauth(auth_hash)
+     end
+     success = fb_data && user.persisted?
+   end

    if success
      render json: {
        message: "ok",
        auth_token: user.authentication_token
      }
    else
      render json: { message: "failed" }, status: 401
    end
  end
end
```
