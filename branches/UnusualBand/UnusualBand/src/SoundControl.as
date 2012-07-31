package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;

	import utils.CentralLoader;

	public class SoundControl extends Sprite
	{
		public function SoundControl(song:String, centralLoader:CentralLoader):void
		{
			mSong = song;

			centralLoader.AddToQueue("Assets/UnusualBand/" + mSong + ".xml", false, "UnusualBand", OnXMLLoaded);
		}

		public function GetNotesInRange(startTime:Number, endTime:Number) : Array
		{
			var ret : Array = new Array;

			for (var c:int=0; c < mNotes.length; c++)
			{
				if (mNotes[c].Time >= startTime)
				{
					if (mNotes[c].Time < endTime)
						ret.push(mNotes[c]);
					else
						break;
				}
			}

			return ret;
		}

		private function OnXMLLoaded(loader:URLLoader):void
		{
			var xml : XML = XML(loader.data);

			mScoreSpeed = parseFloat(xml.ScoreSpeed.toString());

			for each(var note : XML in xml.child("Note"))
			{
				var newNote : Note = new Note();
				newNote.Time = parseFloat(note.Time.@val.toString());

				for each(var key : XML in note.child("Key"))
				{
					var numKey : int = parseInt(key.@num.toString());
					newNote.Keys.push(numKey);
				}

				mNotes.push(newNote);
			}

			SortNotes();
		}

		private function SortNotes():void
		{
			mNotes.sort(sortFunc);

			function sortFunc(a : Note, b : Note) : int
			{
				if (a.Time < b.Time)
					return -1;
				else
				if (a.Time > b.Time)
					return 1;
				return 0;
			}
		}

		public function StartPlaying(score3D : Score3D) : void
		{
			mScore3D = score3D;

			addEventListener(Event.ENTER_FRAME, OnEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, OnRemovedFromStage);

			mSound = new Sound();
			var req:URLRequest = new URLRequest("Assets/UnusualBand/" + mSong + ".mp3");
			mSound.load(req);

			mSoundChannel = mSound.play();
			mSoundChannel.addEventListener(Event.SOUND_COMPLETE, OnPlaybackComplete);

			//mSoundChannel.soundTransform = new SoundTransform(0);

			mTimeText = new TextField();
			addChild(mTimeText);
			mTimeText.y = 20;
			mTimeText.text = "0";
		}

		private function OnRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
		}


		private function OnEnterFrame(event:Event):void
		{
			var currentTime : int = mSoundChannel.position;
			var elapsedTime : int = currentTime - mLastTime;

			mScore3D.Update(currentTime);
			mLastTime = currentTime;

			mTimeText.text = currentTime.toString();
		}

		public function GetScoreSpeed() : Number
		{
			return mScoreSpeed;
		}


		private function OnPlaybackComplete(event:Event):void
		{
		}

		private var mSong : String;
		private var mNotes : Array = new Array;

		private var mSound : Sound;
		private var mSoundChannel : SoundChannel;

		private var mScore3D : Score3D;
		private var mLastTime : Number;
		private var mScoreSpeed : Number;

		private var mTimeText : TextField;
	}
}
