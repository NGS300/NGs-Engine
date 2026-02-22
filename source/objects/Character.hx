package objects;

class Character extends CharSprite {
    public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
    public function new(x:Float, y:Float, ?char:String, ?isPlayer:Bool) {
        super(x, y, char, isPlayer);
        change(char ?? 'bf');
    }

    public function change(char:String) {
        offsets = [];
        curCharacter = char;
        script = getFolder(char);
        script.set('loadAtlas', loadAtlas);

        script.set('animPrefix', newPrefix);
        script.set('animIndices', newIndices);
        script.set('setOffset', newOffset);
        script.set('playAnim', play);

        script.set('singTimer', singDuration);
        script.set('flipX', flipX);
        script.set('flipY', flipY);
        script.set('scale', scale);
        script.set('setSize', setSize);
        script.set('setGraphicSize', setGraphicSize);
        script.set('updateHitbox', updateHitbox);

        script.set('posArray', positionArray);
        script.set('camPos', cameraPosition);
        script.call('onNew');
        addSings();
        
        skipDance = false;
        recalcDance();
		dance();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    function addSings() {
        var check = ['left', 'down', 'up', 'right'];
        var frameLower = frame.name.toLowerCase();
        var matchedFrame:Null<String> = null;
        for (i in check) {
            if (frameLower.endsWith(i)) {
                matchedFrame = frame.name;
                break;
            }
            var noteSuffix = i + " note";
            if (frameLower.endsWith(noteSuffix)) {
                matchedFrame = frame.name;
                break;
            }
        }

        if (matchedFrame != null) {
            var side = "";
            for (s in check) {
                if (matchedFrame.toLowerCase().endsWith(s)) {
                    side = s;
                    break;
                }
            }
            var singName = "sing" + side.toUpperCase();
            animation.addByPrefix(singName, matchedFrame);
        }
    }
}