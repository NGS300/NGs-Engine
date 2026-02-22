package objects;

class BGSprite extends FlxSprite {
	private var idleAnim:String;
	public function new(
		image:String,
		?folder:String,
		?x:Float,
		?y:Float,
		?scrollX:Float,
		?scrollY:Float,
		?animArray:Array<String>,
		?loop:Bool
	) {
		super(x ?? 0, y ?? 0);
		scrollFactor.set(scrollX ?? 1, scrollY ?? 1);
		antialiasing = Settings.data.antialiasing;

		if (image == null) return;
		if (animArray != null && animArray.length > 0) {
			frames = Paths.atlas(image, folder);
			for (anim in animArray) {
				animation.addByPrefix(anim, anim, 24, loop ?? false);
				if (idleAnim == null)
					idleAnim = anim;
			}

			if (idleAnim != null)
				animation.play(idleAnim);
			active = true;
		} else {
			loadGraphic(Paths.image(image, folder));
			active = false;
		}
	}

	public function dance(?forcePlay = false) {
		if (idleAnim != null)
			animation.play(idleAnim, forcePlay);
	}
}