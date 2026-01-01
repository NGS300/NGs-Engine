package;

class Core {
	public static var engine:Map<String, Dynamic> = [ // Engine Information's
		'title' => 'Unknown',
		'engine' => 'Unknown',
		'name' => 'Unknown',
		'version' => 'v0.0.0',
		'state' => 'Unknown',
		'number' => 0,
		'date' => '????-??-??'
	];

	// Game Information's
	public static var game:Map<String, Dynamic> = ['name' => "Friday Night Funkin'", 'version' => 'v0.0.0'];

	// API's Keys
	public static var api:Map<String, Dynamic> = ['discord_id' => 'Unknown', 'jolt_key' => 'Unknown', 'jolt_id' => 'Unknown'];
}