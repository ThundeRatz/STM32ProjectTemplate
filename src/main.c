#include <stdint.h>

#include "gpio.h"
#include "main.h"
#include "mcu.h"

int main(void) {
    HAL_Init();

    SystemClock_Config();

    MX_GPIO_Init();

    for (;;) {
        HAL_GPIO_TogglePin(LD2_GPIO_Port, LD2_Pin);
        HAL_Delay(1500);
    }
}
