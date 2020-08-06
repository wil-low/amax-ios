//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxAspectSetCell.h"
#import "AmaxSummaryItem.h"
#import "AmaxSummaryViewController.h"

@implementation AmaxAspectSetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //stackView = (UIStackView *)[self viewWithTag:4];
    //stackView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //stackView.translatesAutoresizingMaskIntoConstraints = false;
}

- (void)configure:(AmaxSummaryItem *)si
{
    [super configure:si];
    NSMutableArray* aspects = [NSMutableArray array];
    for (AmaxEvent *e in si.mEvents) {
        //UIView* view = [[NSBundle mainBundle] loadNibNamed:@"AspectCell" owner:self options:nil].firstObject;
        //UILabel* aspect = (UILabel*)[view viewWithTag:3];
        UIButton* aspect = [UIButton buttonWithType:UIButtonTypeSystem];
        [aspect setTitle:[NSString stringWithFormat:@"%c %c %c",
                          getSymbol(TYPE_PLANET, e.mPlanet0),
                          getSymbol(TYPE_ASPECT, e.mDegree),
                          getSymbol(TYPE_PLANET, e.mPlanet1)]
                forState:UIControlStateNormal];
        aspect.titleLabel.font = [UIFont fontWithName:@"Astronom" size:self.font.pointSize];
        [aspect setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [aspect setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        
        [aspect addTarget:self action:@selector(aspectTapped:) forControlEvents:UIControlEventTouchUpInside];

        [aspects addObject:aspect];
    }
    for (UIView* view in self.contentView.subviews) {
        [view removeFromSuperview];
    }

    UIStackView* stackedInfoView = [[UIStackView alloc] initWithArrangedSubviews:aspects];
    
    stackedInfoView.axis = UILayoutConstraintAxisHorizontal;
    stackedInfoView.distribution = UIStackViewDistributionFillEqually;//EqualSpacing;
    stackedInfoView.alignment = UIStackViewAlignmentFill;
    //stackedInfoView.spacing = 5;
    stackedInfoView.translatesAutoresizingMaskIntoConstraints = false;
    
    // To Make Our Buttons aligned to left We have added one spacer view
    UIButton *spacerButton = [[UIButton alloc] init];
    [spacerButton setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
    [spacerButton setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
    [stackedInfoView addArrangedSubview:spacerButton];

    [self.contentView addSubview:stackedInfoView];

    [stackedInfoView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = true;
    [stackedInfoView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = true;
    [stackedInfoView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = true;
    [stackedInfoView.trailingAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.trailingAnchor].active = true;
    //[stackedInfoView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = true;

    [self updateInfoButtonWith:si];
}

- (void)aspectTapped:(UIButton *)sender
{
    UIResponder *responder = self;
    while ([responder isKindOfClass:[UIView class]])
        responder = [responder nextResponder];
    AmaxSummaryViewController* controller = (AmaxSummaryViewController*)responder;
    [controller showEventListFor:summaryItem xib:@"AspectCell"];
    NSLog(@"Ok button was tapped: dismiss the view controller.");
}
@end
