package core;

import core.Song.SwagSong;

typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor {
	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = calcSafeZoneOffset(safeFrames);
	public static var timeScale:Float = safeZoneOffset / 166;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	public static var bpm:Float = 100;
	public static var crochet:Float = calcCrochet(bpm);
	public static var stepCrochet:Float = crochet / 4;

	public static var songPosition:Float = 0;
	public static var lastSongPos:Float = 0;
	public static var offset:Float = 0;

	private static inline function calcSafeZoneOffset(frames:Int):Float
		return Math.floor((frames / 60) * 1000);

	private static inline function calcCrochet(bpm:Float):Float
		return (60 / bpm) * 1000;

	public static function recalculateTimings():Void {
		if (FlxG.save?.data?.frames != null)
			safeFrames = FlxG.save.data.frames;
		safeZoneOffset = calcSafeZoneOffset(safeFrames);
		timeScale = safeZoneOffset / 166;
	}

	public static function mapBPMChanges(song:SwagSong):Void {
		bpmChangeMap = [];
		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (note in song.notes) {
			if (note.changeBPM && note.bpm != curBPM) {
				curBPM = note.bpm;
				bpmChangeMap.push({
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				});
			}

			var deltaSteps:Int = note.lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += (calcCrochet(curBPM) / 4) * deltaSteps;
		}
		trace("Novo mapa de BPM: " + bpmChangeMap);
	}

	public static function newBpm(newBpm:Float, ?recalcLength = true):Void {
		bpm = newBpm;
		crochet = calcCrochet(bpm);
		stepCrochet = crochet / 4;
	}
}