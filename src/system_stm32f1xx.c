#include "stm32f1xx.h"

#ifndef HSE_VALUE
#define HSE_VALUE 8000000U 
#endif

#ifndef HSI_VALUE
#define HSI_VALUE 8000000U
#endif

#define VECT_TAB_OFFSET  0x00000000U

// Clock Definition
uint32_t SystemCoreClock = 72000000U;

const uint8_t AHBPrescTable[16U] = {0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 6, 7, 8, 9};
const uint8_t APBPrescTable[8U] =  {0, 0, 0, 0, 1, 2, 3, 4};

void SystemInit (void)
{
  RCC->CR |= 0x00000001U;

  RCC->CFGR &= 0xF8FF0000U;
  
  RCC->CR &= 0xFEF6FFFFU;

  RCC->CR &= 0xFFFBFFFFU;

  RCC->CFGR &= 0xFF80FFFFU;

  RCC->CIR = 0x009F0000U;

  SCB->VTOR = FLASH_BASE | VECT_TAB_OFFSET; /* Vector Table Relocation in Internal FLASH. */
}

void SystemCoreClockUpdate (void)
{
  uint32_t tmp = 0U, pllmull = 0U, pllsource = 0U;

  tmp = RCC->CFGR & RCC_CFGR_SWS;
  
  switch (tmp)
  {
    case 0x00U:
      SystemCoreClock = HSI_VALUE;
      break;
    case 0x04U:
      SystemCoreClock = HSE_VALUE;
      break;
    case 0x08U:
      pllmull = RCC->CFGR & RCC_CFGR_PLLMULL;
      pllsource = RCC->CFGR & RCC_CFGR_PLLSRC;
      
      pllmull = ( pllmull >> 18U) + 2U;
      
      if (pllsource == 0x00U)
      {
        SystemCoreClock = (HSI_VALUE >> 1U) * pllmull;
      }
      else
      {
        if ((RCC->CFGR & RCC_CFGR_PLLXTPRE) != (uint32_t)RESET)
        {
          SystemCoreClock = (HSE_VALUE >> 1U) * pllmull;
        }
        else
        {
          SystemCoreClock = HSE_VALUE * pllmull;
        }
      }

      break;

    default:
      SystemCoreClock = HSI_VALUE;
      break;
  }

  tmp = AHBPrescTable[((RCC->CFGR & RCC_CFGR_HPRE) >> 4U)];
  SystemCoreClock >>= tmp;  
}
