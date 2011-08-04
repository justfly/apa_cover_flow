package com.weberdesignlabs.media.events {	

	import flash.events.Event;
	
	public class VidPlayerEvent extends Event{
				
		public static const PLAYBACK_COMPLETE:String = "playback_complete";
		public static const PLAYBACK_STOP:String = "playback_stop";
		public static const PLAYBACK_START:String = "playback_start";
		public static const PLAYBACK_PAUSE:String = "playback_pause";
		public static const PLAYBACK_RESUME:String = "playback_resume";
		public static const PLAYBACK_SEEK:String = "playback_seek";
		
		public static const CUEPOINT:String = "cuepoint";
		
		public static const BUFFER_FULL:String = "buffer_full";
		public static const BUFFER_EMPTY:String = "buffer_empty";
		public static const BUFFER_FLUSH:String = "buffer_flush";
		
		public static const RESET:String = "reset";
		
		public static const LOAD_START:String = "load_start";
		public static const LOAD_PROGRESS:String = "load_progress";
		public static const LOAD_COMPLETE:String = "load_complete";
		
		public static const SEEK_FAILED:String = "seek_failed";
		public static const SEEK_INVALID_TIME:String = "seek_invalid_time";
		public static const SEEK_NOTIFY:String = "seek_notify";
		
		public static const VOLUME_CHANGED:String = "volume_changed";
		
		public var traits:Object;
		
		public function VidPlayerEvent(type:String, disp_obj:Object) {
			// You have to call the super class constructor (Event)  before doing anything else.
			super(type);
			this.traits = disp_obj;
		}
		
		public override function clone():Event {
			return new VidPlayerEvent(type, this.traits);
		}
		
		public override function toString():String {
			return "[ VidPlayerEvent ]";
		}
	}
	
}