echo "Hello!"
apt install make

chmod +x .setup/scripts/*.sh
chmod +x .setup/scripts/*/*.sh

echo "================"
echo "You can now start to setup your project by running make setup-user"
echo "Don't forget to configure your domain's DNS before running make setup-prod"