package Model
{
	import GameComponents.DefaultGameComponent;
	import GameComponents.GameComponent;
	import GameComponents.IsoComponent;
	import GameComponents.Render2DComponent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;

	import mx.collections.ArrayCollection;

	import utils.Point3;


	[Bindable]
	/**
	 * Objeto principal de librería.
	 *
	 * Sirve como template para crear SceneObjs. Lleva todos los GameComponents que dan propiedades y comportamiento al SceneObjs.
	 */
	public class AssetObject extends EventDispatcher
	{
		[Bindable(event="GameComponentsChanged")]
		public function get TheGameComponents() : ArrayCollection { return mComponents; }

		/** Acceso directo al componente por defecto. Todos los AssetObj lo tienen **/
		public function get TheDefaultGameComponent() : DefaultGameComponent { return mDefaultGameComponent; }

		/** Acceso directo al IsoComponent. */
		public function get TheIsoComponent() : IsoComponent { return FindGameComponentByShortName("IsoComponent") as IsoComponent; }

		/** Acceso directo al Render2DComponent. */
		public function get TheRender2DComponent() : Render2DComponent { return FindGameComponentByShortName("Render2DComponent") as Render2DComponent; }

		/** SceneObject al que este AssetObj puede pertenecer. Será null si el AssetObj no está en el escenario */
		public function get TheSceneObject() : SceneObject { return mSceneObject; }

		public function AddToScene(sceneObject : SceneObject) : void
		{
			mSceneObject = sceneObject;

			for each(var comp : GameComponent in mComponents)
			{
				comp.AddToScene();
			}
		}

		public function RemoveFromScene() : void
		{
			for each(var comp : GameComponent in mComponents)
			{
				comp.RemoveFromScene();
			}

			mSceneObject = null;
		}

		public function SetRenderingEnabled(enable : Boolean):void
		{
			for each(var comp : GameComponent in mComponents)
			{
				if (enable)
					comp.AddToScene();
				else
					comp.RemoveFromScene();
			}
		}

		/** Busca un componente */
		public function FindGameComponentByShortName(shortName : String) : GameComponent
		{
			var ret : GameComponent;

			for each(var comp : GameComponent in mComponents)
			{
				if (comp.ShortName == shortName)
				{
					ret = comp;
					break;
				}
			}

			return ret;
		}

		//
		// Clone profundo, copia bit a bit todo el AssetObject
		//
		public function GetDeepClone() : AssetObject
		{
			var myClone : AssetObject = new AssetObject(false);

			for each (var comp : GameComponent in mComponents)
			{
				var compClone : GameComponent = comp.CloneByReflection(myClone);

				if (compClone is DefaultGameComponent)
					myClone.mDefaultGameComponent = compClone as DefaultGameComponent;

				// Ya podemos añadirselo
				myClone.mComponents.addItem(compClone);
			}

			return myClone;
		}

		public function Overwrite(other : AssetObject) : void
		{
			if (other == this)
				return;

			mComponents.removeAll();

			for each (var comp : GameComponent in other.mComponents)
			{
				var compClone : GameComponent = comp.CloneByReflection(this);

				if (compClone is DefaultGameComponent)
					mDefaultGameComponent = compClone as DefaultGameComponent;

				mComponents.addItem(compClone);
			}
		}

		public function AssetObject(bCreateDefault : Boolean = true) : void
		{
			mComponents = new ArrayCollection;

			if (bCreateDefault)
			{
				mDefaultGameComponent = new DefaultGameComponent()
				mDefaultGameComponent.OnAddedToAssetObject(this);

				mComponents.addItem(mDefaultGameComponent);
			}
		}

		public function AddGameComponent(fullCompName : String) : GameComponent
		{
			if (HasComponent(fullCompName))
				throw "Componente ya añadido";

			var newComponent : GameComponent = new (getDefinitionByName(fullCompName) as Class);
			newComponent.OnAddedToAssetObject(this);

			mComponents.addItem(newComponent);

			dispatchEvent(new Event("GameComponentsChanged"));

			return newComponent;
		}

		public function RemoveGameComponent(fullCompName : String) : void
		{
			if (!HasComponent(fullCompName))
				throw "Componente no existente";

			for (var c:int = 0; c < mComponents.length; c++)
			{
				if (mComponents[c].FullName == fullCompName)
				{
					var toRemove : GameComponent = mComponents[c];
					mComponents.removeItemAt(c);
					toRemove.OnAddedToAssetObject(null);
					break;
				}
			}

			dispatchEvent(new Event("GameComponentsChanged"));
		}


		public function CanBeAddedToScene() : Boolean
		{
			var comp : Object = FindGameComponentByShortName("IsoComponent");
			if (comp != null)
				return true;

			comp = FindGameComponentByShortName("Render2DComponent");
			if (comp != null)
				return true;

			return false;
		}

		public function HasComponent(fullName : String):Boolean
		{
			for each(var comp : GameComponent in mComponents)
				if (fullName == comp.FullName)
					return true;
			return false;
		}

		public function LoadFromXML(xml : XML) : void
		{
			mComponents = new ArrayCollection();

			for each(var compXML : XML in xml.child("GameComponent"))
			{
				var className : String = compXML.ClassName.toString();
				var compClass : Class = getDefinitionByName(className) as Class;
				var component : GameComponent = new compClass();
				component.OnAddedToAssetObject(this);

				if (component is DefaultGameComponent)
					mDefaultGameComponent = component as DefaultGameComponent;

				this.mComponents.addItem(component);

				component.LoadFromXML(compXML);
			}
		}

		public function GetXML() : XML
		{
			var assetObjXML : XML = <AssetObject></AssetObject>

			for each(var component : GameComponent in mComponents)
			{
				var compXML : XML = component.GetXML();
				assetObjXML.appendChild(compXML);
			}

			return assetObjXML;
		}

		private var mComponents : ArrayCollection;
		private var mSceneObject : SceneObject;
		private var mDefaultGameComponent : DefaultGameComponent;
	}
}