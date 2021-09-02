import cv2 as cv
import numpy as np


img = cv.imread('Photos/rei.jpg')
#cv.imshow('Rei', img)



#convert to greyscale
grey = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
cv.imshow('Grey', grey)


#METHOD 1 


canny = cv.Canny(img, 125, 175)
cv.imshow('Canny edges', canny)

#finding contours of the image
    #contours is python list of all contours found in image
    #hierarchies are the hierarchial representation of contours, how opencv finds contours

    #structure
        #canny edges

    #
        #TREE -> all the hierarchial contours, the ones in a hierarchial system
        #EXTERNAL -> external contours, ones on outside
        #LIST -> all contours in image

    #contour approx method
        #CHAIN_APPROX_NONE -> returns all contours
        #CHAIN_APPROX_SIMPLE -> compresses all contours into simple ones that make more sense
                #e.g. a line can be represented by just the 2 endpoins in SIMPLE, NONE would give lots of points in the line

contours, hierarchies = cv.findContours(canny, cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE)
print(f'{len(contours)} contour(s) found!')   #2053 contours

contours2, hierarchies2 = cv.findContours(canny, cv.RETR_LIST, cv.CHAIN_APPROX_NONE)
print(f'{len(contours2)} contour(s) found!')   #2053 contours, same so there was not much compression in SIMPLE

#blur first
blur = cv.GaussianBlur(grey, (5,5), cv.BORDER_DEFAULT)
#cv.imshow('Blur', blur)
canny_blur = cv.Canny(blur, 125, 175)
cv.imshow('Canny blur',canny_blur)
contours_blur, hierarchies_blur = cv.findContours(canny_blur, cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE)
print(f'{len(contours_blur)} contour(s) found!')   #60 contours, reduction in contours



#METHOD 2

#threshold looks at an image and tries to binarise the image 
#if a pixel intensity below 125, set to black (0),   if it is above 125 it is set to white (255)
ret, thresh = cv.threshold(grey, 125,255, cv.THRESH_BINARY)
cv.imshow('Thresh', thresh)
contours_t , hierarchies_t = cv.findContours(thresh, cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE)
print(f'{len(contours_t)} contour(s) found!')   #563 contours



#drawing in contours
blank = np.zeros(img.shape, dtype='uint8')   #same size as original image

#image to draw over, contours (a list), contour index (how many contours to have in image, -1 is all), colour, thickness
cv.drawContours(blank, contours, -1, (0,0,255), 1)
cv.imshow('Countours drawn',blank)

blank = np.zeros(img.shape, dtype='uint8')   #same size as original image
cv.drawContours(blank, contours_t, -1, (0,0,255), 1)
cv.imshow('Countours drawn thresh',blank)

cv.waitKey(0)