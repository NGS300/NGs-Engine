package objects;

import core.HScript;

class Character extends CharSprite {
    public var cameraPosition:Array<Float> = [0, 0];
    public var positionArray:Array<Float> = [0, 0];
    public var stunned:Bool = false;
    var script:HScript;
    public function new(?x:Float, ?y:Float, ?char:String, ?isPlayer:Bool) {
        super(x ?? 0, y ?? 0, char, isPlayer);
        change(char ?? 'bf');
    }

    public function change(char:String) {
        offsets = [];
        curCharacter = char;
        script = new HScript('characters/$char');
        script.canObjects = false;
        script.set('loadAtlas', loadAtlas);

        script.set('animPrefix', newPrefix);
        script.set('animIndices', newIndices);
        script.set('setOffset', newOffset);
        script.set('play', playAnim);

        script.set('flipY', flipY);
        script.set('width', width);
        script.set('height', height);
        script.set('scale', scale);
        script.set('size', setSize);
        script.set('graphicSize', setGraphicSize);
        script.set('updateBox', updateHitbox);

        script.set('singTimer', singDuration);
        script.set("pos", { set: [0, 0], cam: [0, 0] });
        script.call('onNew');

        positionArray = script.getFloatArray("pos.set");
        cameraPosition  = script.getFloatArray("pos.cam");

        var flip = script.get('flipX') ?? null;
        flipX = (flip is Bool) ? flip : false;
        
        var raw:Null<Bool> = cast script.get("antialiasing") ?? null;
        antialiasing = (raw != null ? raw : (Stage.isPixel ? false : Settings.data.antialiasing));

        skipDance = false;
        recalcDance();
		dance();
    }

    public function play(name:String, ?force:Bool)
        playAnim(name, force);
}