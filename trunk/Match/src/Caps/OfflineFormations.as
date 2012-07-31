package Caps
{
	//
	// Alineaciones de los jugadores cuando no nos vienen del manager
	//
	public class OfflineFormations
	{
		// Distintos alineamientos posibles
		static public const Defensive:int = 0;			// 
		static public const Medium:int = 1;				// 
		static public const Offensive:int = 2;			//
		static public const Count:int = 3;				// Contador de alineaciones
		
		
		static public var Position:Array =
			[
				// Alineación defensiva 
				[
					{ x:18.85, 	y:215.45*0.93  },
					{ x:96.85*0.93, 	y:170.45*0.93  },
					{ x:96.85*0.93, 	y:271.45*0.93  },
					{ x:198.85*0.93, y:57.5*0.93    },
					{ x:202.8*0.93, 	y:219.45*0.93  },
					{ x:202.8*0.93, 	y:383.45*0.93  },
					{ x:277.85*0.93, y:151.45*0.93  },
					{ x:276.85*0.93, y:284.45*0.93  }
				],
				// Alineación media
				[
					{ x:18.85, 	y:215.45  },
					{ x:96.85, 	y:170.45  },
					{ x:96.85, 	y:271.45  },
					{ x:198.85, y:57.5    },
					{ x:202.8, 	y:219.45  },
					{ x:202.8, 	y:383.45  },
					{ x:277.85, y:151.45  },
					{ x:276.85, y:284.45  }
				],
				// Alineación ofensiva
				[
					{ x:18.85, 	y:215.45  },
					{ x:96.85, 	y:170.45  },
					{ x:96.85, 	y:271.45  },
					{ x:198.85, y:57.5    },
					{ x:202.8, 	y:219.45  },
					{ x:202.8, 	y:383.45  },
					{ x:277.85, y:151.45  },
					{ x:276.85, y:284.45  }
				]
			]
	}
}