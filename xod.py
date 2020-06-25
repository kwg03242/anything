
from tkinter import *
from PIL import Image
from PIL import ImageTk
import webbrowser
import os
import time
import serial
import time
import winsound
import threading
import datetime
import multiprocessing
#os.chdir("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들")
app = Tk()


app.title("")

canvas = Canvas(app,width = 1000,height = 1000)



#-----------------------------------------------------Initialization of Objects

BUTTON1 = ""
BUTTON2 = ""
BUTTON3 = ""
BUTTON4 = ""
BUTTON_BodyParts1 = ""
BUTTON_BodyParts2 = ""
BUTTON_BodyParts3 = ""
BUTTON_BodyParts4 = ""
BUTTON_BodyPartsreturn = ""

BUTTON_getVideoreturn = ""

BUTTON_getVideo1 = ""
BUTTON_getVideo2 = ""
BUTTON_GasmUndong1=""
BUTTON_GasmUndong2=""
BUTTON_GasmUndong3=""
BUTTON_GasmUndong4=""
BUTTON_HacheUndong1=""
BUTTON_HacheUndong2=""
BUTTON_HacheUndong3=""
BUTTON_BokGeunUndong1 = ""
BUTTON_BokGeunUndong2 = ""
BUTTON_BokGeunUndong3 = ""
BUTTON_BokGeunUndong4 = ""
BUTTON_PalUndong1 = ""
BUTTON_PalUndong2 = ""
BUTTON_PalUndong3 = ""
BUTTON_PalUndong4 = ""
BUTTON_ReturnfromGasmUndongtogotoBodyParts = ""
BUTTON_StartBalance=""
BUTTON_BodyPartsreturnIMAGE=""
Gasm1vid = Gasm2vid = Gasm3vid = Gasm4vid = ""
Pal1vid = Pal2vid = Pal3vid = Pal4vid = ""
BalanceErrorText = ""
BalanceFinishFlag = 0
x=y=z=w=""
Dietapp=""
xx=""
firstLabel = Label(app,text = "메인메뉴",font=("Times New Roman",30,))
#firstLabel.place(x=400,y=0)
#----------------------------------------------------Image Global
def play_sound():
    winsound.Beep(600,100)
def Finish_Balance():
    global BalanceFinishFlag
    global BUTTON_
    global BUTTON_StartBalance
    global BUTTON_FinishBalance
    BalanceFinishFlag = 1
    BUTTON_FinishBalance.destroy()
    BUTTON_StartBalance = Button(app,text="균형조절 시작",height =2, width = 30,command = Balance_ready)
    BUTTON_StartBalance.place(x=100,y=100)





def Balance():
    global BUTTON_StartBalance
    global BalanceThread
    global BalanceFinishFlag
    global BUTTON_FinishBalance
    global flag
    global BalanceErrorText
    BUTTON_StartBalance.destroy()


    BUTTON_FinishBalance = Button(app,text="끝내기",width=30,height=2,command = Finish_Balance)
    BUTTON_FinishBalance.place(x=100,y=100)

    cnt = 0
    ThrArray = [0]*1000000
    arduino=serial.Serial('COM15', 9600)

    ypr=[0,0,0]
    start=False
    flag=0

    while(True):
        if BalanceFinishFlag==1:
            break

        a=arduino.readline()
        a=a.decode()
        print(a,end="")
        #print("the a is {}",a[0])
        #print(len(a))
        #print("currentcnt %d",cnt)




        if len(a)>15:
            ThrArray[cnt] = threading.Thread(target=play_sound)
            ThrArray[cnt].start()
            cnt += 1
         #   print("currentcnt %d",cnt,end="")
            if flag==0:
                BalanceErrorText = Label(app,text="응아니야")
                BalanceErrorText.place(x=750,y=500)
                flag=1


        else:
            if flag==1:
                BalanceErrorText.destroy()
                flag = 0

def Balance_ready():
    BalanceThread = threading.Thread(target=Balance)
    BalanceThread.start()


def ImagePreProcess():
    LIST = ['My Fitness Coach','가슴','덤벨프레스','덤벨플라이','마이페이지','벤치프레스','식단관리','운동시작','자세촬영','팔어깨','푸시업','하체']
    CropConstWidth=[0,330,0,0,230,0,330,330,330,0,0,0,]
    CropConstHeight = [0]*len(LIST)





    for i in range(len(LIST)):
        tt = LIST[i]

        BUTTON1IMAE = Image.open(tt+".jpg")
        #BUTTON1IMAE.show()
        w,h = BUTTON1IMAE.size
        cropconst = CropConstWidth[i]
        cropconsth = CropConstHeight[i]
        BUTTON1IMAEcrop = BUTTON1IMAE.crop((cropconst,0,w-cropconst,h))
        BUTTON1IMAEcrop.resize((300,300))

        BUTTON1IMAEcrop.save(tt+".gif")
#---------------------------------------------------- Videoopen Func.
def Gasm1():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\푸시업.mp4")
def Gasm2():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\벤치프레스.mp4")
def Gasm3():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\덤벨프레스.mp4")
def Gasm4():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\덤벨 플라이.mp4")
def Pal1():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\숄더 프레스.mp4")
def Pal2():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\바벨컬.mp4")
def Pal3():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\덤벨컬.mp4")

def Pal4():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\덤벨킥백.mp4")
def Bok1():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\윗몸일으키기.mp4")
def Bok2():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\V업.mp4")
def Bok3():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\마운틴 클라이머.mp4")
def Bok4():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\플랭크.mp4")
def Hache1():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\스쿼트.mp4")
def Hache2():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\런지.mp4")
def Hache3():
    webbrowser.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\동영상 파일들\\데드리프트.mp4")

#-----------------------------------------------------뒤로가기 버튼


def returntomain():

    global BUTTON_BodyParts1,BUTTON_BodyParts2,BUTTON_BodyParts3,BUTTON_BodyParts4
    global BUTTON1,BUTTON2,BUTTON3,BUTTON4
    global BUTTON_BodyPartsreturn
    global BUTTON1IMAGE,BUTTON2IMAGE,BUTTON3IMAGE,BUTTON4IMAGE
    BUTTON_BodyParts1.destroy()
    BUTTON_BodyParts2.destroy()
    BUTTON_BodyParts3.destroy()
    BUTTON_BodyParts4.destroy()
    BUTTON_BodyPartsreturn.destroy()

    BUTTON1IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\운동정보.gif")
    BUTTON1IMAGE = BUTTON1IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON1IMAGE = ImageTk.PhotoImage(BUTTON1IMAGE)

    BUTTON1 = Button(app,image=BUTTON1IMAGE,width = 355,height=355,text="싣",command = gotoBodyParts)#,image=BUTTON1IMAGE,height=400,width=350




    #BUTTON1.pack()
    BUTTON1.place(x=100,y=50)

    BUTTON2IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\식단관리.gif")
    BUTTON2IMAGE = BUTTON2IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON2IMAGE = ImageTk.PhotoImage(BUTTON2IMAGE)

    BUTTON2 = Button(app,text = "식단관리",image = BUTTON2IMAGE,height = 355, width = 355,command=gotoDiet)

    BUTTON2.place(x=500,y=50)

    BUTTON3IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\운동시작.gif")
    BUTTON3IMAGE = BUTTON3IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON3IMAGE = ImageTk.PhotoImage(BUTTON3IMAGE)

    BUTTON3 = Button(app,text = "자세 촬영",image = BUTTON3IMAGE,height = 355, width = 355,command=gotogetVideo)

    BUTTON3.place(x=100,y=500)

    BUTTON4IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\마이페이지.gif")
    BUTTON4IMAGE = BUTTON4IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON4IMAGE = ImageTk.PhotoImage(BUTTON4IMAGE)

    BUTTON4 = Button(app,text = "마이페이지",image = BUTTON4IMAGE,height = 355, width = 355,command=gotoMypage)


    BUTTON4.place(x=500,y=500)
def returnfromDiettomain():
    global BUTTON1,BUTTON2,BUTTON3,BUTTON4
    global BUTTON_BodyPartsreturn
    global BUTTON1IMAGE,BUTTON2IMAGE,BUTTON3IMAGE,BUTTON4IMAGE

    BUTTON_BodyPartsreturn.destroy()
    canvas.delete(ALL)



    BUTTON1IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\운동시작.gif")
    BUTTON1IMAGE = BUTTON1IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON1IMAGE = ImageTk.PhotoImage(BUTTON1IMAGE)

    BUTTON1 = Button(app,image=BUTTON1IMAGE,width = 355,height=355,text="싣",command = gotoBodyParts)#,image=BUTTON1IMAGE,height=400,width=350




    #BUTTON1.pack()
    BUTTON1.place(x=100,y=50)

    BUTTON2IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\식단관리.gif")
    BUTTON2IMAGE = BUTTON2IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON2IMAGE = ImageTk.PhotoImage(BUTTON2IMAGE)

    BUTTON2 = Button(app,text = "식단관리",image = BUTTON2IMAGE,height = 355, width = 355,command=gotoDiet)

    BUTTON2.place(x=500,y=50)

    BUTTON3IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\자세촬영.gif")
    BUTTON3IMAGE = BUTTON3IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON3IMAGE = ImageTk.PhotoImage(BUTTON3IMAGE)

    BUTTON3 = Button(app,text = "자세 촬영",image = BUTTON3IMAGE,height = 355, width = 355,command=gotogetVideo)

    BUTTON3.place(x=100,y=500)

    BUTTON4IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\마이페이지.gif")
    BUTTON4IMAGE = BUTTON4IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON4IMAGE = ImageTk.PhotoImage(BUTTON4IMAGE)

    BUTTON4 = Button(app,text = "마이페이지",image = BUTTON4IMAGE,height = 355, width = 355,command=gotoMypage)


    BUTTON4.place(x=500,y=500)
def returnfromMypagetomain():
    global BUTTON1,BUTTON2,BUTTON3,BUTTON4
    global BUTTON_BodyPartsreturn
    global BUTTON1IMAGE,BUTTON2IMAGE,BUTTON3IMAGE,BUTTON4IMAGE

    BUTTON_BodyPartsreturn.destroy()

    BUTTON1IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\운동시작.gif")
    BUTTON1IMAGE = BUTTON1IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON1IMAGE = ImageTk.PhotoImage(BUTTON1IMAGE)

    BUTTON1 = Button(app,image=BUTTON1IMAGE,width = 355,height=355,text="싣",command = gotoBodyParts)#,image=BUTTON1IMAGE,height=400,width=350




    #BUTTON1.pack()
    BUTTON1.place(x=100,y=50)

    BUTTON2IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\식단관리.gif")
    BUTTON2IMAGE = BUTTON2IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON2IMAGE = ImageTk.PhotoImage(BUTTON2IMAGE)

    BUTTON2 = Button(app,text = "식단관리",image = BUTTON2IMAGE,height = 355, width = 355,command=gotoDiet)

    BUTTON2.place(x=500,y=50)

    BUTTON3IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\자세촬영.gif")
    BUTTON3IMAGE = BUTTON3IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON3IMAGE = ImageTk.PhotoImage(BUTTON3IMAGE)

    BUTTON3 = Button(app,text = "자세 촬영",image = BUTTON3IMAGE,height = 355, width = 355,command=gotogetVideo)

    BUTTON3.place(x=100,y=500)

    BUTTON4IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\마이페이지.gif")
    BUTTON4IMAGE = BUTTON4IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON4IMAGE = ImageTk.PhotoImage(BUTTON4IMAGE)

    BUTTON4 = Button(app,text = "마이페이지",image = BUTTON4IMAGE,height = 355, width = 355,command=gotoMypage)


    BUTTON4.place(x=500,y=500)
def returnfromgetVideotomain():
    global BUTTON1,BUTTON2,BUTTON3,BUTTON4
    global BUTTON_getVideo1,BUTTON_getVideo2
    global BUTTON_BodyPartsreturn
    global BUTTON_StartBalance
    global BUTTON1IMAGE,BUTTON2IMAGE,BUTTON3IMAGE,BUTTON4IMAGE
    BUTTON_StartBalance.destroy()
    BUTTON_BodyPartsreturn.destroy()
    BUTTON1IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\운동시작.gif")
    BUTTON1IMAGE = BUTTON1IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON1IMAGE = ImageTk.PhotoImage(BUTTON1IMAGE)

    BUTTON1 = Button(app,image=BUTTON1IMAGE,width = 355,height=355,text="싣",command = gotoBodyParts)#,image=BUTTON1IMAGE,height=400,width=350




    #BUTTON1.pack()
    BUTTON1.place(x=100,y=50)

    BUTTON2IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\식단관리.gif")
    BUTTON2IMAGE = BUTTON2IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON2IMAGE = ImageTk.PhotoImage(BUTTON2IMAGE)

    BUTTON2 = Button(app,text = "식단관리",image = BUTTON2IMAGE,height = 355, width = 355,command=gotoDiet)

    BUTTON2.place(x=500,y=50)

    BUTTON3IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\자세촬영.gif")
    BUTTON3IMAGE = BUTTON3IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON3IMAGE = ImageTk.PhotoImage(BUTTON3IMAGE)

    BUTTON3 = Button(app,text = "자세 촬영",image = BUTTON3IMAGE,height = 355, width = 355,command=gotogetVideo)

    BUTTON3.place(x=100,y=500)

    BUTTON4IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\마이페이지.gif")
    BUTTON4IMAGE = BUTTON4IMAGE.resize((355,355),Image.ANTIALIAS)
    BUTTON4IMAGE = ImageTk.PhotoImage(BUTTON4IMAGE)

    BUTTON4 = Button(app,text = "마이페이지",image = BUTTON4IMAGE,height = 355, width = 355,command=gotoMypage)


    BUTTON4.place(x=500,y=500)




def returnfromGasmtoBodyParts():
    global BUTTON_GasmUndong1,BUTTON_GasmUndong2,BUTTON_GasmUndong3,BUTTON_GasmUndong4
    global BUTTON_BodyPartsreturn
    global BUTTON_BodyParts1,BUTTON_BodyParts2,BUTTON_BodyParts3,BUTTON_BodyParts4
    BUTTON_GasmUndong1.destroy()
    BUTTON_GasmUndong2.destroy()
    BUTTON_GasmUndong3.destroy()
    BUTTON_GasmUndong4.destroy()
    BUTTON_BodyPartsreturn.destroy()

    global x,y,z,w

    x = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\가슴.gif")
    x = x.resize((355,355),Image.ANTIALIAS)
    x = ImageTk.PhotoImage(x)
    BUTTON_BodyParts1 = Button(app,image=x,height = 355,width = 355,command=GasmUndong)

    y = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\하체.gif")
    y = y.resize((355,355),Image.ANTIALIAS)
    y = ImageTk.PhotoImage(y)
    BUTTON_BodyParts2 = Button(app,image=y,height = 355, width = 355,command=HacheUndong)

    z = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\복근.gif")
    z = z.resize((355,355),Image.ANTIALIAS)
    z = ImageTk.PhotoImage(z)

    BUTTON_BodyParts3 = Button(app,image=z,height = 355, width = 355,command=BokGeunUndong)

    w = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\팔.어깨.gif")
    w = w.resize((355,355),Image.ANTIALIAS)
    w = ImageTk.PhotoImage(w)

    BUTTON_BodyParts4 = Button(app,image=w,height = 355, width = 355,command=PalUndong)

    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((50,50),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)
    BUTTON_BodyPartsreturn = Button(app,image = BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command=returntomain)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)
    BUTTON_BodyParts1.place(x=100,y = 50)
    BUTTON_BodyParts2.place(x=500,y = 50)
    BUTTON_BodyParts3.place(x=100,y = 500)
    BUTTON_BodyParts4.place(x=500,y = 500)
def returnfromHachetoBodyParts():
    global BUTTON_HacheUndong1,BUTTON_HacheUndong2,BUTTON_HacheUndong3
    global BUTTON_BodyPartsreturn
    global BUTTON_BodyParts1,BUTTON_BodyParts2,BUTTON_BodyParts3,BUTTON_BodyParts4
    BUTTON_HacheUndong1.destroy()
    BUTTON_HacheUndong2.destroy()
    BUTTON_HacheUndong3.destroy()
    BUTTON_BodyPartsreturn.destroy()
    global x,y,z,w

    x = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\가슴.gif")
    x = x.resize((355,355),Image.ANTIALIAS)
    x = ImageTk.PhotoImage(x)
    BUTTON_BodyParts1 = Button(app,image=x,height = 355,width = 355,command=GasmUndong)

    y = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\하체.gif")
    y = y.resize((355,355),Image.ANTIALIAS)
    y = ImageTk.PhotoImage(y)
    BUTTON_BodyParts2 = Button(app,image=y,height = 355, width = 355,command=HacheUndong)

    z = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\복근.gif")
    z = z.resize((355,355),Image.ANTIALIAS)
    z = ImageTk.PhotoImage(z)

    BUTTON_BodyParts3 = Button(app,image=z,height = 355, width = 355,command=BokGeunUndong)

    w = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\팔.어깨.gif")
    w = w.resize((355,355),Image.ANTIALIAS)
    w = ImageTk.PhotoImage(w)

    BUTTON_BodyParts4 = Button(app,image=w,height = 355, width = 355,command=PalUndong)
    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((50,50),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)
    BUTTON_BodyPartsreturn = Button(app,image = BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command=returntomain)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)
    BUTTON_BodyParts1.place(x=100,y = 50)
    BUTTON_BodyParts2.place(x=500,y = 50)
    BUTTON_BodyParts3.place(x=100,y = 500)
    BUTTON_BodyParts4.place(x=500,y = 500)

def returnfromBokGeuntoBodyParts():
    global BUTTON_BokGeunUndong1,BUTTON_BokGeunUndong2,BUTTON_BokGeunUndong3,BUTTON_BokGeunUndong4
    global BUTTON_BodyPartsreturn
    global BUTTON_BodyParts1,BUTTON_BodyParts2,BUTTON_BodyParts3,BUTTON_BodyParts4
    BUTTON_BokGeunUndong1.destroy()
    BUTTON_BokGeunUndong2.destroy()
    BUTTON_BokGeunUndong3.destroy()
    BUTTON_BokGeunUndong4.destroy()
    BUTTON_BodyPartsreturn.destroy()
    global x,y,z,w

    x = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\가슴.gif")
    x = x.resize((355,355),Image.ANTIALIAS)
    x = ImageTk.PhotoImage(x)
    BUTTON_BodyParts1 = Button(app,image=x,height = 355,width = 355,command=GasmUndong)

    y = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\하체.gif")
    y = y.resize((355,355),Image.ANTIALIAS)
    y = ImageTk.PhotoImage(y)
    BUTTON_BodyParts2 = Button(app,image=y,height = 355, width = 355,command=HacheUndong)

    z = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\복근.gif")
    z = z.resize((355,355),Image.ANTIALIAS)
    z = ImageTk.PhotoImage(z)

    BUTTON_BodyParts3 = Button(app,image=z,height = 355, width = 355,command=BokGeunUndong)

    w = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\팔.어깨.gif")
    w = w.resize((355,355),Image.ANTIALIAS)
    w = ImageTk.PhotoImage(w)

    BUTTON_BodyParts4 = Button(app,image=w,height = 355, width = 355,command=PalUndong)
    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((50,50),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)
    BUTTON_BodyPartsreturn = Button(app,image = BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command=returntomain)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)
    BUTTON_BodyParts1.place(x=100,y = 50)
    BUTTON_BodyParts2.place(x=500,y = 50)
    BUTTON_BodyParts3.place(x=100,y = 500)
    BUTTON_BodyParts4.place(x=500,y = 500)
def returnfromPaltoBodyParts():
    global BUTTON_PalUndong1,BUTTON_PalUndong2,BUTTON_PalUndong3,BUTTON_PalUndong4
    global BUTTON_BodyPartsreturn
    global BUTTON_BodyParts1,BUTTON_BodyParts2,BUTTON_BodyParts3,BUTTON_BodyParts4
    BUTTON_PalUndong1.destroy()
    BUTTON_PalUndong2.destroy()
    BUTTON_PalUndong3.destroy()
    BUTTON_PalUndong4.destroy()
    BUTTON_BodyPartsreturn.destroy()

    global x,y,z,w

    x = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\가슴.gif")
    x = x.resize((355,355),Image.ANTIALIAS)
    x = ImageTk.PhotoImage(x)
    BUTTON_BodyParts1 = Button(app,image=x,height = 355,width = 355,command=GasmUndong)

    y = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\하체.gif")
    y = y.resize((355,355),Image.ANTIALIAS)
    y = ImageTk.PhotoImage(y)
    BUTTON_BodyParts2 = Button(app,image=y,height = 355, width = 355,command=HacheUndong)

    z = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\복근.gif")
    z = z.resize((355,355),Image.ANTIALIAS)
    z = ImageTk.PhotoImage(z)

    BUTTON_BodyParts3 = Button(app,image=z,height = 355, width = 355,command=BokGeunUndong)

    w = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\팔.어깨.gif")
    w = w.resize((355,355),Image.ANTIALIAS)
    w = ImageTk.PhotoImage(w)

    BUTTON_BodyParts4 = Button(app,image=w,height = 355, width = 355,command=PalUndong)

    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((50,50),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)
    BUTTON_BodyPartsreturn = Button(app,image = BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command=returntomain)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)
    BUTTON_BodyParts1.place(x=100,y = 50)
    BUTTON_BodyParts2.place(x=500,y = 50)
    BUTTON_BodyParts3.place(x=100,y = 500)
    BUTTON_BodyParts4.place(x=500,y = 500)
def returnfromgetVideotoBodyParts():
    global BUTTON1,BUTTON2,BUTTON3,BUTTON4
    global BUTTON_getVideo1,BUTTON_getVideo2
    global BUTTON_BodyPartsreturn





def openGasm1():
    Gasm1Exp = Toplevel(app,height=500,width=500)
    Gasm1Exp.title("푸시업 운동설명")

    Label(Gasm1Exp,text="▶ 엎드려서 양팔을 어깨너비보다 조금 더 넓게 위치시킨다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Gasm1Exp,text="▶ 팔과 무릎은 곧게 편다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Gasm1Exp,text="▶ 바닥을 밀어주는 느낌으로 팔꿈치를 구부린다.",font=("신명조",12,"bold")).place(x=0,y=40)
    Label(Gasm1Exp,text="TIP. 상체가 일직선이 유지되어야 한다.",font=("신명조",12,"bold")).place(x=0,y=200)

    global Gasm1vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Gasm1vid=Button(Gasm1Exp,image=xx,height=100,width=100,command=Gasm1)
    Gasm1vid.place(x=400,y=400)
def openGasm2():
    Gasm2Exp = Toplevel(app,height=500,width=800)
    Gasm2Exp.title("벤치프레스 운동설명")
    Label(Gasm2Exp,text="▶ 벤치에 누워 엉덩이와 견갑골을 등받이에 붙이고, 허리는 10cm가량 아치형을 만들어준다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Gasm2Exp,text="▶ 어깨너비 두 배로 바를 잡고 눈이 바벨과 수직이 되도록 위치시킨다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Gasm2Exp,text="▶ 바를 들어 가슴 중앙과 바가 수직이 되도록 위치시킨 후 팔꿈치를 살짝 구부려 고정한다.",font=("신명조",12,"bold")).place(x=0,y=40)
    Label(Gasm2Exp,text="▶ 가슴과 바가 자석처럼 서로 만나는 느낌으로 가슴 위쪽 5~10cm까지 저항을 느끼며 바벨을 천천히 당긴다.",font=("신명조",12,"bold")).place(x=0,y=60)
    Label(Gasm2Exp,text="▶ 겨드랑이에 힘을 준다는 느낌으로 바벨을 밀어 올린다.",font=("신명조",12,"bold")).place(x=0,y=80)

    Label(Gasm2Exp,text="TIP. 지나치게 손목을 젖혀서 바를 잡을 경우 손목에 부상을 초래할 수 있고, 무거운 중량을 가슴 부위로 ",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Gasm2Exp,text="지나치게 내리는 경우 어깨 관련 근육이나 회전근개의 손상이 발생할 수 있으므로 주의하도록 한다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Gasm2Exp,text="가슴으로 당기고 올리는 동작을 가급적 느리게 일정한 속도로 실시할 때 대흉근을 가장 효과적으로 자극할 수 있다.",font=("신명조",12,"bold")).place(x=0,y=240)




    global Gasm2vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Gasm2vid=Button(Gasm2Exp,image=xx,height=100,width=100,command=Gasm2)
    Gasm2vid.place(x=700,y=400)
def openGasm3():
    Gasm3Exp = Toplevel(app,height=500,width=800)
    Gasm3Exp.title("덤벨프레스 운동설명")
    Label(Gasm3Exp,text="▶ 벤치에 앉아 팔을 가슴 옆에 붙이고 덤벨을 든다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Gasm3Exp,text="▶ 벤치에 누워 가슴 중앙 부분과 수직이 되게 덤벨을 위치시키면서 팔꿈치를 살짝 구부린다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Gasm3Exp,text="▶ 가슴이 양옆으로 늘어나는 느낌을 느끼면서 덤벨이 가슴과 평행이 될 때까지 당긴다.",font=("신명조",12,"bold")).place(x=0,y=40)
    Label(Gasm3Exp,text="▶ 겨드랑이에 힘을 주면서 가슴을 모아주는 느낌으로 덤벨을 밀어 올린다.",font=("신명조",12,"bold")).place(x=0,y=60)

    Label(Gasm3Exp,text="TIP. ",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Gasm3Exp,text="▶ 덤벨을 내리면서 어깨가 등 뒤로 과도하게 젖혀지면 어깨 주변 근육의 부상 위험이 커질 수 있다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Gasm3Exp,text="▶ 덤벨을 밀어 올리는 동작에서 양손이 벌어지게 않게 살짝 모아줌으로써 대흉근의 수축을 최대화한다.",font=("신명조",12,"bold")).place(x=0,y=240)
    Label(Gasm3Exp,text="▶ 덤벨을 밀어 올릴 때 팔은 모아주되, 덤벨이 부딪히지 않도록 유의한다.",font=("신명조",12,"bold")).place(x=0,y=260)
    Label(Gasm3Exp,text="▶ 덤벨을 당기고 밀어 올릴 때 전완이 양옆으로 벌어지지 않고 수직을 유지하도록 한다.",font=("신명조",12,"bold")).place(x=0,y=280)


    global Gasm3vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Gasm3vid=Button(Gasm3Exp,image=xx,height=100,width=100,command=Gasm3)
    Gasm3vid.place(x=700,y=400)
def openGasm4():
    Gasm4Exp = Toplevel(app,height=500,width=800)
    Gasm4Exp.title("덤벨플라이 운동설명")
    Label(Gasm4Exp,text="▶ 벤치에 앉아 팔을 가슴 옆에 붙이고 덤벨을 든다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Gasm4Exp,text="▶ 벤치에 누워 가슴 중앙과 덤벨이 수직이 되도록 위치시키고 팔꿈치를 살짝 구부려 고정시킨다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Gasm4Exp,text="▶ 어깨관절만을 사용해 반원을 그리며 가슴이 늘어나는 느낌으로 가슴과 평행이 될 때까지 덤벨을 당긴다.",font=("신명조",12,"bold")).place(x=0,y=40)
    Label(Gasm4Exp,text="▶ 겨드랑이에 힘을 준 상태에서 안아주듯이 반원을 그리며 덤벨을 밀어 올린다.",font=("신명조",12,"bold")).place(x=0,y=60)

    Label(Gasm4Exp,text="TIP. 덤벨이 어깨 밑으로 지나치게 내려갈 경우 어깨 주변 근육의 상해를 유발할 수 있다.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Gasm4Exp,text="▶ 팔꿈치의 각도가 너무 굽혀져서도 너무 펴져서도 안 된다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Gasm4Exp,text="▶ 덤벨을 들어올리는 동작에서 양손이 벌어지게 않게 살짝 모아줌으로써 대흉근의 수축을 최대화한다.",font=("신명조",12,"bold")).place(x=0,y=240)



    global Gasm4vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Gasm4vid=Button(Gasm4Exp,image=xx,height=100,width=100,command=Gasm4)
    Gasm4vid.place(x=700,y=400)

def openHache1():
    Hache1Exp = Toplevel(app,height=500,width=800)
    Hache1Exp.title("스쿼트 운동설명")
    Label(Hache1Exp,text="▶ 선 자세에서 어깨너비보다 넓게 바벨을 잡는다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Hache1Exp,text="▶ 바벨을 들어 머리 뒤의 승모근에 위치시킨다.시선은 정면을 향하고 복부에 힘을 주어 허리를 단단히 조여준다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Hache1Exp,text="▶ 무릎이 발끝보다 앞으로 나오지 않도록 하면서 허벅지와 수평이 될 때까지 앉는다.",font=("신명조",12,"bold")).place(x=0,y=40)
    Label(Hache1Exp,text="▶ 발뒤꿈치로 민다는 느낌으로 허벅지에 힘을 주면서 일어선다.",font=("신명조",12,"bold")).place(x=0,y=60)

    Label(Hache1Exp,text="TIP.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Hache1Exp,text="▶ 무릎을 바깥쪽 또는 안쪽으로 굽히지 말고, 일정하게 수평을 이루며 동작을 실시한다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Hache1Exp,text="▶ 배에 힘을 주어 복압을 증가시키면, 보다 강한 힘을 낼 수 있으며, 허리 부상의 위험을 최소화할 수 있다.",font=("신명조",12,"bold")).place(x=0,y=240)



    global Hache1vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Hache1vid=Button(Hache1Exp,image=xx,height=100,width=100,command=Hache1)
    Hache1vid.place(x=700,y=400)
def openHache2():
    Hache2Exp = Toplevel(app,height=500,width=1000)
    Hache2Exp.title("런지 운동설명")
    Label(Hache2Exp,text="▶ 바벨을 어깨너비보다 넓게 잡고 선 다음, 바벨을 들어 승모근에 위치시킨다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Hache2Exp,text="▶ 왼발을 앞으로 70~100cm 정도 벌려 내민다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Hache2Exp,text="▶ 앞으로 내민 왼쪽 다리는 허벅지가 지면과 수평이 될 때까지 구부리고, 뒤의 오른쪽 다리는 무릎이 자연스럽게 바닥을 향하게 한다.",font=("신명조",12,"bold")).place(x=0,y=40)
    Label(Hache2Exp,text="▶ 발뒤꿈치로 민다는 느낌을 주면서 하체의 힘으로 무릎을 다시 펴서 원위치한다. 반대쪽도 같은 방법으로 실시한다.",font=("신명조",12,"bold")).place(x=0,y=60)

    Label(Hache2Exp,text="TIP.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Hache2Exp,text="▶ 등과 허리는 항상 똑바로 편 상태로 실시해야 부상을 방지할 수 있다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Hache2Exp,text="▶ 대둔근 발달에 보다 주안점을 두는 운동이므로 보폭을 넓게 하는 것이 권장된다.",font=("신명조",12,"bold")).place(x=0,y=240)



    global Hache2vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Hache2vid=Button(Hache2Exp,image=xx,height=100,width=100,command=Hache2)
    Hache2vid.place(x=900,y=400)
def openHache3():
    Hache3Exp = Toplevel(app,height=500,width=900)
    Hache3Exp.title("데드리프트 운동설명")
    Label(Hache3Exp,text="▶ 바벨을 들고 양발 사이에 발 하나가 들어갈 정도로 좁게 선다. 어깨가 굽지 않도록 시선을 앞쪽에 두고 가슴을 내밀어 준다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Hache3Exp,text="▶ 등의 각도가 지면과 수평에 가까워질 때까지 상체를 숙인다. 시선은 45도 앞을 바라본다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Hache3Exp,text="▶ 대퇴이두근의 힘을 이용하여 상체를 일으킨다.",font=("신명조",12,"bold")).place(x=0,y=40)
   # Label(Hache1Exp,text="▶ 발뒤꿈치로 민다는 느낌으로 허벅지에 힘을 주면서 일어선다.",font=("신명조",12,"bold")).place(x=0,y=60)

    Label(Hache3Exp,text="TIP.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Hache3Exp,text="▶ 허리는 곧게 펴고 가슴을 앞으로 내밀어 바른 자세를 유지한다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Hache3Exp,text="▶ 머리를 숙이지 않고 시선을 전방을 향하게 하면 허리가 자연스럽게 펴진다.",font=("신명조",12,"bold")).place(x=0,y=240)



    global Hache3vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Hache3vid=Button(Hache3Exp,image=xx,height=100,width=100,command=Hache3)
    Hache3vid.place(x=800,y=400)

def openBok1():
    Bok1Exp = Toplevel(app,height=500,width=800)
    Bok1Exp.title("윗몸일으키기 운동설명")
    Label(Bok1Exp,text="▶ 바닥에 누워 무릎을 구부리고 발이 바닥과 떨어지지 않도록 한다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Bok1Exp,text="▶ 양손을 귀에 대고 복부에 힘을 주면서 고개를 살짝 든다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Bok1Exp,text="▶ 팔꿈치가 무릎에 닿을 정도까지 등을 둥글게 구부리면서 상체를 일으킨다.",font=("신명조",12,"bold")).place(x=0,y=40)
    Label(Bok1Exp,text="▶ 복근에 힘이 풀어지지 않도록 천천히 긴장하면서 원위치한다.",font=("신명조",12,"bold")).place(x=0,y=60)

    Label(Bok1Exp,text="TIP. 복근의 힘이 충분하지 못한 상태에서 실시하게 되면 허리에 통증을 유발할 수 있다.",font=("신명조",12,"bold")).place(x=0,y=200)




    global Bok1vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Bok1vid=Button(Bok1Exp,image=xx,height=100,width=100,command=Bok1)
    Bok1vid.place(x=700,y=400)
def openBok2():
    Bok2Exp = Toplevel(app,height=500,width=900)
    Bok2Exp.title("V업 운동설명")
    Label(Bok2Exp,text="▶ 바닥에 누운 자세에서 무릎을 살짝 구부리고 팔을 가슴 위로 쭉 편다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Bok2Exp,text="▶ 상체와 다리가 V자 모양이 되도록 상체를 일으켜 세우면서 동시에 다리를 들어올린다.이때 팔은 다리와 평행이 되도록 뻗는다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Bok2Exp,text="▶ 등이 바닥과 약 45도에서 60도가 되게 유지한 채로 최고 지점에서 잠시 멈춘다.",font=("신명조",12,"bold")).place(x=0,y=40)
    Label(Bok2Exp,text="▶ 다시 천천히 시작 자세로 돌아온다.",font=("신명조",12,"bold")).place(x=0,y=60)

    Label(Bok2Exp,text="TIP.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Bok2Exp,text="▶ 운동 강도가 다소 높은 복근 운동으로 정확한 자세를 통해 복부에 집중될 수 있도록 한다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Bok2Exp,text="▶ 팔과 다리가 이루는 각도가 작아질수록 운동의 강도가 증가하게 된다.",font=("신명조",12,"bold")).place(x=0,y=240)


    global Bok2vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Bok2vid=Button(Bok2Exp,image=xx,height=100,width=100,command=Bok2)
    Bok2vid.place(x=800,y=400)
def openBok3():
    Bok3Exp = Toplevel(app,height=500,width=800)
    Bok3Exp.title("마운틴 클라이머 운동설명")
    Label(Bok3Exp,text="▶ 엎드린 자세에서 한쪽 발을 가슴쪽으로 끌어당긴다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Bok3Exp,text="▶ 반대편 발을 올림과 동시에 올라와있던 발을 내린다.",font=("신명조",12,"bold")).place(x=0,y=20)

    Label(Bok3Exp,text="TIP.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Bok3Exp,text="▶ 엉덩이가 올라오지 않도록 주의한다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Bok3Exp,text="▶ 유연성이 안좋다면 할수 있는 곳까지 올린다.",font=("신명조",12,"bold")).place(x=0,y=240)

    global Bok3vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Bok3vid=Button(Bok3Exp,image=xx,height=100,width=100,command=Bok3)
    Bok3vid.place(x=700,y=400)
def openBok4():
    Bok4Exp = Toplevel(app,height=500,width=900)
    Bok4Exp.title("플랭크 운동설명")
    Label(Bok4Exp,text="▶ 손목과 팔꿈치를 지면에 고정할 때 어깨 아래 팔꿈치가 수직으로 올 수 있도록 한다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Bok4Exp,text="▶ 발을 앞꿈치만 바닥에 고정 후 바닥을 밀어내는 힘을 이용하여 무릎을 바닥에서 띄어내며 골반과 허벅지를 들어 올린다.",font=("신명조",12,"bold")).place(x=0,y=20)


    Label(Bok4Exp,text="TIP.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Bok4Exp,text="▶ 머리부터 발 끝까지 일직선이 되도록 만든다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Bok4Exp,text="▶ 배꼽을 계속 등 쪽으로 밀어 넣는다고 생각한다.",font=("신명조",12,"bold")).place(x=0,y=240)

    global Bok4vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Bok4vid=Button(Bok4Exp,image=xx,height=100,width=100,command=Bok4)
    Bok4vid.place(x=800,y=400)
def openPal1():
    Pal1Exp = Toplevel(app,height=500,width=900)
    Pal1Exp.title("숄더 프레스 운동설명")
    Label(Pal1Exp,text="▶ 벤치에 앉아 등과 허리를 곧게 편다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Pal1Exp,text="▶ 덤벨이 귀와 수평이 되고 팔꿈치가 직각이 되도록 위치시킨다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Pal1Exp,text="▶ 이두근이 귀에 닿는 느낌으로 덤벨을 머리 위로 들어올린다.",font=("신명조",12,"bold")).place(x=0,y=40)
    Label(Pal1Exp,text="▶ 천천히 저항을 느끼면서 덤벨이 귀와 수평될 때까지 내린다.",font=("신명조",12,"bold")).place(x=0,y=60)


    Label(Pal1Exp,text="TIP.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Pal1Exp,text="▶ 덤벨이 지나치게 몸쪽이나 바깥쪽으로 나가면 주변 근육의 상해의 위험이 있으므로 주의한다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Pal1Exp,text="▶ 덤벨이 서로 부딪히거나 팔꿈치가 완전히 펴지게 되면 목표 근육에 힘을 유지할 수 없게 되므로 주의하여 동작한다.",font=("신명조",12,"bold")).place(x=0,y=240)

    global Pal1vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Pal1vid=Button(Pal1Exp,image=xx,height=100,width=100,command=Pal1)
    Pal1vid.place(x=800,y=400)
def openPal2():
    Pal2Exp = Toplevel(app,height=500,width=900)
    Pal2Exp.title("바벨컬 운동설명")
    Label(Pal2Exp,text="▶ 두 손으로 바벨을 어깨너비로 잡고 다리도 어깨너비만큼 벌리고 선다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Pal2Exp,text="▶ 팔꿈치를 옆구리에 고정시키고, 이두근의 힘을 이용해 바벨을 들어올린다.손의 방향은 삼각근 전면을 향하도록 한다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Pal2Exp,text="▶ 천천히 이두근의 저항을 느끼면서 바벨을 내린다.",font=("신명조",12,"bold")).place(x=0,y=40)


    Label(Pal2Exp,text="TIP.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Pal2Exp,text="▶ 상체와 무릎의 반동을 이용하지 않는다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Pal2Exp,text="▶ 팔꿈치가 앞으로 나가지 않도록 고정시킨다.",font=("신명조",12,"bold")).place(x=0,y=240)
    Label(Pal2Exp,text="▶ 어깨보다 좁게 그립을 잡으면 상완이두근 바깥쪽 근육에 집중할 수 있다.",font=("신명조",12,"bold")).place(x=0,y=260)
    Label(Pal2Exp,text="▶ 어깨보다 넓게 와이드 그립을 잡으면 상완이두근 안쪽 근육에 집중할 수 있다.",font=("신명조",12,"bold")).place(x=0,y=280)

    global Pal2vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Pal2vid=Button(Pal2Exp,image=xx,height=100,width=100,command=Pal2)
    Pal2vid.place(x=800,y=400)
def openPal3():
    Pal3Exp = Toplevel(app,height=500,width=900)
    Pal3Exp.title("덤벨컬 운동설명")
    Label(Pal3Exp,text="▶ 벤치에 앉아 다리는 골반 너비만큼 벌린 후 양손으로 덤벨을 잡고, 손바닥이 앞을 향하도록 한다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Pal3Exp,text="▶ 팔꿈치를 옆구리에 고정시키고 덤벨을 들어올린다.들어올리는 마지막 지점에서 손목이 바깥쪽을 향하도록 한다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Pal3Exp,text="▶ 천천히 이두근의 저항을 느끼며 덤벨을 내린다.",font=("신명조",12,"bold")).place(x=0,y=40)


    Label(Pal3Exp,text="TIP.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Pal3Exp,text="▶ 전완이 지면과 수평을 이루는 시점에서부터 손목을 바깥쪽으로 돌려주는 것이 상완이두근을 더욱 자극시킬 수 있다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Pal3Exp,text="▶ 목표 근육의 수축에 최대한 집중하기 위해 벤치에 앉아서 실시하는 것이 좋다.",font=("신명조",12,"bold")).place(x=0,y=240)


    global Pal3vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Pal3vid=Button(Pal3Exp,image=xx,height=100,width=100,command=Pal3)
    Pal3vid.place(x=800,y=400)
def openPal4():
    Pal4Exp = Toplevel(app,height=500,width=900)
    Pal4Exp.title("덤벨킥백 운동설명")
    Label(Pal4Exp,text="▶ 벤치에 왼쪽 무릎과 왼손을 대고 등을 곧게 펴고 지면과 수평이 되도록 엎드린다.오른쪽 무릎은 살짝 구부려준다.",font=("신명조",12,"bold")).place(x=0,y=0)
    Label(Pal4Exp,text="▶ 오른손으로 덤벨을 잡고 이두근 안쪽을 옆구리에 고정시킨다.",font=("신명조",12,"bold")).place(x=0,y=20)
    Label(Pal4Exp,text="▶ 팔이 지면과 수평을 이룰 때까지 덤벨을 뒤로 들어올린 후 1~2초간 정지한다.",font=("신명조",12,"bold")).place(x=0,y=40)
    Label(Pal4Exp,text="▶ 천천히 저항을 느끼면서 덤벨을 내리며 처음 자세로 돌아온다.반대쪽도 같은 방법으로 실시한다.",font=("신명조",12,"bold")).place(x=0,y=40)



    Label(Pal4Exp,text="TIP.",font=("신명조",12,"bold")).place(x=0,y=200)
    Label(Pal4Exp,text="▶ 등이 지면과 수평에 가깝게 한다. 어깨가 과도하게 등 위로 올라가지 않도록 한다.",font=("신명조",12,"bold")).place(x=0,y=220)
    Label(Pal4Exp,text="▶ 덤벨을 잡은 손이 어깨선과 나란하거나 약간 높은 위치에 있을 때 수축 효과가 더 크다.",font=("신명조",12,"bold")).place(x=0,y=240)



    global Pal4vid
    global xx
    xx = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\영상보기.gif")
    xx = xx.resize((100,100),Image.ANTIALIAS)
    xx = ImageTk.PhotoImage(xx)
    Pal4vid=Button(Pal4Exp,image=xx,height=100,width=100,command=Pal4)
    Pal4vid.place(x=800,y=400)




#----------------------------------------------------tkinter module
def GasmUndong():
    global BUTTON_BodyParts1,BUTTON_BodyParts2,BUTTON_BodyParts3,BUTTON_BodyParts4
    global BUTTON_GasmUndong1,BUTTON_GasmUndong2,BUTTON_GasmUndong3,BUTTON_GasmUndong4
    global BUTTON_ReturnfromGasmUndongtogotoBodyParts,BUTTON_BodyPartsreturn
    BUTTON_BodyParts1.destroy()
    BUTTON_BodyParts2.destroy()
    BUTTON_BodyParts3.destroy()
    BUTTON_BodyParts4.destroy()
    BUTTON_BodyPartsreturn.destroy()
    global x,y,z,w
    x = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\푸시업.gif")
    x = x.resize((710,150),Image.ANTIALIAS)
    x = ImageTk.PhotoImage(x)
    BUTTON_GasmUndong1 = Button(app,image=x,width=710,height=150,command=openGasm1)
    BUTTON_GasmUndong1.place(x=100,y=50)

    y = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\벤치프레스.gif")
    y = y.resize((710,150),Image.ANTIALIAS)
    y = ImageTk.PhotoImage(y)
    BUTTON_GasmUndong2 = Button(app,image=y,width=710,height=150,command=openGasm2)
    BUTTON_GasmUndong2.place(x=100,y=250)

    z = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\덤벨프레스.gif")
    z = z.resize((710,150),Image.ANTIALIAS)
    z = ImageTk.PhotoImage(z)
    BUTTON_GasmUndong3 = Button(app,image=z,width=710,height=150,command=openGasm3)
    BUTTON_GasmUndong3.place(x=100,y=450)

    w = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\덤벨플라이.gif")
    w = w.resize((710,150),Image.ANTIALIAS)
    w = ImageTk.PhotoImage(w)
    BUTTON_GasmUndong4 = Button(app,image =w,width=710,height=150,command=openGasm4)
    BUTTON_GasmUndong4.place(x=100,y=650)

    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((50,50),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)
    BUTTON_BodyPartsreturn = Button(app,image = BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command=returnfromGasmtoBodyParts)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)

def HacheUndong():
    global BUTTON_BodyParts1,BUTTON_BodyParts2,BUTTON_BodyParts3,BUTTON_BodyParts4
    global BUTTON_BodyPartsreturn
    global BUTTON_HacheUndong1,BUTTON_HacheUndong2,BUTTON_HacheUndong3
    BUTTON_BodyParts1.destroy()
    BUTTON_BodyParts2.destroy()
    BUTTON_BodyParts3.destroy()
    BUTTON_BodyParts4.destroy()
    BUTTON_BodyPartsreturn.destroy()

    global x,y,z
    x = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\스쿼트.gif")
    x = x.resize((710,150),Image.ANTIALIAS)
    x = ImageTk.PhotoImage(x)
    BUTTON_HacheUndong1 = Button(app,image=x,width=710,height=150,command=openHache1)
    BUTTON_HacheUndong1.place(x=100,y=50)

    y = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\런지.gif")
    y = y.resize((710,150),Image.ANTIALIAS)
    y = ImageTk.PhotoImage(y)
    BUTTON_HacheUndong2 = Button(app,image=y,width=710,height=150,command=openHache2)
    BUTTON_HacheUndong2.place(x=100,y=250)

    z = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\데드리프트.gif")
    z = z.resize((710,150),Image.ANTIALIAS)
    z = ImageTk.PhotoImage(z)
    BUTTON_HacheUndong3 = Button(app,image=z,width=710,height=150,command=openHache3)
    BUTTON_HacheUndong3.place(x=100,y=450)

    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((50,50),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)
    BUTTON_BodyPartsreturn = Button(app,image = BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command=returnfromHachetoBodyParts)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)
def BokGeunUndong():
    global BUTTON_BodyParts1,BUTTON_BodyParts2,BUTTON_BodyParts3,BUTTON_BodyParts4
    global BUTTON_BodyPartsreturn
    global BUTTON_BokGeunUndong1,BUTTON_BokGeunUndong2,BUTTON_BokGeunUndong3,BUTTON_BokGeunUndong4
    BUTTON_BodyParts1.destroy()
    BUTTON_BodyParts2.destroy()
    BUTTON_BodyParts3.destroy()
    BUTTON_BodyParts4.destroy()
    BUTTON_BodyPartsreturn.destroy()
    global x,y,z,w
    x = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\윗몸일으키기.gif")
    x = x.resize((710,150),Image.ANTIALIAS)
    x = ImageTk.PhotoImage(x)
    BUTTON_BokGeunUndong1 = Button(app,image = x,width=710,height=150,command=openBok1)
    BUTTON_BokGeunUndong1.place(x=100,y=50)

    y = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\V업.gif")
    y = y.resize((710,150),Image.ANTIALIAS)
    y = ImageTk.PhotoImage(y)
    BUTTON_BokGeunUndong2 = Button(app,image = y,width=710,height=150,command=openBok2)
    BUTTON_BokGeunUndong2.place(x=100,y=250)

    z = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\마운틴클라이머.gif")
    z = z.resize((710,150),Image.ANTIALIAS)
    z = ImageTk.PhotoImage(z)
    BUTTON_BokGeunUndong3 = Button(app,image = z,width=710,height=150,command=openBok3)
    BUTTON_BokGeunUndong3.place(x=100,y=450)

    w = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\플랭크.gif")
    w = w.resize((710,150),Image.ANTIALIAS)
    w = ImageTk.PhotoImage(w)
    BUTTON_BokGeunUndong4 = Button(app,image = w,height=150,width=710,command=openBok4)
    BUTTON_BokGeunUndong4.place(x=100,y=650)
    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((50,50),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)
    BUTTON_BodyPartsreturn = Button(app,image = BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command=returnfromBokGeuntoBodyParts)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)
def PalUndong():
    global BUTTON_BodyParts1,BUTTON_BodyParts2,BUTTON_BodyParts3,BUTTON_BodyParts4
    global BUTTON_BodyPartsreturn
    global BUTTON_PalUndong1,BUTTON_PalUndong2,BUTTON_PalUndong3,BUTTON_PalUndong4,BUTTON_PalUndong5
    BUTTON_BodyParts1.destroy()
    BUTTON_BodyParts2.destroy()
    BUTTON_BodyParts3.destroy()
    BUTTON_BodyParts4.destroy()
    BUTTON_BodyPartsreturn.destroy()
    a = 200
    global x,y,z,w

    x = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\숄더프레스.gif")
    x = x.resize((710,150),Image.ANTIALIAS)
    x = ImageTk.PhotoImage(x)
    BUTTON_PalUndong1 = Button(app,image=x,width=710,height=150,command=openPal1)
    BUTTON_PalUndong1.place(x=100,y=50)


    y = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\바벨컬.gif")
    y = y.resize((710,150),Image.ANTIALIAS)
    y = ImageTk.PhotoImage(y)
    BUTTON_PalUndong2 = Button(app,image=y,width=710,height=150,command=openPal2)
    BUTTON_PalUndong2.place(x=100,y=50+a)

    z = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\덤벨컬.gif")
    z = z.resize((710,150),Image.ANTIALIAS)
    z = ImageTk.PhotoImage(z)
    BUTTON_PalUndong3 = Button(app,image=z,width=710,height=150,command=openPal3)
    BUTTON_PalUndong3.place(x=100,y=50+2*a)

    w = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\덤벨킥백.gif")
    w = w.resize((710,150),Image.ANTIALIAS)
    w = ImageTk.PhotoImage(w)
    BUTTON_PalUndong4 = Button(app,image=w,width=710,height=150,command=openPal4)
    BUTTON_PalUndong4.place(x=100,y=50+3*a)

    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((50,50),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)
    BUTTON_BodyPartsreturn = Button(app,image = BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command=returnfromPaltoBodyParts)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)




def gotoBodyParts():

    global BUTTON1,BUTTON2,BUTTON3,BUTTON4
    global BUTTON_BodyParts1,BUTTON_BodyParts2,BUTTON_BodyParts3,BUTTON_BodyParts4
    global BUTTON_BodyPartsreturn
    global canvas


    BUTTON1.destroy()
    BUTTON2.destroy()
    BUTTON3.destroy()
    BUTTON4.destroy()
    global x,y,z,w

    x = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\가슴.gif")
    x = x.resize((355,355),Image.ANTIALIAS)
    x = ImageTk.PhotoImage(x)
    BUTTON_BodyParts1 = Button(app,image=x,height = 355,width = 355,command=GasmUndong)

    y = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\하체.gif")
    y = y.resize((355,355),Image.ANTIALIAS)
    y = ImageTk.PhotoImage(y)
    BUTTON_BodyParts2 = Button(app,image=y,height = 355, width = 355,command=HacheUndong)

    z = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\복근.gif")
    z = z.resize((355,355),Image.ANTIALIAS)
    z = ImageTk.PhotoImage(z)

    BUTTON_BodyParts3 = Button(app,image=z,height = 355, width = 355,command=BokGeunUndong)

    w = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\팔.어깨.gif")
    w = w.resize((355,355),Image.ANTIALIAS)
    w = ImageTk.PhotoImage(w)

    BUTTON_BodyParts4 = Button(app,image=w,height = 355, width = 355,command=PalUndong)

    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((80,80),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)

    BUTTON_BodyPartsreturn = Button(app,image=BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command = returntomain)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)
    BUTTON_BodyParts1.place(x=100,y = 50)
    BUTTON_BodyParts2.place(x=500,y = 50)
    BUTTON_BodyParts3.place(x=100,y = 500)
    BUTTON_BodyParts4.place(x=500,y = 500)


def gotogetVideo():
    global BUTTON1,BUTTON2,BUTTON3,BUTTON4
    global BUTTON_getVideo1,BUTTON_getVideo2
    global BUTTON_BodyPartsreturn
    global BUTTON_StartBalance
    BUTTON1.destroy()
    BUTTON2.destroy()
    BUTTON3.destroy()
    BUTTON4.destroy()

    BUTTON_StartBalance = Button(app,text="균형조절 시작",height =2, width = 30,command = Balance_ready)
    BUTTON_StartBalance.place(x=100,y=100)
    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((50,50),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)
    BUTTON_BodyPartsreturn = Button(app,image = BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command=returnfromgetVideotomain)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)
def openDietURL():
    webbrowser.open("http://www.curveskorea.co.kr/curves-health/calorie-calculator.html")
def openExURL():
    webbrowser.open("http://www.nalthin.com/diet/bmi/bmikcal.htm")
def giveDietoutput():
    global Diet1input,Ex1input
    global Dietapp
    Eatcal = float(Diet1input.get("1.0","end-1c"))
    Neededcal = float(Ex1input.get("1.0","end-1c"))
    x=""
    if Eatcal>Neededcal:
        workout = Eatcal-Neededcal



        Verd = Label(Dietapp,text=str(workout)+"kcal"+" 만큼 운동해야 합니다!!",font=("Times New Roman",50,"bold"))
        Verd.place(Dietapp,x=200,y=600)
    else:

        workout = Eatcal-Neededcal
        Verd = Label(Dietapp,text=str(workout)+"kcal"+" 만큼 운동해야 합니다!!",font=("Times New Roman",50,"bold"))
        Verd.place(Dietapp,x=200,y=600)



def gotoDiet():


    global BUTTON1,BUTTON2,BUTTON3,BUTTON4
    global BUTTON_BodyPartsreturn


    global BUTTON_BodyPartsreturnIMAGE
    Dietapp = Toplevel(app,height=1000,width=1000)
    Dietapp.title("식단관리")


    # make url interface
    global BUTTON_Diet1,BUTTON_Ex1
    global Diet1input,Ex1input
    global BUTTON_Diet1IMAGE,BUTTON_Ex1IMAGE
    BUTTON_Diet1IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\오늘의섭취칼로리알아보기.gif")
    BUTTON_Diet1IMAGE = BUTTON_Diet1IMAGE.resize((380,80),Image.ANTIALIAS)
    BUTTON_Diet1IMAGE = ImageTk.PhotoImage(BUTTON_Diet1IMAGE)
    BUTTON_Diet1 = Button(Dietapp,image=BUTTON_Diet1IMAGE,height = 80,width = 380,command=openDietURL)
    BUTTON_Diet1.place(x=100,y=300)
    Diet1input = Text(Dietapp,height=1,width=8,font=("Times New Roman",50,"bold"))
    Diet1input.place(x=500,y=100)
    Kcaltext = Label(Dietapp,text="kcal",font=("Times New Roman",50,"bold"))
    Kcaltext.place(x=800,y=100)
    Kcaltext2 = Label(Dietapp,text="kcal",font=("Times New Roman",50,"bold"))
    Kcaltext2.place(x=800,y=200)
    Gitext = Label(Dietapp,text="섭취 칼로리:",font=("Times New Roman",50,"bold"))
    Gitext.place(x=100,y=100)
    Hwtext = Label(Dietapp,text="활동 대사량:",font=("Times New Roman",50,"bold"))
    Hwtext.place(x=100,y=200)
    FinishButton = Button(Dietapp,text="입력완료",command=giveDietoutput,width=53,height=5)
    FinishButton.place(x=500,y=500)



    BUTTON_Ex1IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\나의활동대사량알아보기.gif")
    BUTTON_Ex1IMAGE = BUTTON_Ex1IMAGE.resize((380,80),Image.ANTIALIAS)
    BUTTON_Ex1IMAGE = ImageTk.PhotoImage(BUTTON_Ex1IMAGE)


    BUTTON_Ex1 = Button(Dietapp,image=BUTTON_Ex1IMAGE,height=80,width=380,command=openExURL)
    BUTTON_Ex1.place(x=500,y=300)
    Ex1input = Text(Dietapp,height=1,width=8,font=("Times New Roman",50,"bold"))
    Ex1input.place(x=500,y=200)
    D = datetime.datetime.now().date().day
    M = datetime.datetime.now().date().month
    Y = datetime.datetime.now().date().year
    Date = Label(Dietapp,text=str(Y)+"년 "+str(M)+"월 "+str(D)+"일 식단정보",font=("Times New Roman",50,"bold"))
    Date.place(x=100,y=0)







def gotoMypage():
    global BUTTON1,BUTTON2,BUTTON3,BUTTON4
    global BUTTON_BodyPartsreturn
    BUTTON1.destroy()
    BUTTON2.destroy()
    BUTTON3.destroy()
    BUTTON4.destroy()
    global BUTTON_BodyPartsreturnIMAGE
    BUTTON_BodyPartsreturnIMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\뒤로가기.gif")
    BUTTON_BodyPartsreturnIMAGE = BUTTON_BodyPartsreturnIMAGE.resize((50,50),Image.ANTIALIAS)
    BUTTON_BodyPartsreturnIMAGE = ImageTk.PhotoImage(BUTTON_BodyPartsreturnIMAGE)
    BUTTON_BodyPartsreturn = Button(app,image = BUTTON_BodyPartsreturnIMAGE,height = 50,width = 50,command=returnfromMypagetomain)
    BUTTON_BodyPartsreturn.place(x = 0,y=0)





#------------------------------------------------------Main Function
#ImagePreProcess()

BUTTON1IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\운동정보.gif")
BUTTON1IMAGE = BUTTON1IMAGE.resize((355,355),Image.ANTIALIAS)
BUTTON1IMAGE = ImageTk.PhotoImage(BUTTON1IMAGE)

BUTTON1 = Button(app,image=BUTTON1IMAGE,width = 355,height=355,text="싣",command = gotoBodyParts)#,image=BUTTON1IMAGE,height=400,width=350




#BUTTON1.pack()
BUTTON1.place(x=100,y=20)

BUTTON2IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\식단관리.gif")
BUTTON2IMAGE = BUTTON2IMAGE.resize((355,355),Image.ANTIALIAS)
BUTTON2IMAGE = ImageTk.PhotoImage(BUTTON2IMAGE)

BUTTON2 = Button(app,text = "식단관리",image = BUTTON2IMAGE,height = 355, width = 355,command=gotoDiet)

BUTTON2.place(x=500,y=20)

BUTTON3IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\운동시작.gif")
BUTTON3IMAGE = BUTTON3IMAGE.resize((355,355),Image.ANTIALIAS)
BUTTON3IMAGE = ImageTk.PhotoImage(BUTTON3IMAGE)

BUTTON3 = Button(app,text = "자세 촬영",image = BUTTON3IMAGE,height = 355, width = 355,command=gotogetVideo)

BUTTON3.place(x=100,y=420)

BUTTON4IMAGE = Image.open("C:\\Users\\user\\Desktop\\서울대학교 2019년 여름학기\\창의설계축전\\이미지 파일들\\마이페이지.gif")
BUTTON4IMAGE = BUTTON4IMAGE.resize((355,355),Image.ANTIALIAS)
BUTTON4IMAGE = ImageTk.PhotoImage(BUTTON4IMAGE)

BUTTON4 = Button(app,text = "마이페이지",image = BUTTON4IMAGE,height = 355, width = 355,command=gotoMypage)


BUTTON4.place(x=500,y=420)
#1canvas.create_rectangle(0,0,1000,1000,fill="white")

canvas.pack()
app.mainloop()

#FITT



