<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class UploadController extends Controller
{
    public function upload(Request $request): array
    {
        $path = $request->file('file')->store('uploads');

        return ['path' => $path];
    }
}