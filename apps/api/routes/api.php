<?php

use App\Http\Controllers\AdminDashboardController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReviewController;
use Illuminate\Support\Facades\Route;

Route::post('auth/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    // Operações de consulta disponíveis para usuários autenticados.
    Route::apiResource('products', ProductController::class)
        ->only(['index', 'show']);

    Route::apiResource('categories', CategoryController::class)
        ->only(['index', 'show']);

    // Operações exclusivas dos administradores.
    Route::middleware('admin')->group(function () {

        Route::apiResource('products', ProductController::class)
            ->only(['store', 'update', 'destroy']);

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