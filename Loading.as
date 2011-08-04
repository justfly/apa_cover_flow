package
{
         import flash.display.*;
         import flash.events.*;
 
         public class Loading extends MovieClip
         {
                  private var objLoadingBar:LoadingBar = new LoadingBar();
                  private var objLoadingBarBorder:LoadingBarBorder = new LoadingBarBorder();
  
                  public function Loading() {}
   
                  public function HandleOpen():void
                  {   
                          objLoadingBar.x = 70;
                          objLoadingBar.y = 225;
                          objLoadingBar.width = 0;
   
                           addChild(objLoadingBar);
   
                           objLoadingBarBorder.x = 70;
                           objLoadingBarBorder.y = 225;
   
                           addChild(objLoadingBarBorder);
                  }
  
                  public function HandleProgress(objevent:ProgressEvent):void
                  {
                           var percent:Number = objevent.bytesLoaded * 260 / objevent.bytesTotal;
   
                           objLoadingBar.width = percent;
                  }
  
                  public function HandleComplete(objevent:Event):void
                  {
                           trace("Complete");
                           //removeChild(objLoadingBarBorder);
                           //removeChild(objLoadingBar);
                  }
         }
}