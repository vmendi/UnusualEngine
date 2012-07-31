using System;
using System.Diagnostics;

using Weborb.Util.Logging;
using System.Collections.Generic;


namespace SoccerServerV1
{
    public class RealtimeMatch
    {
        protected class ClientState
        {
            public int ShootCount = 0;
            public string []Client  = { "", "" };
        }

        public const string PLAYER_1 = "player1";
        public const string PLAYER_2 = "player2";
        const int Player1 = 0;                                  // identificador para el player 1
        const int Player2 = 1;                                  // identificador para el player 2
        const int PlayerCount = 2;                              // Contador de jugadores
        const int Invalid = (-1);                               // identificador inválido

        public const String MATCHLOG = "MATCH";
        public const String MATCHLOG_DEBUG = "MATCH DEBUG";
        public const bool DebugClientState = true;                  // Depura el estado del partido de cada cliente cada vez que se efectúa un shoot

        protected List<ClientState> TheClientState = new List<ClientState>();    // Estado de los clientes representado en cadena
        public int ShootCount = 0;                              // Contabiliza el numero de disparos en todo el partido
        
        public const int MinClientVersion = 106;                    // Versión mínima que exigimos a los clientes para jugar
        public const int ServerVersion = 101;                       // Versión del servidor

        enum State
        {
            WaittingPlayers,                        // Esperando que los jugadores estén listos
            Playing,                                // Estamos jugando
            End
        }

        // Las diferentes habilidades especiales
        enum SkillType
        {
            Superpotencia = 1,
            Furiaroja,
            Catenaccio,
            Tiroagoldesdetupropiocampo,
            Tiempoextraturno,
            Turnoextra,
            CincoEstrellas,
            Verareas,
            Manodedios,
        }

        public class SkillState
        {
            public bool InUse = false;                     // Indica si el skill está en uso
            public float LastTimeUsed = 0;                 // Indica cuando fué la última vez que se utilizó el skill, para determinar si es posible utilizarlo otra vez
        }

        // Define el estado de los jugadores
        public class PlayerState
        {
            public bool TiroPuerta = false;                                     // Ha declarado tiro a puerta?
            public int ScoredGoals = 0;                                         // Goles que ha metido el equipo
            public SkillState[] Skills = new SkillState[SkillsCount + 1];       // El skill 0 no se  utiliza 1 - 9

            public PlayerState()
            {
                for (int i = 1; i <= SkillsCount; i++)
                    Skills[i] = new SkillState();
            }
        }

        const int SkillsCount = 9;                              // Contador de habilidades especiales

        Realtime MainRT = null;                                 // Objeto que nos ha creado

        int PlayerIdAbort = Invalid;                            // Jugador que ha abandonado el partido
        bool IsMarkedToFinish = false;                          // Señal para terminar el partido

        private float RemainingSecs = 0;		                // Tiempo en segundos que queda de la "mitad" actual del partido
        private int Part = 1;                                   // Mitad de juego en la que nos encontramos
        private State CurState = State.WaittingPlayers;         // Estado actual del servidor de juego

        RealtimePlayer[] Players = new RealtimePlayer[PlayerCount];           // Los jugadores en el manager
        PlayerState[] PlayersState = new PlayerState[PlayerCount];            // Estado de los jugadores

        private int CountReadyPlayers = 0;                      // Contador de jugadores listos (No empezamos el partido hasta que estén listos todos)
        private float ServerTime = 0;		                    // Tiempo en segundos que lleva el servidor del partido funcionando

        private int ValidityGoal = Invalid;                     // Almacena la validad del gol reportado (0 = valido)
        private int CountPlayersReportGoal = 0;                 // Contador de jugadores que han comunicado el gol
        private int CountPlayersEndShoot = 0;                   // Contador de jugadores que han terminado de simular un disparo
        private bool SimulatingShoot = false;                   // Estamos simulando un disparo?

        private int MatchLength = -1;                           // Segundos
        private int TurnLength = -1;

        private int mMatchID;

        #region Interfaz hacia el manager
        public int MatchID
        {
            get { return mMatchID; }
        }

        public bool IsRealtimePlayerInMatch(RealtimePlayer who)
        {
            return Players[Player1] == who || Players[Player2] == who;
        }

        public int GetGoals(String player)
        {
            if (player == PLAYER_1)
                return PlayersState[Player1].ScoredGoals;
            else
                return PlayersState[Player2].ScoredGoals;
        }

        public int GetGoals(RealtimePlayer player)
        {
            return GetGoals(GetStringPlayer(player));
        }

        public RealtimePlayer GetOpponentOf(RealtimePlayer who)
        {
            RealtimePlayer ret = null;

            if (who == Players[Player1])
                ret = Players[Player2];
            else
                if (who == Players[Player2])
                    ret = Players[Player1];

            return ret;
        }

        // Comprueba si un jugador ha abandonado el partido
        public bool HasPlayerAbandoned(RealtimePlayer player)
        {
            bool bAbandon = false;
            if (this.GetIdPlayer(player) == this.PlayerIdAbort)
                bAbandon = true;
            return (bAbandon);
        }

        private String GetStringPlayer(RealtimePlayer player)
        {
            String ret = null;

            if (player == Players[Player1])
                ret = PLAYER_1;
            else
                if (player == Players[Player2])
                    ret = PLAYER_2;

            return ret;
        }

        public RealtimePlayer GetRealtimePlayer(String player)
        {
            if (player == PLAYER_1)
                return Players[Player1];
            else
                return Players[Player2];
        }
        #endregion


        // 
        // Inicializa el partido. 
        // NOTE : En este momento la conexión todavía no puede utilizarse, todavía el cliente simulador no ha tomado el control
        //
        public RealtimeMatch(int matchID, RealtimePlayer firstPlayer, RealtimePlayer secondPlayer, int matchLength, int turnLength, Realtime mainRT)
        {
            mMatchID = matchID;
            MainRT = mainRT;
            
            // Añade los jugadores a la lista de jugadores
            Players[Player1] = firstPlayer;
            Players[Player2] = secondPlayer;

            // Creamos el estado de los jugados
            PlayersState[Player1] = new PlayerState();
            PlayersState[Player2] = new PlayerState();

            MatchLength = matchLength;
            TurnLength = turnLength;

            // Información del partido y versiones
            LogEx("Init Match: " + matchID + " FirstPlayer: " + firstPlayer.Name + " SecondPlayer: " + secondPlayer.Name, MATCHLOG);
            LogEx( "Server Version: " + ServerVersion + " MinClientVersion required: " + MinClientVersion, MATCHLOG );

            // NOTE : En este momento la conexión todavía no puede utilizarse, todavía el cliente simulador no ha tomado el control

            // Comienza a esperar a que los jugadores estén listos para arrancar la primera parte
            StartPart();
        }


        #region Eventos entrantes desde los clientes

        
        // Determina si estamos esperando a algun jugador que informe de un gol
        public Boolean IsWaittingAnyGoal(  )
        {
            if ( CountPlayersReportGoal == 1 )
                return true;
            return false;
        }

        //
        // Verifica si aceptamos acciones de los clientes, si no es así las ignoramos
        // EJEMPLO: Aunque el servidor ha indicado la finalización de un tiempo, es posible que el mensaje tarde en llegar a los clientes.
        // En este caso ellos mandarían un Shoot, pero el servidor lo ignorará, ya que les llegará instantaneamente un evento de finalización
        // 
        public Boolean CheckActionsAllowed(  )
        {
            if ( this.CurState != State.Playing )
            {
                LogEx( "IMPORTANT: Ignorando acción no estamos en modo Playing" );
                return false;
            }
            
            return true;
        }
        
        // 
        // Un cliente ha disparado sobre una chapa
        // 
        public void OnServerShoot(int idPlayer, int capID, float dirX, float dirY, float force)
        {
            ShootCount++;               // Contabilizamos el disparo

            LogEx( "OnServerShoot: " + idPlayer + " Shoot: " + ShootCount + " Cap ID: " + capID + " dir: " + dirX + ", " + dirY + " force: " + force + " CPES: " + CountPlayersEndShoot );
            
            if (CountPlayersEndShoot != 0)
            {
                throw new Exception("Match: " + MatchID + " SERVER: Hemos recibido un ServerShoot cuando todavía no todos los clientes habían confirmado la finalización de un disparo anterior");
            }
            if (SimulatingShoot == true)
            {
                throw new Exception("Match: " + MatchID + " SERVER: Hemos recibido un ServerShoot mientras estamos simulando (SimulatingShoot = true)");
            }

            if ( CheckActionsAllowed() )        // Estan las acciones permitidas?
            {
                // Creamos una nueva descripción de estado para que los clientes puedan envíarnos su estado.
                // NOTE: Lo hacemos con lista ya que un cliente puede no haber envíado los resultados del anterior disparo, y el otro estar simulando el siguiente.
                if ( DebugClientState == true )
                {
                    ClientState clientState = new ClientState();
                    clientState.ShootCount = ShootCount;
                    TheClientState.Add( clientState );
                }

                SimulatingShoot = true;     // Indicamos que estamos simulando un disparo
                CountPlayersEndShoot = 0;   // Reseteamos el contador de jugadores que indican que han terminado la simulación
                Broadcast( "OnShoot", idPlayer, capID, dirX, dirY, force );
            }
        }

        // 
        // Un cliente ha terminado de simular un disparo
        // Cuando todos hayan terminado la simulación, lo notificamos a los clientes
        // 
        public void ClientEndShoot(int idPlayer)
        {
            LogEx("ClientEndShoot: " + idPlayer);

            if (SimulatingShoot == false)
            {
                throw new Exception("Match: " + MatchID + "Hemos recibido una finalización de disparo cuando no estamos simulando (SimulatingShoot = false)");
            }

            // Contabilizamos jugadores listos 
            CountPlayersEndShoot++;

            // Si "TODOS=2" jugadores están listos notificamos a los clientes.
            // Además reseteamos las variables de espera
            if (CountPlayersEndShoot == 2)
            {
                SimulatingShoot = false;            // Indicamos que hemos terminado la simulación
                CountPlayersEndShoot = 0;
                Broadcast("OnShootSimulated");
            }
        }

        //
        // Resultado que ha calculado un cliente de un disparo que ha terminado
        // Además se envían los descriptores de las chapas para evaluar desincronías
        //
        public void OnResultShoot(int idPlayer, int result, int countTouchedCaps, int paseToCapId, int framesSimulating, int reasonTurnChanged, string capListStr)
        {            
            string finalStr = " RCS: " + result + " Pase: " + paseToCapId + " CountTC: " + countTouchedCaps + " FS: " + framesSimulating + " RTC: "+ reasonTurnChanged + " " + capListStr;
            int shootCount = 0;

            if (DebugClientState == true)
            {
                // Buscamos el estado vacio para ese cliente (tiene que ser el primero vacio que encontremos, pq los mensajes vienen ordenados)
                // NOTE: Esto lo hacemos porque con mucho lag se pueden tener 2 estados al mismo tiempo!

                ClientState theState = null;
                foreach ( ClientState clientState in TheClientState )
                {
                    if ( string.IsNullOrEmpty( clientState.Client[ idPlayer ] ) )
                    {
                        theState = clientState;
                        break;
                    }
                }
                
                if ( theState == null )
                    throw new Exception( "No se ha encontrado un clientstate vacio!" );
                else
                {
                    shootCount = theState.ShootCount;

                    // Almacenamos la cadena de estado del cliente
                    theState.Client[ idPlayer ] = finalStr;

                    // Si ya tenemos el estado de los dos clientes (las dos cadenas), comprobamos que son iguales, y destruimos este estado
                    if ( theState.Client[ Player1 ] != "" && theState.Client[ Player2 ] != "" )
                    {
                        if ( theState.Client[ Player1 ] != theState.Client[ Player2 ] )
                        {
                            // Informamos a los clientes de que se ha producido una desincronia (cartel blanco en los clientes)
                            Broadcast( "PushedMatchUnsync" );

                            LogEx( ">>>>>>FATAL ERROR UNSYNC STATE: >>>>>>>>> " + MatchID, MATCHLOG );
                            LogEx( " STATE 1: " + theState.Client[ Player1 ], MATCHLOG );
                            LogEx( " STATE 2: " + theState.Client[ Player2 ], MATCHLOG );
                        }
                        // Eliminamos el estado
                        TheClientState.Remove( theState );
                    }
                }
            }
            LogEx( "P: " + idPlayer +" SHOOT:"+shootCount + finalStr );
        }

        //
        // Sacamos un log con información extendida
        //
        public void LogEx(string message, string category = MATCHLOG_DEBUG)
        {
            string finalMessage = " M: " + MatchID + " Time: " + this.ServerTime + " " + message;
            finalMessage += " <Vars>: SS: " + SimulatingShoot + " CountPlayersES: " + CountPlayersEndShoot + " P: " + Part + " T: " + RemainingSecs + " SC1=" + PlayersState[Player1].ScoredGoals + " SC2=" + PlayersState[Player2].ScoredGoals;

            Log.log(category, finalMessage);
        }

        // 
        // Un cliente ha colocado el balón después de un pase al pie
        // 
        public void OnPlaceBall(int idPlayer, int capID, float dirX, float dirY)
        {
            LogEx("OnPlaceBall: " + idPlayer + " Cap ID: " + capID);

            if ( CheckActionsAllowed() )        // Estan las acciones permitidas?
                Broadcast("OnPlaceBall", idPlayer, capID, dirX, dirY);
        }

        // 
        // Un cliente ha colocado una chapa en una posición 
        // NOTE: Se utiliza para la colocación del portero
        // 
        public void OnPosCap(int idPlayer, int capID, float posX, float posY)
        {
            LogEx("OnPosCap: " + idPlayer + " Cap ID: " + capID);

            if ( CheckActionsAllowed() )        // Estan las acciones permitidas?
                Broadcast("OnPosCap", idPlayer, capID, posX, posY);
        }


        // 
        // El cliente activo nos indica que ha alcanzado el timeout
        // NOTE: Este mensaje solo lo envía el jugador activo!
        //
        public void OnServerTimeout(int idPlayer)
        {
            LogEx("OnServerTimeout: " + idPlayer);

            // El tiempo se detiene al lanzar un disparo, con lo cual no puede llegar un TimeOut
            if (SimulatingShoot == true)
                throw new Exception("Match: " + MatchID + " Hemos recibido un TimeOut mientras estamos simulando un disparo (SimulatingShoot = true). ");

            if ( CheckActionsAllowed() )        // Estan las acciones permitidas?
                Broadcast("OnTimeout", idPlayer);
        }


        #endregion


        private void Broadcast(string method, params object[] args)
        {
            Players[Player1].TheConnection.Invoke(method, args);
            Players[Player2].TheConnection.Invoke(method, args);
        }

        private void Invoke(int idPlayer, string method, params object[] args)
        {
            Players[idPlayer].TheConnection.Invoke(method, args);
        }

        public void OnSecondsTick(float elapsed = 1.0f)
        {
            ServerTime += elapsed;      // Contabilizamos tiempo de servidor

            // El partido ha sido marcado para finalizar. Notificamos a todos los clientes
            if (IsMarkedToFinish)
            {
                Finish();
                IsMarkedToFinish = false;
                return;
            }

            switch (CurState)
            {
                case State.WaittingPlayers:
                    {

                    }
                    break;

                case State.Playing:
                    {
                        // Contabilizamos el tiempo que queda de la parte actual
                        RemainingSecs -= elapsed;

                        // Cada 4 segundos sincronizamos el tiempo con los clientes
                        if (((int)RemainingSecs) % 4 == 0)
                            this.Broadcast("SyncTime", RemainingSecs);

                        // Comprobamos si ha terminado el tiempo
                        // NOTE: No permitimos que termine el tiempo durante la simulación del disparo, ni cuando estamos esperando una confirmación de gol
                        // de uno de los jugadores (el otro ya ha informado)!
                        if ( RemainingSecs <= 0 && SimulatingShoot == false && IsWaittingAnyGoal() == false )
                        {
                            // Comprobamos si ha terminado la primera parte o el partido
                            if (Part == 1)
                            {
                                // Notificamos a los clientes que ha terminado la mitad de juego

                                LogEx( "Finalización de parte!. Enviado a los clientes <FinishPart>" );
                                Broadcast("FinishPart", Part, null);

                                Part++;                             // Pasamos  a la siguiente parte
                                StartPart();
                            }
                            else if (Part == 2)
                            {
                                // Finalizamos el partido
                                RealtimeMatchResult result = NotifyOwnerFinishMatch();
                                // Notificamos a los clientes que ha terminado la mitad de juego y como es la segunda
                                // envíamos el resultado
                                Broadcast("FinishPart", Part, result);
                                CurState = State.End;
                            }
                        }
                    }
                    break;
                case State.End:
                    {

                    }
                    break;

            }
        }

        //
        // Obtiene el identificador del player a partir de su objeto
        //
        public int GetIdPlayer(RealtimePlayer player)
        {
            // Determinamos el identificador del player

            int idPlayer = Invalid;
            if (Players[Player1] == player)
                idPlayer = Player1;
            else if (Players[Player2] == player)
                idPlayer = Player2;
            else
                Debug.Assert(true, "GetIdPlayer: El player pasado no es ninguno de los jugadores actuales!");

            return (idPlayer);
        }

        //
        // Uno de los jugadores ha indicado que necesita los datos del partido
        //
        // Enviamos los datos del partido al jugador
        //
        public void OnRequestData(RealtimePlayer player)
        {
            // Determinamos el identificador del player
            int idPlayer = GetIdPlayer(player);
            LogEx( "OnRequestData: Datos del partido solicitador por el Player: " + idPlayer + "Configuración partido: TotalTime: " + MatchLength + " TurnTime: "+ TurnLength );

            // Envía la configuración del partido al jugador, indicándole además a quien controlan  ellos (LocalUser)
            Invoke(idPlayer, "InitMatch", this.mMatchID, Players[Player1].PlayerData, Players[Player2].PlayerData, idPlayer, MatchLength, TurnLength, MinClientVersion);
        }

        //
        // Uno de los jugadores ha indicado que está listo para empezar
        //
        public void OnPlayerReady(RealtimePlayer player)
        {
            // Determinamos el identificador del player
            int idPlayer = GetIdPlayer(player);

            LogEx("OnPlayerReady: " + idPlayer);

            // Contabilizamos jugadores listos 
            CountReadyPlayers++;

            // Si "TODOS=2" jugadores están listos continuamos el partido y notificamos a los clientes.
            // Además reseteamos las variables de espera
            if (CountReadyPlayers == 2)
            {
                LogEx( "Todos los jugadores han indicado que están listros. Les envíamos la notificación para que continuen" );
                Broadcast("OnAllPlayersReady");
                CountReadyPlayers = 0;
                this.CurState = State.Playing;
            }
        }

        //
        // Evento producido cuando un usuario utiliza una habilidad especial
        //
        public void OnUseSkill(int idPlayer, int idSkill)
        {
            LogEx("OnUseSkill: Player: " + idPlayer + " Skill: " + idSkill);

            if ( CheckActionsAllowed() )        // Estan las acciones permitidas?
            {
                // TODO: Validar parámetros correctos
                // TODO: Validar si puede utilizar el skill

                SkillState skill = PlayersState[ idPlayer ].Skills[ idSkill ];
                skill.LastTimeUsed = ServerTime;
                skill.InUse = true;

                // Propagamos la orden a todos los clientes
                Broadcast( "OnUseSkill", idPlayer, idSkill );
            }
        }

        //
        // Comprobamos si un skill están en uso
        //
        private bool SkillInUse(int idPlayer, int idSkill)
        {
            return (PlayersState[idPlayer].Skills[idSkill].InUse);
        }

        // 
        // Un jugador declara que va a lanzar a puerta
        // TODO: IMPLEMENTACIÓN DE PORTERO!!!
        // TODO: IMPLEMENTAR RESTAURACIÓN DE LA BANDERA CUANDO TIRE!!
        // 
        public void OnTiroPuerta(int idPlayer)
        {
            LogEx("OnTiroPuerta: Player: " + idPlayer);

            if ( CheckActionsAllowed() )        // Estan las acciones permitidas?
            {
                if ( ValidatePlayer( idPlayer ) )
                {
                    PlayersState[ idPlayer ].TiroPuerta = true;

                    // Propagamos a los clientes
                    Broadcast( "OnTiroPuerta", idPlayer );
                }
            }
        }
        
        // 
        // Un jugador declara que ha ocurrido un gol (puede ser de si mismo o del contrario)!
        // Hasta que todos los jugadores nos digan que ha habido gol, no hacemos nada!
        //
        public void OnGoalScored(int idPlayer, int scoredPlayer, int validity)
        {
            LogEx( "OnGoalScored: Player: " + idPlayer + " Scored player: " + scoredPlayer + " Validity: " + validity + " CountPlayersReportGoal: " + CountPlayersReportGoal );

            if ( CheckActionsAllowed() )        // Estan las acciones permitidas?
            {
                if ( ValidatePlayer( scoredPlayer ) && ValidatePlayer( idPlayer ) )
                {
                    // Contabilizamos el número de jugadores que han comunicado el gol. Hasta que los 2 no lo hayan hecho no lo contabilizamos
                    CountPlayersReportGoal++;

                    // Hacemos caso a la validez que indica el jugador que ha marcado gol
                    if ( idPlayer == scoredPlayer )      // El jugador que nos comunica el gol es quien ha marcado?
                    {
                        ValidityGoal = validity;
                        LogEx( "Anotamos la validez del gol. Es el jugador que ha marcado! Player: " + idPlayer + " Validity: " + ValidityGoal );
                    }

                    // Todos los jugadores han comunicado el gol? Si es así lo procesamos
                    if ( CountPlayersReportGoal == PlayerCount )
                    {
                        LogEx( "Todos los jugadores han informado del gol. Notificamos a los clientes." );
                        CountPlayersReportGoal = 0;     // Reseteamos contador para el siguiente gol que se produzca!
                        
                        // Ponemos a 0 el contador de playes que han terminado una simulación de disparo, ya que al haber gol se va a resetear la posición de la pelota en el cliente
                        // y no nos enviarán este valor
                        CountPlayersEndShoot = 0;
                        // Indicamos que hemos terminado la simulación aunque esté en funcionamiento, ya que no nos enviarán los mensajes, y borramos el último estado de clientes
                        SimulatingShoot = false;
                        TheClientState.RemoveAt( TheClientState.Count - 1 );

                        // Validamos el gol. Para que un gol sea válido el jugador tiene que haber declarado "Tiro a puerta"
                        // TODO: De momento este control lo llevamos en el cliente
                        //bValid = bValid && PlayersState[ idPlayer ].TiroPuerta;

                        // Contabilizamos el gol si es válido (en AS3 la validity es un enumerado y vale 0 cuando el gol ha sido valido)
                        if ( ValidityGoal == 0 )
                            PlayersState[ scoredPlayer ].ScoredGoals++;

                        // Propagamos a los usuarios
                        Broadcast( "OnGoalScored", scoredPlayer, ValidityGoal );

                        // Reseteamos validez del gol y comprobamos coherencia
                        if ( ValidityGoal == Invalid )
                            throw new Exception( "La validez del gol es inválida" );
                        ValidityGoal = Invalid;
                    }
                }
            }
        }

        public void OnMsgToChatAdded(RealtimePlayer source, string msg)
        {
            Log.log(MATCHLOG, MatchID + " Chat: " + msg);

            // Solo permitos el chateo durante este estado, para evitar que cuando todavía esta cargando uno de los clientes le lleguen mensajes. Estaba pasando que se le mandaba
            // este invoke cuando no tenía asignado el cliente de la NetConnection a Game, sino a RTMPModel, con lo que este metodo no existia => excepcion #1069
            // Con esto, ocurrira q no se puede chatear al final de la primera parte, porque se reusa el estado WaittingState. Si realmente es un problema, se puede meter
            // un estado adicional para el final de la primera parte y hacer q aqui lo que se compruebe sea CurState != State.WaittingState
            if (CurState == State.Playing)
                Broadcast("OnChatMsg", msg);
        }

        //
        // Validamos un identificador
        //
        public bool ValidatePlayer(int playerId)
        {
            if (playerId == Player1 || playerId == Player2)
                return true;
            return false;
        }


        //
        // Se llama cada vez que comienza una nueva mitad de juego
        // NOTE: No comienza inmediatamente, se queda esperando que los jugados declaren que están listos
        //
        private void StartPart()
        {
            LogEx("Start Part: " + Part);

            CurState = State.WaittingPlayers;
            RemainingSecs = MatchLength / 2;        // Reseteamos tiempo de juego

            if( CountPlayersReportGoal != 0 )
                throw new Exception( "Comienza una mitad de juego y estamos esperando la notificación de un gol de un jugador! Un jugador se ha caído? CountPlayersReportGoal = " + CountPlayersReportGoal );
        }

        // 
        // Marca el partido para terminar en el próximo tick de ejecución
        //
        private void MarkToFinish()
        {
            LogEx("Match marked to finish: ");
            IsMarkedToFinish = true;
        }


        //
        // Notifica al owner que ha terminado el partido
        // y retorna el resultado
        // NOTE: Este método no puede llamarse desde la respuesta a un evento. Debe llamarse desde el Tick
        //
        private RealtimeMatchResult NotifyOwnerFinishMatch()
        {
            // Notificamos a nuestro creador que el partido ha terminado
            return (MainRT.OnFinishMatch(this));
        }

        // 
        // Marca el partido para terminar en el próximo tick de ejecución
        //
        public void OnAbort(int playerId)
        {
            LogEx("OnAbort: Player: " + playerId);

            // Almacenamos el jugador que abandonó el partido
            PlayerIdAbort = playerId;

            // Marcamos el partido para que termine
            MarkToFinish();
        }


        //
        // Finaliza el partido y notifica a todos los clientes y a nuestro creador
        // NOTE: Este método no puede llamarse desde la respuesta a un evento. Debe llamarse desde el Tick
        // NOTE: Pasamos por este finish tanto cuando un usuario aborta de forma manual, pero no cuando termina el
        // partido de forma normal
        //
        private void Finish()
        {
            LogEx("Match finished ");

            // Notificamos a nuestro creador que el partido ha terminado
            RealtimeMatchResult result = NotifyOwnerFinishMatch();

            // Notificamos a todos los clientes que el partido ha terminado y les envíamos el resultado
            Broadcast("Finish", result);
        }
    }
}

