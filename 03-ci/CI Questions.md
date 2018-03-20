## CI Tutorial & Practice

### Tutorial

我們試試看把 RuboCop 導入 CI 的客製化任務裡面！

#### RuboCop 是什麼

[RuboCop](https://github.com/bbatsov/rubocop) 是一個開源專案，他可以幫你的專案做 Ruby 代碼分析和檢查，可以讓不熟悉 Ruby 語法的人學習 Ruby 語法優良的傳統。

#### RuboCop 導入 CI

Step1

依照 RuboCop README 的指示安裝，完成後記得輸入 rubocop，可以看到很多語法上的建議。這些規則都是可以隨自己的喜好打開或是關閉，請參考[這份文件](https://github.com/bbatsov/rubocop/blob/master/config/default.yml)。

[圖ㄧ]('./CI-q01.png')

Step2

在 `.circleci/config.yml` 加上

```
# Rubocup
- run: bundle exec rubocop
```

讓 Circle CI 執行 rubocop

Step3

現在只要 rubocop 發現你寫的 Ruby 語法不合格，就不會讓這次的代碼通過

[圖二]('./CI-q02.png')

### Practice

1. 在 GitHub marketplace 挑選一個任務，並嘗試將他導入專案。

2. 嘗試將 [gemnasium](https://github.com/marketplace/gemnasium) 導入專案，讓他幫你管理你的 Gems!

3. 上討論區分享上面兩個練習的心得！