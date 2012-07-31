using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using SoccerServerV1.BDDModel;
using Weborb.Util.Logging;
using System.Data.Linq;
using Weborb.Service;

namespace SoccerServerV1
{
	public partial class MainService
	{
        [WebORBCache(CacheScope = CacheScope.Global)]
		public List<TransferModel.TrainingDefinition> RefreshTrainingDefinitions()
		{
            using (CreateDataForRequest())
            {
                List<TransferModel.TrainingDefinition> ret = new List<TransferModel.TrainingDefinition>();

                foreach (TrainingDefinition tr in mContext.TrainingDefinitions)
                    ret.Add(new TransferModel.TrainingDefinition(tr));

                return ret;
            }
		}

		public int RefreshRemainingSecondsForPendingTraining()
		{
            using (CreateDataForRequest())
            {
                int ret = 0;
                Team theTeam = mPlayer.Team;
                PendingTraining theTraining = theTeam.PendingTraining;

                if (theTraining != null)
                {
                    ret = (int)Math.Ceiling(theTraining.TimeEnd.Subtract(DateTime.Now).TotalSeconds);

                    // Jamas devolvemos < 0. Sera que el thread no ha pasado todavia.
                    if (ret <= 0)
                    {
                        ret = 1;
                    }
                }

                return ret;
            }
		}

		public TransferModel.PendingTraining Train(string trainingName)
		{
            using (CreateDataForRequest())
            {
                PendingTraining ret = mPlayer.Team.PendingTraining;

                if (ret == null)
                {
                    var newTrDef = (from trDef in mContext.TrainingDefinitions
                                    where trDef.Name == trainingName
                                    select trDef).FirstOrDefault();

                    if (newTrDef == null)
                        throw new Exception("TrainingDefinition doesn't exist " + trainingName);

                    ret = new PendingTraining();
                    ret.Team = mPlayer.Team;
                    ret.TrainingDefinition = newTrDef;
                    ret.TimeStart = DateTime.Now;
                    ret.TimeEnd = ret.TimeStart.Add(TimeSpan.FromSeconds(newTrDef.Time));

                    mContext.PendingTrainings.InsertOnSubmit(ret);
                    mContext.SubmitChanges();
                }

                return new TransferModel.PendingTraining(ret);
            }
		}


		public void TrainSpecial(int specialTrainingDefinitionID)
		{
            using (CreateDataForRequest())
            {
                Team theTeam = mPlayer.Team;

                SpecialTraining theTraining = (from t in theTeam.SpecialTrainings
                                               where t.SpecialTrainingDefinitionID == specialTrainingDefinitionID
                                               select t).FirstOrDefault();

                if (theTraining == null)
                    throw new Exception("Unknown Training");

                if (theTeam.XP < theTraining.SpecialTrainingDefinition.RequiredXP)
                    throw new Exception("Nice try");

                if (theTeam.SkillPoints < theTraining.SpecialTrainingDefinition.EnergyStep)
                    throw new Exception("Nice try");

                theTraining.EnergyCurrent += theTraining.SpecialTrainingDefinition.EnergyStep;

                // Hemos eliminado la energia del equipo. Ahora las habilidades especiales se entrenan restando puntos Mahou
                theTeam.SkillPoints -= theTraining.SpecialTrainingDefinition.EnergyStep;

                if (theTraining.EnergyCurrent >= theTraining.SpecialTrainingDefinition.EnergyTotal)
                {
                    theTraining.EnergyCurrent = theTraining.SpecialTrainingDefinition.EnergyTotal;
                    theTraining.IsCompleted = true;
                }

                mContext.SubmitChanges();
            }
		}


        public void AssignSkillPoints(int soccerPlayerID, int weight, int sliding, int power)
        {
            using (CreateDataForRequest())
            {
                Team playerTeam = mPlayer.Team;
                int available = playerTeam.SkillPoints;

                if (weight < 0 || sliding < 0 || power < 0)
                    throw new Exception("Nice hack try");

                if (weight + sliding + power > available)
                    throw new Exception("Too many skill points");

                SoccerPlayer soccerPlayer = (from sp in playerTeam.SoccerPlayers
                                             where sp.SoccerPlayerID == soccerPlayerID
                                             select sp).FirstOrDefault();

                if (soccerPlayer == null)
                    throw new Exception("Invalid SoccerPlayer");

                soccerPlayer.Weight += weight;
                soccerPlayer.Sliding += sliding;
                soccerPlayer.Power += power;

                playerTeam.SkillPoints -= weight + sliding + power;

                if (soccerPlayer.Weight > 100)
                    soccerPlayer.Weight = 100;

                if (soccerPlayer.Sliding > 100)
                    soccerPlayer.Sliding = 100;

                if (soccerPlayer.Power > 100)
                    soccerPlayer.Power = 100;

                mContext.SubmitChanges();
            }
        }
	}
}