#include "gpio.hpp"

const hal::Gpio::Config led_config = {
    .port = GPIOC,
    .pin = GPIO_PIN_13,
};
