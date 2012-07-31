﻿package away3d.core.base
{
    import away3d.animators.data.*;
    import away3d.animators.skin.*;
    import away3d.arcane;
    import away3d.containers.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    import away3d.loaders.data.MaterialData;
    import away3d.materials.*;
    
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    
    use namespace arcane;
    
	/**
	 * Dispatched when the bounding dimensions of the geometry object change.
	 * 
	 * @eventType away3d.events.GeometryEvent
	 */
	[Event(name="dimensionsChanged",type="away3d.events.GeometryEvent")]
    
	/**
	 * Dispatched when a sequence of animations completes.
	 * 
	 * @eventType away3d.events.AnimationEvent
	 */
	[Event(name="sequenceDone",type="away3d.events.AnimationEvent")]
    
	/**
	 * Dispatched when a single animation in a sequence completes.
	 * 
	 * @eventType away3d.events.AnimationEvent
	 */
	[Event(name="cycle",type="away3d.events.AnimationEvent")]
	
    /**
    * 3d object containing face and segment elements 
    */
    public class Geometry extends EventDispatcher
    {
    	/** @private */
		arcane var commands:Array = [];
		/** @private */
		arcane var indices:Array = [];
		/** @private */
		arcane var startIndices:Array = [];
        /** @private */
		arcane var faceVOs:Array = [];
        /** @private */
		arcane var segmentVOs:Array = [];
        /** @private */
		arcane var billboardVOs:Array = [];
		 /** @private */
		arcane function get vertexDirty():Boolean
		{
			var rtn:Boolean = false;
			
			for each (var vertex:Vertex in vertices)
        		if (vertex.getVertexDirty())
        			rtn = true;
        	
        	return rtn;
		}
		/** @private */
        arcane function getFacesByVertex(vertex:Vertex):Array
        {
            if (_vertfacesDirty)
                findVertFaces();

            return _vertfaces[vertex];
        }
		/** @private */
		arcane function getVertexNormal(vertex:Vertex):Number3D
        {
        	if (_vertfacesDirty)
                findVertFaces();
            
            if (_vertnormalsDirty)
                findVertNormals();
            
            return _vertnormals[vertex];
        }
		/** @private */
        public function neighbour01(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            
            return _neighbour01[face];
        }
		/** @private */
        public function neighbour12(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            
            return _neighbour12[face];
        }
		/** @private */
        public function neighbour20(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            
            return _neighbour20[face];
        }
		/** @private */
        arcane function notifyDimensionsChange():void
        {
            if (_dispatchedDimensionsChange || !hasEventListener(GeometryEvent.DIMENSIONS_CHANGED))
                return;
            
            if (!_dimensionschanged)
                _dimensionschanged = new GeometryEvent(GeometryEvent.DIMENSIONS_CHANGED, this);
                
            dispatchEvent(_dimensionschanged);
            
            _dispatchedDimensionsChange = true;
        }
		/** @private */
		arcane function addMaterial(element:Element, material:IMaterial):void
		{
			//detect if materialData exists
			if (!(_materialData = materialDictionary[material])) {
				_materialData = materialDictionary[material] = new MaterialData();
				
				//set material property of materialData
				_materialData.material = material;
				
				//add update listener
				material.addOnMaterialUpdate(onMaterialUpdate);
			}
			
			//check if element is added to elements array
			if (_materialData.elements.indexOf(element) == -1)
				_materialData.elements.push(element);
		}
		/** @private */
		arcane function removeMaterial(element:Element, material:IMaterial):void
		{
			//detect if materialData exists
			if ((_materialData = materialDictionary[material])) {
				//check if element is removed from elements array
				if ((_index = _materialData.elements.indexOf(element)) != -1)
					_materialData.elements.splice(_index, 1);
				
				//check if elements array is empty
				if (!_materialData.elements.length) {
					delete materialDictionary[material];
					
					//remove update listener
					material.removeOnMaterialUpdate(onMaterialUpdate);
				}
			}
		}
		
        private var _faces:Array = [];
        private var _faceVO:FaceVO;
        private var _segments:Array = [];
        private var _segmentVO:SegmentVO;
        private var _billboards:Array = [];
        private var _billboardVO:BillboardVO;
        private var _vertices:Array = [];
        private var _processed:Dictionary;
        private var _vertex:Vertex;
        private var _element:Element;
        private var _element_vertices:Array;
        private var _element_commands:Array;
        private var _verticesDirty:Boolean = true;
        private var _dispatchedDimensionsChange:Boolean;
        private var _dimensionschanged:GeometryEvent;
        private var _neighboursDirty:Boolean = true;
        private var _neighbour01:Dictionary;
        private var _neighbour12:Dictionary;
        private var _neighbour20:Dictionary;
        private var _vertfacesDirty:Boolean = true;
        private var _vertfaces:Dictionary;
        private var _vertnormalsDirty:Boolean = true;
		private var _vertnormals:Dictionary;
        private var _fNormal:Number3D;
        private var _fAngle:Number;
        private var _fVectors:Array;
        private var clonedvertices:Dictionary;
        private var clonedskinvertices:Dictionary;
        private var clonedskincontrollers:Dictionary;
        private var cloneduvs:Dictionary;
        private var _frame:int;
        private var _animation:Animation;
		private var _animationgroup:AnimationGroup;
        private var _sequencedone:AnimationEvent;
        private var _cycle:AnimationEvent;
		private var _activePrefix:String;
		private var _materialData:MaterialData;
		private var _index:int;
		private var _quarterFacesTotal:int = 0;
		
        private function addElement(element:Element):void
        {
            _verticesDirty = true;
            
            element.addOnVertexChange(onVertexChange);
            element.addOnVertexValueChange(onVertexValueChange);
			element.addOnMappingChange(onMappingChange);
			
			element.parent = this;
			
            notifyDimensionsChange();
        }
        
        private function removeElement(element:Element):void
        {
            _verticesDirty = true;
			
            element.removeOnVertexChange(onVertexChange);
            element.removeOnVertexValueChange(onVertexValueChange);
			element.notifyMappingChange();
            element.removeOnMappingChange(onMappingChange);
            
            notifyDimensionsChange();
        }
		
        private function findVertFaces():void
        {
            _vertfaces = new Dictionary();
            
            for each (var face:Face in faces)
            {
                var v0:Vertex = face.v0;
                if (_vertfaces[v0] == null)
                    _vertfaces[v0] = [face];
                else
                    _vertfaces[v0].push(face);
                var v1:Vertex = face.v1;
                if (_vertfaces[v1] == null)
                    _vertfaces[v1] = [face];
                else
                    _vertfaces[v1].push(face);
                var v2:Vertex = face.v2;
                if (_vertfaces[v2] == null)
                    _vertfaces[v2] = [face];
                else
                    _vertfaces[v2].push(face);
            }
            
            _vertfacesDirty = false;
            _vertnormalsDirty = true;
        }
        
        private function findVertNormals():void
        {
            _vertnormals = new Dictionary();
            
            for each (var v:Vertex in vertices)
            {
            	var vF:Array = _vertfaces[v];
            	var nX:Number = 0;
            	var nY:Number = 0;
            	var nZ:Number = 0;
            	for each (var f:Face in vF)
            	{
	            	_fNormal = f.normal;
	            	_fVectors = [];
	            	var _f_vertices:Array = f.vertices;
	            	for each (var fV:Vertex in _f_vertices)
	            		if (fV != v)
	            			_fVectors.push(new Number3D(fV.x - v.x, fV.y - v.y, fV.z - v.z, true));
	            	
	            	_fAngle = Math.acos((_fVectors[0] as Number3D).dot(_fVectors[1] as Number3D));
            		nX += _fNormal.x*_fAngle;
            		nY += _fNormal.y*_fAngle;
            		nZ += _fNormal.z*_fAngle;
            	}
            	var vertNormal:Number3D = new Number3D(nX, nY, nZ);
            	vertNormal.normalize();
            	_vertnormals[v] = vertNormal;
            }            
            
            _vertnormalsDirty = false;    
        }
        
		private function onMaterialUpdate(event:MaterialEvent):void
		{
			dispatchEvent(event);
		}
        
        private function onMappingChange(event:ElementEvent):void
        {
        	dispatchEvent(event);
        }

        private function onVertexChange(event:ElementEvent):void
        {
            _verticesDirty = true;
			
			if (event.element is Face) {
				(event.element as Face).normalDirty = true;
				_vertfacesDirty = true;
			}
			
            notifyDimensionsChange();
        }

        private function onVertexValueChange(event:ElementEvent):void
        {
        	if (event.element is Face)
				(event.element as Face).normalDirty = true;
			
            notifyDimensionsChange();
        }
        
        private function cloneFrame(frame:Frame):Frame
        {
        	var result:Frame = new Frame();
        	var _frame_vertexpositions:Array = frame.vertexpositions;
        	for each(var vertexPosition:VertexPosition in _frame_vertexpositions)
        		result.vertexpositions.push(cloneVertexPosition(vertexPosition));
        	
        	return result;
        }
        
		private function cloneVertexPosition(vertexPosition:VertexPosition):VertexPosition
        {
        	var result:VertexPosition = new VertexPosition(cloneVertex(vertexPosition.vertex));
        	
        	result.x = vertexPosition.x;
        	result.y = vertexPosition.y;
        	result.z = vertexPosition.z;
        	
        	return result;
        }
        
		private function cloneVertex(vertex:Vertex):Vertex
        {
            var result:Vertex = clonedvertices[vertex];
            
            if (result == null) {
                result = vertex.clone();
                result.extra = (vertex.extra is IClonable) ? (vertex.extra as IClonable).clone() : vertex.extra;
                clonedvertices[vertex] = result;
            }
            
            return result;
        }
        
        private function cloneSkinVertex(skinVertex:SkinVertex):SkinVertex
        {
        	var result:SkinVertex = clonedskinvertices[skinVertex];
        	
        	if (result == null) {
	        	result = new SkinVertex(cloneVertex(skinVertex.skinnedVertex));
	        	result.weights = skinVertex.weights.concat();
	        	
	        	var _skinVertex_controllers:Array = skinVertex.controllers;
				for each (var skinController:SkinController in _skinVertex_controllers)
					result.controllers.push(cloneSkinController(skinController));
					
				clonedskinvertices[skinVertex] = result;
        	}
        	
        	return result;
        }
        
        private function cloneSkinController(skinController:SkinController):SkinController
        {
        	var result:SkinController = clonedskincontrollers[skinController];
        	
        	if (result == null) {
        		result = new SkinController();
	            result.name = skinController.name;
	            result.bindMatrix = skinController.bindMatrix;
        		clonedskincontrollers[skinController] = result;
        	}
        	
        	return result;
        }
        
        private function cloneUV(uv:UV):UV
        {
            if (uv == null)
                return null;

            var result:UV = cloneduvs[uv];
            
            if (result == null) {
                result = new UV(uv._u, uv._v);
                cloneduvs[uv] = result;
            }
            
            return result;
        }
        
        private function updatePlaySequence(e:AnimationEvent):void
		{
			var _length:int = _animationgroup.playlist.length;
			if(_length == 0 ){
				_animation.removeEventListener(AnimationEvent.SEQUENCE_UPDATE, updatePlaySequence);
				_animation.sequenceEvent = false;
				
				if (hasSequenceEvent) {
					if (_sequencedone == null)
						_sequencedone = new AnimationEvent(AnimationEvent.SEQUENCE_DONE, null);
					
					dispatchEvent(_sequencedone);
				}
				if(_animationgroup.loopLast)  _animation.start();
			} else{
			
				if(_length == 1 ){
					loop = _animationgroup.loopLast;
					//trace("loop last = "+ _animation.loop);
					_animationgroup.playlist[0].loop = _animationgroup.loopLast;
					//trace("_animationgroup.playlist[0].loop = "+ _animationgroup.playlist[0].loop);
				}
				play(_animationgroup.playlist.shift());
			}
			 
		}
		
        /**
         * Instance of the Init object used to hold and parse default property values
         * specified by the initialiser object in the 3d object constructor.
         */
		protected var ini:Init;
        
        /**
        * Reference to the root heirarchy of bone controllers for a skin.
        */
        public var rootBone:Bone;
        
    	/**
    	 * Array of vertices used in a skin.
    	 */
        public var skinVertices:Array;
        
        /**
        * Array of controller objects used to bind vertices with joints in a skin.
        */
        public var skinControllers:Array;
                
        /**
        * A dictionary containing all frames of the geometry.
        */
        public var frames:Dictionary;
        
        /**
        * A dictionary containing all frame names of the geometry.
        */
        public var framenames:Dictionary;
        
        /**
        * An dictionary containing all the materials included in the geometry.
        */
        public var materialDictionary:Dictionary = new Dictionary(true);
        
        /**
        * An dictionary containing associations between cloned elements.
        */
        public var cloneElementDictionary:Dictionary = new Dictionary();
        
        /**
        * A graphics element in charge of managing the distribution of vector drawing commands into faces.
        */
        public var graphics:Graphics3D = new Graphics3D();
        
		/**
		 * Indicates the current frame of animation
		 */
        public function get frame():int
        {
            return _animation.frame;
        }
        
        public function set frame(value:int):void
        {
            if (_animation.frame == value)
                return;
			_frame = value;
            _animation.frame = value;
            frames[value].adjust(1);
        }
        
		/**
		 * Determines the frames per second at which the animation will run.
		 */
		public function get fps():int
		{
			return _animation.fps;
		}
		
		public function set fps(value:int):void
		{
			_animation.fps = (value >= 1)? value : 1;
		}
		
		/**
		 * Determines whether the animation will loop.
		 */
		public function get loop():Boolean
		{
			return _animation.loop;
		}
		
		public function set loop(val:Boolean):void
		{
			_animation.loop = val;
		}
		
		/**
		 * Determines how many frames a transition between the actual and the next animationSequence should interpolate together.
		 * must be higher or equal to 1. Default = 10;
		 */
		public function get transitionValue():Number
		{
			return _animation.transitionValue;
		}
        
		public function set transitionValue(val:Number):void
		{
			_animation.transitionValue = val;
		}
		
        /**
         * Determines whether the animation will smooth motion (interpolate) between frames.
         */
		public function get smooth():Boolean
		{
			return _animation.smooth;
		}
		
		public function set smooth(val:Boolean):void
		{
			_animation.smooth = val;
		}
		
		/**
		 * Indicates whether the animation is currently running.
		 */
		public function get isRunning():Boolean
		{
			return (_animation != null)? _animation.isRunning  : false;
		}
        
		/**
		 * Indicates whether the animation has a cycle event listener
		 */
		public function get hasCycleEvent():Boolean
        {
			return _animation.hasEventListener(AnimationEvent.CYCLE);
        }
        
		/**
		 * Indicates whether the animation has a sequencedone event listener
		 */
		public function get hasSequenceEvent():Boolean
        {
			return hasEventListener(AnimationEvent.SEQUENCE_DONE);
        }
        
		/**
		* return the prefix of the active animation.
		*/
		public function get activePrefix():String
		{
			return _activePrefix;
		}
		
		/**
		 * Returns the total number of times the geometry has been quartered.
		 */
        public function get quarterFacesTotal():int
        {
	        return _quarterFacesTotal
        }
        
		/**
		 * Returns an array of the faces contained in the geometry object.
		 */
        public function get faces():Array
        {
            return _faces;
        }
		
		/**
		 * Returns an array of the segments contained in the geometry object.
		 */
        public function get segments():Array
        {
            return _segments;
        }
		
		/**
		 * Returns an array of the billboards contained in the geometry object.
		 */
        public function get billboards():Array
        {
            return _billboards;
        }
        
		/**
		 * Returns an array of all elements contained in the geometry object.
		 */
        public function get elements():Array
        {
            return _faces.concat(_segments, _billboards);
        }
        
        /**
        * Returns an array of all vertices contained in the geometry object
        */
        public function get vertices():Array
        {
            if (_verticesDirty) {
                _verticesDirty = false;
                
                _vertices.length = 0;
                indices.length = 0;
                commands.length = 0;
                startIndices.length = 0;
                faceVOs.length = 0;
                segmentVOs.length = 0;
                billboardVOs.length = 0;
                _processed = new Dictionary(true);
                
                for each (_element in elements) {
                	if (_element.visible && _element.vertices.length > 0) {
	                    _element_vertices = _element.vertices;
	                    _element_commands = _element.commands;
	                    
	                    startIndices[startIndices.length] = indices.length;
	                    
                		if (_element is Face) {
                			_faceVO = (_element as Face).faceVO;
                			faceVOs[faceVOs.length] = _faceVO;
                		} else if (_element is Segment) {
                			_segmentVO = (_element as Segment).segmentVO;
                			segmentVOs[segmentVOs.length] = _segmentVO;
                		} else if (_element is Billboard) {
                			_billboardVO = (_element as Billboard).billboardVO;
                			billboardVOs[billboardVOs.length] = _billboardVO;
                		}
                		
                		_index = 0;
                		
	                    while (_index < _element_vertices.length) {
	                    	
	                    	_vertex = _element_vertices[_index];
	                    	
	                        if (!_processed[_vertex]) {
	                            _vertices[_vertices.length] = _vertex;
	                            indices[indices.length] = (_processed[_vertex] = _vertices.length) - 1;
	                        } else {
	                        	indices[indices.length] = _processed[_vertex] - 1;
	                        }
	                        
	                        commands[commands.length] = _element_commands[_index];
	                        
	                        _index++;
	                    }
	                }
                }
                
                startIndices[startIndices.length] = indices.length;
            }
            
            return _vertices;
        }
        
        /**
		 * Creates a new <code>Geometry</code> object.
         */        
        public function Geometry():void
    	{
    		graphics.geometry = this;
    	}
    	
		/**
		 * Adds a face object to the geometry object.
		 * 
		 * @param	face	The face object to be added.
		 */
        public function addFace(face:Face):void
        {
            addElement(face);
			
			if (face.material)
				addMaterial(face, face.material);
			
			_vertfacesDirty = true;
			
			if(face.v0)
				face.v0.geometry = this;
			
			if(face.v1)
				face.v1.geometry = this;
			
			if(face.v2)
				face.v2.geometry = this;
			
            _faces.push(face);
        }
		
		/**
		 * Removes a face object from the geometry object.
		 * 
		 * @param	face	The face object to be removed.
		 */
        public function removeFace(face:Face):void
        {
            var index:int = _faces.indexOf(face);
            if (index == -1)
                return;
			
            removeElement(face);
			
			if (face.material)
				removeMaterial(face, face.material);
			
            _vertfacesDirty = true;
			
			face.v0.geometry = null;
			face.v1.geometry = null;
			face.v2.geometry = null;
            
            _faces.splice(index, 1);
        }
		
		/**
		 * Adds a segment object to the geometry object.
		 * 
		 * @param	segment	The segment object to be added.
		 */
        public function addSegment(segment:Segment):void
        {
            addElement(segment);
			
			if (segment.material)
				addMaterial(segment, segment.material);
			
			segment.v0.geometry = this;
			segment.v1.geometry = this;
			
            _segments.push(segment);
        }
		
		/**
		 * Removes a segment object to the geometry object.
		 * 
		 * @param	segment	The segment object to be removed.
		 */
        public function removeSegment(segment:Segment):void
        {
            var index:int = _segments.indexOf(segment);
            if (index == -1)
                return;
			
            removeElement(segment);
			
			if (segment.material)
				removeMaterial(segment, segment.material);
			
			segment.v0.geometry = null;
			segment.v1.geometry = null;
			
            _segments.splice(index, 1);
        }
		
		/**
		 * Adds a billboard object to the geometry object.
		 * 
		 * @param	billboard	The segment object to be added.
		 */
        public function addBillboard(billboard:Billboard):void
        {
            addElement(billboard);
			
			if (billboard.material)
				addMaterial(billboard, billboard.material);
			
			billboard.vertex.geometry = this;
			
            _billboards.push(billboard);
        }
		
		/**
		 * Removes a segment object to the geometry object.
		 * 
		 * @param	segment	The segment object to be removed.
		 */
        public function removeBillboard(billboard:Billboard):void
        {
            var index:int = _billboards.indexOf(billboard);
            if (index == -1)
                return;
			
            removeElement(billboard);
			
			if (billboard.material)
				removeMaterial(billboard, billboard.material);
			
			billboard.vertex.geometry = null;
			
            _billboards.splice(index, 1);
        }
        
		/**
		 * Inverts the geometry of all face objects.
		 * 
		 * @see away3d.code.base.Face#invert()
		 */
        public function invertFaces():void
        {
            for each (var face:Face in _faces)
                face.invert();
        }
		
		/**
		* Divides all faces objects of a Mesh into 4 equal sized face objects.
		* Used to segment a geometry in order to reduce affine persepective distortion.
		* 
		* @see away3d.primitives.SkyBox
		*/
        public function quarterFaces():void
        {
        	_quarterFacesTotal++;
        	
            var medians:Dictionary = new Dictionary();
            for each (var face:Face in _faces.concat([]))
               quarterFace(face, medians);
        }
		/**
		* Divides a face object into 4 equal sized face objects.
		* 
		* @param	face	The face to split in 4 equal faces.
		*/
		public function quarterFace(face:Face, medians:Dictionary = null):void
        {
			if(medians == null)
				medians = new Dictionary();
			
			var v0:Vertex = face.v0;
			var v1:Vertex = face.v1;
			var v2:Vertex = face.v2;
			
			if (medians[v0] == null)
				medians[v0] = new Dictionary();
			if (medians[v1] == null)
				medians[v1] = new Dictionary();
			if (medians[v2] == null)
				medians[v2] = new Dictionary();
			
			var v01:Vertex = medians[v0][v1];
			if (v01 == null) {
				v01 = Vertex.median(v0, v1);
				medians[v0][v1] = v01;
				medians[v1][v0] = v01;
			}
			
			var v12:Vertex = medians[v1][v2];
			if (v12 == null) {
				v12 = Vertex.median(v1, v2);
				medians[v1][v2] = v12;
				medians[v2][v1] = v12;
			}
			
			var v20:Vertex = medians[v2][v0];
			if (v20 == null) {
				v20 = Vertex.median(v2, v0);
				medians[v2][v0] = v20;
				medians[v0][v2] = v20;
			}
			
			var uv0:UV = face.uv0;
			var uv1:UV = face.uv1;
			var uv2:UV = face.uv2;
			var uv01:UV = UV.median(uv0, uv1);
			var uv12:UV = UV.median(uv1, uv2);
			var uv20:UV = UV.median(uv2, uv0);
			var material:ITriangleMaterial = face.material;
			
			//remove old face
			removeFace(face);
			
			//add new faces
			addFace(new Face(v0, v01, v20, material, uv0, uv01, uv20));
			addFace(new Face(v01, v1, v12, material, uv01, uv1, uv12));
			addFace(new Face(v20, v12, v2, material, uv20, uv12, uv2));
			addFace(new Face(v12, v20, v01, material, uv12, uv20, uv01));
		}
		
		/**
		* Divides all faces objects of a Mesh into 3 face objects.
		* 
		*/
        public function triFaces():void
        {
            for each (var face:Face in _faces.concat([]))
            {
               triFace(face);
            }
        }
		/**
		* Divides a face object into 3 face objects.
		* 
		* @param	face	The face to split in 3 faces.
		*/
		public function triFace(face:Face):void
        {
			var v0:Vertex = face.v0;
			var v1:Vertex = face.v1;
			var v2:Vertex = face.v2;
			
			var vc:Vertex = new Vertex((face.v0.x+face.v1.x+face.v2.x)/3, (face.v0.y+face.v1.y+face.v2.y)/3, (face.v0.z+face.v1.z+face.v2.z)/3);
			
			var uv0:UV = face.uv0;
			var uv1:UV = face.uv1;
			var uv2:UV = face.uv2;
			
			var uvc:UV = new UV((uv0.u+uv1.u+uv2.u)/3, (uv0.v+uv1.v+uv2.v)/3);
			
			var material:ITriangleMaterial = face.material;
			removeFace(face);
			
			addFace(new Face(v0, v1, vc, material, uv0, uv1, uvc));
			addFace(new Face(vc, v1, v2, material, uvc, uv1, uv2));
			addFace(new Face(v0, vc, v2,  material, uv0, uvc, uv2));
		}
		
		/**
		* Divides all faces objects of a Mesh into 2 face objects.
		* 
		* @param	side	The side of the faces to split in two. 0 , 1 or 2. (clockwize).
		*/
        public function splitFaces(side:int = 0):void
        {
			side = (side<0)? 0 : (side>2)? 2: side;
            for each (var face:Face in _faces.concat([]))
            {
               splitFace(face, side);
            }
        }
		/**
		* Divides a face object into 2 face objects.
		* 
		* @param	face	The face to split in 2 faces.
		* @param	side	The side of the face to split in two. 0 , 1 or 2. (clockwize).
		*/
		public function splitFace(face:Face, side:int = 0):void
        {
			var v0:Vertex = face.v0;
			var v1:Vertex = face.v1;
			var v2:Vertex = face.v2;
			
			var uv0:UV = face.uv0;
			var uv1:UV = face.uv1;
			var uv2:UV = face.uv2;
			
			var vc:Vertex;
			var uvc:UV;
			
			var material:ITriangleMaterial = face.material;
			removeFace(face);
			
			switch(side){
				case 0:
					vc = new Vertex((face.v0.x+face.v1.x)*.5, (face.v0.y+face.v1.y)*.5, (face.v0.z+face.v1.z)*.5);
					uvc = new UV((uv0.u+uv1.u)*.5, (uv0.v+uv1.v)*.5);
					addFace(new Face(vc, v1, v2, material, uvc, uv1, uv2));
					addFace(new Face(v0, vc, v2, material, uv0, uvc, uv2));
					break;
				case 1:
					vc = new Vertex((face.v1.x+face.v2.x)*.5, (face.v1.y+face.v2.y)*.5, (face.v1.z+face.v2.z)*.5);
					uvc = new UV((uv1.u+uv2.u)*.5, (uv1.v+uv2.v)*.5);
					addFace(new Face(v0, v1, vc, material, uv0, uv1, uvc));
					addFace(new Face(v0, vc, v2, material, uv0, uvc, uv2));
					break;
				default:
					vc = new Vertex((face.v2.x+face.v0.x)*.5, (face.v2.y+face.v0.y)*.5, (face.v2.z+face.v0.z)*.5);
					uvc = new UV((uv2.u+uv0.u)*.5, (uv2.v+uv0.v)*.5);
					addFace(new Face(v0, v1, vc, material, uv0, uv1, uvc));
					addFace(new Face(vc, v1, v2, material, uvc, uv1, uv2));
			}
		}
		
		private function findNeighbours():void
        {
            _neighbour01 = new Dictionary();
            _neighbour12 = new Dictionary();
            _neighbour20 = new Dictionary();
            
            for each (var face:Face in _faces)
            {
                var skip:Boolean = true;
                for each (var another:Face in _faces)
                {
                    if (skip)
                    {
                        if (face == another)
                            skip = false;
                        continue;
                    }

                    if ((face._v0 == another._v2) && (face._v1 == another._v1))
                    {
                        _neighbour01[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v0 == another._v0) && (face._v1 == another._v2))
                    {
                        _neighbour01[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v0 == another._v1) && (face._v1 == another._v0))
                    {
                        _neighbour01[face] = another;
                        _neighbour01[another] = face;
                    }
                
                    if ((face._v1 == another._v2) && (face._v2 == another._v1))
                    {
                        _neighbour12[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v1 == another._v0) && (face._v2 == another._v2))
                    {
                        _neighbour12[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v1 == another._v1) && (face._v2 == another._v0))
                    {
                        _neighbour12[face] = another;
                        _neighbour01[another] = face;
                    }
                
                    if ((face._v2 == another._v2) && (face._v0 == another._v1))
                    {
                        _neighbour20[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v2 == another._v0) && (face._v0 == another._v2))
                    {
                        _neighbour20[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v2 == another._v1) && (face._v0 == another._v0))
                    {
                        _neighbour20[face] = another;
                        _neighbour01[another] = face;
                    }
                }
            }

            _neighboursDirty = false;
        }
        
        /**
         * Updates the elements in the geometry object
		 * 
		 * @see away3d.core.traverse.TickTraverser
		 * @see away3d.core.basr.Animation#update()
		 */
        public function updateElements():void
        {
            _dispatchedDimensionsChange = false;
        	
        	for each(var skinController:SkinController in skinControllers)
				skinController.update();
				
            for each(var skinVertex:SkinVertex in skinVertices)
				skinVertex.update();
				
			if ((_animation != null) && (frames != null))
                _animation.update();
            
            if (vertexDirty)
            	notifyDimensionsChange();
        }
        
        /**
        * Updates the materials in the geometry object
        */
        public function updateMaterials(source:Object3D, view:View3D):void
        {    	
        	for each (var materialData:MaterialData in materialDictionary)
        		materialData.material.updateMaterial(source, view);
        }
        
		/**
		 * Duplicates the geometry properties to another geometry object.
		 * 
		 * @return				The new geometry instance with duplicated properties applied.
		 */
        public function clone():Geometry
        {
            var geometry:Geometry = new Geometry();
			
            clonedvertices = new Dictionary();
            cloneduvs = new Dictionary();
            
			if (skinVertices) {
				clonedskinvertices = new Dictionary(true);
				clonedskincontrollers = new Dictionary(true);
				
				geometry.skinVertices = [];
				geometry.skinControllers = [];
				
	            for each (var skinVertex:SkinVertex in skinVertices)
	            	geometry.skinVertices.push(cloneSkinVertex(skinVertex));
	            	
	            for each (var skinController:SkinController in clonedskincontrollers)
	            	geometry.skinControllers.push(skinController);
	       	}
            
            for each (var face:Face in _faces)
            {
            	var cloneFace:Face = new Face(cloneVertex(face._v0), cloneVertex(face._v1), cloneVertex(face._v2), face.material, cloneUV(face._uv0), cloneUV(face._uv1), cloneUV(face._uv2));
                geometry.addFace(cloneFace);
                cloneElementDictionary[face] = cloneFace;
            }
            
            for each (var segment:Segment in _segments)
            {
                var cloneSegment:Segment = new Segment(cloneVertex(segment._v0), cloneVertex(segment._v1), segment.material);
                geometry.addSegment(cloneSegment);
                cloneElementDictionary[segment] = cloneSegment;
            }
            
            geometry.frames = new Dictionary(true);
            
            var i:int = 0;
            
            for each (var frame:Frame in frames) {
            	geometry.frames[i++] = cloneFrame(frame);
            	
            }
            
            geometry.framenames = new Dictionary(true);
            
            for (var framename:String in framenames)
            	geometry.framenames[framename] = framenames[framename];
            
            return geometry;
        }
		
		/**
 		 * update vertex information.
 		 * 
 		 * @param		v						The vertex object to update
 		 * @param		x						The new x value for the vertex
 		 * @param		y						The new y value for the vertex
 		 * @param		z						The new z value for the vertex
		 * @param		refreshNormals	[optional]	Defines whether normals should be recalculated
 		 * 
 		 */
		public function updateVertex(v:Vertex, x:Number, y:Number, z:Number, refreshNormals:Boolean = false):void
		{
			v.setValue(x,y,z);
			
			if(refreshNormals)
				_vertnormalsDirty = true;
		}
		
		/**
 		* Apply the given rotation values to vertex coordinates.
 		*/
		public function applyRotations(rotationX:Number, rotationY:Number, rotationZ:Number):void
		{
			 
			var x:Number;
			var y:Number;
			var z:Number;
			var x1:Number;
			var y1:Number;
			
			var rad:Number = Math.PI / 180;
			var rotx:Number = rotationX * rad;
			var roty:Number = rotationY * rad;
			var rotz:Number = rotationZ * rad;
			var sinx:Number = Math.sin(rotx);
			var cosx:Number = Math.cos(rotx);
			var siny:Number = Math.sin(roty);
			var cosy:Number = Math.cos(roty);
			var sinz:Number = Math.sin(rotz);
			var cosz:Number = Math.cos(rotz);

			for each (var vertex:Vertex in vertices) {
				 
				x = vertex.x;
				y = vertex.y;
				z = vertex.z;

				y1 = y;
				y = y1*cosx+z*-sinx;
				z = y1*sinx+z*cosx;
				
				x1 = x;
				x = x1*cosy+z*siny;
				z = x1*-siny+z*cosy;
			
				x1 = x;
				x = x1*cosz+y*-sinz;
				y = x1*sinz+y*cosz;
 
				updateVertex(vertex, x, y, z, false);
			}
		}
		
		/**
 		* Apply the given position values to vertex coordinates.
 		*/
		public function applyPosition(dx:Number, dy:Number, dz:Number):void
		{
			var x:Number;
			var y:Number;
			var z:Number;
			
			for each (var vertex:Vertex in vertices) {
				x = vertex.x;
				y = vertex.y;
				z = vertex.z;
				vertex.setValue(x - dx, y - dy, z - dz);
			}
		}
		
		/**
		 * Plays a sequence of frames
		 * 
		 * @param	sequence	The animationsequence to play
		 */
        public function play(sequence:AnimationSequence):void
        {
			if(!_animation){
            	_animation = new Animation(this); 
			} else{
				_animation.sequence = [];
			}
			
            _animation.fps = sequence.fps;
            _animation.smooth = sequence.smooth;
            _animation.loop = sequence.loop;
			
            if (sequence.prefix != null && sequence.prefix != ""){
				if(_animation.smooth){
					_animation.interpolate();
				}
				var bvalidprefix:Boolean;
                for (var framename:String in framenames){
                    if (framename.indexOf(sequence.prefix) == 0){
						bvalidprefix = true;
						_activePrefix = (_activePrefix != sequence.prefix)? sequence.prefix : _activePrefix ;
                        _animation.sequence.push(new AnimationFrame(framenames[framename], "" + parseInt(framename.substring(sequence.prefix.length))));
					}
				}
				
				if(bvalidprefix){
					_animation.sequence.sortOn("sort", Array.NUMERIC );            
					frames[_frame].adjust(1);
					_animation.start();
					//trace(">>>>>>>> [  start "+activeprefix+"  ]");
				} else{
					trace("--------- \n--> unable to play animation: unvalid prefix ["+sequence.prefix+"]\n--------- ");
				}
				
			} else{
				trace("--------- \n--> unable to play animation: prefix is null \n--------- ");
			}
        }
		
		/**
		 * Starts playing the animation at the specified frame.
		 * 
		 * @param	value		A number representing the frame number.
		 */
		public function gotoAndPlay(value:int):void
		{
			_frame = _animation.frame = value;
			
			frames[_frame].adjust(1);
			
			if(!_animation.isRunning)
				_animation.start();
		}
		
		/**
		 * Brings the animation to the specifed frame and stops it there.
		 * 
		 * @param	value		A number representing the frame number.
		 */
		public function gotoAndStop(value:int):void
		{
			_frame = _animation.frame = value;
			
			frames[_frame].adjust(1);
			
			if(_animation.isRunning)
				_animation.stop();
		}
		
		/**
		* Plays a sequence of frames
		* Note that the framenames must be be already existing in the system before you can use this handler
		* @param	prefixes  	Array. The list of framenames to be played
		* @param	fps			uint: frames per second
		* @param	smooth		[optional] Boolean. if the animation must interpolate. Default = true.
		* @param	loop			[optional] Boolean. if the animation must loop. Default = false.
		*/
		public function playFrames( prefixes:Array, fps:uint, smooth:Boolean=true, loop:Boolean=false ):void
		{
			if( _animation ) {
				_animation.sequence = [];
			} else{
				_animation = new Animation(this);
			}
			
			_animation.fps = fps;
			_animation.smooth = smooth;
			_animation.loop = loop;
			
			if(smooth) _animation.createTransition();
			
			for each( var framename:String in prefixes )
			{
				if( framenames[framename] != null )
					_animation.sequence.push( new AnimationFrame(framenames[framename]));
				 
			}
			
			if( _animation.sequence.length ) _animation.start();
		}


		/**
		 * Passes an array of animationsequence objects to be added to the animation.
		 * 
		 * @param	playlist				An array of animationsequence objects.
		 * @param	loopLast	[optional]	Determines whether the last sequence will loop. Defaults to false.
		 */
		public function setPlaySequences(playlist:Array, loopLast:Boolean = false):void
		{
			var _length:int = playlist.length;
			if(_length == 0)
				return;
			
			if(!_animation)
				_animation = new Animation(this); 
			
			_animationgroup = new AnimationGroup();
			_animationgroup.loopLast = loopLast;
			_animationgroup.playlist = [];
			
			for(var i:int = 0;i<_length;++i )
				_animationgroup.playlist[i] = new AnimationSequence(playlist[i].prefix, playlist[i].smooth, true, playlist[i].fps);
			 
			if(!_animation.hasEventListener(AnimationEvent.SEQUENCE_UPDATE))
				_animation.addEventListener(AnimationEvent.SEQUENCE_UPDATE, updatePlaySequence);
			
			_animation.sequenceEvent = true;
			loop = true;
			play(_animationgroup.playlist.shift());
		}
		
		/**
		 * Default method for adding a sequenceDone event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function addOnSequenceDone(listener:Function):void
        {
            addEventListener(AnimationEvent.SEQUENCE_DONE, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a sequenceDone event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function removeOnSequenceDone(listener:Function):void
        {
            removeEventListener(AnimationEvent.SEQUENCE_DONE, listener, false);
        }
		
		/**
		 * Default method for adding a cycle event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function addOnCycle(listener:Function):void
        {
			_animation.cycleEvent = true;
			_cycle = new AnimationEvent(AnimationEvent.CYCLE, _animation);
			_animation.addEventListener(AnimationEvent.CYCLE, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a cycle event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function removeOnCycle(listener:Function):void
        {
			_animation.cycleEvent = false;
            _animation.removeEventListener(AnimationEvent.CYCLE, listener, false);
        }
		
		/**
		 * Default method for adding a dimensionsChanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnDimensionsChange(listener:Function):void
        {
            addEventListener(GeometryEvent.DIMENSIONS_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a dimensionsChanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnDimensionsChange(listener:Function):void
        {
            removeEventListener(GeometryEvent.DIMENSIONS_CHANGED, listener, false);
        }
        
		/**
		 * Default method for adding a materialUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMaterialUpdate(listener:Function):void
        {
            addEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a materialUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMaterialUpdate(listener:Function):void
        {
            removeEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false);
        }
        
		/**
		 * Default method for adding a mappingChanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMappingChange(listener:Function):void
        {
            addEventListener(ElementEvent.MAPPING_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a mappingChanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMappingChange(listener:Function):void
        {
            removeEventListener(ElementEvent.MAPPING_CHANGED, listener, false);
        }
    }
}
