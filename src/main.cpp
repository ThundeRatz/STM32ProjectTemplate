/**
 * @file main.cpp
 *
 * @brief Main function
 *
 * @author Thunderatz Development Team <comp@thunderatz.org>
 */

#include "mcu.hpp"
#include "target.hpp"

/*****************************************
 * Private Constant Definitions
 *****************************************/

static constexpr uint16_t led_toggle_delay_ms = 1500;

/*****************************************
 * Main Function
 *****************************************/

int main() {
    hal::mcu::init();

    hal::Gpio led{led_config};

    for (;;) {
        led.toggle();
        hal::mcu::sleep(led_toggle_delay_ms);
    }
}
