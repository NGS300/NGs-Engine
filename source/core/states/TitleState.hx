package core.states;

import flixel.util.FlxGradient;

class TitleState extends MusicBeatState
{
	var textGroup = new flixel.group.FlxGroup();
	var curShit:Array<String> = [];
	var blackScreen:FlxSprite;
	var titleText:FlxSprite;
	var logoSpr:FlxSprite;
	var gradDown:FlxSprite;
	var gradUp:FlxSprite;

	var startScale:Float = 0.34;
	var beatScale:Float = 0.365; // change this var to set how much the logo will bump
	var scaleTarget:Float = 0.34;
	var lastBeat:Int = 0;

	static var initialized:Bool = false; // Only play the credits once per session.

	var transitioning:Bool = false;
	var skippedIntro:Bool = false;

	override public function create()
	{
		Paths.clearMemoryCache();
		super.create();
		Paths.clearUnusedCache();
		transOut = FlxTransitionableState.defaultTransOut;
		curShit = FlxG.random.getObject(getIntroTextShit());

		if (!initialized)
		{
			persistentUpdate = persistentDraw = true;
			Settings.load(); // as a precaution
			KadeEngineData.initSave();
			FlxG.save.data.botplay = true;
		}

		// #if FREEPLAY
		// changeState(FreeplayState);
		// #elseif CHARTING
		// changeState(core.states.editors.ChartingState);
		// #else
		if (FlxG.save.data.notified == null)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			changeState(WarningState);
		}
		else
			startIntro();
		// #end
	}

	function startIntro():Void
	{
		var i = 'menus/title/';
		Conductor.changeBPM(102);
		// Conductor.bpm = 102;
		persistentUpdate = true;

		if (!initialized && FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK).screenCenter());
		gradDown = FlxGradient.createGradientFlxSprite(1880, 256, [0xFFFFFFFF, 0x00FFFFFF], 3);
		gradDown.antialiasing = Settings.data.antialiasing;
		// gradDown.setGraphicSize(1880, 256);
		gradDown.color = 0xFF680000;
		gradDown.screenCenter(X);
		gradDown.y = FlxG.height - gradDown.height;
		gradDown.y += 30;
		gradDown.flipY = true;
		gradDown.alpha = 0.5;
		add(gradDown);

		gradUp = FlxGradient.createGradientFlxSprite(1880, 256, [0x00FFFFFF, 0xFFFFFFFF], 3);
		gradUp.antialiasing = Settings.data.antialiasing;
		// gradUp.setGraphicSize(1880, 256);
		gradUp.color = 0xFFFF0000;
		gradUp.y -= 30;
		gradUp.screenCenter(X);
		gradUp.flipY = true;
		gradUp.alpha = 0.3;
		add(gradUp);

		logoSpr = new FlxSprite(250, 142);
		logoSpr.loadGraphic(Paths.image(i + 'EngineLogo')); // logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.6), Std.int(logoSpr.height * 0.6));
		logoSpr.scale.set(scaleTarget, scaleTarget);
		logoSpr.centerOrigin();

		logoSpr.screenCenter();
		// logoSpr.animation.addByPrefix('bump', 'bump0', 24, false);
		logoSpr.antialiasing = Settings.data.antialiasing;
		// logoSpr.animation.play('bump');
		logoSpr.updateHitbox();
		add(logoSpr);

		var isMobile = (Main.os.isMobile ? true : false);
		titleText = new FlxSprite((isMobile ? 60 : 122) + (flixel.math.FlxPoint.get().x / 2), 590);
		titleText.frames = Paths.atlas(i + 'title' + (!isMobile ? '_enter' : '_tap'));
		// titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByIndices("idle", "ENTER PRESSED", [1], "", 24);
		titleText.animation.addByIndices('press', "ENTER PRESSED", [0, 1], "", 24);
		titleText.antialiasing = Settings.data.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.updateHitbox();
		add(blackScreen);

		if (!initialized)
			add(textGroup);

		initialized ? skipIntro() : initialized = true;
	}

	inline function getIntroTextShit():Array<Array<String>>
		return lime.utils.Assets.getText(Paths.txt('introText')).split('\n').map(line -> line.split('--'));

	inline function introClear():Void
	{
		while (textGroup.members.length > 0 && textGroup != null)
			textGroup.remove(textGroup.members[0], true);
	}

	inline function introPush(text:String, ?off = 0.0):Void
	{
		var a = new objects.Alphabet(0, 20, text, true);
		a.screenCenter(X);
		a.y += (textGroup.length * 60) + 200 + off;
		textGroup.add(a);
	}

	inline function introSet(lines:Array<String>, ?off:Float):Void
	{
		introClear();
		for (l in lines)
			introPush(l, off);
	}

	private var sickBeats = 0;

	override function beatHit()
	{
		super.beatHit();
		scaleTarget = beatScale;

		if (skippedIntro)
			return;

		if (curBeat > lastBeat)
			for (b in lastBeat...curBeat)
				switch (++sickBeats)
				{
					case 2:
						introSet(['NGS Engine by'], 40);
					case 4:
						introPush('Hiro Sora', 40);
						introPush('KiwiSky', 40);
					case 5:
						introClear();
					case 6:
						introSet(['Not associated', 'with'], -40);
					case 8:
						introPush('Newgrounds', -40);
					case 9:
						introClear();
					case 10:
						introSet([curShit[0]]);
					case 12:
						introPush(curShit[1]);
					case 13:
						introClear();
					case 14:
						introPush('Friday');
					case 15:
						introPush('Night');
					case 16:
						introPush('Funkin');
					case 17:
						skipIntro();
				}
		lastBeat = curBeat;

		trace(curBeat);
	}

	override function update(elapsed:Float)
	{
		scaleTarget = FlxMath.lerp(scaleTarget, startScale, 0.094);
		logoSpr.scale.set(scaleTarget, scaleTarget);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressed:Bool = Settings.justPressed("ENTER") || controls.ACCEPT;
		var os = Main.os;
		if (os.isMobile)
		{
			for (t in FlxG.touches.list)
				if (t.justPressed)
					pressed = true;
		}
		else
			pressed = pressed || Settings.justPressed((os.isSwitch ? 'B' : 'START'), true);

		if (initialized && pressed)
		{
			if (!skippedIntro)
				skipIntro();
			else if (!transitioning)
			{
				FlxTween.cancelTweensOf(titleText);
				titleText.color = 0xFFFFFFFF;
				titleText?.animation.play('press');
				transitioning = true;
				FlxG.camera.flash(Settings.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				FlxTween.tween(logoSpr, {x: logoSpr.x + 1000}, 2.9, {
					ease: FlxEase.backInOut,
					type: PERSIST,
					onStart: function(twn:FlxTween)
					{
						FlxTween.tween(titleText, {y: titleText.y + 400}, 3, {
							ease: FlxEase.backInOut,
							type: PERSIST,
						});
					},
					onComplete: (_) -> changeState(MenuState)
				});
				FlxTween.tween(gradDown, {y: gradDown.y + 500}, 3.2, {
					ease: FlxEase.quartInOut,
					type: PERSIST,
					onComplete: (_) -> gradDown.destroy()
				});
				FlxTween.tween(gradUp, {y: gradUp.y - 500}, 3.2, {
					ease: FlxEase.quartInOut,
					type: PERSIST,
					onComplete: (_) -> gradUp.destroy()
				});
			}
		}
		super.update(elapsed);
	}

	private function skipIntro()
	{
		if (!skippedIntro)
		{
			introClear();
			FlxG.camera.flash(FlxColor.WHITE, initialized ? 1 : 4);
			remove(blackScreen);
			skippedIntro = true;
			logoSpr.screenCenter();
			FlxTween.angle(logoSpr, -6, 6, 2.5, {
				ease: FlxEase.quadInOut,
				type: PINGPONG,
			});
			FlxTween.color(gradDown, 2, 0xFFff0000, 0xFF680000, {
				ease: FlxEase.quadInOut,
				type: PINGPONG,
			});
			FlxTween.color(gradUp, 2, 0xFF680000, 0xFFff0000, {
				ease: FlxEase.quadInOut,
				type: PINGPONG,
			});
			FlxTween.color(titleText, 2, 0xFF33FFFF, 0xFF3333CC, {
				ease: FlxEase.linear,
				type: PINGPONG,
			});
		}
	}
}
