/**
 * @file test_gpio.cpp
 *
 * @brief Test for GPIO HAL implementation
 *
 * @author Thunderatz Development Team <comp@thunderatz.org>
 */

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
