import cv2 as cv
import numpy as np

img=cv.imread('Photos/rei.jpg')


cv.imshow('Rei', img)

#1. Translation
def translate(image, x, y):
    #positive x -> right
    #negative x -> left
    #positive y -> down
    #negative y -> up

    #translating matrix
    transMat = np.float32([[1,0,x], [0,1,y]])

    #width, height
    dimensions = (img.shape[1], img.shape[0])

    return cv.warpAffine(img, transMat, dimensions)

#right 100 pixels, down 100 pixels
translated_img = translate(img, 100,100)
#cv.imshow('Translated', translated_img)


#2. Rotation
def rotate(img, angle, rotPoint=None):
    (height, width) = img.shape[:2]

    #rotate around centre
    if rotPoint is None:
        rotPoint = (width//2, height//2)

    rotMat = cv.getRotationMatrix2D(rotPoint, angle, 1.0)
    dimensions = (width, height)

    return cv.warpAffine(img, rotMat, dimensions)

#rotate image by 45 degrees anticlockwise
rotated = rotate(img, 45) 
#rotate clockwise by 45 degrees
rotated2 = rotate(rotated, -45) 
#cv.imshow('Rotated', rotated2)   

#3. Resizing
resized = cv.resize(img, (500,300), interpolation = cv.INTER_CUBIC)
#cv.imshow('Resized', resized)

#4. Flipping
#flip code:
#0 -> flipping image vertically
#1 -> flipping image horizontally
#-1 -> flipping image horizontally and vertically
flip = cv.flip(img, 1)
#cv.imshow('Flipped', flip)

#5. Cropping
#shows a grey bit next to it
cropped = img[200:400, 200:300]
cv.imshow('Cropped', cropped)



cv.waitKey(0)