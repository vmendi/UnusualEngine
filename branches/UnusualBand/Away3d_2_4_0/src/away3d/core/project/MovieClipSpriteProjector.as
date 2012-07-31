﻿package away3d.core.project
{
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.sprites.*;
	
	import flash.display.*;
	import flash.utils.*;
	
	public class MovieClipSpriteProjector implements IPrimitiveProvider
	{
		private var _view:View3D;
		private var _drawPrimitiveStore:DrawPrimitiveStore;
		private var _movieClipSprite:MovieClipSprite;
		private var _lens:ILens;
		private var _movieclip:DisplayObject;
		private var _screenVertices:Array;
        private var _screenX:Number;
        private var _screenY:Number;
        private var _screenZ:Number;
        
        public function get view():View3D
        {
        	return _view;
        }
        public function set view(val:View3D):void
        {
        	_view = val;
        	_drawPrimitiveStore = view.drawPrimitiveStore;
        }
      
		public function primitives(source:Object3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):void
		{
			_screenVertices = _drawPrimitiveStore.getScreenVertices(source.id);
			
			_movieClipSprite = source as MovieClipSprite;
			
			_lens = _view.camera.lens;
			
			_movieclip = _movieClipSprite.movieclip;
			
			_lens.project(viewTransform, _movieClipSprite.center, _screenVertices);
            
            _screenX = _screenVertices[0];
            _screenY = _screenVertices[1];
            _screenZ = (_screenVertices[2] += _movieClipSprite.deltaZ);
			
			if(_movieClipSprite.align != "none"){
				switch(_movieClipSprite.align){
					case "center":
						_screenX -= _movieclip.width/2;
						_screenY -= _movieclip.height/2;
						break;
					case "topcenter":
						_screenX -= _movieclip.width/2;
						break;
					case "bottomcenter":
						_screenX -= _movieclip.width/2;
						_screenY -= _movieclip.height;
						break;
					case "right":
					   _screenX -= _movieclip.width;
					   _screenY -= _movieclip.height/2;
					  break;
					case "topright":
						_screenX -= _movieclip.width;
						break;
					case "bottomright":
						_screenX -= _movieclip.width;
						_screenY -= _movieclip.height;
						break;
					case "left":
						_screenY -= _movieclip.height/2;
						break;
					case "topleft":
						break;
					case "bottomleft":				
						_screenY -= _movieclip.height;
						break;
				}
			}
			
			if(_movieClipSprite.rescale)
				_movieclip.scaleX = _movieclip.scaleY = _movieClipSprite.scaling*view.camera.zoom / (1 + _screenZ / view.camera.focus);
			
            consumer.primitive(_drawPrimitiveStore.createDrawDisplayObject(source, _screenX, _screenY, _screenZ, _movieClipSprite.session, _movieclip));
		}
	}
}