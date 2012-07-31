using System;
using System.Linq;
using SoccerServerV1.BDDModel;
using Weborb.Util.Logging;
using Weborb.Config;
using Weborb.Messaging;
using Weborb.Messaging.Server;
using Weborb.Messaging.Api;
using System.Data.Linq;
using SoccerServerV1.NetEngine;
using System.Threading;
using System.Net;
using System.Web;

namespace SoccerServerV1
{
	public class Global : System.Web.HttpApplication
	{		
		protected void Application_Start(object sender, EventArgs e)
		{
            var newEngine = new NetEngineMain(new Realtime());
            Application["NetEngineMain"] = newEngine;

            var starterThread = new Thread(StarterThread);
            starterThread.Name = "StarterThread";
            starterThread.Start();
		}

        public void StarterThread()
        {
            // Create a *blocking* request to weborb to make sure the logger is started. Dumps a benign exception (bad request... blah)
            WebRequest theRequest = HttpWebRequest.Create("http://localhost" + HttpRuntime.AppDomainAppVirtualPath + "/weborb.aspx");
            theRequest.GetResponse();
         
            Log.startLogging(GLOBAL);
            Log.log(GLOBAL, ":******************* Initialization from Global.asax *******************");

            (Application["NetEngineMain"] as NetEngineMain).Start();
            
            mSecondsTimer = new System.Timers.Timer(1000);
            mSecondsTimer.Elapsed += new System.Timers.ElapsedEventHandler(SecondsTimer_Elapsed);

            mSecondsTimer.Start();
        }

		void SecondsTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
		{         
			mSecondsTimer.Stop();
			mSeconds++;
            
			try
			{                
				using (SoccerDataModelDataContext theContext = new SoccerDataModelDataContext())
				{
					bool bSubmit = false;

					// Procesamos los entrenamientos expirados
					var expiredTrainings = from pendingTr in theContext.PendingTrainings
										   where pendingTr.TimeEnd < DateTime.Now
										   select pendingTr;

					if (expiredTrainings.Count() != 0)
					{
						foreach (PendingTraining pendingTr in expiredTrainings)
						{
							pendingTr.Team.Fitness += pendingTr.TrainingDefinition.FitnessDelta;

							if (pendingTr.Team.Fitness > 100)
								pendingTr.Team.Fitness = 100;
						}

						theContext.PendingTrainings.DeleteAllOnSubmit(expiredTrainings);
						bSubmit = true;
					}

					// 100 de fitness cada 24h
					if (mSeconds % 864 == 0)
					{
                        var notZeroFitness = (from t in theContext.Teams
                                              where t.Fitness > 0 && t.PendingTraining != null
                                              select t);

						foreach (var team in notZeroFitness)
							team.Fitness -= 1;

						bSubmit = true;
					}
                    
					if (bSubmit)
					{
						try
						{
							theContext.SubmitChanges(ConflictMode.FailOnFirstConflict);
						}
						catch (ChangeConflictException)
						{
							Log.log(GLOBAL, "WTF: Es el unico sitio donde se debería modificar!");
						}
					}
				}

				// Llamamos al tick de los partidos en curso
                ((Application["NetEngineMain"] as NetEngineMain).NetServer.NetClientApp as Realtime).OnSecondsTick();
			}
			catch (Exception excp)
			{
				Log.log(GLOBAL, excp);
			}
			finally
			{
				mSecondsTimer.Start();
			}
        }

		protected void Session_Start(object sender, EventArgs e)
		{
		}

		protected void Application_BeginRequest(object sender, EventArgs e)
		{
		}

		protected void Application_AuthenticateRequest(object sender, EventArgs e)
		{
		}

		protected void Application_Error(object sender, EventArgs e)
		{
            // Code that runs when an unhandled error occurs
            Exception objErr = Server.GetLastError().GetBaseException();
            
            Log.log(GLOBAL, "Error in: " + Request.Url.ToString() + ". Error Message:" + objErr.Message.ToString());
		}

		protected void Session_End(object sender, EventArgs e)
		{
		}

		protected void Application_End(object sender, EventArgs e)
		{
			Log.log(GLOBAL, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Application_End !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

            mSecondsTimer.Stop();
            mSecondsTimer.Dispose();

            (Application["NetEngineMain"] as NetEngineMain).Stop();
		}

        private const String GLOBAL = "GLOBAL";
        private System.Timers.Timer mSecondsTimer;
		private int mSeconds = 0;		
	}
}