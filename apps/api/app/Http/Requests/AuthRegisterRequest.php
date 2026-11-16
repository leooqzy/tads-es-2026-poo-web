<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AuthRegisterRequest extends FormRequest
{
    protected function prepareForValidation(): void
    {
        foreach (['phone', 'cpf'] as $field) {
            $value = $this->input($field);

            if ($value !== null) {
                $this->merge([
                    $field => preg_replace('/\D/', '', (string) $value),
                ]);
            }
        }
    }

    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => [
                'required',
                'string',
                'max:255',
            ],

            'email' => [
                'required',
                'email',
                'max:255',
                'unique:users,email',
            ],

            'password' => [
                'required',
                'string',
                'min:8',
                'confirmed',
            ],

            'role' => [
                'required',
                Rule::in(['seller', 'buyer']),
            ],

            'phone' => [
                'required_if:role,seller',
                'nullable',
                'string',
                'regex:/^\d{10,11}$/',
            ],

            'cpf' => [
                'required_if:role,seller',
                'nullable',
                'string',
                'digits:11',
                function ($attribute, $value, $fail) {
                    if (
                        $value !== null &&
                        $value !== '' &&
                        !self::isValidCpf($value)
                    ) {
                        $fail('Informe um CPF válido.');
                    }
                },
            ],
        ];
    }

    private static function isValidCpf(string $cpf): bool
    {
        if (
            strlen($cpf) !== 11 ||
            preg_match('/^(\d)\1{10}$/', $cpf)
        ) {
            return false;
        }

        for ($position = 9; $position < 11; $position++) {
            $sum = 0;

            for ($i = 0; $i < $position; $i++) {
                $sum += (int) $cpf[$i] * ($position + 1 - $i);
            }

            $digit = ($sum * 10) % 11;

            if ($digit === 10) {
                $digit = 0;
            }

            if ((int) $cpf[$position] !== $digit) {
                return false;
            }
        }

        return true;
    }
}
