package
{
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.math.Number3D;
	import away3d.core.render.Renderer;
	import away3d.lights.DirectionalLight3D;
	import away3d.materials.PhongColorMaterial;
	import away3d.materials.ShadingColorMaterial;
	import away3d.materials.TransformBitmapMaterial;
	import away3d.primitives.Cylinder;
	import away3d.primitives.Plane;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Score3D extends Sprite
	{
		public const TAB_HEIGHT : Number = 2700;
		public const TAB_WIDTH : Number = 750;
		public const INTERKEY_SPACE : Number = 150;
		public const FINAL_LINE_DISPLACEMENT : Number = 350;
		public const INITIAL_TIME_OFFSET : Number = 750;		// Para que no empiecen justo en la linea del fondo


		public function Score3D(soundControl : SoundControl)
		{
			mSoundControl = soundControl;
			mScoreSpeed = mSoundControl.GetScoreSpeed();

			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage);
		}

		public function Update(currentTime : Number):void
    	{
    		UpdateRotation();

			var elapsedTime : int = currentTime - mLastTime;
			var notesInRange : Array = mSoundControl.GetNotesInRange(currentTime - FINAL_LINE_DISPLACEMENT/mScoreSpeed,
																	 currentTime + TAB_HEIGHT/mScoreSpeed - INITIAL_TIME_OFFSET);
			for each(var note : Note in mDisplayingNotes)
			{
				if (notesInRange.indexOf(note) == -1)
				{
					mDisplayingNotes.splice(mDisplayingNotes.indexOf(note), 1);

					for each(var sph : Cylinder in note.KeysGeom)
						mScene.removeChild(sph);
				}
			}

			for each(note in notesInRange)
			{
				if (mDisplayingNotes.indexOf(note) == -1)
				{
					mDisplayingNotes.push(note);

					for each(var key : int in note.Keys)
					{
						var keyColor :  uint = GetKeyColor(key);
						var colorMat : ShadingColorMaterial = new ShadingColorMaterial(0x0, {color:0x0, ambient:0x0,
																ambient_brightness:0, diffuse:keyColor, diffuse_brightness:1.0});
						var geom : Cylinder = new Cylinder({material:colorMat, radius:50, height:30, segmentsH:1, segmentsW:12});
						mScene.addChild(geom);

						var posX : Number = (key+1)*INTERKEY_SPACE - TAB_WIDTH*0.5;
						geom.position = new Number3D(posX, 0, GetPosZForNote(note, currentTime));

						note.KeysGeom.push(geom);
					}
				}
			}

			var mat : TransformBitmapMaterial = mPlane.material as TransformBitmapMaterial;
			mat.offsetY += (mScoreSpeed * mBackgroundBitmap.height/TAB_HEIGHT) * elapsedTime;

			for each(note in mDisplayingNotes)
			{
				for each(var keyGeom : Cylinder in note.KeysGeom)
				{
					keyGeom.position = new Number3D(keyGeom.position.x, keyGeom.position.y, GetPosZForNote(note, currentTime));
				}
			}

			mView.render();

			mLastTime = currentTime;
    	}

    	private function GetKeyColor(key:int):uint
    	{
			if (key==0)
				return 0x00FF00;
			if (key==1)
				return 0xFF0000;
			if (key==2)
				return 0xFFFF00;
			return 0x0000FF;
    	}

    	private function GetPosZForNote(note:Note, currentTime:Number):Number
    	{
			return (note.Time - currentTime)*mScoreSpeed - TAB_HEIGHT*0.5 + (FINAL_LINE_DISPLACEMENT);
    	}


		private function InitScene():void
		{
			mBackgroundBitmap = new mBackgroundClass();

			//var planeMaterial:ColorMaterial = new ColorMaterial(0x00cc00);
			var planeMaterial:TransformBitmapMaterial = new TransformBitmapMaterial(mBackgroundBitmap.bitmapData, {repeat:true, scaleX:1.0, scaleY:1});
			planeMaterial.smooth = true;
			planeMaterial.precision = 3.0;
			//planeMaterial.debug = true;

			mPlane = new Plane({material:planeMaterial, width:TAB_WIDTH, height:TAB_HEIGHT, segmentsH:10, segmentsW:5});
			mPlane.x = 0
			mPlane.y = 0
			mPlane.z = 0;
			mPlane.ownCanvas = true;
			mPlane.pushback = true;
			mScene.addChild(mPlane);

			var finalLinePlane : Plane = new Plane({width:TAB_WIDTH, height:75, segmentsH:3, segmentsW:3});
			finalLinePlane.position = new Number3D(0, 5, -TAB_HEIGHT*0.5 + FINAL_LINE_DISPLACEMENT);
			finalLinePlane.ownCanvas = true;
			mScene.addChild(finalLinePlane);

			SetCameraPosition();
		}

		private function Init3D():void
		{
			// Create a new scene where all the 3D object will be rendered
			mScene = new Scene3D();

			// Create a new camera, passing some initialisation parameters
			mCamera = new Camera3D({zoom:20, focus:30, x:-100, y:-100, z:-500});

			// Create a new view that encapsulates the scene and the camera
			mView = new View3D({scene:mScene, camera:mCamera, renderer:Renderer.BASIC});

			var light : DirectionalLight3D = new DirectionalLight3D({ambient:0.0, diffuse:1.00, specular:0.0, color:0xFFFFFF});
			light.x = 10;
			light.y = 100;
	      	light.z = -75;
			mScene.addChild(light);

			// center the viewport to the middle of the stage
			mView.x = stage.stageWidth / 2;
			mView.y = stage.stageHeight / 2;
			addChild(mView);
		}

		private function OnAddedToStage(event:Event):void
		{
		    stage.align = StageAlign.TOP_LEFT;
      		stage.scaleMode = StageScaleMode.NO_SCALE;

			Init3D();
			InitScene();

		    mLastMouseX = stage.mouseX;
		    mLastMouseY = stage.mouseY;

		    stage.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
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

		private function UpdateRotation():void
		{
      		if (mDoRotation)
      		{
		        var dPitch:Number = (mouseY - mLastMouseY) / 15;
		        var dYaw:Number = (mouseX - mLastMouseX) / 15;

		        mPitch -= dPitch;
		        mYaw -= dYaw;

		        mLastMouseX = mouseX;
		        mLastMouseY = mouseY;
      		}

      		SetCameraPosition();
    	}

    	private function SetCameraPosition():void
    	{
    		mCamera.position = new Number3D(0, 500, -1500);
    		mCamera.lookAt(new Number3D(0, 0, 0));
    		mCamera.pitch(mPitch);
    		mCamera.yaw(mYaw);
    		//mPlane.rotationX = mPitch;
    		//mPlane.rotationY = mYaw;
    	}


    	private var mPitch : Number = 0;
		private var mYaw : Number = 0;
		private var mDoRotation : Boolean;
		private var mLastMouseX : Number = 0;
		private var mLastMouseY : Number = 0;

		private var mLastTime : Number = 0;
		private var mScoreSpeed : Number = 0.5;

		[Embed(source="Embedded/Trastes.jpg")]
        private var mBackgroundClass:Class;
        private var mBackgroundBitmap:Bitmap;

        private var mScene:Scene3D;
	    private var mCamera:Camera3D;
    	private var mView:View3D;
    	private var mPlane : Plane;

    	private var mSoundControl : SoundControl;
    	private var mDisplayingNotes : Array = new Array;
	}
}