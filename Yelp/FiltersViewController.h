//
//  FiltersViewController.h
//  Yelp
//
//  Created by Carter Chang on 6/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@class FiltersViewController;

@protocol FiltersViewControllerDelegate <NSObject>

-(void) filtersViewController: (FiltersViewController *)
filtersViewController didChangeFilters: (NSDictionary *) filters
         filterableCategories: (NSMutableArray*)categories
         selectedCategories: (NSMutableSet*)selectedCategories
         sort:(NSString*)sort
         radius_filter: (NSString*)radius_filter
         deal: (BOOL)deal;
@end

@interface FiltersViewController : UIViewController

@property (nonatomic, weak) id<FiltersViewControllerDelegate>delegate;

-(id) initWithCategories:(NSMutableArray *)categories
   andSelectedCategories:(NSMutableSet*)selectedCategories
   sort: (NSString*)sort
   radius_filter: (NSString*) radius_filter
   deal: (BOOL)deal;
@end
