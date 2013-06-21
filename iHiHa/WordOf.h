//
//  WordOf.h
//  iHiHa
//
//  Created by Wouter Timmer on 25-09-12.
//  Copyright (c) 2012 Wouter Timmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <MapKit/MapKit.h>

@interface WordOf : UIViewController < ADBannerViewDelegate,MKMapViewDelegate,CLLocationManagerDelegate, NSXMLParserDelegate> {
   
    //Map view
    IBOutlet MKMapView *MapView;
    
    
    //ADView
    IBOutlet ADBannerView *adView;
    
    //Datadownload
    NSMutableData *DownloadData;


}

@end
