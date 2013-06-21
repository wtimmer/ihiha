//
//  iHiHa.h
//  iHiHa
//
//  Created by Wouter Timmer on 28-09-12.
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

@interface iHiHa : UIViewController < ADBannerViewDelegate,ADBannerViewDelegate,CLLocationManagerDelegate> {
    
    IBOutlet UIImageView *iB;
	IBOutlet UIImageView *InputLevelView;
	IBOutlet UIImageView *OutputLevelView;
	IBOutlet UILabel *dBLevel;
	IBOutlet UIImageView *RB;
	IBOutlet UIImageView *LB;
	IBOutlet UIImageView *LO;
	IBOutlet UIImageView *RO;
    
    IBOutlet UIImageView *image;
    //ADView
    IBOutlet ADBannerView *adView;
    
    AVAudioRecorder *theRecord;
	AVAudioPlayer *thePlayer[5];
	NSInteger StepLevelGlobal;
	NSInteger MaxStepLevelGlobal;
	NSInteger OutputStepLevelGlobal;
	NSInteger HuilenCount;
	NSInteger RimpleCount;
	bool Huilen;
	bool Rimple;
    //teller van aantal ettesalvo
    int Count;
    //Locatie
    CLLocationManager *locationMan;
    float latitude ;
    float longitude;
    
    //Voel
    BOOL actief;

    
    
}

@end
