//
//  AmaxTypes.c
//  Astromaximum
//
//  Created by admin on 27.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#include "AmaxTypes.h"

char getSymbol(SymbolType type, int id)
{
    char result = '?';
    switch (type) {
		case TYPE_PLANET:
			result = 0x50 + id;
			break;
		case TYPE_ASPECT:
			switch (id) {
                case 0: result = 0x60; break;
                case 180: result = 0x64; break;
                case 120: result = 0x63; break;
                case 90: result = 0x62; break;
                case 60: result = 0x61; break;
                case 45: result = 0x65; break;
			}
			break;
		case TYPE_ZODIAC:
			result = 0x40 + id;
			break;
		case TYPE_RETROGRADE:
			result = 0x24;
			break;
    }
    return result;
}

int dateBetween(long date0, long start, long end)
{
    if (date0 < start) {
        return -1;
    }
    if (date0 > end) {
        return 1;
    }
    return 0;
}
/*
func dateBetween(_ date0: Int, _ start: Int, _ end: Int) -> Int {
    if date0 < start {
        return -1
    }
    if date0 > end {
        return 1
    }
    return 0
}
*/
