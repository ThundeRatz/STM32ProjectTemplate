#include "target.hpp"
#include "mcu.hpp"

int main() {
    hal::mcu::init();

    hal::Gpio led{led_config};

    for (;;) {
        led.toggle();
        hal::mcu::sleep(500);
    }
}
