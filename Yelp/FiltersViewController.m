//
//  FiltersViewController.m
//  Yelp
//
//  Created by Carter Chang on 6/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import "DDParentCell.h"
#import "DDChildCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSArray *allCategories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
-(void) initCategories;
@end

#define MMPI 3.1415926

@implementation FiltersViewController

enum {
    DealSection = 0,
    DistanceSection,
    SortBySection,
    CategorySection
};

NSMutableIndexSet *expandedSections;
NSArray *allDistance = nil;
NSMutableArray *selectableDistance = nil;
NSDictionary *distanceFilter = nil;

NSArray *allSortBy = nil;
NSMutableArray *selectableSortBy = nil;
NSDictionary *sortByFilter = nil;

- (void) initVariables {
    
    allDistance = @[
                    @{@"title": @"Auto", @"value": @0},
                    @{@"title": @"0.3 miles", @"value": @483},
                    @{@"title": @"1 mile", @"value": @1609},
                    @{@"title": @"5 miles", @"value": @8047},
                    @{@"title": @"20 miles", @"value": @32187}
                   ];
    distanceFilter = allDistance[0];
    
    allSortBy = @[
                    @{@"title": @"Best Matched", @"value": @0},
                    @{@"title": @"Distance", @"value": @1},
                    @{@"title": @"Highest Rated", @"value": @2}
                    ];
     sortByFilter = allSortBy[0];
}

- (id) initWithCategories:(NSMutableArray *)categories andSelectedCategories:(NSMutableSet*)selectedCategories {
    
    if ((self = [super initWithNibName:@"FiltersViewController" bundle:nil]))
    {
        if (categories != nil && selectedCategories!=nil){
            self.categories = categories;
            self.selectedCategories = selectedCategories;
        }else{
            self.selectedCategories = [NSMutableSet set];
            self.categories = [[NSMutableArray alloc]init];
            [self initCategories];
        }
        [self initVariables];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onSearch)];
    
    self.title = @"Filter";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DDParentCell" bundle:nil] forCellReuseIdentifier:@"DDParentCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DDChildCell" bundle:nil] forCellReuseIdentifier:@"DDChildCell"];
    
     expandedSections = [[NSMutableIndexSet alloc] init];
}

#pragma mark Private methods
-(NSDictionary *) filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if(self.selectedCategories.count > 0){
        NSMutableArray *names = [NSMutableArray array];
        for( NSDictionary *category in self.selectedCategories){
            [names addObject:category[@"alias"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    return filters;
}

-(void) onCancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) onSearch{
    [self.delegate filtersViewController:self didChangeFilters:self.filters
                        filterableCategories:self.categories
                        selectedCategories:self.selectedCategories
                        sort: sortByFilter[@"value"]
                        radius_filter: distanceFilter[@"value"]
     ];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initCategories {
        
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"categories"
                                                             ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:jsonPath];
        NSError *error = nil;
        
        self.allCategories = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
    
        
        for(NSDictionary *category in self.allCategories){
            NSArray *parents = category[@"parents"];
            if (parents.count> 0 && ![parents[0] isEqual:[NSNull null]] && [ (NSString *)parents[0] isEqualToString: @"restaurants"]) {
                [self.categories addObject:category];
            }
        }
    //}
    // NSLog(@"JSON: %@", json);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Switch cell delegate
-(void) switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
    if(value){
        [self.selectedCategories addObject:self.categories[indexPath.row]];
    
    }else{
        [self.selectedCategories removeObject:self.categories[indexPath.row]];
    }
}

#pragma mark - Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num;
    switch (section) {
        case DealSection:
            num = 1;
            break;
        case DistanceSection:
            if ([expandedSections containsIndex:section]) {
                return 5;
            } else {
                return 1;
            }
            break;
        case SortBySection:
            if ([expandedSections containsIndex:section]) {
                return 3;
            } else {
                return 1;
            }
            break;
        case CategorySection:
        default:
            num = 7;
            break;
    }
    return num;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    UITableViewCell *cell = nil;
    switch (section) {
        case DealSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            ((SwitchCell*)cell).delegate = self;
            ((SwitchCell*)cell).on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            ((SwitchCell*)cell).titleLabel.text = @"Offering a Deal";
            break;
        case DistanceSection:
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DDParentCell"];
                ((DDParentCell*)cell).titleLabel.text = distanceFilter[@"title"];
            } else {
                /* Child cell */
                cell = [tableView dequeueReusableCellWithIdentifier:@"DDChildCell"];
                ((DDChildCell*)cell).titleLabel.text = selectableDistance[indexPath.row][@"title"];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case SortBySection:
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DDParentCell"];
                ((DDParentCell*)cell).titleLabel.text = sortByFilter[@"title"];
            } else {
                /* Child cell */
                cell = [tableView dequeueReusableCellWithIdentifier:@"DDChildCell"];
                ((DDChildCell*)cell).titleLabel.text = selectableSortBy[indexPath.row][@"title"];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case CategorySection:
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            ((SwitchCell*)cell).delegate = self;
            ((SwitchCell*)cell).on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            ((SwitchCell*)cell).titleLabel.text = self.categories[indexPath.row][@"title"];
            break;
    }
    
    if (indexPath.row == 0) {
        /* Parent cell */
        NSLog(@"Parent");
        
    } else {
        /* Child cell */
        NSLog(@"Child");
    }
    
    
//    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
//    cell.delegate = self;
//    cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
//    cell.titleLabel.text = self.categories[indexPath.row][@"title"];
      return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case DealSection:
            return @" ";
            break;
            
        case DistanceSection:
            return @"Distance";
            break;
            
        case SortBySection:
            return @"Sort By";
            break;
            
        case CategorySection:
        default:
            return @"Category";
            break;
    }
}

- (NSMutableArray *) subTableRows:(NSInteger)section
                     withTableView:(UITableView*)tableView
                     andExpandedStatus:(BOOL)currentlyExpanded{
    NSInteger rows;
    NSMutableArray *arrRows = [NSMutableArray array];
    
    if (currentlyExpanded) {
        /* Child cell for this parent */
        rows = [self tableView:tableView numberOfRowsInSection:section];
        [expandedSections removeIndex:section];
    } else {
        [expandedSections addIndex:section];
        rows = [self tableView:tableView numberOfRowsInSection:section];
    }
    
    for (int i = 1; i < rows; i++) {
        NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i inSection:section];
        [arrRows addObject:tmpIndexPath];
    }
    return arrRows;

}

- (void)rotateImageView:(UIImageView*)imageView angle:(CGFloat)angle
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [imageView setTransform:CGAffineTransformRotate(imageView.transform, angle)];
    }completion:^(BOOL finished){
    }];
}

- (void) toggleDistanceSelector:(NSIndexPath *)indexPath withTableView:(UITableView*)tableView{
    NSInteger section = indexPath.section;
    BOOL currentlyExpanded = [expandedSections containsIndex:section];
    
    NSMutableArray *arrRows = [self subTableRows:section withTableView:tableView andExpandedStatus:currentlyExpanded];
    
    selectableDistance = [allDistance mutableCopy];
    [selectableDistance removeObject:distanceFilter];
    [selectableDistance insertObject:distanceFilter atIndex:0];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (currentlyExpanded) {
        [tableView deleteRowsAtIndexPaths:arrRows withRowAnimation:UITableViewRowAnimationTop];
        ((DDParentCell *)cell).titleLabel.text = distanceFilter[@"title"];
        [self rotateImageView:((DDParentCell *)cell).arrowIcon angle:-1*MMPI];
    } else {
        [tableView insertRowsAtIndexPaths:arrRows withRowAnimation:UITableViewRowAnimationTop];
        ((DDParentCell *)cell).titleLabel.text = distanceFilter[@"title"];
        [self rotateImageView:((DDParentCell *)cell).arrowIcon angle:MMPI];
    }
}

- (void) toggleSortBySelector:(NSIndexPath *)indexPath withTableView:(UITableView*)tableView{
    NSInteger section = indexPath.section;
    BOOL currentlyExpanded = [expandedSections containsIndex:section];
    
    NSMutableArray *arrRows = [self subTableRows:section withTableView:tableView andExpandedStatus:currentlyExpanded];
    
    selectableSortBy = [allSortBy mutableCopy];
    [selectableSortBy removeObject:sortByFilter];
    [selectableSortBy insertObject:sortByFilter atIndex:0];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (currentlyExpanded) {
        [tableView deleteRowsAtIndexPaths:arrRows withRowAnimation:UITableViewRowAnimationTop];
        ((DDParentCell *)cell).titleLabel.text = sortByFilter[@"title"];
        [self rotateImageView:((DDParentCell *)cell).arrowIcon angle:-1*MMPI];
    } else {
        [tableView insertRowsAtIndexPaths:arrRows withRowAnimation:UITableViewRowAnimationTop];
        ((DDParentCell *)cell).titleLabel.text = sortByFilter[@"title"];
        [self rotateImageView:((DDParentCell *)cell).arrowIcon angle:MMPI];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;

    switch (section) {
        case DistanceSection:
            if (indexPath.row == 0) {
                [self toggleDistanceSelector:indexPath withTableView:tableView];
            }else {
                distanceFilter = selectableDistance[indexPath.row];
                selectableDistance = nil;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [(DDChildCell *)cell addMark];
                NSIndexPath *parentIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
               [self toggleDistanceSelector:parentIndexPath withTableView:tableView];
                //NSLog(@"click Child %ld", indexPath.row);
            }
            break;
            
        case SortBySection:
            if (indexPath.row == 0) {
                [self toggleSortBySelector:indexPath withTableView:tableView];
            }else {
                sortByFilter = selectableSortBy[indexPath.row];
                selectableSortBy = nil;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [(DDChildCell *)cell addMark];
                NSIndexPath *parentIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                [self toggleSortBySelector:parentIndexPath withTableView:tableView];
                //NSLog(@"click Child %ld", indexPath.row);
            }
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


#pragma mark - style table section header

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 25;
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50.0f)];
//
//    [view setBackgroundColor:UIColorFromRGB(0xf7f7f7)];
//    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 150, 25)];
//    [lbl setFont:[UIFont boldSystemFontOfSize:16]];
//    [lbl setTextColor:[UIColor grayColor]];
//    [view addSubview:lbl];
//    
//    [lbl setText:[NSString stringWithFormat:@"%@", [self tableView:self.tableView titleForHeaderInSection:section]]];
//    
//    return view;
//}



@end
