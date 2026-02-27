package;

import util.SaveUtil;

class Highscore {
	public static var freeplayScores = new Map<String, Int>();
	public static var weekScores = new Map<String, Int>();
	static var setFreeplayScore = Scores.setFreeplayScore;
	static var setWeekScore = Scores.setWeekScore;

	public static function getScore(song:String, diffName:String):Int {
		var key = formatSong(song, diffName);
		if (!freeplayScores.exists(key))
			setFreeplayScore(key, 0);

		return freeplayScores.get(key);
	}

	public static function saveScore(song:String, score:Int, diffName:String):Void {
		var key = formatSong(song, diffName);
		if (!FlxG.save.data.botplay) {
			if (freeplayScores.exists(key)) {
				if (freeplayScores.get(key) < score)
					setFreeplayScore(key, score);
			} else
				setFreeplayScore(key, score);
		}
	}

	public static function getWeekScore(week:Int, diffName:String):Int {
		var key = formatSong('Week' + week, diffName);
		if (!weekScores.exists(key))
			setWeekScore(key, 0);

		return weekScores.get(key);
	}

	public static function saveWeekScore(week:Int, score:Int, diffName:String):Void {
		var key = formatSong('Week' + week, diffName);
		if (!FlxG.save.data.botplay) {
			if (weekScores.exists(key)) {
				if (weekScores.get(key) < score)
					setWeekScore(key, score);
			} else
				setWeekScore(key, score);
		}
	}

	public static function formatSong(song:String, diffName:String):String {
		if (diffName == null || diffName.length == 0)
			return song;
		return song + '-' + diffName.toLowerCase();
	}

	public static function load():Void {
		if (FlxG.save.data.freeplayScores != null)
			freeplayScores = FlxG.save.data.freeplayScores;

		if (FlxG.save.data.weekScores != null)
			weekScores = FlxG.save.data.weekScores;
	}
}