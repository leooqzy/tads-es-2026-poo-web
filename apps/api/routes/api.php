<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ReviewController;
use Illuminate\Support\Facades\Route;

// Registrar a rota de login
Route::post('login', [AuthController::class, 'login']);

// Mover rotas da aplicação (CRUD) para um grupo protegido
Route::group([
    'middleware' => [
        'auth:sanctum'],
    ], function() {
Route::apiResource('categories', CategoryController::class);
Route::apiResource('customers', CustomerController::class);
Route::apiResource('reviews', ReviewController::class);
Route::apiResource('orders', OrderController::class);
    });