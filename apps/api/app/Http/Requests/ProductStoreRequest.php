<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProductStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id' => [
                'nullable',
                'integer',
                'exists:categories,id',
            ],
            'name' => [
                'required',
                'string',
                'max:255',
            ],
            'description' => [
                'nullable',
                'string',
            ],
            'image_account' => [
                'required',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],
            'image_inventory' => [
                'required',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],
            'price' => [
                'required',
                'numeric',
                'min:0.01',
            ],
            'stock' => [
                'sometimes',
                'integer',
                'min:0',
            ],
            'position' => [
                'sometimes',
                'integer',
                'min:0',
            ],
            'enabled' => [
                'sometimes',
                'boolean',
            ],
        ];
    }
}
