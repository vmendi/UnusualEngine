﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Windows.Browser;

namespace Silverlight_game
{
    public partial class MainPage : UserControl
    {
        public MainPage()
        {
            InitializeComponent();

            //HtmlPage.RegisterScriptableObject("MainPage", this);
            HtmlPage.Window.Invoke("SilverlightRun");
        }
    }
}
