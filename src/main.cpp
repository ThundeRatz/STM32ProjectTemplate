/**
 * @file main.cpp
 *
 * @brief Main function
 */

#include "mcu.hpp"

/*****************************************
 * Private Constant Definitions
 *****************************************/

static constexpr uint16_t led_toggle_delay_ms = 1500;

/*****************************************
 * Main Function
 *****************************************/

int main(void) {
    hal::mcu::init();

    for (;;) {
        hal::mcu::sleep(led_toggle_delay_ms);
    }
}
