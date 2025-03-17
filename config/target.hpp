#ifndef TARGET_HPP
#define TARGET_HPP

#include <main.h>
#include "gpio.hpp"

const hal::Gpio::Config led_config = {
    .port = LED_GPIO_Port,
    .pin = LED_Pin,
};


#endif // TARGET_HPP
