echo "Hello!"
apt install make

chmod +x .setup/scripts/*.sh
chmod +x .setup/scripts/*/*.sh

echo "================"
echo ""
echo "You can now start to setup your project by running :"
echo ""
echo "1) make deps"
echo "2) create your own .env.config file by copying .env.config.example in .setup/"
echo "2) make user"
echo "3) make setup-prod"
echo ""
echo "Don't forget to configure your domain's DNS before running make setup-prod"