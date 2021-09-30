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
		private static function int WndProc(System.Windows.HWnd hwnd, int32 uMsg, int wParam, int lParam);
		private static WndProc m_SDLWndProc;

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

			//Add a hittest through SDL's own API.
			SDL.SetWindowHitTest(m_Window, => HitTest, (void*)0);

			SDL.SDL_SysWMinfo sysInfo = .();
			SDL.GetWindowWMInfo(m_Window, ref sysInfo);

			//Store the pointer to SDL's windowproc
			int addr = Windows.GetWindowLong(sysInfo.info.win.window, Windows.GWL_WNDPROC);
			m_SDLWndProc = (.)addr;

			//Set the actual WndProc to our own custom one.
			WndProc customProc = => WindowProc;
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
				//Poll for events.
				SDL.Event event = .();
				while(SDL.PollEvent(out event) != 0)
				{
					switch(event.type)
					{
						default:
						{
							
						}
					}
				}

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

		public static SDL.HitTestResult HitTest(SDL.Window win, SDL.Point* area, void* data)
		{
			if(area.x <= 2 && area.y <= 2)
				return .ResizeTopLeft;

			if(area.x >= m_WindowWidth - 2 && area.y <= 2)
				return .ResizeTopRight;

			if(area.x <= 2 && area.y >= m_WindowHeight - 2)
				return .ResizeBottomLeft;

			if(area.x >= m_WindowWidth - 2 && area.y >= m_WindowHeight - 2)
				return .ResizeBottomRight;

			if(area.x <= 2)
				return .ResizeLeft;

			if(area.x >= m_WindowWidth - 2)
				return .ResizeRight;

			if(area.y <= 2)
				return .ResizeTop;

			if(area.y >= m_WindowHeight - 2)
				return .ResizeBottom;

			if(area.y <= 25)
				return .Draggable;

			return .Normal;
		}

		public static int WindowProc(System.Windows.HWnd hwnd, int32 uMsg, int wParam, int lParam)
		{
			switch(uMsg)
			{
				case 5: //WM_SIZE
				{
					int x = LOWORD(lParam);
					int y = HIWORD(lParam);

					Resize(x, y);
					Draw();
				}
			}

			return m_SDLWndProc(hwnd, uMsg, wParam, lParam);
		}

		public ~this()
		{
			delete m_Stopwatch;
		}
	}
}
