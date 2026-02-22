package objects;

class Character extends CharSprite {
    public function new(x:Float, y:Float, ?char:String, ?isPlayer:Bool) {
        super(x, y, char, isPlayer);
        change(char ?? 'bf');
    }

    public function change(char:String) {
        offsets = [];
        curCharacter = char;
        script = getFolder(char);
        script.set('load', loadSprite);
        script.set('prefix', newPrefix);
        script.set('indices', newIndices);
        script.set('offset', newOffset);
        script.set('play', play);
        script.call('onNew');
        skipDance = false;
        recalcDance();
		dance();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}