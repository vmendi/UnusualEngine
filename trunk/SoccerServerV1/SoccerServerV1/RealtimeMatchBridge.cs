using Weborb.Util.Logging;
using SoccerServerV1.NetEngine;


namespace SoccerServerV1
{
    // 
    // Se encarga de hacer puente de todos los comandos que se reciben de los clientes.
    // Cada "comando" se reenvía al partido correspondiente
    //
    public partial class Realtime
    {
        // 
        // Uno de los clientes está solicitando los datos del partido
        // 
        public void OnRequestData(NetPlug plug)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    thePlayer.TheMatch.OnRequestData(thePlayer);
                }
            }
        }

        // 
        // Uno de los clientes está listo para comenzar
        // 
        public void OnPlayerReady(NetPlug plug)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    thePlayer.TheMatch.OnPlayerReady(thePlayer);
                }
            }
        }


        // 
        // Un cliente ha disparado sobre una chapa
        // 
        public void OnServerShoot(NetPlug plug, int capID, float dirX, float dirY, float force)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    int idPlayer = thePlayer.TheMatch.GetIdPlayer(thePlayer);
                    thePlayer.TheMatch.OnServerShoot(idPlayer, capID, dirX, dirY, force);
                }
            }
        }
        // 
        // Un cliente notifica que terminado la simulación del disparo
        // 
        public void ClientEndShoot(NetPlug plug)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    int idPlayer = thePlayer.TheMatch.GetIdPlayer(thePlayer);
                    thePlayer.TheMatch.ClientEndShoot(idPlayer);
                }
            }
        }

        // 
        // Un cliente ha colocado el balón después de un pase al pie
        // 
        public void OnPlaceBall(NetPlug plug, int capID, float dirX, float dirY)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    int idPlayer = thePlayer.TheMatch.GetIdPlayer(thePlayer);
                    thePlayer.TheMatch.OnPlaceBall(idPlayer, capID, dirX, dirY);
                }
            }
        }

        // 
        // Un cliente ha colocado una chapa en una posición 
        // NOTE: Se utiliza para la colocación del portero
        // 
        public void OnPosCap(NetPlug plug, int capID, float posX, float posY)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    int idPlayer = thePlayer.TheMatch.GetIdPlayer(thePlayer);
                    thePlayer.TheMatch.OnPosCap(idPlayer, capID, posX, posY);
                }
            }
        }

        // 
        // Un cliente ha colocado el balón después de un pase al pie
        // 
        public void OnUseSkill(NetPlug plug, int idSkill)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    int idPlayer = thePlayer.TheMatch.GetIdPlayer(thePlayer);
                    thePlayer.TheMatch.OnUseSkill(idPlayer, idSkill);
                }
            }
        }

        // 
        // Un jugador declara que va a lanzar a puerta
        // TODO: IMPLEMENTACIÓN DE PORTERO!!!
        // 
        public void OnTiroPuerta(NetPlug plug)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    int idPlayer = thePlayer.TheMatch.GetIdPlayer(thePlayer);
                    thePlayer.TheMatch.OnTiroPuerta(idPlayer);
                }
            }
        }

        // 
        // Un jugador declara que ha ocurrido un gol (puede ser de si mismo o del contrario)!
        // 
        public void OnGoalScored(NetPlug plug, int scoredPlayer, int validity)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    int idPlayer = thePlayer.TheMatch.GetIdPlayer(thePlayer);

                    // VENDRÁ POR DUPLICADO NO REACCIONAR HASTA QUE LOS 2 JUGADORES CONFIRMEN!!!
                    thePlayer.TheMatch.OnGoalScored(idPlayer, scoredPlayer, validity);
                }
            }
        }

        // 
        // Un cliente notifica la finalización del partido
        // NOTE: Han abortado. No ha terminado
        // 
        public void OnServerTimeout(NetPlug plug)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    int idPlayer = thePlayer.TheMatch.GetIdPlayer(thePlayer);
                    thePlayer.TheMatch.OnServerTimeout(idPlayer);
                }
            }
        }

        // 
        // Un cliente notifica que abandona voluntariamente un partido
        // NOTE: Han abortado. No ha terminado
        // 
        public void OnAbort(NetPlug plug)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    int idPlayer = thePlayer.TheMatch.GetIdPlayer(thePlayer);
                    thePlayer.TheMatch.OnAbort(idPlayer);
                }
            }
        }

        //
        // Resultado que ha calculado un cliente de un disparo que ha terminado
        //
        public void OnResultShoot(NetPlug plug, int result, int countTouchedCaps, int paseToCapId, int framesSimulating, int reasonTurnChanged, string capList)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;
            
            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    int idPlayer = thePlayer.TheMatch.GetIdPlayer(thePlayer);
                    thePlayer.TheMatch.OnResultShoot(idPlayer, result, countTouchedCaps, paseToCapId, framesSimulating, reasonTurnChanged, capList);
                }
            }
        }

        // Nos mandan un nuevo mensaje al chat
        public void OnMsgToChatAdded(NetPlug plug, string msg)
        {
            RealtimePlayer thePlayer = plug.UserData as RealtimePlayer;

            lock (mGlobalLock)
            {
                if (thePlayer.TheMatch != null)
                {
                    thePlayer.TheMatch.OnMsgToChatAdded(thePlayer, msg);
                }
            }
        }

    }
}