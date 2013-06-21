//
//  RealTime.h
//  iHiHa
//
//  Created by Wouter Timmer on 29-09-12.
//  Copyright (c) 2012 Wouter Timmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <MapKit/MapKit.h>

@interface RealTime : UIViewController < ADBannerViewDelegate,MKMapViewDelegate,CLLocationManagerDelegate, NSXMLParserDelegate>{
    //Map view
    IBOutlet MKMapView *MapView;
    
    
    //ADView
    IBOutlet ADBannerView *adView;
    
    //Datadownload
    NSMutableData *DownloadData;
    
    //Voel
    BOOL actief;
}

@end
