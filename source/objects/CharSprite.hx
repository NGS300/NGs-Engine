package objects;

import core.HScript;
import openfl.utils.Assets as OpenFlAssets;

class CharSprite extends FlxSprite {
    public var offsets:Map<String, Array<Dynamic>>;
    public var curCharacter:String;
    public var suffix = '';

    public var singDuration:Float = 4;
	public var holdTimer:Float = 0;
    public var heyTimer:Float = 0;
    public var specialAnim = false;
    public var skipDance = false;
    public var isPlayer = false;

    public var debugMode = false;
    var danceIdle = false;
    var danced = false;

    var localFolder:String;
    var script:HScript;
    public function new(x:Float, y:Float, ?char:String, ?isPlayer:Bool) {
        super(x, y);
        offsets = new Map<String, Array<Dynamic>>();
        this.isPlayer = isPlayer ?? false;
        localFolder = "shared/characters/";
    }

    private function getFolder(character:String):HScript {
        var folders = ["bf", "gf", "opponent"];
        for (folder in folders) {
            var path = Paths.getPath(character + ".hx", localFolder + '$folder/data');
            if (OpenFlAssets.exists(path))
                return new HScript(path);
        }
        trace('Character script not found: $character');
        return null;
    }

    public function loadSprite(file:String, ?folder:String) {
        frames = Paths.atlas(file, localFolder + folder);
        antialiasing = (PlayState.stage.isPixel ? false : Settings.data.antialiasing);
    }

    public function newPrefix(name:String, prefix:String, ?frame:Float, ?loop:Bool, ?flipX:Bool, ?flipY:Bool)
        animation.addByPrefix(name, prefix, frame ?? 24, loop ?? false, flipX ?? false, flipY ?? false);

    public function newIndices(name:String, prefix:String, indices:Array<Int>, ?postfix:String, ?frame:Float, ?loop:Bool, ?flipX:Bool, ?flipY:Bool)
        animation.addByIndices(name, prefix, indices, postfix ?? "", frame ?? 24, loop ?? false, flipX ?? false, flipY ?? false);

    public function newOffset(name:String, ?x:Float, ?y:Float)
	    offsets[name] = [x ?? 0, y ?? 0];

    public function hasAnim(anim:String):Bool
        return offsets.exists(anim);

    public function play(name:String, ?force:Bool, ?reversed:Bool, ?frame:Int):Void {
		animation.play(name, force ?? false, reversed ?? false, frame ?? 0);
		if (hasAnim(name)) {
            var daOffset = offsets.get(name);
			offset.set(daOffset[0], daOffset[1]);
        }

        if (curCharacter.startsWith('gf-') || curCharacter == 'gf') {
			if (name == 'singLEFT')
				danced = true;
			else if (name == 'singRIGHT')
				danced = false;

			if (name == 'singUP' || name == 'singDOWN')
				danced = !danced;
		}
	}

    override function update(elapsed:Float) {
        if (debugMode) {
			super.update(elapsed);
			return;
		}

        if (heyTimer > 0) {
			heyTimer -= elapsed;
			if (heyTimer <= 0) {
				var anim:String = animation.curAnim.name;
				if (specialAnim && (anim == 'hey' || anim == 'cheer')) {
					specialAnim = false;
					dance();
				}
				heyTimer = 0;
			}
		} else if (specialAnim && animation.curAnim.finished) {
			specialAnim = false;
			dance();
		} else if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished) {
			dance();
			animation.curAnim.finish();
		}

        if (animation.curAnim.name.startsWith('sing'))
            holdTimer += elapsed;
		else if (isPlayer)
            holdTimer = 0;

        if (!isPlayer) {
            if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration) {
                dance();
                holdTimer = 0;
            }
        } else {
			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
				play('idle', true, false, 10);

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
				play('deathLoop');
        }
        super.update(elapsed);
    }

    public function dance() {
        if (!debugMode && !skipDance && !specialAnim) {
			if (danceIdle) {
				danced = !danced;
				if (danced)
					play('danceRight');
				else
					play('danceLeft');
			} else if (hasAnim('idle'))
				play('idle');
		}
	}

    public var danceEveryNumBeats = 2;
	var settingCharacterUp = true;
    public function recalcDance() {
		var lastDanceIdle = danceIdle;
		danceIdle = (hasAnim('danceLeft' + suffix) && hasAnim('danceRight' + suffix));

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