package core.states;

import objects.SongMeta;

class FreeplayState extends BeatState {
    var grpSongs:FlxTypedGroup<Item>;
    var songs:Array<Data>;

    static var curSelected:Int = 0;
	var diffNames:Array<String>;
	var curDifficulty:Int = 0;
	var songInfo = new Info();
    var metaScript:HScript;

    var idleOscillating:Bool = false;
    var idleDelay:Float = 2.7;
    var idleTimer:Float = 0;
    var intendedColor:Int;
    var bg:BGSprite;

    var intendedScore:Int = 0;
    //var lerpScore:Int = 0;

    override function create() {
        transOut = FlxTransitionableState.defaultTransOut;
        var script = new HScript('songList');
        var lists = new List();
        script.set("songs", function(name:Dynamic, ?characters:Dynamic, ?forceWeek:Int) {
            lists.add(name, characters, forceWeek);
        });
        script.call('onCreate');
        songs = lists.songs;

        bg = new BGSprite(0, 0, 'menus/freeplay/desat');
        bg.screenCenter();
        add(bg);

        grpSongs = new FlxTypedGroup<Item>();
        add(grpSongs);

        for (i in 0...songs.length) {
            var item = new Item(songs[i]);
            item.targetY = i;
            item.snapToPosition();
            grpSongs.add(item);
        }

        if (curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

        changeSelection();
        changeDiff();
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.sound.music.volume < 0.7)
            FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
        
        if (songs.length > 0) {
            idleTimer += elapsed;
            if (!idleOscillating && idleTimer >= idleDelay)
                startOscillation();
        }

        if (controls.ACCEPT && songInfo.name != null && songInfo.name.length > 0) {
            var input = CoolUtil.normalizeName(songs[curSelected].song).toLowerCase();
            PlayState.SONG = Song.load('charts/' + diffNames[curDifficulty], 'songs/' + input);
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = curDifficulty;
            PlayState.storyWeek = songs[curSelected].week;

			PlayState.song.isStory = false;
            PlayState.difficulty.name = diffNames[curDifficulty];
            PlayState.difficulty.index = curDifficulty;

			PlayState.song.stage = songInfo.stage;
            PlayState.song.version = songInfo.version;
            PlayState.song.name = songInfo.name;
            PlayState.song.artist = songInfo.artist;
            PlayState.song.charter = songInfo.charter;
			PlayState.song.characters = songInfo.characters;


            trace('song dir: ' + Song.load('charts/' + diffNames[curDifficulty], 'songs/' + input));
            LoadingState.loadAndSwitchState(PlayState);
            return;
        }

        if (controls.BACK) {
            changeState(MenuState);
            return;
        }

		if (songs.length <= 0 || songInfo.name == null || songInfo.name.length <= 0) 
			return
		else {
			if (controls.UI_UP_P)
				changeSelection(-1);
			else if (controls.UI_DOWN_P)
				changeSelection(1);
			else if (controls.UI_LEFT_P)
				changeDiff(-1);
			else if (controls.UI_RIGHT_P)
				changeDiff(1);
		}
    }

    function changeDiff(change:Int = 0) {
		if (songs.length <= 0) return;
        curDifficulty = FlxMath.wrap(curDifficulty + change, 0, diffNames.length - 1);
        updateMeta();

        #if !switch
        intendedScore = Highscore.getScore(songInfo.name, diffNames[curDifficulty]);
        #end

        var selectedItem:Item = cast grpSongs.members[curSelected]; 
        if (selectedItem != null) {
            selectedItem.diffText.alpha = 1;
            selectedItem.diffText.text = '<' + diffNames[curDifficulty].toUpperCase() + '>';
        }

        for (i in 0...grpSongs.members.length) {
            if (i == curSelected) continue;
            var item:Item = cast grpSongs.members[i];
            if (item != null)
                item.diffText.alpha = 0;
        }
    }

    function changeSelection(change:Int = 0) {
		if (songs.length <= 0) return;
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
        var newColor:Int = songs[curSelected].color;

        idleTimer = 0;
        idleOscillating = false;
        if (colorTween != null) {
            colorTween.cancel();
            colorTween = null;
        }
        
        if (newColor != intendedColor) {
            intendedColor = newColor;
            FlxTween.cancelTweensOf(bg);
            FlxTween.color(bg, 1, bg.color, intendedColor);
        }
        loadSongMeta();

        #if !switch
        intendedScore = Highscore.getScore(songInfo.name, diffNames[curDifficulty]);
        #end

        var bullShit:Int = 0;
        for (item in grpSongs.members) {
            if (item == null) continue;

            item.targetY = bullShit - curSelected;
            bullShit++;

            item.setAlpha(0.6);
            if (item.targetY == 0)
                item.setAlpha(1);
        }
        changeDiff();
    }
    var colorTween:FlxTween;

    function startOscillation():Void {
        idleOscillating = true;

        var base:FlxColor = intendedColor;
        var lighter:FlxColor = FlxColor.fromRGB(
            Std.int(Math.min(base.red + 20, 255)),
            Std.int(Math.min(base.green + 20, 255)),
            Std.int(Math.min(base.blue + 20, 255))
        );

        if (colorTween != null)
            colorTween.cancel();

        colorTween = FlxTween.color(bg, 2, intendedColor, lighter, {
            ease: FlxEase.quadInOut,
            type: PINGPONG
        });
    }

    function prepareMetaScript():Bool {
        if (songs.length <= 0) return false;

        var rawName = songs[curSelected].song;
        var folder = CoolUtil.normalizeName(rawName).toLowerCase();

        var metaPath = 'data/metadata';
        if (!sys.FileSystem.exists(Paths.hxs(metaPath, 'songs/$folder', false)))
            return false;

        metaScript = new HScript(metaPath, 'songs/$folder', false);
        return true;
    }

	function loadSongMeta():Void {
		var hasScript = prepareMetaScript();
		if (hasScript) {
			metaScript.set("difficulties", ["unknown"]);
			metaScript.set("song", { name: 'unknown' });
			metaScript.call('onCreateMeta');
		}

		var diff:Array<String> = metaScript.getStringArray("difficulties", -1);
		if (!hasScript) {
			diffNames = ["unknown"];
			curDifficulty = 0;
		} else {
			var validDiffs:Array<String> = [];
			for (d in diff) {
				if (d != null && d.length > 0 && d.toLowerCase() != "unknown")
					validDiffs.push(d);
			}
			diffNames = (validDiffs.length > 0) ? validDiffs : ["normal"];

			if (validDiffs.length == 0)
				curDifficulty = 0;
			else {
				if (curDifficulty >= diffNames.length)
					curDifficulty = 0;
			}
		}

		var metaName = metaScript.getString("song.name");
		if (metaName != null && metaName.length > 0 && metaName.toLowerCase() != "unknown")
			songInfo.name = metaName;
		else {
			var raw = CoolUtil.normalizeName(songs[curSelected].song, false);
			var parts = raw.split(" ");
			for (i in 0...parts.length) {
				var p = parts[i];
				if (p.length > 0)
					parts[i] = p.charAt(0).toUpperCase() + p.substr(1);
			}
			songInfo.name = parts.join(" ");
		}
		updateMeta();
	}

    function updateMeta():Void {
        if (metaScript == null) return;

        metaScript.set("diff", diffNames[curDifficulty]);
		metaScript.set("stage", 'stage');
		metaScript.set("song", {
            artist: "unknown",
            charter: "unknown",
            version: "v0.0.0.0"
        });

		metaScript.set("character", {
            gf: "gf",
            dad: "dad",
            bf: "bf"
        });
        metaScript.call("onUpdateMeta");

		songInfo.stage  = metaScript.getString("stage");
		songInfo.artist = metaScript.getString("song.artist");
		songInfo.charter  = metaScript.getString("song.charter");
		songInfo.version = metaScript.getString('song.version');

		songInfo.characters.set('gf', metaScript.getString('character.gf'));
		songInfo.characters.set('dad', metaScript.getString('character.dad'));
		songInfo.characters.set('bf', metaScript.getString('character.bf'));
    }
}