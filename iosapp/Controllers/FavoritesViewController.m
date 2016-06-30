//
//  FavoritesViewController.m
//  iosapp
//
//  Created by ChanAetern on 12/11/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "FavoritesViewController.h"
#import "Config.h"
#import "Utils.h"
#import "OSCNews.h"
#import "OSCBlog.h"
#import "OSCPost.h"
#import "DetailsViewController.h"

#import "SoftWareViewController.h"
#import "NewsBlogDetailTableViewController.h"
#import "QuesAnsDetailViewController.h"

static NSString * const kFavoriteCellID = @"FavoriteCell";


@implementation FavoritesViewController

- (instancetype)initWithFavoritesType:(FavoritesType)favoritesType
{
    self = [super init];
    if (!self) {return nil;}
    
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?uid=%llu&type=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_FAVORITE_LIST, [Config getOwnID], favoritesType, (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    self.objClass = [OSCFavorite class];
    
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"favorites"] childrenWithTag:@"favorite"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFavoriteCellID];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kFavoriteCellID forIndexPath:indexPath];
    OSCFavorite *favorite = self.objects[indexPath.row];
    
    cell.backgroundColor = [UIColor themeColor];
    cell.textLabel.text = favorite.title;
    cell.textLabel.textColor = [UIColor titleColor];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

    OSCFavorite *favorite = self.objects[indexPath.row];
    switch (favorite.type) {
        case FavoritesTypeSoftware: {        //软件详情
            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:favorite.objectID];
            [detailsViewController setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:detailsViewController animated:YES];
        }
            break;
        case FavoritesTypeTopic: {           //问答详情
            QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.questionID = favorite.objectID;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
            break;
        case FavoritesTypeBlog: {            //博客详情
            NewsBlogDetailTableViewController *newsBlogDetailVc = [[NewsBlogDetailTableViewController alloc]initWithObjectId:favorite.objectID
                                                                                                                isBlogDetail:YES];
            [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
        }
            break;
        case FavoritesTypeNews: {            //资讯详情
            NewsBlogDetailTableViewController *newsBlogDetailVc = [[NewsBlogDetailTableViewController alloc]initWithObjectId:favorite.objectID
                                                                                                                isBlogDetail:NO];
            [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
        }
            break;
        default:
            [self.navigationController handleURL:favorite.url];
            break;
    }
}




@end
