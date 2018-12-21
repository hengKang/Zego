//
//  zegoVideoTableViewController.h
//  ZegoSDKTest
//
//  Created by hengKing on 2018/11/12.
//  Copyright © 2018年 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZegoLiveRoom/ZegoLiveRoom.h>


@interface zegoVideoTableViewController : UITableViewController

@property (nonatomic, copy) NSArray *streamList;
@property (nonatomic, strong) ZegoLiveRoomApi *liveRoomApi;
@property (nonatomic, copy) NSString *roomId;

@end
