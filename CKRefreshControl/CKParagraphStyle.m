// CKParagraphStyle.m
//
// Copyright (c) 2012 Instructure, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CKParagraphStyle.h"
#import <objc/objc-runtime.h>

static BOOL _isMasquerading = NO;

@implementation CKParagraphStyle

#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_5_1
#define IMP_WITH_BLOCK_TYPE __bridge void*
#else
#define IMP_WITH_BLOCK_TYPE id
#endif

static void *NSParagraphStyleKey;

- (id) initWithCoder: (NSCoder *) aDecoder
{
    return [super init];
}

// This is overridden so that things like
//    [object isKindOfClass:[NSParagraphStyle class]]
// will work on both iOS 5 and iOS 6.
+ (Class)class {
    Class nsParagraphStyleClass = NSClassFromString(@"NSParagraphStyle");
    if (nsParagraphStyleClass) {
        return nsParagraphStyleClass;
    }
    else {
        return [super class];
    }
}

+ (void) load
{
    if ([NSAttributedString instancesRespondToSelector:@selector(size)])
        return;
    
    // CKParagraphStyle will masquerade as UIRefreshControl
    static dispatch_once_t registerNSParagraphStyleClass_onceToken;
    dispatch_once(&registerNSParagraphStyleClass_onceToken, ^{
        Class nsParagraphStyleClass = objc_allocateClassPair([self class], "NSParagraphStyle", 0);
        objc_registerClassPair(nsParagraphStyleClass);
        _isMasquerading = YES;
        
        Class nsAttributedStringClass = [NSAttributedString class];
        IMP paragraphStyleIMP = imp_implementationWithBlock((IMP_WITH_BLOCK_TYPE)(^NSParagraphStyle *(id dynamicSelf) {
            return objc_getAssociatedObject(dynamicSelf, &NSParagraphStyleKey);
        }));
        BOOL added = class_addMethod(nsAttributedStringClass, @selector(paragraphStyle), paragraphStyleIMP, "@@:");
        NSAssert(added, @"We tried to add the paragraphStyle method, and it failed. This is going to break things, so we may as well stop here.");
        
        IMP setParagraphStyleIMP = imp_implementationWithBlock((IMP_WITH_BLOCK_TYPE)(^void(NSAttributedString *dynamicSelf, id paragraphStyle) {
            if (dynamicSelf.paragraphStyle == paragraphStyle) {
                return;
            }
            objc_setAssociatedObject(dynamicSelf, &NSParagraphStyleKey, paragraphStyle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }));
        
        added = class_addMethod(nsAttributedStringClass, @selector(setParagraphStyle:), setParagraphStyleIMP, "v@:@");
        NSAssert(added, @"We tried to add the setParagraphStyle: method, and it failed. This is going to break things, so we may as well stop here.");
    });
}
                  
@end
