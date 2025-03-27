/**
 * @file gpio.cpp
 *
 * @brief HAL GPIO class source
 *
 * @author Thunderatz Development Team <comp@thunderatz.org>
 */

#include "gpio.hpp"

namespace hal {
Gpio::Gpio(const Config& config) : port{config.port}, pin{config.pin}, active_state{config.active_state} { }

bool Gpio::read() const {
    return HAL_GPIO_ReadPin(this->port, this->pin) == this->active_state;
}

void Gpio::write(bool state) {
    GPIO_PinState pin_state = this->active_state;

    if (!state) {
        pin_state = (this->active_state == GPIO_PIN_SET) ? GPIO_PIN_RESET : GPIO_PIN_SET;
    }

    HAL_GPIO_WritePin(this->port, this->pin, pin_state);
}

void Gpio::toggle() {
    HAL_GPIO_TogglePin(this->port, this->pin);
}
}  // namespace hal
