## Rails 測試準備

在之前 TDD 相關的章節裡面，我們已經蠻詳盡的介紹 TDD 的用法和好處，也圍繞著冷氣遙控器舉了幾個例子。這一章我們會針對 Rails 討論測試的概念和搭配的的測試工具。

### 在 Rails 裡面寫測試

到目前為止，你應該順利完成了一個餐廳推薦主題的網站，接下來我們會用它做一個出發點，教你怎麼把既有的功能加上測試。在正式開始之前，我們需要安裝一些需要的工具，加速我們撰寫測試的過程。

### 測試工具安裝

#### 安裝 RSpec

[RSpec](https://github.com/rspec/rspec) 是 2010 年推出的 Rails 測試框架，以清楚、語義化的撰寫方式和好用的 API 活躍於 Rails 社群。RSpec 其實是一個函式庫的集合，裡面包含了四個主要的函式庫:

- rspec-core: 提供豐富的 command line 指令，彈性且可以客製化的結果回報 API，並提供 API 來管理 code examples。
- rspec-expectations: 提供方便閱讀的 API 來檢測預期結果和真正結果。
- rspec-mocks: 提供多種 mock 的工具讓你方便假裝各種物件，讓輕鬆的控制各種測試環境變數。
- rspec-rails: 提供一些讓上述的函式庫能夠順利整合 Ruby on Rails 這個 framework 的函式庫。

透過在 Gemfile 裡面加上

```
group :development, :test do
  gem 'rspec-rails', '~> 3.6'
end
```

透過 bundler 安裝成功之後，我們接著要幫我們的專案初始化 RSpec

```
bundle exec rails generate rspec:install
```

這個指令會幫你安裝三個設定檔

- .rspec: 你可以把常用的參數加到這個檔案裡面。舉例來說，如果你想顯示來自 Ruby 的 warning，你可以在檔案裡面加上一行 --warnings，這樣之後每次在跑 `bundle exec rspec` 的時候就會自動帶上這個參數。你可以透過 `rspec -h` 這個指令看到所有的參數。
- spec/rails_helper.rb: 我們會在這裡撰寫跟 Rails 相關的內容。舉例來說，在測試開始跑之前導入自定義的 matcher 檔案。
- spec/spec_helper.rb: 我們會在這裡撰寫跟 RSpec 本身設定有關的內容。舉例來說，調整 `rspec-mock` 或是 `rspec-expectation` 的設定。

透過 rspec 的指令看看安裝有沒有成功

```
bundle exec rspec
```

順利的話會看到下面的畫面

![圖一](Rails Testing 0101.png)

#### 安裝 factory_girl_rails

[factory_girl_rails](https://github.com/thoughtbot/factory_girl_rails) 是一個能夠快速幫你產生假物件的函式庫，透過這個 Gem 可以省下你很多準備資料的時間。

安裝 factory_girl_rails

```
group :development, :test do
  gem 'factory_girl_rails'
end
```

接著在 `spec/spec_helper.rb` 裡面加上

```ruby
RSpec.configure do |config|
  ...
  config.include FactoryGirl::Syntax::Methods
end
```

安裝完成之後我們必須先針對目標 model 在新增相對應的設定檔，一般來說，假設我們要新增 `user` model 的假資料，我們會加在 `spec/factories/` 目錄下面建立 `model.rb` 檔案，內容如下:

```
FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@gmail.com" }
    phone_number { "0227011001" }
  end
end
```

之後就可以在測試裡面透過 `Factory.create(:user)` 的 API 來幫我們建立新的 user，加速開發的流程。如果針對 user 的屬性需要更詳細的調整，可以參考[官方文件](https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#configure-your-test-suite)。

#### 安裝 ffaker

[ffaker](https://github.com/ffaker/ffaker) 是用來幫我們建立亂數資料的 Gem，通常會跟 `factory_girl_rails` 搭配使用。

安裝 ffaker

```
group :development, :test do
  gem 'ffaker'
end
```

透過 bundler 安裝完成之後，在 console 裡面測試

```
> FFaker::Name.name
#=> "Christophe Bartell"
> FFaker::Internet.email
#=> "kirsten.greenholt@corkeryfisher.info"
```

跟 `factory_girl_rails` 搭配使用，在上面已經建立過的 factory user 裡面增加 nickname 和 description 兩個欄位。

```
FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@gmail.com" }
    phone_number { "0227011001" }
    nickname { FFaker::Name.last_name }
    description { FFaker::Lorem.sentence }
  end
end
```

#### 安裝 Shoulda-matchers

Shoulda-matchers 是一個 RSpec 的補充包，裡面針對 `ActiveModel`、`ActiveRecord` 和 `ActionController` 的設定提供了方便的 API 來進行測試。

安裝 shoulda-matchers

```
group :development, :test do
  gem 'shoulda-matchers', '~> 3.1'
end
```

在 `spec/rails_helper.rb` 裡面新增設定

```
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
    with.library :active_model
  end
end
```

現在你可以使用更直覺的方式做測試，像是測試 user.name 的 validation

```
RSpec.describe User, type: :model do
  it { should validate_presence_of(:name) }
end
```

或是測試兩個 model 之間的關聯

```
RSpec.describe User, type: :model do
  it { should have_many(:restaurants) }
end
```

### 小結

這一章介紹了許多方便的工具，讓我們撰寫測試維護更加的方便。關於這些工具的使用方法和細節，在每個專案的文件裡面都有詳細的紀錄，由於內容繁多，請有需要的學員自行到專案裡面查詢。下一章我們會示範這些工具在各種不同的測試情境裡面將如何幫助我們開發。

### 參考資料
- http://rspec.info/documentation/
- https://github.com/thoughtbot/factory_girl_rails
- https://github.com/ffaker/ffaker
- https://github.com/thoughtbot/shoulda-matchers
