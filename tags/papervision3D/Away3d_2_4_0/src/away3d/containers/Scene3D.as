﻿package away3d.containers
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.traverse.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	
	import flash.events.*;
	import flash.utils.*;
    
	use namespace arcane;
	
    /**
    * The root container of all 3d objects in a single scene
    */
    public class Scene3D extends ObjectContainer3D
    {
    	/** @private */
        arcane function setId(object:Object3D):void
		{
			var i:int = 0;
			
			while(_objects[i])
				i++;
			
			_objects[i] = object;
			
			object._id = i;
		}
		/** @private */
        arcane function clearId(id:int):void
		{
			delete _objects[id];
		}
		/** @private */
        arcane function internalRemoveView(view:View3D):void
        {
        	view.removeEventListener(ViewEvent.UPDATE_SCENE, onUpdate);
        }
		/** @private */
        arcane function internalAddView(view:View3D):void
        {
        	view.addEventListener(ViewEvent.UPDATE_SCENE, onUpdate);
        }
     
    	private var _objects:Array = new Array();
        private var _currentView:View3D;
        private var _mesh:Mesh;
        private var _projtraverser:ProjectionTraverser = new ProjectionTraverser();
        private var _sessiontraverser:SessionTraverser = new SessionTraverser();
        private var _lighttraverser:LightTraverser = new LightTraverser();
        
        private function onUpdate(event:ViewEvent):void
        {
        	if (autoUpdate) {
        		if (_currentView && _currentView != event.view)
        			Debug.warning("Multiple views detected! Should consider switching to manual update");
        		
        		_currentView = event.view;
        		
        		update();
        	}
        }
        
        public var viewDictionary:Dictionary = new Dictionary(true);
        
		/**
		 * Traverser object for all custom <code>tick()</code> methods
		 * 
		 * @see away3d.core.base.Object3D#tick()
		 */
        public var tickTraverser:TickTraverser = new TickTraverser();
        
        /**
        * Library of updated 3d objects in the scene.
        */
        public var updatedObjects:Dictionary;
        
        /**
        * Library of updated sessions in the scene.
        */
        public var updatedSessions:Dictionary;
        
        /**
        * Library of  all meshes in the scene.
        */
        public var meshes:Dictionary;
        
        /**
        * Library of  all geometries in the scene.
        */
        public var geometries:Dictionary;
        
        /**
        * Defines whether scene events are automatically triggered by the view, or manually by <code>updateScene()</code>
        */
		public var autoUpdate:Boolean;
		
        /**
        * Defines whether scene is need to calculate light
        */
		public var updateLight:Boolean;
		
    	/**
    	 * Interface for physics (not implemented)
    	 */
        public var physics:IPhysicsScene;
        
		/**
		 * @inheritDoc
		 */
        public override function get sceneTransform():Matrix3D
        {
        	if (_transformDirty)
        		 _sceneTransformDirty = true;
			
        	if (_sceneTransformDirty)
        		notifySceneTransformChange();
        	
            return transform;
        }
    	
		/**
		 * Creates a new <code>Scene3D</code> object
		 * 
	    * @param	...initarray		An array of 3d objects to be added as children of the scene on instatiation. Can contain an initialisation object
		 */
        public function Scene3D(...initarray)
        {
            var init:Object;
            var childarray:Array = [];
            
            for each (var object:Object in initarray)
            	if (object is Object3D)
            		childarray.push(object);
            	else
            		init = object;
			
			//force ownCanvas and ownLights
			if (init) {
				init["ownCanvas"] = true;
				init["ownLights"] = true;
			} else {
				init = {ownCanvas:true, ownLights:true};
            }
            
            super(init);
			
			autoUpdate = ini.getBoolean("autoUpdate", true);
			updateLight = ini.getBoolean("updateLight", true);
			
            var ph:Object = ini.getObject("physics");
            if (ph is IPhysicsScene)
                physics = ph as IPhysicsScene;
            if (ph is Boolean)
                if (ph == true)
                    physics = null; // new RobPhysicsEngine();
            if (ph is Object)
                physics = null; // new RobPhysicsEngine(ph); // ph - init object
                
            for each (var child:Object3D in childarray)
                addChild(child);
        }
		
		/**
		 * Calling manually will update scene specific variables
		 */
        public function update():void
        {
        	//clear updated objects
        	updatedObjects = new Dictionary(true);
        	
        	//clear updated sessions
        	updatedSessions = new Dictionary(true);
    		
        	//clear meshes
        	meshes = new Dictionary(true);
        	
        	//clear geometries
        	geometries = new Dictionary(true);
        	
        	//traverse lights
			if(updateLight)
				traverse(_lighttraverser);
				
        	//execute projection traverser on each view
			var v:View3D;
			var vArr:Array;
			var g:Geometry;
			var o:Object;
			
        	for each(v in viewDictionary) {
	        	
				//update camera
	        	v.camera.update();
				
	        	//clear blockers
	        	v.blockers = new Dictionary(true);
	        	
	        	v.drawPrimitiveStore.blockerDictionary = new Dictionary(true);
	        	
	        	//clear camera view transforms
	        	v.cameraVarsStore.reset();
	        	
	        	//clear blockers
	        	v.blockerarray.clip = v.screenClipping;
	        	
	        	//traverse scene
        		_projtraverser.view = v;
				traverse(_projtraverser);
        	}
        	
        	//update meshes
        	for (o in meshes) {
        		_mesh = o as Mesh;
        		vArr = meshes[_mesh];
        		//update materials
        		for each (v in vArr)
		        	_mesh.updateMaterials(_mesh, v);
        	}
        	
        	//update geometries
        	for each (g in geometries)
        		g.updateElements();
        	
        	//traverse sessions
			traverse(_sessiontraverser);
        }
		
		/**
		 * Calling manually will update 3d objects that execute updates on their <code>tick()</code> methods.
		 * Uses the <code>TickTraverser</code> to traverse all tick methods in the scene.
		 * 
		 * @see	away3d.core.base.Object3D#tick()
		 * @see	away3d.core.traverse.TickTraverser
		 */
        public function updateTime(time:int = -1):void
        {
        	//set current time
            if (time == -1)
                time = getTimer();
            
            //traverser scene ticks
            tickTraverser.now = time;
            traverse(tickTraverser);
            
            
            if (physics != null)
                physics.updateTime(time);
        }
    }
}
