//
//  LFSDetailViewController.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LFSAuthor.h"
#import "LFSContent.h"

#import "LFSDetailView.h"

@protocol LFSDetailViewDelegate;

@interface LFSDetailViewController : UIViewController <LFSDetailViewDelegate>

@property (nonatomic, assign) BOOL hideStatusBar;

@property (nonatomic, copy) NSDictionary *collection;
@property (nonatomic, copy) NSString *collectionId;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) LFSContent *contentItem;

@property (assign, nonatomic) NSUInteger numberOfLikes;

@end
