package objects;

class BGSprite extends FlxSprite {
	public function new(?x:Float, ?y:Float, image:String, ?folder:String, ?scrollX:Float, ?scrollY:Float) {
		super(x ?? 0, y ?? 0);
		if (image != null)
			loadGraphic(Paths.image(image, folder));
		active = false;
		scrollFactor.set(scrollX ?? 1, scrollY ?? 1);
		antialiasing = Settings.data.antialiasing;
	}
}