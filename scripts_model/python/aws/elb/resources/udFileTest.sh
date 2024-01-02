echo "Arquivo de Teste"
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get install -y nano curl wget

sudo apt-get install nginx -y
sudo systemctl start nginx