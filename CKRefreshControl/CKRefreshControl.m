// CKRefreshControl.m
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

#import "CKRefreshControl.h"
#import "CKRefreshArrowView.h"
#import "CKParagraphStyle.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error Add -fobjc-arc to the compile flags for CKRefreshControl.m
#endif

typedef enum {
    CKRefreshControlStateHidden,
    CKRefreshControlStatePulling,
    CKRefreshControlStateReady,
    CKRefreshControlStateRefreshing
} CKRefreshControlState;

@interface CKRefreshControl ()
@property (nonatomic) CKRefreshControlState refreshControlState;
@end

@implementation CKRefreshControl {
    UILabel *textLabel;
    UIActivityIndicatorView *spinner;
    CKRefreshArrowView *arrow;
    UIColor *defaultTintColor;
    CGFloat originalTopContentInset;
    CGFloat decelerationStartOffset;
}

- (id)init
{
    if (![[UIRefreshControl class] isSubclassOfClass:[CKRefreshControl class]])
        return (id)[[UIRefreshControl alloc] init];

    if (self = [super init])
    {
        [self commonInit];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
        
        if ([aDecoder containsValueForKey:@"UITintColor"])
        {
            self.tintColor = (UIColor *)[aDecoder decodeObjectForKey:@"UITintColor"];
            defaultTintColor = self.tintColor;
        }
        
        if ([aDecoder containsValueForKey:@"UIAttributedTitle"])
            self.attributedTitle = [aDecoder decodeObjectForKey:@"UIAttributedTitle"];

        // we can set its refresh control when the table view controller sets its view
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(tableViewControllerDidSetView:)
                                                     name: CKRefreshControl_UITableViewController_DidSetView_Notification
                                                   object: nil                                                              ];

    }
    return self;
}

- (void) commonInit
{
    self.frame = CGRectMake(0, 0, 320, 60);
    [self populateSubviews];
    [self setRefreshControlState:CKRefreshControlStateHidden];
    defaultTintColor = [UIColor colorWithWhite:0.5 alpha:1];
}

- (void) tableViewControllerDidSetView: (NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CKRefreshControl_UITableViewController_DidSetView_Notification
                                                  object:nil];

    UITableViewController *tableViewController = notification.object;
    if (tableViewController.refreshControl != (id)self)
        tableViewController.refreshControl = (id)self;
}

// remove notification observer in case notification never fired
- (void) awakeFromNib
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: CKRefreshControl_UITableViewController_DidSetView_Notification
                                                  object: nil                                                           ];
    [super awakeFromNib];
}

- (void)populateSubviews {
    CGRect frame = CGRectInset(self.bounds, 12, 12);
    arrow = [[CKRefreshArrowView alloc] initWithFrame:frame];
    arrow.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:arrow];
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    textLabel.textAlignment = UITextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    [self addSubview:textLabel];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = (CGPoint){
        .x = CGRectGetMidX(self.bounds),
        .y = CGRectGetMidY(self.bounds)
    };
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleTopMargin |
                                UIViewAutoresizingFlexibleBottomMargin);
    [self addSubview:spinner];
}

- (void)setTintColor: (UIColor *) tintColor
{
    if (!tintColor)
        tintColor = defaultTintColor;

    textLabel.textColor = tintColor;
    arrow.tintColor = tintColor;
    spinner.color = tintColor;
}

- (UIColor *)tintColor {
    return arrow.tintColor;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    _attributedTitle = attributedTitle;
    textLabel.text = attributedTitle.string;
}

- (void)beginRefreshing {
    _refreshing = YES;
    [self setRefreshControlState:CKRefreshControlStateRefreshing];
}

- (void)endRefreshing {
    _refreshing = NO;
    [self setRefreshControlState:CKRefreshControlStateHidden];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSString *text = self.attributedTitle.string;
    CGPoint center =(CGPoint){
        .x = CGRectGetMidX(self.bounds),
        .y = CGRectGetMidY(self.bounds)
    };
    
    if (text.length > 0) {
        CGPoint newArrowCenter = (CGPoint){.x = center.x, .y = center.y - 10};
        arrow.center = spinner.center = newArrowCenter;
        textLabel.frame = (CGRect){
            .origin.x = 0,
            .origin.y = CGRectGetMaxY(self.bounds) - 25,
            .size.width = CGRectGetWidth(self.bounds),
            .size.height = 25
        };
    }
    else {
        arrow.center = spinner.center = center;
        textLabel.frame = CGRectZero;
    }
}

- (void)setRefreshControlState:(CKRefreshControlState)refreshControlState {
    
    _refreshControlState = refreshControlState;
    switch (refreshControlState) {
        case CKRefreshControlStateHidden:
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 0.0;
            }];
            break;
        }
            
        case CKRefreshControlStatePulling:
        case CKRefreshControlStateReady:
            self.alpha = 1.0;
            arrow.alpha = 1.0;
            textLabel.alpha = 1.0;
            break;
            
        case CKRefreshControlStateRefreshing:
            self.alpha = 1.0;
            [UIView animateWithDuration: 0.2
                             animations:^{
                                 arrow.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 [spinner startAnimating];
                             }];
            break;
    };
    
    
    
    UIEdgeInsets contentInset = UIEdgeInsetsMake(originalTopContentInset, 0, 0, 0);
    if (refreshControlState == CKRefreshControlStateRefreshing) {
        contentInset = UIEdgeInsetsMake(self.frame.size.height + originalTopContentInset, 0, 0, 0);
    }
    else {
        [spinner stopAnimating];
    }
    
    
    UIScrollView *scrollView = nil;
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)self.superview;
    }
    
    if(!UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, contentInset)) {
        [UIView animateWithDuration:0.2 animations:^{
            scrollView.contentInset = contentInset;
        }];
    }
    
}

static void *contentOffsetObservingKey = &contentOffsetObservingKey;

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self.superview removeObserver:self forKeyPath:@"contentOffset" context:contentOffsetObservingKey];
}

- (void)didMoveToSuperview {
    UIView *superview = self.superview;
    
    // Reposition ourself in the scrollview
    if ([superview isKindOfClass:[UIScrollView class]]) {
        [self repositionAboveContent];
        
        [superview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld context:contentOffsetObservingKey];
        
        originalTopContentInset = [(UIScrollView *)superview contentInset].top;
    }
    // Set the 'UITableViewController.refreshControl' property, if applicable
    if ([superview isKindOfClass:[UITableView class]]) {
        UITableViewController *tableViewController = (UITableViewController *)superview.nextResponder;
        if ([tableViewController isKindOfClass:[UITableViewController class]]) {
            if (tableViewController.refreshControl != (id)self)
                tableViewController.refreshControl = (id)self;
        }
    }
}

- (void)repositionAboveContent {
    CGRect scrollBounds = self.superview.bounds;
    CGFloat height = self.bounds.size.height;
    CGRect newFrame = (CGRect){
        .origin.x = 0,
        .origin.y = -height,
        .size.width = scrollBounds.size.width,
        .size.height = height
    };
    self.frame = newFrame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != contentOffsetObservingKey) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if ([self.superview isKindOfClass:[UIScrollView class]] == NO) {
        return;
    }
    UIScrollView *scrollview = (UIScrollView *)self.superview;
    CGFloat pullHeight = -scrollview.contentOffset.y - originalTopContentInset;
    CGFloat triggerHeight = self.bounds.size.height;
    CGFloat previousPullHeight = -[change[NSKeyValueChangeOldKey] CGPointValue].y;
    
    // Update the progress arrow
    CGFloat progress = pullHeight / triggerHeight;
    CGFloat deadZone = 0.3;
    if (progress > deadZone) {
        CGFloat arrowProgress = ((progress - deadZone) / (1 - deadZone));
        arrow.progress = arrowProgress;
    }
    else {
        arrow.progress = 0.0;
    }
    
    
    // Track when deceleration starts
    if (scrollview.isDecelerating == NO) {
        decelerationStartOffset = 0;
    }
    else if (scrollview.isDecelerating && decelerationStartOffset == 0) {
        decelerationStartOffset = scrollview.contentOffset.y;
    }

    
    // Transition to the next state
    if (self.refreshControlState == CKRefreshControlStateRefreshing) {
        // No state transitions necessary
    }
    else if (decelerationStartOffset > 0) {
        // Deceleration started before reaching the header 'rubber band' area; hide the refresh control
        self.refreshControlState = CKRefreshControlStateHidden;
    }
    else if (pullHeight >= triggerHeight || (pullHeight > 0 && previousPullHeight >= triggerHeight)) {

        if (scrollview.isDragging) {
            // Just waiting for them to let go, then we'll refresh
            self.refreshControlState = CKRefreshControlStateReady;
        }
        else if (([self allControlEvents] & UIControlEventValueChanged) == 0) {
            NSLog(@"No action configured for UIControlEventValueChanged event, not transitioning to refreshing state");
        }
        else {
            // They let go! Refresh!
            self.refreshControlState = CKRefreshControlStateRefreshing;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    else if (scrollview.decelerating == NO && pullHeight > 0) {
        self.refreshControlState = CKRefreshControlStatePulling;
    }
    else {
        self.refreshControlState = CKRefreshControlStateHidden;
    }
    
    if (pullHeight > self.bounds.size.height) {
        // Center in the rubberbanding area
        CGPoint rubberBandCenter = (CGPoint) {
            .x = CGRectGetMidX(self.superview.bounds),
            .y = scrollview.contentOffset.y / 2.0
        };
        self.center = rubberBandCenter;
    }
    else {
        [self repositionAboveContent];
    }
}

#pragma mark - Class methods

+ (Class) class
{
    // cannot call +class from inside this method
    Class uiRefreshControlClass = NSClassFromString(@"UIRefreshControl");
    Class ckRefreshControlClass = NSClassFromString(@"CKRefreshControl");
    
    if (![self isSubclassOfClass:ckRefreshControlClass])
        return uiRefreshControlClass;

    return [super class];
}

// If UIRefreshControl is available, we need to customize that class, not
// CKRefreshControl. Otherwise, the +appearance proxy is broken on iOS 6.
+ (id)appearance
{
    if (![[UIRefreshControl class] isSubclassOfClass:[CKRefreshControl class]])
        return [UIRefreshControl appearance];

    if ([self isEqual:[UIRefreshControl class]])
        return [CKRefreshControl appearance];

    return [super appearance];
}

+ (id)appearanceWhenContainedIn:(Class<UIAppearanceContainer>)ContainerClass, ...
{
    va_list list;
    va_start(list, ContainerClass);
    
    Class classes[10] = {0};
    
    for (int i=0; i<10; ++i) {
        Class c = va_arg(list, Class);
        if (c == Nil) {
            break;
        }
        classes[i] = c;
    }
    va_end(list);

    if (![[UIRefreshControl class] isSubclassOfClass:[CKRefreshControl class]])
        return [UIRefreshControl appearanceWhenContainedIn:ContainerClass, classes[0], classes[1], classes[2], classes[3], classes[4], classes[5], classes[6], classes[7], classes[8], classes[9], nil];

    if ([self isEqual:[UIRefreshControl class]])
        return [CKRefreshControl appearanceWhenContainedIn:ContainerClass, classes[0], classes[1], classes[2], classes[3], classes[4], classes[5], classes[6], classes[7], classes[8], classes[9], nil];

    return [super appearanceWhenContainedIn:ContainerClass, classes[0], classes[1], classes[2], classes[3], classes[4], classes[5], classes[6], classes[7], classes[8], classes[9], nil];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_5_1
#define IMP_WITH_BLOCK_TYPE __bridge void*
#else
#define IMP_WITH_BLOCK_TYPE id
#endif

typedef IMP *IMPPointer;

static void *CKRefreshControlKey;

static BOOL class_swizzleMethodAndStore(Class class, SEL original, IMP replacement, IMPPointer store)
{
    IMP imp = NULL;
    Method method = class_getInstanceMethod(class, original);
    
    if (method)
    {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(class, original, replacement, type);
        
        if (!imp)
            imp = method_getImplementation(method);
    }
    
    if (imp && store)
        *store = imp;
    
    return (imp != NULL);
}

NSString *const CKRefreshControl_UITableViewController_DidSetView_Notification = @"CKRefreshControl_UITableViewController_DidSetView";
static void CKRefreshControl_UITableViewController_SetView(UITableViewController *dynamicSelf, SEL _cmd, UITableView *view);
static void (*UITableViewController_SetViewIMP)(UITableViewController *dynamicSelf, SEL _cmd, UITableView *view);
static void CKRefreshControl_UITableViewController_SetView(UITableViewController *dynamicSelf, SEL _cmd, UITableView *view)
{
    UITableViewController_SetViewIMP(dynamicSelf, _cmd, view);
    [[NSNotificationCenter defaultCenter] postNotificationName:CKRefreshControl_UITableViewController_DidSetView_Notification object:dynamicSelf];
}


// +load has some inline asm. When compiling a reference to a class name (e.g. UIRefreshControl),
// the compiler emits "L_OBJC_CLASS_UIRefreshControl". If this label is nil or doesn't exist, the
// class reference will be Nil. So we need to manually set the value at that label, and then
// register the class with the runtime. That's all that's going on here. For a line-by-line
// breakdown of what's going on, see https://gist.github.com/OliverLetterer/4643294/

+ (void)load
{
    if (objc_getClass("UIRefreshControl"))
        return;

    // CKRefreshControl will masquerade as UIRefreshControl
    static dispatch_once_t registerUIRefreshControlClass_onceToken;
    dispatch_once(&registerUIRefreshControlClass_onceToken, ^{

        Class *UIRefreshControlClassRef = NULL;
#if TARGET_CPU_ARM
        __asm(
              "movw %0, :lower16:(L_OBJC_CLASS_UIRefreshControl-(LPC0+4))\n"
              "movt %0, :upper16:(L_OBJC_CLASS_UIRefreshControl-(LPC0+4))\n"
              "LPC0: add %0, pc" : "=r"(UIRefreshControlClassRef)
              );
#elif TARGET_CPU_X86_64
        __asm("leaq L_OBJC_CLASS_UIRefreshControl(%%rip), %0" : "=r"(UIRefreshControlClassRef));
#elif TARGET_CPU_X86
        void *pc = NULL;
        __asm(
              "calll L0\n"
              "L0: popl %0\n"
              "leal L_OBJC_CLASS_UIRefreshControl-L0(%0), %1" : "=r"(pc), "=r"(UIRefreshControlClassRef)
              );
#else
#error Unsupported CPU
#endif
        if (UIRefreshControlClassRef && *UIRefreshControlClassRef == Nil)
        {
            *UIRefreshControlClassRef = objc_allocateClassPair(self, "UIRefreshControl", 0);
            objc_registerClassPair(*UIRefreshControlClassRef);
        }
        
        // Add UITableViewController.refreshControl if it isn't present
        Class tableViewController = [UITableViewController class];
        IMP refreshControlIMP = imp_implementationWithBlock((IMP_WITH_BLOCK_TYPE)(^id(id dynamicSelf) {
            return objc_getAssociatedObject(dynamicSelf, &CKRefreshControlKey);
        }));
        BOOL added = class_addMethod(tableViewController, @selector(refreshControl), refreshControlIMP, "@@:");
        
        NSAssert(added, @"We tried to add the refreshControl method, and it failed. This is going to break things, so we may as well stop here.");


        IMP setRefreshControlIMP = imp_implementationWithBlock((IMP_WITH_BLOCK_TYPE)(^void(UITableViewController *dynamicSelf, id newControl) {
            if (dynamicSelf.refreshControl == newControl) {
                return;
            }
            objc_setAssociatedObject(dynamicSelf, &CKRefreshControlKey, newControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

            if ([newControl superview] != dynamicSelf.tableView) {
                [dynamicSelf.tableView addSubview:newControl];
            }
        }));

        added = class_addMethod(tableViewController, @selector(setRefreshControl:), setRefreshControlIMP, "v@:@");
        NSAssert(added, @"We tried to add the setRefreshControl: method, and it failed. This is going to break things, so we may as well stop here.");

        // swizzle setView: method so we can post notification to CKRefreshControl ...
        // CKRefreshControl will assign itself to the UIViewController
        class_swizzleMethodAndStore(tableViewController,
                                    @selector(setView:),
                                    (IMP)CKRefreshControl_UITableViewController_SetView,
                                    (IMP *)&UITableViewController_SetViewIMP            );
    });
}

// This is just declaring the L_OBJC_CLASS_UIRefreshControl label, so that we can reference it in +load.
// Again, see https://gist.github.com/OliverLetterer/4643294/ for more information.

__asm(
      ".section        __DATA,__objc_classrefs,regular,no_dead_strip\n"
#if	TARGET_RT_64_BIT
      ".align          3\n"
      "L_OBJC_CLASS_UIRefreshControl:\n"
      ".quad           _OBJC_CLASS_$_UIRefreshControl\n"
#else
      ".align          2\n"
      "L_OBJC_CLASS_UIRefreshControl:\n"
      ".long           _OBJC_CLASS_$_UIRefreshControl\n"
#endif
      ".weak_reference _OBJC_CLASS_$_UIRefreshControl\n"
      );

@end
