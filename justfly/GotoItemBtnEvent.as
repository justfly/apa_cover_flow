package justfly{
	import flash.events.Event;
	public class GotoItemBtnEvent extends Event {
		public static const GotoItemBtn_Over:String="gotoItemBtnOver";
		public static const GotoItemBtn_Out:String="gotoItemBtnOut";
		public var percentage:Number=0;
		public function GotoItemBtnEvent(type:String) {
			super(type);
		}
	}
}