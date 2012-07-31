using System;
using System.Collections.Generic;
using System.Linq;

using Weborb.Util.Logging;
using SoccerServerV1.BDDModel;
using SoccerServerV1.NetEngine;

 
namespace SoccerServerV1
{
    public partial class Realtime : INetClientApp
    {
        static private string GetRoomNameByID(int roomID)
        {
            return ROOM_PREFIX + roomID.ToString("d2");
        }

        private Room GetRoomByID(int roomID)
        {
            return mRooms[roomID];
        }

        private Room GetPreferredRoom()
        {
            return mRooms[0];
        }

        public override void OnAppStart(NetServer netServer)
        {
            Log.startLogging(REALTIME);
            Log.startLogging(REALTIME_DEBUG);
            Log.startLogging(RealtimeMatch.MATCHLOG);
            //Log.startLogging(RealtimeMatch.MATCHLOG_DEBUG);            

            Log.log(REALTIME, "************************* Realtime Starting *************************");

            mNetServer = netServer;

            mRooms.Clear();
            mMatches.Clear();

            for (int c = 0; c < NUM_ROOMS; c++)
            {
                mRooms.Add(new Room(GetRoomNameByID(c)));
            }

            mSecondsCount = 0;
        }

        public override void OnAppEnd()
        {
            Log.log(REALTIME, "************************* Realtime Stopping *************************");
        }

        public override void OnServerAboutToShutdown()
        {
            IList<NetPlug> plugs = mNetServer.GetNetPlugs();

            foreach (NetPlug plug in plugs)
            {
                plug.Invoke("PushedDisconnected", "ServerShutdown");
            }
        }


        public override void OnClientConnected(NetPlug client)
        {
            Log.log(REALTIME_DEBUG, "************************* OnClientConnected  " + client.ID + " *************************");

            lock (mGlobalLock)
            {
                if (mBroadcastMsg != "")
                    client.Invoke("PushedBroadcastMsg", mBroadcastMsg);
            }
        }

        public override void OnClientLeft(NetPlug client)
        {
            lock (mGlobalLock)
            {
                RealtimePlayer leavingPlayer = client.UserData as RealtimePlayer;

                // Es posible que no haya RealtimePlayer porque no haya llegado a hacer login, aunque haya conectado
                if (leavingPlayer != null)
                {
                    if (leavingPlayer.Room != null)
                    {
                        LeaveRoom(leavingPlayer);
                    }
                    else
                    {
                        // Como despues de un partido dejamos que sean los propios clientes los que se unan a la habitacion,
                        // es posible tambien que no tenga ni room ni partido, si pilla justo en esa transicion
                        if (leavingPlayer.TheMatch != null)
                            OnPlayerDisconnectedFromMatch(leavingPlayer);
                    }
                }
            }
        }

        private void LeaveRoom(RealtimePlayer who)
        {
            Room theRoom = who.Room;

            if (!theRoom.Players.Remove(who))
                throw new Exception("WTF: Player was not in room");

            // Tenemos que quitar todos los challenges en los que participara, bien como Source o como Target
            foreach (Challenge leftChallenge in who.Challenges)
            {
                RealtimePlayer other = leftChallenge.SourcePlayer == who ? leftChallenge.TargetPlayer : leftChallenge.SourcePlayer;
                bool hadChallenge = other.Challenges.Remove(leftChallenge);

                if (!hadChallenge)
                    throw new Exception("WTF");
            }
            who.Challenges.Clear();
            who.Room = null;

            foreach (RealtimePlayer thePlayer in theRoom.Players)
            {
                thePlayer.TheConnection.Invoke("PushedPlayerLeftTheRoom", who);
            }
        }

        private void OnPlayerDisconnectedFromMatch(RealtimePlayer who)
        {
            RealtimeMatch theMatch = who.TheMatch;
            RealtimePlayer opp = theMatch.GetOpponentOf(who);

            // Simulamos la pulsación del botón de abortar...
            theMatch.OnAbort(theMatch.GetIdPlayer(who));

            // Y continuamos por el procedimiento normal...
            RealtimeMatchResult matchResult = OnFinishMatch(theMatch);

            // Hay que notificar al oponente de que ha habido cancelacion
            opp.TheConnection.Invoke("PushedOpponentDisconnected", matchResult);
        }

        public bool LogInToDefaultRoom(NetPlug myConnection, string facebookSession)
        {
            lock (mGlobalLock)
            {
                bool bRet = false;

                // Como se vuelve a llamar aqui despues de jugar un partido, nos aseguramos de que la conexion este limpia para
                // la correcta recreacion del RealtimePlayer
                myConnection.UserData = null;

                using (SoccerDataModelDataContext theContext = new SoccerDataModelDataContext())
                {
                    Session theSession = (from s in theContext.Sessions
                                          where s.FacebookSession == facebookSession
                                          select s).FirstOrDefault();

                    if (theSession == null)
                        throw new Exception("Invalid session sent by client");

                    Player theCurrentPlayer = theSession.Player;

                    // Sólo permitimos una conexión para un player dado. 
                    CloseOldConnectionForPlayer(theCurrentPlayer);

                    Team theCurrentTeam = theCurrentPlayer.Team;

                    // Unico punto de creacion del RealtimePlayer
                    RealtimePlayer theRealtimePlayer = new RealtimePlayer();

                    theRealtimePlayer.PlayerID = theCurrentPlayer.PlayerID;
                    theRealtimePlayer.ClientID = myConnection.ID;
                    theRealtimePlayer.FacebookID = theCurrentPlayer.FacebookID;
                    theRealtimePlayer.Name = theCurrentTeam.Name;
                    theRealtimePlayer.PredefinedTeamName = theCurrentTeam.PredefinedTeam.Name;
                    theRealtimePlayer.TrueSkill = theCurrentTeam.TrueSkill;

                    myConnection.UserData = theRealtimePlayer;
                    theRealtimePlayer.TheConnection = myConnection;

                    JoinPlayerToPreferredRoom(theRealtimePlayer);

                    bRet = true;

                    Log.log(REALTIME_DEBUG, theCurrentPlayer.FacebookID + " " + theRealtimePlayer.ClientID +  " logged in: " + theCurrentPlayer.Name + " " + theCurrentPlayer.Surname + ", Team: " + theCurrentTeam.Name);
                }

                return bRet;
            }
        }

        private void JoinPlayerToPreferredRoom(RealtimePlayer player)
        {
            Room theRoom = GetPreferredRoom();
            
            // Al que se une le enviamos los players que ya hay, sin contar con él mismo
            player.TheConnection.Invoke("PushedRefreshPlayersInRoom", theRoom.Name, theRoom.Players);

            // Informamos a todos los demas de que hay un nuevo player
            foreach (RealtimePlayer thePlayer in theRoom.Players)
            {
                thePlayer.TheConnection.Invoke("PushedNewPlayerJoinedTheRoom", player);
            }

            player.Room = theRoom;
            player.Room.Players.Add(player);
        }

        private void CloseOldConnectionForPlayer(Player player)
        {
            IList<NetPlug> plugs = mNetServer.GetNetPlugs();

            foreach (NetPlug plug in plugs)
            {
                // Es posible que la conexión se haya desconectado o que no haya hecho login todavia...
                if (!plug.IsClosed && plug.UserData != null)
                {
                    if ((plug.UserData as RealtimePlayer).PlayerID == player.PlayerID)
                    {
                        plug.Invoke("PushedDisconnected", "Duplicated");
                        plug.CloseRequest();
                        break;
                    }
                }
            }
        }

        public int Challenge(NetPlug from, int clientID, string msg, int matchLengthSeconds, int turnLengthSeconds)
        {
            lock (mGlobalLock)
            {
                int ret = -1;	// Devolvemos el clientID en caso de exito para ayudar al cliente

                if (!MATCH_DURATION_SECONDS.Contains(matchLengthSeconds))
                    throw new Exception("Nice try");

                if (!TURN_DURATION_SECONDS.Contains(turnLengthSeconds))
                    throw new Exception("Nice try");

                RealtimePlayer self = from.UserData as RealtimePlayer;

                // Es posible que nos llegue un challenge cuando ya nos han aceptado otro de los nuestros
                if (self.Room != null)
                {
                    RealtimePlayer other = null;

                    for (int c = 0; c < self.Room.Players.Count; c++)
                    {
                        if (self.Room.Players[c].ClientID == clientID)
                        {
                            other = self.Room.Players[c];
                            break;
                        }
                    }

                    if (other != null && !HasChallenge(self, other))
                    {
                        Challenge newChallenge = new Challenge();
                        newChallenge.SourcePlayer = self;
                        newChallenge.TargetPlayer = other;
                        newChallenge.Message = msg;
                        newChallenge.MatchLengthSeconds = matchLengthSeconds;
                        newChallenge.TurnLengthSeconds = turnLengthSeconds;

                        self.Challenges.Add(newChallenge);
                        other.Challenges.Add(newChallenge);

                        ret = clientID;

                        other.TheConnection.Invoke("PushedNewChallenge", newChallenge);
                    }
                }
            
                return ret;
            }
        }

        public bool AcceptChallenge(NetPlug from, int opponentClientID)
        {
            bool bRet = false;
            lock (mGlobalLock)
            {
                RealtimePlayer self = from.UserData as RealtimePlayer;
                RealtimePlayer opp = null;
                Challenge theChallenge = null;

                foreach (Challenge challenge in self.Challenges)
                {
                    if (challenge.SourcePlayer.ClientID == opponentClientID)
                    {
                        theChallenge = challenge;
                        opp = theChallenge.SourcePlayer;
                        break;
                    }
                }

                if (theChallenge != null)
                {
                    bRet = true;
                    StartMatch(self, opp, theChallenge.MatchLengthSeconds, theChallenge.TurnLengthSeconds);
                }
            }
            return bRet;
        }

        public bool SwitchLookingForMatch(NetPlug from)
        {
            bool bRet = false;

            lock (mGlobalLock)
            {
                RealtimePlayer self = from.UserData as RealtimePlayer;
                self.LookingForMatch = !self.LookingForMatch;

                bRet = self.LookingForMatch;
            }

            return bRet;
        }


        private void StartMatch(RealtimePlayer firstPlayer, RealtimePlayer secondPlayer, int matchLength, int turnLength)
        {
            LeaveRoom(firstPlayer);
            LeaveRoom(secondPlayer);

            int matchID = -1;

            // Generacion de los datos de inicializacion para el partido. No valen con los del RealtimePlayer, hay que refrescarlos.
            using (SoccerDataModelDataContext theContext = new SoccerDataModelDataContext())
            {
                matchID = CreateDatabaseMatch(theContext, firstPlayer, secondPlayer);
                FillRealtimePlayerData(theContext, firstPlayer);
                FillRealtimePlayerData(theContext, secondPlayer);
            }

            RealtimeMatch theNewMatch = new RealtimeMatch(matchID, firstPlayer, secondPlayer, matchLength, turnLength, this);
            mMatches.Add(theNewMatch);

            firstPlayer.TheMatch = theNewMatch;
            secondPlayer.TheMatch = theNewMatch;

            firstPlayer.TheConnection.Invoke("PushedStartMatch", firstPlayer.ClientID, secondPlayer.ClientID);
            secondPlayer.TheConnection.Invoke("PushedStartMatch", firstPlayer.ClientID, secondPlayer.ClientID);
        }

        private void ProcessMatchMaking()
        {
            var availables = new List<RealtimePlayer>();

            foreach (RealtimePlayer thePlayer in mRooms[0].Players)
            {
                if (thePlayer.LookingForMatch)
                    availables.Add(thePlayer);
            }

            while (availables.Count > 1)
            {
                var candidate = availables.First();
                availables.Remove(candidate);

                var opponent = FindBestOpponent(candidate, availables);

                if (opponent != null)
                {
                    availables.Remove(opponent);

                    candidate.LookingForMatch = false;
                    opponent.LookingForMatch = false;

                    StartMatch(candidate, opponent, MATCH_DURATION_SECONDS[1], TURN_DURATION_SECONDS[1]);
                }
            }
        }

        static private RealtimePlayer FindBestOpponent(RealtimePlayer who, IEnumerable<RealtimePlayer> available)
        {
            RealtimePlayer closest = null;
            int bestSoFar = int.MaxValue;

            foreach (var other in available)
            {
                int absDiff = Math.Abs(other.TrueSkill - who.TrueSkill);
                if (absDiff < bestSoFar)
                {
                    bestSoFar = absDiff;
                    closest = other;
                }
            }

            // No lo damos por valido si no es partido puntuable
            if (bestSoFar > TrueSkillHelper.CUTOFF * TrueSkillHelper.MULTIPLIER)
                closest = null;

            return closest;
        }

        static private void FillRealtimePlayerData(SoccerDataModelDataContext theContext, RealtimePlayer rtPlayer)
        {
            RealtimePlayerData data = new RealtimePlayerData();
            Player player = GetPlayerForRealtimePlayer(theContext, rtPlayer);

            data.Name = player.Team.Name;
            data.PredefinedTeamName = player.Team.PredefinedTeam.Name;
            data.TrueSkill = player.Team.TrueSkill;
            data.SpecialSkillsIDs = (from s in player.Team.SpecialTrainings
                                     where s.IsCompleted
                                     select s.SpecialTrainingDefinitionID).ToList();
            data.Formation = player.Team.Formation;

            var soccerPlayers = (from p in player.Team.SoccerPlayers
                                 where p.FieldPosition < 100
                                 orderby p.FieldPosition
                                 select p);

            // Multiplicamos por el fitness (entre 0 y 1)
            float daFitness = player.Team.Fitness / 100.0f;

            foreach (SoccerPlayer sp in soccerPlayers)
            {
                var spData = new RealtimePlayerData.SoccerPlayerData();

                spData.Name = sp.Name;
                spData.Number = sp.Number;

                spData.Power = (int)Math.Round(sp.Power * daFitness);
                spData.Control = (int)Math.Round(sp.Sliding * daFitness);
                spData.Defense = (int)Math.Round(sp.Weight * daFitness);

                data.SoccerPlayers.Add(spData);
            }

            rtPlayer.PlayerData = data;
        }

        static private int CreateDatabaseMatch(SoccerDataModelDataContext theContext, RealtimePlayer homeRT, RealtimePlayer awayRT)
        {
            BDDModel.Match theNewMatch = new BDDModel.Match();
            theNewMatch.DateStarted = DateTime.Now;

            BDDModel.MatchParticipation homePart = CreateMatchParticipation(theContext, homeRT, true);
            BDDModel.MatchParticipation awayPart = CreateMatchParticipation(theContext, awayRT, false);

            homePart.Match = theNewMatch;
            awayPart.Match = theNewMatch;

            theContext.MatchParticipations.InsertOnSubmit(homePart);
            theContext.MatchParticipations.InsertOnSubmit(awayPart);

            theContext.Matches.InsertOnSubmit(theNewMatch);
            theContext.SubmitChanges();

            homeRT.MatchParticipationID = homePart.MatchParticipationID;
            awayRT.MatchParticipationID = awayPart.MatchParticipationID;

            return theNewMatch.MatchID;
        }

        static private BDDModel.MatchParticipation CreateMatchParticipation(SoccerDataModelDataContext theContext, RealtimePlayer playerRT, bool asHome)
        {
            BDDModel.MatchParticipation part = new BDDModel.MatchParticipation();

            part.AsHome = asHome;
            part.Goals = 0;
            part.TurnsPlayed = 0;
            part.Team = GetPlayerForRealtimePlayer(theContext, playerRT).Team;

            return part;
        }

        static private Player GetPlayerForRealtimePlayer(SoccerDataModelDataContext theContext, RealtimePlayer playerRT)
        {
            return (from s in theContext.Players
                    where s.PlayerID == playerRT.PlayerID
                    select s).FirstOrDefault();
        }


        static private bool HasChallenge(RealtimePlayer first, RealtimePlayer second)
        {
            bool bRet = false;

            foreach (Challenge challenge in first.Challenges)
            {
                if (challenge.TargetPlayer == second)
                {
                    bRet = true;
                    break;
                }
            }

            if (!bRet)
            {
                foreach (Challenge challenge in second.Challenges)
                {
                    if (challenge.TargetPlayer == first)
                    {
                        bRet = true;
                        break;
                    }
                }
            }

            return bRet;
        }

        internal RealtimeMatchResult OnFinishMatch(RealtimeMatch realtimeMatch)
        {
            RealtimeMatchResult matchResult = null;

            RealtimePlayer player1 = realtimeMatch.GetRealtimePlayer(RealtimeMatch.PLAYER_1);
            RealtimePlayer player2 = realtimeMatch.GetRealtimePlayer(RealtimeMatch.PLAYER_2);

            using (SoccerDataModelDataContext theContext = new SoccerDataModelDataContext())
            {
                Player bddPlayer1 = GetPlayerForRealtimePlayer(theContext, player1);
                Player bddPlayer2 = GetPlayerForRealtimePlayer(theContext, player2);

                // Los BDDPlayers se actualizan dentro de la funcion (... old GiveMatchRewards)
                matchResult = new RealtimeMatchResult(theContext, realtimeMatch, bddPlayer1, bddPlayer2);

                // Actualizacion del BDDMatch...
                BDDModel.Match theBDDMatch = (from m in theContext.Matches
                                                where m.MatchID == realtimeMatch.MatchID
                                                select m).FirstOrDefault();

                theBDDMatch.DateEnded = DateTime.Now;
                theBDDMatch.WasTooManyTimes = matchResult.WasTooManyTimes;
                theBDDMatch.WasJust = matchResult.WasJust;
                theBDDMatch.WasAbandoned = matchResult.WasAbandoned;
                theBDDMatch.WasAbandonedSameIP = matchResult.WasAbandonedSameIP;

                // ... y de las MatchParticipations de la BDD
                (from p in theContext.MatchParticipations
                    where p.MatchParticipationID == player1.MatchParticipationID
                    select p).FirstOrDefault().Goals = matchResult.GetGoalsFor(player1);

                (from p in theContext.MatchParticipations
                    where p.MatchParticipationID == player2.MatchParticipationID
                    select p).FirstOrDefault().Goals = matchResult.GetGoalsFor(player2);

                theContext.SubmitChanges();
            }

            player1.PlayerData = null;
            player2.PlayerData = null;
            player1.MatchParticipationID = -1;
            player2.MatchParticipationID = -1;
            player1.TheMatch = null;
            player2.TheMatch = null;

            // Borramos el match, dejamos que ellos se unan a la habitacion
            mMatches.Remove(realtimeMatch);

            return matchResult;
        }


        public void OnSecondsTick()
        {
            lock (mGlobalLock)
            {
                // El borrado del partido (OnFinishMatch) se produce siempre dentro del tick, asi que modificara la coleccion -> tenemos que hacer una copia
                var matchesCopy = new List<RealtimeMatch>(mMatches);

                foreach (RealtimeMatch theMatch in matchesCopy)
                {
                    theMatch.OnSecondsTick();
                }
                
                // Cada X segundos evaluamos los matcheos automaticos
                mSecondsCount++;

                if (mSecondsCount % 5 == 0)
                {
                    ProcessMatchMaking();
                }
            }
        }

        public int GetNumMatches()
        {
            lock (mGlobalLock)
            {
                return mMatches.Count;
            }
        }

        public int GetNumTotalPeopleInRooms()
        {
            lock (mGlobalLock)
            {
                return mRooms[0].Players.Count;
            }
        }

        public int GetPeopleLookingForMatch()
        {
            int ret = 0;

            lock (mGlobalLock)
            {
                foreach (var rt in mRooms[0].Players)
                {
                    if (rt.LookingForMatch)
                        ret++;
                }
            }
            return ret;
        }

        public void SetProgrammedStop(bool stop)
        {
            lock (mGlobalLock)
            {
                mbAcceptingNewMatches = stop;
            }
        }

        public void SetBroadcastMsg(string msg)
        {
            lock (mGlobalLock)
            {
                mBroadcastMsg = msg;

                // Cuando nos vacian el mensaje no hace falta enviar nada
                if (mBroadcastMsg == "")
                    return;

                IList<NetPlug> allConnections = mNetServer.GetNetPlugs();

                foreach (NetPlug plug in allConnections)
                {
                    plug.Invoke("PushedBroadcastMsg", mBroadcastMsg);
                }
            }
        }

        public string GetBroadcastMsg(NetPlug from)
        {
            lock (mGlobalLock)
            {
                return mBroadcastMsg;
            }
        }

        public const String REALTIME = "REALTIME";
        public const String REALTIME_DEBUG = "REALTIME DEBUG";
        public const String REALTIME_INVOKE = "REALTIME INVOKE";

        private const String ROOM_PREFIX = "Room";
        private const int NUM_ROOMS = 8;

        private int[] MATCH_DURATION_SECONDS = new int[] { 5 * 60, 10 * 60, 15 * 60 };
        private int[] TURN_DURATION_SECONDS = new int[] { 5, 10, 15 };

        private NetServer mNetServer;

        private readonly List<Room> mRooms = new List<Room>();
        private readonly List<RealtimeMatch> mMatches = new List<RealtimeMatch>();

        private readonly object mGlobalLock = new object();

        private int mSecondsCount = 0;                  // Para mirar el Match Making cada X segundos
        private bool mbAcceptingNewMatches = true;      // Parada programada
        private string mBroadcastMsg = "";
    }

    public class Room
    {
        public String Name;
        public List<RealtimePlayer> Players = new List<RealtimePlayer>();

        public Room(String name) { Name = name; }
    }

    public class Challenge
    {
        public RealtimePlayer SourcePlayer;

        [NonSerialized]
        public RealtimePlayer TargetPlayer;

        public String Message;
        public int MatchLengthSeconds;
        public int TurnLengthSeconds;
    }

    public class RealtimePlayer
    {
        [NonSerialized]
        public int PlayerID = -1;                       // El equivalente en la BDD
        public int ClientID = -1;                       // El del NetEngine

        public String Name;
        public String FacebookID;
        public String PredefinedTeamName;
        public int    TrueSkill;

        [NonSerialized]
        public bool LookingForMatch = false;

        [NonSerialized]
        public RealtimeMatch TheMatch = null;

        [NonSerialized]
        public int MatchParticipationID = -1;           // TODO: Per player, la deberia llevar el match

        [NonSerialized]
        public RealtimePlayerData PlayerData;			// Datos de inicializacion para el partido. TODO: Quitarlos de aqui!

        [NonSerialized]
        public List<Challenge> Challenges = new List<Challenge>();

        [NonSerialized]
        public Room Room;

        [NonSerialized]
        public NetPlug TheConnection;
    }

    // Datos de un jugador para el partido
    // NOTE: Esta clase se transfiere por red. No cambiar nombres o destruir variables sin sincronizar los cambios en el cliente!!!
    //
    public class RealtimePlayerData
    {
        public class SoccerPlayerData
        {
            public int Number;		// Dorsal
            public String Name;
            public int Power;
            public int Control;
            public int Defense;
        }

        public String Name;								// Nombre del equipo del player
        public String PredefinedTeamName;				// El player tiene un equipo real asociado: "Getafe"
        public int TrueSkill;							// ...Por si acaso hay que mostrarlo
        public List<int> SpecialSkillsIDs;				// Del 1 al 9
        public String Formation;						// Nombre de la formacion: "331", "322", etc..

        // Todos los futbolistas, ordenados según la posición/formacion. Primero siempre el portero.
        public List<SoccerPlayerData> SoccerPlayers = new List<SoccerPlayerData>();
    }
}