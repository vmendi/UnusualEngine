package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	import GameComponents.IsoComponent;

	import Model.SceneObject;

	import flash.geom.Point;

	import gs.TweenLite;

	import utils.Delegate;
	import utils.GenericEvent;
	import utils.MovieClipListener;
	import utils.Point3;

	public class DesafiateCharacter extends GameComponent
	{
		override public function OnPreStart():void
		{
			mBalloon = TheGameModel.CreateSceneObjectFromMovieClip("mcBalloon", "Balloon") as Balloon;
			mGroundNavOK = TheGameModel.CreateSceneObjectFromMovieClip("mcGroundNavOK", "IsoComponent") as IsoComponent;
			mGroundNavOK.TheVisualObject.visible = false;

			MovieClipListener.AddFrameScript(mGroundNavOK.TheVisualObject, "end", OnGroundNavAnimEnd);
		}
		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;

			mBalloon.FollowObject(TheVisualObject);
			mBalloon.SetBalloon(250, new Point(35,-100));
		}

		override public function OnStartComplete():void
		{
			mTelevision = TheGameModel.FindGameComponentByShortName("Television") as Television;
			mCharacter = TheAssetObject.FindGameComponentByShortName("Character") as Character;
			mMainSalaTrabajo = TheGameModel.FindGameComponentByShortName("MainSalaTrabajo") as MainSalaTrabajo;
			mMainSalaIT = TheGameModel.FindGameComponentByShortName("MainSalaIT") as MainSalaIT;

			mCharacter.addEventListener("NavigationStart", OnNavigationStart);
		}

		private function OnGroundNavAnimEnd():void
		{
			mGroundNavOK.TheVisualObject.visible = false;
		}

		public function Seat(target:SceneObject):void
		{
			if (!mSeated)
			{
				mCharacter.TheVisualObject.visible = false;
				mSeated = true;
				mCouch = target;
				target.TheVisualObject.gotoAndPlay("seat");
				MovieClipListener.AddFrameScript(target.TheVisualObject, "dream", OnDream);
			}
		}

		public function StandUp():void
		{
			if (mSeated)
			{
				mCouch.TheVisualObject.gotoAndStop("empty");
				mCharacter.TheVisualObject.visible = true;
				mSeated = false;
			}
		}

		public function OnCharacterInteraction(target:SceneObject):void
		{
			switch(target.Name)
			{
				// *** RECEPCIÓN ***
				case "Sillon":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTRO:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Ahora no es el momento de descansar, quizá más tarde.",3500], null);
						break;
						case Checkpoints.INTER01:
							Seat(target);
						break;
						case Checkpoints.TM02_START:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Ahora no es el momento de descansar, tengo que ocuparme de los servidores.",3500], null);
						break;
						case Checkpoints.INTER02:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Preferiría no sentarme, que luego pasa lo que pasa.",3000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Ahora no es el momento de descansar, hay una urgencia en la sala de reuniones.",3500], null);
						break;
					}
				break;
				case "RecepcionTelevisor":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTRO:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["No tengo tiempo de ver la tele, me esperan en la sala de IT", 2000], null);
						break;
						case Checkpoints.TM02_START:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Ahora no tengo tiempo de ver la tele, tengo que ocuparme de los servidores.", 2000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Ahora no tengo tiempo de ver la tele, tengo que ocuparme del problema en la sala de reuniones.",3500], null);
						break;
						default:
							mTelevision.TurnOn();
						break;
					}
				break;
				// *** SALA DE IT ***
				case "Rack01":
				case "Rack02":
				case "Rack03":
				case "Rack04":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTRO:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Será mejor que hable con el jefe de IT antes de tocar nada.", 2000], null);
						break;
						case Checkpoints.TM01_START:
						case Checkpoints.INTER01:
							mBalloon.SetBalloon(250, new Point(35,-100));
							var rackMessages : Array= [["Con las capacidades de consolidación y virtualización de Windows Server 2008 R2...", 3000, "...podríamos reducir el número de máquinas...", 2000, "...disminuyendo así las emisiones de CO2 y los gastos energéticos.",2500],
												["No me quiero imaginar el tiempo que consume la gestión de estos servidores.", 3000, "Con Windows Server 2008 R2 reduciríamos la carga administrativa...", 2500, "...y el esfuerzo dedicado a las tareas operativas más habituales.",2500],
												["Con todas estas máquinas y sistemas distintos, si pasa cualquier imprevisto, me va a tocar sufrir.",3000],
												["No creo que los sistemas de alimentación eléctrica permitan instalar nuevos equipos aquí.", 3000, "Cambiando a Windows Server 2008 R2 podríamos disponer de más servidores...", 2500, "...con el mismo, o incluso menos, consumo eléctrico que antes.",2500]
											   ];
							var idxToMsg : int = Math.floor(Math.random()*rackMessages.length);
							Talk(rackMessages[idxToMsg], null);

							// ATLAS
							if (idxToMsg == 0)
								AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/235604535/direct/01/");
							else
							if (idxToMsg == 1)
								AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/235604536/direct/01/");
							else
							if (idxToMsg == 3)
								AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/235604537/direct/01/");

						break;
						case Checkpoints.TM02_START:
							if (!mMainSalaIT.PlayingTM)
							{
								mBalloon.SetBalloon(250, new Point(35,-100));
								Talk(["¡Uff! Esto no pinta bien.", 2000], null);
							}
						break;
						case Checkpoints.INTER02:
							if (!mMainSalaIT.PlayingTM)
							{
								mBalloon.SetBalloon(250, new Point(35,-120));
								Talk(["Gracias a Windows Server 2008 R2 hemos reducido el número de máquinas.", 3000, "Así hemos conseguido reducir las emisiones de CO2 y los gastos energéticos.", 3000], null);

								AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033939/direct/01/");
							}
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(250, new Point(35,-120));
							Talk(["Todo funciona perfectamente, así que debería atender la urgencia que hay en la sala de reuniones.", 3000], null);
						break;
					}
				break;
				case "RackConsola":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTRO:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Será mejor que hable con el jefe de IT antes de tocar nada.", 2000], null);
						break;
						case Checkpoints.TM01_START:
						case Checkpoints.INTER01:
							mBalloon.SetBalloon(300, new Point(35,-100));
							Talk(["Con Hyper-V integrado y Live Migration...", 2000,
								  "...podríamos conectar a los usuarios con los recursos sin tener que establecer una VPN.", 3000,
								  "Y todo controlado desde una única pantalla.", 2000], null);

							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033922/direct/01/");
						break;
						case Checkpoints.TM02_START:
							if (!mMainSalaIT.PlayingTM)
							{
								mBalloon.SetBalloon(250, new Point(35,-100));
								Talk(["¡Uff! Esto no pinta bien.", 2000], null);
							}
						break;
						case Checkpoints.INTER02:
							mBalloon.SetBalloon(250, new Point(35,-120));
							Talk(["Gracias a Windows Server 2008 R2 hemos reducido el número de máquinas.", 3000, "Así hemos conseguido reducir las emisiones de CO2 y los gastos energéticos.", 3000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(250, new Point(35,-120));
							Talk(["Todo funciona perfectamente, así que debería atender la urgencia que hay en la sala de reuniones.", 3000], null);
						break;
					}
				break;
				case "PuertaCerrada":
					mBalloon.SetBalloon(250, new Point(-225,-80));
					Talk(["Está cerrada", 1500], null);
				break;
				case "JefeIT":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.TM01_START:
							mBalloon.SetBalloon(250, new Point(25,-90));
							Talk(["La silla del jefe parece más cómoda que la mía.", 2000], null);
						case Checkpoints.TM02_START:
							if (!mMainSalaIT.PlayingTM)
							{
								mBalloon.SetBalloon(250, new Point(25,-90));
								Talk(["El jefe no está, así que no podrá sacarme de esta.", 2500], null);
							}
						break;
						case Checkpoints.INTER02:
							mBalloon.SetBalloon(250, new Point(25,-90));
							Talk(["Se va a llevar una sorpresa cuando vuelva.", 2000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(250, new Point(35,-120));
							Talk(["El jefe no puede antender la urgencia que tienen en la sala de reuniones, pero yo si.", 3000], null);
						break;
					}
				break;
				case "MesaOrdenador":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTRO:
							mBalloon.SetBalloon(250, new Point(25,-90));
							Talk(["Vaya desorden. Me gustaría saber de quién es esta mesa.", 2000], null);
						break;
						case Checkpoints.TM01_START:
							mBalloon.SetBalloon(250, new Point(-300,-200));
							Talk(["Mmm… Si usara Microsoft System Center podría gestionar todo el centro de proceso de datos desde mi puesto.", 3500], null);

							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033923/direct/01/");
						break;
						case Checkpoints.INTER02:
							mBalloon.SetBalloon(250, new Point(-300,-200));
							Talk(["Gracias a Microsoft System Center puedo gestionar todo el centro de datos desde mi puesto.", 3500], null);

							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033944/direct/01/");
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(250, new Point(35,-140));
							Talk(["Todo funciona perfectamente, así que debería atender la urgencia que hay en la sala de reuniones.", 3000], null);
						break;
					}
				break;
				case "Arcade":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTER02:
							mBalloon.SetBalloon(250, new Point(-300,-200));
							Talk(["Gracias a Windows Server 2008 R2 hemos reducido el número de servidores.", 3000, "Con el espacio que hemos ganado hemos instalado este videojuego ¡increíble!", 3000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(250, new Point(35,-140));
							Talk(["Este juego es increíble, pero debería atender la urgencia que hay en la sala de reuniones.", 3000], null);
						break;
					}
				break;
				// *** SALA DE TRABAJO ***
				case "WaterCooler":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.TM01_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No es el momento de detenerme a beber agua, me espera el Director Comercial.", 3000], null);
						break;
						case Checkpoints.TM02_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No es el momento de detenerme a beber agua, tengo que solucionar el problema con los servidores.", 3000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No es el momento de detenerme a beber agua, tengo que solucionar el problema que tienen arriba.", 3000], null);
						break;
						default:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["Nunca me he fiado de estos aparatos.", 2500], null);
						break;
					}
				break;
				case "VendingCafe":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.TM01_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["Debería ir a hablar con el Director Comercial, parece que tienen problemas.", 3000], null);
						break;
						case Checkpoints.TM02_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["¿Café ahora? El problema con los servidores parece urgente, debería solucionarlo.", 3000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["¿Café? El problema que tienen arriba parece urgente, debería solucionarlo.", 3000], null);
						break;
						default:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["El café me pone nervioso.", 2500], null);
						break;
					}
				break;
				case "EstanteriaSoft":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.TM01_START:
							if (!mMainSalaTrabajo.PlayingTM)
							{
								mBalloon.SetBalloon(300, new Point(40,-120));
								Talk(["No es el momento de detenerme a beber agua, me espera el Director Comercial.", 3000], null);
							}
						break;
						default:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["Gracias a Windows 7 todo este software de terceros funciona mucho mejor en todos los puestos.", 3500], null);

							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033929/direct/01/")
						break;
					}
				break;
				// **** CAFETERÍA ***
				case "CafeteriaVendingComida":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTER01:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["Uy, a esta máquina le pasa algo raro.", 2000], null);
						break;
						case Checkpoints.TM02_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No tengo tiempo de tomar nada. Tengo que solucionar el problema con los servidores.", 3000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No tengo tiempo de tomar nada. Debería solucionar el problema que tienenen la sala de reuniones.", 3000], null);
						break;
					}
				break;
				case "CafeteriaVendingBebida":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.TM02_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No tengo tiempo de tomar nada. Tengo que solucionar el problema con los servidores.", 3000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No tengo tiempo de tomar nada. Debería solucionar el problema que tienenen la sala de reuniones.", 3000], null);
						break;
						default:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No me apetece nada de aquí.", 2000], null);
						break;
					}
				break;
				case "CafeteriaWaterCooler":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.TM02_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No es el momento de detenerme a beber agua, tengo que solucionar el problema con los servidores.", 3000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No es el momento de detenerme a beber agua, tengo que solucionar el problema que tienen arriba.", 3000], null);
						break;
						default:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["Nunca me he fiado de estos aparatos.", 2000], null);
						break;
					}
				break;
				case "CafeteriaVendingCafe":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.TM02_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["¿Café ahora? El problema con los servidores parece urgente, debería solucionarlo.", 3000], null);
						break;
						case Checkpoints.TM02_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["¿Café? El problema que tienen arriba parece urgente, debería solucionarlo.", 3000], null);
						break;
						default:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["El café me pone nervioso.", 2000], null);
						break;
					}
				break;
				// *** DIRECCIÓN ***
				case "DireccionSillas":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTER02:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No me parece apropiado: no me ha invitado a sentarme.", 3000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No es el momento de sentarme, tengo una misión que cumplir.", 3000], null);
						break;
					}
				break;
				case "DireccionSillon":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTER02:
							//mBalloon.SetBalloon(300, new Point(40,-120));
							//Talk(["Parecen cómodos.", 2000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(300, new Point(40,-120));
							Talk(["No es el momento, tengo una misión que cumplir.", 3000], null);
						break;
					}
				break;
			}
		}

		public function Talk(speech : Array, callback : Function):void
		{
			mCallBack = callback;
			mSpeech = speech;
			TalkLoop(0);
		}

		public function SetBalloon(width : Number, displacement: Point):void
		{
			mBalloon.SetBalloon(width, displacement);
		}

		private function TalkLoop(step : Number):void
		{
			switch (step)
			{
				case 0:
					//TheVisualObject.mcRecepcionista.gotoAndPlay("talk_loop");
					mBalloon.SetSpeech(mSpeech, Delegate.create(TalkLoop, 1));
				break;
				case 1:
					//TheVisualObject.mcRecepcionista.gotoAndPlay("talk_end");
					if (mCallBack != null)
						mCallBack();
				break;
			}
		}

		private function OnNavigationStart(e:GenericEvent):void
		{
			mBalloon.StopDialog();
			if (mSeated)
				StandUp();

			mGroundNavOK.TheVisualObject.visible = true;
			mGroundNavOK.TheVisualObject.gotoAndPlay("start");

			//mGroundNavOK.WorldPos = GameModel.GetSnappedWorldPos(e.Data as Point3);
			mGroundNavOK.WorldPos = e.Data as Point3;
		}

		private function OnDream():void
		{
			var miniGameManager : MiniGameManager = TheGameModel.FindGameComponentByShortName("MiniGameManager") as MiniGameManager;
			if (miniGameManager.GetNumTimesPlayed("SuenoDelGeek") >= 8)
			{
				mCouch.TheVisualObject.gotoAndStop("seat");
				Talk(["¡Prefiero no dormirme! Todavía tengo muchas cosas que hacer.", 3000], null);
			}
			else
			{
				mCharacter.MouseControlled = false;
				miniGameManager.PlayMiniGame("SuenoDelGeek", OnDreamEnd);
			}
		}

		private function OnDreamEnd(score : Number):void
		{
			mCouch.TheVisualObject.gotoAndStop("seat");
			if (score == -1)
			{
				Talk(["¡Ufff! Menudo sueño. Espero que nadie me haya visto quedarme dormido.", 3000], UnFreezeCharacter);
			}
			else if (score == 0)
			{
				Talk(["¡Ufff! Menudo sueño. Espero que nadie me haya visto quedarme dormido.", 3000], UnFreezeCharacter);
			}
			else
			{
				Talk(["¡Ufff! Menudo sueño. Espero que nadie me haya visto quedarme dormido.", 3000, "Al menos he ganado " + score +  " puntos geek.", 3000], ShowLogro);
			}
		}

		private function ShowLogro():void
		{
			mStatus.AddLogro("Empollon");
			TweenLite.delayedCall(5, UnFreezeCharacter);
		}

		private function UnFreezeCharacter():void
		{
			mCharacter.MouseControlled = true;
		}

		[NonSerializable]
		public function set GrabbedObject(objectName : String):void
		{
			if (objectName != null)
			{
				TheVisualObject.mcIconoTM.visible = true;
				TheVisualObject.mcIconoTM.gotoAndStop(objectName);
			}
			else
				TheVisualObject.mcIconoTM.visible = false;
		}
		public function get GrabbedObject() : String
		{
			return TheVisualObject.mcIconoTM.visible? TheVisualObject.mcIconoTM.currentLabel : null;
		}


		private var mCharacter : Character;
		private var mBalloon : Balloon;
		private var mSeated : Boolean = false;
		private var mStatus : GameStatus;
		private var mMainFase : GameComponent;
		private var mCouch : SceneObject;
		private var mCallBack : Function;
		private var mSpeech : Array;
		private var mTelevision : Television;
		private var mGroundNavOK : IsoComponent;
		private var mMainSalaTrabajo : MainSalaTrabajo;
		private var mMainSalaIT : MainSalaIT;
	}
}