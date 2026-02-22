function onNew() {
    load('GF_assets', 'gf');
    prefix('cheer', 'GF Cheer');
	prefix('singLEFT', 'GF left note');
	prefix('singRIGHT', 'GF Right Note');
	prefix('singUP', 'GF Up Note');
	prefix('singDOWN', 'GF Down Note');
	indices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
	indices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
	indices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]);
	indices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
    indices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24, true);
	prefix('scared', 'GF FEAR', 24, true);

	offset('cheer');
	offset('sad', -2, -2);
	offset('danceLeft', 0, -9);
	offset('danceRight', 0, -9);

	offset("singUP", 0, 4);
	offset("singRIGHT", 0, -20);
	offset("singLEFT", 0, -19);
	offset("singDOWN", 0, -20);
	offset('hairFall', 0, -9);
    offset('hairBlow', 45, -8);
	offset('scared', -2, -17);

	play('danceRight');
}