package objects;

class Note extends FlxSprite {
	public static var swagWidth = 160 * 0.7;
	public var isSustainNote = false;
	public var ignoreNote = false;
	public var wasGoodHit = false;
	public var mustPress = false;
	public var canBeHit = false;
	public var tooLate = false;
	public var isAlt = false;

	public var earlyHitMult = 1.0;
	public var lateHitMult = 1.0;
	public var strumTime = 0.0;
	public var noteData = 0;
	public var prevNote:Note;

	public var noteCharterObject:FlxSprite;
	public var charterSelected = false;
	public var sustainLength = 0.0;
	public var rawNoteData = 0;

	public var noteDir = ['left', 'down', 'up', 'right'];
	public var inEditor = false;
	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool, ?inEditor:Bool, ?isAlt:Bool) {
		super();

        var isPixel = false;
		setupNotes(isPixel);
		if (prevNote == null)
			prevNote = this;

		this.isAlt = isAlt ?? false;
		this.prevNote = prevNote;
		isSustainNote = sustainNote ?? false;
		this.inEditor = inEditor ?? false;

		x += 50;
		y -= 2000;
		this.strumTime = strumTime;
		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;
		x += swagWidth * noteData;
		animation.play(noteDir[noteData] + '-arrow');

		if (isSustainNote && prevNote != null) {
			alpha = 0.6;
			if (Settings.data.downScroll)
				flipY = true;

			x += width / 2;

			animation.play(noteDir[noteData] + '-end');
			updateHitbox();
			x -= width / 2;
			if (isPixel)
				x += 30;

			if (prevNote.isSustainNote) {
				prevNote.animation.play(noteDir[noteData] + '-hold');
				prevNote.updateHitbox();

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if (isPixel) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); // Auto adjust note size
				}
				prevNote.updateHitbox();
			}
			earlyHitMult = 0;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (mustPress) {
			canBeHit = (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult));

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		} else {
			canBeHit = false;
			if (!wasGoodHit && strumTime <= Conductor.songPosition) {
				if (!isSustainNote || (prevNote.wasGoodHit && !ignoreNote))
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor) {
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	function setupNotes(isPixel:Bool) {
		var basePath = 'note/skins/NOTES_';
		var animTypes = ["arrow", "hold", "end"];
		if (!isPixel) { // NORMAL NOTES
			frames = Paths.atlas(basePath + 'assets');

			var suffix = ["arrow" => " alone", "hold" => " hold", "end" => " tail"];
			for (dir in noteDir)
				for (type in animTypes)
					animation.addByPrefix('$dir-$type', dir + suffix[type]);

			setGraphicSize(Std.int(width * 0.7));
		} else { // PIXEL NOTES
			loadGraphic(Paths.image(basePath + 'pixels'), true, 17, 17);

			if (isSustainNote)
				loadGraphic(Paths.image(basePath + 'ends'), true, 7, 6);

			for (i in 0...noteDir.length) {
				var dir = noteDir[i];
				animation.add('$dir-arrow', [i + 4]); // Scroll
				animation.add('$dir-hold', [i]); // Hold
				animation.add('$dir-end', [i + 4]); // Tail
			}
			// setGraphicSize(widthSize);
		}
		updateHitbox();
		antialiasing = !isPixel && Settings.data.antialiasing;
	}
}