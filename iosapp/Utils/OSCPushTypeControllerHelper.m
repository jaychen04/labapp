//
//  OSCPushTypeControllerHelper.m
//  iosapp
//
//  Created by Graphic-one on 16/8/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPushTypeControllerHelper.h"
#import "OSCMessageCenter.h"
#import "OSCNewHotBlog.h"

#import "SoftWareViewController.h"
#import "QuesAnsDetailViewController.h"
#import "NewsBlogDetailTableViewController.h"
#import "TranslationViewController.h"
#import "ActivityDetailViewController.h"
#import "TweetDetailsWithBottomBarViewController.h"

@implementation OSCPushTypeControllerHelper

+ (UIViewController *)pushControllerWithOriginType:(OSCOrigin *)origin{
    switch (origin.originType) {
        case OSCOriginTypeLinkNews:{
            return nil;
            break;
        }
        case OSCOriginTypeSoftWare:{
            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:origin.id];
            [detailsViewController setHidesBottomBarWhenPushed:YES];
            return detailsViewController;
            break;
        }
        case OSCOriginTypeForum:{
            QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.questionID = origin.id;
            detailVC.commentCount = 20;
            return detailVC;
            break;
        }
        case OSCOriginTypeBlog:{
            OSCNewHotBlog* blog = [[OSCNewHotBlog alloc]init];
            blog.id = origin.id;
            
            NewsBlogDetailTableViewController *newsBlogDetailVc = [[NewsBlogDetailTableViewController alloc]initWithObjectId:blog.id isBlogDetail:YES];
            newsBlogDetailVc.hidesBottomBarWhenPushed = YES;
            return newsBlogDetailVc;
            break;
        }
        case OSCOriginTypeTranslation:{
            TranslationViewController *translationVc = [TranslationViewController new];
            translationVc.hidesBottomBarWhenPushed = YES;
            translationVc.translationId = origin.id;
            return translationVc;
            break;
        }
        case OSCOriginTypeActivity:{
            ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:origin.id];
            activityDetailCtl.hidesBottomBarWhenPushed = YES;
            return activityDetailCtl;
            break;
        }
        case OSCOriginTypeInfo:{
            NewsBlogDetailTableViewController *newsBlogDetailVc = [[NewsBlogDetailTableViewController alloc]initWithObjectId:origin.id isBlogDetail:NO];
            newsBlogDetailVc.hidesBottomBarWhenPushed = YES;
            return newsBlogDetailVc;
            break;
        }
        case OSCOriginTypeTweet:{
            TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:origin.id];
            return tweetDetailsBVC;
            break;
        }
            
        default:
            return nil;
            break;
    }
}
/**
 OSCOriginTypeLinkNews = 0,      //链接新闻
 OSCOriginTypeSoftWare = 1,      //软件推荐
 OSCOriginTypeForum = 2,         //讨论区帖子
 OSCOriginTypeBlog = 3,          //博客
 OSCOriginTypeTranslation = 4,   //翻译文章
 OSCOriginTypeActivity = 5,      //活动类型
 OSCOriginTypeInfo = 6,          //资讯
 OSCOriginTypeTweet = 100        //动弹
 */

@end
