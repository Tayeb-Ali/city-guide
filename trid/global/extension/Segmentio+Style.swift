//
//  Segmentio+Style.swift
//  trid
//
//  Created by Black on 10/13/16.
//  Copyright © 2016 Black. All rights reserved.
//

extension Segmentio {
    func segmentioOptions(maxVisibleItems max: Int) -> SegmentioOptions {
        let imageContentMode = UIView.ContentMode.center
        let option = SegmentioOptions(
            backgroundColor: .white,
            maxVisibleItems: max,
            scrollEnabled: true,
            indicatorOptions: segmentioIndicatorOptions(),
            horizontalSeparatorOptions: segmentioHorizontalSeparatorOptions(color: UIColor(netHex: AppSetting.Color.whitesmoke)),
            verticalSeparatorOptions: segmentioVerticalSeparatorOptions(color: UIColor(netHex: AppSetting.Color.whitesmoke)),
            imageContentMode: imageContentMode,
            labelTextAlignment: .center,
            segmentStates: segmentioStates2(font: UIFont(name: AppSetting.Font.roboto_medium, size: AppSetting.FontSize.big)!,
                                           textColor: UIColor(netHex: AppSetting.Color.gray),
                                           textColorSelected: AppState.getCurrentColor()),
            isFlexibleWidth: false
        )
        return option
    }
    
    func segmentioOptions(background: UIColor,
                          maxVisibleItems max: Int,
                          font: UIFont,
                          textColor: UIColor,
                          textColorSelected: UIColor,
                          verticalColor: UIColor,
                          horizontalColor: UIColor,
                          isFlexibleWidth flex: Bool,
                          indicatorColor: UIColor = .white,
                          indicatorHeight: CGFloat? = nil,
                          indicatorOverSeperator: Bool = false) -> SegmentioOptions {
        return SegmentioOptions(
            backgroundColor: background,
            maxVisibleItems: max,
            scrollEnabled: true,
            indicatorOptions: segmentioIndicatorOptions(color: indicatorColor, height: indicatorHeight, isOverSeperator: indicatorOverSeperator),
            horizontalSeparatorOptions: segmentioHorizontalSeparatorOptions(color: horizontalColor, height: indicatorHeight),
            verticalSeparatorOptions: segmentioVerticalSeparatorOptions(color: verticalColor),
            imageContentMode: UIView.ContentMode.bottom,
            labelTextAlignment: .center,
            segmentStates: segmentioStates2(font: font, textColor: textColor, textColorSelected: textColorSelected),
            isFlexibleWidth: flex
        )
    }
    
    func segmentioStates2(font: UIFont, textColor: UIColor, textColorSelected: UIColor) -> SegmentioStates {
        return SegmentioStates(
            defaultState: segmentioState(
                backgroundColor: .clear,
                titleFont: font,
                titleTextColor: textColor
            ),
            selectedState: segmentioState(
                backgroundColor: .clear,
                titleFont: font,
                titleTextColor: textColorSelected
            ),
            highlightedState: segmentioState(
                backgroundColor: .clear,
                titleFont: font,
                titleTextColor: UIColor.white
            )
        )
    }
    
    func segmentioState(backgroundColor: UIColor, titleFont: UIFont, titleTextColor: UIColor) -> SegmentioState {
        return SegmentioState(backgroundColor: backgroundColor, titleFont: titleFont, titleTextColor: titleTextColor)
    }
    
    func segmentioIndicatorOptions(color: UIColor = .white, height: CGFloat? = 2, isOverSeperator: Bool = false) -> SegmentioIndicatorOptions {
        return SegmentioIndicatorOptions(type: .bottom, ratio: 1, height: height ?? 2, color: color, isOverSeperator: isOverSeperator)
    }
    
    func segmentioHorizontalSeparatorOptions(color: UIColor, height: CGFloat? = 1) -> SegmentioHorizontalSeparatorOptions {
        return SegmentioHorizontalSeparatorOptions(type: .bottom, height: height ?? 1, color: color)
    }
    
    func segmentioVerticalSeparatorOptions(color: UIColor) -> SegmentioVerticalSeparatorOptions {
        return SegmentioVerticalSeparatorOptions(ratio: 0.6, color: color)
    }
}

