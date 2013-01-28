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
#import <objc/runtime.h>

@implementation CKParagraphStyle

#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_5_1
#define IMP_WITH_BLOCK_TYPE __bridge void*
#else
#define IMP_WITH_BLOCK_TYPE id
#endif

- (id) initWithCoder: (NSCoder *) aDecoder
{
    return [super init];
}

+ (void) load
{
    if (objc_getClass("NSParagraphStyle"))
        return;
    
    // CKParagraphStyle will masquerade as NSParagraphStyle
    static dispatch_once_t registerNSParagraphStyleClass_onceToken;
    dispatch_once(&registerNSParagraphStyleClass_onceToken, ^{
        Class nsParagraphStyleClass = NSClassFromString(@"NSParagraphStyle");
        if (!nsParagraphStyleClass)
        {
            nsParagraphStyleClass = objc_allocateClassPair(self, "NSParagraphStyle", 0);
            objc_registerClassPair(nsParagraphStyleClass);
        }
    });
}
                  
@end
