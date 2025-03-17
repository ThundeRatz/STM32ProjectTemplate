#include "target.hpp"
#include "mcu.hpp"

int main() {
    hal::mcu::init();

    hal::Gpio led{led_config};

    for (;;) {
        led.write(true);
        hal::mcu::sleep(500);
        led.write(false);
        hal::mcu::sleep(500);
    }

    return 0;
}
