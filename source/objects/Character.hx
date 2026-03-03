package objects;

import core.HScript;

class Character extends CharSprite {
    public var cameraPosition:Array<Float> = [0, 0];
    public var positionArray:Array<Float> = [0, 0];
    public var stunned:Bool = false;
    var script:HScript;
    public function new(?x:Float, ?y:Float, ?char:String, ?isPlayer:Bool) {
        super(x ?? 0, y ?? 0, char, isPlayer);
        change(char);
    }

    public function change(char:String) {
        offsets = [];
        curCharacter = char;
        script = new HScript('characters/$char');
        script.canObjects = false;
        script.set("loadAtlas", loadAtlas);

        script.set("animPrefix", newPrefix);
        script.set("animIndices", newIndices);
        script.set("setOffset", newOffset);
        script.set("play", playAnim);

        script.set("flipX", false);
        script.set("flipY", false);
        script.set("width", width);
        script.set("height", height);
        script.set("scale", { set: [0, 0], x: 0, y: 0 });
        script.set("size", setSize);
        script.set("graphicSize", setGraphicSize);
        script.set("updateBox", updateHitbox);

        script.set("canDancedSing", singDanced);
        script.set("singTimer", singDuration);
        script.set("pos", { set: [0, 0], cam: [0, 0] });
        script.call("onCharacter");

        positionArray = script.getFloatArray("pos.set");
        cameraPosition  = script.getFloatArray("pos.cam");

        var FLIPX = script.get("flipX") ?? null;
        flipX = (FLIPX is Bool) ? FLIPX : false;

        var FLIPY = script.get("flipY") ?? null;
        flipY = (FLIPY is Bool) ? FLIPY : false;
        
        var raw:Null<Bool> = cast script.get("antialiasing") ?? null;
        antialiasing = (raw != null ? raw : (core.backend.Stage.isPixel ? false : Settings.data.antialiasing));

        singDanced = script.getBool("canDancedSing") ?? false;

        skipDance = false;
        recalcDance();
		dance();
    }

    public function play(name:String, ?force:Bool)
        playAnim(name, force);
}