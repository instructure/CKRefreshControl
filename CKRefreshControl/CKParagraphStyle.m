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
        
        Class *NSParagraphStyleClassRef = NULL;
#if TARGET_CPU_ARM
        __asm(
              "movw %0, :lower16:(L_OBJC_CLASS_NSParagraphStyle-(LPC0+4))\n"
              "movt %0, :upper16:(L_OBJC_CLASS_NSParagraphStyle-(LPC0+4))\n"
              "LPC0: add %0, pc" : "=r"(NSParagraphStyleClassRef)
              );
#elif TARGET_CPU_X86_64
        __asm("leaq L_OBJC_CLASS_NSParagraphStyle(%%rip), %0" : "=r"(NSParagraphStyleClassRef));
#elif TARGET_CPU_X86
        void *pc = NULL;
        __asm(
              "calll L0\n"
              "L0: popl %0\n"
              "leal L_OBJC_CLASS_NSParagraphStyle-L0(%0), %1" : "=r"(pc), "=r"(NSParagraphStyleClassRef)
              );
#else
#error Unsupported CPU
#endif
        if (NSParagraphStyleClassRef && *NSParagraphStyleClassRef == Nil)
            *NSParagraphStyleClassRef = objc_duplicateClass(self, "NSParagraphStyle", 0);
    });
}
__asm(
#if defined(__OBJC2__) && __OBJC2__
      ".section        __DATA,__objc_classrefs,regular,no_dead_strip\n"
#if	TARGET_RT_64_BIT
      ".align          3\n"
      "L_OBJC_CLASS_NSParagraphStyle:\n"
      ".quad           _OBJC_CLASS_$_NSParagraphStyle\n"
#else
      ".align          2\n"
      "L_OBJC_CLASS_NSParagraphStyle:\n"
      ".long           _OBJC_CLASS_$_NSParagraphStyle\n"
#endif
#else
      ".section        __TEXT,__cstring,cstring_literals\n"
      "L_OBJC_CLASS_NAME_NSParagraphStyle:\n"
      ".asciz          \"NSParagraphStyle\"\n"
      ".section        __OBJC,__cls_refs,literal_pointers,no_dead_strip\n"
      ".align          2\n"
      "L_OBJC_CLASS_NSParagraphStyle:\n"
      ".long           L_OBJC_CLASS_NAME_NSParagraphStyle\n"
#endif
      ".weak_reference _OBJC_CLASS_$_NSParagraphStyle\n"
      );
                  
@end
