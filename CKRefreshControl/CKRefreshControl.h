// CKRefreshControl.h
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

#import <UIKit/UIKit.h>

/* This is an API-compatible replacement of UIRefreshControl
 * It is intended to be an API-compatible replacement
 * for platforms where UIRefreshControl is not available.
 */

@interface CKRefreshControl : UIControl


/* The designated initializer
 * This initializes a CKRefreshControl with a default height and width.
 * Once assigned to a UITableViewController, the frame of the control is managed automatically.
 * When a user has pulled-to-refresh, the CKRefreshControl fires its UIControlEventValueChanged event.
 */
- (id)init;

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

// This 'Tint Color' will set the text color and spinner color
@property (nonatomic, retain) UIColor *tintColor UI_APPEARANCE_SELECTOR; // Default = 0.5 gray, 1.0 alpha
@property (nonatomic, retain) NSAttributedString *attributedTitle UI_APPEARANCE_SELECTOR;

// May be used to indicate to the refreshControl that an external event has initiated the refresh action
- (void)beginRefreshing;
// Must be explicitly called when the refreshing has completed
- (void)endRefreshing;


@end


@class UIRefreshControl;
@interface UITableViewController (CKRefreshControlAdditions)
// This will be added to the class at runtime if not already available
@property (nonatomic,retain) UIRefreshControl *refreshControl;
@end
