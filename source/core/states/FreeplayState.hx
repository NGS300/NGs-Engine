package core.states;

import objects.SongMeta;

class FreeplayState extends BeatState {
    var grpSongs:FlxTypedGroup<Item>;
    var songs:Array<Data>;

	var diffNames:Array<String>;
	var curDifficulty:Int = 0;
    var curSelected:Int = 0;
	var songInfo = new Info();
    var metaScript:HScript;

    var scoreText:FlxText;
    var diffText:FlxText;
    var lerpScore:Int = 0;
    var intendedScore:Int = 0;

    override function create() {
        transOut = FlxTransitionableState.defaultTransOut;
        var script = new HScript('songList');
        var lists = new List();
        script.set("songs", function(name:Dynamic, ?characters:Dynamic, ?forceWeek:Int) {
            lists.add(name, characters, forceWeek);
        });
        script.call('onCreate');
        songs = lists.songs;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/desat'));
        add(bg);
        FlxTween.color(bg, 2, 0xFF2A0F4D, 0xFF3A1C71, {
            ease: FlxEase.quadInOut,
            type: PINGPONG,
        });

        grpSongs = new FlxTypedGroup<Item>();
        add(grpSongs);

        for (i in 0...songs.length) {
            var item = new Item(songs[i]);
            item.targetY = i;
            item.snapToPosition();
            grpSongs.add(item);
        }

        scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
        scoreText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, RIGHT);

        var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
        scoreBG.alpha = 0.6;
        add(scoreBG);

        diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
        diffText.font = scoreText.font;
        add(diffText);

        add(scoreText);

        changeSelection();
        changeDiff();
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.sound.music.volume < 0.7)
            FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

        lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
        if (Math.abs(lerpScore - intendedScore) <= 10)
            lerpScore = intendedScore;
        scoreText.text = "PERSONAL BEST:" + lerpScore;

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

        diffText.text = diffNames[curDifficulty].toUpperCase();
    }

    function changeSelection(change:Int = 0) {
		if (songs.length <= 0) return;
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
        loadSongMeta();

        #if !switch
        intendedScore = Highscore.getScore(songInfo.name, diffNames[curDifficulty]);
        #end

        var bullShit:Int = 0;
        for (item in grpSongs.members) {
            if (item == null) continue;

            item.targetY = bullShit - curSelected;
            bullShit++;

            item.setAlpha(0.4);
            if (item.targetY == 0)
                item.setAlpha(1);
        }
        changeDiff();
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