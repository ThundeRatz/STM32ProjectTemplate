/**
 * @file mcu.cpp
 *
 * @brief MCU related
 */

#include "mcu.hpp"
// #include <gpio.h>
// #include "gpio.h"
#include "../cube/Inc/gpio.h"

/*****************************************
 * Public Function Body Definitions
 *****************************************/

namespace hal {
void mcu::init() {
    HAL_Init();

    SystemClock_Config();

    MX_GPIO_Init();
}

void mcu::sleep(uint32_t ms) {
    HAL_Delay(ms);
}
}  // namespace hal
