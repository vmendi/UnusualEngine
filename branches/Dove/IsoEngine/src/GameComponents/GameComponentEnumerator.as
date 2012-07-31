package GameComponents
{
	import GameComponents.Dove.*;
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
			mComponentClasses.addItem(DisableInteraction as Class);
			mComponentClasses.addItem(FreeCameraController as Class);
			mComponentClasses.addItem(InfinitePreloader as Class);
			
			// Ahora los componentes por grupo
			RegisterScreenSystem();			
			RegisterDove();
		}
		
		private function RegisterScreenSystem():void
		{
			mComponentClasses.addItem(ScreenNavigator as Class);
			mComponentClasses.addItem(Screen as Class);
			mComponentClasses.addItem(ScreenTab as Class);
		}

		private function RegisterDove() : void
		{
			mComponentClasses.addItem(GameComponents.Dove.DoveMenuTest as Class);
			mComponentClasses.addItem(GameComponents.Dove.DoveMainMenu as Class);
			mComponentClasses.addItem(GameComponents.Dove.DoveMenuProducts as Class);
			mComponentClasses.addItem(GameComponents.Dove.DoveLogo as Class);
			mComponentClasses.addItem(GameComponents.Dove.DoveFormulario as Class);
			mComponentClasses.addItem(GameComponents.Dove.DoveTestEnd as Class);
			mComponentClasses.addItem(GameComponents.Dove.DoveMessage as Class);
			mComponentClasses.addItem(GameComponents.Dove.DoveHome as Class);
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