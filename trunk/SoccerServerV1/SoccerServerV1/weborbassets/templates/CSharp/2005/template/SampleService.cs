using System;
using System.Collections.Generic;
using System.Text;
using Weborb;

namespace $safeprojectname$
{
	/// <summary>
	/// WebORB-enabled Web Service
	/// </summary>
	public class SampleService
	{
		public SampleService()
		{
		}

		public string echo(string text)
		{
			return "Service echo: " + text;
		}
	}
}
