#!/bin/bash
 
  echo "content-type: text/html"
  echo
  echo
  echo "<!DOCTYPE html>"
  echo "<html lang="pt-br"> <head> <title> Login </title> <style> p{color: white;} body{background-color: green;}  a{text-decoration: none;} </style> <link rel="shortcut icon" href="192.168.0.128:20000/imgs/favicon1.ico" type="image/x-icon"> <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"> <meta http-equiv="Pragma" content="no-cache"> <meta http-equiv="Expires" content="0"> </head>"
  echo "<body>"
 
  VAR=$(sed -n '1p')
  
  usuario=$(echo $VAR | sed 's/\(usuario=\)\(.*\)\(\&senha=.*\)/\2/;s/+/ /g')
  senha=$(echo $VAR | sed 's/.*\&senha=//')

  grep "^$usuario:$senha$" usuarios.txt >/dev/null

  if [ $? -eq 0 ]; then
    sudo iptables -t mangle -A PREROUTING -s $REMOTE_ADDR -j MARK --set-mark 0x1
    echo "sudo iptables -t mangle -D PREROUTING -s $REMOTE_ADDR -j MARK --set-mark 0x1" | sudo at now +2 minute  
    echo "<h1 style='color:blue;'> Acesso a internet liberado </h1>"
    echo "<a href="$HTTP_REFERER"><p> Volte para o site (aperte F5 para recarregar a página) </p></a>"
  else 
    echo "<h1 style='color:red;'>Usuário e senha inválido</h1>"
    echo "<a href="http://192.168.0.128:20000"><p> Voltar para página de login </p></a>"
  fi

  

  echo "</body>"
  echo "</html>"
  
