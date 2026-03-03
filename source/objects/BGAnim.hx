package objects;

class BGAnim extends FlxSprite {
	public var canLoopIdle:Bool = false;
	var autoLoop:Bool = false;

	var danceDir:Bool = false;
	var firtDance:Bool = true;

	public function new(?x:Float, ?y:Float, image:String, ?folder:String, ?scrollX:Float, ?scrollY:Float) {
		super(x ?? 0, y ?? 0);
		frames = Paths.atlas(image, folder);
		active = true;
		scrollFactor.set(scrollX ?? 1, scrollY ?? 1);
		antialiasing = Settings.data.antialiasing;
	}

	public function play(name:String, ?force:Bool):Void
		animation.play(name, force ?? false);

	public function prefix(name:String, prefix:String, ?loop:Bool):Void
		animation.addByPrefix(name, prefix, 24, loop ?? false);

	public function indices(name:String, prefix:String, indices:Array<Int>, ?loop:Bool):Void
		animation.addByIndices(name, prefix, indices, "", 24, loop ?? false);

	public function dance():Void {
		autoLoop = false;
		if (animation.exists('danceLeft') && animation.exists('danceRight')) {
			if (firtDance) {
				animation.play('danceLeft', true);
				firtDance = false;
			} else {
				danceDir = !danceDir;
				if (danceDir)
					animation.play('danceRight', true);
				else
					animation.play('danceLeft', true);
			}

		}  else if (animation.exists('idle')) {
			animation.play('idle');

			var anim = animation.curAnim;
			if (canLoopIdle && anim != null && anim.name == 'idle' && anim.looped)
				autoLoop = true;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (!canLoopIdle || !autoLoop)
			return;

		var anim = animation.curAnim;
		if (anim == null)
			return;

		if (anim.name == 'idle' && anim.finished)
			animation.play('idle', true);
	}
}