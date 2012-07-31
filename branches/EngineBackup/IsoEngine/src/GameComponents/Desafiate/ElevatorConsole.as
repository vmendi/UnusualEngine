package GameComponents.Desafiate
{
	import GameComponents.Bso;
	import GameComponents.GameComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import utils.Delegate;
	import utils.MovieClipListener;

	public class ElevatorConsole extends GameComponent
	{
		override public function OnPreStart():void
		{
			mBalloon = TheGameModel.CreateSceneObjectFromMovieClip("mcBalloonOverlay", "Balloon") as Balloon;
		}

		override public function OnStart():void
		{
			mInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;

			TheVisualObject.gotoAndStop("empty");
			TheVisualObject.visible = false;

			mBalloon.FollowObject(TheVisualObject);
			mBalloon.SetBalloon(450, new Point(-60,-75));
		}

		public function Show():void
		{
			mInterface.ShowAll(false);
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndPlay("show");
			MovieClipListener.AddFrameScript(TheVisualObject, "showEnd", OnShowEnd);
			TheGameModel.PauseGame(true);
			
			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/Ascensor.mp3");
		}

		private function OnShowEnd():void
		{
			TheVisualObject.stop();
			TheVisualObject.btClose.addEventListener(MouseEvent.CLICK, OnCloseClick);

			TheVisualObject.btSalaIT.addEventListener(MouseEvent.CLICK, Delegate.create(OnGoto, "SalaIT"));
			TheVisualObject.btRecepcion.addEventListener(MouseEvent.CLICK, Delegate.create(OnGoto, "Recepcion"));
			TheVisualObject.btSalaTrabajo.addEventListener(MouseEvent.CLICK, Delegate.create(OnGoto, "SalaTrabajo"));
			TheVisualObject.btConferencias.addEventListener(MouseEvent.CLICK, Delegate.create(OnGoto, "Conferencias"));
			TheVisualObject.btCafeteria.addEventListener(MouseEvent.CLICK, Delegate.create(OnGoto, "Cafeteria"));
			TheVisualObject.btDireccion.addEventListener(MouseEvent.CLICK, Delegate.create(OnGoto, "Direccion"));
		}

		private function OnCloseClick(e:Event):void
		{
			mBalloon.StopDialog();
			TheVisualObject.visible = false;
			TheVisualObject.gotoAndPlay("hide");
			TheGameModel.PauseGame(false);
			mInterface.ShowAll(true);
			
			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/General.mp3");
		}

		private function OnGoto(e:MouseEvent, donde : String):void
		{
			switch (mStatus.Checkpoint)
			{
				case Checkpoints.INTRO:
					// En la intro sólo podemos ir a la sala de IT
					if (donde!="SalaIT")
					{
						mBalloon.SetSpeech(["Debería hablar con el responsable de IT antes de nada.", 3000], null, false);
						return;
					}
				break;
				case Checkpoints.TM01_START:
					// Sólo podemos ir a la sala de trabajo
					if (donde!="SalaTrabajo")
					{
						mBalloon.SetSpeech(["Debería ocuparme de la alerta que he recibido, parecía urgente.", 3000], null, false);
						return;
					}
				break;
				case Checkpoints.INTER01:
					// Podemos ir a todas partes, excepto a la sala de reuniones y al despacho de dirección
					if (donde=="Conferencias")
					{
						mBalloon.SetSpeech(["Se está celebrando una reunión, mejor no molestar.", 3000], null, false);
						return;
					}
					else if (donde=="Direccion")
					{
						mBalloon.SetSpeech(["No es el momento de visitar al jefazo, esperaré a que me llame.", 3000], null, false);
						return;
					}
				break;
				case Checkpoints.TM02_START:
					// Sólo podemos ir a la sala de IT
					if (donde!="SalaIT")
					{
						mBalloon.SetSpeech(["Debería ir a la Sala de IT a ver qué problema hay con los servidores.", 3000], null, false);
						return;
					}
				break;
				case Checkpoints.INTER02:
					if (donde=="Conferencias")
					{
						mBalloon.SetSpeech(["Se está celebrando una reunión, mejor no molestar.", 3000], null, false);
						return;
					}
				break;
				case Checkpoints.TM03_START:
					if (donde!="Conferencias")
					{
						mBalloon.SetSpeech(["En la sala de reuniones tienen problemas. Debería ir a ver qué pasa.", 3000], null, false);
						return;
					}
				break;
			}
			TheGameModel.TheIsoEngine.Load("Maps/Desafiate/"+donde+".xml");
		}

		private var mInterface : DesafiateInterface;
		private var mBalloon : Balloon;
		private var mStatus : GameStatus;
	}
}