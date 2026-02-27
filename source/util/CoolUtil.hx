package util;

class CoolUtil {
    inline static public function normalizeName(value:String, ?useMinus:Bool):String {
		var formaMinus = useMinus ?? true;
		if (value == null)
			return "";

		final hideChars = ~/[.,'"%?!]/g;

		var out = value.trim();
		if (formaMinus) {
			final invalidChars = ~/[~&;:<>#\s]/g;
			out = invalidChars.replace(out, "-");
			out = out.split("--").join("-");
		} else {
			final invalidChars = ~/[~&;:<>#]/g;
			out = invalidChars.replace(out, "");
		}
		out = hideChars.replace(out, "");

		return out;
	}
}