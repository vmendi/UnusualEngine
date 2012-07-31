/*****************************************************************
*
*  To force the compiler to include all the generated complex types
*  into the compiled application, add the following line of code 
*  into the main function of your Flex application:
*
*  new SoccerServerV1.DataTypeInitializer();
*
******************************************************************/

package SoccerServerV1
{
	import SoccerServerV1.TransferModel.vo.TeamMatchStats;
	import SoccerServerV1.TransferModel.vo.PredefinedTeam;
	import SoccerServerV1.TransferModel.vo.RankingPage;
	import SoccerServerV1.TransferModel.vo.RankingTeam;
	import SoccerServerV1.TransferModel.vo.TeamDetails;
	import SoccerServerV1.TransferModel.vo.Team;
	import SoccerServerV1.TransferModel.vo.PendingTraining;
	import SoccerServerV1.TransferModel.vo.TrainingDefinition;
	import SoccerServerV1.TransferModel.vo.SoccerPlayer;
	import SoccerServerV1.TransferModel.vo.SpecialTraining;
	import SoccerServerV1.TransferModel.vo.SpecialTrainingDefinition;
	
	public class DataTypeInitializer
	{
		public function DataTypeInitializer()
		{
			new SoccerServerV1.TransferModel.vo.TeamMatchStats();	
			new SoccerServerV1.TransferModel.vo.PredefinedTeam();	
			new SoccerServerV1.TransferModel.vo.RankingPage();	
			new SoccerServerV1.TransferModel.vo.RankingTeam();	
			new SoccerServerV1.TransferModel.vo.TeamDetails();	
			new SoccerServerV1.TransferModel.vo.Team();	
			new SoccerServerV1.TransferModel.vo.PendingTraining();	
			new SoccerServerV1.TransferModel.vo.TrainingDefinition();	
			new SoccerServerV1.TransferModel.vo.SoccerPlayer();	
			new SoccerServerV1.TransferModel.vo.SpecialTraining();	
			new SoccerServerV1.TransferModel.vo.SpecialTrainingDefinition();	
		}
	}  
}  
