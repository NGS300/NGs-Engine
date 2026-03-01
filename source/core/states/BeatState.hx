package core.states;

import Conductor.BPMChangeEvent;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;

class BeatState extends FlxTransitionableState {
	public static var instance:BeatState;
	var curStep:Int = 0;
	var curBeat:Int = 0;
	
	var controls(get, never):Controls;
	inline function get_controls()
		return Controls.instance;

	override function create() {
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), null, null);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.6, new FlxPoint(0, 1), null, null);
		transIn = FlxTransitionableState.defaultTransIn;

		super.create();
	}

	override function update(elapsed:Float) {		
		var oldStep = curStep;
		updateCurStep();
		updateBeat();
		if (oldStep != curStep && curStep > 0)
			stepHit();
		super.update(elapsed);
	}

	function updateBeat():Void {
		curBeat = Math.floor(curStep / 4);
	}

	function updateCurStep():Void {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}
		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void {
		if (PlayState.stage != null)
			PlayState.stage.stepHit(curStep);
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void {
		if (PlayState.stage != null)
			PlayState.stage.beatHit(curBeat);
	}

	public function changeState(?next:Class<flixel.FlxState>) {
		if (next == null) {
			FlxG.resetState();
			Log.info('Resetting the current $next.');
			return;
		}
		FlxG.switchState(() -> cast Type.createInstance(next, []));
		Log.info('Switching to a $next.');
	}
}