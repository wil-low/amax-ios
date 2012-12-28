//
//  AmaxInterpreterController.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxInterpreterController.h"
#import "AmaxEvent.h"

@implementation AmaxInterpreterController

@synthesize dateRangeView;
@synthesize interpreterText = _interpreterText;
@synthesize interpreterEvent = _interpreterEvent;
@synthesize interpreterTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSString *)makeTitleFromEvent:(AmaxEvent *)ev
{
    switch (ev.mEvtype) {
		case EV_VOC:
			return NSLocalizedString(@"si_key_voc", nil);
		case EV_VIA_COMBUSTA:
			return NSLocalizedString(@"si_key_vc", nil);
		case EV_DEGREE_PASS: {/*
			return String
            .format(getStr(R.string.fmt_planet_in_degree),
                    mContext.getResources().getStringArray(
                                                           R.array.planets)[ev.mPlanet0],
                    ev.getDegree() % 30 + 1,
                    mContext.getResources().getStringArray(
                                                           R.array.constell_genitive)[ev.getDegree() / 30]);*/
            
            NSString* textId = [NSString stringWithFormat:@"%d", ev.mPlanet0];
            NSString* planet = NSLocalizedStringFromTable(textId, @"Planets", nil);

            textId = [NSString stringWithFormat:@"%d", [ev getDegree] / 30];
            NSString* constell = NSLocalizedStringFromTable(textId, @"ConstellGenitive", nil);

			return [NSString stringWithFormat:NSLocalizedString(@"fmt_planet_in_degree", nil), 
                    planet,
                    [ev getDegree] % 30 + 1,
                    constell]; }
		case EV_SIGN_ENTER: {/*
			return String
            .format(getStr(R.string.fmt_planet_in_sign),
                    mContext.getResources().getStringArray(
                                                           R.array.planets)[ev.mPlanet0],
                    mContext.getResources().getStringArray(
                                                           R.array.constell_locative)[ev.getDegree()]);*/
            NSString* textId = [NSString stringWithFormat:@"%d", ev.mPlanet0];
            NSString* planet = NSLocalizedStringFromTable(textId, @"Planets", nil);
            
            textId = [NSString stringWithFormat:@"%d", [ev getDegree]];
            NSString* constell = NSLocalizedStringFromTable(textId, @"ConstellLocative", nil);
            
			return [NSString stringWithFormat:NSLocalizedString(@"fmt_planet_in_sign", nil), 
                    planet,
                    constell]; }
            
		case EV_PLANET_HOUR: {/*
			return String.format(
                                 getStr(R.string.fmt_hour_of_planet),
                                 mContext.getResources().getStringArray(
                                                                        R.array.planets_genitive)[ev.mPlanet0]);*/
            NSString* textId = [NSString stringWithFormat:@"%d", ev.mPlanet0];
            NSString* planet = NSLocalizedStringFromTable(textId, @"PlanetsGenitive", nil);
            
			return [NSString stringWithFormat:NSLocalizedString(@"fmt_hour_of_planet", nil), 
                    planet]; }

		case EV_MOON_MOVE:
			return NSLocalizedString(@"si_key_moon_move", nil);
            
		case EV_ASP_EXACT_MOON:
		case EV_ASP_EXACT: {/*
			return String
            .format(getStr(R.string.fmt_aspect),
                    mContext.getResources().getStringArray(
                                                           R.array.aspect)[Event.ASPECT_MAP
                                                                           .get(ev.getDegree())],
                    mContext.getResources().getStringArray(
                                                           R.array.planets)[ev.mPlanet0],
                    mContext.getResources().getStringArray(
                                                           R.array.planets)[ev.mPlanet1]);*/
            NSString* textId = [NSString stringWithFormat:@"%d", ev.mPlanet0];
            NSString* planet0 = NSLocalizedStringFromTable(textId, @"Planets", nil);
            
            textId = [NSString stringWithFormat:@"%d", ev.mPlanet1];
            NSString* planet1 = NSLocalizedStringFromTable(textId, @"Planets", nil);

            textId = [NSString stringWithFormat:@"%d", [ev getDegree]];
            NSString* aspect = NSLocalizedStringFromTable(textId, @"Aspects", nil);
            
			return [NSString stringWithFormat:NSLocalizedString(@"fmt_aspect", nil),
                    aspect,
                    planet0,
                    planet1]; }
            
		case EV_TITHI: {/*
			return getStr(R.string.si_key_tithi) + " "
            + Integer.toString(ev.getDegree());*/
            NSString* result = NSLocalizedString(@"si_key_moon_move", nil);
 			return [NSString stringWithFormat:@"%@ %d", result, [ev getDegree]]; }
           
		case EV_RETROGRADE: {/*
			return String
            .format(getStr(R.string.fmt_retrograde_motion),
                    mContext.getResources().getStringArray(
                                                           R.array.planets_genitive)[ev.mPlanet0]);*/
            NSString* textId = [NSString stringWithFormat:@"%d", ev.mPlanet0];
            NSString* planet0 = NSLocalizedStringFromTable(textId, @"Planets", nil);
            
			return [NSString stringWithFormat:NSLocalizedString(@"fmt_retrograde_motion", nil),
                    planet0]; }
   }
    return nil;
}

- (NSString *)makeDateRangeFromEvent:(AmaxEvent *)ev
{
    NSMutableString* result = [NSMutableString string];
    switch (ev.mEvtype) {
		case EV_ASP_EXACT_MOON:
		case EV_ASP_EXACT:
			return [AmaxEvent long2String:[ev dateAt:0] format:[AmaxEvent monthAbbrDayDateFormatter] h24:NO];
    }
    return [NSString stringWithFormat:@"%@ - %@",
            [AmaxEvent long2String:[ev dateAt:0] format:[AmaxEvent monthAbbrDayDateFormatter] h24:NO],
            [AmaxEvent long2String:[ev dateAt:1] format:[AmaxEvent monthAbbrDayDateFormatter] h24:YES]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setDateRangeView:nil];
    [self setInterpreterTextView:nil];
    [self setInterpreterTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = [self makeTitleFromEvent:_interpreterEvent];
    dateRangeView.text = [self makeDateRangeFromEvent:_interpreterEvent];
    [interpreterTextView loadHTMLString:_interpreterText baseURL:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
