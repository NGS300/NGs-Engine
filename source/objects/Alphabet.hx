package objects;

/**
 * Kade Alphabet Copy
 */
class Alphabet extends flixel.group.FlxSpriteGroup {
	public var isMenuItem = false;
	public var targetY = 0.0;

	public var text = "";
	var _finalText = "";
	var yMulti = 1.0;

	var lastSprite:AlphaCharacter;
	var xPosResetted = false;
	var lastWasSpace = false;

	var listOAlphabets:List<AlphaCharacter> = new List<AlphaCharacter>();
	var splitWords:Array<String> = [];
	var isBold = false;

	var xScale:Float;
	var yScale:Float;
	var pastX = 0.0;
	var pastY = 0.0;

	public function new(x:Float, y:Float, text = "", ?bold = false, typed = false, shouldMove = false, ?xScale:Float, ?yScale:Float) {
		pastX = x;
		pastY = y;

		this.xScale = xScale ?? 1.0;
		this.yScale = yScale ?? 1.0;

		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;

		if (text != "") {
			if (typed)
				startTypedText();
			else
				addText();
		}
	}

	public function reType(text, ?xScale:Float, ?yScale:Float) {
		for (i in listOAlphabets)
			remove(i);
		_finalText = text;
		this.text = text;
		
		lastSprite = null;
		updateHitbox();

		listOAlphabets.clear();
		x = pastX;
		y = pastY;

		this.xScale = xScale ?? 1.0;
		this.yScale = yScale ?? 1.0;

		addText();
	}

	public function addText() {
		doSplitWords();
		var xPos = 0.0;
		for (character in splitWords) {
			if (character == " " || character == "-")
				lastWasSpace = true;
			if (AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1) {
				if (lastSprite != null)
					xPos = lastSprite.x - pastX + lastSprite.width;

				if (lastWasSpace) {
					xPos += 40 * xScale;
					lastWasSpace = false;
				}

				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);
				letter.scale.set(xScale, yScale);
				letter.updateHitbox();
				listOAlphabets.add(letter);

				if (isBold)
					letter.createBold(character);
				else
					letter.createLetter(character);
				add(letter);
				lastSprite = letter;
			}
		}
	}

	function doSplitWords():Void
		splitWords = _finalText.split("");

	public function startTypedText():Void {
		_finalText = text;
		doSplitWords();
		var loopNum = 0;
		var xPos = 0.0;
		var curRow = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer) {
			if (_finalText.fastCodeAt(loopNum) == "\n".code) {
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
				lastWasSpace = true;

			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);
			if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol) {
				if (lastSprite != null && !xPosResetted) {
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
				} else
					xPosResetted = false;

				if (lastWasSpace) {
					xPos += 20;
					lastWasSpace = false;
				}

				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti);
				listOAlphabets.add(letter);
				letter.row = curRow;
				if (isBold)
					letter.createBold(splitWords[loopNum]);
				else {
					if (isNumber)
						letter.createNumber(splitWords[loopNum]);
					else if (isSymbol)
						letter.createSymbol(splitWords[loopNum]);
					else
						letter.createLetter(splitWords[loopNum]);
					letter.x += 90;
				}
				add(letter);
				lastSprite = letter;
			}
			loopNum += 1;
			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
	}

	override function update(elapsed:Float) {
		if (isMenuItem) {
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
			x = FlxMath.lerp(x, (targetY * 20) + 90, 0.30);
		}
		super.update(elapsed);
	}

	public function resizeText(xScale:Float, yScale:Float, xStaysCentered = true, yStaysCentered = false):Void {
		var oldMidpoint:FlxPoint = this.getMidpoint();
		reType(text, xScale, yScale);
		if (!(xStaysCentered && yStaysCentered)) {
			if (xStaysCentered)
				moveTextToMidpoint(new FlxPoint(oldMidpoint.x, getMidpoint().y));
			if (yStaysCentered)
				moveTextToMidpoint(new FlxPoint(getMidpoint().x, oldMidpoint.y));
		} else
			moveTextToMidpoint(new FlxPoint(oldMidpoint.x, oldMidpoint.y));
	}

	public function moveTextToMidpoint(midpoint:FlxPoint):Void {
		this.x = midpoint.x - this.width / 2;
		this.y = midpoint.y - this.height / 2;
	}
}

class AlphaCharacter extends flixel.FlxSprite {
	public static var alphabet = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers = "1234567890";

	public static var symbols = "|~#$%()*+-:;<=>@[]^_.,'!? ";

	public var row = 0;

	public function new(x:Float, y:Float) {
		super(x, y);
		frames = Paths.atlas('alphabet');
		antialiasing = Settings.data.antialiasing;
	}

	public function createBold(letter:String) {
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createLetter(letter:String):Void {
		var letterCase = "lowercase";
		if (letter.toLowerCase() != letter)
			letterCase = 'capital';

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		updateHitbox();
		FlxG.log.add('the row' + row);

		y = (110 - height);
		y += row * 60;
	}

	public function createNumber(letter:String):Void {
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createSymbol(letter:String) {
		switch (letter) {
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 50;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				y -= 0;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
			case '_':
				animation.addByPrefix(letter, '_', 24);
				animation.play(letter);
				y += 50;
			case "#":
				animation.addByPrefix(letter, '#', 24);
				animation.play(letter);
			case "$":
				animation.addByPrefix(letter, '$', 24);
				animation.play(letter);
			case "%":
				animation.addByPrefix(letter, '%', 24);
				animation.play(letter);
			case "&":
				animation.addByPrefix(letter, '&', 24);
				animation.play(letter);
			case "(":
				animation.addByPrefix(letter, '(', 24);
				animation.play(letter);
			case ")":
				animation.addByPrefix(letter, ')', 24);
				animation.play(letter);
			case "+":
				animation.addByPrefix(letter, '+', 24);
				animation.play(letter);
			case "-":
				animation.addByPrefix(letter, '-', 24);
				animation.play(letter);
			case '"':
				animation.addByPrefix(letter, '"', 24);
				animation.play(letter);
				y -= 0;
			case '@':
				animation.addByPrefix(letter, '@', 24);
				animation.play(letter);
			case "^":
				animation.addByPrefix(letter, '^', 24);
				animation.play(letter);
				y -= 0;
			case ' ':
				animation.addByPrefix(letter, 'space', 24);
				animation.play(letter);
		}
		updateHitbox();
	}
}