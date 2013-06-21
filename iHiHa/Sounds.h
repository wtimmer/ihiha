//
//  Sounds.h
//  iHiHa
//
//  Created by Wouter Timmer on 29-09-12.
//  Copyright (c) 2012 Wouter Timmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#include <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MPVolumeView.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MFMailComposeViewController.h>

#import <SystemConfiguration/CaptiveNetwork.h>


@interface Sounds : UIViewController <ADBannerViewDelegate, AVAudioRecorderDelegate,  AVAudioPlayerDelegate> {
    
        IBOutlet ADBannerView *adView;

    
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *recordButton;
    IBOutlet UIButton *stopButton;
    IBOutlet UIButton *resetButton;
    IBOutlet UIButton *ib1Button;
    IBOutlet UIButton *ib2Button;
    IBOutlet UIButton *ib3Button;
    
    
    IBOutlet UIProgressView *Progress;
    
    NSString *AudioFile ;
    NSString *OrgAudioFile ;
    
    IBOutlet UIImageView *iB;
}

-(IBAction) recordAudio;
-(IBAction) playAudio;
-(IBAction) stop;
-(IBAction) del;
-(IBAction) Ib1;
-(IBAction) Ib2;
-(IBAction) Ib3;


@end
