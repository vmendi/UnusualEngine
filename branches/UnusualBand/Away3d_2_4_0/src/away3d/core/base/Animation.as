﻿package away3d.core.base
{
    import away3d.events.*;
    
    import flash.events.EventDispatcher;
    import flash.utils.*;
    
	 /**
	 * Dispatched when all frame sequences are complete
	 * 
	 * @eventType away3d.events.AnimationEvent
	 */
	[Event(name="cycle",type="away3d.events.AnimationEvent")]
	
	 /**
	 * Dispatched when the current frame sequence is complete
	 * 
	 * @eventType away3d.events.AnimationEvent
	 */
	[Event(name="sequenceupdate",type="away3d.events.AnimationEvent")]
		
	/**
	 * Holds information about the current state of a mesh animation.
	 */
    public class Animation extends EventDispatcher implements IAnimation
    {
        private var _time:uint;
        private var _cycle:AnimationEvent;
        private var _sequenceupdate:AnimationEvent;
        private var _isRunning:Boolean = false;
        private var _latest:uint = 0;
        private var _transition:AnimationTransition;
		
		 /**
        * Creates a new AnimationTransition object.
        */
		public function createTransition():void
		{
			if(_transition == null) 
				_transition = new AnimationTransition(geometry);
		}
        /**
        * The current frame of the animation.
        */
        public var frame:Number = 0;
        
        /**
        * The frames per second at which the animation will run.
        */
        public var fps:Number = 24;
        
        /**
        * Determines whether the animation will loop.
        */
        public var loop:Boolean = false;
        
        /**
        * Determines whether the animation will smooth motion (interpolate) between frames.
        */
        public var smooth:Boolean = false;
        
        /**
        * Determines whether the animation will fire cycle events.
        * 
        * @see away3d.events.AnimationEvent
        */
		public var cycleEvent:Boolean = false;
		
        /**
        * Determines whether the animation will fire sequence events.
        * 
        * @see away3d.events.AnimationEvent
        */
		public var sequenceEvent:Boolean = false;
		
		/**
		 * Determines the delay time between animation cycles if loop is set to true.
		 * 
		 * @see loop
		 */
        public var delay:Number = 0;
        
        /**
        * Holds an array of animation frames.
        * 
        * @see away3d.core.base.AnimationFrame
        */
        public var sequence:Array = [];
		 
        /**
        * Returns the number of the latest frame displayed.
        */
		public function get latest():uint
		{
			return _latest;
		}
		
		/**
		 * Indicates whether the animation is currently running.
		 */
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		/**
		 * The mesh on which the animation is occurring.
		 */
		public var mesh:Mesh;
				
		/**
		 * The geometry on which the animation is occurring.
		 */
		public var geometry:Geometry;
    	
		/**
		 * Creates a new <code>Animation</code> object.
		 * 
		 * @param	obj		The geometry object that the animation acts on.
		 */
        public function Animation(geo:Geometry)
        {
			geometry = geo;
			_cycle = new AnimationEvent(AnimationEvent.CYCLE, this);
			_sequenceupdate = new AnimationEvent(AnimationEvent.SEQUENCE_UPDATE, this);
        }
		
		/**
		 * Jumps to the beginning of the animation and start playing
		 */
        public function start():void
        {
            _time = getTimer();
            _isRunning = true;
			_latest = 0;
            frame = 0;
        }
		
		/**
		 * Smooth interpolations between new AnimationSequence objects
		 */
		public function interpolate():void
		{
			var isNew:Boolean = (_transition == null);
			
			if(isNew)
				createTransition();
			else
				_transition.reset();
			
		}
		/*
		 * Determines howmany frames a transition between the actual and the next animationSequence should interpolate together.
		 * must be higher or equal to 1. Default = 10;
		 */
		public function set transitionValue(val:Number):void
		{
			createTransition();
			 _transition.transitionValue = val;
		}
		
		public function get transitionValue():Number
		{
			 return (_transition == null)? 10 : _transition.transitionValue;
		}
		
		/**
		 * @inheritDoc
		 */
        public function update():void
        {
            if (!_isRunning && !sequenceEvent)
                return;
			 
			
            var now:uint = getTimer();
            frame += (now - _time) * fps / 1000;
            _time = now;
			
			var _length:int = sequence.length;
			var _length1delay:int = _length - 1 + delay;
            if (_length == 1){
				
				if(cycleEvent)
					dispatchEvent(_cycle);
				
				if(sequenceEvent)
					dispatchEvent(_sequenceupdate);
			 	
				if(!loop)
					 _isRunning = false;
					 
				_latest = 0;
				frame = 0;
					 
            } else if (loop && !sequenceEvent) {
              
				 while (frame > _length1delay)
					 frame -= _length1delay;
					
            } else {
				
                if (frame > _length1delay){
					
                    frame = _length1delay;
					 
					 if(cycleEvent)
					 	dispatchEvent(_cycle);
					 
					 if(sequenceEvent)
					 	dispatchEvent(_sequenceupdate);
					
					if(!loop)
					 _isRunning = false;
                } 
				 
            }
			
            var rf:Number = frame;
			 
            if (!smooth)
                rf = Math.round(rf);
                
            if (rf < 0)
                rf = 0;

            if (rf > _length - 1  )
                rf = _length - 1;
				
				 
            if (rf == Math.round(rf)) {
                geometry.frames[sequence[int(rf)].frame].adjust(1);
				
            }  else {
                var lf:Number = Math.floor(rf);
                var hf:Number = Math.ceil(rf);
                geometry.frames[sequence[int(lf)].frame].adjust(1);
                geometry.frames[sequence[int(hf)].frame].adjust(rf-lf);
				 
				if(loop || sequenceEvent ){
					if(_latest == 0 || _latest+1 == sequence[int(lf)].frame || _latest == sequence[int(lf)].frame){
						_latest = sequence[int(lf)].frame;
					} else{
						_latest = 0;
						 
						if(cycleEvent)
							dispatchEvent(_cycle);
						
						if(sequenceEvent)
							dispatchEvent(_sequenceupdate);
						 
					}
				} else if( cycleEvent  || sequenceEvent || _length == 2){
						 
						if(cycleEvent)
							dispatchEvent(_cycle);
						
						if(sequenceEvent)
							dispatchEvent(_sequenceupdate);
				}
				 
            }
			
			if(smooth)
				if(_transition.interpolate < 1)
					_transition.update();
			 
        }
		
		/**
		 * Stops the animation at it's current position.
		 */
        public function stop():void
        {
            _isRunning = false;
			_latest = 0;
        }
    }
}