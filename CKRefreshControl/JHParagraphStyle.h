//
//  JHParagraphStyle.h
//  CKRefreshControl
//
//  Created by John Haitas on 1/19/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHParagraphStyle : NSObject

@end


@class NSAttributedString;
@class NSParagraphStyle;
@interface NSAttributedString (CKRefreshControlAdditions)
// This will be added to the class at runtime if not already available
@property (nonatomic,retain) NSParagraphStyle *paragraphStyle;
@end