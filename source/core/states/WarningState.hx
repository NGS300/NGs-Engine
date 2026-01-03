package core.states;

class WarningState extends BeatState {
	var texts = new FlxTypedSpriteGroup<FlxText>();
	var selector:FlxText;
	var isBouce = false;
	var isYes = true;

	override function create() {
		super.create();
		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
		texts.alpha = 0;
		add(texts);

		var warnText = new FlxText(0, 0, FlxG.width, LanguageManager.get("warning_text"));
		// warnText.text += 'This Mod contains Flashing Lights, which MAY CAUSE DISCOMFORT OR ISSUES for some players.\n';
		// warnText.text += 'To ensure a SAFER EXPERIENCE, it is recommended to disable these effects.\n';
		// warnText.text += 'Would you like to DISABLE the Flashing Lights?';
		// for (LanguageManager.getRaw("warning.warning_text"))
		warnText.setFormat(Paths.font("fredoka_One"), 22, FlxColor.WHITE, CENTER);
		warnText.antialiasing = Settings.data.antialiasing;
		warnText.y = (FlxG.height - warnText.height) / 2.4;
		warnText.updateHitbox();
		texts.add(warnText);

		final options = ["Yes", "No"];
		for (i in 0...options.length) {
			var opt = new FlxText(0, 0, FlxG.width, options[i]);
			opt.setFormat(Paths.font("fredoka_One"), 28, FlxColor.WHITE, CENTER);
			opt.antialiasing = Settings.data.antialiasing;
			opt.y = warnText.y + warnText.height + 32;
			opt.x += (160 * i) - 80;
			texts.add(opt);
		}

		selector = new FlxText(0, 0, 0, ">");
		selector.setFormat(Paths.font("fredoka_One"), 28, FlxColor.WHITE, LEFT);
		selector.antialiasing = Settings.data.antialiasing;
		selector.angle = -90;
		texts.add(selector);
		FlxTween.tween(texts, {alpha: 1}, 0.4, {
			onComplete: (_) -> updateItems()
		});
	}

	override function update(elapsed:Float) {
		var next = isYes;
		if (controls.UI_LEFT_P)
			next = true;
		else if (controls.UI_RIGHT_P)
			next = false;

		if (next != isYes) {
			isYes = next;
			FlxG.sound.play(Paths.sound("scrollMenu"), 0.7);
			updateItems();
		}

		var back = controls.BACK;
		if (controls.ACCEPT || back) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			if (!back) {
				FlxG.sound.play(Paths.sound("confirmMenu"));
				var button = texts.members[isYes ? 1 : 2];
				flixel.effects.FlxFlicker.flicker(button, 0.8, 0.1, false, true, function(_) {
					FlxTween.tween(texts, {alpha: 0}, 0.25, {
						onComplete: (_) -> save(true)
					});
				});
			} else {
				FlxG.sound.play(Paths.sound("cancelMenu"));
				FlxTween.tween(texts, {alpha: 0}, 0.4, {
					onComplete: (_) -> save(false)
				});
			}
		}
		super.update(elapsed);
	}

	function save(disable:Bool) {
		if (disable)
			Settings.data.flashing = !isYes;
		FlxG.save.data.notified = true;
		Settings.save();
		changeState(TitleState);
	}

	function updateItems() {
		var yes = texts.members[1];
		var no = texts.members[2];

		var target = isYes ? yes : no;
		var other = isYes ? no : yes;

		target.alpha = 1.0;
		other.alpha = 0.5;

		target.color = FlxColor.YELLOW;
		other.color = FlxColor.WHITE;

		selector.x = target.x + (target.width / 2) - (selector.width / 2);
		selector.y = target.y + target.height - 6;

		target.scale.set(1.1, 1.1);
		FlxTween.tween(target.scale, {x: 1, y: 1}, 0.15);
		if (!isBouce) {
			FlxTween.tween(selector, {y: selector.y + 4}, 0.6, {
				type: PINGPONG,
				ease: FlxEase.sineInOut
			});
			isBouce = true;
		}
	}
}
