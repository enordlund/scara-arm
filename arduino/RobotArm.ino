//RobotArm.ino
//Author: Joseph Noreen, Erik Nordlund, Samuel Chamseddine
//This code parses in a bluetooth message corresponding to x and y coordinates, and will drive stepper motors to these positions
// Sets the encoder pins as Outputs
#include <SoftwareSerial.h>
#include <Servo.h>
#include <math.h>

#define shoulderStateA 9
#define shoulderStateB 3
#define elbowStateA 10
#define elbowStateB 11

float pi = 3.1415926535897932384626433832795;

// arm dimensions (units in inches)
float length1 = 6.08;
float length2 = 5.75;

// Paper and arm orientation (units in inches):
/*                    ^ y
 *                    |           
 *                    |           
 *           _________|__________
 *          |         |          |
 *          |         |          |
 *          |         |          |
 *          |         |          |
 *          |         |          |
 *  ___     |_________|__________|
 *   |                |
 *   |<-y offset .    |
 *  _|_               0-------------------> x
 *                    
 */

float paperXSize = 11;
float paperYSize = 8.5;

float paperXOffset = (paperXSize / 2);
float paperYOffset = 1.5;

enum orientation {
  landscape,
  portrait
} projectOrientation = portrait;

// 1's are elbow, non-1's are shoulder
// Erik's variables
int baudRate = 9600;
// // usbMode will be enabled if Serial.available() triggers
bool usbMode = false;
// Bluetooth
SoftwareSerial bluetoothSerial(7, 8); // RX, TX
int bluetoothStatePin = 12;
// memory
String lastString = "";


Servo penServo;

int currentZPosition = 0;

int targetZPosition = 0;

float shoulderAngleMax = 117;
float shoulderAngleMin = -45;

float elbowAngleMax = 108;
float elbowAngleMin = 0;

float currentShoulderAngle = -45;
float currentElbowAngle = 108;

double motorRatio = 12.1 / 37.65; // motorRadius / jointRadius
double encoderRatio = 1; //  encoderRadius / jointRadius

double encoderRatioDegrees = 9 * encoderRatio;
double shoulderDegreesPerStep = 1.8 * motorRatio;
double elbowDegreesPerStep = 1.8 * motorRatio;


// this is for 
int shoulderCompensationTracker = 0;
int shoulderCompensationStepCount = 0;
int shoulderCompensationRatio = 1 / motorRatio;


double deadzone = encoderRatioDegrees;

// defines pins numbers
const int shoulderStepPin = 5; 
const int shoulderDirectionPin = 6;
const int elbowStepPin = 4; 
const int elbowDirectionPin = 2; 
//Creating Variables 
int shoulderCounter = 0; 
int elbowCounter = 0; 
int shoulderEncoderState = 0;
int shoulderEncoderLastState = 0; 
int elbowEncoderState = 0;
int elbowEncoderLastState = 0;

//double targetXCoordinate = 0;
//double targetYCoordinate = 0;
double targetShoulderAngle = 0;
double targetElbowAngle = 0;

// P loop stuff
int shoulderDelay = 1500;
int elbowDelay = 1500;


void setup() {
  // Erik's setup
  pinMode(bluetoothStatePin, INPUT);
  // Serial setup
  Serial.begin(baudRate);
  bluetoothSerial.begin(baudRate);

  penServo.attach(13);

  pinMode(shoulderStepPin,OUTPUT); 
  pinMode(shoulderDirectionPin,OUTPUT);
  pinMode(elbowStepPin,OUTPUT);
  pinMode(elbowDirectionPin,OUTPUT);
  pinMode (shoulderStateA,INPUT);
  pinMode (shoulderStateB,INPUT);
  pinMode (elbowStateA,INPUT);
  pinMode (elbowStateB,INPUT);
  
  // Reads the initial state of the shoulderStateA
  shoulderEncoderLastState = digitalRead(shoulderStateA);
  shoulderEncoderLastState = digitalRead(elbowStateA);  
}
bool readShoulderEncoder() {
  bool output = false;
   shoulderEncoderState = digitalRead(shoulderStateA); // Reads the "current" state of the shoulderStateA
   // If the previous and the current state of the shoulderStateA are different, that means a Pulse has occured
   if (shoulderEncoderState != shoulderEncoderLastState){
     // If the shoulderStateB state is different to the shoulderStateA state, that means the encoder is rotating clockwise
     if (digitalRead(shoulderStateB) != shoulderEncoderState) {
       currentShoulderAngle -= encoderRatioDegrees;
       //shoulderCounter --;// --___________----- just swapped these
       Serial.print("CCW ");
     } else {
       currentShoulderAngle += encoderRatioDegrees;
       //shoulderCounter ++;
       Serial.print("CW ");
     }
     //currentShoulderAngle = (float)shoulderCounter * encoderRatioDegrees;
     Serial.print("Position of Shoulder Motor in degrees: ");
     Serial.println((currentShoulderAngle));
     output = true;
   } 
   shoulderEncoderLastState = shoulderEncoderState; // Updates the previous state of the shoulderStateA with the current state

   return output;
}

bool readElbowEncoder() {
  bool output = false;
   elbowEncoderState = digitalRead(elbowStateA); // Reads the "current" state of the elbowStateA
   // If the previous and the current state of the elbowStateA are different, that means a Pulse has occured
   if (elbowEncoderState != elbowEncoderLastState){     
     // If the elbowStateA state is different to the elbowStateB state, that means the encoder is rotating clockwise
     if (digitalRead(elbowStateB) != elbowEncoderState) { 
       currentElbowAngle += encoderRatioDegrees;
       //elbowCounter ++;
       Serial.print("     CCW ");
     } else {
       currentElbowAngle -= encoderRatioDegrees;
       ///elbowCounter --;
       Serial.print("     CW ");
     }
     //currentElbowAngle = (float)elbowCounter * encoderRatioDegrees;
     Serial.print("Position of Elbow Motor in degrees: ");
     Serial.println((currentElbowAngle));
     output = true;
   } 
   elbowEncoderLastState = elbowEncoderState; // Updates the previous state of the elbowStateA with the current state

   return output;
}

double boundedRadius(double radius) {
  double maximumRadius = length1 + length2;

  if (radius > maximumRadius) {
    Serial.println("ERROR: Radius exceeds maximum radius of arm.");
    return maximumRadius;
  } else {
    return radius;
  }
}

double boundedShoulderAngle(double angle) {
  if (angle > shoulderAngleMax) {
    return shoulderAngleMax;
  } else if (angle < shoulderAngleMin) {
    return shoulderAngleMin;
  }

  return angle;
}

double boundedElbowAngle(double angle) {
  if (angle > elbowAngleMax) {
    return elbowAngleMax;
  } else if (angle < elbowAngleMin) {
    return elbowAngleMin;
  }

  return angle;
}

void setTargetAnglesFromCoordinates(double x, double y, orientation pageLayout) {
  
  
  double adjustedX = x;
  double adjustedY = y;

  if (pageLayout == portrait) {
    adjustedX = paperXOffset - y;
    adjustedY = x + paperYOffset;
    //Serial.print("Portrait coordinates (converted): ");
    //Serial.print(adjustedX);
    //Serial.print(", ");
    //Serial.println(adjustedY);
  } else {// pageLayout is landscape
    adjustedX = x - paperXOffset;
    adjustedY = y + paperYOffset;
    //Serial.print("Landscape coordinates (converted): ");
    //Serial.print(adjustedX);
    //Serial.print(", ");
    //Serial.println(adjustedY);
    
  }
  
  //Serial.println("Setting target angles");
  //Serial.print("radius: ");
  double radius = sqrt(pow(adjustedX, 2) + pow(adjustedY, 2));
  //Serial.println(radius);

  //Serial.print("angle: ");
  double polarAngleDegrees = atan(adjustedY / adjustedX) * (180.0 / pi);
  

  if (adjustedX == 0) {
    polarAngleDegrees = 90.0;
  } else if (adjustedX < 0) {
    polarAngleDegrees = polarAngleDegrees + 180;
  }

  //Serial.print("polarAngleDegrees: ");
  //Serial.println(polarAngleDegrees);

  double numeratorA = pow(length1, 2) + pow(length2, 2) - pow(radius, 2);
  //Serial.print("numeratorA: ");
  //Serial.println(numeratorA);
  double denominatorA = 2.0 * length1 * length2;
  //Serial.print("denominatorA: ");
  //Serial.println(denominatorA);
  double angleA = acos(numeratorA / denominatorA) * 180 / pi;
  //Serial.print("angleA: ");
  //Serial.println(angleA);

  double numeratorC = pow(radius, 2) + pow(length1, 2) - pow(length2, 2);
  double denominatorC = 2 * radius * length1;

  //Serial.print("numeratorC: ");
  //Serial.println(numeratorC);
  //Serial.print("denominatorC: ");
  //Serial.println(denominatorC);
  
  double angleC = acos(numeratorC / denominatorC) * 180.0 / pi;

  //Serial.print("angleC: ");
  //Serial.println(angleC);
  double tempShoulderAngle = polarAngleDegrees - angleC;
  double tempElbowAngle = 180 - angleA;
  
  targetShoulderAngle = boundedShoulderAngle(tempShoulderAngle);
  targetElbowAngle = boundedElbowAngle(tempElbowAngle);
}


int boundedDelay(double fromAngleDifference) {
  int boundedDelay = 10000 - abs(fromAngleDifference) * 40;
  
  if (boundedDelay > 10000) {
    boundedDelay = 10000;
  } else if (boundedDelay < 1500) {
    boundedDelay = 1500;
  }
  
  return boundedDelay;
}

void stepShoulder(bool shoulderDirection, bool elbowDirection) {
  double shoulderAngleDifference = currentShoulderAngle - targetShoulderAngle;
  double shoulderAngleDifferenceMagnitude = abs(shoulderAngleDifference);

  shoulderDelay = boundedDelay(shoulderAngleDifference);
  
  if (shoulderAngleDifferenceMagnitude >= deadzone) {
    // step the shoulder once
    readShoulderEncoder();
    digitalWrite(shoulderStepPin, HIGH); 
    delayMicroseconds(shoulderDelay);
    digitalWrite(shoulderStepPin, LOW); 
    delayMicroseconds(shoulderDelay);
    

    
    if ((shoulderCompensationRatio - shoulderCompensationStepCount) < 1) {
      // moving the elbow motor to keep band steady
      //readElbowEncoder();
      digitalWrite(elbowDirectionPin, shoulderDirection);
      digitalWrite(elbowStepPin, HIGH); 
      delayMicroseconds(elbowDelay); 
      digitalWrite(elbowStepPin, LOW); 
      delayMicroseconds(elbowDelay);
      //readElbowEncoder();
      digitalWrite(elbowDirectionPin, elbowDirection);

      shoulderCompensationStepCount = 0;
    } else {
      shoulderCompensationStepCount += 1;
    }
    
    
  }
}

void stepElbow() {
  double elbowAngleDifference = currentElbowAngle - targetElbowAngle;
  //Serial.print("elbowAngleDifference: ");
  //Serial.println(elbowAngleDifference);
  double elbowAngleDifferenceMagnitude = abs(elbowAngleDifference);

  elbowDelay = boundedDelay(elbowAngleDifference);
  
  if (elbowAngleDifferenceMagnitude >= deadzone) {
    // step the shoulder once
    readElbowEncoder();
    digitalWrite(elbowStepPin, HIGH); 
    delayMicroseconds(elbowDelay);
    digitalWrite(elbowStepPin, LOW); 
    delayMicroseconds(elbowDelay);
  }
}

void setTargetAnglesFromPolar(double angle, double radius) {
  Serial.print("radius: ");
  Serial.println(radius);
  // calculating arm angles
  double numeratorA = pow(length1, 2) + pow(length2, 2) - pow(radius, 2);
  Serial.print("numeratorA: ");
  Serial.println(numeratorA);
  double denominatorA = 2.0 * length1 * length2;
  Serial.print("denominatorA: ");
  Serial.println(denominatorA);
  double angleA = acos(numeratorA / denominatorA) * 180 / pi;
  Serial.print("angleA: ");
  Serial.println(angleA);

  double numeratorC = pow(radius, 2) + pow(length1, 2) - pow(length2, 2);
  double denominatorC = 2 * radius * length1;

  Serial.print("numeratorC: ");
  Serial.println(numeratorC);
  Serial.print("denominatorC: ");
  Serial.println(denominatorC);
  
  double angleC = acos(numeratorC / denominatorC) * 180.0 / pi;

  Serial.print("angleC: ");
  Serial.println(angleC);
  double tempShoulderAngle = angle - angleC;
  double tempElbowAngle = 180 - angleA;
  
  targetShoulderAngle = boundedShoulderAngle(tempShoulderAngle);
  targetElbowAngle = boundedElbowAngle(tempElbowAngle);
}

void moveToTargetAngles() {
  Serial.print("Target Shoulder Degrees: ");
  Serial.println(targetShoulderAngle);
  Serial.print("Current Shoulder Angle: ");
  Serial.println(currentShoulderAngle);
  
  Serial.print("Target Elbow Degrees: ");
  Serial.println(targetElbowAngle);
  Serial.print("Current Elbow Angle: ");
  Serial.println(currentElbowAngle);

  // --------------------------------------------- stop if within accuracy of encoder
  // --------------------------------------------- calculate step ratio for the move for simultaneous motion
  
  double shoulderAngleDifference = currentShoulderAngle - targetShoulderAngle;
  double elbowAngleDifference = currentElbowAngle - targetElbowAngle;

  int shouldersPerElbow = 1;

  bool shoulderDirection = HIGH;
  bool elbowDirection = HIGH;

  int shoulderSteps = 0;
  int elbowSteps = 0;

  double shoulderAngleDifferenceMagnitude = abs(shoulderAngleDifference);
  double elbowAngleDifferenceMagnitude = abs(elbowAngleDifference);
  
  while ( (shoulderAngleDifferenceMagnitude >= deadzone) || (elbowAngleDifferenceMagnitude >= deadzone) ) {
    //Serial.println("out of deadzone");
    //Serial.print("deadzone: ");
    //Serial.println(deadzone);
    

    if (shoulderAngleDifference >= deadzone) {
      shoulderDirection = LOW;
    } else if (abs(shoulderAngleDifference) >= deadzone) {
      shoulderDirection = HIGH;
    }

    digitalWrite(shoulderDirectionPin, shoulderDirection);
  
    if (elbowAngleDifference >= deadzone) {
      elbowDirection = LOW;
    } else if (abs(elbowAngleDifference) >= deadzone) {
      elbowDirection = HIGH;
    }
    
    digitalWrite(elbowDirectionPin, elbowDirection);
    
    shoulderSteps = abs(shoulderAngleDifference / shoulderDegreesPerStep);
    elbowSteps = abs(elbowAngleDifference / elbowDegreesPerStep);

    //Serial.print("shoulderSteps: ");
    //Serial.println(shoulderSteps);

    //Serial.print("elbowSteps: ");
    //Serial.println(elbowSteps);
    
    if (elbowSteps <= 0) {
      shouldersPerElbow = shoulderSteps;
    } else {
      shouldersPerElbow = shoulderSteps / elbowSteps;
    }

    //Serial.print("later elbowSteps: ");
    //Serial.println(elbowSteps);
    
    shoulderDelay = boundedDelay(shoulderAngleDifference);
    elbowDelay = boundedDelay(elbowAngleDifference);
    
    //readShoulderEncoder();

    //Serial.print("shouldersPerElbow: ");
    //Serial.println(shouldersPerElbow);
    
    //Serial.println("starting for loop");

    if (shoulderSteps < elbowSteps) {
      //Serial.println("shoulderSteps < elbowSteps");
      
      double elbowsPerShoulder = (double)elbowSteps / (double)shoulderSteps;

      //Serial.print("elbowsPerShoulder: ");
      //Serial.println(elbowsPerShoulder);

      /*
      if (shoulderSteps <= 0) {
        elbowsPerShoulder = elbowSteps;
      } else {
        
        stepshoulder(shoulderDirection, elbowDirection);

        if (readElbowEncoder()) {
          continue;
        }
        
        
      }
      
      for (int elbows = 0; elbows < elbowsPerShoulder; elbows = elbows + 1) {
        stepElbow();
      }
      */
      
      
      if (shoulderSteps > 0) {
        for (int shoulders = 0; shoulders < shoulderSteps; shoulders = shoulders + 1) {
          stepShoulder(shoulderDirection, elbowDirection);
    
          if (readElbowEncoder()) {
            shoulderAngleDifference = currentShoulderAngle - targetShoulderAngle;
            elbowAngleDifference = currentElbowAngle - targetElbowAngle;

            shoulderDelay = boundedDelay(shoulderAngleDifference);
            elbowDelay = boundedDelay(elbowAngleDifference);
        
            shoulderAngleDifferenceMagnitude = abs(shoulderAngleDifference);
            elbowAngleDifferenceMagnitude = abs(elbowAngleDifference);

            // get back to while loop
            shoulders = shoulderSteps + 1;
            break;
          }

          int stepsForElbow = floor(elbowsPerShoulder);
          
          for (int elbows = 0; elbows < stepsForElbow; elbows = elbows + 1) {
            stepElbow();

            if (stepsForElbow < elbowsPerShoulder) {
              stepsForElbow = ceil(elbowsPerShoulder);
            } else {
              stepsForElbow = floor(elbowsPerShoulder);
            }
          }
        }
      } else {
        elbowsPerShoulder = elbowSteps;
        for (int elbows = 0; elbows < elbowsPerShoulder; elbows = elbows + 1) {
          stepElbow();
        }
      }
      
      
      //Serial.println("end of if");
      
      
    } else if (elbowSteps < shoulderSteps) {
      //Serial.println("elbowSteps < shoulderSteps");
      
      double shouldersPerElbow = (double)shoulderSteps / (double)elbowSteps;

      //Serial.print("shouldersPerElbow: ");
      //Serial.println(shouldersPerElbow);
      /*
      if (elbowSteps <= 0) {
        shouldersPerElbow = shoulderSteps;
      } else {
        //stepElbow();
      }
      
      for (int shoulders = 0; shoulders < shouldersPerElbow; shoulders = shoulders + 1) {
        stepshoulder(shoulderDirection, elbowDirection);
        
        if (readElbowEncoder()) {
          continue;
        }
      }
      */

      if (elbowSteps > 0) {
        for (int elbows = 0; elbows < elbowSteps; elbows = elbows + 1) {
          if (elbowSteps <= 0) {
            shouldersPerElbow = shoulderSteps;
          } else {
            stepElbow();
          }

          int stepsForShoulder = floor(shouldersPerElbow);
  
          for (int shoulders = 0; shoulders < stepsForShoulder; shoulders = shoulders + 1) {
            stepShoulder(shoulderDirection, elbowDirection);
            if (readElbowEncoder()) {
              //Serial.println("BREAK");
              
              shoulderAngleDifference = currentShoulderAngle - targetShoulderAngle;
              elbowAngleDifference = currentElbowAngle - targetElbowAngle;

              shoulderDelay = boundedDelay(shoulderAngleDifference);
              elbowDelay = boundedDelay(elbowAngleDifference);
          
              shoulderAngleDifferenceMagnitude = abs(shoulderAngleDifference);
              elbowAngleDifferenceMagnitude = abs(elbowAngleDifference);

              elbows = elbowSteps + 1;
              break;
            }

            if (stepsForShoulder < shouldersPerElbow) {
              stepsForShoulder = ceil(shouldersPerElbow);
            } else {
              stepsForShoulder = floor(shouldersPerElbow);
            }
          }
        }
      } else {
        shouldersPerElbow = shoulderSteps;
        //Serial.print("shouldersPerElbow: ");
        //Serial.println(shouldersPerElbow);
        for (int shoulders = 0; shoulders < shouldersPerElbow; shoulders = shoulders + 1) {
          stepShoulder(shoulderDirection, elbowDirection);
          if (readElbowEncoder()) {
            //Serial.println("BREAK");
            
            shoulderAngleDifference = currentShoulderAngle - targetShoulderAngle;
            elbowAngleDifference = currentElbowAngle - targetElbowAngle;

            shoulderDelay = boundedDelay(shoulderAngleDifference);
            elbowDelay = boundedDelay(elbowAngleDifference);
        
            shoulderAngleDifferenceMagnitude = abs(shoulderAngleDifference);
            elbowAngleDifferenceMagnitude = abs(elbowAngleDifference);

            
            break;
          }
        }
      }
      
      //Serial.println("end of if");
      
    } else {
      /*
      if (shoulderSteps > 0) {
        stepshoulder(shoulderDirection, elbowDirection);
        
        if (readElbowEncoder()) {
          continue;
        }
        
        stepElbow();
      }
      */
      //Serial.println("ELSE");
      for (int steps = 0; steps < shoulderSteps; steps = steps + 1) {
        stepShoulder(shoulderDirection, elbowDirection);

        if (readElbowEncoder()) {
          //Serial.println("BREAK");
          
          shoulderAngleDifference = currentShoulderAngle - targetShoulderAngle;
          elbowAngleDifference = currentElbowAngle - targetElbowAngle;

          shoulderDelay = boundedDelay(shoulderAngleDifference);
          elbowDelay = boundedDelay(elbowAngleDifference);
      
          shoulderAngleDifferenceMagnitude = abs(shoulderAngleDifference);
          elbowAngleDifferenceMagnitude = abs(elbowAngleDifference);
          
          break;
        }
        
        stepElbow();
      }

      //Serial.println("end of if");
      
    }

    shoulderAngleDifference = currentShoulderAngle - targetShoulderAngle;
    elbowAngleDifference = currentElbowAngle - targetElbowAngle;

    shoulderDelay = boundedDelay(shoulderAngleDifference);
    elbowDelay = boundedDelay(elbowAngleDifference);

    shoulderAngleDifferenceMagnitude = abs(shoulderAngleDifference);
    elbowAngleDifferenceMagnitude = abs(elbowAngleDifference);
  }
}

void moveToPolar(double angle, double radius) {
  setTargetAnglesFromPolar(angle, radius);
  moveToTargetAngles();
}

void moveToNewXY(double newX, double newY) {
  //currentShoulderAngle = (float)shoulderCounter * encoderRatioDegrees;
  //currentElbowAngle = (float)elbowCounter * encoderRatioDegrees;
  //readShoulderEncoder();
  //readElbowEncoder();
  //setTargetAnglesFromCoordinates(newX, newY, projectOrientation);

  double adjustedNewX = newX;
  double adjustedNewY = newY;

  if (projectOrientation == portrait) {
    adjustedNewX = paperXOffset - newY;
    adjustedNewY = newX + paperYOffset;
    //Serial.print("Portrait coordinates (converted): ");
    //Serial.print(adjustedX);
    //Serial.print(", ");
    //Serial.println(adjustedY);
  } else {// pageLayout is landscape
    adjustedNewX = newX - paperXOffset;
    adjustedNewY = newY + paperYOffset;
    //Serial.print("Landscape coordinates (converted): ");
    //Serial.print(adjustedX);
    //Serial.print(", ");
    //Serial.println(adjustedY);
    
  }

  
  
  // calculating cartesean position
  double radius = sqrt(pow(length1, 2) + pow(length2, 2) - 2 * length1 * length2 * cos((180.0 - currentElbowAngle) * pi / 180.0));
  float numeratorC = pow((float)radius, 2) + pow(length1, 2) - pow(length2, 2);
  float denominatorC = 2 * (float)radius * length1;
  double fractionC = numeratorC / denominatorC;
  double fractionCMagnitude = abs(fractionC);
  if (fractionCMagnitude > 1) {
    //Serial.println("ERROR: fraction greater than 1");
  }
  double angleC = acos(fractionC);
  float polarAngleRadians = currentShoulderAngle * pi / 180.0 + angleC;
  
  double currentXPosition = radius * cos(polarAngleRadians);
  double currentYPosition = radius * sin(polarAngleRadians);

  
  double slopeRise = adjustedNewX - currentXPosition;
  double slopeRun = adjustedNewY - currentYPosition;

  double slope = slopeRise / slopeRun;

  double intercept = currentYPosition - (slope * currentXPosition);

  double targetPolarAngle = atan(adjustedNewY / adjustedNewX) * (180.0 / pi);
  double targetPolarRadius = sqrt(pow(adjustedNewX, 2) + pow(adjustedNewY, 2));
  
  double currentPolarAngle = atan(currentYPosition / currentXPosition) * (180.0 / pi);
  double currentPolarRadius = sqrt(pow(currentXPosition, 2) + pow(currentYPosition, 2));

  double polarAngleDifference = targetPolarAngle - currentPolarAngle;
  double polarAngleDifferenceMagnitude = abs(polarAngleDifference);

  double polarDeadzone = deadzone;

  if ((polarAngleDifference / polarAngleDifferenceMagnitude) > 0) {
    for (int i = 0; i < polarAngleDifference; i++) {
      
    }
  } else if ((polarAngleDifference / polarAngleDifferenceMagnitude) > 0) {
    
  }
  
  for (int i = 0; i < polarAngleDifference; i++) {
    Serial.println("Polar angle out of deadzone");
    double nextPolarAngle = currentPolarAngle + 1;// * polarAngleDifference / abs(polarAngleDifference);
    double nextPolarRadius = intercept / (sin(nextPolarAngle) - slope * cos(nextPolarAngle));
    moveToPolar(nextPolarAngle, nextPolarRadius);
    
    radius = sqrt(pow(length1, 2) + pow(length2, 2) - 2 * length1 * length2 * cos((180.0 - currentElbowAngle) * pi / 180.0));
    
    numeratorC = pow((float)radius, 2) + pow(length1, 2) - pow(length2, 2);
    denominatorC = 2 * (float)radius * length1;
    fractionC = numeratorC / denominatorC;
    fractionCMagnitude = abs(fractionC);
    if (fractionCMagnitude > 1) {
      //Serial.println("ERROR: fraction greater than 1");
    }
    angleC = acos(fractionC);
    polarAngleRadians = currentShoulderAngle * pi / 180.0 + angleC;
    
    currentXPosition = radius * cos(polarAngleRadians);
    currentYPosition = radius * sin(polarAngleRadians);
    
    currentPolarAngle = atan(currentYPosition / currentXPosition) * (180.0 / pi);
    polarAngleDifference = targetPolarAngle - currentPolarAngle;
    polarAngleDifferenceMagnitude = abs(polarAngleDifference);
  }

  

  Serial.println("MOVE COMPLETED");
}

void moveToNewZ(int newZ) {
  if (newZ == 1) {
    // move pen up
    penServo.write(90);
  } else if (newZ == 0) {
    // move pen down
    penServo.write(0);
  }

  currentZPosition = newZ;
  
  return;
}

// Erik's functions
// Bluetooth serial management
double boundXValue(double value) {
  if (projectOrientation == portrait) {
    if (value > 8.5) {
      return 8.5;
    } else if (value < 0) {
      return 0;
    } else {
      return value;
    }
  } else {// pageLayout is landscape
    if (value > 11) {
      return 11;
    } else if (value < 0) {
      return 0;
    } else {
      return value;
    }
  }
  
}

double boundYValue(double value) {
  if (projectOrientation == portrait) {
    if (value > 11) {
      return 11;
    } else if (value < 0) {
      return 0;
    } else {
      return value;
    }
  } else {// pageLayout is landscape
    if (value > 8.5) {
      return 8.5;
    } else if (value < 0) {
      return 0;
    } else {
      return value;
    }
  }
}

void sendStatus() {
  // calculating cartesean position
  double radius = sqrt(pow(length1, 2) + pow(length2, 2) - 2 * length1 * length2 * cos((180.0 - currentElbowAngle) * pi / 180.0));
  float numeratorC = pow((float)radius, 2) + pow(length1, 2) - pow(length2, 2);
  float denominatorC = 2 * (float)radius * length1;
  double fractionC = numeratorC / denominatorC;
  double fractionCMagnitude = abs(fractionC);
  if (fractionCMagnitude > 1) {
    //Serial.println("ERROR: fraction greater than 1");
  }
  double angleC = acos(fractionC);
  float polarAngleRadians = currentShoulderAngle * pi / 180.0 + angleC;
  
  double currentXPosition = radius * cos(polarAngleRadians);
  double currentYPosition = radius * sin(polarAngleRadians);

  //Serial.print("Status coordinates (pre-conversion): ");
  //Serial.print(currentXPosition);
  //Serial.print(", ");
  //Serial.println(currentYPosition);

  if (projectOrientation == portrait) {
    double tempXPosition = currentXPosition;
    
    currentXPosition = currentYPosition - paperYOffset;
    currentYPosition = paperXOffset - tempXPosition;
    //Serial.print("Portrait coordinates (converted): ");
    //Serial.print(currentXPosition);
    //Serial.print(", ");
    //Serial.println(currentYPosition);
  } else {// pageLayout is landscape
    currentXPosition = currentXPosition + paperXOffset;
    currentYPosition = currentYPosition - paperYOffset;
    //Serial.print("Landscape coordinates (converted): ");
    //Serial.print(currentXPosition);
    //Serial.print(", ");
    //Serial.println(currentYPosition);
    
  }
  /*
  Serial.print("shoulderAngle: ");
  Serial.println(currentShoulderAngle);
  
  Serial.print("elbowAngle: ");
  Serial.println(currentElbowAngle);

  Serial.print("radius: ");
  Serial.println(radius);

  Serial.print("numeratorC: ");
  Serial.println(numeratorC);

  Serial.print("denominatorC: ");
  Serial.println(denominatorC);
  
  Serial.print("fractionC: ");
  Serial.println(fractionC);
  
  Serial.print("angleC: ");
  Serial.println(angleC);

  Serial.print("polarAngleRadians: ");
  Serial.println(polarAngleRadians);
  */
  //Serial.print("currentX: ");
  //Serial.println(currentXPosition);

  //Serial.print("currentY: ");
  //Serial.println(currentYPosition);
  
  double boundedXValue = boundXValue(currentXPosition);
  double boundedYValue = boundYValue(currentYPosition);
  
  int roundedCurrentXValue = round(boundedXValue * 1000);
  int roundedCurrentYValue = round(boundedYValue * 1000);
  
  String currentXValueString = String(roundedCurrentXValue);
  String currentYValueString = String(roundedCurrentYValue);
  String currentZValueString = String(currentZPosition);

  if (roundedCurrentXValue < 10) {
    currentXValueString = "0000" + currentXValueString;
  } else if (roundedCurrentXValue < 100) {
    currentXValueString = "000" + currentXValueString;
  } else if (roundedCurrentXValue < 1000) {
    currentXValueString = "00" + currentXValueString;
  } else if (roundedCurrentXValue < 10000) {
    currentXValueString = "0" + currentXValueString;
  }

  if (roundedCurrentYValue < 10) {
    currentYValueString = "0000" + currentYValueString;
  } else if (roundedCurrentYValue < 100) {
    currentYValueString = "000" + currentYValueString;
  } else if (roundedCurrentYValue < 1000) {
    currentYValueString = "00" + currentYValueString;
  } else if (roundedCurrentYValue < 10000) {
    currentYValueString = "0" + currentYValueString;
  }
  
  if (currentZPosition == 1) {
    currentZValueString = currentZValueString;
  } else if (currentZPosition == 0) {
    currentZValueString = currentZValueString;
  }

  
  
  String statusString = "s:x" + currentXValueString + "y" + currentYValueString + "z" + currentZValueString + ".";
  printToSerial(statusString);
}

void requestRepeat() {
  // ********************************************* THIS WILL NEED TO BE VERIFIED
  // Writes repeat request to serial stream.
  printToSerial("?");
}

size_t printToSerial(String string) {
  if (string != "?") {
    lastString = string;
  }
  if (usbMode == false) {
    return bluetoothSerial.print(string);
  } else {
    return Serial.print(string);
  }
}

String readFromSerial() {
  if (usbMode == false) {
    return bluetoothSerial.readString();
  } else {
    return Serial.readString();
  }
}

void managePairingMode() {
  // If phone unpairs from HM-10, this will read the state pin of the HM-10 and enter into an unpaired mode.
  if (digitalRead(bluetoothStatePin) == LOW) {
    
    // If usb is disconnected, show disconnected status light
    if (usbMode == false) {
      
      while (!Serial.available() && !bluetoothSerial.available()) {
        
        //disconnectedStatusLight();
      
      }
      
      if (Serial.available()) {
        
        usbMode = true;
        
      } else if (bluetoothSerial.available()) {
        
        usbMode = false;
        
      }
    }
  }
}

void handleInbox(String inbox) {
  if (inbox.startsWith("xy:") && inbox.endsWith("!") && (inbox.length() == 16)) {
      // begins at first index, ends before last index.
      
      double newXValue = inbox.substring(4, 9).toDouble() / 1000;
      double newYValue = inbox.substring(10, 15).toDouble() / 1000;

      /*
      int incrementDenominator = 1;//sqrt(pow(newXValue, 2) + pow(newYValue, 2));
      double xIncrement = newXValue / (double)incrementDenominator;
      double yIncrement = newYValue / (double)incrementDenominator;

      newXValue = xIncrement;
      newYValue = yIncrement;

      for (int i = 0; i < incrementDenominator; i++) {
        moveToNewXY(newXValue, newYValue);
        newXValue += xIncrement;
        newYValue += yIncrement;
      }
      */
      moveToNewXY(newXValue, newYValue);

      sendStatus();
      
    } else if (inbox.startsWith("z:z") && inbox.endsWith("!") && (inbox.length() == 5)) {

      targetZPosition = inbox.substring(3, 4).toInt();

      moveToNewZ(targetZPosition);
      
      sendStatus();
      
    } else if (inbox == "s?") {
      
      sendStatus();
      
    } else if (inbox == "c?") {
      
      //connectedStatusLight();
      
      printToSerial("c.");
      
    } else if (inbox == "d!") {
      
      usbMode = false;
      
    } else if (inbox == "?") {
      
      printToSerial(lastString);
      
    } else {
      if (inbox.length() > 0) {
        requestRepeat();
      }
    }
}

bool serialAvailable() {
  if (usbMode == true) {
    if (Serial.available()) {
      bluetoothSerial.read();
      return true;
    }
  } else {
    if (bluetoothSerial.available()) {
      Serial.read();
      return true;
    }
  }
  return false;
}


void loop() {
  managePairingMode();
  
  // Order of operations for Bluetooth communications:
  // 0) Phone says "Hello?" (sent as "c?")
  // 1) Arduino says "I'm listening," and leaves a low power mode (sent as "c.").
  // 2) Phone sends new position.
  // 3) Arduino says "I'm done" when new color is completed.
  
  // // This way of communication is meant for both sides to have explicit expectations
  // based on what they send. If expectations are not met, the expecting device
  // requests a repeat of the last thing the sender sent.
  // // What does it mean for expectations to not be met?
  // // // 1) Expector recieves nothing for a period of time longer than a response should take.
  // // // 2) Expector recieves something that is not an expected response.
  // // // // // For everything sent, the next response will be analyzed by a switch to determine
  // // // // the next step. The default case will be a repeat request.
  
  // Reads XY Command
  // // Structure: "xy:x00000y00000!" with x and y divided by 1000
  while (serialAvailable()) {
    
    String inbox = readFromSerial();
    
    handleInbox(inbox);
    
  }
}
