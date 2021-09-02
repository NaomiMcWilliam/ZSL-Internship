import cv2 as cv

# reads in the image
img = cv.imread('Photos/rei.jpg')

# displays the image as a window
# name of window and image to display
cv.imshow('Cat', img)

# waits for a time in ms for a key to be pressed
cv.waitKey(0)
