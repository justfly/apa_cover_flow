////////////////////////////////////////////
// Project: Video Coverflow
// Author: Stephen Weber
// Website: www.weberdesignlabs.com
////////////////////////////////////////////

package {

	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import flash.text.TextField;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import flash.geom.Rectangle;

	import caurina.transitions.Tweener;
	
	import justfly.*;

	public class CoverflowItem extends MovieClip {

		private var __title:String;
		private var __photopath:String;
		private var __introduction:String;
		private var __itemID:Number;
		private var __productsurl:String;
		private var __loader:Loader;
		
		public var _bg:Bg;
		public var title:String;
		public var photopath:String;
		public var introduction:String;
		public var productsurl:String;
		public var itemID:Number;

		public function CoverflowItem(_title:String="", _photopath:String="",_introduction:String="",_productsurl:String="",_itemID:Number=0) {

			title=_title;
			photopath=_photopath;
			introduction=_introduction;
			productsurl=_productsurl;
			itemID=_itemID;
			__loader = new Loader();
			__loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imageLoad_Complete);
			__loader.load(new URLRequest(_photopath));
			var re:Reflect=new Reflect(this,50,80, 0,0,1);
			_bg = new Bg();
			addChild(_bg);
			addChild(__loader);
		}
		private function imageLoad_Complete(event:Event):void {
			//trace(__loader,"IMAGE LOADED");
			__loader.alpha = 0;
			Tweener.addTween(__loader,{ alpha:1, time:1 });
			Tweener.addTween(this.bg,{ alpha:0, time:1 });
		}
	}
}