import socket

HOST = '192.168.43.11'
PORT = 9009

def start():
    data_transferred = 0

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.connect((HOST,PORT))
        sock.sendall("start".encode())
    #print('파일[%s] 전송종료. 전송량 [%d]' %(filename, data_transferred))

#filename = input('다운로드 받은 파일이름을 입력하세요:')
start()
