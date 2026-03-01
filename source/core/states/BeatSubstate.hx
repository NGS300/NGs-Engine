package core.states;

import Conductor.BPMChangeEvent;

class BeatSubstate extends flixel.FlxSubState {
	public function new()
		super();

	var curStep:Int = 0;
	var curBeat:Int = 0;

	var controls(get, never):Controls;
	inline function get_controls()
		return Controls.instance;

	override function update(elapsed:Float) {
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);
		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	function updateCurStep():Void {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}
		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void {
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void {}
}