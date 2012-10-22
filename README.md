# CKRefreshControl

Open source 100% API-compatible replacement for `UIRefreshControl`, supporting iOS 5.0+

Using it is as simple as this:

    UITableViewController *controller;

    CKRefreshControl *refreshControl = [CKRefreshControl new];
    [refreshControl addTarget:self action:@selector(doRefresh:) forControlEvents:UIControlEventValueChanged];
    controller.refreshControl = (id)refreshControl;

![iOS 5 example](/instructure/CKRefreshControl/raw/readme-resources/iOS5.png) &nbsp; 
![iOS 6 example](/instructure/CKRefreshControl/raw/readme-resources/iOS6.png)

----

### API Compatible

CKRefreshControl has exactly the same public API as UIRefreshControl. Thus, your code can treat either one as an instance of the other. Just use CKRefreshControl instead of UIRefreshControl everywhere, and you'll magically get iOS 5 support.

We take advantage of this to provide excellent iOS 6 compatibility. When running on an iOS 6 device, `-[CKRefreshControl init]` actually returns a `UIRefreshControl` instance. No CKRefreshControl is ever initialized, and everything will work exactly as if CKRefreshControl did not even exist.

You can even use the `+appearance` proxies introduced in iOS 5.0; CKRefreshControl will appropriately forward the customizations to UIRefreshControl on iOS 6.

There is only one minor inconvenience. The `-[UITableViewController setRefreshControl:]` method in iOS 6 accepts a `UIRefreshControl *` parameter. Although CKRefreshControl is API compatible with UIRefreshControl, it is not a subclass (so it can be used on iOS 5). Thus, the compiler does not know that CKRefreshControl can be used as a UIRefreshControl. Thus, you must add an explicit cast to avoid a compiler warning. This is completely safe.

---

### Appearance

CKRefreshControl intentionally does not mimic the iOS 6 UIRefreshControl look and feel. Instead, it was designed to look more like the other pull-to-refresh controls commonly used in iOS 5 apps. Thus, whether the user is running iOS 5 or iOS 6, they get an interface that fits in with other apps on the device.

Despite the difference in interface between iOS 5 and iOS 6, CKRefreshControl supports the  same properties UIRefreshControl does.

---

### Why the name?

CKRefreshControl was originally part of our internal "CanvasKit" library, used in building Instructure's iOS apps. 

---

### But does it work?

Yes! Instructure is using it in shipping code with no problems. That said, if you find a bug, please let us know and we'll make it work. 

--- 

### License

CKRefreshControl, and all the accompanying source code, is released under the MIT license. You can see the full text of the license in the accompanying LICENSE.txt file.