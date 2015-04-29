//
//  TeamMemberViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 3/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamMemberViewController.h"
#import "TeamAPI.h"
#import "TeamMember.h"
#import "MemberCell.h"
#import "Utils.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

static NSString * const kMemberCellID = @"MemberCell";

@interface TeamMemberViewController ()

@property (nonatomic, assign) int teamID;
@property (nonatomic, strong) NSMutableArray *members;

@end

@implementation TeamMemberViewController

- (instancetype)initWithTeamID:(int)teamID
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    flowLayout.minimumInteritemSpacing = (screenWidth - 40 - 30 * 7) / 7;
    flowLayout.minimumLineSpacing = 25;
    flowLayout.itemSize = CGSizeMake(100, 100);
    flowLayout.sectionInset = UIEdgeInsetsMake(15, 0, 5, 0);
    
    self = [super initWithCollectionViewLayout:flowLayout];
    self.hidesBottomBarWhenPushed = YES;
    
    if (self) {
        _teamID = teamID;
        _members = [NSMutableArray new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[MemberCell class] forCellWithReuseIdentifier:kMemberCellID];
    self.collectionView.backgroundColor = [UIColor themeColor];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return (_members.count + 2 ) / 3;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger left = _members.count - section * 3;
    return left >= 3 ? 3: left;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMemberCellID forIndexPath:indexPath];
    TeamMember *member = _members[indexPath.section * 3 + indexPath.row];
    
    [cell setContentWithMember:member];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}


#pragma mark - 更新数据

- (void)switchToTeam:(int)teamID
{
    _teamID = teamID;
    [self refresh];
}

- (void)refresh
{
    [_members removeAllObjects];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_MEMBER_LIST]
      parameters:@{@"teamid": @(_teamID)}
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             NSArray *membersXML = [[responseObject.rootElement firstChildWithTag:@"members"] childrenWithTag:@"member"];
             
             for (ONOXMLElement *memberXML in membersXML) {
                 TeamMember *teamMember = [[TeamMember alloc] initWithXML:memberXML];
                 [_members addObject:teamMember];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.collectionView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}


@end
