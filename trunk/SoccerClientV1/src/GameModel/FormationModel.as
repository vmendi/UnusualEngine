package GameModel
{
	import SoccerServerV1.MainService;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	public class FormationModel extends EventDispatcher
	{
		public function FormationModel(mainService : MainService, mainModel : MainGameModel)
		{
			mMainService = mainService;
			mMainModel = mainModel;
			
			mFormations = new ArrayCollection();
			
			mFormations.addItem( {Name:"3-2-2", 
									Points: [ new Point(173, 320),
											  new Point(73, 248),
											  new Point(173, 248),
									 		  new Point(273, 248),
											  new Point(128, 165),
											  new Point(218, 165),
											  new Point(103, 90),
											  new Point(243, 90) ] 
									} );
			mFormations.addItem( {Name:"3-3-1", 
									Points: [ new Point(173, 320),
											  new Point(73, 248),
											  new Point(173, 248),
											  new Point(273, 248),
											  new Point(73, 165),
											  new Point(173, 165),
											  new Point(273, 165),
											  new Point(173, 90) ] 
									} );
			mFormations.addItem( {Name:"4-1-2",			
									Points: [ new Point(173, 320),
											  new Point(52, 248),
											  new Point(132, 248),
											  new Point(214, 248),
											  new Point(296, 248),
											  new Point(173, 165),
											  new Point(103, 90),
											  new Point(243, 90) ] 
									} );
			mFormations.addItem( {Name:"4-2-1", 
									Points: [ new Point(173, 320),
											  new Point(52, 248),
											  new Point(132, 248),
											  new Point(214, 248),
											  new Point(296, 248),
											  new Point(128, 165),
											  new Point(218, 165),
											  new Point(173, 90) ] 
									 } );
			mFormations.addItem( {Name:"1-2-4", 
									Points: [ new Point(173, 320),
											  new Point(173, 248),
											  new Point(128, 165),
											  new Point(218, 165),
											  new Point(52, 90),
											  new Point(132, 90),
											  new Point(214, 90),
											  new Point(296, 90) ] 
									} );
			mFormations.addItem( {Name:"1-3-3",			
									Points: [ new Point(173, 320),
											  new Point(173, 248),
											  new Point(73, 165),
											  new Point(173, 165),
											  new Point(273, 165),										
											  new Point(73, 90),
											  new Point(173, 90),
											  new Point(273, 90) ] 	
									} );				
			mFormations.addItem( {Name:"1-4-2",			
									Points: [ new Point(173, 320),
											  new Point(173, 248),
											  new Point(52, 165),
											  new Point(132, 165),
											  new Point(214, 165),
											  new Point(296, 165),					
											  new Point(103, 90),
											  new Point(243, 90) ] 					
									} );			
			mFormations.addItem( {Name:"2-1-4",			
									Points: [ new Point(173, 320),
											  new Point(128, 248),
											  new Point(218, 248),
											  new Point(173, 165),
											  new Point(52, 90),
											  new Point(132, 90),
											  new Point(214, 90),
											  new Point(296, 90) ] 
									} );
			mFormations.addItem( {Name:"2-2-3", 
									Points: [ new Point(173, 320),
											  new Point(128, 248),
											  new Point(218, 248),
											  new Point(128, 165),
											  new Point(218, 165),
											  new Point(73, 90),
											  new Point(173, 90),
											  new Point(273, 90) ] 
									 } );
			mFormations.addItem( {Name:"2-3-2",
									Points: [ new Point(173, 320),
											  new Point(128, 248),
											  new Point(218, 248),
											  new Point(73, 165),
											  new Point(173, 165),
											  new Point(273, 165),
											  new Point(103, 90),
											  new Point(243, 90) ] 
									 } );
			mFormations.addItem( {Name:"2-4-1",			
									Points: [ new Point(173, 320),
											  new Point(128, 248),
											  new Point(218, 248),
											  new Point(52, 165),
											  new Point(132, 165),
											  new Point(214, 165),
											  new Point(296, 165),
											  new Point(173, 90) ] 
									} );			
			mFormations.addItem( {Name:"3-1-3",			
									Points: [ new Point(173, 320),
											  new Point(73, 248),
											  new Point(173, 248),
											  new Point(273, 248),
											  new Point(173, 165),
											  new Point(73, 90),
											  new Point(173, 90),
											  new Point(273, 90) ] 					
									} );
			
			BindingUtils.bindSetter(OnFormationChanged, mMainModel, ["TheTeamModel", "TheTeam", "Formation"]);
		}
		
		private function OnFormationChanged(e:String) : void
		{
			mFormationIdx = mFormations.getItemIndex(GetFormationByName(e));
			
			// Es posible que todavia no esté bien setteada en el modelo
			if (mFormationIdx == -1)
				mFormationIdx = 0;
			
			mAnyFormationIdx = mFormationIdx;
			
			dispatchEvent(new Event("FormationChanged"));
		}
		
		[Bindable(event="FormationChanged")]
		public function get Formation() : String 
		{ 		
			return mFormations[mFormationIdx].Name;
		}
		
		public function GetFormationByName(formationName : String) : Object
		{
			var ret : Object = null;
			
			for each(var form : Object in mFormations)
			{
				if (form.Name == formationName)
				{
					ret = form;
					break;
				}
			}
			return ret;
		}
		
		public function get Formations() : ArrayCollection
		{
			return mFormations;
		}
				
		[Bindable(event="FormationChanged")]
		public function get AnyFormation() : String
		{
			return mFormations[mAnyFormationIdx].Name;
		}
		
		[Bindable(event="FormationChanged")]
		public function get IsAnyFormationAvailable() : Boolean
		{
			if (mAnyFormationIdx <= GetLastAvailableFormationBasedOnXP())
				return true;
			return false;
		}
		
		public function GetFormationsTransformedToMatch() : Object
		{
			var ret : Object = new Object();
			
			for each(var form : Object in mFormations)
			{
				ret[form.Name] = new Array();
				
				for each(var p : Point in form.Points)
				{
					var transformed : Point = new Point( (363 - (p.y*1.02))*0.93, (p.x - 8)*1.333*0.93 );
					ret[form.Name].push(transformed);
				}
			}
			return ret;
		}
		
		private function GetLastAvailableFormationBasedOnXP() : int
		{
			if (mMainModel.TheTeamModel.TheTeam.XP <= 50 )
				return 3;
			else if (mMainModel.TheTeamModel.TheTeam.XP > 50 && mMainModel.TheTeamModel.TheTeam.XP <= 80)
				return 4;
			else if (mMainModel.TheTeamModel.TheTeam.XP > 80 && mMainModel.TheTeamModel.TheTeam.XP <= 110)
				return 5;
			else if (mMainModel.TheTeamModel.TheTeam.XP > 110 && mMainModel.TheTeamModel.TheTeam.XP <= 140)
				return 6;
			else if (mMainModel.TheTeamModel.TheTeam.XP > 140 && mMainModel.TheTeamModel.TheTeam.XP <= 170)
				return 7;
			else if (mMainModel.TheTeamModel.TheTeam.XP > 170 && mMainModel.TheTeamModel.TheTeam.XP <= 200)
				return 8;
			else if (mMainModel.TheTeamModel.TheTeam.XP > 200 && mMainModel.TheTeamModel.TheTeam.XP <= 230)
				return 9;
			else if (mMainModel.TheTeamModel.TheTeam.XP > 230 && mMainModel.TheTeamModel.TheTeam.XP <= 260)
				return 10;
			else if (mMainModel.TheTeamModel.TheTeam.XP > 260 && mMainModel.TheTeamModel.TheTeam.XP <= 290)
				return 11;
			else
				return mFormations.length-1;
		}
		
		public function NextAnyFormation() : void
		{
			if (mAnyFormationIdx < mFormations.length-1)
				mAnyFormationIdx++;
			else
				mAnyFormationIdx = 0;
			
			if (mAnyFormationIdx <= GetLastAvailableFormationBasedOnXP())
			{
				mFormationIdx = mAnyFormationIdx;
				mMainService.ChangeFormation(mFormations[mFormationIdx].Name, ErrorMessages.FaultResponder);
			}
			
			dispatchEvent(new Event("FormationChanged"));
		}
		
		public function PrevAnyFormation() : void
		{
			if (mAnyFormationIdx > 0)
				mAnyFormationIdx--;
			else
				mAnyFormationIdx = mFormations.length-1;
			
			if (mAnyFormationIdx <= GetLastAvailableFormationBasedOnXP())
			{
				mFormationIdx = mAnyFormationIdx;
				mMainService.ChangeFormation(mFormations[mFormationIdx].Name, ErrorMessages.FaultResponder);
			}
			
			dispatchEvent(new Event("FormationChanged"));
		}
		
		
		private var mFormations : ArrayCollection;
		private var mFormationIdx : int = 0;
		private var mAnyFormationIdx : int = 0;		
		
		private var mMainModel : MainGameModel;
		private var mMainService : MainService;
	}
}