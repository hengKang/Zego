//
//  AppDelegate.h
//  ZegoSDKTest
//
//  Created by hengKing on 2018/11/8.
//  Copyright © 2018年 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

