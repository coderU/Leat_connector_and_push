#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <iostream>
#include <fstream>
#include <strings.h>
#include <stdlib.h>
#include <string>
#include <vector>
#include <pthread.h>
using namespace std;

void *task1(void *);

static int connFd;

void split_string(const string& str, const string& delim, vector<string>& output)
{
  size_t start = 0, found = str.find_first_of(delim);

  while (found != string::npos)
    {
      if (found > start)
	output.push_back( str.substr(start, found - start) );

      start = ++found;
      found = str.find_first_of(delim, found);
    }
  if (start < str.size())
    output.push_back( str.substr(start) );
}

int main(int argc, char* argv[])
{
  int pId, portNo, listenFd;
  socklen_t len; //store size of the address
  bool loop = false;
  struct sockaddr_in svrAdd, clntAdd;
    
  pthread_t threadA[3];
    
  if (argc < 2)
    {
      cerr << "Syntam : ./server <port>" << endl;
      return 0;
    }
    
  portNo = atoi(argv[1]);
    
  if((portNo > 65535) || (portNo < 2000))
    {
      cerr << "Please enter a port number between 2000 - 65535" << endl;
      return 0;
    }
    
  portNo = 8888;
  //create socket
  listenFd = socket(AF_INET, SOCK_STREAM, 0);
    
  if(listenFd < 0)
    {
      cerr << "Cannot open socket" << endl;
      return 0;
    }
    
  bzero((char*) &svrAdd, sizeof(svrAdd));
    
  svrAdd.sin_family = AF_INET;
  svrAdd.sin_addr.s_addr = INADDR_ANY;
  svrAdd.sin_port = htons(portNo);
    
  //bind socket
  if(bind(listenFd, (struct sockaddr *)&svrAdd, sizeof(svrAdd)) < 0)
    {
      cerr << "Cannot bind" << endl;
      return 0;
    }
    
  listen(listenFd, 5);
    
  len = sizeof(clntAdd);
  pid_t pid;
  while(1){
    connFd = accept(listenFd, (struct sockaddr *)&clntAdd, &len);
    
    
    if (connFd < 0)
      {
	cerr << "Cannot accept connection" << endl;
	return 0;
      }
    else
      {
	cout << "Connection successful" << endl;
      }
    char buf[256];
    bzero(buf,256);
    int n = read( connFd,buf,255 );
    if( n > 0){
      printf("Incoming Message: %s\n", buf);
    }
    
    vector<string> tokens; // sub-strings stored here
    split_string(string(buf), " ", tokens);
    
    if(tokens.size() >2 )
      close(connFd);
    string phone = tokens.at(0);
    string xmpppasswd = tokens.at(1);
    
    char* argv[6];
    argv[0] = (char*)"ejabberdctl";
    argv[1] = (char*)"register";
    argv[2] = (char*)(phone.c_str());
    argv[3] = (char*)"localhost";
    argv[4] = (char*)(xmpppasswd.c_str());
    argv[5] = NULL;
    
    //for( int i = 0 ; i < 5 ;i ++)
    //cout<<"Running command: "<<argv[i]<<endl;
    
    pid = fork();
    if(pid == 0)
      execvp(argv[0], argv);


    write(connFd,"Ok",3);
    close(connFd);
  }
}


