package {

	import flash.display.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	
  	import caurina.transitions.*;
	import caurina.transitions.properties.FilterShortcuts;
	import caurina.transitions.properties.TextShortcuts
	FilterShortcuts.init();
	TextShortcuts.init();
	
	import org.papervision3d.objects.primitives.Plane;
	
	import justfly.GotoItemBtnEvent;

	public class GotoItemBtn extends MovieClip {
		
		private var changeTxtTimer:Timer = new Timer(300);
		private var transition:String="easeOutExpo";
		private var nowItem:Plane;
		
		//GlowFilter(color:uint = 0xFF0000, alpha:Number = 1.0, blurX:Number = 6.0, blurY:Number = 6.0, strength:Number = 2, quality:int = 1, inner:Boolean = false, knockout:Boolean = false)
		private var glowIn:GlowFilter = new GlowFilter(0x333333,0.9,2,2,10,5);
		private var glowOut:GlowFilter = new GlowFilter(0x333333,0,2,2,10,5);

		public function GotoItemBtn() {
			addEventListener(Event.ADDED_TO_STAGE,init);
			gotoUrlBtn.buttonMode=true;
			gotoUrlBtn.addEventListener(MouseEvent.CLICK,gotoUrlBtnDown);
			gotoUrlBtn.addEventListener(MouseEvent.ROLL_OVER,gotoUrlBtnOver);
			gotoUrlBtn.addEventListener(MouseEvent.ROLL_OUT,gotoUrlBtnOut);
		}
		private function init(e:Event){
			//this.cacheAsBitmap = true;
			this.alpha = 0;
		}
		
		public function changeItem(Item:Plane):void{
			changeTxtTimer.start();
			nowItem = Item;
			changeTxtTimer.addEventListener(TimerEvent.TIMER,changeTxt);
			Tweener.addTween(this,{ alpha:0, time:0.3 ,delay:0,transition:transition });
			Tweener.addTween(this,{ alpha:1, time:0.3 ,delay:0.3, transition:transition});
		}
		
		private function changeTxt(e:TimerEvent){
			changeTxtTimer.stop();
			this.name_txt.text = nowItem.material["texture"].title;
			this.slogan_txt.text = nowItem.material["texture"].introduction;
			//trace(Item.material["texture"].title,Item.material["texture"].introduction);
		}
		private function gotoUrlBtnOver(e:MouseEvent):void{
			//name_txt.filters = [filt];
			//trace("dispatchEvent GotoItemBtnEvent")
			this.dispatchEvent(new GotoItemBtnEvent(GotoItemBtnEvent.GotoItemBtn_Over));
			//Tweener.addTween(name_txt, {_filter:glowIn, time:0.3});	
			//Tweener.addTween(slogan_txt, {_filter:glowIn, time:0.3});
			Tweener.addTween(name_txt, {_text_size:14, time:0.2});
			Tweener.addTween(slogan_txt, {_text_size:14, time:0.2});
			var bold_fmt:TextFormat = new TextFormat();
			bold_fmt.bold = true;
			name_txt.setTextFormat(bold_fmt);
			slogan_txt.setTextFormat(bold_fmt);
		}
		private function gotoUrlBtnDown(e:MouseEvent):void{
			trace(nowItem.material["texture"].productsurl);
		}
		private function gotoUrlBtnOut(e:MouseEvent):void{
			this.dispatchEvent(new GotoItemBtnEvent(GotoItemBtnEvent.GotoItemBtn_Out));
			//Tweener.addTween(name_txt, {_filter:glowOut, time:0.3, transition:transition});	
			//Tweener.addTween(slogan_txt, {_filter:glowOut, time:0.3, transition:transition});	
			Tweener.addTween(name_txt, {_text_size:13, time:0.1});	
			Tweener.addTween(slogan_txt, {_text_size:13, time:0.1});
			var unbold_fmt:TextFormat = new TextFormat();
			unbold_fmt.bold = false;
			name_txt.setTextFormat(unbold_fmt);
			slogan_txt.setTextFormat(unbold_fmt);
		}

	}
}