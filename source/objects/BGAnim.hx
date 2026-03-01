package objects;

class BGAnim extends FlxSprite {
	var idleAnim:String;

	public function new(?x:Float, ?y:Float, image:String, ?folder:String, ?animArray:Array<String>, ?loop:Bool, ?scrollX:Float, ?scrollY:Float) {
		super(x ?? 0, y ?? 0);
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
		}
		scrollFactor.set(scrollX ?? 1, scrollY ?? 1);
		antialiasing = Settings.data.antialiasing;
	}

	public function play(name:String, ?force:Bool)
		animation.play(name, force ?? false);

	public function dance(?force:Bool) {
		if (idleAnim != null)
			animation.play(idleAnim, force ?? false);
	}
}