/**
 * @file test_main.cpp
 *
 * @brief Main function for tests.
 *
 * @author Thunderatz Development Team <comp@thunderatz.org>
 */

#include "mcu.hpp"

int main() {
    hal::mcu::init();

    for (;;) { }
}
