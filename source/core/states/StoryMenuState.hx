package core.states;

import flixel.addons.display.FlxBackdrop;
import objects.MenuItem;

using flixel.util.FlxSpriteUtil;

class StoryMenuState extends MusicBeatState
{
	public static var weekUnlocked:Array<Bool> = [false, false, true, true, true, true, true];

	var allowedDiffs:Array<String> = ["normal", "hard", "erect"];
	var allowedModes:Array<String> = ["weeks", "diffs"];
	var weekIcons:Array<String> = ["gf", "dad", "spooky", "pico", "mom", "parents-christmas", "senpai"];
	var weekColors:Array<Int> = [
		0xFFA5004D,
		0xFFAF66CE,
		0xFFD57E00,
		0xFFB7D855,
		0xFFD8558E,
		0xFF9E3188,
		0xFFFFAA6F
	];

	var weekSelected:Bool = false;
	var curWeek:Int = 0;
	var curDiff:Int = 0;
	var curMode:Int = 0;
	var canSelectWeek:Bool = true;
	var selectedDiff:Bool = false;
	var isSelectingWeeks:Bool = true;
	var currentColor:Int;
	var lockAngle:Float = 0;
	var lockAngleTarget:Float = 0;
	var lockSize:Float = 1;
	var beats:Int = 0;

	var discCenter:FlxSprite;
	var discSprite:FlxSprite;
	var tiledBG:FlxBackdrop;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpLock:FlxTypedGroup<FlxSprite>;
	var grpDiff:FlxTypedGroup<MenuItem>;
	var icon:HealthIcon;

	var modeSelectorSprites:Map<String, FlxSprite>;

	var path = 'menus/storymode/';

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		Conductor.changeBPM(102);

		persistentUpdate = true;
		persistentDraw = true;

		if (FlxG.sound.music != null)
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

		tiledBG = new FlxBackdrop(Paths.image(path + "storybg"));
		tiledBG.scale.set(tiledBG.graphic.width / FlxG.width, tiledBG.graphic.height / FlxG.height);
		add(tiledBG);

		modeSelectorSprites = new Map<String, FlxSprite>();

		var blackCut:FlxSprite = new FlxSprite();
		blackCut.loadGraphic(Paths.image(path + "story_black"));

		var leftSpr:FlxSprite = new FlxSprite();
		leftSpr.loadGraphic(Paths.image(path + "story_black_border_left"));
		leftSpr.visible = false;
		modeSelectorSprites.set("weeks", leftSpr);

		var rightSpr:FlxSprite = new FlxSprite();
		rightSpr.loadGraphic(Paths.image(path + "story_black_border_right"));
		rightSpr.visible = false;
		modeSelectorSprites.set("diffs", rightSpr);

		add(leftSpr);
		add(rightSpr);
		add(blackCut);

		discSprite = new FlxSprite();
		discSprite.frames = Paths.atlas(path + "disc_storymod");

		discSprite.animation.addByPrefix("idle", "disc", 24, true);
		discSprite.animation.play("idle");

		discSprite.scale.set(2, 2);
		discSprite.updateHitbox();

		discSprite.centerOrigin();
		discSprite.centerOffsets();

		discSprite.screenCenter();
		discSprite.x = FlxG.width - discSprite.width * 0.5 - 64;
		discSprite.y = -(discSprite.height * 0.5) + 64;
		add(discSprite);

		var polyDrawLine:LineStyle = {color: FlxColor.WHITE, thickness: 1};
		var polyRenderStyle:DrawStyle = {smoothing: true};
		discCenter = new FlxSprite();
		discCenter.makeGraphic(126, 126, FlxColor.TRANSPARENT);
		add(discCenter);
		discCenter.drawEllipse(0, 0, discCenter.width, discCenter.height, polyDrawLine, polyRenderStyle);
		discCenter.scale.set(1.5, 1.5);
		discCenter.updateHitbox();
		discCenter.centerOrigin();
		discCenter.centerOffsets();
		discCenter.screenCenter();
		discCenter.x = FlxG.width - discCenter.width * 0.5 - 64;
		discCenter.y = -(discCenter.height * 0.5) + 64;
		discCenter.color = weekColors[curWeek];
		currentColor = discCenter.color;

		var sprTracker:FlxSprite = new FlxSprite(discCenter.x, discCenter.y);
		sprTracker.makeGraphic(32, 32, FlxColor.RED);
		sprTracker.updateHitbox();
		sprTracker.x = FlxG.width - discCenter.width + 8;
		sprTracker.y = 16;
		sprTracker.visible = false;

		add(sprTracker);

		var sprGlow:FlxSprite = new FlxSprite();
		sprGlow.loadGraphic(Paths.image("effects/light"));
		sprGlow.scale.set(1.8, 1.8);
		sprGlow.updateHitbox();
		sprGlow.centerOrigin();
		sprGlow.centerOffsets();
		sprGlow.color = 0xFF000000;
		sprGlow.x = FlxG.width - discCenter.width + 8;
		sprGlow.y = -64;

		add(sprGlow);

		icon = new HealthIcon(weekIcons[curWeek]);
		icon.sprTracker = sprTracker;
		add(icon);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		for (i in 0...weekUnlocked.length)
		{
			var weekThing:MenuItem = new MenuItem(150, 200, i);
			// weekThing.angleX = 160;
			weekThing.angleY = 62;
			weekThing.startX += 200;
			weekThing.startY -= 180;
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.alphaMultiplier = 0.25;
			weekThing.scaleMultiplier = 0.17;
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
		}

		grpDiff = new FlxTypedGroup<MenuItem>();
		add(grpDiff);

		for (i in 0...allowedDiffs.length)
		{
			var diffThing:MenuItem = new MenuItem(FlxG.width * 0.5, FlxG.height * 0.5, "", false);
			diffThing.loadSprite(path + "difficulties/" + allowedDiffs[i]);
			diffThing.angleY = 62;
			diffThing.startX -= 100;
			diffThing.startY += 650;
			diffThing.y += ((diffThing.height + 30) * i);
			diffThing.alphaMultiplier = 0.5;
			diffThing.scaleMultiplier = 0.14;
			diffThing.targetY = i;
			grpDiff.add(diffThing);
		}

		grpLock = new FlxTypedGroup<FlxSprite>();
		add(grpLock);

		for (i in 0...weekUnlocked.length)
		{
			var lockSpr:FlxSprite = new FlxSprite();
			lockSpr.loadGraphic(Paths.image(path + "lock_new"));
			lockSpr.updateHitbox();
			lockSpr.scale.set(1.2, 1.2);
			lockSpr.ID = i;
			grpLock.add(lockSpr);

			if (weekUnlocked[i])
				lockSpr.visible = false;
		}

		modeSelectorSprites[allowedModes[curMode]].visible = true;

		super.create();
	}

	function changeDiff(change:Int = 0):Void
	{
		curDiff += change;

		if (curDiff >= allowedDiffs.length)
			curDiff = 0;

		if (curDiff < 0)
			curDiff = allowedDiffs.length - 1;

		var idx:Int = 0;

		for (item in grpDiff.members)
		{
			if (item != null)
				item.targetY = idx - curDiff;
			idx++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekUnlocked.length)
			curWeek = 0;

		if (curWeek < 0)
			curWeek = weekUnlocked.length - 1;

		var index:Int = 0;

		for (item in grpWeekText.members)
		{
			if (item != null)
				item.targetY = index - curWeek;

			index++;
		}

		icon.animation.play(weekIcons[curWeek]);
		discCenter.color = weekColors[curWeek];

		var newColor:Int = weekColors[curWeek];
		if (newColor != currentColor)
		{
			FlxTween.cancelTweensOf(discCenter);
			FlxTween.color(discCenter, 1.3, currentColor, newColor);
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function switchMode(mode:Int)
	{
		curMode += mode;

		if (curMode >= allowedModes.length)
			curMode = 0;

		if (curMode < 0)
			curMode = allowedModes.length - 1;

		for (mode => sprites in modeSelectorSprites)
			sprites.visible = false;

		modeSelectorSprites[allowedModes[curMode]].visible = true;

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function selectWeek()
	{
		if (!weekUnlocked[curWeek])
			return;

		FlxG.sound.play(Paths.sound('confirmMenu'));
		grpWeekText.members[curWeek].startFlashing();
		canSelectWeek = false;

		// escreva aqui a logica para selecionar a week kkkk
	}

	override function update(elapsed:Float)
	{
		tiledBG.x -= 20 * elapsed;
		discSprite.angle -= 40 * elapsed;
		icon.angle = discSprite.angle;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		for (i in 0...grpLock.members.length)
		{
			// lock.angle = FlxMath.lerp(lock.angle, lockAngle, 0.085);
			var lock:FlxSprite = grpLock.members[i];
			var item:MenuItem = grpWeekText.members[lock.ID];

			lock.x = item.x + item.week.width + 8;
			lock.y = item.y;
			lock.alpha = item.alpha;
			lockSize = FlxMath.lerp(lockSize, 1.2, 0.075);
			lock.scale.set(lockSize, lockSize);
			lock.angle = FlxMath.lerp(lock.angle, lockAngle, 0.075);
		}

		if (!weekSelected && canSelectWeek)
		{
			if (controls.UI_UP_P && allowedModes[curMode] == "weeks")
				changeWeek(-1);
			else if (controls.UI_DOWN_P && allowedModes[curMode] == "weeks")
				changeWeek(1);

			if (controls.UI_UP_P && allowedModes[curMode] == "diffs")
				changeDiff(-1);
			else if (controls.UI_DOWN_P && allowedModes[curMode] == "diffs")
				changeDiff(1);

			if (controls.UI_RIGHT_P)
				switchMode(-1);
			else if (controls.UI_LEFT_P)
				switchMode(1);

			if (controls.ACCEPT)
				selectWeek();
		}

		if (controls.BACK && canSelectWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			canSelectWeek = false;
			changeState(core.states.MenuState);
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		beats++;

		if (beats % 1 == 0)
		{
			lockAngle = -12;
			lockSize = 1.4;
		}
		if (beats % 2 == 0)
		{
			lockAngle = 12;
			lockSize = 1.5;
		}
	}
}
