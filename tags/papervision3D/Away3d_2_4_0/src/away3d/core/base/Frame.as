﻿package away3d.core.base
{
	/**
	 * Holds vertexposition information about a single animation frame.
	 */
    public class Frame implements IFrame
    {
    	/**
    	 * An array of vertex position objects.
    	 */
        public var vertexpositions:Array = [];
    	
		/**
		 * Creates a new <code>Frame</code> object.
		 */
        public function Frame()
        {
        }
        
		/**
		 * @inheritDoc
		 */
        public function adjust(k:Number = 1):void
        {
			var vertexposition:VertexPosition;
            for each (vertexposition in vertexpositions) {
                vertexposition.adjust(k);
            }
        }
		
		// temp undocumented patch for missing indexes on md2 files and as3 outputs for as3exporters
		public function getIndexes(vertices:Array):Array
        {
			var indexes:Array = [];
			var vertexposition:VertexPosition;
            for each (vertexposition in vertexpositions) {
                indexes.push(vertexposition.getIndex(vertices));
            }
			return indexes;
        }
    }
}