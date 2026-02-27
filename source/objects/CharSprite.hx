package objects;

class CharSprite extends FlxSprite {
    public var offsets:Map<String, Array<Dynamic>>;
    public var specialAnim:Bool = false;
    public var skipDance:Bool = false;
    public var isPlayer:Bool = false;
    public var curCharacter:String;
    public var suffix:String = '';
    var danceIdle:Bool = false;
    var danced:Bool = false;

    public var singDuration:Float = 4;
	public var holdTimer:Float = 0;

    public var debugMode:Bool = false;
    var _lastAnim:String;
    public function new(x:Float, y:Float, ?char:String, ?isPlayer:Bool) {
        super(x, y);
        offsets = new Map<String, Array<Dynamic>>();
        this.isPlayer = isPlayer ?? false;
    }

    public function playAnim(name:String, ?force:Bool, ?reversed:Bool, ?frame:Int):Void {
		animation.play(name, force ?? false, reversed ?? false, frame ?? 0);
        _lastAnim = name;

		if (hasAnim(name)) {
            var id = offsets.get(name);
			offset.set(id[0], id[1]);
        }

        if (curCharacter.startsWith('gf-') || curCharacter == 'gf') {
            if (name.startsWith('sing')) {
                switch (name.substr(4)) {
                    case 'LEFT':  danced = true;
                    case 'RIGHT': danced = false;
                    case 'UP', 'DOWN': danced = !danced;
                }
            }
        }
	}

    override function update(elapsed:Float) {

        /*if (specialAnim && isFinished()) {
			specialAnim = false;
			dance();
		} else if (getAnim().endsWith('miss') && isFinished()) {
			dance();
			finishAnimation();
		}*/

        if (getAnim().startsWith('sing'))
			holdTimer += elapsed;
		else if (isPlayer)
			holdTimer = 0;

        if (getAnim().endsWith('miss') && isFinished() && !debugMode)
			playAnim('idle', true, false, 10);

        if (isPlayer) {
		    if (getAnim() == 'firstDeath' && isFinished())
			    playAnim('deathLoop');
        } else if (!isPlayer) {
            if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration) {
                dance();
                holdTimer = 0;
            }
        }
        super.update(elapsed);
    }

    public function loadAtlas(file:String, ?folder:String)
        frames = Paths.atlas('characters/$file');

    public function newPrefix(name:String, prefix:String, ?frame:Float, ?loop:Bool, ?flipX:Bool, ?flipY:Bool) {
        animation.addByPrefix(name, prefix, frame ?? 24, loop ?? false, flipX ?? false, flipY ?? false);
        newOffset(name);
    }

    public function newIndices(name:String, prefix:String, indices:Array<Int>, ?frame:Float, ?loop:Bool, ?flipX:Bool, ?flipY:Bool) {
        animation.addByIndices(name, prefix, indices, "", frame ?? 24, loop ?? false, flipX ?? false, flipY ?? false);
        newOffset(name);
    }

    inline public function isNull():Bool
		return animation.curAnim == null;//!isAnimateAtlas ? (animation.curAnim == null) : (atlas.anim.curInstance == null || atlas.anim.curSymbol == null);

    public function hasAnim(name:String):Bool
        return offsets.exists(name);

    public function getAnim():String
        return _lastAnim;

    public function isFinished():Bool {
        if (isNull()) return false;
		return animation.curAnim.finished; //!isAnimateAtlas ? animation.curAnim.finished : atlas.anim.finished;
    }

    public function finishAnimation():Void {
		if (isNull()) return;
		animation.curAnim.finish(); //if(!isAnimateAtlas) animation.curAnim.finish(); else atlas.anim.curFrame = atlas.anim.length - 1;
	}

    public function newOffset(name:String, ?x:Float, ?y:Float)
	    offsets[name] = [x ?? 0, y ?? 0];

    /*public function dance() {
        if (!debugMode && !skipDance && !specialAnim) {
            if (danceIdle) {
                danced = !danced;
                playAnim('dance' + (danced ? 'Right' : 'Left'));
            } else if (hasAnim('idle'))
                playAnim('idle');
        }
    }*/

    public function dance() {
		if (!debugMode && !skipDance && !specialAnim) {
			if (danceIdle) {
				danced = !danced;
				if (danced)
					playAnim('danceRight');
				else
					playAnim('danceLeft');
			} else if (hasAnim('idle'))
				playAnim('idle');
		}
	}

    public var danceEveryNumBeats = 2;
	var settingCharacterUp = true;
    /*public function recalcDance() {
        var lastDanceIdle = danceIdle;
        var base = 'dance';

        danceIdle = hasAnim(base + 'Left' + suffix) && hasAnim(base + 'Right' + suffix);
        if (settingCharacterUp)
            danceEveryNumBeats = danceIdle ? 1 : 2;
        else if (lastDanceIdle != danceIdle) {
            var factor = danceIdle ? 0.5 : 2;
            danceEveryNumBeats = Math.round(Math.max(danceEveryNumBeats * factor, 1));
        }
        settingCharacterUp = false;
    }*/
    public function recalcDance() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (hasAnim('danceLeft') && hasAnim('danceRight'));

		if (settingCharacterUp)
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		else if (lastDanceIdle != danceIdle) {
			var calc:Float = danceEveryNumBeats;
			if (danceIdle)
				calc /= 2;
			else
				calc *= 2;
			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}
}