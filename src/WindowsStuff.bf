namespace SDLTest
{
	using System;

	static
	{
		
		[AllowDuplicates]
		public enum HitTestResult
		{
		    NotHandled = -3,

		    Border = 18,
		    Bottom = 15,
		    BottomLeft = 16,
		    BottomRight = 17,
		    Caption = 2,
		    Client = 1,
		    Close = 20,
		    Error = -2,
		    GrowBox = 4,
		    Help = 21,
		    HScroll = 6,
		    Left = 10,
		    Menu = 5,
		    MaxButton = 9,
		    MinButton = 8,
		    NoWhere = 0,
		    Reduce = 8,
		    Right = 11,
		    Size = 4,
		    SysMenu = 3,
		    Top = 12,
		    TopLeft = 13,
		    TopRight = 14,
		    Transparent = -1,
		    VScroll = 7,
		    Zoom = 9            
		}



		[CRepr]
		struct MARGINS
		{
			int32 lw;
			int32 rw;
			int32 th;
			int32 lh;

			public this(int32 a, int32 b, int32 c, int32 d)
			{
				lw = a;
				rw = b;
				th = c;
				lh = d;
			}
		}

		[CRepr]
		public struct RECT
		{
		    public int32 Left;        // x position of upper-left corner
		    public int32 Top;         // y position of upper-left corner
		    public int32 Right;       // x position of lower-right corner
		    public int32 Bottom;      // y position of lower-right corner
		}

		[CRepr]
		struct POINT {
		  public int32 x;
		  public int32 y;
		}

		[CRepr]
		struct MINMAXINFO {
		  	public POINT ptReserved;
		  	public POINT ptMaxSize;
		  	public POINT ptMaxPosition;
		 	public POINT ptMinTrackSize;
			public POINT ptMaxTrackSize;
		}

		[Import("USER32.dll"), CLink]
		public static extern int SetWindowLongPtrA(System.Windows.HWnd hWnd, int32 nIndex, void* dwNewLong);

		[Import("Dwmapi.dll"), CLink]
		public static extern int DwmExtendFrameIntoClientArea(System.Windows.HWnd hWnd, MARGINS* margins);

		[Import("USER32.dll"), CLink]
		public static extern int DefWindowProcA(System.Windows.HWnd hWnd, int32 msg, int wParam, int lParam);

		[Import("user32.dll"), CLink]
		public static extern bool GetWindowRect(System.Windows.HWnd hWnd, out RECT lpRect);

		public static int LOWORD(int i)
		{
		    return (int16)(i & 0xFFFF);
		}

		public static int HIWORD(int i)
		{
		    return (int16)(i >> 16);
		}
	}
}
