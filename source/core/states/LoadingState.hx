package core.states;

import flixel.FlxState;

class LoadingState extends BeatState {
	inline static final MIN_TIME:Float = 1.0;
	var callbacks:MultiCallback;
	var target:Class<FlxState>;
	var stopMusic:Bool;

	public function new(target:Class<FlxState>, stopMusic:Bool) {
		super();
		this.target = target;
		this.stopMusic = stopMusic;
	}

	override function create():Void {
		super.create();
		callbacks = new MultiCallback(onLoad);
		final introDone = callbacks.add("intro");

		final song = PlayState.SONG.song;
		checkSong(Paths.inst(song), song);
		if (PlayState.SONG.needsVoices)
			checkSong(Paths.voices(song), song + "_voices");

		final fadeTime = 0.5;
		FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
		new FlxTimer().start(fadeTime + MIN_TIME, _ -> introDone());
	}

	function checkSong(sound:openfl.media.Sound, id:String):Void {
		if (sound == null) return;
		final done = callbacks.add('song:$id');
		done();
	}

	function onLoad():Void {
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		FlxG.switchState(() -> Type.createInstance(target, []));
	}

	inline static public function loadAndSwitchState(target:Class<FlxState>, stopMusic:Bool = false):Void {
		FlxG.switchState(() -> {
			final song = PlayState.SONG.song;

			final inst = Paths.inst(song);
			final voices = PlayState.SONG.needsVoices ? Paths.voices(song) : null;

			final loaded = inst != null && (!PlayState.SONG.needsVoices || voices != null);
			if (!loaded)
				return new LoadingState(target, stopMusic);

			if (stopMusic && FlxG.sound.music != null)
				FlxG.sound.music.stop();

			return Type.createInstance(target, []);
		});
	}

	override function destroy():Void {
		super.destroy();
		callbacks = null;
	}
}

class MultiCallback {
	public var remaining(default, null):Int = 0;
	public var length(default, null):Int = 0;

	var pending:Map<String, Bool> = [];
	var fired:Array<String> = [];
	var callback:Void->Void;

	public function new(callback:Void->Void)
		this.callback = callback;

	public function add(id:String):Void->Void {
		final key = '${length++}:$id';
		pending.set(key, true);
		remaining++;
		return () -> {
			if (!pending.exists(key))
				return;

			pending.remove(key);
			fired.push(key);
			remaining--;
			if (remaining == 0)
				callback();
		};
	}

	public inline function getFired():Array<String>
		return fired.copy();

	public function getUnfired():Array<String> {
		final arr:Array<String> = [];
		for (k in pending.keys())
			arr.push(k);
		return arr;
	}
}