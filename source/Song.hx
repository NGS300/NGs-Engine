package;

import haxe.Json;
import lime.utils.Assets;
import Section.SwagSection;

typedef SwagSong = {
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class Song {
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	public var noteStyle:String = 'normal';
	public var stage:String = 'stage';

	public function new(song, notes, bpm) {
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static var loadedSongName:String;
	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
		trace(jsonInput);
		
		loadedSongName = folder;
		var folderLowercase = StringTools.replace(folder, " ", "-").toLowerCase();
		switch (folderLowercase) {
			case 'dad-battle': folderLowercase = 'dadbattle';
			case 'philly-nice': folderLowercase = 'philly';
		}
		trace('loading ' + folderLowercase + '/' + jsonInput.toLowerCase());

		var rawJson = Assets.getText(Paths.json(folderLowercase + '/' + jsonInput.toLowerCase())).trim();
		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return parseJSONshit(rawJson);
	}

	public static function load(input:String, ?folder:String):SwagSong {
		var normalizer = CoolUtil.normalizeName(input).toLowerCase();
		var raw = Assets.getText(Paths.json(normalizer.toLowerCase(), folder)).trim();
		while (!raw.endsWith("}"))
			raw = raw.substr(0, raw.length - 1);

		trace('loading: $folder/' + normalizer);
		return parseJSONshit(raw);
	}

	public static function parseJSONshit(raw:String):SwagSong {
		var swagShit:SwagSong = cast Json.parse(raw).song;
		swagShit.validScore = true;
		return swagShit;
	}
}