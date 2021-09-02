#drawing and writing on images

import cv2 as cv
import numpy as np

#can draw on top of another image
#img=cv.imread('Photos/rei.jpg')
#cv.imshow('Rei', img)


#creating a blank image to work with
#shape (height, width, number of colour channels) and data type (uint8 is the data type of an image)
blank = np.zeros((500,500,3), dtype='uint8')
#cv.imshow('Blank image', blank)

#1. Paint image a certain colour

#blank[:] = 0,255,0              #green
#cv.imshow('Green', blank)

#Paint a range
#blank[200:300, 300:400] = 0,0,255
#cv.imshow('Red', blank)


#2. Draw a rectangle
#where to draw, colour, thickness
#thickness = 2 (border) thickness = -1 or cv.FILLED (fills)

#cv.rectangle(blank,(0,0), (250,500), (0,255,0), thickness=cv.FILLED )

#has dimensions that are half of the original image, (250,250)
cv.rectangle(blank,(0,0), (blank.shape[1]//2,blank.shape[0]//2), (0,255,0), thickness=cv.FILLED )
#cv.imshow('Rectangle', blank)


#3. Draw a circle
#centre of circle, radius, colour, thickness
cv.circle(blank, (blank.shape[1]//2,blank.shape[0]//2), 40, (0,0,255), thickness=-1)
#cv.imshow('Circle', blank)


#4. Draw a line
cv.line(blank, (0,0), (blank.shape[1]//2,blank.shape[0]//2), (255,255,255), thickness=3)
cv.line(blank, (100,250), (300,400), (255,255,255), thickness=3)
cv.imshow('Line', blank)


#5. Write text on an image
#text, centre, font, font scale, colour, thickness
cv.putText(blank, 'Hello', (225,225), cv.FONT_HERSHEY_TRIPLEX, 1.0, (255,255,0), 2)
cv.imshow('Text', blank)


cv.waitKey(0)