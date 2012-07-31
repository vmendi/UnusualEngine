﻿package away3d.animators
{
	import flash.events.EventDispatcher;
	import away3d.animators.utils.*;
	import away3d.animators.data.Path;
	import away3d.animators.data.CurveSegment;
	import away3d.core.math.Number3D;
	import away3d.core.utils.Init;
	import away3d.events.PathEvent;
	import away3d.core.base.Object3D;

	public class PathAnimator extends EventDispatcher
	{
		private var _path:Path;
		private var _time:Number;
		private var _index:Number = 0;
		private var _indextime:Number = 0;
		private var _duration:Number;
		private var _aTime:Array;
		private var _rotations:Array;
		private var _lookAt:Boolean;
		private var _alignToPath:Boolean;
		private var _object3d:Object3D;
		private var _targetobject:*;
		private var _easein:Boolean;
		private var _easeout:Boolean;
		private var _fps:int ;
		private var ini:Init;
		private var _offset:Number3D;
		private var _rotatedOffset:Number3D = new Number3D();
		private var _objectrotation:Number3D;
		private var _position:Number3D = new Number3D();
		//events
		private var _eCycle:PathEvent;
		private var _bCycle:Boolean;
		private var _lasttime:Number;
		private var _from:Number;
		private var _to:Number;
		private var _bRange:Boolean;
		private var _eRange:PathEvent;
		private var _bSegment:Boolean;
		private var _eSeg:PathEvent;
		private var _lastSegment:int = 0;
		private var _nRot:Number3D;
		private var _worldAxis:Number3D = new Number3D(0,1,0);
		private var _basePosition:Number3D = new Number3D(0,0,0);
		 
		private function updatePosition(st:Number3D, contr:Number3D, end:Number3D, t:Number):void
		{
			var dt:Number = 2 * (1 - t);
			_basePosition.x = st.x + t * (dt * (contr.x - st.x) + t * (end.x - st.x));
			_basePosition.y = st.y + t * (dt * (contr.y - st.y) + t * (end.y - st.y));
			_basePosition.z = st.z + t * (dt * (contr.z - st.z) + t * (end.z - st.z)); 
			
			_position.x = _basePosition.x;
			_position.y = _basePosition.y;
			_position.z = _basePosition.z;
		}
		
		private function updateObjectPosition(rotate:Boolean = false):void{
			
			if(rotate && _offset != null  ){
				
				 _rotatedOffset.x =  _offset.x;
				 _rotatedOffset.y =  _offset.y;
				 _rotatedOffset.z =   _offset.z;
				 
				 _rotatedOffset = PathUtils.rotatePoint(  _rotatedOffset, _nRot);
				 _position.x +=  _rotatedOffset.x;
				 _position.y +=  _rotatedOffset.y;
				 _position.z +=   _rotatedOffset.z;
				 
			} else  if(_offset != null) {
				
				_position.x += _offset.x;
				_position.y += _offset.y;
				_position.z +=_offset.z;
				
			} 
			_object3d.position = _position;
			
		}
		  
		/**
		* Creates a new <PathAnimator>PathAnimator</code>
		* 
		* @param	 			path		A Path object. The _path definition.
		* @param	 			object3d		 An Object, defines the object to be animated along the path. The object of any kind must have 3 public properties "x,y,z".
		* Note: if an rotations array is passed, the object must have rotationX, Y and Z public properties as well.
		* @param 	init		[optional]	An initialisation object for specifying default instance properties. Default is null. 
		* 
		*/
		function PathAnimator(path:Path, object3d:*, init:Object = null)
		{
			_path = path;
			_worldAxis = _path.worldAxis;
			_object3d = object3d;
			
			ini = Init.parse(init);
            _duration = ini.getNumber("duration", 1000, {min:0});
			_lookAt = ini.getBoolean("lookat", false);
			_alignToPath = ini.getBoolean("aligntopath", !_lookAt);
			_easein = ini.getBoolean("easein", false);
			_easeout = ini.getBoolean("easeout", false);
			_fps = ini.getInt("fps", 20, {min:0});
			_offset = ini.getNumber3D("offset");
			 
			if(init && init["rotations"] != null && init["rotations"].length > 0){
				_rotations = ini.getArray("rotations");
				_nRot = new Number3D();
			}
				
			_targetobject = ini.getObject("targetobject", null);
			
			if(_lookAt && _targetobject == null)
				_lookAt = false;
			
			if(_lookAt && _alignToPath)
				_alignToPath = false;
  
			_index=0;
			_indextime=0;
			_time=0;
			_lasttime=0;
			 _aTime = [];
			
			update(0);
		}
		
		/**
    	* Update automatically the tween. Note that if you want to use a more extended tween engine like Tweener. Use the "update" handler.
		*
		* @param startFrom 	A Number  from 0 to 1. Note: this will have fx on the next iteration on the Path, if you want it start at this point, use clearTime handler first.
    	*/
		public function animateOnPath(startFrom:Number = 0):void
		{
			if (_aTime.length == 0) {
				_lastSegment = 0;
				_indextime = 0;
				_aTime = AWTweener.calculate((startFrom == 0)?_fps : _fps+(_fps*(1*startFrom)) , (startFrom == 0)? 0 : 1*startFrom ,1,_duration,_easein,_easeout); 
			}
			
			update(_aTime[_indextime]);
			_indextime =_indextime + 1 > _aTime.length - 1? 0:_indextime + 1;

		}
		
		/**
    	* Calculates the new position and set the object on the path accordingly
		*
		* @param t 	A Number  from 0 to 0.999999999  (less than one to allow alignToPath)
    	*/
		public function update(t:Number):void
		{
			
			if(t< 0){
				t = 0;
				_lastSegment = 0;
			}
			
			if( t>=0.999999999){
				t = 0.999999999;
				_lastSegment = 0;
				if(_bCycle && t != _lasttime){					 
					dispatchEvent(_eCycle);
				}
			}
			_lasttime = t;
			
			var curve:CurveSegment;
			var multi:Number = _path.array.length*t;
			_index = Math.floor(multi);
			curve = _path.array[_index];
			
			if(_offset != null  )
				_object3d.position = _basePosition;
			
			var nT:Number = multi-_index;
			updatePosition(curve.v0, curve.vc, curve.v1, nT);
		
			var rotate:Boolean;
			if (_lookAt && _targetobject!= null && !_alignToPath) {
				_object3d.x += _offset.x;
				_object3d.y += _offset.y;
				_object3d.z += _offset.z;
				_object3d.lookAt(_targetobject["scenePosition"]);
				
			} else if (_alignToPath && !_lookAt ) {
	
				if(_rotations != null  ){
					
					if(_rotations[_index+1] == null){
						
						 _nRot.x = _rotations[_rotations.length-1].x*nT;
						 _nRot.y = _rotations[_rotations.length-1].y*nT;
						 _nRot.z = _rotations[_rotations.length-1].z*nT;
						 
					} else {
						 
						_nRot.x = _rotations[_index].x +   ((_rotations[_index+1].x -_rotations[_index].x)*nT);
						_nRot.y = _rotations[_index].y +   ((_rotations[_index+1].y -_rotations[_index].y)*nT);
						_nRot.z = _rotations[_index].z +   ((_rotations[_index+1].z -_rotations[_index].z)*nT);
						 
					}
					 
					 _worldAxis.x = 0;
					 _worldAxis.y = 1;
					 _worldAxis.z = 0;
					 _worldAxis = PathUtils.rotatePoint(_worldAxis, _nRot);
					 
					 _object3d.lookAt(_basePosition, _worldAxis);
					
					rotate = true;
					
				} else {
					 _object3d.lookAt(_position);
				}
				 
			}				
			
			if (!_lookAt)
				updateObjectPosition(rotate);
			
			
			if(_bSegment && _index >0 && _lastSegment < _index && t < 0.999999999){
					_lastSegment = _index;
					dispatchEvent(_eSeg);
			}
				 
			if(_bRange &&(t >= _from && t <= _to))
					dispatchEvent(_eRange);
					
			_time = t;
		 
		}
		/**
    	* Updates a position Number3D on the path at a given time. Do not use this handler to animate, it's in there to add dummy's or place camera before or after
		* the animated object. Use the update() or the automatic tweened animateOnPath() handlers instead.
		*
		* @param p	Number3D. The Number3D to update according to the "t" time parameter.
		* @param t	Number. A Number  from 0 to 1
		* @see animateOnPath
		* @see update
    	*/
		public function getPositionOnPath( p:Number3D, t:Number):void
		{
			t = (t<0)? 0 : (t>1)?1 : t;
			var m:Number = _path.array.length*t;
			var i:int = Math.floor(m);
			var curve:CurveSegment = _path.array[i];
			var nT:Number = m-i;
			var dt:Number = 2 * (1 - nT);
			p.x = curve.v0.x + nT * (dt * (curve.vc.x - curve.v0.x) + nT * (curve.v1.x - curve.v0.x));
			p.y = curve.v0.y + nT * (dt * (curve.vc.y - curve.v0.y) + nT * (curve.v1.y - curve.v0.y));
			p.z = curve.v0.z + nT * (dt * (curve.vc.z - curve.v0.z) + nT * (curve.v1.z - curve.v0.z));
		}

		/**
    	* returns the actual time on the path.a Number from 0 to 1
    	*/
		public function get time():Number
		{
			return _time;
		}
		
		/**
    	* returns the segment index that is used at a given time;
		* @param	 t		[Number]. A Number between 0 and 1. If no params, actual pathanimator time segment index is returned.
    	*/
		public function getTimeSegment(t:Number = NaN):Number
		{
			t = (isNaN(t))? _time : t;
			return Math.floor(_path.array.length*t);
		}
		 
		/**
    	* clear the tween array in order to start from another time on the path, if the animateOnPath handler is being used
    	*/
		public function clearTime():void
		{
			_aTime = [];
			_lasttime = 0;
			_time = 0;
		}
		
		/**
    	* set the saved time back to a lower time to avoid mesh rotation Y of 180.
    	*/
		public function set offsetTime(t:Number):void
		{
			_lasttime = (_lasttime - t>0)? _lasttime - t : 0;
		}
		
		/**
    	* returns the segment count of the path
    	*/
		public function get pathlength():Number
		{
			return _path.array.length;
		}
		 
		/**
    	* returns the actual tweened pos on the path with no optional offset applyed
    	*/
		public function get position():Number3D
		{
			return _position;
		}
		
		/**
    	* returns the actual rotations of the object3D;
    	*/
		public function get objectRotations():Number3D
		{
			if(_objectrotation == null)
				_objectrotation = new Number3D();
			
			_objectrotation.x = _object3d.rotationX;
			_objectrotation.y = _object3d.rotationY;
			_objectrotation.z = _object3d.rotationZ;
			
			return _objectrotation;
		}
		
		/**
    	* returns the actual interpolated rotation along the path;
    	*/
		public function get orientation():Number3D
		{
			return _nRot;
		}
		
		/**
    	* sets an optional offset to the pos on the path, ideal for cameras or resuse same Path object for other objects
    	*/
		public function set offset(val:Number3D):void
		{
			_offset = val;
		}
		
		public function get offset():Number3D
		{
			return _offset;
		}
		
		/**
    	* To update an optional offset by the x, y and z properties
    	*/
		public function set offsetX(val:Number):void
		{
			if(_offset == null)
				_offset = new Number3D();
				
			_offset.x = val;
		}
		
		public function get offsetX():Number
		{
			if(_offset == null)
				_offset = new Number3D();
				
			return _offset.x;
		}
		
		public function set offsetY(val:Number):void
		{
			if(_offset == null)
				_offset = new Number3D();
				
			_offset.y = val;
		}
		
		public function get offsetY():Number
		{
			if(_offset == null)
				_offset = new Number3D();
				
			return _offset.y;
		}
		
		public function set offsetZ(val:Number):void
		{
			if(_offset == null)
				_offset = new Number3D();
				
			_offset.z = val;
		}
		
		public function get offsetZ():Number
		{
			if(_offset == null)
				_offset = new Number3D();
				
			return _offset.z;
		}
		
		/**
    	* sets the object to be animated along the path. The object must have 3 public properties "x,y,z".
		* Note: if an rotation array is passed, the object must have rotationX, Y and Z public properties.
    	*/
		public function set object3d(object3d:*):void
		{
			_object3d = object3d;
		}
		
		public function get object3d():*
		{
			return _object3d;
		}
		
		/**
    	* sets the target object that the object to be animated along the path will lookat
    	*/
		public function set targetobject(object3d:*):void
		{
			_lookAt = (object3d != null);
			aligntopath = !_lookAt;
			_targetobject = object3d;
		}
		
		public function get targetobject():*
		{
			return _targetobject;
		}
		
		/**
    	* sets an optional array of rotations, probably same as the PathExtrude or PathDuplicator rotation array in order to follow the twisted shape.
    	*/
		public function set rotations(rot:Array):void
		{
			_rotations = (rot != null && rot.length>0)? rot : null;
			if(_rotations != null && _nRot== null) 
				_nRot = new Number3D();
		}
		public function get rotations():Array
		{
			return _rotations;
		}
		
		/**
    	* defines if the motion must easein along the path
    	*/
		public function set easein(b:Boolean):void
		{
			_easein = b;
		}
		public function get easein():Boolean
		{
			return _easein;
		}
		
		/**
    	* defines if the motion must easeout along the path
    	*/
		public function set easeout(b:Boolean):void
		{
			_easeout = b;
		}
		public function get easeout():Boolean
		{
			return _easeout;
		}
		
		/**
    	* defines if the object animated along the path must be aligned to the path.
    	*/
		public function set aligntopath(b:Boolean):void
		{
			_alignToPath = b;
		}
		public function get aligntopath():Boolean
		{
			return _alignToPath;
		}
		
		/**
    	* defines the path to follow
		* @see Path
    	*/
		public function set path(p:Path):void
		{
			_path = p;
			_worldAxis = _path.worldAxis;
		}
		public function get path():Path
		{
			return _path;
		}
		
		/**
    	* defines the frame rate per second. This only affects the animateOnPath handler.
    	*/
		public function set fps(val:int):void
		{
			_fps = val;
		}
		public function get fps():int
		{
			return _fps;
		}
		
		/**
    	* defines the duration in ticks (ms). This only affects the animateOnPath handler.
    	*/
		public function set duration(val:int):void
		{
			_duration = val;
		}
		public function get duration():int
		{
			return _duration;
		}
		
		/**
    	* defines the frame rate per second. This only affects the animateOnPath handler.
    	*/
		public function set index(val:int):void
		{
			_index = (val > _path.array.length - 1)? _path.array.length - 1 : (val > 0)? val : 0;
			_aTime = [];
		}
		public function get index():int
		{
			return _index;
		}
		
		/**
		 * Default method for adding a cycle event listener. Event fired when the time reaches  0.999999999 or higher.
		 * 
		 * @param	listener		The listener function
		 */
		public function addOnCycle(listener:Function):void
        {
			_lasttime = 0;
			_bCycle = true;
			_eCycle = new PathEvent(PathEvent.CYCLE, this);
			this.addEventListener(PathEvent.CYCLE, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a cycle event listener
		 * 
		 * @param		listener		The listener function
		 */
		public function removeOnCycle(listener:Function):void
        {
			_bCycle = false;
			_eCycle = null;
            this.removeEventListener(PathEvent.CYCLE, listener, false);
        }
		
		/**
		 * Default method for adding a range event listener. Event fired when the time is >= from and <= to variables.
		 * 
		 * @param		listener		The listener function
		 */
		public function addOnRange(listener:Function, from:Number = 0, to:Number = 0):void
        {
			_from = from;
			_to = to;
			_bRange = true;
			_eRange = new PathEvent(PathEvent.RANGE, this);
			this.addEventListener(PathEvent.RANGE, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a range event listener
		 * 
		 * @param		listener		The listener function
		 */
		public function removeOnRange(listener:Function):void
        {
			_from = 0;
			_to = 0;
			_bRange = false;
			_eRange = null;
            this.removeEventListener(PathEvent.RANGE, listener, false);
        }
		
		/**
		 * Default method for adding a segmentchange event listener. Event fired when the time pointer reads another CurveSegment. Note that it's not triggered if the value time is decreasing along the path.
		 * 
		 * @param		listener		The listener function
		 */
		public function addOnChangeSegment(listener:Function):void
        {
			_bSegment = true;
			_lastSegment = 0;
			_eSeg = new PathEvent(PathEvent.CHANGE_SEGMENT, this);
			this.addEventListener(PathEvent.CHANGE_SEGMENT, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a range event listener
		 * 
		 * @param		listener		The listener function
		 */
		public function removeOnChangeSegment(listener:Function):void
        {
			_bSegment = false;
			_eSeg = null;
			_lastSegment = 0;
            this.removeEventListener(PathEvent.CHANGE_SEGMENT, listener, false);
        }
		
		/**
		 * Returns a position on the path according to duration/elapsed time. Duration variable must be set.
		 * 
		 * @param		p		Number3D. An empty Number3D that will be returned with the location on path at a given time in ms.
		 * @param		d		Number. A number representing a time in ms. 
		 *
		 *@ returns Number3D The position at a given elapsed time, compared to total duration.
		 */
		public function getDurationOnPath( p:Number3D, d:Number):Number3D
        {
            var t:Number = d/_duration;
            t = (t<0)? 0 : (t>1)?1 : t;
            var m:Number = _path.array.length*t;
            var i:int = Math.floor(m);
            var curve:CurveSegment = _path.array[i];
            var nT:Number = m-i;
            var dt:Number = 2 * (1 - nT);
            p.x = curve.v0.x + nT * (dt * (curve.vc.x - curve.v0.x) + nT * (curve.v1.x - curve.v0.x));
            p.y = curve.v0.y + nT * (dt * (curve.vc.y - curve.v0.y) + nT * (curve.v1.y - curve.v0.y));
            p.z = curve.v0.z + nT * (dt * (curve.vc.z - curve.v0.z) + nT * (curve.v1.z - curve.v0.z));
			
			return p;
        }
		/**
		 * Default method for removing a range event listener
		 * 
		 * @param		d		Number. A number representing a time in ms. Duration variable must be set.
		 *@ returns Number. The elapsed time compared to total duration
		 */
        public function updateTimeElapsed(d:Number):Number
		{
            update((d/_duration));
            return (d/_duration);
        }
		
		/**
		* Returns the elapsed time along the path.
		* duration variable must be set for this function
		*@ returns Number. The elapsed time compared to total duration
		*/
        public function getTimeElapsed():Number
		{
            return _duration*time;
        }
		 
	}
}