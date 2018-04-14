## 上傳題

請你依本章的教學，使用 TDD 開發功能，依以下說明來分享你的練習成果：
- Cover：請在終端機執行 `rspec spec --format documentation`，輸出你的測試文件，附上截圖
- GitHub：附上相關的 commit，請你盡可能利用 git branch 的功能，將相關的程式碼整理到一顆獨立的 commit 上，並分享該 commit 的連結，做法如下：
   - git branch new_branch 開啟新分支
   - git checkout new_branch 切換到新分支
   - 在該分支上進行開發
   - git checkout master，完成開發後，切回主幹
   - git merge new_branch --no-ff，用主幹合併新分支，並設定不要快轉，如此一來，在 master 上會產生一顆獨立的 commit，內容是所有你在新分支上實作的程式碼

- Description：用文字摘要你撰寫的測試與功能
