# flutter_wanandroid
Flutter版 [玩Android \- wanandroid\.com \- 每日推荐优质文章](http://www.wanandroid.com/) 网站的移动端练手项目，总体架构完成，还有部分细节未完成。

# Android apk下载测试
[apk 下载](https://github.com/JakeyYe/flutter_wanandroid/blob/master/raw/app-release.apk),该apk为release版，iOS安装包没有，可以自己下载代码安装测试。

# 效果演示（Android手机，iOS效果类似）
<img src="https://github.com/JakeyYe/flutter_wanandroid/blob/master/raw/screenrecord.gif?raw=true" width="20%" height="20%">

<!--gif缩小比例width和比例之间不能有空格，而图片缩小比例就要空格，：（刚好相反）-->

<ul>
<img src="https://github.com/JakeyYe/flutter_wanandroid/blob/master/raw/Screenshot_1.png?raw=true" width = "20%" height = "20%" alt='首页'>
<img src="https://github.com/JakeyYe/flutter_wanandroid/blob/master/raw/Screenshot_2.png?raw=true" width = "20%" height = "20%" alt='体系'>
<img src="https://github.com/JakeyYe/flutter_wanandroid/blob/master/raw/Screenshot_3.png?raw=true" width = "20%" height = "20%" alt='导航'>
</ul>

<ul>
<img src="https://github.com/JakeyYe/flutter_wanandroid/blob/master/raw/Screenshot_4.png?raw=true" width = "20%" height = "20%" alt='项目'>
<img src="https://github.com/JakeyYe/flutter_wanandroid/blob/master/raw/Screenshot_5.png?raw=true" width = "20%" height = "20%" alt='侧边栏'>
<img src="https://github.com/JakeyYe/flutter_wanandroid/blob/master/raw/Screenshot_6.png?raw=true" width = "20%" height = "20%" alt='TabBar+TabBarView界面'>
</ul>


# 不足之处
1. `TabBar+TabBarView`布局（最后一张图片的布局）点击Tab快速跳转界面会出现bug，关于此问题官方还为解决 [Use TabBarView with AutomaticKeepAliveClientMixin and with 4 or more pages will cause error · Issue \#16502 · flutter/flutter](https://github.com/flutter/flutter/issues/16502)；

2. WebView控件支持不是太好，[Inline Android and iOS WebView · Issue \#730 · flutter/flutter](https://github.com/flutter/flutter/issues/730)；

3. 项目不足之处是并未完全完成：）。