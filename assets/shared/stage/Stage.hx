function onCreate() {
    var bg = new Sprite('stageback', 'week1', -600, -200, 0.9, 0.9);
	bg.active = false;
	add(bg);
	
	var stageFront = new Sprite('stagefront', 'week1', -650, 600, 0.9, 0.9);
	stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
	stageFront.updateHitbox();
	stageFront.active = false;
	add(stageFront);
	
	var stageCurtains = new FlxSprite('stagecurtains', 'week1', -500, -300, 1.3, 1.3);
	stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
	stageCurtains.updateHitbox();
	stageCurtains.active = false;
	add(stageCurtains);
}