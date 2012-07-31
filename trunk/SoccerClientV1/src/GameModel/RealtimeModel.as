package GameModel
{
	import GameView.ImportantMessageDialog;
	
	import NetEngine.InvokeResponse;
	import NetEngine.NetPlug;
	
	import SoccerServerV1.MainService;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.Security;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.utils.URLUtil;
	
	import org.osflash.signals.Signal;
	
	import utils.Delegate;
	import utils.GenericEvent;
	
	[Bindable]
	public final class RealtimeModel extends EventDispatcher
	{
		static public function GetDefaultURI() : String 
		{
			if (mDefaultURI == null)
				mDefaultURI = URLUtil.getServerName(FlexGlobals.topLevelApplication.url) + ":2020";

			return mDefaultURI; 
		}
		static public function SetDefaultURI(v:String) : void { mDefaultURI = v; }
		
		// El partido está listo, podemos cargar match.swf, etc
		public var MatchStarted : Signal = new Signal();
		
		// El partido ha acabado, el UI puede volver al manager.
		public var MatchEnded : Signal = new Signal(Object);
		
		
		public  function get IsConnected() : Boolean { return mIsConnected; }
		private function set IsConnected(v : Boolean) : void { mIsConnected = v; }		
		
		public function RealtimeModel(mainService : MainService, gameModel : MainGameModel)
		{
			mMainModel = gameModel;
			mMainService = mainService;
			
			mIsConnected = false;			
		}
		
		public function InitialConnection(callback : Function) : void
		{
			Connect(Delegate.create(RTMPConnectionSuccess, callback));
		}
			
		public function Connect(callback : Function) : void
		{
			if (IsConnected)
				throw "Already connected";
			
			mURI = GetDefaultURI();
			
			mServerConnection = new NetPlug();
			mServerConnection.SocketClosedSignal.add(NetPlugClosed);
			mServerConnection.SocketErrorSignal.add(NetPlugError);
			mServerConnection.SocketConnectedSignal.add(NetPlugConnected);
			
			if (callback != null)
				mServerConnection.SocketConnectedSignal.add(callback);
			
			// La policy forzamos a que la pille de 843 sin timeouts
			var completeURI : String = mURI;
			
			// Arreglo del bug de getServerName, q se salta el primer caracter si no tiene el protocolo delante
			if (completeURI.indexOf("http") != 0)
				completeURI = "http://" + completeURI;
			
			Security.loadPolicyFile("xmlsocket://" + URLUtil.getServerName(completeURI) + ":843");
			
			mServerConnection.AddClient(this);
			mServerConnection.Connect(mURI);
		}
		
		
		private function RTMPConnectionSuccess(callback : Function) : void
		{
			LogInToDefaultRoom(callback);
		}
		
		private function NetPlugConnected() : void
		{
			if (IsConnected)
				throw new Error("WTF NetPlugConnected");
			
			mLocalRealtimePlayer = new RealtimePlayer(null);
			mLocalRealtimePlayer.ClientID = -1;
			mLocalRealtimePlayer.PredefinedTeamName = mMainModel.TheTeamModel.PredefinedTeamName;
			mLocalRealtimePlayer.Name = mMainModel.TheTeamModel.TheTeam.Name;
			
			// Los detalles del equipo local los tiene el TeamModel
			BindingUtils.bindProperty(mLocalRealtimePlayer, "TheTeamDetails", mMainModel.TheTeamModel, "TheTeamDetails");
			
			dispatchEvent(new Event("LocalRealtimePlayerChanged"));

			IsConnected = true;
		}
		
		private function NetPlugClosed() : void
		{
			IsConnected=false;
			
			if (!mLegitCloseFromServer)
				ErrorMessages.ClosedConnection();
		}
				
		private function NetPlugError(reason : String) : void
		{
			ErrorMessages.RealtimeConnectionFailed();
		}
		
		public function Disconnect() : void
		{
			mServerConnection.RemoveClient(this);
			mServerConnection.Disconnect();	// Won't dispatch NetPlugClosed
			mServerConnection = null;
			IsConnected = false;
		}
			
		public function PushedDisconnected(reason : String) : void
		{
			IsConnected = false;
			
			if (reason == "Duplicated")
			{
				ErrorMessages.DuplicatedConnectionCloseHandler();
				mLegitCloseFromServer = true;
			}
			else
			if (reason == "ServerShutdown")
			{
				ErrorMessages.ServerShutdown();
				mLegitCloseFromServer = true;
			}
			else
			{
				ErrorMessages.ServerClosedConnectionUnknownReason();
			}
		}
		
		public function LogInToDefaultRoom(onSuccess : Function) : void
		{
			if (!IsConnected || mRoomModel != null)
				throw new Error("LogInToDefaultRoom - WTF");
			
			TheRoomModel = new RoomModel(mServerConnection, mMainService, mMainModel);
						
			mServerConnection.Invoke("LogInToDefaultRoom", new InvokeResponse(this, Delegate.create(OnLoginPlayerResponded, onSuccess)), 
									 SoccerClientV1.GetFacebookFacade().SessionKey);
		}
		
		private function OnLoginPlayerResponded(logged : Boolean, onSuccess : Function) : void
		{
			if (!logged)
				ErrorMessages.RealtimeLoginFailed();
			else 
			{
				if (onSuccess != null)
					onSuccess();
			}
		}
		
		public function SwitchLookingForMatch() : void
		{
			mServerConnection.Invoke("SwitchLookingForMatch", new InvokeResponse(this, SwitchLookingForMatchResponded));
		}
		
		private function SwitchLookingForMatchResponded(lookingForMatch : Boolean) : void
		{
			if (lookingForMatch != mLookingForMatch)
			{
				mLookingForMatch = lookingForMatch;
				dispatchEvent(new Event("LookingForMatchChanged"));
			}
		}
		
		[Bindable(event="LookingForMatchChanged")]
		public function get LookingForMatch() : Boolean { return mLookingForMatch; }
		public function set LookingForMatch(v:Boolean) : void { throw new Error("Use switch"); }
		
		
		// Si el comienzo de partido viene de la aceptación de un challenge, firstClientID será siempre el aceptador, y
		// secondClientID será el que lanzó el challenge
		public function PushedStartMatch(firstClientID : int, secondClientID : int) : void
		{
			mRoomModel.LogOff();
			mRoomModel = null;
			
			// Ya no estamos buscando
			SwitchLookingForMatchResponded(false);

			// Nosotros lanzamos la señal y alguien (RealtimeMatch.mxml) se encarga de cargarlo por fuera
			MatchStarted.dispatch();
		}
		
		public function OnMatchLoaded(match:DisplayObject) : void
		{
			if (mMatch != null)
				throw "WTF";
						
			mMatch = match;
						
			mMatch.addEventListener("OnMatchEnded", OnMatchEnded);					
			(mMatch as Object).Init(mServerConnection, mMainModel.TheFormationModel.GetFormationsTransformedToMatch());
		}
		
		public function OnMatchEnded(e:GenericEvent) : void
		{
			mMatch.removeEventListener("OnMatchEnded", OnMatchEnded);
			mMatch.loaderInfo.loader.unload();
			mMatch = null;		
			
			// Shall I do it?
			mMainModel.TheTeamModel.RefreshTeam(null);
			
			// De vuelta a nuestra habitación, el servidor nos deja en el limbo, como si acabáramos de conectar
			LogInToDefaultRoom(null);
			
			// Informamos a la vista
			MatchEnded.dispatch(e.Data);
		}
		
		public function ForceMatchFinish() : void
		{
			if (mMatch != null)
				(mMatch as Object).Finish();
		}
		
		public function PushedMatchUnsync() : void
		{
			Alert.show("Estado desincronizado!", "BETA");
		}
		
		public function PushedBroadcastMsg(msg : String) : void
		{
			ImportantMessageDialog.Show(msg, "¡Mensaje importante!", "center");
		}
		
		[Bindable(Event="LocalRealtimePlayerChanged")]
		public function get LocalRealtimePlayer() : RealtimePlayer { return mLocalRealtimePlayer; }
						
		public function  get TheRoomModel() : RoomModel { return mRoomModel; }
		private function set TheRoomModel(v:RoomModel) : void { mRoomModel = v; }
		

		private var mServerConnection:NetPlug;
		private var mURI : String;
		private var mIsConnected : Boolean = false;
		
		private var mMainModel : MainGameModel;
		private var mMainService : MainService;
		
		private var mMatch : DisplayObject;
		private var mRoomModel : RoomModel;
		
		private var mLocalRealtimePlayer : RealtimePlayer;		
		private var mLegitCloseFromServer : Boolean = false; // Para evitar lanzar el error dos veces
		private var mLookingForMatch : Boolean = false;
		
		static private var mDefaultURI : String;
	}
}