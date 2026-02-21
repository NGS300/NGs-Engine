package core.states;

import flixel.effects.FlxFlicker;

class MenuState extends BeatState {
	var menuItems = new FlxTypedGroup<FlxSprite>();
	var camFollow = new flixel.FlxObject(0, 0, 1, 1);
    var mainUnder:FlxSprite;
	var mainBG:FlxSprite;
	var NORMAL_X = 625;
	var menuData = [
		{name: "story_mode", color: "FFD84C"},
		{name: "freeplay", color: "4CDFFF"},
		// {name: "mods", color: "FF9F4A"},
		{name: "options", color: "6CFF8D"},
		{name: "credits", color: "FF6BD6"}
	];
	static var curSelected = 0;
	var timeNotMoving = 0.0;
	var selectedIt = false;
	var allowMouse = true;

    override function create() {
        super.create();
		transOut = FlxTransitionableState.defaultTransOut;
		DiscordClient.changePresence('In Main Menu');
		persistentUpdate = persistentDraw = true;

		var i = 'menu/desat';
        var yScroll = 0.25;
		mainBG = new FlxSprite().loadGraphic(Paths.textures(i));
		mainBG.antialiasing = Settings.data.antialiasing;
		mainBG.scrollFactor.set(0, yScroll);
		mainBG.setGraphicSize(Std.int(mainBG.width * 1.175));
		mainBG.updateHitbox();
        mainBG.screenCenter();
		add(mainBG);
		
		mainUnder = new FlxSprite().loadGraphic(Paths.textures(i));
		mainUnder.antialiasing = Settings.data.antialiasing;
		mainUnder.scrollFactor.set(0, yScroll);
		mainUnder.setGraphicSize(Std.int(mainUnder.width * 1.175));
		mainUnder.updateHitbox();
		mainUnder.screenCenter();
		mainUnder.visible = false;
		mainUnder.color = 0xFFFFFFFF;
		add(mainUnder);

		add(camFollow);
		add(menuItems);

		for (num => data in menuData) {
			var name = data.name;
			var menuItem = new FlxSprite();
			menuItem.frames = Paths.textures('menu/_$name');
			menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
			menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
			menuItem.animation.play('idle');
			menuItem.updateHitbox();

			menuItem.y = (num * 140) + 90 + (4 - menuData.length) * 70;
			menuItem.x = FlxG.width / 2 - NORMAL_X;

			menuItem.antialiasing = Settings.data.antialiasing;
			menuItem.scrollFactor.set();
			menuItems.add(menuItem);
		}

		var engineVer = new FlxText(2, FlxG.height - 42, 0, "NG's Engine " + Core.engine.get('version'), 16);
		engineVer.setFormat(Paths.font("fredoka_One"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineVer.antialiasing = Settings.data.antialiasing;
		engineVer.scrollFactor.set();
		engineVer.borderQuality = 1;
		engineVer.borderSize = 1;
		add(engineVer);

		var fnfVer = new FlxText(2, FlxG.height - 22, 0, "Friday Night Funkin' " + Core.game.get('version'), 16);
		fnfVer.setFormat(Paths.font("fredoka_One"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fnfVer.antialiasing = Settings.data.antialiasing;
		fnfVer.scrollFactor.set();
		fnfVer.borderQuality = 1;
		fnfVer.borderSize = 1;
		add(fnfVer);
		changeMenu();
		
		FlxG.camera.follow(camFollow, null, 0.15);
    }

	override function update(elapsed:Float) {
		if (!selectedIt) {
			if (allowMouse && ((FlxG.mouse.deltaViewX != 0 || FlxG.mouse.deltaViewY != 0) || FlxG.mouse.justPressed)) { // MOUSE SUPPORT (Psych adapted)
				timeNotMoving = 0;
				FlxG.mouse.visible = true;

				var dist:Float = -1;
				var distItem:Int = -1;
				for (i in 0...menuItems.length) {
					var item = menuItems.members[i];
					if (item != null && FlxG.mouse.overlaps(item)) {
						var dx = item.getGraphicMidpoint().x - FlxG.mouse.viewX;
						var dy = item.getGraphicMidpoint().y - FlxG.mouse.viewY;
						var distance = Math.sqrt(dx * dx + dy * dy);
						if (dist < 0 || distance < dist) {
							dist = distance;
							distItem = i;
						}
					}
				}

				if (distItem != -1 && distItem != curSelected) {
					curSelected = distItem;
					changeMenu();
				}
			} else {
				timeNotMoving += elapsed;
				if (timeNotMoving >= 1.5)
					FlxG.mouse.visible = false;
			}

			if (controls.UI_UP_P)
				changeMenu(-1);
			else if (controls.UI_DOWN_P)
				changeMenu(1);

			if (controls.BACK) {
				selectedIt = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				changeState(TitleState);
			}
			
			if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse)) {
				selectedIt = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if (Settings.data.flashing)
					FlxFlicker.flicker(mainUnder, 1.1, 0.15, false);

				var selectedItem = menuItems.members[curSelected];
				FlxFlicker.flicker(selectedItem, 1, 0.06, false, false, function(_) {
					switch (menuData[curSelected].name) {
						//case 'story_mode': changeState(StoryState);
						case 'freeplay': changeState(FreeplayState);
						//case 'mods': changeState(ModsState);
						//case 'options': changeState(OptionsState);
						//case 'credits': changeState(CreditsState);
						default:
							Log.info('Menu ${menuData[curSelected].name} not implemented.');
							selectedIt = false;
					}
				});
				for (item in menuItems) {
					if (item != selectedItem)
						FlxTween.tween(item, {alpha: 0}, 0.4);
				}
			}
		}
		super.update(elapsed);
	}

	function changeMenu(change = 0) {
		curSelected = flixel.math.FlxMath.wrap(curSelected + change, 0, menuData.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'));

		final SELECTED_X = NORMAL_X - 90;
		for (item in menuItems) {
			item.animation.play('idle');
			item.centerOffsets();
			item.x = FlxG.width / 2 - NORMAL_X;
		}

		var selectedItem:FlxSprite = menuItems.members[curSelected];
		selectedItem.animation.play('selected');
		selectedItem.centerOffsets();
		var moreX:Float;
		switch (menuData[curSelected].name) {
			case 'freeplay': moreX = 16;
			case 'options': moreX = 32;
			case 'credits': moreX = 2;
			default: moreX = 0;
		}
		selectedItem.x = FlxG.width / 2 - (SELECTED_X + moreX);
		camFollow.y = selectedItem.getGraphicMidpoint().y;
		FlxTween.color(mainBG, 0.25, mainBG.color, (0xFF << 24) | Std.parseInt("0x" + menuData[curSelected].color));
	}
}