//
//  iHiHa.m
//  iHiHa
//
//  Created by Wouter Timmer on 28-09-12.
//  Copyright (c) 2012 Wouter Timmer. All rights reserved.
//

#import "iHiHa.h"
#import "UIDevice+IdentifierAddition.h"


// Minium level waarop geluids drempel wordt overschreven
#define MinSoundLevel = 15;
// Waarde wat als minimaal dB wordt gezien. Hier door is de schaal gelijkdelijker
#define MinDb = -56;
#define MaxSteps = 27

@interface iHiHa ()

@end

@implementation iHiHa


#pragma view onload
-(void)viewDidLoad {
	// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
	
    //stel scherm actief
     actief = YES;
    
	//Then tell the device you want to record and play audio at the same time:
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	NSError *err = nil;
	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
	
	// Bereid de recording voor
	NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
							  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,							  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
							  nil];
	NSError *error;
	theRecord = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
	// Level waarop geluisd drempel wordt overschreven
	MaxStepLevelGlobal = 17;
	
	// schaal stappen
	OutputStepLevelGlobal = 1 ;
	StepLevelGlobal		  = 1 ;
	
	// Huilen
	Huilen = FALSE;
	HuilenCount = 1 ;
	
	//Plaatjes interactief gebruike
	[iB setUserInteractionEnabled:YES];
    
    [self checkforsalvo];
    [self InputLevelView];
    [self HiHa];
    
	// Diverse timer's om gegevens te meten en te updaten.
	[NSTimer scheduledTimerWithTimeInterval: 0.05
									 target: self
								   selector: @selector(InputLevelView)
								   userInfo: nil
									repeats: YES];
	[NSTimer scheduledTimerWithTimeInterval: 1
									 target: self
								   selector: @selector(checkforsalvo)
								   userInfo: nil
									repeats: YES];
	[NSTimer scheduledTimerWithTimeInterval: 0.5
									 target: self
								   selector: @selector(HiHa)
								   userInfo: nil
									repeats: NO];
	[NSTimer scheduledTimerWithTimeInterval: 0.1
									 target: self
								   selector: @selector(etterbak)
								   userInfo: nil
									repeats: YES];
	[NSTimer scheduledTimerWithTimeInterval: 0.05
									 target: self
								   selector: @selector(OutputLevelView)
								   userInfo: nil
									repeats: YES];

    
    //Postie
    locationMan = [[CLLocationManager alloc] init];
    locationMan.delegate = self;
    locationMan.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationMan.desiredAccuracy = kCLLocationAccuracyBest; // beste
    longitude = 0;
    latitude = 0;
    Count = 0 ;
    [locationMan startUpdatingHeading];
    [locationMan startUpdatingLocation];
	//map
    
    
    [self SendWorldInfo];
    
}
-(void)viewDidAppear:(BOOL)animated {
    //Verplaats iAd banner naar boven
    [self adOverTop];
    [self Animatiebanner];
    [self iBFadeIn];
     actief = YES;
}
-(void)viewDidDisappear:(BOOL)animated {
    actief = NO;
    [thePlayer[0] stop];
    [thePlayer[1] stop];
    [thePlayer[2] stop];
    [thePlayer[3] stop];
    [thePlayer[4] stop];
    
}

-(void)iBFadeIn {
    CGRect orgframe = image.frame;
    
    image.frame = CGRectMake((self.view.frame.size.width / 2 ),(self.view.frame.size.height / 2 ),0,0);
    
    [UIView animateWithDuration:2
                     animations:^{
                         
                         image.frame = orgframe;
                         
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)io {
    [self adOverTop];
    [self Animatiebanner];
}
#pragma timers
-(void)InputLevelView{
	int StepLevel = StepLevelGlobal;
	[theRecord updateMeters ] ;
    
	[InputLevelView setImage:[UIImage imageNamed: @"level-0.png"]];
	int StartDb= -56;
	int MaxTeller = 27;
	int dB = [theRecord peakPowerForChannel:0];
	int peakPowerForChannel;  // round( pow(10, ( ( [theRecord peakPowerForChannel:0] )* 0.05))*MaxTeller);
	
	
	if ( dB >= StartDb ) {
        peakPowerForChannel = round( (StartDb - dB) / (StartDb  / MaxTeller)) ;
	} else {
        peakPowerForChannel = 0;
	}
	
	//NSLog(@"%d db",dB);
	if (StepLevel < peakPowerForChannel) {
		StepLevel++;
	} else {
		StepLevel--;
	}
    if (StepLevel <0 ) StepLevel = 0;
	if (StepLevel > MaxTeller ) StepLevel = MaxTeller;
    // asl er geen record loopt teller op null
	if (theRecord.recording == false  ) { StepLevel = 0 ;}
    
	
	// meten van speaker volume
	NSString *filename =[NSString stringWithFormat:@"Signaal-%d.png",StepLevel];
	[InputLevelView setImage:[UIImage imageNamed:filename]];
	StepLevelGlobal = StepLevel;
    
}
-(void)OutputLevelView {
	// Output level tonen
	int StepLevel = OutputStepLevelGlobal;
	
	int StartDb= -56;
	int MaxTeller = 27;
	int dB=-160;
	int peakPowerForChannel;
	int playcount = 0 ;
	
	for (int i=0 ; i < 5 ; i++ ) {
		[thePlayer[i] updateMeters];
		if (thePlayer[i].playing )	{
			if ( [thePlayer[i] averagePowerForChannel:0] > dB ) {
				dB = [thePlayer[i] averagePowerForChannel:0];
			}
			playcount ++;
		}
	}
	
	if ( dB >= StartDb ) {
		peakPowerForChannel = round( (StartDb - dB) / (StartDb  / MaxTeller)) ;
	} else {
		peakPowerForChannel = 0;
	}
	
	if ( peakPowerForChannel > MaxStepLevelGlobal ) {
		MaxStepLevelGlobal = peakPowerForChannel;
	} else {
		// Geen input geluid en geen output dan reset tellers om aan te slaan.
		if ( ( playcount == 0 ) &&  (StepLevelGlobal < 17 )) {
			MaxStepLevelGlobal = 17 ;
		}
	}
	
	
	
	if (StepLevel < peakPowerForChannel) {
		StepLevel++;
	} else {
		StepLevel--;
	}
    if (StepLevel <0 ) StepLevel = 0;
	if (StepLevel > MaxTeller ) StepLevel = MaxTeller;
	
	//	power = [thePlayer[1] peakPowerForChannel:1];
	//dBLevel.text = [NSString stringWithFormat:@"Power %d",MaxStepLevelGlobal ];
	NSString *filename =[NSString stringWithFormat:@"Signaal-%d.png",StepLevel];
	[OutputLevelView setImage:[UIImage imageNamed:filename]];
	
	OutputStepLevelGlobal = StepLevel;
}
#pragma ihihaondersteunend
-(void)etterbak {
	NSString *string ;
	if ( Huilen == FALSE )  {
		
		// tellen hoevel sound er lopen en afhankelijk daarvan de smile laten zien
		int CountGo = 0 ;
        
		for (int  i = 0  ; i < 5 ; i++ ) {
			if (thePlayer[i].playing) {
				CountGo++;
			}
		}
        Count = CountGo;
		//start hierna met huilen
		switch ( Count )
		{
                
			case 3:
				string = @"iB_mond_level_1.jpg" ;
				break;
			case 4:
				string = @"iB_mond_level_2.png" ;
				break;
			case 5:
				string = @"SmileyTraan1.jpg" ;
				Huilen = TRUE; //start hierna met huilen
                
				HuilenCount = 1;
				// Zorg er voor dat er geen nieuwe geluiden meer worden gestart.
				break;
			default:
				string = @"iB.jpg" ;
                
		}
	}  else {
        // IB is aan het huilen
        if ( HuilenCount > 33  ) {
            Huilen = FALSE ;
            
        } // start met huilen
        string =[NSString stringWithFormat:@"SmileyTraan%d.jpg",HuilenCount];
		HuilenCount++;
        
	}
    
	if (Rimple) {
		RimpleCount++;
		string =[NSString stringWithFormat:@"Rimpel%d.jpg",RimpleCount];
	}
	[iB setImage:[UIImage imageNamed:string]];
	
	if ( RimpleCount > 10 )  {
		Rimple = FALSE;
		RimpleCount = 0 ;
	}
	
}
-(void)HiHa {
	//standaard snelheid
	double speed = 0.7;
	// tonen van de HiHa info.
	//string vullen met plaatjes
	int MaxCount = 18;
	NSString *strings[MaxCount];
	int x;
	
	// eerst leeg om ook lege objecten te tonen
	for (x = 0; x <= MaxCount-1; x++)
	{
		strings[x]=@"";;
	}
	strings[0] = @"Ha Blauw Left.png";
	strings[1] = @"Ha Blauw Right.png";
	strings[2] = @"Ha Blauw.png";
	strings[3] = @"Hi Blauw Left.png";
	strings[4] = @"Hi Blauw Right.png";
	strings[5] = @"Hi Blauw.png";
	strings[6] = @"Ha Groen Left.png";
	strings[7] = @"Ha Groen Right.png";
	strings[8] = @"Ha Groen.png";
	strings[9] = @"Hi Groen Left.png";
	strings[10] = @"Hi Groen Right.png";
	strings[11] = @"Hi Groen.png";
	strings[12] = @"Ha Rood Left.png";
	strings[13] = @"Ha Rood Right.png";
	strings[14] = @"Ha Rood.png";
	strings[15] = @"Hi Rood Left.png";
	strings[16] = @"Hi Rood Right.png";
	strings[17] = @"Hi Rood.png";
    
    
	if ( thePlayer[2].playing  ) {
		[LO setImage:[UIImage imageNamed:strings[rand() % MaxCount]]];
		speed = 0.5;
	}
	else {
		[LO setImage:[UIImage imageNamed:@""]];
	}
    
	if ( thePlayer[3].playing  ) {
		[RO setImage:[UIImage imageNamed:strings[rand() % MaxCount]]];
		speed = 0.4;
	} else {
		[RO setImage:[UIImage imageNamed:@""]];
	}
    
	if ( thePlayer[0].playing  ) {
		[LB setImage:[UIImage imageNamed:strings[rand() % MaxCount]]];
	} else {
		[LB setImage:[UIImage imageNamed:@""]];
		speed = 0.3;
        
	}
    
	if ( thePlayer[1].playing  ) {
		[RB setImage:[UIImage imageNamed:strings[rand() % MaxCount]]];
    } else {
		[RB setImage:[UIImage imageNamed:@""]];
	}
	
	if ( thePlayer[4].playing  ) {
        // Verdullel de snelheid
		speed = 0.2;
	}
	
	
	//Snelheid bepalen en daarna een nieuwe timezetten.
	[NSTimer scheduledTimerWithTimeInterval: speed
									 target: self
								   selector: @selector(HiHa)
								   userInfo: nil
									repeats: NO];
}
-(void)checkforsalvo {
	// Elke tijd interfac kijken of een nieuwe salvo moet worden afgevuurt.
	// Ook kijken of de record nog loopt anders deze opnieuw starte.
	int StepLevel = StepLevelGlobal;
	// De Step level wordt dynamische gestart.
	
	
	// eerste level bepalen anders gaat de meting fout.
	[self InputLevelView];
	[self OutputLevelView];
	if ( StepLevel >= MaxStepLevelGlobal )
	{
		// Output geluid hoger is dan input den geen salve.
		if ( OutputStepLevelGlobal < StepLevelGlobal )
        {
            // Als IB aan het huilen is deze leker uit ratelen
            if ( Huilen == FALSE )  [self salvo];
        }
	}
	if ( theRecord.recording == false  ) {
		[theRecord prepareToRecord];
		theRecord.meteringEnabled = YES;
		[theRecord record]; 
		StepLevel = 0 ;
	}
	StepLevelGlobal = StepLevel;
	
}
-(NSString *)Docsdir {
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    return [dirPaths objectAtIndex:0];
}
-(NSString *)prepairaudiofile:(NSString *)_audiofile alternative:(NSString *)alternativefile {
    
    NSString *soundFilePath = [[self Docsdir]
                               stringByAppendingPathComponent:_audiofile];
 
    
    AVAudioPlayer *player =   [[AVAudioPlayer alloc]
                               initWithContentsOfURL:[NSURL fileURLWithPath:soundFilePath]
                               error:nil];
    if ( player.duration > 0 ) {
        return _audiofile ;
    } else {
        return alternativefile;
    }
    
    
}

-(void)salvo {
	// Sound bytes bepalen en een willekeurig soundbyte kiezen
    	if (!actief) { return ;}
    
    [self SendWorldInfo];
	NSString *sounds[3];
	/*sounds[0] = [self prepairaudiofile:@"sound level 1.caf" alternative:@"HiHiHaHa Level 1" ];
	sounds[1] = [self prepairaudiofile:@"sound level 2.caf" alternative:@"HiHiHaHa Level 2" ];
	sounds[2] = [self prepairaudiofile:@"sound level 3.caf" alternative:@"HiHiHaHa Level 3" ];*/
    
    sounds[0] = @"HiHiHaHa Level 1" ;
	sounds[1] = @"HiHiHaHa Level 2" ;
	sounds[2] = @"HiHiHaHa Level 3" ;
    
	NSString *path = [[NSBundle mainBundle] pathForResource:sounds[rand() % 3] ofType:@"mp3"];
    NSLog(@"%@",path);
    
	
    
	// Deze fix in versie 1.1 geplaats omdat ander na stanby de overide niet meer geldig was
	//Then, and this is the key, allow the volume from the speakers to also be loud when recording:
	// Als een koptelefoon is aangesloten dan komt geluid over de speaker.
	UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
	AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride),&audioRouteOverride);

    
	if ( thePlayer[0].playing == false ) {
		thePlayer[0] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]  error:NULL];
		thePlayer[0].meteringEnabled = YES ;
		[thePlayer[0] prepareToPlay] ;
		[thePlayer[0] play];
        
        
	} else {
		if ( thePlayer[1].playing == false ) {
			//dBLevel.text = [NSString stringWithFormat:@"Twee level sound %d", [thePlayer[0] peakPowerForChannel:0] ];
			thePlayer[1] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]  error:NULL];
			thePlayer[1].meteringEnabled = YES ;
			[thePlayer[1] prepareToPlay] ;
			[thePlayer[1] play];
            
		} else {
			if ( thePlayer[2].playing == false ) {
				//dBLevel.text = [NSString stringWithFormat:@"Twee level sound %d", [thePlayer[0] peakPowerForChannel:0] ];
				thePlayer[2] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]  error:NULL];
				thePlayer[2].meteringEnabled = YES ;
				[thePlayer[2] prepareToPlay] ;
				[thePlayer[2] play];
				
			} else {
				if ( thePlayer[3].playing == false ) {
					//dBLevel.text = [NSString stringWithFormat:@"Twee level sound %d", [thePlayer[0] peakPowerForChannel:0] ];
					thePlayer[3] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]  error:NULL];
					thePlayer[3].meteringEnabled = YES ;
					[thePlayer[3] prepareToPlay] ;
					[thePlayer[3] play];
                    
				} else {
					if ( thePlayer[4].playing == false ) {
						//dBLevel.text = [NSString stringWithFormat:@"Twee level sound %d", [thePlayer[0] peakPowerForChannel:0] ];
						thePlayer[4] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]  error:NULL];
						thePlayer[4].meteringEnabled = YES ;
						[thePlayer[4] prepareToPlay] ;
						[thePlayer[4] play];
                        
					}
				}
			}
		}
	}
    
    
}
#pragma uploaddata
-(void)SendWorldInfo {
    
    // send GPS locatie waar gelaggen word.
    
    //WiFi netwerk bepalen
    NSString *BSSID;
	NSString *SSID;
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    // Get the dictionary containing the captive network infomation
  //  CFDictionaryRef captiveNtwrkDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
    
   // NSLog(@"Information of the network we're connected to: %@", captiveNtwrkDict);
    
//    NSDictionary *dict = (__bridge NSDictionary*) captiveNtwrkDict;
//    SSID = [dict objectForKey:@"SSID"];
//   BSSID = [dict objectForKey:@"BSSID"];
    
   // NSLog(@"%@ %@",Interface,CurrentNetwork);
    
    // NSLog ( @"%@ %@" , latitude, longitude);
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *uniqueGlobalDeviceIdentifier = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString *uniqueDeviceIdentifier ;//= [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *myRequestString = [NSString stringWithFormat:@"<iOS UUID='' uniqueGlobalDeviceIdentifier='%@' uniqueDeviceIdentifier='%@' model='%@' name='%@' appversion='%@' iOS='%@' CFBundleIdentifier='%@' level='%d' longitude='%f' latitude='%f' BSSID='%@' SSID='%@' BANNER='%d'><item/>\n" ,uniqueGlobalDeviceIdentifier, uniqueDeviceIdentifier, [myDevice model], [myDevice name], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[myDevice systemVersion],appID, Count, longitude, latitude, BSSID, SSID, adView.bannerLoaded];
    //NSLog(@"%@",myRequestString);
    //XML Header einde
    myRequestString = [NSString stringWithFormat:@"%@\n </iOS> ", myRequestString];
    // de tekens uit de teksen verwijderen.
    myRequestString = [myRequestString stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    // NSLog(@"post:%@",myRequestString);
    
    // Upload de verzamelde data
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
	NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString:[NSString stringWithFormat:@"http://www.timmer.info/iHiHa/DeviceToken.php" ]]];
    
    [ request setHTTPMethod: @"POST" ];
    [ request setHTTPBody: myRequestData ];
	NSURLConnection *connect =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connect){}
    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	//NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] );
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"connectionDidFinishLoading");
}
#pragma Banner
-(void)adOverTop {
   // NSLog(@"adOverTop");
    //adView.frame =  CGRectOffset(adView.frame, 0, -adView.frame.size.height);
    adView.frame = CGRectMake(0, -adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
    LB.frame = CGRectMake ( 0,0,LB.frame.size.width,LB.frame.size.height);
    RB.frame = CGRectMake ( (self.view.frame.size.width - RB.frame.size.width),0,RB.frame.size.width,RB.frame.size.height);
    adView.hidden = NO;
}
-(void)Animatiebanner {
    //Als banner nog niet is getoond deze animeren
    //NSLog(@"%f %d",adView.frame.origin.y, [adView isBannerLoaded] );
    if ( [adView isBannerLoaded] && adView.frame.origin.y < 0  ) {
        
        [ADBannerView animateWithDuration: 2
                                    delay: 0
                                  options:UIViewAnimationCurveLinear
                               animations:^{
                                   adView.frame = CGRectOffset(adView.frame, 0, adView.frame.size.height);
                                   LB.frame = CGRectOffset(LB.frame, 0, adView.frame.size.height);
                                   RB.frame =  CGRectOffset(RB.frame, 0, adView.frame.size.height);
                               }
                               completion:^(BOOL finished){
                                   
                               }];
        
        
    }
    if ( ![adView isBannerLoaded] ) {
        [ADBannerView animateWithDuration: 0.5
                                    delay: 0
                                  options:UIViewAnimationCurveLinear
                               animations:^{
                                   [self adOverTop];
                                   
                               }
                               completion:^(BOOL finished){
                                   
                               }];
    }
}
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Error [%@]",error);
    [self Animatiebanner];
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner {
    //iAd word getoont
    //adView.hidden = NO ;
   // NSLog(@"bannerViewWillLoadAd %d",[banner isBannerLoaded]);
    [self Animatiebanner];
    
    
}
-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
    // adView.hidden = YES ;
    //NSLog(@"bannerViewDidLoadAd %d",[banner isBannerLoaded]);
    [self Animatiebanner];
    
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner {
    //iAd word weer verwijderd
    //NSLog(@"bannerViewActionDidFinish %d",[banner isBannerLoaded]);
    [self Animatiebanner];
}
#pragma Locatie
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    longitude = newLocation.coordinate.longitude;
    latitude = newLocation.coordinate.latitude;
    
    // NSLog(@"%f %f",longitude, latitude);
}
#pragma netwerk
-(NSString *)RealMac:(NSString *)MAC {
	//omzetten van een macadres met dubbele punten en zonder voorlop nullen omzetten naar 12 digit.
	NSString *newMac = [NSString stringWithFormat:@""];
	for (NSString *string in [MAC componentsSeparatedByString:@":"]) {
		if (string.length == 1 ){
			newMac = [NSString stringWithFormat:@"%@0%@",newMac,string];
		} else {
			newMac = [NSString stringWithFormat:@"%@%@",newMac,string];
		}
	}
	return newMac;
}
@end
