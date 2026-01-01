package util;

import DateTools;

/**
 * Utility class for date and time operations.
 */
class DateUtil {
	public static function getCurrentDate():Date
		return Date.now();

	public static function getCurrentTimestamp():Float
		return Sys.time();

	public static function getFormattedDate():String {
		var currentDate:Date = Date.now();
		return DateTools.format(currentDate, "%Y-%m-%d %H:%M:%S");
	}

	public static function getFormattedDateOnly():String {
		var currentDate:Date = Date.now();
		return DateTools.format(currentDate, "%Y-%m-%d");
	}

	public static function getFormattedTimeWithMilliseconds():String {
		var currentDate:Date = Date.now();
		var hours:String = StringTools.lpad(Std.string(currentDate.getHours()), "0", 2);
		var minutes:String = StringTools.lpad(Std.string(currentDate.getMinutes()), "0", 2);
		var seconds:String = StringTools.lpad(Std.string(currentDate.getSeconds()), "0", 2);
		var milliseconds:Int = Std.int(currentDate.getTime() % 1000);
		var millisecondsString:String = StringTools.lpad(Std.string(milliseconds), "0", 3);
		return hours + ":" + minutes + ":" + seconds + "." + millisecondsString;
	}

	public static function getFormattedTimeOnly():String {
		var currentDate:Date = Date.now();
		return DateTools.format(currentDate, "%H:%M:%S");
	}

	public static function getDayOfWeek():String {
		var currentDate:Date = Date.now();
		return DateTools.format(currentDate, "%A");
	}

	public static function getMonthName():String {
		var currentDate:Date = Date.now();
		return DateTools.format(currentDate, "%B");
	}

	public static function getDetailedDate():String {
		var currentDate:Date = Date.now();
		return "Year: " + currentDate.getFullYear() + ", Month: " + (currentDate.getMonth() + 1) + ", Day: " + currentDate.getDate() + ", Hour: "
			+ currentDate.getHours() + ", Minutes: " + currentDate.getMinutes() + ", Seconds: " + currentDate.getSeconds();
	}

	public static function getFormattedCustomDate(formatTxt = false, withMinus = false):String {
		var currentDate:Date = Date.now();
		return formatDate(currentDate, formatTxt, withMinus);
	}

	private static function formatDate(date:Date, isText:Bool, withMinus:Bool):String {
		var year:String = Std.string(date.getFullYear());
		var month:String = StringTools.lpad(Std.string(date.getMonth() + 1), "0", 2);
		var day:String = StringTools.lpad(Std.string(date.getDate()), "0", 2);
		var hours:String = StringTools.lpad(Std.string(date.getHours()), "0", 2);
		var minutes:String = StringTools.lpad(Std.string(date.getMinutes()), "0", 2);
		var seconds:String = StringTools.lpad(Std.string(date.getSeconds()), "0", 2);
		var space = " ";
		var m = "-";
		var i = ':';
		if (isText) {
			space = '_';
			i = (withMinus ? m : "'");
			return year + m + month + m + day + space + hours + i + minutes + i + seconds;
		}
		return year + m + month + m + day + space + hours + i + minutes + i + seconds;
	}

	public static function systemDate():String {
		var now = Date.now();
		var day = (if (now.getDate() < 10) "0" else "") + now.getDate();
		var month = (if (now.getMonth() + 1 < 10) "0" else "") + (now.getMonth() + 1);
		var year = now.getFullYear();
		var hours = (if (now.getHours() < 10) "0" else "") + now.getHours();
		var minutes = (if (now.getMinutes() < 10) "0" else "") + now.getMinutes();
		var seconds = (if (now.getSeconds() < 10) "0" else "") + now.getSeconds();
		return day + "/" + month + "/" + year + " - " + hours + ":" + minutes + ":" + seconds;
	}

	public static function generateTimestamp(date:Date = null):String {
		if (date == null)
			date = Date.now();
		return '${date.getFullYear()}-${Std.string(date.getMonth() + 1).lpad('0', 2)}-${Std.string(date.getDate()).lpad('0', 2)}-${Std.string(date.getHours()).lpad('0', 2)}-${Std.string(date.getMinutes()).lpad('0', 2)}-${Std.string(date.getSeconds()).lpad('0', 2)}';
	}

	public static function generateCleanTimestamp(date:Date = null):String {
		if (date == null)
			date = Date.now();
		return '${DateTools.format(date, '%B %d, %Y')} at ${DateTools.format(date, '%I:%M %p')}';
	}
}