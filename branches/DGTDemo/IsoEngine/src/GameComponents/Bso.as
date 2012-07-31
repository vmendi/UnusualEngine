package GameComponents
{
	import Model.UpdateEvent;
	
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	/**
	 *  CRAPFEST !!! TODO Hecho para que funcione en Desafiate, pero no contempla muchos casos
	 */
	public final class Bso extends GameComponent
	{
		public var PlayOnStart : Boolean = false;
		public var SurviveStop : Boolean = true;
		public var IgnoreGeneralPause : Boolean = true;
		
		
		public function Bso():void
		{
			mState = new BsoState();
			mState.mSong = "Assets/FirstSnow.mp3";
		}
		
		public function get Song() : String { return mState.mSong; }
		public function set Song(s : String) : void { mState.mSong = s; }
		

		override public function OnStart() : void
		{
			if (TheGameModel.GlobalGameState.hasOwnProperty("BsoState"))
			{
				mState = TheGameModel.GlobalGameState["BsoState"];
			}
			else
			{
				Initialize(mState.mSong);
	
	            if(PlayOnStart)
	            	Play();
	  		}
	  		
	  		// Para que el crossfade funcione durante la pausa
	  		TheGameModel.addEventListener("BeforeUpdate", OnProcessCrossfade);
		}
		
		private function Initialize(url : String) : void
		{
			Shutdown();

			mState.mSong = url;			
			mState.mSound = new Sound();
			
			// Como son de error, q se auto-remuevan cuando sea...
            mState.mSound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
            mState.mSound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
            
            mState.mPlaying = false;
            mState.mPaused = false;

			try
			{
				mState.mSound.load(new URLRequest(IsoEngine.BaseUrl+url));
			}
 			catch (error:Error)
 			{
 				trace("Exception loading BSO: " + mState.mSong);
                Shutdown();
            }
		}
		
		override public function OnPause():void
		{
			// TODO Hacer que funcione el crossfade con el IgnoreGeneralPause
			
			if (!IgnoreGeneralPause)
				Pause();
		}
		
		override public function OnResume():void
		{
			Resume();
		}
		
		private function Shutdown() : void
		{
			if (mState.mSound == null)
				return;

			Stop();

			mState.mSound = null;
			mState.mSoundControl = null;
			mState.mPlaying = false;
			mState.mPaused = false;
			
			// TODO .... Alternate...
		}
		
		override public function OnStop():void
		{
			if (!SurviveStop || TheGameModel.TheIsoEngine.IsEditor || TheGameModel.GlobalGameState == null)
				Shutdown();
			else
				TheGameModel.GlobalGameState.BsoState = mState;
  		}
  		
        private function securityErrorHandler(event:SecurityErrorEvent) : void
        {
        	trace("Exception loading BSO: " + event.text);

        	Shutdown();        	
        }

        private function ioErrorHandler(event:IOErrorEvent):void
        {
        	trace("Exception loading BSO: " + event.text);
        	
            Shutdown();
        }
        
        public function Play() : void
        {
        	// TODO .... Alternate...
        	
        	if (mState.mPlaying)
        		return;

			if (mState.mSound != null)
			{
				mState.mSoundControl = mState.mSound.play(0, 1000);
				mState.mPlaying = true;
				mState.mPaused = false;
			}
        }
        
        public function Stop() : void
        {
        	// TODO .... Alternate...
        	
			if (mState.mPlaying)
			{
				mState.mSoundControl.stop();
				mState.mPlaying = false;
				mState.mPaused = false;
			}
        }
        
        public function Pause() : void
        {
        	// TODO .... Alternate...
			
			if (mState.mPlaying)
			{
				mState.mSoundControl.stop();
				mState.mPaused = true;
   			}
        }
        
        public function Resume() : void
        {
        	// TODO .... Alternate...
        	
			if (mState.mPaused)
			{
				mState.mSoundControl = mState.mSound.play();
				mState.mPaused = false;
			}
        }
        
        public function CrossFadeTo(url : String) : void
        {
        	// TODO: De momento... O soportar n-way o se debería substituir la entrante?
        	if (mState.mAlternateSound != null)
        		return;

        	// Si no estamos tocando, ahora es el momento de inicializar con la nueva URL y empezar a tocar
        	if (!mState.mPlaying)
        	{
        		Initialize(url);
        		Play();
        	}
        	else 
        	if (mState.mSong != url)	// En caso de ser la misma cancion, seguimos por donde fueramos
        	{
        		mState.mAlternateSong = url;
	        	mState.mAlternateSound = new Sound();
	        	mState.mAlternateSound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
	        	mState.mAlternateSound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
	        	
	        	try	{
					mState.mAlternateSound.load(new URLRequest(IsoEngine.BaseUrl+url));
					
					mState.mCrossFadeInTransform = new SoundTransform(0);
		        	mState.mCrossFadeOutTransform = new SoundTransform(1);
		        	
		        	mState.mAlternateSoundControl = mState.mAlternateSound.play(0, 1000, mState.mCrossFadeInTransform);
		        	mState.mSoundControl.soundTransform = mState.mCrossFadeOutTransform;
				}
	 			catch (error:Error)
	 			{
	 				trace("Exception loading BSO: " + url);
	                Shutdown();
	            }
	        }
        }
        
        private function OnProcessCrossfade(event:UpdateEvent):void
        {
        	if (mState.mCrossFadeInTransform != null)
        	{
        		var currVolume : Number = mState.mCrossFadeInTransform.volume;
        		currVolume += event.ElapsedTime/1000 * 4;
        		
        		if (currVolume < 1)
        		{
        			mState.mCrossFadeInTransform = new SoundTransform(currVolume);
        			mState.mCrossFadeOutTransform = new SoundTransform(1-currVolume);
        			
        			mState.mAlternateSoundControl.soundTransform = mState.mCrossFadeInTransform;
					mState.mSoundControl.soundTransform = mState.mCrossFadeOutTransform;        			
        		}
        		else
        		{
        			mState.mCrossFadeInTransform = new SoundTransform(1);

        			mState.mSoundControl.stop();
        			
        			mState.mSong = mState.mAlternateSong;
        			mState.mSound = mState.mAlternateSound;
        			mState.mSoundControl = mState.mAlternateSoundControl;

        			mState.mAlternateSound = null;
        			mState.mAlternateSoundControl = null;
        			
        			mState.mCrossFadeInTransform = null;
        			mState.mCrossFadeOutTransform = null; 
        		}
        	}
        }
        
        private var mState : BsoState = null;
	}
	
}

import flash.net.URLRequest;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
	

internal class BsoState
{
	public var mSong : String;	
	public var mSound : Sound;
	public var mSoundControl : SoundChannel;
	
	// Crapfest...
	public var mAlternateSong : String;
	public var mAlternateSound : Sound;
	public var mAlternateSoundControl : SoundChannel;
	
	public var mCrossFadeInTransform : SoundTransform;
	public var mCrossFadeOutTransform : SoundTransform;
	
	public var mPlaying : Boolean;
	public var mPaused : Boolean;
}


