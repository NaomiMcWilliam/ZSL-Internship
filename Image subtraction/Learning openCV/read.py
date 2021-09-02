import cv2 as cv

# reads in the image
#img = cv.imread('Photos/rei.jpg')

#does not fit on screen
#img = cv.imread('Photos/cat_large.jpg')

# displays the image as a window
# name of window and image to display
#cv.imshow('Cat', img)

#Reading Videos
capture=cv.VideoCapture('Videos/dog.mp4')

while True:
    isTrue, frame = capture.read()          #reads in the video frame by frame, returns frame and boolean that says whether it was successfully read in
    cv.imshow('Video', frame)               #display that frame

    if cv.waitKey(20) & 0xFF==ord('d'):     #if letter d is pressed then stop video
        break

capture.release()                           #release capture
cv.destroyAllWindows()

# waits for a time in ms for a key to be pressed
cv.waitKey(0)
