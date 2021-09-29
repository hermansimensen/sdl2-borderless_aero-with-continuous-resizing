namespace SDLTest
{
	using System;
	using System.Diagnostics;
	using SDL2;

	class BorderlessWindow
	{
		private static SDL.Window* m_Window;
		private static SDL.Renderer* m_Renderer;
		private static Stopwatch m_Stopwatch;

		private static int m_WindowWidth;
		private static int m_WindowHeight;

		private static int m_MinWidth;
		private static int m_MinHeight;
		
		private static bool m_QuitRequested;

		public this()
		{
			InitSDL();
			StartLoop();
		}

		public bool InitSDL()
		{
			if(SDL.Init(.Video | .Events) != 0)
			{
				Console.WriteLine("Could not initialize SDL video rendering. Error: {}", SDL.GetError());
				return false;
			}

			SDL.SetHintWithPriority("SDL_BORDERLESS_RESIZABLE_STYLE", "1", .Override);
			SDL.SetHintWithPriority("SDL_BORDERLESS_WINDOWED_STYLE", "1", .Override);

			m_WindowWidth = 800;
			m_WindowHeight = 600;

			m_MinWidth = 640;
			m_MinHeight = 480;

			m_Window = SDL.CreateWindow("SDLTest", .Centered, .Centered, (int32) m_WindowWidth, (int32) m_WindowHeight, .Resizable);
			SDL.SetWindowBordered(m_Window, .False);

			m_Renderer = SDL.CreateRenderer(m_Window, -1, .Accelerated);

			SDL.SetWindowMinimumSize(m_Window, (int32) m_MinWidth, (int32) m_MinWidth);

			SDL.SDL_SysWMinfo sysInfo = .();
			SDL.GetWindowWMInfo(m_Window, ref sysInfo);

			function int(System.Windows.HWnd hwnd, int32 uMsg, int wParam, int lParam) customProc = => WindowProc;

			Windows.SetWindowLong(sysInfo.info.win.window, Windows.GWL_WNDPROC, (int) (void*) customProc);

			return true;
		}

		private void StartLoop()
		{
			int64 lastRender = 0;

			m_Stopwatch = new .();
			m_Stopwatch.Start();

			while(!m_QuitRequested)
			{
				SDL.PumpEvents();

				int remaining;

				int64 delta = m_Stopwatch.ElapsedMicroseconds - lastRender;
				if(delta >= 16666)
				{
					Draw();
					lastRender = m_Stopwatch.ElapsedMicroseconds;
				}
				else
				{
					remaining = 16666 - delta;
					SDL.Delay((uint32)remaining/1000);
				}
			}
		}

		private static void Resize(int width, int height)
		{
			m_WindowWidth = width;
			m_WindowHeight = height;

			SDL.SetWindowSize(m_Window, (int32) width, (int32) height);
		}

		private static void Draw()
		{
			SDL.SetRenderDrawColor(m_Renderer, 127, 127, 127, 255);
			SDL.RenderClear(m_Renderer);

			SDL.Rect rect =  .();
			rect.w = (int32) ((m_WindowWidth - rect.w) / 2);
			rect.h = (int32) ((m_WindowHeight - rect.h) / 2);
			rect.x = (int32) ((m_WindowWidth - rect.w) / 2);
			rect.y = (int32) ((m_WindowHeight - rect.h) / 2);

			SDL.SetRenderDrawColor(m_Renderer, 255, 255, 255, 255);
			SDL.RenderFillRect(m_Renderer, &rect);

			SDL.RenderPresent(m_Renderer);
		}
		public static void CoordsToWindowPoint(int x, int y, out int xx, out int yy)
		{
			SDL.SDL_SysWMinfo sysInfo = .();
			SDL.GetWindowWMInfo(m_Window, ref sysInfo);

			RECT bounds = .();
			GetWindowRect(sysInfo.info.win.window, out bounds);

			xx = x - bounds.Left;
			yy = y - bounds.Top;
		}

		public static int WindowProc(System.Windows.HWnd hwnd, int32 uMsg, int wParam, int lParam)
		{
			SDL.Event e = .();
			switch(uMsg)
			{
				case 2: //WM_DESTROY
				{
					m_QuitRequested = true;
				}

				case 5: //WM_SIZE
				{
					int x = LOWORD(lParam);
					int y = HIWORD(lParam);

					Resize(x, y);
					Draw();
				}

				case 36: //WM_GETMINMAXINFO 
				{
					MINMAXINFO* info = (MINMAXINFO*) (void*) lParam;
					info.ptMinTrackSize.x = (int32) m_MinWidth;
					info.ptMinTrackSize.y = (int32) m_MinHeight;
					return 0;
				}

				case 131: //WM_NCCALCSIZE
				{
					return 0;
				}

				case 132: //WM_NCHITTEST
				{
					int x = LOWORD(lParam);
					int y = HIWORD(lParam);

					CoordsToWindowPoint(x, y, out x, out y);

					if(x <= 2 && y <= 2)
						return 13;

					if(x >= m_WindowWidth - 2 && y <= 2)
						return 14;

					if(x <= 2 && y >= m_WindowHeight - 2)
						return 16;

					if(x >= m_WindowWidth - 2 && y >= m_WindowHeight - 2)
						return 17;

					if(x <= 2)
						return 10;

					if(x >= m_WindowWidth - 2)
						return 11;

					if(y <= 2)
						return 12;

					if(y >= m_WindowHeight - 2)
						return 15;

					if(y <= 25)
						return 2;

					return 0;
				}

				default:
				{

				}
			}

			return DefWindowProcA(hwnd, uMsg, wParam, lParam);
		}

		private static void Exit()
		{
			SDL.Quit();
			m_QuitRequested = true;
		}

		public ~this()
		{
			delete m_Stopwatch;
		}
	}
}
