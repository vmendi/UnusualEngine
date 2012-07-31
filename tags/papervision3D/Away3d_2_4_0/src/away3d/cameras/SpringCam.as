﻿package away3d.cameras
{
  import away3d.cameras.Camera3D;
  import away3d.containers.View3D;
  import away3d.core.base.Object3D;
  import away3d.core.math.Matrix3D;
  import away3d.core.math.Number3D;
  
	/** b at turbulent dot ca - http://agit8.turbulent.ca 
   * v1 - 2009-01-21
   **/
   
  /**
   * A 1st and 3d person camera(depending on positionOffset!), hooked on a physical spring on an optional target.
   */
  public class SpringCam extends Camera3D
  {
    /**
     * [optional] Target object3d that camera should follow. If target is null, camera behaves just like a normal Camera3D.
     */
    public var target:Object3D;
    
    //spring stiffness
    /**
     * Stiffness of the spring, how hard is it to extend. The higher it is, the more "fixed" the cam will be.
     * A number between 1 and 20 is recommended.
     */
    public var stiffness:Number = 1;
    
    /**
     * Damping is the spring internal friction, or how much it resists the "boinggggg" effect. Too high and you'll lose it!
     * A number between 1 and 20 is recommended.
     */
    public var damping:Number = 4;
    
    /**
     * Mass of the camera, if over 120 and it'll be very heavy to move.
     */
    public var mass:Number = 40;
    
    /**
     * Offset of spring center from target in target object space, ie: Where the camera should ideally be in the target object space.
     */
    public var positionOffset:Number3D = new Number3D(0,5,-50);
    
    /**
     * offset of facing in target object space, ie: where in the target object space should the camera look.
     */
    public var lookOffset:Number3D = new Number3D(0,2,10);
    
    //zrot to apply to the cam
    private var _zrot:Number = 0;
    
    //private physics members
    private var _velocity:Number3D = new Number3D();
    private var _dv:Number3D = new Number3D();
    private var _stretch:Number3D = new Number3D();
    private var _force:Number3D = new Number3D();
    private var _acceleration:Number3D = new Number3D();
    
    //private target members
    private var _desiredPosition:Number3D = new Number3D();
    private var _lookAtPosition:Number3D = new Number3D();
    private var _targetTransform:Matrix3D = new Matrix3D();
    
    //private transformed members
    private var _xPositionOffset:Number3D = new Number3D();
    private var _xLookOffset:Number3D = new Number3D();
    private var _xPosition:Number3D = new Number3D();
    
    public function SpringCam(init:Object=null)
    {
    super(init);
    }
    
    /**
     * Rotation in degrees along the camera Z vector to apply to the camera after it turns towards the target .
     */
    public function set zrot(n:Number):void
    {
      _zrot = n;
      if(_zrot < 0.001) n = 0;
    }
    public function get zrot():Number
    {
      return _zrot;
    }
    
    public override function get view():View3D
    {
      if(target != null)
      {
      	_targetTransform.szx = target.transform.szx;
      	_targetTransform.szy = target.transform.szy;
      	_targetTransform.szz = target.transform.szz;
      	
      	_targetTransform.syx = target.transform.syx;
      	_targetTransform.syy = target.transform.syy;
      	_targetTransform.syz = target.transform.syz;
      	
      	_targetTransform.sxx = target.transform.sxx;
      	_targetTransform.sxy = target.transform.sxy;
      	_targetTransform.sxz = target.transform.sxz;
      	
      	_xPositionOffset.transform(positionOffset, _targetTransform);
      	_xLookOffset.transform(lookOffset, _targetTransform);
      	
      	_desiredPosition.add(target.position, _xPositionOffset);
      	_lookAtPosition.add(target.position, _xLookOffset);
      	
      	_stretch.sub(this.position, _desiredPosition);
      	_stretch.scale(_stretch, -stiffness);
      	_dv.scale(_velocity, damping);
      	_force.sub(_stretch, _dv);
      	
      	_acceleration.scale(_force, 1/mass);
      	_velocity.add(_velocity, _acceleration);
      	
      	_xPosition.add(position, _velocity);
      	x = _xPosition.x;
      	y = _xPosition.y;
      	z = _xPosition.z;
      	
      	lookAt(_lookAtPosition);
      	
      	if(Math.abs(_zrot) > 0)
      		rotate(Number3D.FORWARD, _zrot);
      }  
      return super.view;
    }
    
  }
}