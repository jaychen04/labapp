//
//  TweetFriendsListViewController.m
//  iosapp
//
//  Created by 王晨 on 15/8/25.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "TweetFriendsListViewController.h"
#import "AppDelegate.h"
#import "Config.h"
#import "UIColor+Util.h"
#import "OSCUser.h"
#import "TweetFriendCell.h"
#import "UIImageView+Util.h"
#import "NSString+pinyin.h"

static NSString *kTweetFriendCellID = @"TweetFriendCell";

@interface TweetFriendsListViewController () <UISearchBarDelegate,UISearchDisplayDelegate,UISearchControllerDelegate>
@property (nonatomic,strong) NSMutableArray *selectedObjects;
@property (nonatomic,strong) NSMutableArray *filterObjects;
@property (nonatomic,strong) NSMutableArray *objectsWithIndex;
@property (nonatomic,strong) NSMutableArray *sectionTitles;
@property (nonatomic,strong) UISearchDisplayController *searchDisplay;

@end

@implementation TweetFriendsListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedObjects = @[].mutableCopy;
        self.filterObjects = @[].mutableCopy;
        self.generateURL = ^NSString * (NSUInteger page) {
                return [NSString stringWithFormat:@"%@%@?uid=%lld&all=1", OSCAPI_PREFIX, OSCAPI_FRIENDS_LIST,[Config getOwnID]];
        };
        self.objClass = [OSCUser class];

        __weak TweetFriendsListViewController * weakSelf = self;
        self.tableWillReload = ^void (NSUInteger responseObjectsCount) {
            UILocalizedIndexedCollation * indexCollation = [UILocalizedIndexedCollation currentCollation];

            weakSelf.sectionTitles = indexCollation.sectionTitles.mutableCopy;
            weakSelf.objectsWithIndex = @[].mutableCopy;
            [indexCollation.sectionTitles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                [weakSelf.objectsWithIndex addObject:@[].mutableCopy];

            }];
            [weakSelf.objects enumerateObjectsUsingBlock:^(OSCUser *object, NSUInteger idx, BOOL *stop) {
                NSString *pinyin = [object.name pinyin];
                object.pinyin = [pinyin stringByReplacingOccurrencesOfString:@" " withString:@""]; //去空格
                NSArray *pinyinArray = [pinyin componentsSeparatedByString:@" "]; //取首字母
                NSMutableString *pinyinStr = @"".mutableCopy;
                for (NSString *obj in pinyinArray) {
                    [pinyinStr appendString:[obj substringToIndex:1]];
                }
                object.pinyinFirst = pinyinStr;
                NSInteger section = [indexCollation sectionForObject:object.pinyin collationStringSelector:@selector(uppercaseString)];
                NSMutableArray *sectionArray = [weakSelf.objectsWithIndex objectAtIndex:section];
                [sectionArray addObject:object];
            }];
            
            for (NSInteger i = 0; i < [weakSelf.objectsWithIndex count]; i++) {
                if ([weakSelf.objectsWithIndex[i] count] == 0) {
                    [weakSelf.objectsWithIndex removeObjectAtIndex:i];
                    [weakSelf.sectionTitles removeObjectAtIndex:i];
                    i --;
                }
            }
        };
    }
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"friends"] childrenWithTag:@"friend"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"选择@好友";
    
    [self refresh_done];
    self.view.backgroundColor = [UIColor whiteColor];
   
    ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = [Config getMode];
    [self initSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor themeColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)initSubViews
{
    self.tableView.header = nil;
    self.tableView.footer = nil;
    self.tableView.tintColor = [UIColor colorWithHex:0x15A230];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor]; 
    [self.tableView registerClass:[TweetFriendCell class] forCellReuseIdentifier:kTweetFriendCellID];
    self.tableView.allowsMultipleSelection = YES;
    [self refresh_tableHeader];
    
    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 52)];
    searchBar.delegate = self;
//    searchBar.barTintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    searchBar.translucent = NO; //是否半透明
    [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [searchBar sizeToFit];
    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchDisplay.searchResultsTableView.tag = 1;
    [self.searchDisplay.searchResultsTableView registerClass:[TweetFriendCell class] forCellReuseIdentifier:kTweetFriendCellID];
    self.searchDisplay.delegate = self;
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;
}

#pragma mark table回调
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger result = 0;
    switch (tableView.tag) {
        case 0: {
            result = [self.objectsWithIndex count];
        }
            break;
        case 1: {
            result = 1;
        }
            break;
        default:
            break;
    }
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger result = 0;
    switch (tableView.tag) {
        case 0: {
            result = [self.objectsWithIndex[section] count];
        }
            break;
        case 1: {
            result = [self.filterObjects count];
        }
            break;
        default:
            break;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCUser *user = nil;
    switch (tableView.tag) {
        case 0: {
            user = self.objectsWithIndex[indexPath.section][indexPath.row];
        }
            break;
        case 1: {
            user = self.filterObjects[indexPath.row];
        }
            break;
        default:
            break;
    }

    TweetFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweetFriendCellID forIndexPath:indexPath];
    
    [cell.portrait loadPortrait:user.portraitURL];
    cell.nameLabel.text = user.name;
    cell.accessoryType = [self.selectedObjects containsObject:user]?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 52;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.indexPathsForSelectedRows.count >= 10) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"您最多可以一次选择10个好友"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles: nil];
        [alertView show];
        return nil;
    }
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    OSCUser *user = nil;
    switch (tableView.tag) {
        case 0: {
            user = self.objectsWithIndex[indexPath.section][indexPath.row];
        }
            break;
        case 1: {
            user = self.filterObjects[indexPath.row];
        }
            break;
        default:
            break;
    }
    if ([self.selectedObjects containsObject:user]) {
        [self.selectedObjects removeObject:user];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        [self.selectedObjects addObject:user];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if (tableView.tag == 0) {
        [self refresh_done];
        [self refresh_tableHeader];
    }

}

#pragma mark 索引回调
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 1) {
        return nil;
    }
    return self.sectionTitles[section];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView.tag == 1) {
        return nil;
    }
    return self.sectionTitles;
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([self.objectsWithIndex[index] count]) {
        // 获取所点目录对应的indexPath值
        NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        // 让table滚动到对应的indexPath位置
        [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    return index;
}
#pragma mark search 回调
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self.filterObjects removeAllObjects];
    NSString *upString = [searchString uppercaseString];
    [self.objects enumerateObjectsUsingBlock:^(OSCUser *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.name rangeOfString:upString].length ||
            [obj.pinyin rangeOfString:upString].length ||
            [obj.pinyinFirst rangeOfString:upString].length ) {
            [self.filterObjects addObject:obj];
        }
    }];
    return YES;
}
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [controller.searchBar removeFromSuperview];
    [self refresh_done];
    [self refresh_tableHeader];
    [self.tableView reloadData];
}
#pragma mark custom event
- (void)refresh_tableHeader {
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 52)];
    scrollView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = scrollView;
    
    CGFloat offsetX = 8;
    for (OSCUser *user in self.selectedObjects) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 8, 36, 36)];
        image.contentMode = UIViewContentModeScaleAspectFill;
        [image setCornerRadius:5.0];
        [image loadPortrait:user.portraitURL];
        [scrollView addSubview:image];
        
        offsetX += 36 + 8;
    }
    
    UIButton * searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(offsetX, 8, 30, 36);
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [searchBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(click_search) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:searchBtn];
    offsetX += 30;
    
    scrollView.contentSize = CGSizeMake(offsetX, 52);
}

- (void)refresh_done {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"确定(%ld/10)",[self.selectedObjects count]]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(click_done)];
}

- (void)click_done {
    if ([self.selectedObjects count]) {
        NSMutableString *result = @"".mutableCopy;
        [self.selectedObjects enumerateObjectsUsingBlock:^(OSCUser *obj, NSUInteger idx, BOOL *stop) {
            [result appendFormat:@"@%@ ",obj.name];
        }];
        self.selectDone(result);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)click_search {
    [self.view addSubview:self.searchDisplayController.searchBar];
    [self.searchDisplay.searchBar becomeFirstResponder];
    [self.searchDisplay setActive:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
