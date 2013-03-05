################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/CDC.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/HID.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/HardwareSerial.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/IPAddress.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/Print.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/Stream.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/Tone.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/USBCore.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/WMath.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/WString.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/main.cpp \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/new.cpp 

C_SRCS += \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/WInterrupts.c \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/wiring.c \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/wiring_analog.c \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/wiring_digital.c \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/wiring_pulse.c \
/opt/arduino-1.0.3/hardware/arduino/cores/arduino/wiring_shift.c 

OBJS += \
./arduino/CDC.o \
./arduino/HID.o \
./arduino/HardwareSerial.o \
./arduino/IPAddress.o \
./arduino/Print.o \
./arduino/Stream.o \
./arduino/Tone.o \
./arduino/USBCore.o \
./arduino/WInterrupts.o \
./arduino/WMath.o \
./arduino/WString.o \
./arduino/main.o \
./arduino/new.o \
./arduino/wiring.o \
./arduino/wiring_analog.o \
./arduino/wiring_digital.o \
./arduino/wiring_pulse.o \
./arduino/wiring_shift.o 

C_DEPS += \
./arduino/WInterrupts.d \
./arduino/wiring.d \
./arduino/wiring_analog.d \
./arduino/wiring_digital.d \
./arduino/wiring_pulse.d \
./arduino/wiring_shift.d 

CPP_DEPS += \
./arduino/CDC.d \
./arduino/HID.d \
./arduino/HardwareSerial.d \
./arduino/IPAddress.d \
./arduino/Print.d \
./arduino/Stream.d \
./arduino/Tone.d \
./arduino/USBCore.d \
./arduino/WMath.d \
./arduino/WString.d \
./arduino/main.d \
./arduino/new.d 


# Each subdirectory must supply rules for building sources it contributes
arduino/CDC.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/CDC.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/HID.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/HID.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/HardwareSerial.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/HardwareSerial.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/IPAddress.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/IPAddress.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/Print.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/Print.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/Stream.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/Stream.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/Tone.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/Tone.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/USBCore.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/USBCore.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/WInterrupts.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/WInterrupts.c
	@echo 'Building file: $<'
	@echo 'Invoking: AVR Compiler'
	avr-gcc -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_VID= -DUSB_PID= -DARDUINO=103 -Wall -Os -fpack-struct -fshort-enums -std=gnu99 -funsigned-char -funsigned-bitfields -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/WMath.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/WMath.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/WString.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/WString.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/main.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/main.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/new.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/new.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: AVR C++ Compiler'
	avr-g++ -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_PID= -DUSB_VID= -DARDUINO=103 -Wall -Os -fno-exceptions -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/wiring.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/wiring.c
	@echo 'Building file: $<'
	@echo 'Invoking: AVR Compiler'
	avr-gcc -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_VID= -DUSB_PID= -DARDUINO=103 -Wall -Os -fpack-struct -fshort-enums -std=gnu99 -funsigned-char -funsigned-bitfields -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/wiring_analog.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/wiring_analog.c
	@echo 'Building file: $<'
	@echo 'Invoking: AVR Compiler'
	avr-gcc -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_VID= -DUSB_PID= -DARDUINO=103 -Wall -Os -fpack-struct -fshort-enums -std=gnu99 -funsigned-char -funsigned-bitfields -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/wiring_digital.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/wiring_digital.c
	@echo 'Building file: $<'
	@echo 'Invoking: AVR Compiler'
	avr-gcc -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_VID= -DUSB_PID= -DARDUINO=103 -Wall -Os -fpack-struct -fshort-enums -std=gnu99 -funsigned-char -funsigned-bitfields -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/wiring_pulse.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/wiring_pulse.c
	@echo 'Building file: $<'
	@echo 'Invoking: AVR Compiler'
	avr-gcc -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_VID= -DUSB_PID= -DARDUINO=103 -Wall -Os -fpack-struct -fshort-enums -std=gnu99 -funsigned-char -funsigned-bitfields -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

arduino/wiring_shift.o: /opt/arduino-1.0.3/hardware/arduino/cores/arduino/wiring_shift.c
	@echo 'Building file: $<'
	@echo 'Invoking: AVR Compiler'
	avr-gcc -I"/opt/arduino-1.0.3/hardware/arduino/cores/arduino" -I"/opt/arduino-1.0.3/hardware/arduino/variants/standard" -DUSB_VID= -DUSB_PID= -DARDUINO=103 -Wall -Os -fpack-struct -fshort-enums -std=gnu99 -funsigned-char -funsigned-bitfields -g  -ffunction-sections  -fdata-sections -mmcu=atmega328p -DF_CPU=8000000UL -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


