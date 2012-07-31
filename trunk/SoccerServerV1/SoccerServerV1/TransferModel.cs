using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using System.Collections;
using Weborb.Writer;
using System.Reflection;

namespace SoccerServerV1.TransferModel
{
	public class Team
	{
		public string Name;
		public int PredefinedTeamID;
		public string Formation;
		public int TrueSkill;
		public int XP;
		public int SkillPoints;
		public int Energy;
		public int Fitness;
		
		public PendingTraining PendingTraining;
		public List<SoccerPlayer> SoccerPlayers = new List<SoccerPlayer>();
		public List<SpecialTraining> SpecialTrainings = new List<SpecialTraining>();
		
		public Team(BDDModel.Team from) 
		{
			Name = from.Name;
			PredefinedTeamID = from.PredefinedTeamID;
			Formation = from.Formation;
			TrueSkill = from.TrueSkill;
			XP = from.XP;
			SkillPoints = from.SkillPoints;
			Energy = from.Energy;
			Fitness = from.Fitness;
			
			if (from.PendingTraining != null)
				PendingTraining = new PendingTraining(from.PendingTraining);

			foreach (BDDModel.SoccerPlayer soccerPlayer in from.SoccerPlayers)
				SoccerPlayers.Add(new SoccerPlayer(soccerPlayer));

			foreach (BDDModel.SpecialTraining sp in from.SpecialTrainings)
				SpecialTrainings.Add(new SpecialTraining(sp));
		}
	}

	public class SoccerPlayer
	{
		public int SoccerPlayerID;
		public string Name;
		public int Number;
		public int Type;
		public int FieldPosition;
		public int Weight;
		public int Sliding;
		public int Power;
		public bool IsInjured;

		public SoccerPlayer(BDDModel.SoccerPlayer from) { CopyHelper.Copy(from, this);  }
	}

	public class SpecialTrainingDefinition
	{
		public int SpecialTrainingDefinitionID;
		public string Name;
		public string Description;
		public int RequiredXP;
		public int EnergyStep;
		public int EnergyTotal;

		public SpecialTrainingDefinition(BDDModel.SpecialTrainingDefinition from) { CopyHelper.Copy(from, this); }
	}

	public class SpecialTraining
	{
		public SpecialTrainingDefinition SpecialTrainingDefinition;
		public int EnergyCurrent;
		public bool IsCompleted;

		public SpecialTraining(BDDModel.SpecialTraining from) 
		{
			SpecialTrainingDefinition = new SpecialTrainingDefinition(from.SpecialTrainingDefinition);
			EnergyCurrent = from.EnergyCurrent;
			IsCompleted = from.IsCompleted;
		}
	}

	public class TrainingDefinition
	{
		public int TrainingDefinitionID;
		public string Name;
		public string Description;
		public int FitnessDelta;
		public int Time;

		public TrainingDefinition(BDDModel.TrainingDefinition from) { CopyHelper.Copy(from, this); }
	}

	public class PendingTraining
	{
		public TrainingDefinition TrainingDefinition;
		public DateTime TimeStart;
		public DateTime TimeEnd;

		public PendingTraining(BDDModel.PendingTraining from) 
		{
			TimeStart = from.TimeStart;
			TimeEnd = from.TimeEnd;
			TrainingDefinition = new TrainingDefinition(from.TrainingDefinition);
		}
	}

	public class PredefinedTeam
	{
		public int PredefinedTeamID;
		public string Name;

		public PredefinedTeam(BDDModel.PredefinedTeam from) { CopyHelper.Copy(from, this); }
	}

    public class RankingPage
    {
        static public int RANKING_TEAMS_PER_PAGE = 50;

        public int PageIndex;
        public int TotalPageCount;
		public List<RankingTeam> Teams = new List<RankingTeam>();

        public RankingPage(int pageIndex, int totalPageCount)
        {
            PageIndex = pageIndex;
            TotalPageCount = totalPageCount;
        }
    }

	public class RankingTeam
	{
		public string Name;
		public string FacebookID;
		public string PredefinedTeamName;
		public int TrueSkill;
	}

	public class TeamMatchStats
	{
		public int NumMatches;
		public int NumWonMatches;
		public int NumLostMatches;
		public int NumGoalsScored;
		public int NumGoalsReceived;
	}

    public class TeamDetails
    {
        public int AverageWeight;
        public int AverageSliding;
        public int AveragePower;

        public int Fitness;

        public List<int> SpecialSkillsIDs;
    }

	public class CopyHelper
	{
		static public void Copy(Object source, Object target)
		{
			Type sourceType = source.GetType();
			Type targetType = target.GetType();

			foreach (FieldInfo targetField in targetType.GetFields())
			{
				PropertyInfo sourceProperty = sourceType.GetProperty(targetField.Name);
				targetField.SetValue(target, sourceProperty.GetValue(source, null));
			}
		}
	}
}