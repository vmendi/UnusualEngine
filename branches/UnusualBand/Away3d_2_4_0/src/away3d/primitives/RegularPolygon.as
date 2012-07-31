﻿package away3d.primitives
{
	import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    
	use namespace arcane;
	
    /**
    * Creates a regular polygon.
    */ 
    public class RegularPolygon extends AbstractPrimitive
    {
        private var _radius:Number;
        private var _sides:Number;
        private var _subdivision:Number;
        private var _yUp:Boolean;
        
		/**
		 * @inheritDoc
		 */
    	protected override function buildPrimitive():void
    	{
    		super.buildPrimitive();
    		
			var tmpPoints:Array = [];
			var i:int = 0;
			var j:int = 0;
			
			var innerstep:Number = _radius/_subdivision;
			
			var radstep:Number = 360/_sides;
			var ang:Number = 0;
			var ang_inc:Number = radstep;
			
			var uva:UV;
			var uvb:UV;
			var uvc:UV;
			var uvd:UV;						
		
			var facea:Vertex;
			var faceb:Vertex;
			var facec:Vertex;
			var faced:Vertex;
			
			for (i; i <= _subdivision; ++i)
				tmpPoints.push(new Number3D(i*innerstep, 0, 0));
						
			var base:Number3D = new Number3D(0,0,0);
			var zerouv:UV = createUV(0.5, 0.5);
			 
			for (i = 0; i < _sides; ++i) {
				
				for (j = 0; j <tmpPoints.length-1; ++j) {						

					uva = createUV( (Math.cos(-ang_inc/180*Math.PI) / ((_subdivision*2)/j) ) + .5, (Math.sin(ang_inc/180*Math.PI) / ((_subdivision*2)/j)) +.5 );
					uvb = createUV( (Math.cos(-ang/180*Math.PI) / ((_subdivision*2)/(j+1)) ) + .5, (Math.sin(ang/180*Math.PI) / ((_subdivision*2)/(j+1)) ) + .5   );
					uvc = createUV( (Math.cos(-ang_inc/180*Math.PI) / ((_subdivision*2)/(j+1)) ) + .5, (Math.sin(ang_inc/180*Math.PI) / ((_subdivision*2)/(j+1))) + .5  );
					uvd = createUV( (Math.cos(-ang/180*Math.PI) / ((_subdivision*2)/j)) + .5, (Math.sin(ang/180*Math.PI) / ((_subdivision*2)/j) ) +.5  );

					if(j==0){
						if (_yUp) {
							facea = createVertex(base.x, base.y, base.z);
							faceb = createVertex(Math.cos(-ang/180*Math.PI) *  tmpPoints[1].x, base.y, Math.sin(ang/180*Math.PI) * tmpPoints[1].x);
							facec = createVertex(Math.cos(-ang_inc/180*Math.PI) *  tmpPoints[1].x, base.y, Math.sin(ang_inc/180*Math.PI) * tmpPoints[1].x);	
						} else {
							facea = createVertex(base.x, base.y, base.z);
							faceb = createVertex(Math.cos(-ang/180*Math.PI) *  tmpPoints[1].x, Math.sin(ang/180*Math.PI) * tmpPoints[1].x, base.z);
							facec = createVertex(Math.cos(-ang_inc/180*Math.PI) *  tmpPoints[1].x, Math.sin(ang_inc/180*Math.PI) * tmpPoints[1].x, base.z);	
						}
			
						addFace(createFace(facea, faceb, facec, null, zerouv, uvb, uvc ) );
						
					} else {
						if (_yUp) {
							facea = createVertex(Math.cos(-ang_inc/180*Math.PI) *  tmpPoints[j].x, base.y, Math.sin(ang_inc/180*Math.PI) * tmpPoints[j].x);
							faceb = createVertex(Math.cos(-ang_inc/180*Math.PI) *  tmpPoints[j+1].x, base.y, Math.sin(ang_inc/180*Math.PI) * tmpPoints[j+1].x);
							facec = createVertex(Math.cos(-ang/180*Math.PI) *  tmpPoints[j+1].x, base.y, Math.sin(ang/180*Math.PI) * tmpPoints[j+1].x);
							faced = createVertex(Math.cos(-ang/180*Math.PI) *  tmpPoints[j].x, base.y, Math.sin(ang/180*Math.PI) * tmpPoints[j].x);
						} else {
							facea = createVertex(Math.cos(-ang_inc/180*Math.PI) *  tmpPoints[j].x, Math.sin(ang_inc/180*Math.PI) * tmpPoints[j].x, base.z);
							faceb = createVertex(Math.cos(-ang_inc/180*Math.PI) *  tmpPoints[j+1].x, Math.sin(ang_inc/180*Math.PI) * tmpPoints[j+1].x, base.z);
							facec = createVertex(Math.cos(-ang/180*Math.PI) *  tmpPoints[j+1].x, Math.sin(ang/180*Math.PI) * tmpPoints[j+1].x, base.z);
							faced = createVertex(Math.cos(-ang/180*Math.PI) *  tmpPoints[j].x, Math.sin(ang/180*Math.PI) * tmpPoints[j].x, base.z);
						}
						 
						addFace(createFace(facec, faceb, facea, null, uvb, uvc, uva ) );
						addFace(createFace(facec, facea, faced, null, uvb, uva, uvd ) );
						 
					}
					
					
				}
				
				ang += radstep;
				ang_inc += radstep;
				
			}
    	}
    	
    	/**
    	 * Defines the radius of the polygon. Defaults to 100.
    	 */
    	public function get radius():Number
    	{
    		return _radius;
    	}
    	
    	public function set radius(val:Number):void
    	{
    		if (_radius == val)
    			return;
    		
    		_radius = val;
    		_primitiveDirty = true;
    	}
    			
    	/**
    	 * Defines the number of sides of the polygon. Defaults to 8 (octohedron).
    	 */
    	public function get sides():Number
    	{
    		return _sides;
    	}
    	
    	public function set sides(val:Number):void
    	{
    		if (_sides == val)
    			return;
    		
    		_sides = val;
    		_primitiveDirty = true;
    	}
    			
    	/**
    	 * Defines the subdivision of the polygon. Defaults to 1.
    	 */
    	public function get subdivision():Number
    	{
    		return _subdivision;
    	}
    	
    	public function set subdivision(val:Number):void
    	{
    		if (_subdivision == val)
    			return;
    		
    		_subdivision = val;
    		_primitiveDirty = true;
    	}
    	
    	/**
    	 * Defines whether the coordinates of the polygon points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
    	 */
    	public function get yUp():Boolean
    	{
    		return _yUp;
    	}
    	
    	public function set yUp(val:Boolean):void
    	{
    		if (_yUp == val)
    			return;
    		
    		_yUp = val;
    		_primitiveDirty = true;
    	}
    	
		/**
		 * Creates a new <code>RegularPolygon</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function RegularPolygon(init:Object = null)
        {
            super(init);

            _radius = ini.getNumber("radius", 100, {min:0});
			_sides = ini.getInt("sides", 8, {min:3});
			_subdivision = ini.getInt("subdivision", 1, {min:1});
 			_yUp = ini.getBoolean("yUp", true);
			
			type = "RegularPolygon";
        	url = "primitive";
        }
    }
}