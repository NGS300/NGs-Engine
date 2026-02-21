package core;

import core.Section.SwagSection;
import haxe.Json;
import util.SongUtil;
import lime.utils.Assets;

class Event {
	public var name:String;
	public var position:Float;
	public var value:Float;
	public var type:String;
	public function new(name:String, pos:Float, value:Float, type:String) {
		this.name = name;
		this.position = pos;
		this.value = value;
		this.type = type;
	}
}

typedef SwagSong = {
	var notes:Array<SwagSection>;
	var events:Array<Event>;
	var chartVersion:String;
	var stage:String;
	var song:String;
	var noteStyle:String;
	var bpm:Float;
	var speed:Float;
	var players:Array<String>;
	var validThing:Array<Bool>;
}

/**
 * Song Datas
 */
class Song {
	var notes:Array<SwagSection>;
	public var event:Array<Event>;
	public var chartVersion:String;
	public var noteStyle = 'normal';
	public var stage = '';
	public var song:String;
	public var bpm:Float;
	public var speed = 1.0;
	public var players = ['', 'bf', 'dad'];

	public function new(song, notes, bpm) {
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJsonRAW(rawJson:String) {
		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);
		return parseJSONshit(rawJson);
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
		var folderLower = SongUtil.normalizePathName(folder);
		trace('loading ' + folderLower + '/' + jsonInput.toLowerCase());

		var rawJson = Assets.getText(Paths.json(folderLower + '/' + jsonInput.toLowerCase())).trim();
		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return parseJSONshit(rawJson);
	}

	public static function conversionChecks(song:SwagSong):SwagSong {
		var ba = song.bpm;
		var index = 0;
		trace("conversion stuff " + song.song + " " + song.notes.length);
		var convertedStuff:Array<Event> = [];
		if (song.events == null)
			song.events = [new Event("Init BPM", 0, song.bpm, "BPM Change")];

		for (i in song.events) {
			var name = Reflect.field(i, "name");
			var type = Reflect.field(i, "type");
			var pos = Reflect.field(i, "position");
			var value = Reflect.field(i, "value");
			convertedStuff.push(new Event(name, pos, value, type));
		}
		song.events = convertedStuff;

		for (i in song.notes) {
			var currentBeat = 4 * index;
			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);
			if (currentSeg == null)
				continue;

			var beat:Float = currentSeg.startBeat + (currentBeat - currentSeg.startBeat);
			if (i.changeBPM && i.bpm != ba) {
				trace("converting changebpm for section " + index);
				ba = i.bpm;
				song.events.push(new Event("FNF BPM Change " + index, beat, i.bpm, "BPM Change"));
			}

			for (ii in i.sectionNotes) {
				if (ii[3] == null)
					ii[3] = false;
			}
			index++;
		}
		return song;
	}

	public static function parseJSONshit(rawJson:String):SwagSong {
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validThing[1] = true;

		for (section in swagShit.notes) { // conversion stuff
			if (section.altAnim)
				section.isP1Alt = section.altAnim;
		}
		return swagShit;
	}
}