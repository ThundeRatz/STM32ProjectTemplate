/**
 * @file mcu.c
 *
 * @brief MCU related
 */

#include <stdint.h>

#include "mcu.hpp"

#include "gpio.h"
#include "main.h"

/*****************************************
 * Public Function Body Definitions
 *****************************************/

void hal::mcu::init(void)
{
    HAL_Init();

    SystemClock_Config();

    MX_GPIO_Init();
}

void hal::mcu::sleep(uint32_t ms)
{
    HAL_Delay(ms);
}

void hal::mcu::led_toggle(void)
{
    HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
}
