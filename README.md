 # rime-liur-lua
 ------------
>基於RIME輸入法設計的無蝦米方案


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->
* [安裝](#安裝)
	* [MacOS or Linux](#macos-or-linux)
	* [Windows](#windows)
* [基本功能](#基本功能)
	* [中英混輸](#中英混輸)
	* [取消碼長限制](#取消碼長限制)
	* [SHIFT鍵切換中英輸入](#shift鍵切換中英輸入)
	* [即時簡繁轉換](#即時簡繁轉換)
* [模式](#模式)
	* [注音模式](#注音模式)
	* [拼音模式](#拼音模式)
	* [*造詞模式](#造詞模式)
* [反查](#反查)
	* [複合型編碼反查](#複合型編碼反查)
	* [讀音反查](#讀音反查)
* [**擴充模式](#擴充模式)

<!-- /code_chunk_output -->


## 安裝
本專案自 PR #5 之後相容於 Rime 官方提供的 [Plum](https://github.com/rime/plum) 管理工具，從而簡化安裝流程，同時也讓跨平台佈署更加方便。
### MacOS or Linux
目前已於 Ubuntu 18.04.1 和 MacOS Catalina 10.15.3 測試過

安裝指令：
```
$ git clone https://github.com/rime/plum.git && cd plum
$ ./rime-install https://raw.githubusercontent.com/hftsai256/rime-liur-lua/master/liur-lua-packages.conf
```

或是直接 pipe：
```
$ curl -fsSL https://git.io/rime-install | bash -s -- https://raw.githubusercontent.com/hftsai256/rime-liur-lua/master/liur-lua-packages.conf
```

若 Distribution 帶入的 `ibus-rime` 版本較舊而不支援 `__patch` 語法 (如 Ubuntu 18.04 LTS)，可參考源碼中提供的範本 `plum/package/hftsai256/rime-lua/default.custom.yaml` 會更簡單些。Ubuntu 20.04 LTS 會直接帶入 `ibus-rime v1.4.0-2` 版。

目前版本保存了位於 `plum/package/hftsai256/rime-lua/tools` 內的管理工具 `config.sh`，執行 `$ ./config.sh -i` 將會安裝所有程式及設定檔。
其它功能請參考 `-h` 說明提示：
```
$ tools/config.sh

Usage: config.sh [-ciuh] install Open Xiami configuration for RIME framework

Options
  -c, --clean     - Remove Build folder in $RIME_CFG_PATH
  -i, --install   - Install everything, including:
                    * main application by homebrew cask
                    * dependencies (luna-pinyan, terra-pinyin, bopomofo) by plum
                    * configuration files to $RIME_CFG_PATH
  -u, --uninstal  - Remove relative files under $RIME_CFG_PATH
  -h, --help      - This message
```

### Windows
雖然 Plum 提供 Windows bat 腳本但並沒有支援 Recipe 語法。因此推荐預載 Git Bash for Windows 方能使 Plum 發揮全部的功力。

* [Git for Windows](https://git-scm.com/download/win)
* [Plum Windows Bootstrap](https://github.com/rime/plum-windows-bootstrap/archive/master.zip)

安裝指令：
```
rime-install https://raw.githubusercontent.com/hftsai256/rime-liur-lua/master/liur-lua-packages.conf
```

如果不想安裝 Git Bash for Windows，你仍然可以執行 `tools/Install.bat` 或是手動把輸入方案複製到 `%AppData%\Rime`。也別忘了安裝朙月拼音，大地拼音和注音輸入：
```
rime-install luna-pinyin terra-pinyin bopomofo
```

## 基本功能
### 中英混輸
透過空白鍵上中文字及中文符號，ENTER鍵上英文字及英文符號
><img div="中英混輸.gif" src="https://raw.githubusercontent.com/ianzhuo/ImageCollection/master/%E4%B8%AD%E8%8B%B1%E6%B7%B7%E8%BC%B8.gif" width="600">

### 取消碼長限制
直接輸入 www.google.com.tw 按ENTER鍵，可直接上字無需切換輸入法
><img div="取消碼長限制.gif" src="https://raw.githubusercontent.com/ianzhuo/ImageCollection/master/%E5%8F%96%E6%B6%88%E7%A2%BC%E9%95%B7%E9%99%90%E5%88%B6.gif" width="600">

### SHIFT鍵切換中英輸入
SHIFT鍵可切換中英輸入，並且將組字區內容直接上字
><img div="中英切換.gif" src="https://raw.githubusercontent.com/ianzhuo/ImageCollection/master/%E4%B8%AD%E8%8B%B1%E5%88%87%E6%8F%9B.gif" width="600">

### 即時簡繁轉換
可利用Ctrl+.(句點)進行即時簡繁體切換
><img div="簡繁體即時轉換.gif" src="https://raw.githubusercontent.com/ianzhuo/ImageCollection/master/%E7%B0%A1%E7%B9%81%E9%AB%94%E5%8D%B3%E6%99%82%E8%BD%89%E6%8F%9B.gif" width="600">

## 模式
### 注音模式
以「';」鍵引導可進行注音輸入
### 拼音模式
以「`」鍵(上排數字鍵1左邊)引導可進行拼音輸入

><img div="注音拼音模式.gif" src="https://raw.githubusercontent.com/ianzhuo/ImageCollection/master/%E6%B3%A8%E9%9F%B3%E6%8B%BC%E9%9F%B3%E6%A8%A1%E5%BC%8F.gif" width="600">
### *造詞模式
以 `;`(分號鍵) 鍵引導進入造詞模式(透過 「\`」 來分詞，分詞符號可不輸入)，空白鍵上字後即完成造詞。
><img div="造詞01.gif" src="https://raw.githubusercontent.com/ianzhuo/ImageCollection/master/%E9%80%A0%E8%A9%9E01.gif" width="600">

>造詞上限為10字

>新詞於第一次被使用後，即會列在候選字中。

>若該詞不再使用，透過上下鍵選定該詞，按下Shift+Del即可刪除。

>所造詞固定為四碼，並以每字的首碼定詞。
例：「中華民國」，可以輸入「;ci\`aj\`oxx\`oka」造詞，未來就可以利用每個字的首碼「caoo」來輸出「中華民國」

>超過四字的詞如「台南市政府」，就輸「;uo\`n\`ni\`ezp\`lpa」來造詞，並輸入一、二、三、最末字的首碼「unnl」來輸出「台南市政府」

>未滿四字詞的話，輸出時要補滿4碼(不足碼用最後一字的首碼來填)，如「捷運站」，就輸「;cz\`ncw\`lzo」來造詞，並輸入一、二、三、三的首碼「cnll」來輸出「捷運站」

## 反查
### 複合型編碼反查
於一般、注音、拼音、造詞模式時，按下`Ctrl+'`鍵，可開啟動態反查編碼功能
並且支援以詞句為單位之反查行為
><img div="編碼反查.gif" src="https://raw.githubusercontent.com/ianzhuo/ImageCollection/master/%E7%B7%A8%E7%A2%BC%E5%8F%8D%E6%9F%A5.gif" width="600">

### 讀音反查
以 `;;`(分號鍵) 鍵引導進入讀音反查，輸入嘸蝦米編碼，可以反查該字讀音。
><img div="讀音反查.gif" src="https://raw.githubusercontent.com/ianzhuo/ImageCollection/master/%E8%AE%80%E9%9F%B3%E5%8F%8D%E6%9F%A5.gif" width="600">

## **擴充模式
以「``」鍵引導啟動擴充模式，
可利用Lua語言，於使用者文件夾中`rime.lua`自定義擴充功能

>目前提供日期轉換器功能，快速轉換中文日期
><img div="擴充模式.gif" src="https://raw.githubusercontent.com/ianzhuo/ImageCollection/master/%E6%93%B4%E5%85%85%E6%A8%A1%E5%BC%8F.gif" width="600">
