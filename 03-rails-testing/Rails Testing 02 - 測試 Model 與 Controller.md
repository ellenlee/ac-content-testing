## 測試 Model 與 Controller
> need add learning outcome

在上個單元，你已經在你的「餐廳論壇」專案裡安裝了 RSpec 的相關環境，接下來，我們會跟隨 TDD 的開發原則，實作一個「關於本站」的頁面，在這個頁面裡會呈現全站統計數據，包括：
1. 全站有多少使用者
2. 全站總共有多少回覆

我們曾經在【[S16 主題論壇：強化功能 > 餐廳 Dashboard - restaurants#dashboard](https://lighthouse.alphacamp.co/units/496)】裡寫過一個 **/dashboard** 頁面，在本單元裡，由於要練習 TDD，我們會特地另外做一個 **/about** 來練習。

### 定義期待結果

#### 構思 API

在一切開始之前，先複習一次 TDD 的流程：
<mark>Ellen's todo: need switch to illustration</mark>
1. 撰寫測試
2. 跑測試（測試未通過）
3. 撰寫程式碼
4. 跑測試（測試通過）

在撰寫 model 相關的測試之前，我們通常會先把需要的情境條列出來，做成一個一個的 API。每一次的轉換需要以下步驟：
1. 思考這個 API 有沒有必要拆解成更小的 API
2. 考慮把 API 放在哪裡
3. 幫這個 API 想一個適合的名字。

對應到我們在上文列出的情境需求，

- **查看全站有多少使用者**：
  - 可以透過 `User.all.size` 得到我們要的資訊，不需要進一步的拆解的必要。
  - 又因為 `User.all.size` 只會被 `User` 資料表影響，所以我會傾向於把此 API 定義成一個類別方法 (class method)，歸類在 `model/user.rb` 裡面。
  - 最後，我打算將此 API 命名為 `get_user_count`。

- **查看某個使用者做過多少回覆**：
  - 這個 API 跟「查看全站有多少使用者」類似，我們可以透過 `user.comments.size` 來達到
  - 同理，定義在 `model/user.rb` 裡面，當成一個實例方法 (instance method)
  - 命名為 `get_comment_count`。

#### 定義路由

我們打算將這個頁面的 route 命名為 **/about**，我們預期呼叫 **/about** 的時候，回傳的 template 裡面帶有**全站使用者的數量**和**全站回覆的數量**的資訊。

這將會需要一組 controller 的測試，我們通常會直接在測試裡面模擬呼叫想測試的路由，然後依據我們的情境設計測試內容。

<mark>Ellen: 需要阿鋒特別 review 這段的潤試有沒有意思跑掉</mark>


### User Model API

#### 查看全站使用者人數

既然是 TDD，顧名思義，我們會先寫測試的程式，首先從 model 的 API 開始，請你在 **spec/model/user_spec.rb** 來撰寫測試案例（目錄與檔案需要手動新增）：

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  it "should count all user" do
    expect(User.get_user_count).to eq(0)
    create(:user)
    expect(User.get_user_count).to eq(1)
  end
end
```
*Path: spec/model/user_spec.rb*

請注意每一個 **\*_spec.rb** 文章的最開頭，都需要加入 `require 'rails_helper'`，來載入針對 Rails 的測試設定。

在這個測試案例中，我們先測試了 User 數量，此時測試環境下的資料庫裡面什麼都沒有，所以可以預期 user 的數量為零。

接著我們透過 FactoryGirl 的 create API 創造一個 user `create(:user)`，呼叫 `create(:user)` 時，就會按我們之前在 `FactoryBot.define` 裡撰寫的設定，產生一個 `User` 物件：

```ruby
FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@gmail.com" }
    password { "12345678" }
    intro { FFaker::Lorem.paragraph }
  end
end
```
*Path: spec/factories/model.rb*

呼叫 `create(:user)` 之後，測試資料庫裡面應該會有只一個 user，我們透過 `expect` 來測試 API 的呼叫結果是不是跟我們預期的一樣，請你以 `bundle exec rspec` 執行測試，預期出現 `1 example, 1 failure`：

![images](images/02-count-user-red.png)

請你仔細閱讀 RSpec 給你的報告，在執行「User should count all user」這個測試案例時，在執行 `expect(User.get_user_count).to eq(0)` 的時候發生錯誤，錯誤原因是沒有定義 `get_user_count` 這個方法。

按照 TDD 的流程，現在我們要來寫 API 程式內容，涉法讓這個案例通過，請你在 `User` model 裡加入 `get_user_count` 方法:

```ruby
def self.get_user_count
  User.all.size
end
```
*Path: model/user.rb*

透過 `User.all.size` 取得資料庫裡面所有的 user 數量，完成之後，重新執行一次測試，應該會出現 `1 example, 1 success`：

![images](images/03-count-user-green.png)

#### 查看全站使用者的回覆數

接著是「查看使用者有過多少回覆」的 API，一樣我們先寫測試，請在剛才的案例下，加入另一個測試案例：

```ruby
RSpec.describe User, type: :model do

  # other examples

  it "should count all comments by this user" do
    user = create(:user)
    expect(user.get_comment_count).to eq(0)
    comment = create(:comment)
    user.comments << comment
    expect(user.get_comment_count).to eq(1)
  end
end
```
*Path: spec/model/user_spec.rb*

首先，透過 `user = create(:user)` 先建立起一個測試用的 user，接著我們用 `expect(user.get_comment_count).to eq(0)` 先確認 comment 為零。再來 `comment = create(:comment)` 建立測試用的 comment，然後把 `user.comments << comment` 讓這個 comment 跟 user 建立關聯，最後用 `expect(user.get_comment_count).to eq(1)` 測試 user 目前的 comment 數量為 1。

透過 `bundle exec rspec` 執行測試，應該會出現 `1 example, 1 failure`。失敗的原因是因為我們在 User 的 model 裡面還沒有定義 `get_comment_count` 這個方法。

![images](images/04-user-comment-red.png)

讓我們回到 User model 完成實作：

```ruby
def get_comment_count
  comments.all.size
end
```
*Path: model/user.rb*

定義完成之後，重新執行一次測試，如果你的 FactoryBot 測試資料設定有誤，可能會在執行 `create(:comment)` 的時候發生錯誤，若是看見此類訊息，請你檢查 **spec/factories/model.rb**：

![images](images/05-user-comment-failure.png)

如果設定沒有問題，預期會出現 `1 example, 1 success`：

![images](images/06-user-comment-green.png)

### controller API

到現在為止，我們還沒有定義 **/about** 的 controller 和 route，一樣我們先從測試開始。

首先我們要開一個專門測試 RestaurantsController 的檔案，命名慣例為 `restaurants_controller_spec.rb`，會歸類在 **spec/controller** 的目錄下，並撰寫以下測試案例：

```ruby
require 'rails_helper'

RSpec.describe RestaurantsController, type: :controller do
  describe "GET dashboard" do
    it "check we have user count info in view template" do
      # part 1
      sign_in(create(:user))
      user_count = rand(20..100)
      allow(User).to receive(:get_user_count).and_return(user_count)

      # part 2
      get :about
      expect(assigns(:user_count)).to eq(user_count)
      expect(response.body).to have_content("There are totally #{user_count} users in this website.")
    end
  end
end
```
*Path: spec/controller/restaurants_controller_spec.rb*

我們定義了一個 describe 區塊來分類同一個 controller 下面不同的 action，這部分的命名則使用 http verb 搭配上 action name，在這個例子裡面就是 `GET dashboard`。

接著我們正式進入測試的程式碼。在 controller 這個階段我們主要會測試兩件事:

1. 變數有確實被 assign
2. template 的內容含有我們想要的結果

而整個測試的過程會被分成兩個部分:

1. 準備變數
2. 測試

#### 準備變數

關於準備工作，考慮到這是一個需要登入的路徑，我們需要先創造一個使用者並且用這個使用者的身份登入，也就是 `sign_in(create(:user))`。由於 `sign_in` 是 Devise 提供的方法，需要在 **spec/rails_helper.rb** 裡引入：

<mark> Ellen: 要和阿鋒確認程式碼</mark>

接著我們要偽造 `get_user_count` 的回傳結果，原因是我們在上一個 model 的例子裡面已經寫過它的測試，所以我們可以相信 `get_user_count` 回傳的結果。而為了保持測試是一個獨立的單元，我們希望盡量不要讓其他因素影響到這個測試，所以我們會用偽造的方式處理。

所謂「偽造的方式」，就是透過 `user_count = rand(20..100)` 來偽造使用者的人數，並且用 `allow(User).to receive(:get_user_count).and_return(user_count)` 嘗試偽造 `get_user_count` 的結果。

#### 測試

準備完之後，就可以正式開始測試了！

首先，用 `get :dashboard` 讓 RSpec 模擬呼叫路徑的情形，然候我們就可以開始檢視我們的假設跟實際狀況是不是吻合：
- `expect(assigns(:user_count)).to eq(user_count)`，用來檢視 action 裡面的 `@user_count` 這個變數跟我們偽造的值是不是一樣；
- `expect(response).to have_content("There are totally #{user_count} users in this website.")` 判斷對應的 template 頁面上有沒有我們預期的字串。

此時我們還沒有在 controller 裡面加上對應的程式，但我們先執行測試看看，你可以在指令後加上檔名，只跑單一檔案的測試，來提高效率：

```bash
[~/restaurant_forum] $ bundle exec rspec ./spec/controller/restaurants_controller_spec.rb
```

預期會出現 `1 example, 1 failure`，表示該測試不通過，因為根本就還沒有實作路由和 controller action：

![images](images/07-get-dashboard-red.png)

讓我們加上對應的路由：
```ruby
collection do
  get :about
end
```
*Path: config/routes.rb*

以及到 RestaurantsController 裡補上對應的方法：

```ruby
# GET restaurats/about
def about
  @user_count = User.get_user_count
end
```
*Path: app/controllers/restaurants_controller.rb*

補上之後，再跑一次測試看看，應該會發現還是沒有通過。原因是我們沒有在 view 裡面加上我們要顯示的資訊：

![images](images/08.png)

讓我們建立一個 template，把指定的變數放進去：

```
<div>There are totally <%= @user_count %> users in this website.</div>
```
*Path: views/restaurants/dashboard.html.erb*

這個時候再跑一次 `bundle exec rspec` 會發現順利通過：

<mark>Ellen: 事實上這裡遇到各種困難，不成功～</mark>

![images](images/09.png)

恭喜你！TDD 開發成功！

這一章用比較基礎的功能當作範例，目的是要讓大家熟習在 Rails 裡面開發 TDD 的感覺，拆解 API 和命名其實是很主觀的，如果你有想到什麼更好的拆解方式或是命名方式，請多上討論區跟同學們分享與討論。下一張章我們將會討論加入 Facebook 的 API 之後，應該要怎麼在測試裡面處理這類型的情境。
