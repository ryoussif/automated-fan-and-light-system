# Automated Light & Fan Control System

## Overview

This project integrates user input and environmental sensing to automate LED lighting and fan speed using the Dragon-12 microcontroller. The system automatically turns on LEDs in low-light conditions and adjusts fan speed based on ambient temperature. A potentiometer allows manual control of the fan.

The goal is to reduce energy waste in environments where fans and lights are often left on unnecessarily, such as homes, offices, or classrooms.

---

## System Design and Architecture

The system automatically controls:

- **LED lighting** based on ambient brightness
- **Fan speed** based on temperature (via the U14 temperature sensor)
- **Manual override** via potentiometer

### Key Components:

- Dragon-12 Microcontroller Board
- Light Sensor
- U14 Temperature Sensor
- Potentiometer
- Relay (for motor control)
- LCD Display

---

## Materials and Methods

### Sensors & Inputs:
- **Light Sensor**: Activates LEDs in darkness
- **Temperature Sensor**: Activates fan as temperature rises
- **Potentiometer**: User input for fan speed control

### Outputs:
- **LEDs**: Indicate brightness response
- **Fan**: Cooled environment when needed
- **LCD Display**: Real-time feedback (e.g., "LED: ON", "FAN: 3.5V")

### Software:
- **CodeWarrior IDE**: Used for development/debugging
- Written in assembly for the HCS12

---

## Implementation

### Steps:
1. Circuit design on Dragon-12 board
2. Sensors and potentiometer integration
3. Development using CodeWarrior
4. Real-time data display on LCD
5. Control logic for LEDs and fan using sensor data

---

## Testing and Results

Tests conducted:
- **Light Sensor**: Finger placed to reduce brightness → LEDs triggered correctly
- **LCD Display**: Correct feedback (e.g., "LED: OFF", "FAN: ON")
- **Fan Output**: Potentiometer controlled voltage and fan speed

### Results:
- Reliable fan control based on temperature input
- Accurate LED response to ambient brightness
- Clear output messages displayed on LCD
- Smooth user input using the potentiometer
