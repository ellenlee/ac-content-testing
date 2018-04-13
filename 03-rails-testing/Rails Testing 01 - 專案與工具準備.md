> **學習成果與目標**
>・認識實務上會和 RSpec 搭配的套件如 FactoryBot 和 Shoulda-matchers

<hr style="border-top: 2px solid #eee">

在之前 TDD 相關的單元裡面，我們已經蠻詳盡的介紹 TDD 的用法和好處，也圍繞著冷氣遙控器舉了幾個例子。在接下來的幾個單元，我們會針對 Rails 討論測試的概念，並且搭配實務工具來撰寫測試。

在這個單元裡，我們會先介紹實務上常用的工具如 FactoryBot 和 Shoulda-matchers，這些工具的目的是幫助工程師能更加方便地撰寫、維護測試，請你先把工具安裝好，至於工具的使用方法和細節，之後會一邊實作、一邊展示。

<br>

### 專案準備：餐廳論壇

本課程的展示，會以你之前完成的「餐廳論壇」為出發點，教你怎麼把既有的功能加上測試。

你可以選擇下載[我們準備的示範專案](https://github.com/ALPHACamp/restaurant-forum-testing)，也可以選擇打開你自己的專案成果。

<br>

### 安裝 RSpec

在正式開始之前，我們需要安裝一些需要的工具，加速我們撰寫測試的過程。

首先是 RSpec，在整合到 Ruby on Rails 時，我們會使用 [rspec-rails](https://github.com/rspec/rspec-rails) 這個 gem，請注意要加在 `:development, :test` 的群組裡，來和正式 production 的環境做區分：

<pre style="background:#f9f9f9;color:#080808">group <span style="color: #0000aa">:development</span>, <span style="color: #0000aa">:test</span> <span style="color: #0000aa">do</span>
  gem <span style="color: #aa5500">&#39;rspec-rails&#39;</span>, <span style="color: #aa5500">&#39;~&gt; 3.6&#39;</span>
<span style="color: #0000aa">end</span>
</pre>

<span style="font-style: italic;color: #999">Path: Gemfile</span>


<br>

然後執行：

<div class='terminal-block'>
  <div class='terminal-block-head'>Terminal</div>
  <div class='terminal-block-body'>
    <div class='terminal-code-line'>
      <span class='terminal-path'>[~/restaurant_forum]</span><span class='terminal-command'> $ bundle install</span>
    </div>
  </div>
</div>

<br>

接著要幫專案初始化 RSpec：

<div class='terminal-block'>
  <div class='terminal-block-head'>Terminal</div>
  <div class='terminal-block-body'>
    <div class='terminal-code-line'>
      <span class='terminal-path'>[~/restaurant_forum]</span><span class='terminal-command'> $ bundle exec rails generate rspec:install
    </div>
  </div>
</div>

<br>

這個指令會幫你安裝三個設定檔：

* **.rspec**: 你可以把常用的參數加到這個檔案裡面。舉例來說，如果你想顯示來自 Ruby 的 warning，你可以在檔案裡面加上一行 `--warnings`，這樣之後每次在跑 `bundle exec rspec` 的時候就會自動帶上這個參數。你可以透過 `rspec -h` 這個指令看到所有的參數。
* **spec/rails_helper.rb**: 我們會在這裡撰寫跟 Rails 相關的內容。舉例來說，在測試開始跑之前，導入自定義的 matcher 檔案。
* **spec/spec_helper.rb**: 我們會在這裡撰寫跟 RSpec 本身設定有關的內容。舉例來說，調整 `rspec-mock` 或是 `rspec-expectation` 的設定。

透過 rspec 的指令看看安裝有沒有成功

<div class='terminal-block'>
  <div class='terminal-block-head'>Terminal</div>
  <div class='terminal-block-body'>
    <div class='terminal-code-line'>
      <span class='terminal-path'>[~/restaurant_forum]</span><span class='terminal-command'> $ bundle exec rspec
    </div>
  </div>
</div>

<br>

順利的話會看到下面的畫面：

<div style="width:100%"> <img style="max-width:800px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2524/01-install-check.png"></div>

<br>

### 安裝 FactoryBot

撰寫測試時，由於每個 `it` 是獨立的，因此每次都要重新建立測試用的假資料，你現在已經知道可以用 `before` 的方法來做一次性的宣告。然而，當 Model 之間的關聯變得複雜時，資料建置就會愈來愈麻煩。因此，實務上會搭配 FactoryBot 這個函式庫，用來快速產生假資料，可以省下很多準備資料的時間。

（FactoryBot 原名為 FactoryGirl，已於 2017 年底更名為 FactoryBot，由於更名不久，絕大多數網路資料仍稱其 FactoryGirl，請同學查詢資料時特別注意。）

以下按照 FactoryBot 提供的[說明文件](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md)，講解安裝步驟。

首先安裝 [factory_bot_rails](https://github.com/thoughtbot/factory_bot_rails) ：

<pre style="background:#f9f9f9;color:#080808">group <span style="color: #0000aa">:development</span>, <span style="color: #0000aa">:test</span> <span style="color: #0000aa">do</span>
  gem <span style="color: #aa5500">&quot;factory_bot_rails&quot;</span>, <span style="color: #aa5500">&quot;~&gt; 4.0&quot;</span>
<span style="color: #0000aa">end</span>
</pre>
<span style="font-style: italic;color: #999">Path: Gemfile</span>

<br>


<div class='terminal-block'>
    <div class='terminal-block-head'>Terminal</div>
    <div class='terminal-block-body'>
        <div class='terminal-code-line'>
            <span class='terminal-path'>[~/restaurant_forum]</span><span class='terminal-command'> $ bundle install</span>
        </div>
    </div>
</div>
<br>

接著請你建立一個 **spec/support/factory_bot.rb** 檔案，加入 FactoryBot 的設定：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aa0000">RSpec</span>.configure <span style="color: #0000aa">do</span> |config|
  config.include <span style="color: #0000aa">FactoryBot</span>:<span style="color: #0000aa">:Syntax</span>::<span style="color: #aa0000">Methods</span>
<span style="color: #0000aa">end</span>
</pre>

<span style="font-style: italic;color: #999">Path: spec/support/factory_bot.rb</span>

<br>

然後記得到 **spec/rails_helper.rb** 檔案上方載入你剛才新建的設定檔：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># 預設載入的設定</span>
<span style="color: #aaaaaa; font-style: italic"># Add additional requires below this line. Rails is not loaded until this point!</span>
<span style="color: #00aaaa">require</span> <span style="color: #aa5500">&#39;support/factory_bot&#39;</span>
</pre>

<span style="font-style: italic;color: #999">Path: spec/rails_helper.rb</span>

<br>

安裝完成之後，你就可以針對目標 model 新增相對應的設定檔，請你建立一個檔案 `spec/factories/model.rb`，用來存放和 model 相關的設定檔。並且參考你之前在「餐廳專案」定義的假資料，搭配 FactoryBot 的[語法說明](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#configure-your-test-suite)，完成測試需要的資料內容，如下：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aa0000">FactoryBot</span>.define <span style="color: #0000aa">do</span>
  factory <span style="color: #0000aa">:user</span> <span style="color: #0000aa">do</span>
    sequence(<span style="color: #0000aa">:name</span>) { |n| <span style="color: #aa5500">&quot;user#{</span>n<span style="color: #aa5500">}&quot;</span> }
    sequence(<span style="color: #0000aa">:email</span>) { |n| <span style="color: #aa5500">&quot;user#{</span>n<span style="color: #aa5500">}@gmail.com&quot;</span> }
    password { <span style="color: #aa5500">&quot;12345678&quot;</span> }
    intro { <span style="color: #0000aa">FFaker</span>:<span style="color: #0000aa">:Lorem</span>.paragraph }
  <span style="color: #0000aa">end</span>

  factory <span style="color: #0000aa">:category</span> <span style="color: #0000aa">do</span>
    sequence(<span style="color: #0000aa">:name</span>) { |n| <span style="color: #aa5500">&quot;category#{</span>n<span style="color: #aa5500">}&quot;</span> }
  <span style="color: #0000aa">end</span>

  factory <span style="color: #0000aa">:restaurant</span> <span style="color: #0000aa">do</span>
    sequence(<span style="color: #0000aa">:name</span>) { |n| <span style="color: #aa5500">&quot;restaurant#{</span>n<span style="color: #aa5500">}&quot;</span> }
    opening_hours { <span style="color: #0000aa">FFaker</span>:<span style="color: #0000aa">:Time</span>.datetime }
    tel { <span style="color: #0000aa">FFaker</span>:<span style="color: #0000aa">:PhoneNumber</span>.short_phone_number }
    address { <span style="color: #0000aa">FFaker</span>:<span style="color: #0000aa">:Address</span>.street_address }
    description { <span style="color: #0000aa">FFaker</span>:<span style="color: #0000aa">:Lorem</span>.paragraph }
    category
  <span style="color: #0000aa">end</span>

  factory <span style="color: #0000aa">:comment</span> <span style="color: #0000aa">do</span>
    content { <span style="color: #0000aa">FFaker</span>:<span style="color: #0000aa">:Lorem</span>.sentence }
    user
    restaurant
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<span style="font-style: italic;color: #999">Path: spec/factories/model.rb</span>

<br>

在這裡我們沿用了專案[稍早安裝](https://lighthouse.alphacamp.co/units/426)的 [FFaker](https://github.com/ffaker/ffaker) 套件來產生亂數資料。做好以上設定之後，之後就可以在測試裡面透過類似 `Factory.create(:user)` 的 API 來幫我們建立新的 user，加速開發的流程。

<br>

### 安裝 Shoulda-matchers

[Shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers) 是一個 RSpec 的補充包，裡面針對 `ActiveModel`、`ActiveRecord` 和 `ActionController` 的設定提供了方便的 API 來進行測試。

安裝 shoulda-matchers：

<pre style="background:#f9f9f9;color:#080808">group <span style="color: #0000aa">:development</span>, <span style="color: #0000aa">:test</span> <span style="color: #0000aa">do</span>
  gem <span style="color: #aa5500">&#39;shoulda-matchers&#39;</span>, <span style="color: #aa5500">&#39;~&gt; 3.1&#39;</span>
<span style="color: #0000aa">end</span>
</pre>

<span style="font-style: italic;color: #999">Path: Gemfile</span>

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


在 `spec/rails_helper.rb` 的檔案最下方新增設定：

<pre style="background:#f9f9f9;color:#080808">Shoulda</span>:<span style="color: #0000aa">:Matchers</span>.configure <span style="color: #0000aa">do</span> |config|
  config.integrate <span style="color: #0000aa">do</span> |with|
    with.test_framework <span style="color: #0000aa">:rspec</span>
    with.library <span style="color: #0000aa">:active_record</span>
    with.library <span style="color: #0000aa">:active_model</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<span style="font-style: italic;color: #999">Path: spec/rails_helper.rb</span>

<br>


現在你可以使用更直覺的方式做測試，像是測試 user.name 的 validation：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aa0000">RSpec</span>.describe <span style="color: #aa0000">User</span>, <span style="color: #0000aa">type</span>: <span style="color: #0000aa">:model</span> <span style="color: #0000aa">do</span>
  it { should validate_presence_of(<span style="color: #0000aa">:name</span>) }
<span style="color: #0000aa">end</span>
</pre>

<br>

或是測試兩個 model 之間的關聯：

<pre style="background:#f9f9f9;color:#080808">
<span style="color: #aa0000">RSpec</span>.describe <span style="color: #aa0000">User</span>, <span style="color: #0000aa">type</span>: <span style="color: #0000aa">:model</span> <span style="color: #0000aa">do</span>
  it { should have_many(<span style="color: #0000aa">:restaurants</span>) }
<span style="color: #0000aa">end</span>
</pre>

<br>

現在我們裝好了寫測試的工具，接下來要進入實作了！

<br>

<div style="background: #fbec9c; padding: 15px; border-radius: 10px">
    <h5><strong>延伸閱讀</strong></h5>
    
    <h5>本章節介紹的測試工具都有各自的語法，在你需要客製化設定時，就需要到以下的專案文件內查詢：</h5>
    <ul>
        <li>RSpec：<a href="http://rspec.info/documentation/" target="_blank">http://rspec.info/documentation/</a></li>
        <li>FactoryBot：<a href="https://github.com/thoughtbot/factory_bot_rails" target="_blank">https://github.com/thoughtbot/factory_bot_rails</a></li>
        <li>Shoulda-matchers：<a href="https://github.com/thoughtbot/shoulda-matchers" target="_blank">https://github.com/thoughtbot/shoulda-matchers</a></li>
    </ul>
</div>

<br>

### 參考程式碼

|Commit Message|GitHub Link|
|:------|:------|
|install RSpec|[LINK]()|
|install FactoryBot|[LINK]()|
|install Shoulda-matchers|[LINK]()|
