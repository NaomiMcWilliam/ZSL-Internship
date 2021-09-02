#add and subtract by adding/subtracting the pixels at corresponding positions

import cv2 as cv
import numpy as np

img_1 = cv.imread('Photos/background.JPG')
img_2 = cv.imread('Photos/camels.JPG')

img_3 = img_2 - img_1
cv.imshow("Image", img_3)
blur2 = cv.GaussianBlur(img_1, (5,5), cv.BORDER_DEFAULT)
canny_blur2 = cv.Canny(blur2, 125, 175)

#very bad
#resized_blur2 = cv.resize(canny_blur2, (1100,600), interpolation = cv.INTER_CUBIC)
#cv.imshow('blur', resized_blur2)

canny_1 = cv.Canny(img_1, 125, 175)
canny_2 = cv.Canny(img_2, 125, 175)

#bad
canny_3 = canny_2 - canny_1
resized_canny_3 = cv.resize(canny_3, (1100,600), interpolation = cv.INTER_CUBIC)
#cv.imshow('Canny2', canny_2)
cv.imshow('Canny edges', resized_canny_3)
###contours

#LOOKS BEST !
grey1 = cv.cvtColor(img_1, cv.COLOR_BGR2GRAY)
grey2 = cv.cvtColor(img_2,cv.COLOR_BGR2GRAY )

ret1, thresh1 = cv.threshold(grey1, 125,255, cv.THRESH_BINARY)
ret2, thresh2 = cv.threshold(grey2, 125,255, cv.THRESH_BINARY)
thresh3 = thresh2 - thresh1

#cv.imshow('Thresh1', thresh1)
#cv.imshow('Thresh2', thresh2)
resized_canny_3 = cv.resize(thresh3, (1100,600), interpolation = cv.INTER_CUBIC)
cv.imshow('Thresh3', resized_canny_3)


contours_t , hierarchies_t = cv.findContours(thresh1, cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE)

#drawing in contours

blank = np.zeros(img_2.shape, dtype='uint8')   #same size as original image

#image to draw over, contours (a list), contour index (how many contours to have in image, -1 is all), colour, thickness
contours, hierarchies = cv.findContours(canny_2, cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE)
cv.drawContours(blank, contours, -1, (0,0,255), 1)
#cv.imshow('Countours drawn',blank)

blank = np.zeros(img_2.shape, dtype='uint8')   #same size as original image
cv.drawContours(blank, contours_t, -1, (0,0,255), 1)
#cv.imshow('Countours drawn thresh',blank)




resized = cv.resize(img_3, (1100,600), interpolation = cv.INTER_CUBIC)

#cv.imshow('Subtracted', img_3)
cv.imshow('Resized', resized)

cv.waitKey(0)