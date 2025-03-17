#ifndef TARGET_HPP
#define TARGET_HPP

#include <main.h>
#include "gpio.hpp"

const hal::Gpio::Config led_config = {
    // NOLINTNEXTLINE(cppcoreguidelines-pro-type-cstyle-cast, performance-no-int-to-ptr)
    .port = LED_GPIO_Port,
    .pin = LED_Pin,
};


#endif // TARGET_HPP
