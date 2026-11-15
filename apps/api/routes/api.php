<?php

use App\Http\Controllers\AdminDashboardController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReviewController;
use Illuminate\Support\Facades\Route;

// Autenticação pública
Route::post('auth/register', [AuthController::class, 'register']);
Route::post('auth/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    // Área de anunciantes e administradores
    // A rota mine precisa vir antes de products/{product}.
    Route::middleware('seller-or-admin')->group(function () {

        Route::get('products/mine', [ProductController::class, 'mine']);

        Route::apiResource('products', ProductController::class)
            ->only(['store', 'update', 'destroy']);
    });

    // Consulta de produtos e categorias
    Route::apiResource('products', ProductController::class)
        ->only(['index', 'show']);

    Route::apiResource('categories', CategoryController::class)
        ->only(['index', 'show']);

    // Administração exclusiva
    Route::middleware('admin')->group(function () {

        Route::apiResource('categories', CategoryController::class)
            ->only(['store', 'update', 'destroy']);

        Route::apiResource('customers', CustomerController::class);

        Route::apiResource('orders', OrderController::class);

        Route::apiResource('reviews', ReviewController::class);

        Route::get(
            'admin/dashboard',
            [AdminDashboardController::class, 'index']
        );
    });
});