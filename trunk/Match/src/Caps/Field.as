package Caps
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Collision.Shapes.b2ShapeDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import Caps.BallEntity;
	
	import Embedded.Assets;
	
	import Framework.EntityManager;
	import Framework.ImageEntity;
	import Framework.MathUtils;
	
	import com.actionsnippet.qbox.QuickBox2D;
	import com.actionsnippet.qbox.QuickContacts;
	import com.actionsnippet.qbox.QuickObject;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//
	// El estadio 
	//
	public class Field
	{
		// Las dimensiones de la zona jugable del campo (en pixels)
		static public const SizeX:Number = 668;
		static public const SizeY:Number = 400;
		static public const HeightGoal:Number = 114;
		
		// Origen del campo (tener en cuenta que el gráfico tiene una zona de vallas, por eso no es 0,0)
		static public const OffsetX:Number = 46;
		static public const OffsetY:Number = 64;
		
		// Coordenadas de las areas del campo en coordenadas absolutas desde el corner superior izquierdo del movieclip
		static public const AreaLeftX:Number = 0 + OffsetX;
		static public const AreaLeftY:Number = 126 + OffsetY;
		static public const AreaRightX:Number = 628 + OffsetX;
		static public const AreaRightY:Number = 126 + OffsetY;
		static public const SizeAreaX:Number = 40;
		static public const SizeAreaY:Number = 148;
		// Coordenadas de las areas GRANDES del campo en coordenadas absolutas desde el corner superior izquierdo del movieclip
		static public const BigAreaLeftX:Number = 0 + OffsetX;
		static public const BigAreaLeftY:Number = 48 + OffsetY;
		static public const BigAreaRightX:Number = 548 + OffsetX;
		static public const BigAreaRightY:Number = 48 + OffsetY;
		static public const SizeBigAreaX:Number = 120;
		static public const SizeBigAreaY:Number = 304;
		
		// Coordenadas de las porterias
		private var X_GOAL_LEFT:Number = 1;
		private var X_GOAL_RIGHT:Number = 713;
		private var Y_GOAL:Number = 202;
		
		// Sensores de gol colocados en cada portería para detectar el gol
		public var GoalLeft : QuickObject = null;
		public var GoalRight : QuickObject = null;
		
		public var Visual:DisplayObjectContainer = null;					// Objeto visual del campo

		//
		// Inicializa el estadio
		// 
		public function Initialize( parent:MovieClip ) : void
		{
			// Creamos el campo
			Visual = new Embedded.Assets.Field();
			parent.addChild( Visual );
			if( AppParams.DrawBackground == false)
				Visual.visible = false;
			
			//Visual.stage.addEventListener( MouseEvent.MOUSE_DOWN, OnMouseDown );
			
			// Crea objetos físicos para gestionar el estadio
			CreatePhysicWalls();
		}
		
		//
		// Inicializa el estadio
		// 
		public function CreatePorterias( parent:MovieClip ) : void
		{
			// Creamos las porterias
			var goalLeft:ImageEntity = new ImageEntity();
			goalLeft.Init( Embedded.Assets.GoalLeft, parent );
			EntityManager.Ref.Add( goalLeft );
			goalLeft.SetPos( new Point( X_GOAL_LEFT, Y_GOAL ) );
			
			var goalRight:ImageEntity = new ImageEntity();
			goalRight.Init( Embedded.Assets.GoalRight, parent );
			EntityManager.Ref.Add( goalRight );
			goalRight.SetPos( new Point( X_GOAL_RIGHT, Y_GOAL ) );
		}
		

			
		//
		// Crea objetos físicos para gestionar el estadio
		// Límites, porterias, sensores de goles, ...
		//
		protected function CreatePhysicWalls() : void
		{
			// Calculamos los valores en coordenadas de espacio físicas 
			var sw:Number = AppParams.Screen2Physic( SizeX );
			var sh:Number = AppParams.Screen2Physic( SizeY );	
			var offsetX:Number = AppParams.Screen2Physic( OffsetX );
			var offsetY:Number = AppParams.Screen2Physic( OffsetY );
			
			// NOTE: La posición especificada tanto en cajas como círculos siempre es el centro
			// Calculamos en coordenadas físicas:
			// 	- Altura de la portería
			//	- Las mitad de la altura del campo sin porterías
			
			var heightGoal:Number = AppParams.Screen2Physic( HeightGoal );
			var halfHeightWithoutGoal:Number = AppParams.Screen2Physic( (SizeY - HeightGoal)/2 );
			var hc1:Number = offsetY + (halfHeightWithoutGoal/2);
			var hc2:Number = offsetY + AppParams.Screen2Physic( SizeY ) - (halfHeightWithoutGoal/2);
			var centerGoalLeft:Point = GetCenterGoal( Enums.Left_Side );
			var centerGoalRight:Point = GetCenterGoal( Enums.Right_Side );
			var halfBall:Number = AppParams.Screen2Physic( BallEntity.Radius/2 );
			
			// Creamos los muros que delimitan el campo 
			var phy:QuickBox2D = Match.Ref.Game.Physic;
			var fillColor:int = 0xFF0000;
			var fillAlpha:Number = 0;
			if( AppParams.Debug )
				fillAlpha = 0.5;
			
			var bCCD:Boolean = true;		// utilizar detección de colisiones continua? Aunque son estaticos lo ponemos a true, por si acaso el motor lo tiene en cuenta

			// Bottom (Utilizamos un grosor mas fino para no tapar los botones del interface)
			var grosor:Number = 0.5;
			var halfGrosor:Number = grosor * 0.5;
			
			phy.addBox({x:offsetX + sw / 2 + 0.05, restitution:1, y:offsetY+sh+halfGrosor, width: sw, height:grosor, density:.0, fillColor: fillColor, fillAlpha: fillAlpha, lineAlpha:fillAlpha, isBullet: bCCD });
			
			// Top			
			grosor = 0.50;
			halfGrosor = grosor * 0.5;
			phy.addBox({x:offsetX + sw / 2 + 0.05, restitution:1, y:offsetY+0-halfGrosor, width:sw, height:grosor,  density:.0,fillColor: fillColor, fillAlpha: fillAlpha, lineAlpha:fillAlpha, isBullet: bCCD});
			
			// Restauramos el grosor standard
			grosor = 1.5;
			halfGrosor = grosor * 0.5;
			
			// Left
			phy.addBox({x:offsetX + 0 - halfGrosor, y:hc1, restitution:1, width:grosor, height:halfHeightWithoutGoal,  density:.0, fillColor: fillColor, fillAlpha: fillAlpha, lineAlpha:fillAlpha, isBullet: bCCD});
			phy.addBox({x:offsetX + 0 - halfGrosor, y:hc2, restitution:1, width:grosor, height:halfHeightWithoutGoal,  density:.0, fillColor: fillColor, fillAlpha: fillAlpha, lineAlpha:fillAlpha, isBullet: bCCD});
			// Right
			phy.addBox({x:offsetX + sw + halfGrosor, y:hc1, restitution:1, width:grosor, height:halfHeightWithoutGoal,  density:.0, fillColor: fillColor, fillAlpha: fillAlpha, lineAlpha:fillAlpha, isBullet: bCCD});
			phy.addBox({x:offsetX + sw + halfGrosor, y:hc2, restitution:1, width:grosor, height:halfHeightWithoutGoal,  density:.0, fillColor: fillColor, fillAlpha: fillAlpha, lineAlpha:fillAlpha, isBullet: bCCD});
		
			// Muros en las porterías para que sólo rebote la chapa y no el balón (usando el mismo GroupIndex(-1) que el balón)
			phy.addBox( { groupIndex:-1, x: AppParams.Screen2Physic( centerGoalLeft.x ) - halfGrosor, y: AppParams.Screen2Physic( centerGoalLeft.y ), density: 0, width:grosor, height:heightGoal, fillColor:0xFF0000, fillAlpha:fillAlpha, lineAlpha:fillAlpha, isBullet: bCCD });
			phy.addBox( { groupIndex:-1, x: AppParams.Screen2Physic( centerGoalRight.x ) + halfGrosor, y: AppParams.Screen2Physic( centerGoalRight.y ), density: 0, width:grosor, height:heightGoal, fillColor:0xFF0000, fillAlpha:fillAlpha, lineAlpha:fillAlpha, isBullet: bCCD });
			
			// Creamos los sensores para chequear el gol
			GoalLeft = phy.addBox( { isSensor: true, x: AppParams.Screen2Physic( centerGoalLeft.x ) - halfGrosor - halfBall, y: AppParams.Screen2Physic( centerGoalLeft.y ), density: 0, width:grosor, height:heightGoal, fillColor:0xFF0000, fillAlpha:fillAlpha, lineAlpha:fillAlpha, isBullet: bCCD });
			GoalRight = phy.addBox( { isSensor: true, x: AppParams.Screen2Physic( centerGoalRight.x ) + halfGrosor + halfBall, y: AppParams.Screen2Physic( centerGoalRight.y ), density: 0, width:grosor, height:heightGoal, fillColor:0xFF0000, fillAlpha:fillAlpha, lineAlpha:fillAlpha, isBullet: bCCD });
		}
		
		//
		// Obtiene el centro del campo
		//
		static public function get CenterX( ) : Number
		{
			return( OffsetX + (SizeX * 0.5) );
		}
		static public function get CenterY( ) : Number
		{
			return( OffsetY + (SizeY * 0.5) );
		}
		
		//
		// Obtiene el punto central de la portería indicada en coordenadas de pantalla (pixels)
		//
		static public function GetCenterGoal( side:int ) : Point
		{
			var y:Number = OffsetY + SizeY / 2;
			var x:Number = OffsetX;
			
			if( side == Enums.Right_Side )
				x += SizeX;
			
			return( new Point( x, y ) );
		}
		
		//
		//
		//
		/*
		private function OnMouseDown( e: MouseEvent ) : void
		{			
		}
		*/
		
		
		// 
		// Comprobamos si una chapa está dentro de su propio area pequeña
		//
		public function IsCircleInsideArea( pos:Point, radius:Number, side:int ) : Boolean
		{
			var bInside:Boolean = false;
			
			if( side == Enums.Left_Side )
			{
				bInside = Framework.MathUtils.CircleInRect( pos, radius, new Point( AreaLeftX, AreaLeftY ), new Point( SizeAreaX, SizeAreaY ) );
			}
			else if( side == Enums.Right_Side )
			{
				bInside = Framework.MathUtils.CircleInRect( pos, radius, new Point( AreaRightX, AreaRightY ), new Point( SizeAreaX, SizeAreaY ) );
			}
			
			return( bInside );
		}
		
		// 
		// Comprobamos si una chapa está dentro de su propio area pequeña
		//
		public function IsCircleInsideBigArea( pos:Point, radius:Number, side:int ) : Boolean
		{
			var bInside:Boolean = false;
			
			if( side == Enums.Left_Side )
			{
				bInside = Framework.MathUtils.CircleInRect( pos, radius, new Point( BigAreaLeftX, BigAreaLeftY ), new Point( SizeBigAreaX, SizeBigAreaY ) );
			}
			else if( side == Enums.Right_Side )
			{
				bInside = Framework.MathUtils.CircleInRect( pos, radius, new Point( BigAreaRightX, BigAreaRightY ), new Point( SizeBigAreaX, SizeBigAreaY ) );
			}
			
			return( bInside );
		}
		
		
		// 
		// Comprobamos si una chapa está dentro de su propio area pequeña
		//
		public function IsCapInsideArea( cap:Cap ) : Boolean
		{
			return( IsCircleInsideArea( cap.GetPos(), 0 /* Cap.Radius*/, cap.OwnerTeam.Side ) );  	
		}
		
		//
		// Valida una posición (con un radio determinado) en el campo.
		// Para ser válida debe estar contenida dentro de la zona de juego del campo,
		//
		public function ValidatePos( pos:Point, radius:Number = 0 ) : Boolean
		{
			return ( Framework.MathUtils.CircleInRect( pos, radius, new Point( OffsetX, OffsetY ), new Point( SizeX, SizeY ) ) );
		}
		
		//
		// Valida una posición de chapa en el campo.
		// Para ser válida debe:
		//		- Estar contenida dentro de la zona de juego del campo 
		// 		- No colisionar con ninguna chapa
		//		- No colisionar con el balón
		//
		public function ValidatePosCap( pos:Point, checkAgainstBall:Boolean, ignoreCap:Cap = null  ) : Boolean
		{
			// Validamos contra el campo
			var bValid:Boolean = ValidatePos( pos, Cap.Radius );
			
			if( bValid )
			{
				// Validamos contra las chapas
				for each( var team:Team in Match.Ref.Game.Teams )
				{
					for each( var cap:Cap in team.CapsList )
					{
						if( cap != null && cap != ignoreCap && cap.InsideCircle( pos, Cap.Radius+Cap.Radius) == true )
							return( false );
					}
				}
			
				// Comprobamos que no colisionemos con el balón
				
				if( checkAgainstBall && Match.Ref.Game.Ball.InsideCircle( pos, Cap.Radius+BallEntity.Radius) )
					bValid = false;
			}
			
			return( bValid );
		}
		
		//
		// Mueve una chapa en una dirección validando que la posición sea correcta.
		// Si no lo consigue opcionalmente intenta situarla en intervalos dentro del vector de dirección
		// Se harán 'stepsToTry' comprobaciones
		// NOTE: stepsToTry debe ser >=1
		//
		// Devolvemos el 'intento' que fué existoso
		//   0 		-> No conseguimos situar chapa (se queda en la posición que está)
		//   1 		-> Justo en el primer intento
		//  '+n'	-> El nº de intento en el que hemos conseguido situar la chapa
		//
		public function MoveCapInDir( cap:Cap, dir:Point, amount:Number, checkAgainstBall:Boolean, stepsToTry:int = 1 ) : int		
		{
			// TODO: Assertar si stepsToTry<1
			
			var trySuccess:int = 0;		// por defecto no hemos conseguido situar la chapa 
			
			dir.normalize( 1.0 );
			
			// Intentaremos posicionar la chapa en la posición indicada, si no es válida vamos probando
			// en posiciones intermedias de la dirección indicada 
			for( var i:int = 0; i < stepsToTry; i++ )
			{
				// Calculamos la posición a la que mover la chapa
				var tryFactor:Number = 1.0 - (i / stepsToTry); 
				var dirTry:Point = new Point( dir.x * (amount * tryFactor), dir.y * (amount * tryFactor) );  
				var endPos:Point = cap.GetPos().add( dirTry );
				
				// Validamos la posición de la chapa, teniendonos en cuenta a nosotros mismos
				//  Validamos contra bandas y otras chapas, ...
				if( ValidatePosCap( endPos, checkAgainstBall, cap ) )
				{
					// Movemos la chapa a la posición y terminamos
					cap.SetPos( endPos );
					trySuccess = i+1;
					break;
				}
			}
			
			// Devolvemos el 'intento' que fué existoso
			//   0 		-> No conseguimos situar chapa
			//   1 		-> Justo en el primer intento
			//  '+n'	-> El nº de intento en el que hemos conseguido situar la chapa
			return( trySuccess );
		}
		
	}
}