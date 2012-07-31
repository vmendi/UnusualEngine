using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using SoccerServerV1.NetEngine;
using Weborb.Util.Logging;

namespace SoccerServerV1
{
    public partial class Realtime
    {
        public string TestMethod01(NetPlug src, string input)
        {
            if (input != "TestMethod01Input")
                return "FAILED";

            return "TestMethod01Return";
        }

        public void TestMethod02(NetPlug src, float input)
        {
            if (input != 666.666f)
                Log.log(REALTIME, "TestMethod02");
        }

        public string TestMethod03(NetPlug src)
        {
            string ret = "";

            for (int c = 0; c < 666; c++)
                ret += "-";

            return ret;
        }

        public string TestMethod04(NetPlug src)
        {
            return src.ID.ToString();
        }
    }
}