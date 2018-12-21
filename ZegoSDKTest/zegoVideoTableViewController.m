//
//  zegoVideoTableViewController.m
//  ZegoSDKTest
//
//  Created by hengKing on 2018/11/12.
//  Copyright © 2018年 zego. All rights reserved.
//

#import "zegoVideoTableViewController.h"
#import "UIView+Category.h"
#import <AVFoundation/AVFoundation.h>
#import "zegoPlayView.h"

@interface zegoVideoTableViewController ()<ZegoLivePublisherDelegate, ZegoLivePlayerDelegate, zegoPlayViewDelegate>

@property (nonatomic, strong) zegoPlayView *playView;
@property (nonatomic, copy) NSString *streamid;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, assign) BOOL pullOrPush;
@property (nonatomic, assign) BOOL isStreamListNull;
@property (nonatomic, strong) UIButton *cancleBtn;
@property (nonatomic, strong) UIButton *switchBtn;
@property (nonatomic, strong) UILabel *fpsLable;//视频帧率
@property (nonatomic, strong) UILabel *kbpsLable;//视频码率
@property (nonatomic, strong) UILabel *akbpsLable;//音频码率
@property (nonatomic, strong) UILabel *rttLable;//延时
@property (nonatomic, strong) UILabel *pktLostRateLable;//丢包率
@property (nonatomic, strong) UILabel *qualityLable;//质量
@property (nonatomic, strong) UILabel *cfpsLable;//视频采集帧率OR音频卡顿率
@property (nonatomic, strong) UILabel *delayLable;//语音延时

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *currentVideoDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *backCameraInput;
@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOut;
@property (nonatomic, assign) BOOL isDevicePositionFront;
@property (nonatomic, strong) AVAudioSession *audioSession;

@property (nonatomic,retain)AVCaptureSession *session;

@end

@implementation zegoVideoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
//    self.playView = [[zegoPlayView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.playView = [[[NSBundle mainBundle] loadNibNamed:@"zegoPlayView" owner:nil options:nil] firstObject];
    self.playView.delegate = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"streamCell"];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 22, 20)];
    [backBtn setImage:[UIImage imageNamed:@"menu_out"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
    
    UIButton *pushBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 32, 10, 22, 20)];
    if (_streamList.count > 0) {
        
        _isStreamListNull = NO;
//        pushBtn.hidden = YES;
    } else {//房间内流为空时可以推流
        
        _isStreamListNull = YES;
        [pushBtn setTitle:@"开始推流" forState:UIControlStateNormal];
    }
    [pushBtn setTitle:@"开始推流" forState:UIControlStateNormal];

    [pushBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [pushBtn addTarget:self action:@selector(pushBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:pushBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self.liveRoomApi setPublisherDelegate:self];
    [self.liveRoomApi setPlayerDelegate:self];
    self.audioSession = [AVAudioSession sharedInstance];
    
}

- (void)pushBtnClick:(UIButton *)btn {
    NSLog(@"开始推流");
    [_cancleBtn setTitle:@"停止推流" forState:UIControlStateNormal];
    [[UIApplication sharedApplication].keyWindow addSubview:self.playView];
    _pullOrPush = YES;
    [_liveRoomApi startPublishing:[NSString stringWithFormat:@"%@-1", _roomId] title:@"" flag:0];
    if ([_liveRoomApi setPreviewView:_playView]) {
        if ([_liveRoomApi startPreview]) {
            NSLog(@"推流成功");
            
//            [NSTimer scheduledTimerWithTimeInterval:30 repeats:NO block:^(NSTimer * _Nonnull timer) {
//                BOOL playback = [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//                NSLog(@"playback ------%d----", playback);
//            }];
//            [NSTimer scheduledTimerWithTimeInterval:60 repeats:NO block:^(NSTimer * _Nonnull timer) {
//                BOOL PlayAndRecord = [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//                NSLog(@"PlayAndRecord ------%d----", PlayAndRecord);
//            }];
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                 BOOL playback = [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//                 NSLog(@"playback ------%d----", playback);
//            });
//
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//                BOOL PlayAndRecord = [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//                NSLog(@"playback ------%d----", PlayAndRecord);
//            });

        }
    }
    
}

- (void)backButtonClick:(UIButton *)btn {
    
    if ([_liveRoomApi logoutRoom]) {
        NSLog(@"退出房间成功");
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)switchBtnClick:(UIButton *)btn {
    [_liveRoomApi setFrontCam:_isDevicePositionFront];
    _isDevicePositionFront = !_isDevicePositionFront;
}

//- (void)cancleBtnClick:(UIButton *)btn {
//    [self.playView removeFromSuperview];
//    if (_pullOrPush) {//推流
//        [_liveRoomApi stopPublishing];
//        [_liveRoomApi stopPreview];
//        [_liveRoomApi setPreviewView:nil];
//    } else {//拉流
//        [_liveRoomApi stopPlayingStream:_streamid];
//    }
//}

#pragma mark -- zegoPlayViewDelegate
- (void)closeBtnClick {

    [self.playView removeFromSuperview];
    if (_pullOrPush) {//推流
        [_liveRoomApi stopPublishing];
        [_liveRoomApi stopPreview];
        [_liveRoomApi setPreviewView:nil];
    } else {//拉流
        [_liveRoomApi stopPlayingStream:_streamid];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.streamList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"streamCell" forIndexPath:indexPath];
    ZegoStream *zegoStream = self.streamList[indexPath.row];
    cell.textLabel.text = zegoStream.streamID;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _pullOrPush = NO;
    [_cancleBtn setTitle:@"停止播放" forState:UIControlStateNormal];
    [[UIApplication sharedApplication].keyWindow addSubview:self.playView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZegoStream *zegoStream = self.streamList[indexPath.row];
    self.streamid = zegoStream.streamID;
    [self.liveRoomApi startPlayingStream:zegoStream.streamID inView:self.playView];
}
#pragma mark -- ZegoLiveDelegate

- (void)onPublishStateUpdate:(int)stateCode streamID:(NSString *)streamID streamInfo:(NSDictionary *)info {
    NSLog(@"%p --  %d", __func__ , stateCode);
}

- (void)onPublishQualityUpdate:(NSString *)streamID quality:(ZegoApiPublishQuality)quality {
    /*
    _fpsLable.text = [NSString stringWithFormat:@"%.2f fps", quality.fps];
    _kbpsLable.text = [NSString stringWithFormat:@"%.2f kbps", quality.kbps];
    _akbpsLable.text = [NSString stringWithFormat:@"%.2f akbps", quality.akbps];
    _rttLable.text = [NSString stringWithFormat:@"%d rtt", quality.rtt]; */
    
    
    self.playView.fpsLable.text = [NSString stringWithFormat:@"%.2f fps", quality.fps];
    self.playView.kbpsLabel.text = [NSString stringWithFormat:@"%.2f kbps", quality.kbps];
    self.playView.akbpsLabel.text = [NSString stringWithFormat:@"%.2f akbps", quality.akbps];
    self.playView.rttLabel.text = [NSString stringWithFormat:@"%d rtt", quality.rtt];
    self.playView.pktLostRateLabel.text = [NSString stringWithFormat:@"%d plR", quality.pktLostRate];
    self.playView.qualityLabel.text = [NSString stringWithFormat:@"%d Q", quality.quality];
}

- (void)onPlayStateUpdate:(int)stateCode streamID:(NSString *)streamID {
    
    NSLog(@"%p --  %d", __func__ , stateCode);
}

- (void)onPlayQualityUpate:(NSString *)streamID quality:(ZegoApiPlayQuality)quality {
    
    self.playView.fpsLable.text = [NSString stringWithFormat:@"%.2f fps", quality.fps];
    self.playView.kbpsLabel.text = [NSString stringWithFormat:@"%.2f kbps", quality.kbps];
    self.playView.akbpsLabel.text = [NSString stringWithFormat:@"%.2f akbps", quality.akbps];
    self.playView.rttLabel.text = [NSString stringWithFormat:@"%d rtt", quality.rtt];
    self.playView.pktLostRateLabel.text = [NSString stringWithFormat:@"%d plR", quality.pktLostRate];
    self.playView.qualityLabel.text = [NSString stringWithFormat:@"%d Q", quality.quality];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
