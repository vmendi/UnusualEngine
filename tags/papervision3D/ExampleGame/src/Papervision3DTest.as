package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.view.BasicView;

	public class Papervision3DTest extends BasicView
	{
        [Embed(source="Embedded/Frame06.jpg")]
        [Bindable]
        public var Frame04:Class;
        [Embed(source="Embedded/Frame05.jpg")]
        [Bindable]
        public var Frame05:Class;
        
        [Embed(source="Embedded/Dream00.png")]
        [Bindable]
        public var Dream00:Class;
        [Embed(source="Embedded/Dream01.png")]
        [Bindable]
        public var Dream01:Class;
        [Embed(source="Embedded/Dream02.png")]
        [Bindable]
        public var Dream02:Class;
        [Embed(source="Embedded/Dream03.png")]
        [Bindable]
        public var Dream03:Class;              
        [Embed(source="Embedded/Dream04.png")]
        [Bindable]
        public var Dream04:Class;
        [Embed(source="Embedded/Dream05.png")]
        [Bindable]
        public var Dream05:Class;
        [Embed(source="Embedded/Dream06.png")]
        [Bindable]
        public var Dream06:Class;   
        [Embed(source="Embedded/Dream07.png")]
        [Bindable]
        public var Dream07:Class;
        [Embed(source="Embedded/Dream08.png")]
        [Bindable]
        public var Dream08:Class;   
        		
		public function Papervision3DTest()
		{	
			var myBitmap : Bitmap = new Frame05() as Bitmap;
			//myBitmap.height = myBitmap.stage.stageHeight - 5;
			addChild(myBitmap);
			//trace(myBitmap + ", " + stage.stageWidth);			
			/**
			 * Width and Height are set to 1, since scaleToStage is set to true, these will be overriden.
			 * We will not use interactivity and keep the default cameraType.
			 */
			super(1, 1, true, true);
					
			//Color the background of this basicview / helloworld instance black.
			opaqueBackground = 0xffffff;
			
			/*
			var url:String = "Assets/Zelda/csi.jpg";
 			var urlReq:URLRequest = new URLRequest(url);
			var ldr:Loader = new Loader();
			ldr.load(urlReq);
			addChild(ldr);
			*/
			
			//Create the materials and primitives.
			initScene();
			
			//Call the native startRendering function, to render every frame.
			startRendering();
		}
		
		/**
		 * initScene will create the needed primitives, and materials.
		 */
		protected function initScene():void
		{
			/*
			var myBitmap : Bitmap = new Dream00() as Bitmap;
			worldBitmapData = new BitmapData(256,256,true,0);
			worldBitmapData.draw(myBitmap); //, null, null, "alpha"); //(myBitmap);
			worldMaterial = new BitmapMaterial(worldBitmapData);
			*/
			
			var myBitmap : Bitmap;
			var myBitmapData : BitmapData;
			
			var myArray : Array = new Array();
			myArray[0] = new Dream00() as Bitmap;
			myArray[1] = new Dream01() as Bitmap;
			myArray[2] = new Dream02() as Bitmap;
			myArray[3] = new Dream03() as Bitmap;
			myArray[4] = new Dream04() as Bitmap;
			myArray[5] = new Dream05() as Bitmap;
			myArray[6] = new Dream06() as Bitmap;
			myArray[7] = new Dream07() as Bitmap;
			myArray[8] = new Dream08() as Bitmap;

			var length:int = 9;
			for(var i:int = 0; i < length; i++)
			{
				// Material
				
				myBitmap = myArray[i]; //new Dream01() as Bitmap;
				myBitmapData = new BitmapData(256,256,true,0);
				myBitmapData.draw(myBitmap);
				
				// Geometria
				
				//var planeMaterial:ColorMaterial = new ColorMaterial(0x00cc00);
				var planeMaterial:BitmapMaterial = new BitmapMaterial(myBitmapData);
				var plane : Plane = new Plane(planeMaterial, 250, 250);
				plane.x = 500 + Math.random() * 1000 - 500;
				plane.y = 500 + Math.random() * 1000;
				plane.z = Math.random() * 1000 - 500;
				plane.scale = Math.random() * 1 + 1;
 				//plane.roll(Math.random()*Math.PI);
 				//plane.rotationY = Math.random()*50;
				scene.addChild(plane);
				
				// Objeto plano
				
				var object : Object = new Object();
				object.plane = plane;
				object.vy = Math.round(Math.random() * 3) + 3;
				object.xinit = object.plane.x;
				object.scaleinit = object.plane.scale;
				object.contador = Math.random() * Math.PI;
				mPlanes.push(object);
			}

			/*
			org.ascollada.utils.Logger.VERBOSE = true;
			mTest3DS = new DAE();
			mTest3DS.load("Assets/Zelda/Skinned/Skinned.dae");
			//mTest3DS.load("Assets/Zelda/Prueba.dae");
			mTest3DS.addEventListener(FileLoadEvent.LOAD_COMPLETE, OnLoadComplete);
			scene.addChild(mTest3DS);			
			*/
			
			SetCameraPosition();
			
			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage);
		}
		
		private function OnAddedToStage(event:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
		    /*
		    mLastMouseX = stage.mouseX; // event.stageX;
		    mLastMouseY = stage.mouseY; //event.stageY;
		    */
		}
		
		private function OnMouseDown(event:MouseEvent):void
	    {
		      mDoRotation = true;
		      mLastMouseX = event.stageX;
		      mLastMouseY = event.stageY;
	    }

		private function OnMouseUp(event:MouseEvent):void
		{
      		mDoRotation = false;
    	}

		private function OnLoadComplete(event:Event):void
		{
			/*
			for each(var theChild : DisplayObject3D in mTest3DS.children)
			{
				var test : TriangleMesh3D = theChild as TriangleMesh3D;
				if (test != null)
					test.meshSort = DisplayObject3D.MESH_SORT_FAR;
			}
			*/
			
			//var theFoot : DisplayObject3D = mTest3DS.getChildByName("CMan0024-RightFoot", true);
			
			//theFoot.visible = false;
			/*
			for each(var mat : BitmapFileMaterial in mTest3DS.materials.materialsByName)
			{
				//mat.addEventListener(FileLoadEvent.LOAD_COMPLETE, Test01);
				mat.precise = false;
				mat.smooth = false;
			}
			*/
		}
		
		/*
		private function Test01(event:Event):void
		{
			var mat : MaterialObject3D = event.target as MaterialObject3D;			
		}
		*/
		
		override protected function onRenderTick(event:Event=null):void
		{
			UpdateCamera();
			UpdatePlanes();
			super.onRenderTick(event);
		}
		
		private function UpdateCamera():void
		{
      		if (mDoRotation)
      		{
		        var dPitch:Number = (mouseY - mLastMouseY) / 2;
		        var dYaw:Number = (mouseX - mLastMouseX) / 2;
		       
		        mCamPitch -= dPitch;
		        mCamYaw -= dYaw;
		       
		        if (mCamPitch <= 0) {
		          mCamPitch = 0.1;
		        } else if (mCamPitch >= 180) {
		          mCamPitch = 179.9;
		        }
		        
		        mLastMouseX = mouseX;
		        mLastMouseY = mouseY;
      		} 
      		
      		SetCameraPosition();
    	}
    	
    	private function SetCameraPosition():void
    	{
    		this.camera.position = new Number3D(0, 0, 1500);
    		this.camera.target.position = new Number3D(0, 1, -100);
    		this.camera.orbit(-80, 80, true); //this.camera.orbit(mCamPitch, mCamYaw, true);
    	}
    	
     	private function UpdatePlanes():void
    	{
			/*
			for each(var plane:Plane in scene.children)
			{
				plane.y += 5;
			}
			*/
			for (var i : Number = 0 ; i<mPlanes.length ; i++)
			{
				var ny : Number = mPlanes[i].plane.y + mPlanes[i].vy;
				if (ny > 2000)
				{
					mPlanes[i].plane.scale = 0;
					ny = 500;
				}
				mPlanes[i].contador += 0.05;
				mPlanes[i].plane.x = mPlanes[i].xinit + (Math.sin(mPlanes[i].contador) * 15);
				var ns : Number = mPlanes[i].plane.scale + 0.1;
				if (ns > mPlanes[i].scaleinit)
					ns = mPlanes[i].scaleinit;
				mPlanes[i].plane.scale = ns;
				mPlanes[i].plane.y = ny;
			}
      	}   	
    	
    	private var mCamPitch : Number = -90;
		private var mCamYaw : Number = 90;
		private var mDoRotation : Boolean;
		private var mLastMouseX : Number = 0;
		private var mLastMouseY : Number = 0;
		private var mPlanes : Array = new Array();
		
		protected var world:Sphere;
		protected var worldBitmapData:BitmapData;
		protected var worldMaterial:BitmapMaterial;

		//protected var mTest3DS : Max3DS;
		//protected var mTest3DS : DAE;
	}
}