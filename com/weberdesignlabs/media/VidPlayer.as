////////////////////////////////////////////
// Project: Generic Video Player
// Author: Stephen Weber
// Version: 1.5
// Website: www.weberdesignlabs.com
////////////////////////////////////////////

package com.weberdesignlabs.media{
	
	////////////////////////////////////////////
	// IMPORTS
	////////////////////////////////////////////

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import com.weberdesignlabs.media.events.*;

	public class VidPlayer extends Sprite {

		////////////////////////////////////////////
		// VARIABLES
		////////////////////////////////////////////
		
		//CONSTANTS
		const SMOOTHING:Boolean = false;
		const DEFAULT_VOLUME:Number = 1;

		private var __nc:NetConnection;
		private var __ns:NetStream;
		private var __vid:Video;
		private var __client:Object;
		private var __volume:Number;


		private var __btnPause:*;
		private var __btnPlay:*;
		private var __btnStop:*;
		private var __btnRestart:*;

		private var __path:String;
		private var __cuepoints:Array;

		private var __silent:Boolean;


		////////////////////////////////////////////
		// CONSTRUCTOR - INITIAL ACTIONS
		////////////////////////////////////////////
		public function VidPlayer(v_h:Number = 780.5, v_w:Number = 419.5) {
			__nc = new NetConnection();
			__nc.connect(null);

			__ns = new NetStream(__nc);
			__volume = 100;

			__client = new Object();
			__client.onCuePoint = cuePointHandle;
			__client.onMetaData = metaDataHandle;
			__ns.addEventListener(NetStatusEvent.NET_STATUS, netStatHandle, false, 0, true);


			__vid = new Video(v_h, v_w);
			__vid.smoothing = SMOOTHING;
			__vid.attachNetStream(__ns);

			__silent = new Boolean(false);

			__cuepoints = new Array();

			volume = DEFAULT_VOLUME;
			
			addChild(__vid);
		}
		public function cuePointHandle(info:Object):void {
			dispatchEvent(new VidPlayerEvent(VidPlayerEvent.CUEPOINT, info));
		}
		public function metaDataHandle(info:Object):void {
			//trace("metaDataHandle");
			__ns.client.__duration = info.duration;
			__cuepoints = new Array();
		}
		////////////////////////////////////////////
		// GETTERS AND SETTERS
		////////////////////////////////////////////

		public function set btnPause(val:*) {
			__btnPause = val;
			val.addEventListener(MouseEvent.MOUSE_DOWN, pauseHandle);
		}
		public function set btnPlay(val:*) {
			__btnPlay = val;
			val.addEventListener(MouseEvent.MOUSE_DOWN, playHandle);
		}
		public function set btnRestart(val:*) {
			__btnRestart = val;
			val.addEventListener(MouseEvent.MOUSE_DOWN, restartHandle);
		}
		public function set btnStop(val:*) {
			__btnStop = val;
			val.addEventListener(MouseEvent.MOUSE_DOWN, stopHandle);
		}
		public function set volume(val:Number) {
			if (val > 1) {
				val /= 100;
			}
			var sound_trans:SoundTransform = new SoundTransform();
			sound_trans.volume = val;
			__ns.soundTransform = sound_trans;
			__volume = val;

			dispatchEvent(new VidPlayerEvent(VidPlayerEvent.VOLUME_CHANGED, {volume: val}));

		}
		public function set silent(val:Boolean) {
			if (val == true) {
				__ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatHandle);
				__ns.client = this;
			} else {
				__ns.addEventListener(NetStatusEvent.NET_STATUS, netStatHandle);
				__ns.client = __client;
			}
			__silent = val;

		}

		public function get btnPause():* {
			return __btnPause;
		}
		public function get btnPlay():* {
			return __btnPlay;
		}
		public function get btnRestart():* {
			return __btnRestart;
		}
		public function get btnStop():* {
			return __btnStop;
		}
		public function get time():Number {
			return __ns.time;
		}
		public function get duration():Number {
			var _return:Number;
			
			if(__ns.client.__duration) {
				_return = __ns.client.__duration;
			} else {
				_return = 0;
			}
			
			return _return;
		}
		public function get formattedTime():String {


			var seconds:Number = Math.round(__ns.time);
			var minutes:Number = Math.floor(seconds/60);
			var hours = Math.floor(minutes/60);

			var seconds_duration = Math.round(__ns.client.__duration);
			var minutes_duration = Math.round(seconds_duration/60);
			var hours_duration = Math.round(minutes_duration/60);

			var ret_string:String = "";

			if (hours_duration > 0) {
				ret_string += addZero(hours) + ":";
			}
			ret_string += addZero(minutes) + ":" + addZero(seconds%60);
			return ret_string;

		}
		public function get formattedDuration():String {
			var seconds:Number = Math.round(__ns.client.__duration);
			var minutes:Number = Math.floor(seconds/60);
			var hours:Number = Math.floor(hours/60);

			var ret_string:String = "";

			if (hours > 0) {
				ret_string += addZero(hours) + ":";
			}
			ret_string += addZero(minutes) + ":" + addZero(seconds%60);
			return ret_string;

		}
		public function get volume():Number {
			return __ns.soundTransform.volume;
		}
		public function get path():String {
			return __path;
		}
		public function get percentLoaded():Number {
			return Number(__ns.bytesLoaded) / Number(__ns.bytesTotal);
		}
		public function get percentPlayed():Number {
			return Number(this.time / this.duration);
		}
		public function get percentBuffered():Number {
			return Number(__ns.bufferLength / __ns.bufferTime);
		}
		public function get bufferLength():Number {
			return __ns.bufferLength;
		}
		public function get bufferTime():Number {
			return __ns.bufferTime;
		}
		public function get silent():Boolean {
			return __silent;
		}
		public function get cue():Array {
			return __cuepoints;
		}
		public function get nextCue():Object {
			var t:Number = __ns.time;
			var cue_count:int = __cuepoints.length;
			var temp_cue:Object;
			for (var cue_loop:int = 0; cue_loop < cue_count; cue_loop++) {
				temp_cue = __cuepoints[cue_loop];
				if (temp_cue.time > t) {
					return temp_cue;
				}
			}
			return {};
		}
		public function get previousCue():Object {
			var t:Number = __ns.time;
			var cue_count:int = __cuepoints.length;
			var temp_cue:Object;
			for (var cue_loop:int = cue_count-1; cue_loop >= 0; cue_loop--) {
				temp_cue = __cuepoints[cue_loop];
				if (temp_cue.time < t) {
					return temp_cue;
				}
			}
			return {};
		}
		public function get nearestCue():Object {
			var pc:Object = this.previousCue;
			var nc:Object = this.nextCue;
			if (Math.abs(pc.time - __ns.time) < Math.abs(nc.time - __ns.time)) {
				return pc;
			} else {
				return nc;
			}
		}
		////////////////////////////////////////////
		// EVENT HANDLERS
		////////////////////////////////////////////
		private function pauseHandle(e:MouseEvent) {
			__ns.togglePause();
		}
		private function playHandle(e:MouseEvent) {
			__ns.resume();
			//dispatchEvent(new VidPlayerEvent(VidPlayerEvent.PLAYBACK_RESUME, {}));
		}
		private function restartHandle(e:MouseEvent) {
			__ns.pause();
			__ns.seek(0);
			__ns.resume();
		}
		private function stopHandle(e:MouseEvent) {
			__ns.pause();
			__ns.seek(0);

		}
		private function netStatHandle(e:NetStatusEvent) {
			var info = e.info;
			var code = e.info.code;
			
			if (code == "NetStream.Play.Stop") {
				if (__ns.time >= __ns.client.__duration) {
					dispatchEvent(new VidPlayerEvent(VidPlayerEvent.PLAYBACK_COMPLETE, {}));
				}
				__ns.seek(0);
				pause(true);
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.PLAYBACK_STOP, {}));
			} else if (code == "NetStream.Play.Start") {
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.PLAYBACK_START, {}));
			} else if (code == "NetStream.Pause.Notify") {
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.PLAYBACK_PAUSE, {time: __ns.time}));
			} else if (code == "NetStream.Unpause.Notify") {
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.PLAYBACK_RESUME, {time: __ns.time}));
			} else if (code == "NetStream.Play.Reset") {
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.RESET, {}));
			} else if (code == "NetStream.Seek.Notify") {
				trace("NETSTAT EVENT SEEK TIME:",__ns.time);
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.PLAYBACK_SEEK, { time: __ns.time }));
			} else if (code == "NetStream.Buffer.Full") {
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.BUFFER_FULL, {}));
			} else if (code == "NetStream.Buffer.Empty") {
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.BUFFER_EMPTY, {}));
			} else if (code == "NetStream.Buffer.Flush") {
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.BUFFER_FLUSH, {}));
			} else if (code == "NetStream.Seek.Failed") {
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.SEEK_FAILED, {}));
			} else if (code == "NetStream.Seek.InvalidTime") {
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.SEEK_INVALID_TIME, {}));
			}
		}
		////////////////////////////////////////////
		// FUNCTIONS
		////////////////////////////////////////////

		public function reset():void {
			destroy();
			__ns = new NetStream(__nc);
			__ns.client = new Object();
			__ns.receiveAudio(true);
			__ns.receiveVideo(true);
			__ns.addEventListener(NetStatusEvent.NET_STATUS, netStatHandle);
			__vid.clear();
			__vid.attachNetStream(__ns);
			this.volume = __volume;
		}
		public function destroy():void {
			__ns.receiveAudio(false);
			__ns.receiveVideo(false);
			__ns.close();

		}
		public function fakePlay(path:String = ""):void {
			reset();
			if (path != "") {
				__ns.play(path);
				__ns.client = __client;
				__path = path;
				//dispatchEvent(new VidPlayerEvent(VidPlayerEvent.LOAD_START, {progress: 0, loaded: __ns.bytesLoaded, total: __ns.bytesTotal}));
				//addEventListener(Event.ENTER_FRAME, reportProgress);
				pause(false);
			} else {
				pause(false);
			}
		}
		public function play(path:String = ""):void {
			reset();
			if (path != "") {
				__ns.play(path);
				__ns.client = __client;
				__path = path;
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.LOAD_START, {progress: 0, loaded: __ns.bytesLoaded, total: __ns.bytesTotal}));
				addEventListener(Event.ENTER_FRAME, reportProgress);
				//pause(false);
			} else {
				pause(false);
			}
		}
		public function pause(val:Boolean=true):void {
			if (val) {
				__ns.pause();
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.PLAYBACK_PAUSE, {}));
			} else {
				__ns.togglePause();
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.PLAYBACK_RESUME, {}));
			}
		}
		public function stop():void {
			__ns.pause();
			__ns.seek(0);

			dispatchEvent(new VidPlayerEvent(VidPlayerEvent.PLAYBACK_STOP, {}));
		}
		public function seek(val:Number) {
			trace("VP SEEK FUNCTION:",val);
			__ns.seek(val);
		}
		
		private function addZero(val:Number):String {
			var ret:String = val.toString();
			if (val < 10) {
				ret = "0" + ret;
			}
			return ret;
		}
		private function reportProgress(e:Event) {
			var percent_loaded = __ns.bytesLoaded/__ns.bytesTotal;
			dispatchEvent(new VidPlayerEvent(VidPlayerEvent.LOAD_PROGRESS, {progress: percent_loaded, loaded:__ns.bytesLoaded, total:__ns.bytesTotal}));
			if (__ns.bytesLoaded == __ns.bytesTotal) {
				dispatchEvent(new VidPlayerEvent(VidPlayerEvent.LOAD_COMPLETE, {}));
				removeEventListener(Event.ENTER_FRAME, reportProgress);
			}
		}
	}
}