import cv2 as cv
import matplotlib.pyplot as plt



img = cv.imread('Photos/rei.jpg')
cv.imshow('rei', img)

#matplot lib does not know it is a BGR , displays as an RGB
#plt.imshow(img)
#plt.show()

#BGR to grayscale
gray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
#cv.imshow('Gray', gray)


#BGR to HSV
hsv = cv.cvtColor(img, cv.COLOR_BGR2HSV)
#cv.imshow('HSV', hsv)

#BGR to LAB or L*a*b
lab = cv.cvtColor(img, cv.COLOR_BGR2LAB)
#cv.imshow('LAB', lab) 

#BGR TO RGB
#open cv, shows as BGR as it assumes it is BGR
rgb = cv.cvtColor(img, cv.COLOR_BGR2RGB)
cv.imshow('RGB', rgb)

 
#matplotlib shows as RGB, correct as we converted to an RGB
plt.imshow(rgb)
plt.show()

cv.waitKey(0)