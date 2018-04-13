<hr style="border-top: 2px solid #eee">

### 一百種任務

CI 的任務有很多種，基礎服務，大概可以分成幾個類型：

|任務類型|說明|
|:------|:------|
|code quality|這類型的任務主要是幫你檢查程式碼風格，部分有提供測試覆蓋率的檢查 |
|code review|這類型的任務會幫你做簡單的 code review。 |
|continuous integration|這類型的任務的客製化程度比較高，通常我們會拿來跑測試和建立新版本，但是設定步驟也會比較複雜。|
|dependency management|這類型的任務比較少見，但出乎意料的方便。他會幫你檢查套件有沒有推出新的版本，然後提醒你升級版本。|
|localization|這類型的任務可以幫你做 project 的翻譯，算是比較少見的需求，可能適合跨國團隊合作的情境。|
|monitoring|這類型的任務可以幫你檢測網站狀況，當 bug 發生或是網站沒有回應的時候馬上通報。|
|project management|這類型的任務可以幫整合代碼與專案的一致性，對於有做專案管理的團隊比較有幫助。|

<br>

由於 CI 任務的種類繁多，你需要依照實際的專案需求去探索適當的工具，在本單元，我們目標是讓你體驗到 CI 任務可以做到哪些事情，並以 Rollbar 為例，做一個完整的安裝介紹。

<br>

### 安裝 Rollbar 到自己的專案

Rollbar 是 monitoring 裡面算蠻實用的任務之一，主要功能是在上線的網站出現 bug 的時候，寄送 email 給網站負責人。

請進入 Rollbar 的介紹頁：[https://github.com/marketplace/rollbar](https://github.com/marketplace/rollbar)
該網頁上有 Rollbar 的使用說明和功能介紹，最重要是價格的地方，這裡說明在「發送一萬個事件」之前都是免費的。閱讀完說明之後，按下 `Install it for free`。

然後要設定安裝的範圍，看你是要全部在 GitHub 上面的方案都安裝、或是安裝特定某個專案，這邊我選擇我自己的一個私有專案安裝。

<div style="width:100%"> <img style="max-width:500px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2491/01.png"></div>

<br>


接著 Rollbar 會跟你要求 GitHub 的資料，按下 `Authorize rollbar`。

<div style="width:100%"> <img style="max-width:500px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2492/02.png"></div>

<br>


你可能會覺得畫面突然變得有點陌生，是因為現在已經是在 Rollbar 的服務，接下來的程序會在這邊完成。切換到 Back-end 的 tab，選擇 Rails，然後按下 continue。

最後一步！照著他的步驟安裝 `rollbar` 的 gem，然後 `bundle install` 安裝這個 gem。接者跑 `rails generate rollbar SERVER SIDE ACCESS TOKEN`，他會幫你產生一隻 `config/initializers/rollbar.rb` 檔案，記得把他 commit 進去。


<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2493/CI-0204.png"></div>

<br>


### 發送測試用 error

安裝完成後，執行 `rake rollbar:test` 發送測試用的 error。

進入 `rollbar.com` ，順利的話應該就可以在 dashboard 看到剛剛發送的 error！

<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2494/CI-0205.png"></div>

<br>


除此之外，應該也可以在專案的底下發現 Rollbar 針對剛剛的 error 幫你開了一個 issue，讓你更方便管理。

<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2495/CI-0206.png"></div>

<br>


### 調整 Rollbar 方案

假設你遇到免費專案不夠用的情況，例如說網站受到大批粉絲的湧入，流量爆炸，這個時候我們就需要到 GitHub 升級我們的方案。

進入 GitHub，從右上個人選單選擇 setting

<div style="width:100%"> <img style="max-width:500px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2496/CI-0207.png"></div>

<br>

左邊的導覽列選擇 billing，找到 Marketplace Apps 區域裡面的 Rollbar，點選 edit

<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2500/CI-0208.png"></div>

<br>


依照流量選擇適合自己的方案

<div style="width:100%"> <img style="max-width:500px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2498/CI-0209.png"></div>

<br>

### 解除 Rollbar 服務

如果有一天我們不需要 Rollbar，想要試試看別的 monitoring 服務。這個時候我們需要到 GitHub 取消。請進入 GitHub，從右上個人選單選擇 setting：

<div style="width:100%"> <img style="max-width:500px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2499/CI-0207.png"></div>

<br>

左邊的導覽列選擇 billing，找到 Marketplace Apps 區域裡面的 Rollbar，點選 cancel 之後就正式解除

<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2497/CI-0208.png"></div>

<br>

### 小結

大多的 CI 常見任務都有提供免費試用，超過某些限制才需要收費，有興趣的讀者可以自己在 [GitHub marketplace](https://github.com/marketplace) 摸索適合自己的服務。下一章我們會針對比較複雜的 continuous integration 類別做比較詳細的介紹，然後帶大家實際走過一次流程。
