/**
 * @file test_core.cpp
 *
 * @brief Core functions to the test
 *
 * @date 04/2021
 *
 * @copyright MIT License
 *
 */

#include "test_core.hpp"
#include "mcu.hpp"

/*****************************************
 * Public Functions Bodies Definitions
 *****************************************/

void test_core_init(void) {
    hal::mcu::init();
}
