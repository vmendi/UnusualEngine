package GameComponents.Desafiate
{
	import GameComponents.GameComponent;

	import Model.UpdateEvent;

	import gs.TweenLite;
	import gs.TweenMax;

	public class TimeManagementMaster extends GameComponent
	{
		public var TotalSeconds : int = 60*3;

		override public function OnStart() : void
		{
			mInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
		}

		public function TimeManagementStart(whichOne : String, withTimeCount : Boolean) : void
		{
			ConfigureSequence(whichOne);

			for each(var slave : TimeManagementSlave in mSlaves)
				slave.TimeManagementStart();

			mRemainingTime = TotalSeconds*1000;
			mTimeToEndCounting = withTimeCount;
			mNextTaskRemainingTime=-1;
			mNumTasksEnded = 0;
			mCurrentTaskIdx = -1;
			NextTask();
		}

		private function ConfigureSequence(whichOne : String):void
		{
			mSlaves = new Array();
			mScore = 0;

			if (whichOne == "SalaTrabajoTutorial01")
			{
				mSlaves.push(GetSlave("Worker03"));
				mSequence = [ { Task:"bug", Slave:"Worker03", FirstWait:10000, SecondWait:0,  ThirdWait:0, OnAbsTime:0, Points: 250, Message:null } ];
			}
			else if (whichOne == "SalaTrabajoTutorial02")
			{
				mSlaves.push(GetSlave("Worker07"));
				mSequence = [ { Task:"disk", Slave:"Worker07", FirstWait:10000, SecondWait:20000,  ThirdWait:0, OnAbsTime:0, Points: 250, Message:null }	];
			}
			else if (whichOne == "SalaTrabajoTutorial03")
			{
				mSlaves.push(GetSlave("Worker02"));
				mSequence = [ { Task:"tool", Slave:"Worker02", FirstWait:7000, SecondWait:14000, ThirdWait:7000, OnAbsTime:0, Points: 250, Message:null } ];
			}
			else if (whichOne == "SalaTrabajoFase01")
			{
				mSlaves.push(GetSlave("Worker01"));
				mSlaves.push(GetSlave("Worker02"));
				mSlaves.push(GetSlave("Worker03"));
				mSlaves.push(GetSlave("Worker04"));
				mSlaves.push(GetSlave("Worker05"));
				mSlaves.push(GetSlave("Worker06"));
				mSlaves.push(GetSlave("Worker07"));
				mSlaves.push(GetSlave("Worker08"));

				mSequence = [
								{ Task:"bug",  Slave:"Worker07", FirstWait:9000,  SecondWait:0,     ThirdWait:0,	 OnAbsTime:0,  Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker06", FirstWait:9000,  SecondWait:0,     ThirdWait:0,	 OnAbsTime:3,  Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker02", FirstWait:9000,  SecondWait:0,     ThirdWait:0,     OnAbsTime:6,  Points: 250,  Message:"Estos sistemas están\ntotalmente desprotegidos." },

								{ Task:"disk", Slave:"Worker03", FirstWait:8000,  SecondWait:14000, ThirdWait:0,     OnAbsTime:12, Points: 250,  Message:"Instalar software así\nes un error." },
								{ Task:"bug",  Slave:"Worker02", FirstWait:8000,  SecondWait:0,     ThirdWait:0,     OnAbsTime:17, Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker08", FirstWait:8000,  SecondWait:0,     ThirdWait:0,     OnAbsTime:19, Points: 250,  Message:null },

								{ Task:"tool", Slave:"Worker01", FirstWait:11000, SecondWait:7000,  ThirdWait:4000,  OnAbsTime:29, Points: 250,  Message:"Fallos, fallos y más fallos." },
								{ Task:"bug",  Slave:"Worker05", FirstWait:7000,  SecondWait:0,     ThirdWait:0,     OnAbsTime:30, Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker06", FirstWait:7000,  SecondWait:0,     ThirdWait:0,     OnAbsTime:31, Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker02", FirstWait:7000,  SecondWait:0,     ThirdWait:0,     OnAbsTime:35, Points: 250,  Message:"Más agujeros de seguridad, increíble." },

								{ Task:"bug",  Slave:"Worker04", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:46, Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker08", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:46, Points: 250,  Message:null  },
								{ Task:"tool", Slave:"Worker07", FirstWait:14000, SecondWait:9000,  ThirdWait:4000,  OnAbsTime:46, Points: 250,  Message:"No me lo puedo creer." },
								{ Task:"bug",  Slave:"Worker02", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:60, Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker06", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:60, Points: 250,  Message:null },

								{ Task:"bug",  Slave:"Worker01", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:70, Points: 250,  Message:"Esto no puede seguir así." },
								{ Task:"bug",  Slave:"Worker04", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:71, Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker05", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:72, Points: 250,  Message:"Esto no puede seguir así." },
								{ Task:"bug",  Slave:"Worker03", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:73, Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker02", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:74, Points: 250,  Message:"Esto no puede seguir así." },
								{ Task:"bug",  Slave:"Worker08", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:75, Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker06", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:76, Points: 250,  Message:"Esto no puede seguir así." },
								{ Task:"bug",  Slave:"Worker07", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:77, Points: 250,  Message:null },

								{ Task:"tool", Slave:"Worker02", FirstWait:14000, SecondWait:14000, ThirdWait:4000,  OnAbsTime:85, Points: 250,  Message:"Uff, no puedo más." },
								{ Task:"disk", Slave:"Worker03", FirstWait:8000,  SecondWait:14000, ThirdWait:0,     OnAbsTime:85, Points: 250,  Message:"Me va a dar algo." },

								{ Task:"bug",  Slave:"Worker04", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:105, Points: 250,  Message:null },
								{ Task:"disk", Slave:"Worker01", FirstWait:8000,  SecondWait:14000, ThirdWait:0,     OnAbsTime:107, Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker08", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:109, Points: 250,  Message:null },
								{ Task:"bug",  Slave:"Worker06", FirstWait:8000,  SecondWait:0,	    ThirdWait:0,	 OnAbsTime:111, Points: 250,  Message:null },

							];
			}
			else if (whichOne == "SalaIT")
			{
				mSlaves.push(GetSlave("Rack01"));
				mSlaves.push(GetSlave("Rack02"));
				mSlaves.push(GetSlave("Rack03"));
				mSlaves.push(GetSlave("Rack04"));
				mSlaves.push(GetSlave("RackConsola"));

				mSequence = [
 							  { Task:"bug",  Slave:"Rack01",       FirstWait:8000, SecondWait:0,	 ThirdWait:0,	  OnAbsTime:0,     Points: 250, Message:null },
							  { Task:"bug",  Slave:"Rack02",       FirstWait:8000, SecondWait:0,     ThirdWait:0,     OnAbsTime:0.2,   Points: 250, Message:null },
							  { Task:"bug",  Slave:"Rack03",       FirstWait:8000, SecondWait:0,     ThirdWait:0,	  OnAbsTime:0.4,   Points: 250, Message:null },
							  { Task:"bug",  Slave:"Rack04",       FirstWait:8000, SecondWait:0,     ThirdWait:0,	  OnAbsTime:0.6,   Points: 250, Message:null },
							  { Task:"bug",  Slave:"RackConsola",  FirstWait:8000, SecondWait:0,     ThirdWait:0,	  OnAbsTime:0.8,   Points: 250, Message:null },

							  { Task:"bug",  Slave:"Rack03",       FirstWait:3000, SecondWait:0,	 ThirdWait:0,	  OnAbsTime:9,     Points: 250, Message:null },
							  { Task:"bug",  Slave:"Rack02",       FirstWait:3000, SecondWait:0,	 ThirdWait:0,	  OnAbsTime:10,    Points: 250, Message:null },
							  { Task:"bug",  Slave:"Rack04",       FirstWait:3000, SecondWait:0,	 ThirdWait:0,	  OnAbsTime:11,    Points: 250, Message:null },
							  { Task:"bug",  Slave:"RackConsola",  FirstWait:3000, SecondWait:0,	 ThirdWait:0,	  OnAbsTime:12,    Points: 250, Message:null },
							  { Task:"disk", Slave:"Rack01",       FirstWait:3000, SecondWait:6000,  ThirdWait:0,     OnAbsTime:13,    Points: 250, Message:null },

							  { Task:"bug",  Slave:"Rack02",       FirstWait:3000, SecondWait:0,	 ThirdWait:0,	  OnAbsTime:20,    Points: 250, Message:null },
							  { Task:"bug",  Slave:"Rack04",       FirstWait:3000, SecondWait:0,	 ThirdWait:0,	  OnAbsTime:21,    Points: 250, Message:null },
							  { Task:"bug",  Slave:"RackConsola",  FirstWait:3000, SecondWait:0,     ThirdWait:0,	  OnAbsTime:22,    Points: 250, Message:null },
							  { Task:"bug",  Slave:"Rack01",       FirstWait:3000, SecondWait:0,	 ThirdWait:0,	  OnAbsTime:23,    Points: 250, Message:null },
							  { Task:"tool", Slave:"Rack03",       FirstWait:3000, SecondWait:4000,  ThirdWait:4000,  OnAbsTime:24,    Points: 250, Message:null },

							  { Task:"disk", Slave:"Rack01",       FirstWait:3000, SecondWait:3600, ThirdWait:0,      OnAbsTime:36,    Points: 250, Message:null },
							  { Task:"disk", Slave:"Rack04",       FirstWait:3000, SecondWait:4800, ThirdWait:0,      OnAbsTime:43,    Points: 250, Message:null },
							  { Task:"disk", Slave:"Rack02",       FirstWait:3000, SecondWait:4500, ThirdWait:0,      OnAbsTime:51,    Points: 250, Message:null },
							  { Task:"disk", Slave:"RackConsola",  FirstWait:2000, SecondWait:5200, ThirdWait:0,      OnAbsTime:59,    Points: 250, Message:null },
							  { Task:"disk", Slave:"Rack03",       FirstWait:2000, SecondWait:4500, ThirdWait:0,      OnAbsTime:67,    Points: 250, Message:null },

							  { Task:"tool", Slave:"Rack02",       FirstWait:4000, SecondWait:4500, ThirdWait:1000,   OnAbsTime:74,    Points: 250, Message:null },
							  { Task:"tool", Slave:"Rack03",       FirstWait:3000, SecondWait:4000, ThirdWait:1000,   OnAbsTime:84,    Points: 250, Message:null },
							  { Task:"tool", Slave:"Rack01",       FirstWait:3000, SecondWait:4500, ThirdWait:1000,   OnAbsTime:94,    Points: 250, Message:null },
							  { Task:"tool", Slave:"RackConsola",  FirstWait:3000, SecondWait:3500, ThirdWait:1000,   OnAbsTime:104,    Points: 250, Message:null },
							  { Task:"tool", Slave:"Rack04",       FirstWait:3000, SecondWait:3500, ThirdWait:1000,   OnAbsTime:114,    Points: 250, Message:null },

 							  { Task:"bug",  Slave:"Rack02",       FirstWait:8000, SecondWait:0,	 ThirdWait:0,	  OnAbsTime:125,     Points: 250, Message:null },
							];
			}
			else if (whichOne == "Conferencias")
			{
				mSlaves.push(GetSlave("ExecutiveNE01"));
				mSlaves.push(GetSlave("ExecutiveNE02"));
				mSlaves.push(GetSlave("ExecutiveNE03"));
				mSlaves.push(GetSlave("ExecutiveSW01"));
				mSlaves.push(GetSlave("ExecutiveSW02"));

				mSequence = [ { Task:"bug",  Slave:"ExecutiveSW01",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:0,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE01",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:3,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE03",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:6,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveSW02",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:9, Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE02",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:12, Points: 250, Message:null },

							  { Task:"disk", Slave:"ExecutiveNE01",  FirstWait:8000,   SecondWait:18000,  ThirdWait:0,    OnAbsTime:15, Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveSW01",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:18,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE02",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:21,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveSW02",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:24,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE03",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:27,  Points: 250, Message:null },

							  { Task:"bug",  Slave:"ExecutiveSW01",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:31,  Points: 250, Message:null },
							  { Task:"tool", Slave:"ExecutiveNE02",  FirstWait:8000,   SecondWait:10000,  ThirdWait:2000, OnAbsTime:34,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveSW02",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:37,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE03",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:40,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE01",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:43,  Points: 250, Message:null },

							  { Task:"disk", Slave:"ExecutiveSW01",  FirstWait:8000,   SecondWait:18000,  ThirdWait:0,    OnAbsTime:46,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE03",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:49,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE01",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:52,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE02",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:55,  Points: 250, Message:null },
							  { Task:"tool", Slave:"ExecutiveSW02",  FirstWait:8000,   SecondWait:10000,  ThirdWait:2000, OnAbsTime:58,  Points: 250, Message:null },

							  { Task:"bug",  Slave:"ExecutiveNE03",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:61,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE01",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:64,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE02",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:67,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE03",  FirstWait:8000,   SecondWait:0,	  ThirdWait:0,	  OnAbsTime:70,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveSW01",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:73,  Points: 250, Message:null },

							  { Task:"disk", Slave:"ExecutiveNE01",  FirstWait:8000,   SecondWait:18000,  ThirdWait:0,	  OnAbsTime:76,  Points: 250, Message:null },
							  { Task:"tool", Slave:"ExecutiveNE03",  FirstWait:8000,   SecondWait:10000,  ThirdWait:2000, OnAbsTime:79,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveSW01",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:82,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE02",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:85,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveSW02",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:88,  Points: 250, Message:null },

							  { Task:"bug",  Slave:"ExecutiveSW01",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:91,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE03",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:94,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveSW02",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:97,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE02",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:100,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE01",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:103,  Points: 250, Message:null },

							  { Task:"disk", Slave:"ExecutiveSW02",  FirstWait:8000,   SecondWait:18000,  ThirdWait:0,	  OnAbsTime:106,  Points: 250, Message:null },
							  { Task:"tool", Slave:"ExecutiveNE03",  FirstWait:8000,   SecondWait:10000,  ThirdWait:2000, OnAbsTime:109,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE01",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:112,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveSW01",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:115,  Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE02",  FirstWait:8000,   SecondWait:0,      ThirdWait:0,    OnAbsTime:118,  Points: 250, Message:null }

/* 							  { Task:"bug",  Slave:"ExecutiveSW01", FirstWait:11000, SecondWait:0,	   ThirdWait:0,	   OnAbsTime:22, Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE03", FirstWait:11000, SecondWait:0,	   ThirdWait:0,	   OnAbsTime:23, Points: 250, Message:null }, */



							  /*
							  { Task:"disk", Slave:"ExecutiveNE01", FirstWait:8000, SecondWait:16000, ThirdWait:0,    OnAbsTime:31, Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE02", FirstWait:8000, SecondWait:0,	  ThirdWait:0,	  OnAbsTime:35, Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE03", FirstWait:8000, SecondWait:0,	  ThirdWait:0,	  OnAbsTime:39, Points: 250, Message:null },
							  { Task:"tool",  Slave:"ExecutiveSW01", FirstWait:6000, SecondWait:10000, ThirdWait:4000,    OnAbsTime:40, Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE02", FirstWait:8000, SecondWait:0,	  ThirdWait:0,	  OnAbsTime:44, Points: 250, Message:null },
							  { Task:"bug",  Slave:"ExecutiveNE03", FirstWait:8000, SecondWait:0,	  ThirdWait:0,	  OnAbsTime:48, Points: 250, Message:null }
							  */
							];
			}

			if (mSequence.length > 0)
				mSequence[0].TimeToNext = 0;

			for (var c:int=1; c < mSequence.length; c++)
			{
				mSequence[c-1].TimeToNext = (mSequence[c].OnAbsTime - mSequence[c-1].OnAbsTime)*1000;
			}
		}

		public function TimeManagementStop() : void
		{
			for each(var slave : TimeManagementSlave in mSlaves)
				slave.TimeManagementStop();

			mInterface.ShowTime(false);
			mTimeToEndCounting = false;
			mNextTaskRemainingTime = -1;
			mSlaves = null;
			mSequence = null;
			TheGameModel.BroadcastMessage("OnTimeManagementEnd", mScore);
		}

		public function IsWaitingForTask() : Boolean
		{
			return mWaitingForTask;
		}

		private function NextTask() : void
		{
			if (mCurrentTaskIdx >= mSequence.length)
				throw "WTF";

			var numActiveTasks : int = mCurrentTaskIdx - mNumTasksEnded;

			if (numActiveTasks >= 4)
				mWaitingForTask = true;
			else
				RealNextTask();
		}

		private function RealNextTask():void
		{
			mWaitingForTask = false;
			mCurrentTaskIdx++;

			if (mCurrentTaskIdx < mSequence.length)
			{
				var obj : Object = mSequence[mCurrentTaskIdx];
				GetSlave(obj.Slave).SetTask(obj.Task, obj.FirstWait, obj.SecondWait, obj.ThirdWait, obj.Points, obj.Message);

				if (mCurrentTaskIdx <= mSequence.length-1)
					mNextTaskRemainingTime = obj.TimeToNext;
			}
		}

		public function OnTaskSuccess(params : Object) : void
		{
			mNumTasksEnded++;
			mScore += params.Points;

			if (mNumTasksEnded == mSequence.length)
			{
				TimeManagementStop();
			}
			else if(mWaitingForTask)
				RealNextTask();
		}

		public function OnTaskFailed(slave : TimeManagementSlave) : void
		{
			mNumTasksEnded++;

			if (mNumTasksEnded == mSequence.length)
			{
				TimeManagementStop();
			}
			else if(mWaitingForTask)
				RealNextTask();
		}

		private function GetSlave(name : String) : TimeManagementSlave
		{
			return TheGameModel.FindSceneObjectByName(name).TheAssetObject.FindGameComponentByShortName("TimeManagementSlave") as TimeManagementSlave;
		}

		override public function OnUpdate(event:UpdateEvent):void
		{
			if (mTimeToEndCounting)
			{
				mRemainingTime -= event.ElapsedTime;

				if (mRemainingTime <= 0)
				{
					TimeManagementStop();
				}
				else
				{
					mInterface.SetTime(mRemainingTime);
				}
			}

			if (mNextTaskRemainingTime != -1)
			{
				mNextTaskRemainingTime -= event.ElapsedTime;

				if (mNextTaskRemainingTime <= 0)
				{
					mNextTaskRemainingTime = -1;
					NextTask();
				}
			}
		}

		private var mNumTasksEnded : int = 0;
		private var mWaitingForTask : Boolean = false;
		private var mCurrentTaskIdx : int = -1;

		private var mRemainingTime : int = -1;				// Contador de tiempo global
		private var mTimeToEndCounting : Boolean = false;

		private var mNextTaskRemainingTime : int = -1;		// Contador de tiempo TimeToNext

		private var mSequence : Array;
		private var mSlaves : Array;
		private var mInterface : DesafiateInterface;
		private var mScore : int = 0;
	}
}