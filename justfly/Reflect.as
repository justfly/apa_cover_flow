 package justfly {
 import flash.events.*;
 import flash.utils.Timer;
 import flash.display.MovieClip;
 import flash.display.DisplayObject;
 import flash.display.BitmapData;
 import flash.display.Bitmap;
 import flash.geom.Matrix;
 import flash.display.GradientType;
 import flash.display.SpreadMethod;
 
 
 public class Reflect extends MovieClip
 {
  //static var for the version of this class
  private static var VERSION:String = "1.0";
 
  //reference to the movie clip we are reflecting
  private var mc:MovieClip;
  //the BitmapData object that will hold a visual copy of the mc
  private var mcBMP:BitmapData;
  //the BitmapData object that will hold the reflected image
  private var reflectionBMP:Bitmap;
  //the clip that will act as out gradient mask
  private var gradientMask_mc:MovieClip;
  //how often the reflection should update (if it is video or animated)
  private var timer1:Timer;
  //the size the reflection is allowed to reflect within
  private var bounds:Object;
  //the distance the reflection is vertically from the mc
  private var distance:Number = 0;
  
  private var alpha1:Number;
  private var ratio:Number ;
  private var updateTime:Number;
  private var reflectionDropoff:Number;
  private var matr:Matrix;
  private var reflectionBMPRef:DisplayObject;
  private var gradientMaskRef:DisplayObject;
  /*TODO:constructor
   *parameters：
   * -ref_mc:MovieClip(An instance of MovieClip which is to be  reflected.)
   * -alpha:int(The alpha level of the reflection clip.The value must between 0-100.)
   * -ratio:int(The ratio opaque color used in the gradient mask.The value must between 0-255.)
   * -distance:int(The distance the reflection starts from the bottom of the mc.)
   * -updateTime:int(The update time interval.)
   * -reflectionDropoff:int(The distance at which the reflection visually drops off at)：
  */
  public function Reflect(ref_mc:MovieClip, alpha:int=50, ratio:int=50, distance:int=0, updateTime:int=0, reflectionDropoff:int=1)
  {
   //the clip being reflected
   mc =ref_mc;
   //the alpha level of the reflection clip
   this.alpha1 = alpha/100;
   //the ratio opaque color used in the gradient mask
   this.ratio = ratio;
   //update time interval
   this.updateTime = updateTime;
   //the distance at which the reflection visually drops off at
   this.reflectionDropoff = reflectionDropoff;
   //the distance the reflection starts from the bottom of the mc
   this.distance = distance;
   
   //store width and height of the clip
   var mcHeight = mc.height;
   var mcWidth = mc.width;
   
   //store the bounds of the reflection
   bounds = new Object();
   bounds.width = mcWidth;
   bounds.height = mcHeight;
   
   //create the BitmapData that will hold a snapshot of the movie clip
   mcBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
   mcBMP.draw(mc);
   
   //create the BitmapData the will hold the reflection
   reflectionBMP = new Bitmap(mcBMP);
   //flip the reflection upside down
   reflectionBMP.scaleY = -1;
   //move the reflection to the bottom of the movie clip
   reflectionBMP.y = (bounds.height*2) + distance;
   
   //add the reflection to the movie clip's Display Stack
   reflectionBMPRef = mc.addChild(reflectionBMP);
   reflectionBMPRef.name = "reflectionBMP";
   
   //add a blank movie clip to hold our gradient mask
   gradientMaskRef = mc.addChild(new MovieClip());
   gradientMaskRef.name = "gradientMask_mc";
   
   //get a reference to the movie clip - cast the DisplayObject that is returned as a MovieClip
   gradientMask_mc = mc.getChildByName("gradientMask_mc") as MovieClip;
   //set the values for the gradient fill
   var fillType:String = GradientType.LINEAR;
    var colors:Array = [0xFFFFFF, 0xFFFFFF];
    var alphas:Array = [alpha1, 0];
     var ratios:Array = [0, ratio];
   var spreadMethod:String = SpreadMethod.PAD;
   //create the Matrix and create the gradient box
     matr = new Matrix();
     //set the height of the Matrix used for the gradient mask
   var matrixHeight:Number;
   if (reflectionDropoff<=0) {
    matrixHeight = bounds.height;
   } else {
    matrixHeight = bounds.height/reflectionDropoff;
   }
   matr.createGradientBox(bounds.width, matrixHeight, Math.PI/2, 0, 0);
     //create the gradient fill
   gradientMask_mc.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
      gradientMask_mc.graphics.drawRect(0,0,bounds.width,bounds.height);
   //position the mask over the reflection clip   
   gradientMask_mc.y = mc.getChildByName("reflectionBMP").y - mc.getChildByName("reflectionBMP").height;
   //cache clip as a bitmap so that the gradient mask will function
   gradientMask_mc.cacheAsBitmap = true;
   mc.getChildByName("reflectionBMP").cacheAsBitmap = true;
   //set the mask for the reflection as the gradient mask
   mc.getChildByName("reflectionBMP").mask = gradientMask_mc;
   
   //if we are updating the reflection for a video or animation do so here
   if(updateTime > -1)
   { 
    timer1 = new Timer(updateTime,0);
    timer1.addEventListener(TimerEvent.TIMER,timer1_c);
    timer1.start();
   }
  }
  
  private function timer1_c(event:TimerEvent):void{
   update(mc);
  }
  
  private function update(mc):void {
   //updates the reflection to visually match the movie clip
   mcBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
   mcBMP.draw(mc);
   reflectionBMP.bitmapData = mcBMP;
  }
  
  public function setBounds(w:int,h:int):void{
   //allows the user to set the area that the reflection is allowed
   //this is useful for clips that move within themselves
   bounds.width = w;
   bounds.height = h;
   gradientMask_mc.width = bounds.width;
   redrawBMP(mc);
   
  }
  public function setDistance(d:int):void{
   //allows the user to set the distance
   distance = d;
   reflectionBMP.y = (bounds.height*2) + distance;
   gradientMask_mc.y = mc.getChildByName("reflectionBMP").y - mc.getChildByName("reflectionBMP").height;
  }
  public function setAlpha(a:int):void{
   alpha1 = a/100;
            gradientMask_mc.graphics.clear();
   gradientMask_mc.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [alpha1, 0], [0, ratio], matr, SpreadMethod.PAD); 
      gradientMask_mc.graphics.drawRect(0,0,bounds.width,bounds.height);
   gradientMask_mc.cacheAsBitmap = true;
  }
  
  public function setRatio(r:int):void{
    ratio =  r;
            gradientMask_mc.graphics.clear();
   gradientMask_mc.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [alpha1, 0], [0, ratio], matr, SpreadMethod.PAD); 
      gradientMask_mc.graphics.drawRect(0,0,bounds.width,bounds.height);
   gradientMask_mc.cacheAsBitmap = true;
  }
  
  public function setUpdateTime(t:int):void
  {
   updateTime=t;
   timer1.delay=t;
  }
  
  public function setReflectionDropoff(r:int):void
  {
   reflectionDropoff=r;
   var matrixHeight:Number;
   if (reflectionDropoff<=0) {
    matrixHeight = bounds.height;
   } else {
    matrixHeight = bounds.height/reflectionDropoff;
   }
   matr.createGradientBox(bounds.width, matrixHeight, Math.PI/2, 0, 0);
   gradientMask_mc.graphics.clear();
   gradientMask_mc.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [alpha1, 0], [0, ratio], matr, SpreadMethod.PAD); 
      gradientMask_mc.graphics.drawRect(0,0,bounds.width,bounds.height);
   gradientMask_mc.cacheAsBitmap = true;
  }
  
  public function redrawBMP(mc:MovieClip):void
  {
   // redraws the bitmap reflection
   mcBMP.dispose();
   mcBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
   mcBMP.draw(mc);
  }
  
  
  public function destroy():void{
   //provides a method to remove the reflection
   mc.removeChild(mc.getChildByName("reflectionBMP"));
   reflectionBMP = null;
   mcBMP.dispose();
   timer1.stop();
   mc.removeChild(mc.getChildByName("gradientMask_mc"));
  }
 }
}