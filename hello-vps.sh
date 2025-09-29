echo "Hello!"
apt install make

cp .setup/.env.config.example .setup/.env.config
chmod +x .setup/scripts/*.sh
chmod +x .setup/scripts/*/*.sh
make deps

echo "================"
echo ""
echo "You can now start to setup your project by running :"
echo ""
echo "1) Edit .setup/.env.config"
echo "2) Use command: make user"
echo "3) Use command: make setup-prod"
echo ""
echo "Don't forget to configure your domain's DNS before running make setup-prod"