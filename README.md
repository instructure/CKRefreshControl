# CKRefreshControl

Open source library providing iOS 5.0+ support for [UIRefreshControl](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIRefreshControl_class/Reference/Reference.html), which was introduced in iOS 6.0.

Using it is as simple as this:

    UITableViewController *controller;

    controller.refreshControl = [[UIRefreshControl alloc] init];
    [controller.refreshControl addTarget:self action:@selector(doRefresh:) forControlEvents:UIControlEventValueChanged];

Yes, that's exactly the code you'd write on iOS 6. No changes required.

You can also configure the refresh control in a storyboard, or use the `+appearance` API proxies if you'd like. It all works just like you'd hope, but now you can deploy it back to iOS 5.0 as well. Just link against the static library the `CKRefreshControl` project provides, add the `-ObjC` linker flag, and you're ready to go.

![iOS 5 example](https://raw.github.com/instructure/CKRefreshControl/readme-resources/iOS5.png) &nbsp; 
![iOS 6 example](https://raw.github.com/instructure/CKRefreshControl/readme-resources/iOS6.png)

----

### Appearance

CKRefreshControl intentionally does not mimic the iOS 6 UIRefreshControl look and feel for iOS 5.0. Instead, it was designed to look more like the other pull-to-refresh controls commonly used in iOS 5-compatible apps. Thus, whether the user is running iOS 5 or iOS 6, they get an interface that fits in with other apps on the device.

---

### Why the name?

CKRefreshControl was originally part of our internal "CanvasKit" library, used in building Instructure's iOS apps. 

---

### Implementation

In general, you won't even know you're using CKRefreshControl. On iOS 5, we register `UIRefreshControl` as a subclass of `CKRefreshControl`, which implements all the compatibility stuff. On iOS 6, we just get out of the way; `UIRefreshControl` is available natively, and we don't have to do anything.

---

### But does it work?

Yes! Instructure is using it in shipping code with no problems. That said, if you find a bug, please let us know and we'll make it work. 

--- 

### Contributors

* [@bjhomer](http://github.com/bjhomer)
* [@johnhaitas](http://github.com/johnhaitas)
* [@steipete](http://github.com/steipete)
* [@0xced](http://github.com/0xced)

---

### License

CKRefreshControl, and all the accompanying source code, is released under the MIT license. You can see the full text of the license in the accompanying LICENSE.txt file.
