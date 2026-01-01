package core;

import flixel.FlxState;
import flixel.addons.transition.TransitionData;

/**
 * Handles beat/step timing updates for the current song
 */
class BeatState extends FlxTransitionableState {
	var systemClock:String = '';
	var curStep:Int = 0;
	var curBeat:Int = 0;
	var curDecimalBeat:Float = 0;

	public var controls(get, never):Controls;
	function get_controls()
		return Controls.instance;

	override function create() {
		FlxTransitionableState.defaultTransIn = new TransitionData(
			FADE, FlxColor.BLACK, 1,
			new FlxPoint(0, -1), null, null
		);
		FlxTransitionableState.defaultTransOut = new TransitionData(
			FADE, FlxColor.BLACK, 0.6,
			new FlxPoint(0, 1), null, null
		);
		transIn = FlxTransitionableState.defaultTransIn;
		TimingStruct.clearTimings(); // Clear old timings
		super.create();
	}

	override function update(elapsed:Float) {
		if (Conductor.songPosition < 0)
			curDecimalBeat = 0;
		else {
			if (TimingStruct.AllTimings.length > 0) {
				var data = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
				if (data != null) {
					Conductor.crochet = ((60 / data.bpm) * 1000);
					var stepMS = Conductor.crochet / 4;
					var startInMS = data.startTime * 1000;

					curDecimalBeat = data.startBeat + ((Conductor.songPosition / 1000 - data.startTime) * (data.bpm / 60));
					var ste:Int = Math.floor(data.startStep + ((Conductor.songPosition - startInMS) / stepMS));
					if (ste >= 0) {
						if (ste > curStep) {
							for (_ in curStep...ste) {
								curStep++;
								updateBeat();
								stepHit();
							}
						} else if (ste < curStep) {
							curStep = ste;
							updateBeat();
						}
					}
				}
			} else { // Fallback if no timings
				curDecimalBeat = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
				var nextStep:Int = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
				if (nextStep >= 0) {
					if (nextStep > curStep) {
						for (_ in curStep...nextStep) {
							curStep++;
							updateBeat();
							stepHit();
						}
					} else if (nextStep < curStep) {
						curStep = nextStep;
						updateBeat();
					}
				}
				Conductor.crochet = ((60 / Conductor.bpm) * 1000);
			}
		}
		systemClock = util.DateUtil.systemDate();
		super.update(elapsed);
	}

	/**
	 * Update current beat from steps
	 */
	function updateBeat():Void 
		curBeat = Math.floor(curStep / 4);

	/**
	 * Calculates the current step using BPM changes
	 */
	function updateCurStep():Int {
		var lastChange:core.Conductor.BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (change in Conductor.bpmChangeMap) {
			if (Conductor.songPosition >= change.songTime)
				lastChange = change;
		}
		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	/**
	 * Called every step
	 */
	public function stepHit():Void {
		if (curStep % 4 == 0)
			beatHit();
	}

	/**
	 * Called every beat (4 steps)
	 */
	public function beatHit():Void {/* intentionally empty */}

	public function changeState(?next:Class<FlxState>) {
		if (next == null) {
			FlxG.resetState();
			Log.info('Resetting the current $next.');
			return;
		}

		FlxG.switchState(() -> cast Type.createInstance(next, []));
		Log.info('Switching to a $next.');
	}
}