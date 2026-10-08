clear
./vendor/bin/pest
clear
exit
exit
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan make:seed UserSeeder
php artisan make:request AuthLoginRequest
php artisan make:controller AuthController
php artisan route:list
docker-compose ps
docker compose exec mysql mysql -u app_user -p
php artisan make:seeder UserSeeder
php artisan db:seed
docker compose exec php php artisan tinker
exit
php artisan route:list
docker compose exerc php php artisan route:clear
docker compose exec php php artisan route:clear
docker compose exec php php artisan route:clear
docker compose exec php php artisan route:clear
docker compose exec php php artisan config:clear
docker compose exec php php artisan cache:clear
php artisan route:clear
php artisan config:clear
php artisan cache:clear
exit
php artisan route:list
exit
