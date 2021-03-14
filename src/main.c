#include <stdint.h>
#include "stm32f1xx.h"

#define LED_DELAY 500000UL // Ticks, 8MHz clock

int main(void)
{
    uint32_t led_delay_count = 0;

    RCC->APB2ENR |= RCC_APB2ENR_IOPCEN;                    // enable clock
    GPIOC->CRH &= ~(GPIO_CRH_MODE13 | GPIO_CRH_CNF13);     // reset PC13
    GPIOC->CRH |= (GPIO_CRH_MODE13_1 | GPIO_CRH_MODE13_0); // config PC13

    while (1)
    {
        // Increment count, wrap at LED_DELAY
        led_delay_count = ((led_delay_count + 1) % LED_DELAY);

        // Note: the on-board LED is 'active low' (turns on when PC13 is low)

        if (led_delay_count == 0)
        {
            GPIOC->BSRR = GPIO_BSRR_BR13; // led on
        }
        else if (led_delay_count == (LED_DELAY / 2))
        {
            GPIOC->BSRR = GPIO_BSRR_BS13; // led off
        }
    }

    /* Will never reach this return */
    return 0;
}
