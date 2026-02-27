package util;

class SongUtil {
	/**
	 * Difficulty order.
	 * Index = difficulty ID
	 */
	public static final difficulties:Array<String> = [
		"easy",
		"normal",
		"hard"
	];

	/**
	 * Convert difficulty string to int
	 */
	public static function diffToInt(diff:String):Int {
		if (diff == null)
			return -1;
		return difficulties.indexOf(diff.toLowerCase());
	}

	/**
	 * Convert difficulty int to string
	 */
	public static function intToDiff(value:Int):String {
		if (value < 0 || value >= difficulties.length)
			return "";
		return difficulties[value];
	}

	/**
	 * Convert Float to String
	 */
	public static function floatToString(f:Float):String {
		var s = Std.string(f);
		if (Math.floor(f) == f && s.indexOf(".") == -1)
			s += ".0";
		return s;
	}

	/**
	 * Wraps a string to a new line based on a max character length per line.
	 * 1. Forces a line break when a semicolon followed by a space ("; ") is found.
	 * 2. Implements mandatory word break/hyphenation if needed.
	 */
	public static function wrapCharText(text:String, maxLineLength:Int):String {
		if (text == null || text.length == 0)
			return "";

		var chunks = text.split("; ");
		var finalLines:Array<String> = [];

		for (chunk in chunks) {
			if (chunk.length == 0)
				continue;

			var words = chunk.split(" ");
			var currentLine = "";

			for (word in words) {
				var currentLength = currentLine.length + (currentLine.length > 0 ? 1 : 0);

				if (currentLength + word.length > maxLineLength) {
					var remainingWord = word;
					var availableSpace = maxLineLength - currentLength;

					if (currentLine.length > 0 && availableSpace >= 2) {
						var charsToBreak = availableSpace - 1;
						if (charsToBreak >= 1) {
							var part1 = word.substr(0, charsToBreak) + "-";
							remainingWord = word.substr(charsToBreak);

							currentLine += " " + part1;
							finalLines.push(currentLine);
							currentLine = "";
						}
					}

					if (currentLine.length > 0) {
						finalLines.push(currentLine);
						currentLine = "";
					}

					while (remainingWord.length > maxLineLength) {
						finalLines.push(remainingWord.substr(0, maxLineLength));
						remainingWord = remainingWord.substr(maxLineLength);
					}

					currentLine = remainingWord;
					continue;
				}

				if (currentLine.length > 0)
					currentLine += " ";
				currentLine += word;
			}

			if (currentLine.length > 0)
				finalLines.push(currentLine);
		}

		return finalLines.join("\n");
	}
}