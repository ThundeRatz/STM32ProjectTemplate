/**
 * @file mcu.hpp
 *
 * @brief MCU related
 *
 * @author Thunderatz Development Team <comp@thunderatz.org>
 */

#ifndef MCU_HPP
#define MCU_HPP

#include <cstdint>

/*****************************************
 * Public Function Prototypes
 *****************************************/

extern "C" {
/**
 * @brief Initializes System Clock.
 * @note  Defined by cube.
 */
void SystemClock_Config(void);
}

namespace hal {
class mcu {
public:
    /**
     * @brief Initializes MCU and some peripherals.
     */
    static void init();

    /**
     * @brief Put the MCU to sleep.
     *
     * @param ms  Sleep time in milliseconds
     */
    static void sleep(uint32_t ms);
};
}  // namespace hal
#endif  // MCU_HPP
