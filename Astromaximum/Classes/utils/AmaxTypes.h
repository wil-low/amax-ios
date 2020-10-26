//
//  AmaxTypes.h
//  Astromaximum
//
//  Created by admin on 21.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#ifndef Astromaximum_AmaxTypes_h
#define Astromaximum_AmaxTypes_h

typedef enum {
	SE_SUN = 0,
	SE_MOON = 1,
	SE_MERCURY = 2,
	SE_VENUS = 3,
	SE_MARS = 4,
	SE_JUPITER = 5,
	SE_SATURN = 6,
	SE_URANUS = 7,
	SE_NEPTUNE = 8,
	SE_PLUTO = 9,
	SE_TRUE_NODE = 10,
	SE_MEAN_APOG = 11,
	SE_WHITE_MOON = 12,
    SE_UNDEFINED = -1,
} AmaxPlanet;

typedef enum {
	EV_VOC = 0, // void of course
	EV_SIGN_ENTER = 1, // enter into sign
	EV_ASP_EXACT = 2, // exact aspect
	EV_RISE = 3, // rising & setting
	EV_DEGREE_PASS = 4, // entering degree
	EV_VIA_COMBUSTA = 5, // good & bad degrees
	EV_RETROGRADE = 6,
	EV_ECLIPSE = 7,
	EV_TITHI = 8,
	EV_NAKSHATRA = 9,
	EV_SET = 10, // rising & setting
	EV_DECL_EXACT = 11, // declination
	EV_NAVROZ = 12, // Navroz
	EV_TOP_DAY = 13, // week days
	EV_PLANET_HOUR = 14, // planetary hours
	EV_STATUS = 15,
	EV_SUN_RISE = 16,
	EV_MOON_RISE = 17,
	EV_MOON_MOVE = 18,
	EV_SEL_DEGREES = 19,
	EV_DAY_HOURS = 20,
	EV_NIGHT_HOURS = 21,
	EV_SUN_DAY = 22,
	EV_MOON_DAY = 23,
	EV_TOP_MONTH = 24,
	EV_MOON_PHASE = 25,
	EV_ZODIAC_SIGN = 26,
	EV_PANEL = 27,
	EV_TOPIC_BUTTON = 28,
	EV_DEG_2ND = 29, // degrees on second page
	EV_WEEK_GRID = 30,
	EV_MONTH_GRID = 31,
	EV_DECUMBITURE = 32,
	EV_DECUMB_ASPECT = 33,
	EV_DECUMB_BEGIN = 34,
	EV_SUN_DEGREE_LARGE = 35,
	EV_MOON_SIGN_LARGE = 36,
	EV_HELP = 37,
	EV_ASP_EXACT_MOON = 38,
	EV_HELP0 = 43,
	EV_HELP1 = 44,
	EV_ASTRORISE = 45,
	EV_ASTROSET = 46,
	EV_APHETICS = 47,
	EV_FAST = 48,
	EV_ASCAPHETICS = 49,
	EV_MSG = 50,
	EV_BACK = 51,
	EV_TATTVAS = 52,
	EV_SUN_DEGREE = 53,
	EV_MOON_SIGN = 54,
	EV_SUN_RISESET = 55,
	EV_MOON_RISESET = 56,
	EV_LAST = 57, // last - do not use
    
} AmaxEventType;

static const int AmaxLABEL_FONT_SIZE = 26;

typedef enum {
    TYPE_PLANET = 0,
    TYPE_ASPECT = 1,
    TYPE_ZODIAC = 2,
    TYPE_RETROGRADE = 3,
} SymbolType;

char getSymbol(SymbolType type, int id);
int dateBetween(long date0, long start, long end);

#endif
