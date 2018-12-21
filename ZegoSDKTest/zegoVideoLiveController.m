//
//  zegoVideoLiveController.m
//  ZegoSDKTest
//
//  Created by hengKing on 2018/11/8.
//  Copyright © 2018年 zego. All rights reserved.
//

#import "zegoVideoLiveController.h"
#import <ZegoLiveRoom/ZegoLiveRoom.h>
#import "zegoVideoTableViewController.h"
#import "UIView+Category.h"

static ZegoLiveRoomApi *liveRoomApi = nil;

@interface zegoVideoLiveController ()

@property (weak, nonatomic) IBOutlet UITextField *appidTextField;
@property (weak, nonatomic) IBOutlet UITextField *appsignTextField;
@property (weak, nonatomic) IBOutlet UISwitch *switchOnOrTest;
@property (weak, nonatomic) IBOutlet UITextField *roomidTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginRoomBtn;

@property (nonatomic, assign) unsigned int appid;
@property (nonatomic, strong) NSData *appsign;

@end

@implementation zegoVideoLiveController

/*
- (ZegoLiveRoomApi *)liveRoomApi {
    if (liveRoomApi == nil) {
        ZegoLiveRoomApi *roomApi = [[ZegoLiveRoomApi alloc] init];
        liveRoomApi = roomApi;
    }
    return liveRoomApi;
}*/

- (void)viewDidLoad {
    [super viewDidLoad];
    [ZegoLiveRoomApi setUserID:@"12345678" userName:@"zegoTest"];
    _switchOnOrTest.on = NO;
    [ZegoLiveRoomApi setUseTestEnv:YES];
}

- (IBAction)loginRoom:(UIButton *)sender {
    
    [self endEditing];
    UIView *plachoderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    plachoderView.backgroundColor = [UIColor blackColor];
    plachoderView.alpha = 0.2;
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.centerX = plachoderView.width * 0.5;
    indicatorView.centerY = plachoderView.height * 0.5;
    [indicatorView startAnimating];
    [plachoderView addSubview:indicatorView];
    [[UIApplication sharedApplication].keyWindow addSubview:plachoderView];

    _appid = [_appidTextField.text intValue];
    NSString *str = _appsignTextField.text;
    _appsign = ConvertStringToSign(str);
    if (liveRoomApi == nil) {
        liveRoomApi = [[ZegoLiveRoomApi alloc] initWithAppID:_appid appSignature:_appsign];
    }
    BOOL isLoginRoom;
    isLoginRoom =  [liveRoomApi loginRoom:_roomidTextField.text role:1 withCompletionBlock:^(int errorCode, NSArray<ZegoStream *> *streamList) {
        
        [indicatorView stopAnimating];
        [plachoderView removeFromSuperview];
        
        if (errorCode != 0) {
            
           UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录报错" message:[NSString stringWithFormat:@"%d", errorCode] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:alertAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }  else {
            
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            zegoVideoTableViewController *tableViewCtr = [storyboard instantiateViewControllerWithIdentifier:@"zegoVideoTableViewController"];
            tableViewCtr.streamList = [streamList copy];
            tableViewCtr.liveRoomApi = liveRoomApi;
            tableViewCtr.roomId = self.roomidTextField.text;
            [self.navigationController pushViewController:tableViewCtr animated:YES];
        }
    }];
    
    if (isLoginRoom) {
        NSLog(@"loginRoom调用成功");
    } else {
        NSLog(@"loginRoom调用失败");
    }
}

- (IBAction)switchOnOrTest:(UISwitch *)sender {
    NSLog(@"%d ---------- ", sender.on);
    [ZegoLiveRoomApi setUseTestEnv:!sender.on];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing];
}

- (void)endEditing {
    [self.appidTextField endEditing:YES];
    [self.appsignTextField endEditing:YES];
    [self.roomidTextField endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

Byte toByte(NSString* c)
{
    NSString *str = @"0123456789abcdef";
    Byte b = [str rangeOfString:c].location;
    return b;
}

NSData* ConvertStringToSign(NSString* strSign)
{
    if(strSign == nil || strSign.length == 0)
        return nil;
    strSign = [strSign lowercaseString];
    strSign = [strSign stringByReplacingOccurrencesOfString:@" " withString:@""];
    strSign = [strSign stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSArray* szStr = [strSign componentsSeparatedByString:@","];
    int nLen = (int)[szStr count];
    Byte szSign[32];
    for(int i = 0; i < nLen; i++)
    {
        NSString *strTmp = [szStr objectAtIndex:i];
        if(strTmp.length == 1)
            szSign[i] = toByte(strTmp);
        else
        {
            szSign[i] = toByte([strTmp substringWithRange:NSMakeRange(0, 1)]) << 4 | toByte([strTmp substringWithRange:NSMakeRange(1, 1)]);
        }
    }
    
    NSData *sign = [NSData dataWithBytes:szSign length:32];
    return sign;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}*/


@end
