//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"
#import <TSMessage.h>
#import <SVProgressHUD.h>

NSString * const kYelpConsumerKey = @"eqGmxYAsZMnl9C3GKs137w";
NSString * const kYelpConsumerSecret = @"xfovXjjqxr5civdJp0sy1p1tq5k";
NSString * const kYelpToken = @"r8HXo7aGBqmHy4DeHCM3tnuSi8oXNcoM";
NSString * const kYelpTokenSecret = @"RJjIG-z0KeEFVGugtepuDc8grwo";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSDictionary *filters;
@property (nonatomic, strong) NSTimer *searchDelayer;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSMutableArray *filterableCategories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
-(void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;
@end


@implementation MainViewController

NSMutableArray *baseSearchTerms = nil;


-(void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        // NSLog(@"response: %@", response);
        NSArray *businessesDictionary = response[@"businesses"];
        self.businesses = [Business businessWithDictionaries:businessesDictionary];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
        
        [TSMessage showNotificationWithTitle:@"No items"
                                    subtitle:@"Please change the filters"
                                        type:TSMessageNotificationTypeWarning];
        
        NSArray *businessesDictionary = [[NSArray alloc]init];
        self.businesses = [Business businessWithDictionaries:businessesDictionary];
        [self.tableView reloadData];

        [SVProgressHUD dismiss];
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // base search terms is restaurants
    baseSearchTerms = [[NSMutableArray alloc] initWithObjects:@"restaurants",nil];

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self initSearchBar];
        
        self.searchTerm = [baseSearchTerms componentsJoinedByString:@","];
        [self fetchBusinessesWithQuery:self.searchTerm params:nil];
    }
    return self;
}
-(void)initSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(56, 0, 252, 44)];
    self.searchBar.translucent = NO;
    self.searchBar.placeholder = @"Restaurants";
    self.searchBar.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil]
         forCellReuseIdentifier:@"BusinessCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.title = @"";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    
    [self.navigationController.navigationBar addSubview:self.searchBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    
    cell.business = self.businesses[indexPath.row];
    return cell;
}

- (void)viewWillAppear:(BOOL)animated {
    // Fix height of cell be strange after filter view closing
    [super viewWillAppear:animated];
    self.tableView.estimatedRowHeight = 100.0; // for example. Set your average height
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //[self.tableView reloadData];
}

#pragma mark - Filter delegate methods

-(void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters
        filterableCategories: (NSMutableArray*)categories
        selectedCategories: (NSMutableSet*)selectedCategories
        sort:(NSString*)sort
        radius_filter: (NSString*)radius_filter;
{
    self.filters = filters;
    self.filterableCategories = categories;
    self.selectedCategories = selectedCategories;
    [self fetchBusinessesWithQuery:self.searchTerm params:self.filters];
}

#pragma mark - Private methods

-(void) onFilterButton {
    //FiltersViewController *vc = [[FiltersViewController alloc] init];
    
    FiltersViewController *vc = [[FiltersViewController alloc]
                                 initWithCategories:self.filterableCategories
                                 andSelectedCategories:self.selectedCategories];
    vc.delegate = self;

    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}


#pragma mark - Search

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.searchDelayer invalidate];
    self.searchDelayer = nil;
    
    self.searchDelayer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                   target:self
                                                   selector:@selector(doDelayedSearch)
                                                   userInfo:searchText
                                                   repeats:NO];
}

-(void) doDelayedSearch {
    NSLog(@"do search: %@", self.searchBar.text);
   
    NSMutableArray *termsAry = [baseSearchTerms mutableCopy];
    [termsAry addObject:self.searchBar.text];
    self.searchTerm = [termsAry componentsJoinedByString:@","];
    
    [self fetchBusinessesWithQuery: [NSString stringWithFormat: self.searchTerm, self.searchBar.text] params:self.filters];
    self.searchDelayer = nil;
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //[self fetchBusinessesWithQuery:self.searchBar.text params:self.filters];
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}


@end
