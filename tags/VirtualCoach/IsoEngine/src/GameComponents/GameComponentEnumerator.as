package GameComponents
{
	import GameComponents.Desafiate.*;
	import GameComponents.FerrariShell.*;
	import GameComponents.Insignia.*;
	import GameComponents.IsoRacer.*;
	import GameComponents.MmoGirl.*;
	import GameComponents.Multiplayer.*;
	import GameComponents.PlanetWars.*;
	import GameComponents.Platforms.*;
	import GameComponents.Quiz.*;
	import GameComponents.ScreenSystem.*;
	import GameComponents.Video.*;
	
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;


	/**
	 * Implementación concreta de enumeración de componentes. Aquí es donde hay que añadir los nuevos
	 * componentes a medida que se van creando.
	 */
	public final class GameComponentEnumerator implements IGameComponentEnumerator
	{
		public function GameComponentEnumerator()
		{
			// Aquí es donde añadimos las Classes de los componentes
			mComponentClasses.addItem(DefaultGameComponent as Class);
			mComponentClasses.addItem(TestGameComponent as Class);
			mComponentClasses.addItem(IsoComponent as Class);
			mComponentClasses.addItem(Render2DComponent as Class);
			mComponentClasses.addItem(Character as Class);
			mComponentClasses.addItem(NPC as Class);
			mComponentClasses.addItem(Interaction as Class);
			mComponentClasses.addItem(DisableInteraction as Class);
			mComponentClasses.addItem(Bso as Class);
			mComponentClasses.addItem(Door as Class);
			mComponentClasses.addItem(FreeCameraController as Class);
			mComponentClasses.addItem(AStarMapSpace as Class);

			// Ahora los componentes por grupo
			RegisterScreenSystem();
			RegisterVideo();
			RegisterQuiz();
			RegisterOpelInsignia();
			RegisterMmoGirl();
			RegisterPlatformsTest();
			RegisterMultiplayer();
			RegisterPlanetWars();
			RegisterIsoRacer();
			RegisterFerrariShell();
			RegisterDesafiate();
		}
		
		private function RegisterScreenSystem():void
		{
			mComponentClasses.addItem(ScreenNavigator as Class);
			mComponentClasses.addItem(Screen as Class);
			mComponentClasses.addItem(ScreenTab as Class);
		}

		private function RegisterVideo() : void
		{
			mComponentClasses.addItem(VideoController as Class);
			mComponentClasses.addItem(VideoContent as Class);
			mComponentClasses.addItem(VideoGizmo as Class);
		}

		private function RegisterMmoGirl() : void
		{
			mComponentClasses.addItem(PuestoHelados as Class);
			mComponentClasses.addItem(CityPuestoGlobos as Class);
			mComponentClasses.addItem(HallPuertaAscensor as Class);
			mComponentClasses.addItem(MmoTeleport as Class);
			mComponentClasses.addItem(CityChicaBolera as Class);
			mComponentClasses.addItem(ParquePuestoLimonada as Class);
		}

		private function RegisterPlatformsTest() : void
		{
			mComponentClasses.addItem(Platform as Class);
			mComponentClasses.addItem(PlatformCharacter as Class);
		}

		private function RegisterOpelInsignia() : void
		{
			mComponentClasses.addItem(OIGestureController as Class);
			mComponentClasses.addItem(OITutorialMain as Class);
			mComponentClasses.addItem(OIChica as Class);
			mComponentClasses.addItem(OIGameMain as Class);
			mComponentClasses.addItem(OIInterface as Class);
			mComponentClasses.addItem(OITrail as Class);
			mComponentClasses.addItem(OIBall as Class);
			mComponentClasses.addItem(OIOst as Class);
			mComponentClasses.addItem(OIQuizInterface as Class);
		}

		private function RegisterQuiz() : void
		{
			mComponentClasses.addItem(QuizController as Class);
			mComponentClasses.addItem(QuizAnswer as Class);
			mComponentClasses.addItem(QuizBackground as Class);
			mComponentClasses.addItem(QuizScore as Class);
		}

		private function RegisterMultiplayer() : void
		{
			mComponentClasses.addItem(ServerConnect as Class);
			mComponentClasses.addItem(CharacterSync as Class);
			mComponentClasses.addItem(RoomSync as Class);
		}

		private function RegisterPlanetWars() : void
		{
			mComponentClasses.addItem(PlanetWarsMain as Class);
			mComponentClasses.addItem(PlanetWarsServerConnect as Class);
			mComponentClasses.addItem(Planet as Class);
			mComponentClasses.addItem(Terrain as Class);
			mComponentClasses.addItem(City as Class);
			mComponentClasses.addItem(Player as Class);
			mComponentClasses.addItem(NetworkSync as Class);
			mComponentClasses.addItem(NetworkSyncManager as Class);
			mComponentClasses.addItem(CityInteraction as Class);
		}

		private function RegisterIsoRacer() : void
		{
			mComponentClasses.addItem(Vehicle as Class);
			mComponentClasses.addItem(Waypoint as Class);
			mComponentClasses.addItem(WaypointSequence as Class);
			mComponentClasses.addItem(Navigator as Class);
		}
		
		private function RegisterFerrariShell() : void
		{
			mComponentClasses.addItem(MenuMain as Class);
			mComponentClasses.addItem(CarSelection as Class);
			mComponentClasses.addItem(TrackSelection as Class);
			mComponentClasses.addItem(RaceMain as Class);
			mComponentClasses.addItem(RaceControl as Class);
			mComponentClasses.addItem(FinalPopup as Class);
			mComponentClasses.addItem(InstruccionesPopup as Class);
			mComponentClasses.addItem(Ranking as Class);
			mComponentClasses.addItem(FerrariTabbedMenu as Class);
			mComponentClasses.addItem(Ganadores as Class);
		}
				
		private function RegisterDesafiate() : void
		{
			mComponentClasses.addItem(SalaITCharacter as Class);
			mComponentClasses.addItem(SalaITPuerta01 as Class);
			mComponentClasses.addItem(SalaITPuerta02 as Class);
			mComponentClasses.addItem(SalaITRack as Class);
			mComponentClasses.addItem(SalaITPuertaAscensor as Class);
			mComponentClasses.addItem(SalaITPrimerPlano as Class);
			mComponentClasses.addItem(SalaITMesaOrdenador as Class);
		}
		
		public function GetComponentClasses() : ArrayCollection
		{
			return mComponentClasses;
		}

		public function GetComponentsDescription() : ArrayCollection
		{
			var ret : ArrayCollection = new ArrayCollection;

			for each (var cl : Class in mComponentClasses)
			{
				ret.addItem(GetDescription(cl));
			}

			return ret;
		}

		public function GetDescription(cl : Class) : Object
		{
			var name : String = getQualifiedClassName(cl);
			var idxShortNameStart : int = name.lastIndexOf("::");
			var shortName : String = name;
			if (idxShortNameStart != -1)
				shortName = name.substr(idxShortNameStart+2, name.length-idxShortNameStart-2);

			var middleNamespace : String = "";
			var middleStart : int = name.indexOf(".")+1;

			if (middleStart != 0)
			{
				var middleEnd : int = idxShortNameStart;
				middleNamespace = name.substr(middleStart, middleEnd-middleStart);
			}

			return {TheClass:cl, FullName:name, ShortName:shortName, MiddleNamespace:middleNamespace};
		}

		private var mComponentClasses : ArrayCollection = new ArrayCollection;
	}
}