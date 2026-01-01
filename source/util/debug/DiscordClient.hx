package util.debug;

import sys.thread.Thread;
import hxdiscord_rpc.Types;
import hxdiscord_rpc.Discord;

class DiscordClient {
	static var presence = new DiscordRichPresence();
	static var initialized = false;

	public static function check() {
		if (Settings.game.discordRPC)
			initialize();
		else if (initialized)
			shutdown();
	}

	public static function start() {
		if (!initialized && Settings.game.discordRPC)
			initialize();
		lime.app.Application.current.window.onClose.add(function() {
			if (initialized)
				shutdown();
		});
	}

	static function initialize() {
		final handlers = new DiscordEventHandlers();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize(Std.string(Core.api.get("discord_id")), cpp.RawPointer.addressOf(handlers), false, null);
		if (!initialized)
			Log.info("Discord: Client initialized.");
		Thread.create(function():Void {
			while (true) {
				if (initialized) {
					#if DISCORD_DISABLE_IO_THREAD
					Discord.UpdateConnection();
					#end

					Discord.RunCallbacks();
				}
				Sys.sleep(1);
			}
		});
		initialized = true;
	}

	static function shutdown() {
		initialized = false;
		Discord.Shutdown();
		Log.info("Discord: Has been shutdown.");
	}

	public static function changePresence(?details:String, ?state:String, ?smallImage:String, ?canTimes:Bool, ?endTimes:Float, ?largeImage:String) {
		var startTimestamp = 0.0;
		if (canTimes ?? false)
			startTimestamp = Date.now().getTime();
		if (endTimes > 0)
			endTimes = startTimestamp + endTimes;

		presence.state = state ?? null;
		presence.details = details ?? 'In Title Screen';
		presence.smallImageKey = smallImage ?? null;
		presence.largeImageKey = largeImage ?? 'icon';
		presence.largeImageText = "Engine Version: " + Std.string(Core.engine.get('version'));
		presence.endTimestamp = Std.int(endTimes / 1000);
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
	}

	static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void {
		final user = request[0].username;
		final discriminator = Std.parseInt(request[0].discriminator);

		var message = 'Discord: Connected to User ';
		if (discriminator != 0)
			message += '($user#$discriminator)';
		else
			message += '($user)';

		Log.info(message);
		changePresence();
	}

	static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
		Log.info('Discord: Disconnected ($errorCode:$message)');

	static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
		Log.info('Discord: Error ($errorCode:$message)');
}