> **學習成果與目標**
>・能夠使用 RSpec 指令創建與執行測試程式 能夠使用 RSpec 語法撰寫測試案例

<hr style="border-top: 2px solid #eee">

你已經快速體驗了 RSpec 的妙用，也透練習熟悉了 RSpec 的基本語法，本單元會對 RSpec 進行更詳盡的說明與補充。

### RSpec

[RSpec](https://github.com/rspec/rspec) 是 2010 年推出的 Rails 測試框架，以清楚、語義化的撰寫方式和好用的 API 活躍於 Rails 社群，RSpec 框架有四個主要的函式庫：

- rspec-core：提供 Rspec CLI 指令，透過指令產出具彈性且可以客製化的測試報告，並提供對應 API 來管理測試案例
- rspec-expectations：提供方便閱讀的 API 來檢測實際結果與預期結果
- rspec-mocks：提供多種 mock 工具讓你方便模擬各種物件，從而輕鬆控制各種測試環境的變數
- rspec-rails：提供讓上述函式庫整合進 Ruby on Rails 框架的函式庫

<br>

### RSpec 指令

安裝 RSpec：

<div class='terminal-block'>
  <div class='terminal-block-head'>Terminal</div>
  <div class='terminal-block-body'>
    <div class='terminal-code-line'>
      <span class='terminal-path'>[~]</span><span class='terminal-command'> $ gem install rspec</span>
    </div>
  </div>
</div>

<br>

要設定 RSpec 的產出格式需要 **.rspec** 檔，你可以手動創建一個，或使用指令創建 .rspec 檔：

<div class='terminal-block'>
  <div class='terminal-block-head'>Terminal</div>
  <div class='terminal-block-body'>
    <div class='terminal-code-line'>
    <span class='terminal-path'>[~]</span><span class='terminal-command'> $ rspec --init</span>
      </div>
  </div>
</div>

<br>

**.rspec** 檔主要是讓我們在使用 `rspec` 指令執行測試程式時，帶入**.rspec** 檔內的設定作為副指令，如：

 * `--format documentation`：產出更詳盡的分類和測試案例
 * `--color`：產出結果用顏色區分

若你想認識更多的 rspec 副指令，可用 `--help` 查詢：

<div class='terminal-block'>
  <div class='terminal-block-head'>Terminal</div>
  <div class='terminal-block-body'>
    <div class='terminal-code-line'>
      <span class='terminal-path'>[~] </span><span class='terminal-command'>$ rspec  --help</span>
      </div>
  </div>
</div>

<br>


執行測試程式：

<div class='terminal-block'>
    <div class='terminal-block-head'>Terminal</div>
    <div class='terminal-block-body'>
        <div class='terminal-code-line'>
            <span class='terminal-path'>[~] </span><span class='terminal-command'>$ rspec filename</span>
        </div>
    </div>
</div>

<br>

### RSpec 資料夾結構

在使用 RSpec 測試 Ruby 程式時，通常會開一個專案資料夾，在裡面建立不同的資料夾管理不同目的的檔案：

 * <strong>lib</strong>：管理程式碼
 * <strong>spec</strong>：管理測試程式
 * <strong>.rspec</strong>：產出格式的設定檔

<br>

### RSpec 語法

#### 描述功能與情境：describe、context

`describe` 和 `context` 用於組織和分類測試案例，兩者可任意套疊。它的參數可以是一個類別，或是一組字串描述：

<pre style="background:#f9f9f9;color:#080808">describe <span style="color: #aa0000">Transaction</span> <span style="color: #0000aa">do</span>
  describe <span style="color: #aa5500">&quot;#price&quot;</span> <span style="color: #0000aa">do</span>
    context <span style="color: #aa5500">&quot;If user is member&quot;</span> <span style="color: #0000aa">do</span>
      <span style="color: #aaaaaa; font-style: italic"># ...</span>
    <span style="color: #0000aa">end</span>

    context <span style="color: #aa5500">&quot;If user is not member&quot;</span> <span style="color: #0000aa">do</span>
      <span style="color: #aaaaaa; font-style: italic"># ...</span>
    <span style="color: #0000aa">end</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

在上述例子裡，我們要測試 `Transaction` 裡的 `price` 方法，在 `user` 是會員和非會員的情況下，購買物品的價格會打多少折扣。

在撰寫測試類別的程式時，最外層通常是我們想要測試的類別（class），然後下一層是該類別的方法（method），然後是不同的情境（context），最後才到測試案例。

<br>

#### 描述測試案例：it

每個 `it` 是一個測試案例，在 `it` 裡要清楚描述測試的事情：

<pre style="background:#f9f9f9;color:#080808">describe <span style="color: #aa5500">&quot;#price&quot;</span> <span style="color: #0000aa">do</span>
    context <span style="color: #aa5500">&quot;If user is member&quot;</span> <span style="color: #0000aa">do</span>
      it <span style="color: #aa5500">&quot;Discount 5% if total &gt; 1000&quot;</span> <span style="color: #0000aa">do</span>
        <span style="color: #aaaaaa; font-style: italic"># ..</span>
      <span style="color: #0000aa">end</span>

      it <span style="color: #aa5500">&quot;Discount 10% if total &gt; 10000&quot;</span> <span style="color: #0000aa">do</span>
        <span style="color: #aaaaaa; font-style: italic"># ..</span>
      <span style="color: #0000aa">end</span>
    <span style="color: #0000aa">end</span>

    context <span style="color: #aa5500">&quot;If user is not member&quot;</span> <span style="color: #0000aa">do</span>
      it <span style="color: #aa5500">&quot;No discount if not member&quot;</span> <span style="color: #0000aa">do</span>
        <span style="color: #aaaaaa; font-style: italic"># ..</span>
      <span style="color: #0000aa">end</span>
    <span style="color: #0000aa">end</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

#### 設定並比較預期結果：expect、to、eq

我們會在每個 `it` 裡，用 `expect`、`to` 和 `eq` 來設定和比較實際結果與預期結果，我們會在 `expect` 內帶入是實際結果，在 `eq` 內帶入預期結果：

<pre style="background:#f9f9f9;color:#080808">describe <span style="color: #aa0000">Transaction</span> <span style="color: #0000aa">do</span>
  describe <span style="color: #aa5500">&quot;#price&quot;</span> <span style="color: #0000aa">do</span>
    context <span style="color: #aa5500">&quot;If user is member&quot;</span> <span style="color: #0000aa">do</span>

      it <span style="color: #aa5500">&quot;Discount 5% if total &gt; 1000&quot;</span> <span style="color: #0000aa">do</span>
        user = <span style="color: #aa0000">User</span>.new( <span style="color: #0000aa">:is_member</span> =&gt; <span style="color: #0000aa">true</span> )
        transaction = <span style="color: #aa0000">Transaction</span>.new( <span style="color: #0000aa">:user</span> =&gt; user, <span style="color: #0000aa">:total</span> =&gt; <span style="color: #009999">2000</span> )
        expect(transaction.price).to eq(<span style="color: #009999">1900</span>)
      <span style="color: #0000aa">end</span>

      <span style="color: #aaaaaa; font-style: italic"># 其他測試案例</span>
    <span style="color: #0000aa">end</span>
    <span style="color: #aaaaaa; font-style: italic"># 其他測試情境</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

我們也可以用 `not_to` 取代 `to` 改為反向判斷：

<pre style="background:#f9f9f9;color:#080808">expect(actual).not_to eq(wrong_result)
</pre>

<br>


除了已使用過的等於判斷函式 `eq`，也還有許多判斷用的函式，RSpec 稱之為 Matcher，以下是用於判斷大小的 Matcher：

|大小判斷| RSpec 語法|
|:-------|:-------|
|大於 | expect(actual).to be >  expected|
|大於等於|expect(actual).to be >= expected|
|小於等於|expect(actual).to be <= expected|
|小於|expect(actual).to be <  expected|

<br>

#### 測試的前置與後置作業：before、after

使用 `before` 和 `after` 可以在每段 `it` 或 `describe` 執行前後進行資料的設定（setup）與清除（teardown），如：宣告物件、刪除測試用的資料庫資料。

`before` 常用於初始化設定，以下是一個使用者購買商品的例子，若這位使用者是 VIP 會員，就可享有 5% 的折扣。

我們可以在每個 `it` 開始前使用 `before` 宣告好 `user` 和 `transaction`，在 `it` 內只需要設定 `total` 屬性：

<pre style="background:#f9f9f9;color:#080808">describe <span style="color: #aa0000">Transaction</span> <span style="color: #0000aa">do</span>
  describe <span style="color: #aa5500">&quot;#price&quot;</span> <span style="color: #0000aa">do</span><span style="color: #aaaaaa; font-style: italic">  # 在名稱前機上「#」表示是物件的方法</span>
    context <span style="color: #aa5500">&quot;If user is VIP&quot;</span> <span style="color: #0000aa">do</span>

      before <span style="color: #0000aa">do</span>
        <span style="color: #aa0000">@user</span> = <span style="color: #aa0000">User</span>.new( <span style="color: #0000aa">:is_VIP</span> =&gt; <span style="color: #0000aa">true</span> ) <span style="color: #aaaaaa; font-style: italic"># 宣告一個新的 VIP user</span>
        <span style="color: #aa0000">@transaction</span> = <span style="color: #aa0000">Transaction</span>.new( <span style="color: #0000aa">:user</span> =&gt; <span style="color: #aa0000">@user</span> ) <span style="color: #aaaaaa; font-style: italic"># user 買了些東西</span>
      <span style="color: #0000aa">end</span>

      it <span style="color: #aa5500">&quot;Discount 5% if total &gt; 1000&quot;</span> <span style="color: #0000aa">do</span>      <span style="color: #aaaaaa; font-style: italic"># 買超過 1000 元的商品時會有 5% 折扣</span>
        <span style="color: #aa0000">@transaction</span>.total = <span style="color: #009999">2000</span>              <span style="color: #aaaaaa; font-style: italic"># 這個 user 買了 2000 元的商品</span>
        expect(<span style="color: #aa0000">@transaction</span>.price).to eq(<span style="color: #009999">1900</span>)  <span style="color: #aaaaaa; font-style: italic"># 打 5% 折扣的結果是 1900</span>
      <span style="color: #0000aa">end</span>

    <span style="color: #0000aa">end</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

`after` 則常用於清除在測試時新增的資料，以下例子與之前類似，我們將一般類別改寫成 `ActiveRecord` 的版本，所以資料會存入資料庫內，因此，我們需要在測試結束後把資料刪掉。

在每個 `it` 結束後使用 `after` 清楚掉在測試裡新增的資料庫資料：

<pre style="background:#f9f9f9;color:#080808">describe <span style="color: #aa0000">Transaction</span> <span style="color: #0000aa">do</span>
  describe <span style="color: #aa5500">&quot;#price&quot;</span> <span style="color: #0000aa">do</span>
    context <span style="color: #aa5500">&quot;If user is VIP&quot;</span> <span style="color: #0000aa">do</span>

      before <span style="color: #0000aa">do</span>
        <span style="color: #aa0000">@user</span> = <span style="color: #aa0000">User</span>.create!( <span style="color: #0000aa">:is_VIP</span> =&gt; <span style="color: #0000aa">true</span> )    <span style="color: #aaaaaa; font-style: italic"># 在資料庫新增一個 VIP user</span>
        <span style="color: #aa0000">@transaction</span> = <span style="color: #aa0000">Transaction</span>.create( <span style="color: #0000aa">:user_id</span> =&gt; <span style="color: #aa0000">@user</span>.id ) <span style="color: #aaaaaa; font-style: italic"># user 買了些東西</span>
      <span style="color: #0000aa">end</span>

      after <span style="color: #0000aa">do</span> <span style="color: #aaaaaa; font-style: italic"># 測試結束後，刪除資料庫的測試資料：user &amp; transaction</span>
         <span style="color: #aa0000">@user</span>.destroy         
         <span style="color: #aa0000">@transaction</span>.destroy
      <span style="color: #0000aa">end</span>

      it <span style="color: #aa5500">&quot;Discount 5% if total &gt; 1000&quot;</span> <span style="color: #0000aa">do</span>
        <span style="color: #aa0000">@transaction</span>.total = <span style="color: #009999">2000</span>  <span style="color: #aaaaaa; font-style: italic"># user 買了 2000 元的東西</span>
        <span style="color: #aa0000">@transaction</span>.save          <span style="color: #aaaaaa; font-style: italic"># transaction 資料存入資料庫</span>
        expect(<span style="color: #aa0000">@transaction</span>.price).to eq(<span style="color: #009999">1900</span>)
      <span style="color: #0000aa">end</span>

    <span style="color: #0000aa">end</span>
  <span style="color: #0000aa">end</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

#### 跳過測試案例：xit

在撰寫測試案例時，並不會一口氣完成所有的測試案例，有時候會只寫測試案例的標題，有時候則是不想跑該測試案例，這時你可以在每個 `it` 前加上 `x` 變成 `xit` 跳過該測試案例。

以下是上個單元的 `reverse integer` 測試程式，我們將最後一個測試案例的 `it` 更動為 `xit` ：

<pre style="background:#f9f9f9;color:#080808">require_relative <span style="color: #aa5500">&#39;./reverse_integer.rb&#39;</span>

describe <span style="color: #aa5500">&quot;將整數反轉過來&quot;</span> <span style="color: #0000aa">do</span>

  it <span style="color: #aa5500">&quot;123 結果應為 321&quot;</span> <span style="color: #0000aa">do</span>
    result = reverse_integer(<span style="color: #009999">123</span>)
    expect(result).to eq(<span style="color: #009999">321</span>)
  <span style="color: #0000aa">end</span>

  it <span style="color: #aa5500">&quot;-104 結果應為 -401&quot;</span> <span style="color: #0000aa">do</span>
    result = reverse_integer(-<span style="color: #009999">104</span>)
    expect(result).to eq(-<span style="color: #009999">401</span>)
  <span style="color: #0000aa">end</span>

  xit <span style="color: #aa5500">&quot;2147483650 結果應為 0&quot;</span> <span style="color: #0000aa">do</span>
    result = reverse_integer(<span style="color: #009999">2147483650 </span>)
    expect(result).to eq(<span style="color: #009999">0</span>)
  <span style="color: #0000aa">end</span>

<span style="color: #0000aa">end</span>
</pre>

<br>


結果會如下圖產生黃色結果與 `PENDING` 字樣，表示我們跳過了那個測試案例：

<div style="width:100%"> <img style="max-width:900px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2439/0104-1.png"></div>

<br>

### 更多 RSpec 語法

在使用 Google 搜尋時，你會常常會被導引到 [Relish](https://relishapp.com/rspec/rspec-expectations/v/3-7/docs/built-in-matchers) ，這也是一個常用來查詢 RSpec 語法的網站：

<div style="width:100%"> <img style="max-width:900px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2451/_____2018-03-30_18.57.23.png"></div>

隨著課程的進行，我們會繼續介紹更多 RSpec 的應用，以及如何整合 Rails 框架進行測試。


<QUIZ>330</QUIZ><QUIZ>331</QUIZ>
