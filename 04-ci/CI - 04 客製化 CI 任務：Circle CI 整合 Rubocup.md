>**學習成果與目標**
>・能夠在客製化 CI 任務裡導入其他的第三方服務

<hr style="border-top: 2px solid #eee">

在這個單元裡，我們來利用你上個單元設定好的 CircleCI，再去整合其他的服務，例如 RuboCop。

<br>

### 安裝 RuboCop

[RuboCop](https://github.com/bbatsov/rubocop) 是一個開源專案，他可以幫你的專案做 Ruby 代碼分析和檢查，可以讓不熟悉 Ruby 語法的人學習 Ruby 語法優良的傳統。

請你自行依照 RuboCop README 的指示安裝，完成後輸入 `rubocop`，可以看到很多語法上的建議。這些規則都是可以隨自己的喜好打開或是關閉，請參考[這份文件](https://github.com/bbatsov/rubocop/blob/master/config/default.yml)。

<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2526/CI-q01.png"></div>

<br>

### RuboCop 導入 CI

打開你在上個單元努力設定好的 **.circleci/config.yml**，加上：

<pre style="background:#f9f9f9;color:#080808"><span style="color: #aaaaaa; font-style: italic"># Rubocup</span>
- run: bundle exec rubocop
</pre>

<br>

這行指令會讓 Circle CI 執行 rubocop。

設定好以後，在你之後執行 CI 時，也會一併執行 rubocop 檢查，只要 rubocop 發現你寫的 Ruby 語法不合格，就不會讓這次的代碼通過。

<div style="width:100%"> <img style="max-width:700px;width:100%;" src="https://assets-lighthouse.s3.amazonaws.com/uploads/image/file/2527/CI-q02.png"></div>
