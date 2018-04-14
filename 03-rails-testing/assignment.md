請你依本章的教學，使用 TDD 開發功能，依以下說明來分享你的練習成果：

<ul>
  <li>Cover：請在終端機執行 <code>rspec spec --format documentation</code>，輸出你的測試文件，附上截圖</li>
  <li>GitHub：附上相關的 commit，請你盡可能利用 git branch 的功能，將相關的程式碼整理到一顆獨立的 commit 上，並分享該 commit 的連結，做法如下：
    <ul>
      <li><code>git branch new_branch</code> 開啟新分支</li>
      <li><code>git checkout new_branch</code> 切換到新分支</li>
      <li>在該分支上進行開發</li>
      <li><code>git checkout master</code>，完成開發後，切回主幹</li>
      <li><code>git merge new_branch --no-ff</code>，用主幹合併新分支，並設定不要快轉，如此一來，在 master 上會產生一顆獨立的 commit，內容是所有你在新分支上實作的程式碼</li>
    </ul>
  </li>
  <li>Description：用文字摘要你撰寫的測試與功能</li>
</ul>

