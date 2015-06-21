//
//  FiltersViewController.h
//  Yelp
//
//  Created by Carter Chang on 6/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FiltersViewController;

@protocol FiltersViewControllerDelegate <NSObject>
-(void) filtersViewController: (FiltersViewController *)
filtersViewController didChangeFilters: (NSDictionary *) filters;

-(void) filtersViewController: (FiltersViewController *)
filtersViewController didChangeFilters: (NSDictionary *) filters
filterableCategories: (NSMutableArray*)categories
selectedCategories: (NSMutableSet*)selectedCategories;

@end

@interface FiltersViewController : UIViewController

@property (nonatomic, weak) id<FiltersViewControllerDelegate>delegate;

-(id) initWithCategories:(NSMutableArray *)categories andSelectedCategories:(NSMutableSet*)selectedCategories;
@end
