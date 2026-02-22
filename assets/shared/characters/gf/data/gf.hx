function onNew() {
    loadAtlas('GF_assets', 'gf');

	//animPrefix('singLEFT', 'left');
    setOffset("singLEFT", 0, -19);
	//animPrefix('singRIGHT', 'right');
    setOffset("singRIGHT", 0, -20);

	//animPrefix('singUP', 'up');
    setOffset("singUP", 0, 4);
	//animPrefix('singDOWN', 'down');
	setOffset("singDOWN", 0, -20);

    animPrefix('cheer', 'GF Cheer');
    setOffset('cheer');

    animPrefix('scared', 'GF FEAR', 24, true);
    setOffset('scared', -2, -17);

	animIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    setOffset('sad', -2, -2);

	animIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
    setOffset('hairFall', 0, -9);

    animIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24, true);
    setOffset('hairBlow', 45, -8);

    animIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
    setOffset('danceLeft', 0, -9);

	animIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]);
	setOffset('danceRight', 0, -9);

	playAnim('danceRight');
}