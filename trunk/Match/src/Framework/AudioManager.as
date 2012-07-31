package Framework
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;	
	
	//
	// Sistema para reproducir sonido y música y contener la libreria de los mismos
	// TODO:
	//		- No podemos controlar la polifonia
	//		- Los sonidos ciclicos deberían siempre almacenarse para luego poder detenerlos
	//		- Al destruir no se detienen todos los sonidos (sobre todo son importantes los cíclicos)
	//
	public class AudioManager
	{
		static public const Cyclic:int = int.MAX_VALUE;					// Reproduce un sonido ciclicamente (infinitas veces)
		
		static private var Sounds:Array = new Array();
		
		static private var Music:SoundChannel = null;					// El objeto de música que se está reproduciendo
		
		// TODO: Diferenciar entre música y efectos de sonido
		static public var GlobalVolume:Number = 1.0;					// Volumen global (0 - 1), todos los sonidos se ven afectado por este volumen  
		

		//
		// Crea la instancia de sonido desde una clase concreta.
		// Luego registra el sonido con un identificador, de tal forma que posteriormente podamos manejarlo a través del mismo
		// El identificador debe ser único.
		//
		static public function AddClass( identifier:String, classSound:Class ) : void
		{
			var sound:Sound = new classSound() as Sound;
			AddSound( identifier, sound );
		}
		
		//
		// Registra un sonido con un identificador, de tal forma que posteriormente podamos manejarlo a través del mismo
		// El identificador debe ser único.
		//
		static protected function AddSound( identifier:String, sound:Sound) : void
		{
			if( Find( identifier ) == null )
			{
				Sounds[identifier] = sound;
				if( sound == null )
					trace( "Warning: AudioManager.AddSound: Se añadio un sonido NULL con nombre " + identifier );
			}
			else
				trace( "Warning: AudioManager.AddSound: Ya está registrado el sonido " + identifier );
		}
		
		//
		// Obtiene un sonido a partir de su identificador
		//
		static protected function Find( identifier:String ) : Sound
		{
			return( Sounds[ identifier ] );
		}

		//
		// Reproduce un sonido determinado a partir de su identificador con un volumen específico y devuelve la instancia del sonido en reproduccion
		// loops: Indica el número de veces que se repite el sonido. AudioManager.Cyclic para infinitas reproducciones
		// Notes: Se lanza una nueva instancia de sonido, quiere decir que sucesivos Plays antes que que termine el primero, 
		// lanzaran sonidos simultáneos
		//
		public static function Play( identifier:String, loops:int = 0, vol:Number = 1.0 ) : SoundChannel
		{
			var sound:Sound = Find( identifier );
			return( PlaySound( sound, loops, vol ) ); 
		}

		//
		// Reproduce un sonido determinado con un volumen específico y devuelve la instancia del sonido en reproduccion
		// Tiene en cuenta el volumen global
		// The volume, ranging from 0 (silent) to 1 (full volume).
		// loops: Indica el número de veces que se repite el sonido. AudioManager.Cyclic para infinitas reproducciones
		//
    	static protected function PlaySound( sound:Sound, loops:int = 0, vol:Number = 1.0) : SoundChannel
    	{
			var instance:SoundChannel = null;
    		
			if( sound != null )
    		{
	    		var soundTransform:SoundTransform;
	    		
	    		soundTransform = new SoundTransform();    		
	    		soundTransform.volume = vol * GlobalVolume;
	    		
	    		// Reproduce un sonido y devuelve un SoundChannel
				instance = sound.play(0, loops, soundTransform);
			}
			
			return( instance );
    	}
		
		//
		// Reproduce la música : La música siempre se reproduce ciclicamente
		//   - Solo puede haber una misma música al mismo tiempo, si se estaba reproduciendo otra se detiene
		// 
		// NOTE: además se guarda la instancia para cuando destruyamos el sistema detenerla
		//
		static public function PlayMusic( identifier:String, vol:Number = 1.0) : SoundChannel
		{
			StopMusic();
			Music = Play( identifier, Cyclic, vol );
			return( Music );
		}
		
		//
		// Detiene la música que se está reproduciendo
		//
		static public function StopMusic( ) : void
		{
			if( Music != null )
			{
				Music.stop();
				Music = null;
			}
		}
		
		//
		// Destruye todos los sonidos 
		//
		static public function Shutdown( ) : void
		{
			// Detenemos la música
			StopMusic();
			
			// Es un objeto estático, debe existir siempre.
			// Para que se destruya el contenido del objeto lo recreamos!
			Sounds = new Array();		
		}
	}
}