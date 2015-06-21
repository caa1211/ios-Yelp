//
//  FiltersViewController.m
//  Yelp
//
//  Created by Carter Chang on 6/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSArray *allCategories;
@property (nonatomic, strong) NSMutableSet *selectedCatrgories;
-(void) initCategories;
@end

@implementation FiltersViewController
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self){
        self.selectedCatrgories = [NSMutableSet set];
        [self initCategories];
    }
    return self;
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onSearch)];
    
    self.title = @"Filter";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
}

#pragma mark Private methods
-(NSDictionary *) filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if(self.selectedCatrgories.count > 0){
        NSMutableArray *names = [NSMutableArray array];
        for( NSDictionary *category in self.selectedCatrgories){
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
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
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
    self.categories = [[NSMutableArray alloc]init];
    
    for(NSDictionary *category in self.allCategories){
        NSArray *parents = category[@"parents"];
        if (parents.count> 0 && ![parents[0] isEqual:[NSNull null]] && [ (NSString *)parents[0] isEqualToString: @"restaurants"]) {
          [self.categories addObject:category];
        }
    }
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
        [self.selectedCatrgories addObject:self.categories[indexPath.row]];
    
    }else{
        [self.selectedCatrgories removeObject:self.categories[indexPath.row]];
    }
}

#pragma mark - Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    cell.delegate = self;
    cell.on = [self.selectedCatrgories containsObject:self.categories[indexPath.row]];
    cell.titleLabel.text = self.categories[indexPath.row][@"title"];
    return cell;
}



@end
