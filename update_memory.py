import RPi.GPIO as GPIO
import time


GPIO.setmode(GPIO.BOARD)

a0 =  8
a1 = 10
a2 = 12
a3 = 16
a4 = 18
a5 = 22
a6 = 24
a7 = 26
a8 = 32
a9 = 36
a10 = 38
a11 = 40
a12 = 3
a13 = 5
a14 = 7

r1 = 11
g1 = 13
b1 = 15

interrupt = 19

GPIO.setup(a0, GPIO.OUT)
GPIO.setup(a1, GPIO.OUT)
GPIO.setup(a2, GPIO.OUT)
GPIO.setup(a3, GPIO.OUT)
GPIO.setup(a4, GPIO.OUT)
GPIO.setup(a5, GPIO.OUT)
GPIO.setup(a6, GPIO.OUT)
GPIO.setup(a7, GPIO.OUT)
GPIO.setup(a8, GPIO.OUT)
GPIO.setup(a9, GPIO.OUT)
GPIO.setup(a10, GPIO.OUT)
GPIO.setup(a11, GPIO.OUT)
GPIO.setup(a12, GPIO.OUT)
GPIO.setup(a13, GPIO.OUT)
GPIO.setup(a14, GPIO.OUT)

GPIO.setup(r1, GPIO.OUT)
GPIO.setup(g1, GPIO.OUT)
GPIO.setup(b1, GPIO.OUT)

GPIO.setup(interrupt, GPIO.OUT)



GPIO.output(interrupt, 0)


for i in range(30000):
    v = '{0:015b}'.format(i)

    GPIO.output(a0, int(v[14]))
    GPIO.output(a1, int(v[13]))
    GPIO.output(a2, int(v[12]))
    GPIO.output(a3, int(v[11]))
    GPIO.output(a4, int(v[10]))
    GPIO.output(a5, int(v[9]))
    GPIO.output(a6, int(v[8]))
    GPIO.output(a7, int(v[7]))
    GPIO.output(a8, int(v[6]))
    GPIO.output(a9, int(v[5]))
    GPIO.output(a10, int(v[4]))
    GPIO.output(a11, int(v[3]))
    GPIO.output(a12, int(v[2]))
    GPIO.output(a13, int(v[1]))
    GPIO.output(a14, int(v[0]))

    if (i % 2 == 0):
        GPIO.output(r1, 0)
        GPIO.output(g1, 0)
        GPIO.output(b1, 1)
    else:
        GPIO.output(r1, 0)
        GPIO.output(g1, 0)
        GPIO.output(b1, 0)

    GPIO.output(interrupt, 1)
    time.sleep(0.00000005);
    GPIO.output(interrupt, 0)


