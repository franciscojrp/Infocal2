using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Date;

enum /* FIELD_TYPES */ {
	FIELD_TYPE_HEART_RATE = 0,
	FIELD_TYPE_BATTERY,
	FIELD_TYPE_CALORIES,
	FIELD_TYPE_DISTANCE,
	FIELD_TYPE_MOVE,
	FIELD_TYPE_STEP,
	FIELD_TYPE_ACTIVE,
	
	FIELD_TYPE_DATE,
	FIELD_TYPE_TIME,
	FIELD_TYPE_EMPTY,
	
	FIELD_TYPE_NOTIFICATIONS = 10,
	FIELD_TYPE_ALARMS,
	FIELD_TYPE_ALTITUDE,
	FIELD_TYPE_TEMPERATURE,
	FIELD_TYPE_SUNRISE_SUNSET,
	FIELD_TYPE_FLOOR,
	FIELD_TYPE_GROUP_NOTI,
	FIELD_TYPE_DISTANCE_WEEK,
	FIELD_TYPE_BAROMETER,
	FIELD_TYPE_TIME_SECONDARY,
	FIELD_TYPE_PHONE_STATUS,
	FIELD_TYPE_COUNTDOWN,
	FIELD_TYPE_WEEKCOUNT,
	
	FIELD_TYPE_TEMPERATURE_OUT = 23,
	FIELD_TYPE_TEMPERATURE_HL,
	FIELD_TYPE_WEATHER,
	
	FIELD_TYPE_AMPM_INDICATOR = 26,
	FIELD_TYPE_CTEXT_INDICATOR,
	FIELD_TYPE_WIND,
	FIELD_TYPE_RECOVERY
}

function buildFieldObject(type) {
	if (type==FIELD_TYPE_HEART_RATE) {
		return new HRField(FIELD_TYPE_HEART_RATE);
	} else if (type==FIELD_TYPE_BATTERY) {
		return new BatteryField(FIELD_TYPE_BATTERY);
	} else if (type==FIELD_TYPE_CALORIES) {
		return new CaloField(FIELD_TYPE_CALORIES);
	} else if (type==FIELD_TYPE_DISTANCE) {
		return new DistanceField(FIELD_TYPE_DISTANCE);
	} else if (type==FIELD_TYPE_MOVE) {
		return new MoveField(FIELD_TYPE_MOVE);
	} else if (type==FIELD_TYPE_STEP) {
		return new StepField(FIELD_TYPE_STEP);
	} else if (type==FIELD_TYPE_ACTIVE) {
		return new ActiveField(FIELD_TYPE_ACTIVE);
	} else if (type==FIELD_TYPE_DATE) {
		return new DateField(FIELD_TYPE_DATE);
	} else if (type==FIELD_TYPE_TIME) {
		return new TimeField(FIELD_TYPE_TIME);
	} else if (type==FIELD_TYPE_EMPTY) {
		return new EmptyDataField(FIELD_TYPE_EMPTY);
	} else if (type==FIELD_TYPE_NOTIFICATIONS) {
		return new NotifyField(FIELD_TYPE_NOTIFICATIONS);
	} else if (type==FIELD_TYPE_ALARMS) {
		return new AlarmField(FIELD_TYPE_ALARMS);
	} else if (type==FIELD_TYPE_ALTITUDE) {
		return new AltitudeField(FIELD_TYPE_ALTITUDE);
	} else if (type==FIELD_TYPE_TEMPERATURE) {
		return new TemparatureField(FIELD_TYPE_TEMPERATURE);
	} else if (type==FIELD_TYPE_SUNRISE_SUNSET) {
		return new SunField(FIELD_TYPE_SUNRISE_SUNSET);
	} else if (type==FIELD_TYPE_FLOOR) {
		return new FloorField(FIELD_TYPE_FLOOR);
	} else if (type==FIELD_TYPE_GROUP_NOTI) {
		return new GroupNotiField(FIELD_TYPE_GROUP_NOTI);
	} else if (type==FIELD_TYPE_DISTANCE_WEEK) {
		return new WeekDistanceField(FIELD_TYPE_DISTANCE_WEEK);
	} else if (type==FIELD_TYPE_BAROMETER) {
		return new BarometerField(FIELD_TYPE_BAROMETER);
	} else if (type==FIELD_TYPE_TIME_SECONDARY) {
		return new TimeSecondaryField(FIELD_TYPE_TIME_SECONDARY);
	} else if (type==FIELD_TYPE_PHONE_STATUS) {
		return new PhoneField(FIELD_TYPE_PHONE_STATUS);
	} else if (type==FIELD_TYPE_COUNTDOWN) {
		return new CountdownField(FIELD_TYPE_COUNTDOWN);
	} else if (type==FIELD_TYPE_WEEKCOUNT) {
		return new WeekCountField(FIELD_TYPE_WEEKCOUNT);
	} else if (type==FIELD_TYPE_TEMPERATURE_OUT) {
		return new TemparatureOutField(FIELD_TYPE_TEMPERATURE_OUT);
	} else if (type==FIELD_TYPE_TEMPERATURE_HL) {
		return new TemparatureHLField(FIELD_TYPE_TEMPERATURE_HL);
	} else if (type==FIELD_TYPE_WEATHER) {
		return new WeatherField(FIELD_TYPE_WEATHER);
	} else if (type==FIELD_TYPE_AMPM_INDICATOR) {
		return new AMPMField(FIELD_TYPE_AMPM_INDICATOR);
	} else if (type==FIELD_TYPE_CTEXT_INDICATOR) {
		return new CTextField(FIELD_TYPE_CTEXT_INDICATOR);
	} else if (type==FIELD_TYPE_WIND) {
		return new WindField(FIELD_TYPE_WIND);
	} else if (type==FIELD_TYPE_RECOVERY) {
		return new RecoveryField(FIELD_TYPE_RECOVERY);
	}
	
	return new EmptyDataField(FIELD_TYPE_EMPTY);
}

class BaseDataField {
	
	function initialize(id) {
		_field_id = id;
	}

	private var _field_id;

	function field_id() {
		return _field_id;
	}

	function have_secondary() {
		return false;
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 100.0;
	}
	
	function cur_val() {
		return 0.01;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "100";
	}
	
	function cur_label(value) {
		return "0";
	}
	
	function need_draw() {
		return true;
	}
	
	function bar_data() {
		return false;
	}
}

class EmptyDataField {

	function initialize(id) {
		_field_id = id;
	}

	private var _field_id;

	function field_id() {
		return _field_id;
	}
	
	function need_draw() {
		return false;
	}
}

///////////////////
// weather stage //
///////////////////

class WindField extends BaseDataField {

	var wind_direction_mapper;

	function initialize(id) {
		BaseDataField.initialize(id);
		wind_direction_mapper = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW",  "WSW", "W", "WNW", "NW", "NNW"];  
	}
	
	function cur_label(value) {
		// WEATHER
		var need_minimal = App.getApp().getProperty("minimal_data");
		var settings = Sys.getDeviceSettings();
		var speed = Weather.getCurrentConditions().windSpeed;
		var direct = Weather.getCurrentConditions().windBearing;
		
		var direct_corrected = direct + 11.25;                                 					// move degrees to int spaces (North from 348.75-11.25 to 360(min)-22.5(max))
		direct_corrected = direct_corrected < 360 ? direct_corrected : direct_corrected - 360;  // move North from 360-371.25 back to 0-11.25 (final result is North 0(min)-22.5(max))
		var direct_idx = (direct_corrected / 22.5).toNumber();                         			// now calculate direction array position: int([0-359.99]/22.5) will result in 0-15 (correct array positions)
		
		var directLabel = wind_direction_mapper[direct_idx];
		var unit = "k";
		if (settings.distanceUnits == System.UNIT_STATUTE) {	
			speed *= 0.621371;
			unit = "m";		
		}
		return directLabel + " " + speed.format("%0.1f") + unit;
	}
}

///////////////////////
// custom text stage //
///////////////////////

class CTextField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
    	var custom_text = App.getApp().getProperty("ctext_input");
		if (custom_text.length() == 0) {
			return "--";
		}
		return custom_text;
	}
}

///////////////////
// weather stage //
///////////////////

class WeatherField extends BaseDataField {

	var weather_icon_mapper;

	function initialize(id) {
		BaseDataField.initialize(id);
		
		weather_icon_mapper = {
    		"01d" => "", //sunny
			"02d" => "", //few clouds
			"03d" => "", //scattered clouds
			"04d" => "", //broken clouds
			"09d" => "", //shower rain
			"10d" => "", //rain
			"11d" => "", //thunderstorm
			"13d" => "", //snow
			"50d" => "", //mist
			
			"01n" => "", //sunny
			"02n" => "", //few clouds
			"03n" => "", //scattered clouds
			"04n" => "", //broken clouds
			"09n" => "", //shower rain
			"10n" => "", //rain
			"11n" => "", //thunderstorm
			"13n" => "", //snow
			"50n" => "", //mist
		};
	}
	
	function cur_icon() {
		var condition = Weather.getCurrentConditions().condition;
		if (condition == Weather.CONDITION_CLEAR) {
			return "";
		} else if (condition == Weather.CONDITION_PARTLY_CLOUDY) {
			return "";
		} else if (condition == Weather.CONDITION_MOSTLY_CLOUDY) {
			return "";
		} else if (condition == Weather.CONDITION_THIN_CLOUDS) {
			return "";
		} else if (condition == Weather.CONDITION_RAIN) {
			return "";
		} else if (condition == Weather.CONDITION_SNOW) {
			return "";
		} else if (condition == Weather.CONDITION_WINDY) {
			return "";//TODO
		} else if (condition == Weather.CONDITION_THUNDERSTORMS) {
			return "";
		} else if (condition == Weather.CONDITION_WINTRY_MIX) {
			return "";//TODO
		} else if (condition == Weather.CONDITION_FOG) {
			return "";
		} else if (condition == Weather.CONDITION_HAZY) {
			return "";
		} else if (condition == Weather.CONDITION_HAIL) { //Granizo
			return "";
		} else if (condition == Weather.CONDITION_SCATTERED_SHOWERS) {
			return "";
		} else if (condition == Weather.CONDITION_SCATTERED_THUNDERSTORMS) {
			return "";
		} else if (condition == Weather.CONDITION_UNKNOWN_PRECIPITATION) {
			return "";
		} else if (condition == Weather.CONDITION_LIGHT_RAIN) {
			return "";
		} else if (condition == Weather.CONDITION_HEAVY_RAIN) {
			return "";
		} else if (condition == Weather.CONDITION_LIGHT_SNOW) {
			return "";
		} else if (condition == Weather.CONDITION_HEAVY_SNOW) {
			return "";
		} else if (condition == Weather.CONDITION_LIGHT_RAIN_SNOW) {
			return "";
		} else if (condition == Weather.CONDITION_HEAVY_RAIN_SNOW) {
			return "";
		} else if (condition == Weather.CONDITION_CLOUDY) {
			return "";
		} else if (condition == Weather.CONDITION_RAIN_SNOW) {
			return "";
		} else if (condition == Weather.CONDITION_PARTLY_CLEAR) {
			return "";
		} else if (condition == Weather.CONDITION_MOSTLY_CLEAR) {
			return "";
		} else if (condition == Weather.CONDITION_LIGHT_SHOWERS) {
			return "";
		} else if (condition == Weather.CONDITION_SHOWERS) {
			return "";
		} else if (condition == Weather.CONDITION_HEAVY_SHOWERS) {
			return "";
		} else if (condition == Weather.CONDITION_CHANCE_OF_SHOWERS) {
			return "";
		} else if (condition == Weather.CONDITION_CHANCE_OF_THUNDERSTORMS) {
			return "";
		} else if (condition == Weather.CONDITION_MIST) {
			return "";
		} else if (condition == Weather.CONDITION_FAIR) {
			return "";
		} else if (condition == Weather.CONDITION_HURRICANE) {
			return "";//TODO
		} else if (condition == Weather.CONDITION_TROPICAL_STORM) {
			return "";
		} else if (condition == Weather.CONDITION_CHANCE_OF_SNOW) {
			return "";
		} else if (condition == Weather.CONDITION_CHANCE_OF_RAIN_SNOW) {
			return "";
		} else if (condition == Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN) {
			return "";
		} else if (condition == Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW) {
			return "";
		} else if (condition == Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW) {
			return "";
			
		} else if (condition == Weather.CONDITION_DUST) {
			return "";
		} else if (condition == Weather.CONDITION_DRIZZLE) {
			return "";
		} else if (condition == Weather.CONDITION_TORNADO) {
			return "";
		} else if (condition == Weather.CONDITION_SMOKE) {
			return "";
		} else if (condition == Weather.CONDITION_ICE) {
			return "";
		} else if (condition == Weather.CONDITION_SAND) {
			return "";
		} else if (condition == Weather.CONDITION_SQUALL) {
			return "";
		} else if (condition == Weather.CONDITION_SANDSTORM) {
			return "";
		} else if (condition == Weather.CONDITION_VOLCANIC_ASH) {
			return "";
		} else if (condition == Weather.CONDITION_HAZE) {
			return "";
		} else if (condition == Weather.CONDITION_FLURRIES) {
			return "";
		} else if (condition == Weather.CONDITION_FREEZING_RAIN) {
			return "";
		} else if (condition == Weather.CONDITION_SLEET) {
			return "";
		} else if (condition == Weather.CONDITION_ICE_SNOW) {
			return "";
		} else if (condition == Weather.CONDITION_UNKNOWN) {
			return "";
		}
		return "";
	}
	
	function cur_label(value) {
		// WEATHER
		// var need_minimal = App.getApp().getProperty("minimal_data");

		// var settings = Sys.getDeviceSettings();
		// var temp = Weather.getCurrentConditions().feelsLikeTemperature;
		// var unit = "°C";
		// if (settings.temperatureUnits == System.UNIT_STATUTE) {
		// 	temp = (temp * (9.0 / 5)) + 32; // Convert to Farenheit: ensure floating point division.
		// 	unit = "°F";
		// }
		// value = temp.format("%d") + unit;
	
		var description = get_weather_desc(Weather.getCurrentConditions().condition);
		if (description != null) {
			return description;// + " " +  value;
		}
	}

	function get_weather_desc(condition) {
		if (condition == Weather.CONDITION_CLEAR) {
			return "Clear";
		} else if (condition == Weather.CONDITION_PARTLY_CLOUDY) {
			return "Part. Cloudy";
		} else if (condition == Weather.CONDITION_MOSTLY_CLOUDY) {
			return "Most. Cloudy";
		} else if (condition == Weather.CONDITION_THIN_CLOUDS) {
			return "Thin Clouds";
		} else if (condition == Weather.CONDITION_RAIN) {
			return "Rain";
		} else if (condition == Weather.CONDITION_SNOW) {
			return "Snow";
		} else if (condition == Weather.CONDITION_WINDY) {
			return "Windy";
		} else if (condition == Weather.CONDITION_THUNDERSTORMS) {
			return "Thunderst.";
		} else if (condition == Weather.CONDITION_WINTRY_MIX) {
			return "Rain-Snow";
		} else if (condition == Weather.CONDITION_FOG) {
			return "Fog";
		} else if (condition == Weather.CONDITION_HAZY) {
			return "Hazy";
		} else if (condition == Weather.CONDITION_HAIL) {
			return "Hail";
		} else if (condition == Weather.CONDITION_SCATTERED_SHOWERS) {
			return "Showers";
		} else if (condition == Weather.CONDITION_SCATTERED_THUNDERSTORMS) {
			return "Thunderst.";
		} else if (condition == Weather.CONDITION_UNKNOWN_PRECIPITATION) {
			return "Precipit.";
		} else if (condition == Weather.CONDITION_LIGHT_RAIN) {
			return "Light Rain";
		} else if (condition == Weather.CONDITION_HEAVY_RAIN) {
			return "Heavy Rain";
		} else if (condition == Weather.CONDITION_LIGHT_SNOW) {
			return "Light Snow";
		} else if (condition == Weather.CONDITION_HEAVY_SNOW) {
			return "Heavy Snow";
		} else if (condition == Weather.CONDITION_LIGHT_RAIN_SNOW) {
			return "Rain-Snow";
		} else if (condition == Weather.CONDITION_HEAVY_RAIN_SNOW) {
			return "Rain-Snow";
		} else if (condition == Weather.CONDITION_CLOUDY) {
			return "Cloudy";
		} else if (condition == Weather.CONDITION_RAIN_SNOW) {
			return "Rain-Snow";
		} else if (condition == Weather.CONDITION_PARTLY_CLEAR) {
			return "Part. Clear";
		} else if (condition == Weather.CONDITION_MOSTLY_CLEAR) {
			return "Most. Clear";
		} else if (condition == Weather.CONDITION_LIGHT_SHOWERS) {
			return "Showers";
		} else if (condition == Weather.CONDITION_SHOWERS) {
			return "Showers";
		} else if (condition == Weather.CONDITION_HEAVY_SHOWERS) {
			return "Showers";
		} else if (condition == Weather.CONDITION_CHANCE_OF_SHOWERS) {
			return "Showers";
		} else if (condition == Weather.CONDITION_CHANCE_OF_THUNDERSTORMS) {
			return "Thunderst.";
		} else if (condition == Weather.CONDITION_MIST) {
			return "Mist";
		} else if (condition == Weather.CONDITION_FAIR) {
			return "Fair";
		} else if (condition == Weather.CONDITION_HURRICANE) {
			return "Hurricane";
		} else if (condition == Weather.CONDITION_TROPICAL_STORM) {
			return "Trop. Storm";
		} else if (condition == Weather.CONDITION_CHANCE_OF_SNOW) {
			return "Snow";
		} else if (condition == Weather.CONDITION_CHANCE_OF_RAIN_SNOW) {
			return "Rain-Snow";
		} else if (condition == Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN) {
			return "Clouds-Rain";
		} else if (condition == Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW) {
			return "Clouds-Snow";
		} else if (condition == Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW) {
			return "Clouds-Snow";
		} else if (condition == Weather.CONDITION_DUST) {
			return "Dust";
		} else if (condition == Weather.CONDITION_DRIZZLE) {
			return "Drizzle";
		} else if (condition == Weather.CONDITION_TORNADO) {
			return "Tornado";
		} else if (condition == Weather.CONDITION_SMOKE) {
			return "Smoke";
		} else if (condition == Weather.CONDITION_ICE) {
			return "Ice";
		} else if (condition == Weather.CONDITION_SAND) {
			return "Sand";
		} else if (condition == Weather.CONDITION_SQUALL) {
			return "Squall";
		} else if (condition == Weather.CONDITION_SANDSTORM) {
			return "Sandstorm";
		} else if (condition == Weather.CONDITION_VOLCANIC_ASH) {
			return "Volc. Ash";
		} else if (condition == Weather.CONDITION_HAZE) {
			return "Haze";
		} else if (condition == Weather.CONDITION_FLURRIES) {
			return "Flurries";
		} else if (condition == Weather.CONDITION_FREEZING_RAIN) {
			return "Freez. Rain";
		} else if (condition == Weather.CONDITION_SLEET) {
			return "Sleet";
		} else if (condition == Weather.CONDITION_ICE_SNOW) {
			return "Ice Snow";
		} else if (condition == Weather.CONDITION_UNKNOWN) {
			return "Unknown";
		}
		return "Unknown";
	}
}

/////////////////
// AM/PM stage //
/////////////////

class AMPMField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
    	var clockTime = Sys.getClockTime();        		
    	var hour = clockTime.hour;
		if (hour>=12) {
			return "pm";
		} else {
			return "am";
		}
	}
}

///////////////////////////
// temparature hl stage //
///////////////////////////

class TemparatureHLField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		// WEATHER
		var need_minimal = App.getApp().getProperty("minimal_data");
		var settings = Sys.getDeviceSettings();
		var temp_min = Weather.getCurrentConditions().lowTemperature;
		var temp_max = Weather.getCurrentConditions().highTemperature;
		var unit = "°C";
		if (settings.temperatureUnits == System.UNIT_STATUTE) {
			temp_min = (temp_min * (9.0 / 5)) + 32; // Convert to Farenheit: ensure floating point division.
			temp_max = (temp_max * (9.0 / 5)) + 32; // Convert to Farenheit: ensure floating point division.
			unit = "°F";
		}
		if (need_minimal) {
			return Lang.format("$1$ $2$",[temp_max.format("%d"), temp_min.format("%d")]);
		} else {
			return Lang.format("H $1$° - L $2$°",[temp_max.format("%d"), temp_min.format("%d")]);
		}
	}
}

///////////////////////////
// temparature out stage //
///////////////////////////

class TemparatureOutField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		// WEATHER
		var need_minimal = App.getApp().getProperty("minimal_data");
		var settings = Sys.getDeviceSettings();
		var temp = Weather.getCurrentConditions().temperature;
		var unit = "°C";
		if (settings.temperatureUnits == System.UNIT_STATUTE) {
			temp = (temp * (9.0 / 5)) + 32; // Convert to Farenheit: ensure floating point division.
			unit = "°F";
		}
		value = temp.format("%d") + unit;
		
		if (need_minimal) {
			return value;
		} else {
			return Lang.format("TEMP $1$",[value]);
		}
	}
}

/////////////////////
// Weekcount stage //
/////////////////////

class WeekCountField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function julian_day(year, month, day) { 
		var a = (14 - month) / 12; 
		var y = (year + 4800 - a); 
		var m = (month + 12 * a - 3); 
		return day + ((153 * m + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045; 
	} 
	
	function is_leap_year(year) { 
		if (year % 4 != 0) { 
			return false; 
		} else if (year % 100 != 0) { 
			return true; 
		} else if (year % 400 == 0) { 
			return true; 
		} 
		return false; 
	} 
	
	function iso_week_number(year, month, day) { 
		var first_day_of_year = julian_day(year, 1, 1); 
		var given_day_of_year = julian_day(year, month, day); 
		
		var day_of_week = (first_day_of_year + 3) % 7; // days past thursday 
		var week_of_year = (given_day_of_year - first_day_of_year + day_of_week + 4) / 7; 
		
		// week is at end of this year or the beginning of next year 
		if (week_of_year == 53) { 
			if (day_of_week == 6) { 
				return week_of_year; 
			} else if (day_of_week == 5 && is_leap_year(year)) { 
				return week_of_year; 
			} else { 
			return 1; 
			} 
		} // week is in previous year, try again under that year 
		else if (week_of_year == 0) { 
			first_day_of_year = julian_day(year - 1, 1, 1); 
			
			day_of_week = (first_day_of_year + 3) % 7; 
			
			return (given_day_of_year - first_day_of_year + day_of_week + 4) / 7; 
		} // any old week of the year 
		else { 
			return week_of_year; 
		} 
	} 
	
	function cur_label(value) {
		var date = Date.info(Time.now(), Time.FORMAT_SHORT);
		var week_num = iso_week_number(date.year, date.month, date.day);
		return Lang.format("WEEK $1$",[week_num]);
	}

}

/////////////////////////
// end Weekcount stage //
/////////////////////////

/////////////////////
// Countdown stage //
/////////////////////

class CountdownField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		var set_end_date = new Time.Moment(App.getApp().getProperty("countdown_date"));
	    var now_d = new Time.Moment(Time.today().value());
	    var dif_e_n = -(now_d.compare(set_end_date))/86400;
	    if (dif_e_n>1 || dif_e_n<-1) {
	    	return Lang.format("$1$ days",[dif_e_n.toString()]);
	    } else {
	    	return Lang.format("$1$ day",[dif_e_n.toString()]);
	    }
	}
}

/////////////////////////
// end countdown stage //
/////////////////////////

//////////////////////////
// time secondary stage //
//////////////////////////

class TimeSecondaryField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		var currentSettings = System.getDeviceSettings();
		var clockTime = Sys.getClockTime();     
		var to_utc_second = clockTime.timeZoneOffset;
		
		var target = App.getApp().getProperty("utc_timezone");
		var shift_val = App.getApp().getProperty("utc_shift") ? 0.5 : 0.0;
    	var secondary_zone_delta = (target+shift_val)*3600 - to_utc_second;
    	
 		var now = Time.now();
		var now_target_zone_delta = new Time.Duration(secondary_zone_delta);
		var now_target_zone = now.add(now_target_zone_delta);
		var target_zone = Date.info(now_target_zone, Time.FORMAT_SHORT);
		  		
    	var hour = target_zone.hour;
    	var minute = target_zone.min;      		
    	var mark = "";
		if(!currentSettings.is24Hour) {
			if (hour>=12) {
				mark = "pm";
			} else {
				mark = "am";
			}
			hour = hour % 12;
        	hour = (hour == 0) ? 12 : hour;  
        }    
        return Lang.format("$1$:$2$ $3$",[hour, minute.format("%02d"), mark]);
	}
}

//////////////////////////////
// end time secondary stage //
//////////////////////////////

////////////////
// baro stage //
////////////////

class BarometerField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_val() {
		var presure_data = _retrieveBarometer();
		return presure_data;
	}
	
	function cur_label(value) {
		var value1 = value[0];
		var value2 = value[1];
		if (value1 == null) {
			return "BARO --";
		} else {
			var hector_pascal = value1/100.0;
			
			var unit = App.getApp().getProperty("barometer_unit");
			if (unit == 1) {
				// convert to inHg
				hector_pascal = hector_pascal*0.0295301;
			}
			var signal = "";
			if (value2==1) {
				signal = "+";
			} else if (value2==-1) {
				signal = "-";
			}
			
			if (unit == 1) {
				return Lang.format("BAR $1$$2$",[hector_pascal.format("%0.2f"), signal]);
			}
			return Lang.format("BAR $1$$2$",[hector_pascal.format("%d"), signal]);
		}
	}
	
	// Create a method to get the SensorHistoryIterator object
	function _getIterator() {
	    // Check device for SensorHistory compatibility
	    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)) {
	        return Toybox.SensorHistory.getPressureHistory({});
	    }
	    return null;
	}
	
	// Create a method to get the SensorHistoryIterator object
	function _getIteratorDurate(hour) {
	    // Check device for SensorHistory compatibility
	    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)) {
	    	var duration = new Time.Duration(hour*3600);
	        return Toybox.SensorHistory.getPressureHistory({"period"=>duration, "order"=>SensorHistory.ORDER_OLDEST_FIRST});
	    }
	    return null;
	}
	
	function _retrieveBarometer() {
		var trend_iter = _getIteratorDurate(3); // 3 hour
		var trending = null;
		if (trend_iter!= null) {
			// get 5 sample
			var sample = null;
			var num = 0.0;
			for (var i=0;i<5;i+=1) {
				sample = trend_iter.next();
				if ((sample != null) && (sample has :data)) {
					var d = sample.data;
					if (d != null) {
						 if (trending == null) {
						 	trending = d;
						 	num += 1;
						 } else {
						 	trending += d;
						 	num += 1;
						 }
					}
				}
			}
			if (trending!=null) {
				trending/=num;
			}
		}
		var iter = _getIterator();
		// Print out the next entry in the iterator
		if (iter != null) {
			var sample = iter.next();
			if ((sample != null) && (sample has :data)) {
				var d = sample.data;
				var c = 0;
				if (trending != null && d != null) {
					c = trending > d ? -1 : 1;
				}
				return [d, c];
			}
		}
		return [null, 0];
	}
	
}

////////////////////
// end baro stage //
////////////////////

/////////////////////////
// distance week stage //
/////////////////////////

class WeekDistanceField extends BaseDataField {

	var days;
	
	function initialize(id) {
		BaseDataField.initialize(id);
		days = {Date.DAY_MONDAY => "MON", 
				Date.DAY_TUESDAY => "TUE", 
				Date.DAY_WEDNESDAY => "WED", 
				Date.DAY_THURSDAY => "THU", 
				Date.DAY_FRIDAY => "FRI", 
				Date.DAY_SATURDAY => "SAT", 
				Date.DAY_SUNDAY => "SUN"};
	}

	function min_val() {
    	return 50.0;
	}
	
	function max_val() {
		var datas = _retriveWeekValues();
	    return datas[1];
	}
	
	function cur_val() {
		var datas = _retriveWeekValues();
		return datas[0];
	}
	
	function cur_label(value) {
		var datas = _retriveWeekValues();
		var total_distance = datas[0];
		
		var need_minimal = App.getApp().getProperty("minimal_data");
		var settings = Sys.getDeviceSettings();
		
		var value2 = total_distance;
		var kilo = value2/100000;
		
		var unit = "Km";
		if (settings.distanceUnits == System.UNIT_METRIC) {					
		} else {
			kilo *= 0.621371;
			unit = "Mi";
		}
		
		if (need_minimal) {
			return Lang.format("$1$ $2$",[kilo.format("%0.1f"), unit]);
		} else {
	    	var valKp = App.getApp().toKValue(kilo*1000);
	    	return Lang.format("DIS $1$$2$",[valKp, unit]);
    	}
	}
	
	function day_of_week(activity) {
		var moment = activity.startOfDay;
		var date = Date.info(moment, Time.FORMAT_SHORT);
		return date.day_of_week;
	}
	
	function today_of_week() {
		var now = Time.now();
		var date = Date.info(now, Time.FORMAT_SHORT);
		return date.day_of_week;
	}
	
	function _retriveWeekValues() {
		var settings = System.getDeviceSettings();
		var firstDayOfWeek = settings.firstDayOfWeek;
		
		var activities = [];
		var activityInfo = ActivityMonitor.getInfo();
		activities.add(activityInfo);
			
		if (today_of_week() != firstDayOfWeek) {
			if (ActivityMonitor has :getHistory) {
				var his = ActivityMonitor.getHistory();
				for (var i = 0; i < his.size(); i++ ) {
					var activity = his[i];
					activities.add(activity);
					if (day_of_week(activity)==firstDayOfWeek) {
						break;
					}
				}
			}
		}
		
		var total = 0.0;
		for (var i = 0; i<activities.size();i++) {
			total += activities[i].distance;
		}
		return [total, 10.0];
	}
	
	function bar_data() {
		return true;
	}
}

/////////////////////////////
// end distance week stage //
/////////////////////////////

////////////////////////
// phone status stage //
////////////////////////

class PhoneField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		var settings = Sys.getDeviceSettings();
		if (settings.phoneConnected) {
			return "CONN";
		} else {
			return "--";
		}
	}
}

////////////////////////////
// end phone status stage //
////////////////////////////

//////////////////////
// group noti stage //
//////////////////////

class GroupNotiField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		var settings = Sys.getDeviceSettings();
		value = settings.alarmCount;
		var alarm_str = Lang.format("A$1$",[value.format("%d")]);
		value = settings.notificationCount;
		var noti_str = Lang.format("N$1$",[value.format("%d")]);
		
		if (settings.phoneConnected) {
			return Lang.format("$1$-$2$-C",[noti_str, alarm_str]);
		} else {
			return Lang.format("$1$-$2$-D",[noti_str, alarm_str]);
		}
	}
}

//////////////////////////
// end group noti stage //
//////////////////////////

/////////////////
// floor stage //
/////////////////

class FloorField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function max_val() {
		var activityInfo = ActivityMonitor.getInfo();
		if (activityInfo has :floorsClimbedGoal) {
			return activityInfo.floorsClimbedGoal.toFloat();
		} else {
			return 1.0;
		}
	}
	
	function cur_val() {
		var activityInfo = ActivityMonitor.getInfo();
		if (activityInfo has :floorsClimbed) {
			return activityInfo.floorsClimbed.toFloat();
		} else {
			return 0.0;
		}
	}
	
	function max_label(value) {
    	return value.format("%d");
	}
	
	function cur_label(value) {
		if (value==null) {
			return "FLOOR --";
		}
	   	return Lang.format("FLOOR $1$",[value.format("%d")]);
	}
	
	function bar_data() {
		return true;
	}
}

/////////////////////
// end floor stage //
/////////////////////

///////////////
// sun stage //
///////////////

class SunField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		var position = null;
		var location = Position.getInfo();
		if (location != null && location.position != null && location.accuracy != Position.QUALITY_NOT_AVAILABLE) {
			//Sys.println("Saving location with accuracy " + location.accuracy);
			position = location.position;
			var loc = location.position.toDegrees(); // Array of Doubles.
			gLocationLat = loc[0].toFloat();
			gLocationLng = loc[1].toFloat();
			//Sys.println("location: " + gLocationLat + ", " + gLocationLng);
			Application.getApp().setProperty("LastLocationLat", gLocationLat);
			Application.getApp().setProperty("LastLocationLng", gLocationLng);
		} else {
			location = null;
			var lat = Application.getApp().getProperty("LastLocationLat");
			if (lat != null) {
				gLocationLat = lat;
			}

			var lng = Application.getApp().getProperty("LastLocationLng");
			if (lng != null) {
				gLocationLng = lng;
			}

			if (lat != null && lng != null) {
				//Sys.println("Using last location: " + gLocationLat + "," + gLocationLng);
				position = new Position.Location(
				{
					:latitude => gLocationLat,
					:longitude => gLocationLng,
					:format => :degrees
				});
			} else {
				//Sys.println("No location available");
			}
		}

		if (position != null) {
			value = "";
			var nextSunEvent = 0;
			var isSunriseNext = false;
			var now = Time.now();
			//Sys.println("location: " + position.toGeoString(Position.GEO_DM));
			var sunrise = Weather.getSunrise(position, now);
			var sunset = Weather.getSunset(position, now);
	
			// If sunrise/sunset happens today.
			var sunriseSunsetToday = ((sunrise != null) && (sunset != null));
			//Sys.println("sunriseSunsetToday: " + sunriseSunsetToday);

			if (sunriseSunsetToday) {
	
				// Before sunrise today: today's sunrise is next.
				if (now.lessThan(sunrise)) {
					nextSunEvent = sunrise;
					isSunriseNext = true;
	
				// After sunrise today, before sunset today: today's sunset is next.
				} else if (now.lessThan(sunset)) {
					nextSunEvent = sunset;
	
				// After sunset today: tomorrow's sunrise (if any) is next.
				} else {
					nextSunEvent = Weather.getSunrise(location.position, Time.today().add(new Time.Duration(86401)));
					isSunriseNext = true;
				}
			}
	
			// Sun never rises/sets today.
			if (!sunriseSunsetToday) {
				// Sun never rises: sunrise is next, but more than a day from now.
				if (sunset == null) {
					isSunriseNext = true;
				}
				return "SUN --";
			// We have a sunrise/sunset time.
			} else {
				var need_minimal = App.getApp().getProperty("minimal_data");
				var time = Date.info(nextSunEvent, Time.FORMAT_MEDIUM);
				var hour = time.hour;
				var min = time.min;
				var ftime = getFormattedTime(hour, min);
//				var timestr = ftime[:hour] + ":" + ftime[:min] + ftime[:amPm]; 
				var timestr = ftime[:hour] + ":" + ftime[:min]; 
				
				var riseicon = isSunriseNext ? "RISE" : "SET";
				if (need_minimal) {
					riseicon = isSunriseNext ? "RI" : "SE";
				}
				return Lang.format("$1$ $2$", [riseicon, timestr]);
			}
	
		// Waiting for location.
		} else {
			return "NO LOC.";
		}
	}
	
	// Return a formatted time dictionary that respects is24Hour and HideHoursLeadingZero settings.
	// - hour: 0-23.
	// - min:  0-59.
	function getFormattedTime(hour, min) {
		var amPm = "";

		if (!Sys.getDeviceSettings().is24Hour) {

			// #6 Ensure noon is shown as PM.
			var isPm = (hour >= 12);
			if (isPm) {
				
				// But ensure noon is shown as 12, not 00.
				if (hour > 12) {
					hour = hour - 12;
				}
				amPm = "p";
			} else {
				
				// #27 Ensure midnight is shown as 12, not 00.
				if (hour == 0) {
					hour = 12;
				}
				amPm = "a";
			}
		}

		// #10 If in 12-hour mode with Hide Hours Leading Zero set, hide leading zero. Otherwise, show leading zero.
		// #69 Setting now applies to both 12- and 24-hour modes.
		hour = hour.format("%2d");

		return {
			:hour => hour,
			:min => min.format("%02d"),
			:amPm => amPm
		};
	}
}

///////////////////
// end sun stage //
///////////////////

///////////////////////
// temparature stage //
///////////////////////

class TemparatureField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		var need_minimal = App.getApp().getProperty("minimal_data");
		value = 0;
		var settings = Sys.getDeviceSettings();
		if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
			var sample = SensorHistory.getTemperatureHistory(null).next();
			if ((sample != null) && (sample.data != null)) {
				var temperature = sample.data;
				if (settings.temperatureUnits == System.UNIT_STATUTE) {
					temperature = (temperature * (9.0 / 5)) + 32; // Convert to Farenheit: ensure floating point division.
				}
				value = temperature.format("%d") + "°";
				if (need_minimal) {
					return value;
				} else {
					return Lang.format("TEMP $1$",[value]);
				}
			} else {
				if (need_minimal) {
					return "--";
				} else {
					return "TEMP --";
				}
			}
		} else {
			if (need_minimal) {
					return "--";
				} else {
					return "TEMP --";
				}
		}
	}
}

///////////////////////////
// end temparature stage //
///////////////////////////

////////////////////
// altitude stage //
////////////////////

class AltitudeField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		var need_minimal = App.getApp().getProperty("minimal_data");
		value = 0;
		// #67 Try to retrieve altitude from current activity, before falling back on elevation history.
		// Note that Activity::Info.altitude is supported by CIQ 1.x, but elevation history only on select CIQ 2.x
		// devices.
		var settings = Sys.getDeviceSettings();
		var activityInfo = Activity.getActivityInfo();
		var altitude = activityInfo.altitude;
		if ((altitude == null) && (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
			var sample = SensorHistory.getElevationHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST })
				.next();
			if ((sample != null) && (sample.data != null)) {
				altitude = sample.data;
			}
		}
		if (altitude != null) {
			var unit = "";
			// Metres (no conversion necessary).
			if (settings.elevationUnits == System.UNIT_METRIC) {
				unit = "m";
			// Feet.
			} else {
				altitude *= /* FT_PER_M */ 3.28084;
				unit = "ft";
			}
	
			value = altitude.format("%d");
			value += unit;
			if (need_minimal) {
				return value;
			} else {
				var temp = Lang.format("ALTI $1$",[value]);
				if (temp.length() > 10) {
					return Lang.format("$1$",[value]);
				}
				return temp;
			}
		} else {
			if (need_minimal) {
				return "--";
			} else {
				return "ALTI --";
			}
		}
	}
}

////////////////////////
// end altitude stage //
////////////////////////

/////////////////
// alarm stage //
/////////////////

class AlarmField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		var settings = Sys.getDeviceSettings();
		value = settings.alarmCount;
		return Lang.format("ALAR $1$",[value.format("%d")]);
	}
}

/////////////////////
// end alarm stage //
/////////////////////

////////////////////////
// notification stage //
////////////////////////

class NotifyField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		var settings = Sys.getDeviceSettings();
		value = settings.notificationCount;
		return Lang.format("NOTIF $1$",[value.format("%d")]);
	}
}

////////////////////////////
// end notification stage //
////////////////////////////

////////////////
// time stage //
////////////////

class TimeField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		return getTimeString();
	}
	
	function getTimeString() {
		var currentSettings = System.getDeviceSettings();
    	var clockTime = Sys.getClockTime();        		
    	var hour = clockTime.hour;
		var minute = clockTime.min;		
		var mark = "";
		if(!currentSettings.is24Hour) {
			if (hour>=12) {
				mark = "pm";
			} else {
				mark = "am";
			}
			hour = hour % 12;
        	hour = (hour == 0) ? 12 : hour;  
        }    
        return Lang.format("$1$:$2$ $3$",[hour, minute.format("%02d"), mark]);
    }
}

////////////////////
// end time stage //
////////////////////

////////////////
// date stage //
////////////////

class DateField extends BaseDataField {
	
	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_label(value) {
		return Application.getApp().getFormatedDate();
	}
}

////////////////////
// end date stage //
////////////////////

//////////////////
// active stage //
//////////////////

class ActiveField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function max_val() {
		var activityInfo = ActivityMonitor.getInfo();
	    return activityInfo.activeMinutesWeekGoal.toFloat();
	}
	
	function cur_val() {
		var activityInfo = ActivityMonitor.getInfo();
	    return activityInfo.activeMinutesWeek.total.toFloat();
	}
	
	function max_label(value) {
		return value.format("%d");
	}
	
	function cur_label(value) {
		return Lang.format("ACT $1$m",[value.format("%d")]);
	}
	
	function bar_data() {
		return true;
	}
}

//////////////////////
// end active stage //
//////////////////////

////////////////////
// distance stage //
////////////////////

class DistanceField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function max_val() {
	    return 300000.0;
	}
	
	function cur_val() {
		var activityInfo = ActivityMonitor.getInfo();
		var value = activityInfo.distance.toFloat();
		return value;
	}
	
	function max_label(value) {
		value = value/1000.0;
		value = value/100.0; // convert cm to km
    	var valKp = App.getApp().toKValue(value);
    	return Lang.format("$1$K",[valKp]);
	}
	
	function cur_label(value) {
		var need_minimal = App.getApp().getProperty("minimal_data");
		var settings = Sys.getDeviceSettings();
		
		var value2 = value;
		var kilo = value2/100000;
		
		var unit = "Km";
		if (settings.distanceUnits == System.UNIT_METRIC) {					
		} else {
			kilo *= 0.621371;
			unit = "Mi";
		}
		
		if (need_minimal) {
			return Lang.format("$1$ $2$",[kilo.format("%0.1f"), unit]);
		} else {
	    	var valKp = App.getApp().toKValue(kilo*1000);
	    	return Lang.format("DIS $1$$2$",[valKp, unit]);
    	}
	}
	
	function bar_data() {
		return true;
	}
}

////////////////////////
// end distance stage //
////////////////////////

////////////////////
// calories stage //
////////////////////

class CaloField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function max_val() {
	    return 3000.0;
	}
	
	function cur_val() {
		var activityInfo = ActivityMonitor.getInfo();
		return activityInfo.calories.toFloat();
	}
	
	function max_label(value) {
    	var valKp = App.getApp().toKValue(value);
    	return Lang.format("$1$K",[valKp]);
	}
	
	function cur_label(value) {
		var activeCalories = active_calories(value);
		var need_minimal = App.getApp().getProperty("minimal_data");
		if (need_minimal) {
			return Lang.format("$1$-$2$",[value.format("%d"), activeCalories.format("%d")]);
		} else {
    		var valKp = App.getApp().toKValue(value);
	    	return Lang.format("$1$K-$2$",[valKp, activeCalories.format("%d")]);
    	}
	}
	
	function active_calories(value) {
		var now = Time.now();
		var date = Date.info(now, Time.FORMAT_SHORT);
		
		var profile = UserProfile.getProfile();
		var bonus = profile.gender == UserProfile.GENDER_MALE ? 5.0 : -161.0;
		var age = (date.year-profile.birthYear).toFloat();
		var weight = profile.weight.toFloat()/1000.0;
		var height = profile.height.toFloat();
//		var bmr = 0.01*weight + 6.25*height + 5.0*age + bonus; // method 1
		var bmr = -6.1*age + 7.6*height + 12.1*weight + 9.0; // method 2
		var current_segment = (date.hour*60.0+date.min).toFloat()/1440.0;
//		var nonActiveCalories = 1.604*bmr*current_segment; // method 1
		var nonActiveCalories = 1.003*bmr*current_segment; // method 2
		var activeCalories = value - nonActiveCalories;
		activeCalories = (activeCalories>0 ? activeCalories : 0).toNumber();
		return activeCalories;
	}

	function bar_data() {
		return true;
	}
}

////////////////////////
// end calories stage //
////////////////////////

////////////////
// move stage //
////////////////

class MoveField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return ActivityMonitor.MOVE_BAR_LEVEL_MIN;
	}
	
	function max_val() {
	    return ActivityMonitor.MOVE_BAR_LEVEL_MAX;
	}
	
	function cur_val() {
		var info = ActivityMonitor.getInfo();
		var currentBar = info.moveBarLevel.toFloat();
		return currentBar.toFloat();
	}
	
	function min_label(value) {
		return value.format("%d");
	}
	
	function max_label(value) {
		return Lang.format("$1$",[(value).format("%d")]);
	}
	
	function cur_label(value) {
    	return Lang.format("MOVE $1$",[value.format("%d")]);
	}
	
	function bar_data() {
		return true;
	}
}

////////////////////
// end move stage //
////////////////////

/////////////////
// steps stage //
/////////////////

class StepField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function max_val() {
	    return ActivityMonitor.getInfo().stepGoal.toFloat();
	}
	
	function cur_val() {
		var currentStep = ActivityMonitor.getInfo().steps;
		return currentStep.toFloat();
	}
	
	function max_label(value) {
    	var valKp = App.getApp().toKValue(value);
    	return Lang.format("$1$K",[valKp]);
	}
	
	function cur_label(value) {
		var need_minimal = App.getApp().getProperty("minimal_data");
		var currentStep = value;
		if (need_minimal) {
			if (currentStep > 999) {
				return currentStep.format("%d");
			} else {
				return Lang.format("STEP $1$",[currentStep.format("%d")]);
			}
		} else {
			if (currentStep > 999) {
				var valKp = App.getApp().toKValue(currentStep);
	    		return Lang.format("STEPS $1$K",[valKp]);
			} else {
				return Lang.format("STEPS $1$",[currentStep.format("%d")]);
			}
    	}
	}

	function bar_data() {
		return true;
	}
}

/////////////////////
// end steps stage //
/////////////////////

///////////////////
// battery stage //
///////////////////

class BatteryField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 100.0;
	}
	
	function cur_val() {
		return Sys.getSystemStats().battery;
	}
	
	function min_label(value) {
		return "b";
	}
	
	function max_label(value) {
		return "P";
	}
	
	function cur_label(value) {
		var battery_format = App.getApp().getProperty("battery_format");
		if (battery_format == 0 || !(Sys.getSystemStats() has :batteryInDays)) {
			// show percent
			return Lang.format("BAT $1$%",[Math.round(value).format("%d")]);
		} else {
			var day_left = Sys.getSystemStats().batteryInDays;
			return Lang.format("$1$ DAYS",[day_left.format("%d")]);
		}
	}
	
	function bar_data() {
		return true;
	}
}

///////////////////////
// end battery stage //
///////////////////////

//////////////
// HR stage //
//////////////

class HRField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 50.0;
	}
	
	function max_val() {
	    return 120.0;
	}
	
	function cur_val() {
		var heartRate = _retrieveHeartrate();
		return heartRate.toFloat();
	}
	
	function min_label(value) {
		return value.format("%d");
	}
	
	function max_label(value) {
		return value.format("%d");
	}
	
	function cur_label(value) {
		var heartRate = value;
		if (heartRate<=1) {
			return "HR --";
		}
		return Lang.format("HR $1$",[heartRate.format("%d")]);
	}
	
	function bar_data() {
		return true;
	}
}

function doesDeviceSupportHeartrate() {
	return ActivityMonitor has :INVALID_HR_SAMPLE;
}

function _retrieveHeartrate() {
	var currentHeartrate = 0.0;
	var activityInfo = Activity.getActivityInfo();
	var sample = activityInfo.currentHeartRate;
	if (sample != null) {
		currentHeartrate = sample;
	} else if (ActivityMonitor has :getHeartRateHistory) {
		sample = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true)
			.next();
		if ((sample != null) && (sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
			currentHeartrate = sample.heartRate;
		}
	}
	return currentHeartrate.toFloat();
}

//////////////////
// end HR stage //
//////////////////

//////////////
// Recovery Time //
//////////////

class RecoveryField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}
	
	function cur_val() {
		var activityInfo = ActivityMonitor.getInfo();
		var value = activityInfo.timeToRecovery;
		return value;
	}
	
	function cur_label(value) {
		var hours = value;
		if (hours<=0) {
			return "Recovered";
		}
		return Lang.format("Rec $1$h",[hours.format("%i")]);
	}
}

//////////////////
// end Recovery Time //
//////////////////
