package core.states;

import flixel.addons.display.FlxBackdrop;
import objects.MenuItem;

using flixel.util.FlxSpriteUtil;

class StoryMenuState extends MusicBeatState
{
	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true];

	var allowedDiffs = ["normal", "hard", "erect"];
	var allowedModes = ["weeks", "diffs"];
	var weekIcons = ["gf", "dad", "spooky", "pico", "mom", "senpai"];

	var weekSelected:Bool = false;
	var curWeek:Int = 0;
	var curDiff:Int = 0;
	var curMode:Int = 0;
	var canSelectWeek:Bool = true;
	var selectedDiff:Bool = false;
	var isSelectingWeeks:Bool = true;

	var discSprite:FlxSprite;
	var tiledBG:FlxBackdrop;
	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpDiff:FlxTypedGroup<MenuItem>;

	var modeSelectorSprites:Map<String, FlxSprite>;

	var path = 'menus/storymode/';

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

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
		discSprite.x = FlxG.width - discSprite.width * 0.5 - 16;
		discSprite.y = -(discSprite.height * 0.5) + 16;
		add(discSprite);

		var polyDrawLine:LineStyle = {color: FlxColor.WHITE, thickness: 1};
		var polyRenderStyle:DrawStyle = {smoothing: true};
		var discCenter:FlxSprite = new FlxSprite();
		discCenter.makeGraphic(126, 126, FlxColor.TRANSPARENT);
		add(discCenter);

		discCenter.drawEllipse(0, 0, discCenter.width, discCenter.height, polyDrawLine, polyRenderStyle);

		discCenter.scale.set(1.5, 1.5);
		discCenter.updateHitbox();

		discCenter.centerOrigin();
		discCenter.centerOffsets();

		discCenter.screenCenter();
		discCenter.x = FlxG.width - discCenter.width * 0.5 - 16;
		discCenter.y = -(discCenter.height * 0.5) + 16;
		trace('${discCenter.x} | ${discCenter.y}');

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
			{
				item.targetY = index - curWeek;

				// Se quiser indicar bloqueado
				// if (!weekUnlocked[index])
				// item.week.color = FlxColor.GRAY;
				// else
				// item.week.color = FlxColor.WHITE;
			}

			index++;
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
		super.update(elapsed);

		tiledBG.x -= 20 * elapsed;
		discSprite.angle -= 40 * elapsed;

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
		}
	}
}
