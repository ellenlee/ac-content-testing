>**學習成果與目標**
>・能夠撰寫測試確保 controller action 的預期流程
>・能夠撰寫測試確保 controller action 的指定變數
>・能夠撰寫測試確保 template 的必要資訊

<hr style="border-top: 2px solid #eee">

延續著上個單元，到現在為止，我們還沒有定義 **/about** 的 controller action，按照 TDD 的開發流程，一樣我們先從測試開始。

<br>

### 撰寫測試

首先我們要開一個專門測試 RestaurantsController 的檔案，命名慣例為 `restaurants_controller_spec.rb`，會歸類在 **spec/controllers** 的目錄下，並撰寫以下測試案例：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #00aaaa">require</span> <span style="color: #aa5500">&#39;rails_helper&#39;</span>

<span style="color: #aa0000">RSpec</span>.describe <span style="color: #aa0000">RestaurantsController</span>, <span style="color: #0000aa">type</span>: <span style="color: #0000aa">:controller</span> <span style="color: #0000aa">do</span>
  render_views

  describe <span style="color: #aa5500">&quot;GET about&quot;</span> <span style="color: #0000aa">do</span>
    it <span style="color: #aa5500">&quot;check we have user count info in view template&quot;</span> <span style="color: #0000aa">do</span>
      <span style="color: #aaaaaa; font-style: italic"># 準備變數</span>
      sign_in(create(<span style="color: #0000aa">:user</span>))
      user_count = <span style="color: #00aaaa">rand</span>(<span style="color: #009999">20</span>..<span style="color: #009999">100</span>)
      allow(<span style="color: #aa0000">User</span>).to receive(<span style="color: #0000aa">:get_user_count</span>).and_return(user_count)

      <span style="color: #aaaaaa; font-style: italic"># 測試</span>
      get <span style="color: #0000aa">:about</span>
      expect(assigns(<span style="color: #0000aa">:user_count</span>)).to eq(user_count)
      expect(response.body).to have_content(<span style="color: #aa5500">&quot;There are totally #{</span>user_count<span style="color: #aa5500">} users in this website.&quot;</span>)
    <span style="color: #0000aa">end</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<span style="font-style: italic;color: #999;">Path: spec/controllers/restaurants_controller_spec.rb</span>

<br>

我們定義了一個 describe 區塊來分類同一個 controller 下面不同的 action，這部分的命名則使用 http verb 搭配上 action name，在這個例子裡面就是 `GET about`。

需要注意的是，在 RSpec 的架構裡，執行 controller action 時不會自動 render view，在想要測試 template 內容時，需要手動加上 `render_views`。

接著我們正式進入測試的程式碼。在 controller 這個階段我們主要會測試兩件事：

1. 變數有確實被 assign
2. template 的內容含有我們想要的結果

因此，整個測試的過程會被分成兩個部分：

1. 準備變數
2. 測試

<br>

#### 準備變數

考慮到這是一個需要登入的路徑，我們需要先創造一個使用者，並且用這個使用者的身份登入，也就是 `sign_in(create(:user))`。之前我已經在 **spec/rails_helper.rb** 裡引入了 Devise，所以可以使用 Devise 提供的 `sign_in` 方法。

接著我們要偽造 `get_user_count` 的回傳結果，原因是我們在上一個 model 的例子裡面已經寫過它的測試，所以我們可以相信 `get_user_count` 回傳的結果。為了保持測試是一個獨立的單元，我們希望盡量不要讓其他因素影響到這個測試，所以我們會用偽造的方式處理。

所謂「偽造的方式」，就是透過 `user_count = rand(20..100)` 來偽造使用者的人數，並且用 `allow(User).to receive(:get_user_count).and_return(user_count)` 嘗試偽造 `get_user_count` 的結果。

`allow(A).to receive(B).with(C).and_return(D)` 是表達「預期 A 物件會收到 B 方法與 C 參數，然後 A 物件會回傳 D」。

<br>

#### 測試

準備完之後，就可以正式開始測試了！

首先，用 `get :about` 讓 RSpec 模擬呼叫路徑的情形，然候我們就可以開始檢視我們的假設跟實際狀況是不是吻合：

* `expect(assigns(:user_count)).to eq(user_count)`，用來檢視 action 裡面的 `@user_count` 這個變數跟我們偽造的值是不是一樣；
* `expect(response.body).to have_content("There are totally #{user_count} users in this website.")` 判斷對應的 template 頁面上有沒有我們預期的字串。

此時我們還沒有在 controller 裡面加上對應的程式，但我們先執行測試看看，你可以在指令後加上檔名，只跑單一檔案的測試，來提高效率：

<div class='terminal-block'>
  <div class='terminal-block-head'>Terminal</div>
  <div class='terminal-block-body'>
    <div class='terminal-code-line'>
      <span class='terminal-path'>[~/restaurant_forum] </span><span class='terminal-command'>$ bundle exec rspec ./spec/controllers/restaurants_controller_spec.rb</span>
    </div>
  </div>
</div>

<br>

預期會出現 failure，表示該測試不通過，失敗原因是找不到 `user_count` 的值，然而因為根本就還沒有 controller action，所以自然也測不到該變數值：

<div style="width:100%"> <img style="max-width:800px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2534/07-get-red.png"></div>

<br>

### 撰寫功能

現在我們到 RestaurantsController 裡補上對應的方法：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># GET restaurats/about</span>
<span style="color: #0000aa">def</span> <span style="color: #00aa00">about</span>
  <span style="color: #aa0000">@user_count</span> = <span style="color: #aa0000">User</span>.get_user_count
<span style="color: #0000aa">end</span>
</pre>

<span style="font-style: italic;color: #999;">Path: app/controllers/restaurants_controller.rb</span>

<br>

補上之後，再跑一次測試看看，應該會發現還是沒有通過。原因是我們沒有在 view 裡面加上我們要顯示的資訊：

<div style="width:100%"> <img style="max-width:800px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2535/08-get-about-red.png"></div>

<br>

讓我們建立一個 template，把指定的變數放進去：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #1e90ff; font-weight: bold">&lt;div&gt;</span>There are totally <span style="color: #4c8317">&lt;%=</span> <span style="color: #aa0000">@user_count</span> <span style="color: #4c8317">%&gt;</span> users in this website.<span style="color: #1e90ff; font-weight: bold">&lt;/div&gt;</span>
</pre>

<span style="font-style: italic;color: #999;">Path: views/restaurants/about.html.erb</span>

<br>

這個時候再跑一次 `bundle exec rspec` 會發現順利通過：

<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2536/09-get-about-green.png"></div>

<br>

恭喜你開發成功！

希望經過以上的命名，你已經熟悉在 Rails 裡面搭配 RSpec 測試框架開發的感覺，拆解 API 和命名其實是很主觀的，如果你有想到什麼更好的拆解方式或是命名方式，請多上討論區跟同學們分享與討論。

<br>

### Recap

下個單元開始，我們會針對 Web API 的情境，討論如何測試以及相關技巧。在進入新主題之前，在此先總結一下目前的學習，目前我們用了較簡單的例子去示範 model 和 controller 測試，希望能讓同學熟悉在 Rails 裡寫測試的手感。

接下來重要的就是鼓勵同學回到自己的專案裡去寫測試，一開始的重點不是追求測試覆蓋率，建議的起手點如下：

* 從習慣寫 model spec 開始，因為粒度最小、也最重要
* 測試你最擔心出錯的部分，把以前手動去檢查的行為，改成寫測試去檢查
* 開發時遇到 bug 時，撰寫單元測試來揭發該 bug，再進行 debug

建議可以先瀏覽一輪 [rspec-rails 文件](https://github.com/rspec/rspec-rails#contributing)，掌握可能的寫法，需要用到時再 Google 查詢，常用的有兩個參考資源：

* rspec-rails 文件：https://github.com/rspec/rspec-rails#contributing
* Relish：https://relishapp.com/rspec/rspec-rails/v/3-7/docs/matchers

<br>

### 參考程式碼

| Commit | GitHub |
|:----- | :----- |
| GET about check we have user count info in view template | [LINK](https://github.com/ALPHACamp/restaurant-forum-testing/commit/dc1325114726a5dfa553e8ce83e72510be8de9c0) |
