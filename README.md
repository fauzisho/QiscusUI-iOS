# [QiscusUI](https://github.com/qiscus) - Messaging and Chat UI Component for iOS
[Qiscus](https://qiscus.com) Enable custom in-app messaging in your Mobile App and Web using Qiscus Chat SDK and Messaging API

[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/QiscusUI)
[![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)](https://github.com/qiscus)
[![CocoaPods](https://img.shields.io/badge/pod-v3.0.109-green.svg)](https://cocoapods.org/pods/QiscusUI)


## Features

- [x] Default Chat View
- [x] Default Chat List
- [x] Custom Chat List Cell
- [X] Custom Chat View Cell
- [x] Customize Input Chat
- [x] Customize Navigation Bar
- [x] [Complete Documentation](https://qiscus.com)

## Component Libraries

In order to keep QiscusCore focused specifically on core messaging implementation, additional libraries have beed create by the [Qiscus IOS] (https://qiscus.com).

* [Qiscus](https://github.com/qiscus) - An chat sdk with complete feature, simple, easy to integrate.
* [QiscusCore](https://github.com/qiscus) - Chat Core API, All chat functionality already on there.
* [QiscusRaltime](https://github.com/qiscus) - An realtime messaging library. Already handle realtime event like user typing, online status, etc.

### Classes in QiscusUI

The table bellow details the most important classess in QiscusUI.


| Controllers                                       | Description                                                                                                                                                                            |
|-----------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **UIChatListViewController**                   | A controller that provides list of conversation for the authenticated user.                                       |
| **UIChatViewController**                          | A controller that a scrollable, auto-pagination view of the messagess. |


Custumize you chat buble or create you specific chat buble for custom comment/message type.


| TableViewCell                                       | Description                                                                                                                                                                            |
|-----------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **UIBaseChatCell**                   |                                       |
| **UIChatListViewCell** |						|


## Installation

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate QiscusUI into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'QiscusUI',
end
```

Then, run the following command:

```bash
$ pod install
```


