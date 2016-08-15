# 开源中国 iOS 客户端

**源代码请切换置对应的分支，master分支中今后不再放源代码。**


##历史分支

编号 | 标签名 | 发布版本 |  备注
------- | ------- | ------- | ------- | -------
1 | [v3.7.2](http://git.oschina.net/oschina/iphone-app/tree/v3.7.2/) | v3.7.2 (1608101524) |  当前最新版
1 | [v3.7.1](http://git.oschina.net/oschina/iphone-app/tree/v3.7.1/) | v3.7.1 (1607111810) |
2 | [v3.7.0](http://git.oschina.net/oschina/iphone-app/tree/v3.7.0/) | v3.7.0 (1606131024) |  




## 编译环境
Xcode 6＋


## 运行项目
1. 安装CocoaPods (关于CocoaPods的安装和使用，可参考[这个教程](http://code4app.com/article/cocoapods-install-usage))
2. 在终端下打开项目所在的目录，执行```pod install``` (若是首次使用CocoaPods，需先执行```pod setup```)
3. ```pod install```命令执行成功后，通过新生成的xcworkspace文件打开工程运行项目


## 目录简介

* Application：  存放AppDelegate和API定义
* Models：       数据实体类
* Controllers：  存放所有的view controller
* Views：        存放一些定制的视图
* Utils：        存放工具类
* Categories：   类扩展
* Resources：    存放除图片以外的资源文件，如html、css文件（图片资源存放在images.xcassets中)
* Vendor：       存放非CocoaPods管理的第三方库


## 项目用到的开源类库、组件

* AFNetworking：                         网络请求
* AFOnoSerializer：                      序列化XML和HTML
* DateTools：                            时间计算
* DTCoreText：                           渲染HTML
* GRMustache：                           html模版引擎
* GPUImage：                             图像处理
* MBProgressHUD：                        显示提示或加载进度
* MJRefresh：                            刷新控件
* Ono：                                  解析XML
* ReactiveCocoa：                        函数式编程和响应式编程框架
* RESideMenu：                           侧拉栏
* SDWebImage：                           加载网络图片和缓存图片
* SSKeychain：                           账号密码的存取
* TBXML：                                解析XML
* TOWebViewController：                  内置浏览器
* TTTAttributedLabel：                   支持富文本显示的label


## 开源协议

	The MIT License (MIT)

	Copyright (c) 2016 OSChina.net

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
