using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

// The Blank Page item template is documented at https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace CudaMage
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        public MainPage()
        {
            this.InitializeComponent();
        }

        private void StartDll_Click(object sender, RoutedEventArgs e)
        {
            GridView grid = new GridView();
            int[] res = CudaAdd.getNumbers();
            for (int i = 0; i < 16; i++)
            {
                grid.Items.Add(res[i]);
            }
            ResultGrid.Children.Add(grid);
        }
    }
}

class CudaAdd
{
    [DllImport("CudaTest.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "GETRANDOMARRAYSUM")]
    unsafe public static extern void GETRANDOMARRAYSUM(
        [MarshalAs(UnmanagedType.LPArray)] int[] c,
        int N
        );

    public static int[] getNumbers()
    {
        int[] c = new int[16];
        int[]a;
        GETRANDOMARRAYSUM(c,16);
        return c;
    }
}
