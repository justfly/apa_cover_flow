////////////////////////////////////////////
// Project: Video Coverflow
// Author: Stephen Weber
// Website: www.weberdesignlabs.com
////////////////////////////////////////////
package {


	////////////////////////////////////////////
	// IMPORTS
	////////////////////////////////////////////
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.TextField;
	import flash.utils.*;

	//Import Papervision
	import org.papervision3d.view.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.scenes.*;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.core.utils.InteractiveSceneManager;
	
	//TweenLite - Tweening Engine - SOURCE: http://blog.greensock.com/tweenliteas3/
	import gs.*;
	import gs.easing.*;
	
	import justfly.Bg;
	import justfly.GotoItemBtnEvent;
	
	//Tweener - Tweening Engine - SOURCE: http://code.google.com/p/tweener/
	//I like to use this one for Papervision, it seems to work better for Papervision
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.ColorShortcuts;
	ColorShortcuts.init();

	public class Main extends Sprite {

		////////////////////////////////////////////
		// VARIABLES
		////////////////////////////////////////////
		
		//Papervision Variables
		private var view:BasicView;
		private var camera:Camera3D;
		private var renderer:BasicRenderEngine;
		private var scene:Scene3D;
		private var viewport:Viewport3D;
		private var ism:InteractiveSceneManager;
		private var autoMoveAt:Boolean = true;
		private var autoMoveTimer:Timer = new Timer(5000);

		//Holds all xml data
		private var xmlData:XML=new XML;
		
		//Holds CoverflowItems
		private var planes:Array;
		
		//Holds Materials
		private var materialArray:Array;
		
		//Holds Current Plane Index in Planes Array
		private var currentPlaneIndex:Number=2;
		
		//CoverflowItem Plane Configuration
		private var planeAngle:Number=80;		//等待的項目之間的旋轉
		private var planeSeparation:Number=50;	//等待的項目之間的間隔
		private var planeOffset:Number=180;		//等待的項目跟現在播放項目之間的基本間隔
		
		private var planeZOffset:Number=60;
		private var selectPlaneZ:Number=-180;
		private var planeZSeparation:Number=10;
		private var tweenTime:Number=0.8;
		private var planeWidth=190;
		private var planeHeight=90;
		private var transition:String="easeOutExpo";

		////////////////////////////////////////////
		// CONSTRUCTOR - INITIAL ACTIONS
		////////////////////////////////////////////
		public function Main() {
			backBtn.alpha  = 0;
			backBtn.x = 30;
			nextBtn.alpha  = 0;
			nextBtn.x  = 470;
			coverOut.alpha  = 0;
			coverOut.scaleX = coverOut.scaleY = 0.9;
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		////////////////////////////////////////////
		// FUNCTIONS
		////////////////////////////////////////////
		//Sets up the papervision
		private function init(e:Event){
			setupPapervision();
			Tweener.addTween(backBtn,{ alpha:1, x:15, time:0.1, delay:0.3 }); // 等coverOut動態結束
			Tweener.addTween(nextBtn,{ alpha:1, x:485, time:0.1, delay:0.3 });
			Tweener.addTween(coverOut,{ alpha:1, time:0.3 });
			Tweener.addTween(coverOut,{ scaleX:1,scaleY:1, time:0.3,onComplete:loadXML,transition:"easeOutBounce"});
			//loadXML();
			this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelEvent);
		}
		
		private function setupPapervision():void {

			view=new BasicView(stage.stageWidth,stage.stageHeight,false,false,CameraType.TARGET);
			view.renderer=new BasicRenderEngine  ;
			CoverflowHolder.addChild(view);

			//Matching pixel dimensions 
			view.camera.focus=100;
			view.camera.zoom=10;
			view.camera.x=10;
			view.camera.z=-1425;
			view.camera.y=100;
			//view.camera.y=130;

			//Get Camera From BasicView
			camera=view.cameraAsCamera3D;

			//Get Renderer From BasicView
			renderer=view.renderer;

			//Get Scene From BasicView
			scene=view.scene;

			//Get Viewport From BasicView
			viewport=view.viewport;

			//Sets the View Port To Be Listening To Interactivity
			viewport.interactive=true;

			//Clear CoverflowItem Planes Array
			planes=new Array;
			
			//Clear CoverflowItem Material Array
			materialArray=new Array;

			//Handles All Click Events for Papervision objects
			ism=viewport.interactiveSceneManager;
			ism.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK,ismClickHandle,false,0,true);
			
			autoMoveTimer.start();
			autoMoveTimer.addEventListener(TimerEvent.TIMER,autoMove);
			
			gotoItembtn.addEventListener(GotoItemBtnEvent.GotoItemBtn_Over,function(e:GotoItemBtnEvent){autoMoveTimer.stop();});
			gotoItembtn.addEventListener(GotoItemBtnEvent.GotoItemBtn_Out,function(e:GotoItemBtnEvent){autoMoveTimer.start();});

		}
		//Loads the XML
		private function loadXML():void {
			
			//URL Loader to get XML
			var xmlLoader:URLLoader=new URLLoader;
			
			//Listen for load complete
			xmlLoader.addEventListener(Event.COMPLETE,loadXML_Complete);
			
			//Load XML
			xmlLoader.load(new URLRequest("albuminfo.xml"));
		}
		//Handles Parsing the XML
		private function loadXML_Complete(e:Event):void {

			//Set xml data
			xmlData=new XML(e.target.data);

			var i:uint = 0;
			
			//Loops through xml to get data
			
			for each(var xml:XML in xmlData.productinfo) {
				var _title:String=xml.title;				//名稱
				var _photopath:String=xml.photopath;		//圖片路徑
				var _introduction:String=xml.introduction;	//簡介
				var _productsurl:String=xml.productsurl;	//url
				
				
				//trace("PATH:",_path,_photopath);
				
				//Create CoverflowItem and pass data
				var _photoloader:CoverflowItem = new CoverflowItem(_title, _photopath, _introduction, _productsurl, i);
				materialArray.push(_photoloader);
				
				//Material
				var _photoloaderMat:MovieMaterial=new MovieMaterial(_photoloader,true);
				_photoloaderMat.smooth=true;
				_photoloaderMat.animated=true;
				_photoloaderMat.interactive=true;
				_photoloaderMat.name=i.toString();
				
				//Apply your MovieMaterial to your 3D object
				var _photoloaderPlane:Plane=new Plane(_photoloaderMat,_photoloader.width,_photoloader.height,9);
				
				//Adds a listener to the papervision object
				_photoloaderPlane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK,ismClickHandle,false,0,true);
				
				planes.push(_photoloaderPlane);
				view.scene.addChild(_photoloaderPlane);
				
				i++;
			}
			
			//Enable Actions To Next and Back Btns
			nextBtn.buttonMode=true;
			backBtn.buttonMode=true;
			nextBtn.addEventListener(MouseEvent.CLICK,nextBtnHandler);
			nextBtn.addEventListener(MouseEvent.ROLL_OVER,nextBtn_RollOver);
			nextBtn.addEventListener(MouseEvent.ROLL_OUT,nextBtn_RollOut);

			backBtn.addEventListener(MouseEvent.CLICK,backBtnHandler);
			backBtn.addEventListener(MouseEvent.ROLL_OVER,backBtn_RollOver);
			backBtn.addEventListener(MouseEvent.ROLL_OUT,backBtn_RollOut);

			//Goes to first plane
			gotoItem(0);

		}
		//Goes to the item in the specified index
		private function gotoItem(newCenterPlaneIndex:Number):void {
			
			autoMoveTimer.stop();

			//Start Rendering for Coverflow Item Plane Movement
			addEventListener(Event.ENTER_FRAME,onRenderViewport);
			
			var leftYPos:Number=(newCenterPlaneIndex)*10;
			var rightYPos:Number=0;
			
			//Loop through coverflowitem planes and position them accordingly
			for (var i:Number=0; i < planes.length; i++) {
				
				//Gets current plane
				var plane:Plane=planes[i]  as  Plane;
				plane.useOwnContainer = true;
				var planeAtNum:int = i - newCenterPlaneIndex;
				
				var _bg:Bg = plane.material["texture"]._bg;
				
				//Center Plane/Current Plane
				if (planeAtNum == 0) {
					gotoItembtn.changeItem(plane);
					Tweener.addTween(_bg,{ _saturation:1, time:tweenTime });
					//Position plane
					Tweener.addTween(plane,{alpha:1,scaleX: 1, scaleY: 1, x:0,z:selectPlaneZ,y:0,rotationY:0,time:tweenTime,transition:transition, onComplete:showVideoPlayer});
					//Remove Click Listener
					plane.removeEventListener(InteractiveScene3DEvent.OBJECT_CLICK, ismClickHandle);

				//All planes to the left
				} else {
					Tweener.addTween(_bg,{ _saturation:0, time:tweenTime });
					Tweener.addTween(plane,{ alpha:1-Math.abs(planeAtNum*2)/10, time:tweenTime });

					//All Planes to the Left
					if (planeAtNum < 0) {
						Tweener.addTween(plane,{ scaleX: 0.9, scaleY: 0.9, x:planeAtNum * planeSeparation - planeOffset ,y:0,z:planeAtNum * 50,rotationY:- planeAngle,time:tweenTime,transition:transition});
					
					//All Planes to the Right
					} else {
						Tweener.addTween(plane,{ scaleX: 0.9, scaleY: 0.9, x:planeAtNum * planeSeparation + planeOffset,y:0,z:planeAtNum * 50,rotationY:planeAngle,time:tweenTime,transition:transition});
					}
					
					//Check for listener
					if (!plane.willTrigger(InteractiveScene3DEvent.OBJECT_CLICK)) {
						plane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK,ismClickHandle,false,0,true);
					}
				}
				
				var _material:CoverflowItem=materialArray[i]  as  CoverflowItem;
				
			}
			
			currentPlaneIndex=newCenterPlaneIndex;
			autoMoveTimer.start();

		}
		//Shows the video player
		private function showVideoPlayer():void {
			
			/// Get Data From Current Plane
			var targ_plane = planes[currentPlaneIndex];
			var targ_mat = materialArray[currentPlaneIndex];
			//var path = targ_mat.videoPath;
			var title = targ_mat.title;
			//var thumb = targ_mat.thumb;
			var i = targ_mat.itemID;
			
			nextBtn.enabled = true;
			backBtn.enabled = true;
			
			//Stop Papervision rendering
			removeEventListener(Event.ENTER_FRAME,onRenderViewport);
			
		}
		//Renders Papervision Scene
		private function onRenderViewport(e:Event):void {

			view.singleRender();
		}
		////////////////////////////////////////////
		// BUTTON ACTIONS
		////////////////////////////////////////////
		private function nextBtn_RollOver(event:MouseEvent):void {
			event.target.gotoAndStop(2);
		}
		private function nextBtn_RollOut(event:MouseEvent):void {
			event.target.gotoAndStop(1);
		}
		private function nextBtnHandler(event:MouseEvent):void {
			noAfter()? null:gotoItem(currentPlaneIndex + 1);
			autoMoveAt = true;
		}
		private function backBtn_RollOver(event:MouseEvent):void {
			event.target.gotoAndStop(2);
		}
		private function backBtn_RollOut(event:MouseEvent):void {
			event.target.gotoAndStop(1);
		}
		private function backBtnHandler(event:MouseEvent):void {
			noAfter(-1)? null:gotoItem(currentPlaneIndex - 1);
			autoMoveAt = false;
		}
		//Handles clicking a Papervision Item
		private function ismClickHandle(e:InteractiveScene3DEvent):void {
			if (e.face3d.material.name) {
				var _clickTarget:Number=parseInt(e.face3d.material.name);
				gotoItem(_clickTarget);
			}

		}
		private function onMouseWheelEvent(event:MouseEvent):void {
			var tmp:int = event.delta/3;
			autoMoveAt = tmp<0? false:true;
			noAfter(tmp)? null:gotoItem(currentPlaneIndex + tmp);
		}
		
		function autoMove(e:TimerEvent):void {
			if(autoMoveAt) {
				autoMoveAt = noAfter()? !autoMoveAt:autoMoveAt;
			}else{
				autoMoveAt = noAfter(-1)? !autoMoveAt:autoMoveAt;
			}
			autoMoveAt?	gotoItem(currentPlaneIndex + 1):gotoItem(currentPlaneIndex - 1);
		}
		
		private function noAfter(n:int = 1):Boolean {
			if(currentPlaneIndex+n >= planes.length) {
				return true;
			}else if(currentPlaneIndex+n < 0){
				return true;
			}else {
				return false;
			}		
		}
	}
}