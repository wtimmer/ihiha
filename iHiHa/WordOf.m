//
//  WordOf.m
//  iHiHa
//
//  Created by Wouter Timmer on 25-09-12.
//  Copyright (c) 2012 Wouter Timmer. All rights reserved.
//

#import "WordOf.h"


@interface WordOf ()

@end

@implementation WordOf



#pragma basicviewload

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self World]; 
    
    
}
-(void)viewDidAppear:(BOOL)animated {
    //Verplaats iAd banner naar boven
    [self adOverTop];
    [self Animatiebanner];
    
    [self Addloc];
}



- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)io {
    [self adOverTop];
    [self Animatiebanner];
}





#pragma Banner
-(void)adOverTop {
  //  NSLog(@"adOverTop");
    //adView.frame =  CGRectOffset(adView.frame, 0, -adView.frame.size.height);
    adView.frame = CGRectMake(0, -adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
    adView.hidden = NO;
}

-(void)Animatiebanner {
    //Als banner nog niet is getoond deze animeren
   // NSLog(@"%f %d",adView.frame.origin.y, [adView isBannerLoaded] );
    if ( [adView isBannerLoaded] && adView.frame.origin.y < 0  ) {
        
        [ADBannerView animateWithDuration: 2
                                    delay: 0
                                  options:UIViewAnimationCurveLinear
                               animations:^{
                                   adView.frame = CGRectOffset(adView.frame, 0, adView.frame.size.height);                     }
                               completion:^(BOOL finished){
                                   
                               }];
        
        
    }
    if ( ![adView isBannerLoaded] ) {
        [ADBannerView animateWithDuration: 0.5
                                    delay: 0
                                  options:UIViewAnimationCurveLinear
                               animations:^{
                                   adView.frame = CGRectMake(0, -adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
                               }
                               completion:^(BOOL finished){
                                   
                               }];
    }
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
  //  NSLog(@"Error [%@]",error);
    [self Animatiebanner];
}

-(void)bannerViewWillLoadAd:(ADBannerView *)banner {
    //iAd word getoont
    //adView.hidden = NO ;
  //  NSLog(@"bannerViewWillLoadAd %d",[banner isBannerLoaded]);
    [self Animatiebanner];
    
    
}
-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
    // adView.hidden = YES ;
   // NSLog(@"bannerViewDidLoadAd %d",[banner isBannerLoaded]);
    [self Animatiebanner];
    
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner {
    //iAd word weer verwijderd
   // NSLog(@"bannerViewActionDidFinish %d",[banner isBannerLoaded]);
    [self Animatiebanner];
}
#pragma Downloads
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    // informeer het system dat er probleem is met de verbinding.
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    // Connectie event dat alle data is binnen gekomen
	//NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] );
    // Voeg de data toe aan globale var.
    [DownloadData appendData:data];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Ale data is binnen en kan de data doorgeven worden naar de XML parser
    //NSLog(@"%@", [[NSString alloc] initWithData:DownloadData encoding:NSASCIIStringEncoding] );
    
    
  
    [self Parse_XML:DownloadData];
     //[NSThread detachNewThreadSelector:@selector(Parse_XML:) toTarget:self withObject:DownloadData];
    
}

-(void)Parse_XML:(NSMutableData *) Data {
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:Data ];
    [rssParser setDelegate:self];
    [rssParser parse];
    
}

#pragma Mapview

-(void) World {
    
    
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=180;
    span.longitudeDelta=180;
    
    CLLocationCoordinate2D location;

    region.span=span;
    region.center=location;
    
    [MapView setRegion:region animated:TRUE];
    [MapView regionThatFits:region];
    
    
    
}
-(void)Addloc {
    
    
    NSArray *annotationArrs = MapView.annotations;
    if(annotationArrs!=nil)
    {
        //NSLog(@"Remove all annotations!");
        [MapView removeAnnotations:annotationArrs];
    }
    
  /*  NSData *imageData = [NSData dataWithContentsOfURL:
                         [NSURL URLWithString:@"http://www.timmer.info/iHiHa/GPS.php"]];
    //NSLog(@"%@",imageData);
    NSString *asciiString = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding ];
    //    NSLog(@"%@", asciiString  );
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:[asciiString dataUsingEncoding:NSUTF8StringEncoding  allowLossyConversion:YES] ];
    [rssParser setDelegate:self];
    [rssParser parse];*/
    
    NSString *url = [NSString stringWithFormat:@"http://www.timmer.info/iHiHa/GPS.php" ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:url] ];
    //[request setTimeoutInterval:20];
    //bereid data variable voor
    DownloadData = [NSMutableData data]  ;
    
    // Download
	NSURLConnection *connect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connect){}
    //NSLog(@"%@",connect);
    
}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSLog(@"%@",error);
}


- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    //NSLog(@"%@",annotation);
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[MapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] ;
    }
    
    annotationView.image = [UIImage imageNamed:@"Icon-Map.png"];
    annotationView.annotation = annotation;
    
    return annotationView;
}


# pragma mark - XML Download
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    // Start van document
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
 
    if ( [elementName  isEqualToString:@"item"] ) {
        //   NSLog(@"%@,%@",elementName,attributeDict);
        //NSLog(@"%@ %@",[attributeDict valueForKey:@"latitude" ],[attributeDict valueForKey:@"longitude"]);
        
        
        
        [self AddIn:attributeDict];
      //  [NSThread detachNewThreadSelector:@selector(AddIn:) toTarget:self withObject:attributeDict];
    }
}

-(void)AddIn:(NSDictionary *) attributeDict {
    NSString *lat =[attributeDict valueForKey:@"latitude" ];
    NSString *lon = [attributeDict valueForKey:@"longitude"];
    
    CLLocationCoordinate2D location;
    
    location.latitude = [lat floatValue];
    location.longitude = [lon floatValue];
   // MKPlacemark *marker = ;
    [MapView addAnnotation:[[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil]];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
}



-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //   NSLog(@"EndelementName:%@,namespaceURI:%@,qualifiedName:%@",elementName,namespaceURI,qName);
       
    
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    //NSLog(@"%@",Items);
}



@end
