/**
* @file light_system.h
* @author www.tuya.com
* @brief system adapter process
* @version 0.2
* @date 2022-03-25
*
* @copyright Copyright (c) tuya.inc 2022
*
*/

#ifndef __LIHGT_SYSTEM_H__
#define __LIHGT_SYSTEM_H__


#include "light_types.h"
#include "tuya_device.h"

#ifdef __cplusplus
extern "C" {
#endif  /* __cplusplus */


#define DPID_SWITCH          20     // switch_led
#define DPID_MODE            21     // work_mode
#define DPID_BRIGHT          22     // bright_value
#define DPID_TEMPR           23     // temp_value
#define DPID_COLOR           24     // colour_data
#define DPID_SCENE           25     // scene_data
#define DPID_COUNTDOWN       26     // countdown
#define DPID_MUSIC           27     // music_data
#define DPID_CONTROL         28

//#define _IS_OEM

#define DEFAULT_CONFIG "{Jsonver:1.1.0,module:CBU,cmod:rgbcw,dmod:0,cwtype:0,onoffmode:0,pmemory:1,title20:0,defcolor:c,defbright:100,deftemp:100,cwmaxp:100,brightmin:10,brightmax:100,colormin:10,colormax:100,wfcfg:spcl,rstmode:0,rstnum:3,rstcor:c,rstbr:50,rsttemp:100,pwmhz:1000,r_pin:8,r_lv:1,g_pin:6,g_lv:1,b_pin:24,b_lv:1,c_pin:26,c_lv:1,w_pin:7,w_lv:1,}"

/**
 * @brief: 灯软件系统初始化
 * @param: none
 * @retval: OPERATE_LIGHT 0表示成功，非0请参照tuya error code描述文档 
 */
OPERATE_LIGHT tuya_light_sys_software_init(VOID);

/**
 * @brief: 灯fast boot 程序 被 early init event 调用
 * @param: none
 * @retval: none
 */
VOID tuya_light_fast_boot(VOID);

/**
 * @brief: wifi fast 初始化程序
 * @param：none 
 * @attention: 此部分无法操作kv flash等wifi系统服务
 * @attention: 被 pre_device_init() 调用
 * @retval: none
 */
VOID tuya_light_sys_pre_device_init(VOID);



/**
 * @brief: 应用常规初始化
 * @param: none
 * @attention: 被tuya_app_init()调用
 * @retval: none
 */
VOID tuya_light_sys_app_init(VOID);

/**
 * @brief: 设备初始化
 * @param: none
 * @attention: 被device_init()调用
 * @retval: none
 */
OPERATE_LIGHT tuya_light_sys_device_init(VOID);

/**
 * @brief: 授权时擦出用户数据
 * @param: none
 * @attention: none
 * @retval: none
 */
VOID tuya_light_sys_erase_flash_data(VOID);

/**
 * @brief: 转到mf测试时停止并清除计时器
 * @param: none
 * @attention: none
 * @retval: OPERATE_LIGHT 0表示成功，非0请参照tuya error code描述文档 
 */
OPERATE_LIGHT tuya_light_sys_mf_user_enter_callback(VOID);


#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif  /* __LIHGT_SYSTEM_H__ */

