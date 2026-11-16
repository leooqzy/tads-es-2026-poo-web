<?php

namespace App\Http\Controllers;

use App\Http\Requests\AuthLoginRequest;
use App\Http\Requests\AuthRegisterRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(AuthRegisterRequest $request): JsonResponse
    {
        $data = $request->validated();

        $cpfHash = null;

        if ($data['role'] === 'seller') {
            $cpfHash = hash_hmac(
                'sha256',
                $data['cpf'],
                (string) config('app.key')
            );

            if (User::where('cpf_hash', $cpfHash)->exists()) {
                throw ValidationException::withMessages([
                    'cpf' => 'Este CPF já está cadastrado.',
                ]);
            }
        }

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
        ]);

        // Perfil definido exclusivamente pelo back-end.
        $user->role = $data['role'];

        if ($data['role'] === 'seller') {
            $user->phone = $data['phone'];
            $user->cpf = $data['cpf'];
            $user->cpf_hash = $cpfHash;
        }

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
