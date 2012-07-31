package GameView.Team
{
	import SoccerServerV1.TransferModel.vo.SoccerPlayer;
	
	import flash.events.EventDispatcher;

	public final class SkillPointAssignerPresentationModel extends EventDispatcher
	{
		public function SkillPointAssignerPresentationModel(soccerPlayer : SoccerPlayer, remaining : Number)
		{
			mRemainingSkillPoints = remaining;
			
			mWeight = soccerPlayer.Weight;
			mSliding = soccerPlayer.Sliding;
			mPower = soccerPlayer.Power;
			
			mStartingWeight = mWeight;
			mStartingSliding = mSliding;
			mStartingPower = mPower;
		}
		
		public function get DiffWeight() : Number { return mWeight - mStartingWeight; }
		public function get DiffSliding() : Number { return mSliding - mStartingSliding; }
		public function get DiffPower() : Number { return mPower - mStartingPower; }
		
		
		[Bindable(event="RemainingSkillPointsChanged")]
		public function get MaxWeight() : Number	{ return mWeight + mRemainingSkillPoints > 100? 100 : mWeight + mRemainingSkillPoints; }		
		[Bindable(event="RemainingSkillPointsChanged")]
		public function get MaxSliding() : Number	{ return mSliding + mRemainingSkillPoints > 100? 100 : mSliding + mRemainingSkillPoints; }		
		[Bindable(event="RemainingSkillPointsChanged")]
		public function get MaxPower() : Number		{ return mPower + mRemainingSkillPoints > 100? 100 : mPower + mRemainingSkillPoints; }
		
		[Bindable(event="RemainingSkillPointsChanged")]
		public function get MinWeight() : Number { return mStartingWeight; }
		[Bindable(event="RemainingSkillPointsChanged")]
		public function get MinSliding() : Number { return mStartingSliding; }
		[Bindable(event="RemainingSkillPointsChanged")]
		public function get MinPower() : Number { return mStartingPower; }

		[Bindable]
		public function get Weight() : Number { return mWeight; }
		public function set Weight(value:Number) : void 
		{ 
			var diff : Number = value - mWeight;
			if (diff > 0)
			{
				if (diff <= mRemainingSkillPoints)
				{
					mWeight = value;
					RemainingSkillPoints -= diff;
				}
			}
			else
			if (diff < 0)
			{
				if (value >= mStartingWeight)
				{
					mWeight = value;
					RemainingSkillPoints -= diff;
				}
			}
		}

		[Bindable]
		public function get Sliding():Number { return mSliding;	}
		public function set Sliding(value:Number):void
		{ 
			var diff : Number = value - mSliding; 
			if (diff > 0)
			{
				if (diff <= mRemainingSkillPoints)
				{
					mSliding = value;
					RemainingSkillPoints -= diff;
				}
			}
			else
			if (diff < 0)
			{
				if (value >= mStartingSliding)
				{
					mSliding = value;
					RemainingSkillPoints -= diff;
				}
			}
		}

		[Bindable]
		public function get Power():Number	{ return mPower; }
		public function set Power(value:Number):void 
		{ 
			var diff : Number = value - mPower; 
			if (diff > 0)
			{
				if (diff <= mRemainingSkillPoints)
				{
					mPower = value;
					RemainingSkillPoints -= diff;
				}
			}
			else
			if (diff < 0)
			{
				if (value >= mStartingPower)
				{
					mPower = value;
					RemainingSkillPoints -= diff;
				}
			}
		}

		[Bindable]
		public function get RemainingSkillPoints():Number	{ return mRemainingSkillPoints; }
		public function set RemainingSkillPoints(value:Number):void	
		{ 
			mRemainingSkillPoints = value;
			dispatchEvent(new Event("RemainingSkillPointsChanged"));
		}
		
		private var mStartingWeight : Number;
		private var mStartingSliding : Number;
		private var mStartingPower : Number;
		
		private var mRemainingSkillPoints : Number;
		
		private var mWeight : Number;
		private var mSliding : Number;
		private var mPower : Number;
	}
}