import socket

HOST = '192.168.43.11'
PORT = 9009

def getfile():
    data_transferred = 0
    filename="video.h264"
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.connect((HOST,PORT))
        sock.sendall(filename.encode())

        data = sock.recv(1024)
        if not data:
            print('파일[%s]: 서버에 존재하지 않거나 전송중 오류발생' %filename)
            return
        with open(filename, 'wb') as f:
            try:
                while  data:
                    f.write(data)
                    data_transferred += len(data)
                    data = sock.recv(1024)
            except Exception as e:
                print(e)

    print('파일[%s] 전송종료. 전송량 [%d]' %(filename, data_transferred))

#filename = input('다운로드 받은 파일이름을 입력하세요:')
#getFileFromServer('video.h264')
