//
//  Business.h
//  Yelp
//
//  Created by Carter Chang on 6/20/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Business : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ratingImageUrl;
@property (nonatomic, assign) NSInteger numReviews;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSString *snippetText;
@property (nonatomic, assign) CGFloat distance;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;


+ (NSArray *)businessWithDictionaries: (NSArray *)dictionaries;

@end
