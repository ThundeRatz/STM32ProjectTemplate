/**
 * @file gpio.hpp
 *
 * @brief HAL GPIO class header
 *
 * @author Thunderatz Development Team <comp@thunderatz.org>
 */

#ifndef HAL_GPIO_HPP
#define HAL_GPIO_HPP

#include <cstdint>
#include <gpio.h>

namespace hal {
/**
 * @brief Class for controlling GPIO pins on STM32 microcontrollers
 */
class Gpio {
public:
    /**
     * @brief Configuration structure for GPIO pin
     */
    struct Config {
        GPIO_TypeDef* port{};
        uint16_t      pin{};
        GPIO_PinState active_state = GPIO_PIN_SET;
    };

    /**
     * @brief Constructor for the Gpio class
     *
     * @param config Configuration for the GPIO pin
     */
    explicit Gpio(const Config& config);

    /**
     * @brief Read the current state of the GPIO pin
     *
     * @return bool The current state of the GPIO pin (true for high, false for
     * low)
     */
    bool read() const;

    /**
     * @brief Write a new state to the GPIO pin
     *
     * @param pin_state The state to be written (true for high, false for low)
     */
    void write(bool state);

    /**
     * @brief Toggle the state of the GPIO pin
     */
    void toggle();

private:
    /**
     * @brief The port of the GPIO
     */
    GPIO_TypeDef* port;

    /**
     * @brief The pin number of the GPIO
     */
    uint16_t pin;

    /**
     * @brief The active state of the GPIO
     */
    GPIO_PinState active_state;
};
}  // namespace hal

#endif  // HAL_GPIO_HPP
