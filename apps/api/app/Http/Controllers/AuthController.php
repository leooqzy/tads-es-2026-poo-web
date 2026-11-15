<?php

namespace App\Http\Controllers;

use App\Http\Requests\AuthLoginRequest;
use App\Http\Requests\AuthRegisterRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(AuthRegisterRequest $request): JsonResponse
    {
        $data = $request->validated();

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
        ]);

        // O perfil é definido separadamente do preenchimento em massa.
        $user->role = $data['role'];
        $user->save();

        $token = $user->createToken($user->name)->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
        ], 201);
    }

    public function login(AuthLoginRequest $request)
    {
        $email = $request->validated('email');
        $password = $request->validated('password');

        $user = User::firstWhere('email', $email);

        if ($user && Hash::check($password, $user->password)) {
            $token = $user->createToken($user->name);

            return [
                'token' => $token->plainTextToken,
                'user' => $user,
            ];
        }

        return response()->json([
            'message' => 'Credenciais inválidas',
        ], Response::HTTP_UNAUTHORIZED);
    }
}