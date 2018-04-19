> **學習成果與目標**
>・理解 MVC 不同的測試要點

<hr style="border-top: 2px solid #eee">

在前兩個單元，我們為冷氣遙控器開發了「打開冷氣」功能，以此理解了 TDD 概念。在這個單元裡，我們要進一步加入 MVC 的概念來拆解程式架構。

之前提過，寫測試的時候，通常會依照 Rails 的架構分別撰寫不同層級的測試，從 MVC 來看的話，重要性依序是 model > controller > view。原因是 model 是邏輯上最不容易改變，卻又最關鍵的地方，而 view 比較常會改變，而且改變的內容通常不會太重要。

|          |  改動頻率  |  重要度  |  難易度   |  撰寫詳細度 |
|----------|----------|----------|----------|-----------|
|view      |    高    |    低    |    低     |    低     |
|model     |    低    |    高    |    中     |    中     |
|controller|    中    |    中    |    中     |    高     |

<br>

### Model

在上個單元最後，我們將「判斷冷氣是否開啟」這個方法移到 `冷氣` model 裡。若我們要針對這個方法來寫測試，可能會有以下的思考步驟。

首先，我們要先確認這個方法的用途和格式，這是一個 model instance level 的方法，當我們呼叫 `冷氣.是否開啟` 的時候，我們預期回傳值是 boolean。

再來我們要把呼叫這個方法的預期結果也列出來：

* 如果冷氣開啟，預期呼叫這個方法會回傳 `True`
* 如果冷氣關閉，預期呼叫這個方法會回傳 `False`

組合起來，組成 model 的完整測試：

<pre style="background:#f9f9f9;color:#080808">測試</span> <span style="color: #aa5500">&quot;若冷氣開啟 -&gt; 「判斷是否開啟」回傳值應為 True&quot;</span> <span style="color: #0000aa">do</span>
  打開冷氣
  呼叫紅外線發射器
  假設發送指令給冷氣的回傳值是 <span style="color: #aa0000">True</span>
  預期(冷氣.是否開啟(設定紅外線)) == <span style="color: #aa0000">True</span>
<span style="color: #0000aa">end</span>

測試 <span style="color: #aa5500">&quot;若冷氣關閉 -&gt; 「判斷是否開啟」回傳值應為 False&quot;</span> <span style="color: #0000aa">do</span>
  關閉冷氣
  呼叫紅外線發射器
  假設發送指令給冷氣的回傳值是 <span style="color: #aa0000">False</span>
  預期(冷氣.是否開啟(設定紅外線)) == <span style="color: #aa0000">False</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

在上述的測試案例裡面，我們沒有直接去請冷氣要求回傳結果，而是自己在測試中假造了「發送指令給冷氣」的回傳結果，目的是避免測試的正確性受到外部因素影響，也就是「維持測試的單元性」的精神。

舉例來說，假設今天冷氣機的發射系統故障，而我們在測試中要求冷氣機回傳結果，就會造成測試失敗，但這個測試案例是針對遙控器「判斷是否開啟」的功能運作，冷氣有沒有壞掉，並不是我們這個測試案例的重點。如果把「冷氣」這個外部因素混合進來，我們看到測試壞掉時，就無法精確的判斷有問題的地方是來自冷氣機、還是冷氣機遙控器。

<br>

### Controller

接著我們來試試看 controller 的測試。`冷氣遙控器` 對應到 controller，而 `打開冷氣` 是其中的 action。

如同上面的步驟，第一步我們要確認 `打開冷氣` 這個 action 的用途和格式，這是一個 controller action，我們預期這個 action 能把 `冷氣` 打開。

也就是說，我們預期呼叫 `冷氣遙控器.打開冷氣()` 時，`冷氣開啟狀態 == 打開`

組合起來，組成 controller 的完整測試：

<pre style="background:#f9f9f9;color:#080808">測試 <span style="color: #aa5500">&quot;冷氣遙控器 按下 打開冷氣按鈕 能順利打開冷氣&quot;</span> <span style="color: #0000aa">do</span>
  設定紅外線發射器
  冷氣開啟狀態 -&gt; 沒開
  預期（假的紅外線）會（發射開機指令給冷氣）
<span style="color: #0000aa">end</span>

測試 <span style="color: #aa5500">&quot;如果冷氣已經開啟，冷氣遙控器不會發射開機訊號 &quot;</span> <span style="color: #0000aa">do</span>
  設定「冷氣開啟狀態」 -&gt; 關機
  設定「冷氣開啟狀態」 -&gt; 有插電
  冷氣遙控器.打開冷氣()
  預期(冷氣狀態) == 運作中
<span style="color: #0000aa">end</span>
</pre>

<br>

### View

view 在冷氣遙控器裡面對應到儀表板 (dashboard)，負責顯示目前冷氣的狀態。

第一步我們要確認這次要測試的 view 範圍，針對「顯示開關機狀態」的區域，我們希望這個區域能正確顯示開關機的狀態，也就是：

- 當冷氣打開時，儀表板上負責顯示開關區域會顯示 on
- 當冷氣關閉時，儀表板上負責顯示開關區域會顯示 off

我們會在測試裡去呼叫模板，判斷實際結果是否等於預期結果。

以下為 view 的測試案例：

<pre style="background:#f9f9f9;color:#080808">測試</span> <span style="color: #aa5500">&quot;儀表板上負責顯示開關的區塊正確顯示&quot;</span> <span style="color: #0000aa">do</span>
  設定「冷氣開啟狀態」 -&gt; 關機
  冷氣遙控器.打開冷氣()
  預期(冷氣遙控器儀表板) 有 <span style="color: #aa5500">&quot;on&quot; 的訊息</span>
<span style="color: #0000aa">end</span>
</pre>

<br>

以上我們對 model、controller、view 三個層級，分別舉出了一個測試案例，希望有助於讓你體會到 MVC 不同的測試重點。

<br>

### 參考程式碼

以下附上對應到 Pseudocode 的程式碼，請你確保你已經充分了解上述案例的邏輯之後，再開啟程式碼來研究：


| 項目 | GitHub |
| :----- | :----- |
| Model 測試案例 | [LINK](https://github.com/ALPHACamp/air-conditioner/commit/e584d5731213ea4228d20ecc0a8842fe0ad9e6cb) |
| Controller 測試案例 | [LINK](https://github.com/ALPHACamp/air-conditioner/commit/1e2a9df696f0312868f143c9c5efb3c8a2ba6820) |
| View 測試案例 | [LINK](https://github.com/ALPHACamp/air-conditioner/commit/613d004b47ca31ac38b771e0dab571ab4f74988d) |
