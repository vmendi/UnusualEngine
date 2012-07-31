package GameComponents
{
	import GameComponents.Desafiate.*;
	import GameComponents.Quiz.*;
	import GameComponents.ScreenSystem.*;
	
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
			mComponentClasses.addItem(Interaction as Class);
			mComponentClasses.addItem(DisableInteraction as Class);
			mComponentClasses.addItem(Bso as Class);
			mComponentClasses.addItem(Door as Class);
			mComponentClasses.addItem(FreeCameraController as Class);
			mComponentClasses.addItem(AStarMapSpace as Class);

			// Ahora los componentes por grupo
			RegisterScreenSystem();
			RegisterQuiz();
			RegisterDesafiate();
		}

		private function RegisterScreenSystem():void
		{
			mComponentClasses.addItem(ScreenNavigator as Class);
			mComponentClasses.addItem(Screen as Class);
			mComponentClasses.addItem(ScreenTab as Class);
		}

		private function RegisterQuiz() : void
		{
			mComponentClasses.addItem(QuizController as Class);
			mComponentClasses.addItem(QuizAnswer as Class);
			mComponentClasses.addItem(QuizBackground as Class);
			mComponentClasses.addItem(QuizScore as Class);
		}

		private function RegisterDesafiate() : void
		{
			mComponentClasses.addItem(SalaITPrimerPlano as Class);
			mComponentClasses.addItem(PuertaAscensor as Class);
			mComponentClasses.addItem(InitFase as Class);
			mComponentClasses.addItem(DesafiateInterface as Class);
			mComponentClasses.addItem(DesafiateCharacter as Class);
			mComponentClasses.addItem(Balloon as Class);
			mComponentClasses.addItem(WindowsPhone as Class);
			mComponentClasses.addItem(ElevatorConsole as Class);
			mComponentClasses.addItem(MainRecepcion as Class);
			mComponentClasses.addItem(MainSalaIT as Class);
			mComponentClasses.addItem(Recepcionista as Class);
			mComponentClasses.addItem(Television as Class);
			mComponentClasses.addItem(JefeIT as Class);
			mComponentClasses.addItem(JefazoIT as Class);
			mComponentClasses.addItem(TimeManagementNPC as Class);
			mComponentClasses.addItem(MiniGameManager as Class);
			mComponentClasses.addItem(TimeManagementMaster as Class);
			mComponentClasses.addItem(TimeManagementSlave as Class);
			mComponentClasses.addItem(TimeManagementShelf as Class);
			mComponentClasses.addItem(MainSalaTrabajo as Class);
			mComponentClasses.addItem(GameStatus as Class);
			mComponentClasses.addItem(Worker as Class);	
			mComponentClasses.addItem(MainCafeteria as Class);
			mComponentClasses.addItem(MesaCafeteria as Class);	
			mComponentClasses.addItem(MainConferencias as Class);
			mComponentClasses.addItem(MainDireccion as Class);
			mComponentClasses.addItem(JefazoDireccion as Class);
			mComponentClasses.addItem(VendingMachine as Class);
			mComponentClasses.addItem(Executive as Class);
			mComponentClasses.addItem(JefazoConferencias as Class);
			mComponentClasses.addItem(JefazoCafeteria as Class);
			mComponentClasses.addItem(Racks as Class);
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