import cv2 as cv

#takes in a frame, and scales the frame default is 0.75
#works for images, videos, live video
def rescaleFrame(frame, scale=0.75):       
    width = int(frame.shape[1] * scale)
    height = int(frame.shape[0] * scale )
    dimensions = (width,height)
    return cv.resize(frame, dimensions, interpolation=cv.INTER_AREA)

#only works for live videos
def changeRes(width,height):    
    capture.set(3,width)        #3 is width, 4 is height, 10 is brightness
    capture.set(4,height)       

#images
img = cv.imread('Photos/rei.jpg')
resized_image = rescaleFrame(img)
cv.imshow('Image', resized_image)

#Videos
capture=cv.VideoCapture('Videos/dog.mp4')

while True:
    isTrue, frame = capture.read()          #reads in the video frame by frame, returns frame and boolean that says whether it was successfully read in

    frame_resized = rescaleFrame(frame, scale=.2)

    cv.imshow('Video', frame)               #display that frame
    cv.imshow('Video Resized', frame_resized)

    if cv.waitKey(20) & 0xFF==ord('d'):     #if letter d is pressed then stop video
        break

capture.release()                           #release capture
cv.destroyAllWindows()

# waits for a time in ms for a key to be pressed
cv.waitKey(0)
