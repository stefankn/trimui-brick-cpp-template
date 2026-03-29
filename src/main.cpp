#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <iostream>

// TrimUI Brick native resolution
const int SCREEN_WIDTH = 1024;
const int SCREEN_HEIGHT = 768;

int main(int argc, char* argv[]) {
    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK) < 0) {
        std::cerr << "SDL init failed: " << SDL_GetError() << "\n";
        return 1;
    }

    // Initialize SDL_ttf
    if (TTF_Init() < 0) {
        std::cerr << "TTF_Init failed: " << TTF_GetError() << "\n";
        SDL_Quit();
        return 1;
    }

    // Create window
#ifdef __linux__
    SDL_Window* window = SDL_CreateWindow(
        "Brick App",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        SCREEN_WIDTH, SCREEN_HEIGHT,
        SDL_WINDOW_FULLSCREEN
    );
#else
    // Windowed mode for macOS development
    SDL_Window* window = SDL_CreateWindow(
        "Brick App",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        SCREEN_WIDTH, SCREEN_HEIGHT,
        SDL_WINDOW_SHOWN
    );
#endif

    if (!window) {
        std::cerr << "Window creation failed: " << SDL_GetError() << "\n";
        TTF_Quit();
        SDL_Quit();
        return 1;
    }

    // Create renderer
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        std::cerr << "Renderer creation failed: " << SDL_GetError() << "\n";
        SDL_DestroyWindow(window);
        TTF_Quit();
        SDL_Quit();
        return 1;
    }

    // Initialize joystick (for Brick hardware)
    SDL_Joystick* joystick = nullptr;
    if (SDL_NumJoysticks() > 0) {
        joystick = SDL_JoystickOpen(0);
        if (joystick) {
            std::cout << "Joystick detected: " << SDL_JoystickName(joystick) << "\n";
        }
    } else {
        std::cout << "No joysticks found\n";
    }

    // Main loop
    bool running = true;
    SDL_Event event;

    while (running) {
        // Event handling
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_QUIT:
                    running = false;
                    break;

                // Keyboard (development)
                case SDL_KEYDOWN:
                    if (event.key.keysym.sym == SDLK_ESCAPE) {
                        running = false;
                    }
                    break;

                // D-pad navigation
                case SDL_JOYHATMOTION:
                    switch (event.jhat.value) {
                        case SDL_HAT_UP:    std::cout << "D-pad Up\n"; break;
                        case SDL_HAT_DOWN:  std::cout << "D-pad Down\n"; break;
                        case SDL_HAT_LEFT:  std::cout << "D-pad Left\n"; break;
                        case SDL_HAT_RIGHT: std::cout << "D-pad Right\n"; break;
                    }
                    break;

                // Buttons: A=1 (select), B=0 (back), X=3, Y=2
                case SDL_JOYBUTTONDOWN:
                    std::cout << "Button " << (int)event.jbutton.button << " pressed\n";
                    if (event.jbutton.button == 0) { // B button
                        running = false;
                    }
                    break;
            }
        }

        // Rendering
        SDL_SetRenderDrawColor(renderer, 20, 20, 30, 255);
        SDL_RenderClear(renderer);

        // Draw your content here

        SDL_RenderPresent(renderer);

        // Cap frame rate
        SDL_Delay(16); // ~60 FPS
    }

    // Cleanup
    if (joystick) {
        SDL_JoystickClose(joystick);
    }
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    TTF_Quit();
    SDL_Quit();

    return 0;
}
