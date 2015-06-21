//
//  Business.m
//  Yelp
//
//  Created by Carter Chang on 6/20/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id) initWithDictionary:dictionary {
    self = [super init];
    if(self){
        NSArray *categories = dictionary[@"cagegories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:categories[0]];
        }];
        
        self.categories = [categoryNames componentsJoinedByString:@", "];
        self.name = dictionary[@"name"];
        self.imageUrl = dictionary[@"image_url"];
        self.ratingImageUrl = dictionary[@"rating_img_url"];
        self.numReviews = [dictionary[@"review_count"] integerValue];
        NSString *street = @"";
        if ( ((NSArray *)[dictionary valueForKeyPath:@"location.address"]).count > 0 ) {
            street = [dictionary valueForKeyPath:@"location.address"][0];
        }
        NSString *neighborhood = @"";
        if ( ((NSArray *)[dictionary valueForKeyPath:@"location.neighborhoods"]).count > 0 ) {
            neighborhood = [dictionary valueForKeyPath:@"location.neighborhoods"][0];
        }
        self.address = [NSString stringWithFormat:@"%@, %@", street, neighborhood];
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] floatValue] * milesPerMeter;
    }
    return self;
}

+ (NSArray *)businessWithDictionaries: (NSArray *)dictionaries {
    NSMutableArray *businesses = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries){
        Business *business = [[Business alloc]initWithDictionary:dictionary];
        [businesses addObject:business];
    }
    
    return businesses;
}
@end
