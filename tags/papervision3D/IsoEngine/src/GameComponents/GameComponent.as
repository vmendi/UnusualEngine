package GameComponents
{
	import Model.AssetObject;
	import Model.GameModel;
	import Model.SceneObject;
	import Model.UpdateEvent;

	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;

	import utils.KeyValueWrapper;
	import utils.Point3;
	import utils.reflection.ClassInfo;
	import utils.reflection.MethodInfo;

	[Bindable]
	/**
	 * Clase base para todos los componentes del juego.
	 */
	public dynamic class GameComponent extends EventDispatcher
	{
		virtual public function OnStart():void {}					/** El sistema llama al comenzar el juego. */
		virtual public function OnUpdate(event:UpdateEvent):void {} /** Actualización en cada fotograma. */
		virtual public function OnPause():void {}					/** El sistema llama para que el componente implemente la pause. */
		virtual public function OnResume():void {}				  	/** Y aquí para volver a jugar. */
		virtual public function OnStop():void {}					/** Se llama al parar el juego. */

		/** El componente Interaction informa a todos sus hermanos de que se ha producido una interacción con el personaje. */
		virtual public function OnCharacterInteraction():void {}

		/** El componente Interaction informa a todos sus hermanos de que se ha producido una interacción de ratón (click). */
		virtual public function OnClickInteraction():void {}


		/** IsoComponent: Acceso directo a uno de mis siblings importantes. */
		public function get TheIsoComponent() : IsoComponent { return mAssetObject.TheIsoComponent; }
		
		/** Render2DComponent: Acceso directo a uno de mis siblings importantes. */
		public function get TheRender2DComponent() : Render2DComponent { return mAssetObject.TheRender2DComponent; }

		/** AssetObject al que pertenece este componente. Siempre existe. */
		public function get TheAssetObject() : AssetObject { return mAssetObject; }

		/** SceneObject al que pertenece este componente. Será null si el componente no está en la escena. */
		public function get TheSceneObject() : SceneObject { return mAssetObject.TheSceneObject; }

		/** GameModel al que pertenece el componente */
		public function get TheGameModel() : GameModel
		{
			// Es posible que no tengamos todavía SceneObject, no estamos añadidos a la escena
			if (mAssetObject != null && mAssetObject.TheSceneObject != null)
				return mAssetObject.TheSceneObject.TheGameModel;
			else
				return null;
		}
		/** VisualObject asociado a nuestro SceneObject */
		public function get TheVisualObject() : MovieClip
		{
			if (mAssetObject != null && mAssetObject.TheSceneObject != null)
				return mAssetObject.TheSceneObject.TheVisualObject;
			else
				return null;
		}


		/** Nombre de la clase del componente, por ejemplo: GameComponents::Character */
		public function get FullName()  : String { return getQualifiedClassName(this); }
		/** Nombre corto de la clase del componente, quitando todos los namespaces */
		public function get ShortName() : String
		{
			var fullName : String = getQualifiedClassName(this);
			var start : int = fullName.lastIndexOf("::");

			return fullName.substr(start+2, fullName.length-start-2);
		}

		
		/** Nos hubiera gustado usar el constructor para esto, pero AS3 forzaría a definirlo tb en todos los hijos (Si usas
		 *  null como parámetro por defecto, no puedes instanciar un hijo con 1 parámetro).
		 *  Si assetObj == null, nos indican que se acaba de quitar el componente del AssetObj
		 * */
		virtual public function OnAddedToAssetObject(assetObj : AssetObject) : void 
		{
			if (mAssetObject != null && assetObj != null)
				throw "Cambio de AssetObject no permitido";

			if (mAssetObject != null && mAssetObject.TheSceneObject != null)
				RemoveFromScene();
			
			mAssetObject = assetObj;
			
			if (mAssetObject != null && mAssetObject.TheSceneObject != null)
				AddToScene();
		}
		
		/** Nos llaman para indicar que el SceneObject es valido y que hagamos lo que tengamos que hacer */
		virtual public function AddToScene() : void {}

		/** Nos llaman para indicar que este componente ya no está en el mapa */
		virtual public function RemoveFromScene() : void {}
		
		/**
		 * Devuelve un ArrayCollection con todas las variables dinámicas del GameComponent.
		 *
		 * Necesitamos esto porque las rows del DataGrid tienen que estar en una colección, y
		 * queremos que ésta colección sea las variables del objeto en formato (llave, valor)
		 */
		public function ReflectGameComponent() : ArrayCollection
		{
			var ret : ArrayCollection = new ArrayCollection();
			var clInfo : ClassInfo = new ClassInfo(this);

			for each(var property : MethodInfo in clInfo.properties)
			{
				// Nos deshacemos de las variables que no nos interesan (IsXXXXXXSerializable)
				var serializeIt : Boolean = true;
				var funcName : String = "Is"+property.name+"Serializable";
				var isSerializableFunc : MethodInfo = clInfo.method(funcName);

				if (isSerializableFunc != null)
					serializeIt = this[funcName]() as Boolean;

				if (property.writable && serializeIt)
				{
					// Envolvemos para que el set al Value nos escriba en nosotros
					ret.addItem(new KeyValueWrapper(this, property.name));
				}
			}

			var theSort : Sort = new Sort();
     		theSort.fields = [new SortField("ValueType",true), new SortField("Key",true, true) ]
       		ret.sort = theSort;
       		theSort.reverse();
       		ret.refresh();

			return ret;
		}

		/**
		 * Deserializa el componente a partir de un XML. Es aquí donde se decide nuestros tipos soportados.
		 */
		public function LoadFromXML(compXML:XML) : void
		{
			var clInfo : ClassInfo = new ClassInfo(this);

			for each(var attribXML : XML in compXML.child("Attrib"))
			{
				var attribName : String = attribXML.Name.toString();

				// Quizá el atributo haya desaparecido en esta nueva versión de la clase
				if (clInfo.property(attribName) != null)
				{
					// Convertimos aquí nuestros tipos y todo lo que no sea inicializable directamente desde String
					if (this[attribName] is Boolean)
						this[attribName] = (attribXML.Value.toString() == "true")? true : false;
					else
					if (this[attribName] is utils.Point3)
						this[attribName] = Point3.Point3FromString(attribXML.Value.toString());
					else
					if (this[attribName] is Point)
						this[attribName] = Point3.PointFromString(attribXML.Value.toString());
					else
						this[attribName] = attribXML.Value.toString();
				}
			}
		}

		public function GetXML() : XML
		{
			var className : String = getQualifiedClassName(this);
			var compXML : XML = <GameComponent><ClassName>{className}</ClassName></GameComponent>

			var props : ArrayCollection = ReflectGameComponent();

			for each(var prop : KeyValueWrapper in props)
			{
				if (prop.Value == null)
					throw "El valor de una propiedad no puede ser null al ir a grabar";

				// Grabamos el Value como una String
				var attribXML : XML = <Attrib>
									  	<Name>{prop.Key}</Name>
									  	<Value>{prop.Value.toString()}</Value>
									  </Attrib>
				compXML.appendChild(attribXML);
			}

			return compXML;
		}

		public function CloneByReflection(newOwner : AssetObject) : GameComponent
		{
			var compClass : Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
			var cloned : GameComponent = new compClass();
			cloned.OnAddedToAssetObject(newOwner);

			var properties : ArrayCollection = ReflectGameComponent();

			for each(var prop : KeyValueWrapper in properties)
			{
				cloned[prop.Key] = prop.Value;
			}

			return cloned;
		}

		protected var mAssetObject : AssetObject;
	}
}