import cv2 as cv


def rescaleFrame(frame, scale=0.75):       
    width = int(frame.shape[1] * scale)
    height = int(frame.shape[0] * scale )
    dimensions = (width,height)
    return cv.resize(frame, dimensions, interpolation=cv.INTER_AREA)

original_img = cv.imread('Photos/tomioka.jpg')
img = rescaleFrame(original_img)
cv.imshow('Tomioka',img)


#RELEVANT SECTIONS


#1. Converting to grayscale
#converting a bgr image to a gray scale image
grey = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
#cv.imshow('Grey image', grey)

#2. bluring an image, can remove extra noise
#kernal size, must be an ordinal number
blur=cv.GaussianBlur(img, (3,3), cv.BORDER_DEFAULT)
#more blurred, increase kernel size
blur2=cv.GaussianBlur(img, (7,7), cv.BORDER_DEFAULT)
#cv.imshow('Blur image', blur)
#cv.imshow('Blur image 2', blur2)

#3. Edge Cascade
#finding edges that are present in the image
#threshold values
canny = cv.Canny(img, 125, 175)
#cv.imshow('Canny edges', canny)

#reduce edges
canny_blur = cv.Canny(blur, 125,175)
#cv.imshow('Canny blur edges', canny_blur)


#4. Dilating the image using the canny edges
#structuring element (canny), kernel size, iterations
dilated = cv.dilate(canny, (3,3), iterations=1)
#increase
dilated2 = cv.dilate(canny, (7,7), iterations=3)
#cv.imshow('Dilated', dilated2)

#5. Eroding, get back to orignal image
eroded = cv.erode(dilated, (3,3), iterations=1)
eroded2 = cv.erode(dilated2, (7,7), iterations=3)
#cv.imshow('Eroded image', eroded2)

#6. Resize
#resizes the image to 500 by 500, ignoring the aspect ratio

#dimension, interpolation in background
#INTER_AREA for areas smaller than normal image
#INTER_LINEAR or INTER_CUBIC for areas larger than original, cubic is slower but looks better than linear
resize = cv.resize(img, (500,500), interpolation=cv.INTER_AREA)
#cv.imshow("Resized", resize)

#7. Cropping
cropped = img[50:200, 200:400]
#cv.imshow('Cropped', cropped)

cv.waitKey(0)
