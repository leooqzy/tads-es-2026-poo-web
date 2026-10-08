<?php

namespace App\Http\Controllers;

use App\Http\Requests\AuthLoginRequest;
use App\Models\User;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(AuthLoginRequest $request)
    {
        // Obtém os dados informados pelo usuário na tentativa de login
        $email = $request->validated('email');
        $password = $request->validated('password');

        // Tenta carregar o usuário pelo email
        $user = User::firstWhere('email', $email);

        if (
            // Se houver usuário, tenta validar a senha informada
            $user &&
            Hash::check($password, $user->password)
        ) {
            // Se tudo OK, registra o token de acesso do mesmo
            $token = $user->createToken($user->name);

            // Retorna o token de acesso e os dados do usuário
            return [
                'token' => $token->plainTextToken,
                'user' => $user,
            ];
        }

        // Caso contrário, retorna erro de credenciais (login ou senha)
        return response()->json([
            'message' => 'Credenciais inválidas',
        ], Response::HTTP_UNAUTHORIZED);
    }
}