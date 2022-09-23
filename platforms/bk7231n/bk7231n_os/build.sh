#!/bin/sh
APP_BIN_NAME=$1
APP_VERSION=$2
TARGET_PLATFORM=$3
USER_CMD=$4

echo APP_BIN_NAME=$APP_BIN_NAME
echo APP_VERSION=$APP_VERSION
echo TARGET_PLATFORM=$TARGET_PLATFORM
echo USER_CMD=$USER_CMD

USER_SW_VER=`echo $APP_VERSION | cut -d'-' -f1`

APP_DIR_temp=$(echo $APP_PROJ_PATH)
if [ "x$APP_DIR_temp" != "x" ];then
    last_character=$(echo -n $APP_PROJ_PATH | tail -c 1)
    if [ "x$last_character" = 'x/' ];then
        APP_DIR_temp=${APP_PROJ_PATH%?}
    else
        APP_DIR_temp=$APP_PROJ_PATH
    fi
    APP_DIR=${APP_DIR_temp%/*}
else
APP_DIR=apps
fi

echo "Start Compile"
set -e

SYSTEM=`uname -s`
echo "system:"$SYSTEM
if [ $SYSTEM = "Linux" ]; then
	TOOL_DIR=package_tool/linux
	OTAFIX=${TOOL_DIR}/otafix
	ENCRYPT=${TOOL_DIR}/encrypt
	BEKEN_PACK=${TOOL_DIR}/beken_packager
	RT_OTA_PACK_TOOL=${TOOL_DIR}/rt_ota_packaging_tool_cli
	TY_PACKAGE=${TOOL_DIR}/package
else
	TOOL_DIR=package_tool/windows
	OTAFIX=${TOOL_DIR}/otafix.exe
	ENCRYPT=${TOOL_DIR}/encrypt.exe
	BEKEN_PACK=${TOOL_DIR}/beken_packager.exe
	RT_OTA_PACK_TOOL=${TOOL_DIR}/rt_ota_packaging_tool_cli.exe
	TY_PACKAGE=${TOOL_DIR}/package.exe
fi

APP_PATH=../../../$APP_DIR
# Applicant's obj directory
APP_OBJ_PATH=Debug/$APP_DIR

echo "Removing TUYA APP Common and Components Objs"
# Remove TUYA APP OBJs first
if [ -e "${APP_OBJ_PATH}/$APP_BIN_NAME/src" ]; then
for i in `find ${APP_OBJ_PATH}/$APP_BIN_NAME/src -type d`; do
    echo "Deleting $i"
    rm -rf $i/*.o
done
fi

# Remove TUYA Common OBJs first
# if [ -e "Debug/tuya_common/" ]; then
# for i in `find Debug/tuya_common/ -type f`; do
#     echo "Deleting $i"
#     rm -rf $i
# done
# fi

# Remove TUYA Components OBJs first
# if [ -e "Debug/components" ]; then
# for i in `find Debug/components -type d`; do
#     echo "Deleting $i"
#     rm -rf $i/*.o
# done
# fi

if [ -z $CI_PACKAGE_PATH ]; then
    echo "not is ci build"
else
	make APP_BIN_NAME=$APP_BIN_NAME USER_SW_VER=$USER_SW_VER APP_VERSION=$APP_VERSION clean -C ./
fi

make APP_BIN_NAME=$APP_BIN_NAME USER_SW_VER=$USER_SW_VER APP_VERSION=$APP_VERSION $USER_CMD APP_DIR=$APP_DIR -j -C ./

echo "Start Combined"
cp ${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_${APP_VERSION}.bin tools/generate/

cd tools/generate/
./${ENCRYPT} ${APP_BIN_NAME}_${APP_VERSION}.bin 510fb093 a3cbeadc 5993a17e c7adeb03 10000
python mpytools.py bk7231n_bootloader_enc.bin ${APP_BIN_NAME}_${APP_VERSION}_enc.bin

./${BEKEN_PACK} config.json

echo "End Combined"
cp all_1.00.bin ${APP_BIN_NAME}_QIO_${APP_VERSION}.bin
rm all_1.00.bin

cp ${APP_BIN_NAME}_${APP_VERSION}_enc_uart_1.00.bin ${APP_BIN_NAME}_UA_${APP_VERSION}.bin
rm ${APP_BIN_NAME}_${APP_VERSION}_enc_uart_1.00.bin

#generate ota file
echo "generate ota file"
./${RT_OTA_PACK_TOOL} -f ${APP_BIN_NAME}_${APP_VERSION}.bin -v $CURRENT_TIME -o ${APP_BIN_NAME}_${APP_VERSION}.rbl -p app -c gzip -s aes -k 0123456789ABCDEF0123456789ABCDEF -i 0123456789ABCDEF
./${TY_PACKAGE} ${APP_BIN_NAME}_${APP_VERSION}.rbl ${APP_BIN_NAME}_UG_${APP_VERSION}.bin $APP_VERSION 
#rm ${APP_BIN_NAME}_${APP_VERSION}.rbl
rm ${APP_BIN_NAME}_${APP_VERSION}.bin
rm ${APP_BIN_NAME}_${APP_VERSION}.cpr
rm ${APP_BIN_NAME}_${APP_VERSION}.out
rm ${APP_BIN_NAME}_${APP_VERSION}_enc.bin

echo "ug_file size:"
ls -l ${APP_BIN_NAME}_UG_${APP_VERSION}.bin | awk '{print $5}'
if [ `ls -l ${APP_BIN_NAME}_UG_${APP_VERSION}.bin | awk '{print $5}'` -gt 679936 ];then
	echo "**********************${APP_BIN_NAME}_$APP_VERSION.bin***************"
	echo "************************** too large ********************************"
	rm ${APP_BIN_NAME}_UG_${APP_VERSION}.bin
	rm ${APP_BIN_NAME}_UA_${APP_VERSION}.bin
	rm ${APP_BIN_NAME}_QIO_${APP_VERSION}.bin
	exit 1
fi

echo "$(pwd)"
cp ${APP_BIN_NAME}_${APP_VERSION}.rbl ../../${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_${APP_VERSION}.rbl
cp ${APP_BIN_NAME}_UG_${APP_VERSION}.bin ../../${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_UG_${APP_VERSION}.bin
cp ${APP_BIN_NAME}_UA_${APP_VERSION}.bin ../../${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_UA_${APP_VERSION}.bin
cp ${APP_BIN_NAME}_QIO_${APP_VERSION}.bin ../../${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_QIO_${APP_VERSION}.bin

echo "*************************************************************************"
echo "*************************************************************************"
echo "*************************************************************************"
echo "*********************${APP_BIN_NAME}_$APP_VERSION.bin********************"
echo "*************************************************************************"
echo "**********************COMPILE SUCCESS************************************"
echo "*************************************************************************"

FW_NAME=$APP_NAME
if [ -n $CI_IDENTIFIER ]; then
        FW_NAME=$CI_IDENTIFIER
fi

if [ -z $CI_PACKAGE_PATH ]; then
    echo "not is ci build"
	exit
else
	mkdir -p ${CI_PACKAGE_PATH}

   cp ../../${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_UG_${APP_VERSION}.bin ${CI_PACKAGE_PATH}/$FW_NAME"_UG_"$APP_VERSION.bin
   cp ../../${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_UA_${APP_VERSION}.bin ${CI_PACKAGE_PATH}/$FW_NAME"_UA_"$APP_VERSION.bin
   cp ../../${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_QIO_${APP_VERSION}.bin ${CI_PACKAGE_PATH}/$FW_NAME"_QIO_"$APP_VERSION.bin
   cp ../../${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_${APP_VERSION}.asm ${CI_PACKAGE_PATH}/$FW_NAME"_"$APP_VERSION.asm
   cp ../../${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_${APP_VERSION}.axf ${CI_PACKAGE_PATH}/$FW_NAME"_"$APP_VERSION.axf
   cp ../../${APP_PATH}/$APP_BIN_NAME/output/$APP_VERSION/${APP_BIN_NAME}_${APP_VERSION}.map ${CI_PACKAGE_PATH}/$FW_NAME"_"$APP_VERSION.map
fi
