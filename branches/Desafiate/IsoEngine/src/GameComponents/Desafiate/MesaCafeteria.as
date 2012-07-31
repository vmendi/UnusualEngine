package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	
	import flash.geom.Point;
	
	import gs.TweenLite;
	
	import utils.Delegate;

	public class MesaCafeteria extends GameComponent
	{
		public var BalloonX : Number = 0;
		public var BalloonY : Number = 0;
		public var Ocupante : String = "";
		
		override public function OnPreStart():void
		{
			mBalloon = TheGameModel.CreateSceneObjectFromMovieClip("mcBalloon", "Balloon") as Balloon;
		}

		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;

			mBalloon.SetColor(0xf3faf3);
			mBalloon.SetBalloon(350, new Point(BalloonX, BalloonY));
			mBalloon.FollowObject(TheVisualObject);
			mBalloon.TheVisualObject.visible = false;
			
			if (mStatus.Checkpoint == Checkpoints.INTER02 || mStatus.Checkpoint == Checkpoints.TM03_START || mStatus.Checkpoint == Checkpoints.END)
			{
				TheVisualObject.gotoAndStop("empty");
				TheVisualObject.InteractiveArea.visible = false;	
			}
		}
		
		override public function OnStartComplete():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
		}

		public function Talk(speech : Array, callback : Function) : void
		{
			mBalloon.SetSpeech(speech, Delegate.create(OnTalkEnd, callback));
		}
		
		private function OnTalkEnd(callback : Function):void
		{
			if (callback != null)
				callback();
		}
		
		public function OnCharacterInteraction(target:SceneObject):void
		{
			if (target != TheSceneObject)
				return;
			
			switch (Ocupante)
			{
				case "Pareja":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTER01:
							Talk(["Hola, ya nos hemos enterado de tu logro en el departamento comercial.",3000,
								  "Todo el mundo está muy contento con el nuevo Windows 7.",3000,
								  "Si tenemos cualquier problema ya sabemos a quién llamar :-)", 3000], null);
						break;
						case Checkpoints.TM02_START:
							Talk(["¿No te has enterado? Hay un lío increíble con los servidores. ¡Te necesitan!", 3000], null);
						break;
					}
				break;
				case "Laptop":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTER01:
							if (TheGameModel.FindGameComponentByShortName("MiniGameManager").GetScoreForMiniGame("PowerShellBug") > 0)
							{
								Talk(["Gracias por ayudarme antes con el PowerShell.",3000], null);
							}
							else
							{						
								mCharacter.MouseControlled = false;
								Talk(["Hola, aquí me tienes liado con PowerShell. La verdad es que es una pasada.",3000,
									  "Sin embargo no consigo hacer funcionar este script.", 2000,
								  	  "Podrías echarle un vistazo, tú que eres un gurú de todo esto.",3000], Delegate.create(LaunchPowerShellGame));
							}
						break;
						case Checkpoints.TM02_START:
							Talk(["¡Revisa tus mensajes! Tienes que ocuparte de un problema urgente.", 3000], null);
						break;				
					}
				break;
			}
		}
		
		private function LaunchPowerShellGame():void
		{
			TheGameModel.FindGameComponentByShortName("MiniGameManager").PlayMiniGame("PowerShellBug", OnPowerShellBugEnd);
		}
		
		private function OnPowerShellBugEnd(score:int):void
		{
			if (score == -1)
			{
				Talk(["¿Y tu eres el gurú?. Seguiré intentándolo por mi cuenta.", 3000], UnFreezeCharacter);
			}
			else
			{
				Talk(["¡Perfecto, muchas gracias! Acabas de ganar 1000 Puntos Geek.", 3000], ShowLogro);
			}
		}
		
		private function ShowLogro():void
		{	
			mStatus.AddLogro("Codigo");
			TweenLite.delayedCall(5, UnFreezeCharacter);
		}
		
		private function UnFreezeCharacter():void
		{
			mCharacter.MouseControlled = true;	
		}
				
		private var mStatus : GameStatus;
		private var mBalloon : Balloon;
		private var mMainCafeteria : MainCafeteria;
		private var mCharacter : Character;
	}
}