# Task A1: Setup Laravel Project with Sanctum

**Files:**
- Create: `backend/` (Laravel project directory)
- Modify: `backend/.env`
- Modify: `backend/app/Models/User.php`
- Modify: `backend/routes/api.php`
- Create: `backend/app/Http/Controllers/Api/AuthController.php`
- Create: `backend/app/Http/Requests/RegisterRequest.php`
- Create: `backend/app/Http/Requests/LoginRequest.php`

**Interfaces:**
- Produces: API endpoints `/api/register`, `/api/login`, `/api/logout`, `/api/user`

---

**Step 1: Create Laravel project**

Run in PowerShell (from `c:\xampp\htdocs\DNTrip`):
```powershell
composer create-project laravel/laravel backend "^10.0"
```

Expected: Laravel project created in `backend/` directory

---

**Step 2: Install Sanctum**

Run in PowerShell (from `c:\xampp\htdocs\DNTrip\backend`):
```powershell
composer require laravel/sanctum "^3.3"
```

Expected: Sanctum installed successfully

---

**Step 3: Publish Sanctum migrations**

Run:
```powershell
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

Expected: Migrations published to `database/migrations/`

---

**Step 4: Configure .env**

Edit `backend/.env`:
```env
APP_NAME=DNTrip
APP_ENV=local
APP_KEY=base64:GENERATED_KEY_HERE
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=dntrip
DB_USERNAME=root
DB_PASSWORD=

SANCTUM_STATEFUL_DOMAINS=localhost:8000
```

Run to generate APP_KEY:
```powershell
php artisan key:generate
```

---

**Step 5: Update User model with HasApiTokens**

Edit `backend/app/Models/User.php`:
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];
}
```

---

**Step 6: Create RegisterRequest validation**

Create `backend/app/Http/Requests/RegisterRequest.php`:
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Name is required',
            'name.min' => 'Name must be at least 2 characters',
            'email.required' => 'Email is required',
            'email.email' => 'Invalid email format',
            'email.unique' => 'Email has already been taken',
            'password.required' => 'Password is required',
            'password.min' => 'Password must be at least 8 characters',
            'password.confirmed' => 'Password confirmation does not match',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'status' => 'error',
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
        ], 422));
    }
}
```

---

**Step 7: Create LoginRequest validation**

Create `backend/app/Http/Requests/LoginRequest.php`:
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.required' => 'Email is required',
            'email.email' => 'Invalid email format',
            'password.required' => 'Password is required',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'status' => 'error',
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
        ], 422));
    }
}
```

---

**Step 8: Create AuthController**

Create `backend/app/Http/Controllers/Api/AuthController.php`:
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => $request->password, // Auto-hashed by $casts in model
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'created_at' => $user->created_at->toISOString(),
                ],
                'token' => $token,
            ],
            'message' => 'Registration successful',
        ], 201);
    }

    /**
     * Login user
     */
    public function login(LoginRequest $request): JsonResponse
    {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid credentials',
            ], 401);
        }

        $user = User::where('email', $request->email)->firstOrFail();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'created_at' => $user->created_at->toISOString(),
                ],
                'token' => $token,
            ],
            'message' => 'Login successful',
        ]);
    }

    /**
     * Logout user (revoke token)
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logged out successfully',
        ]);
    }

    /**
     * Get current user
     */
    public function user(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'created_at' => $user->created_at->toISOString(),
                ],
            ],
        ]);
    }
}
```

---

**Step 9: Define API routes**

Edit `backend/routes/api.php`:
```php
<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
});
```

---

**Step 10: Run migrations**

Run:
```powershell
php artisan migrate
```

Expected: Users and personal_access_tokens tables created

---

**Step 11: Test API endpoints**

Test with curl or Postman:

```powershell
# Test register
Invoke-RestMethod -Method Post -Uri "http://localhost:8000/api/register" `
  -ContentType "application/json" `
  -Body '{"name":"Test User","email":"test@example.com","password":"password123","password_confirmation":"password123"}'

# Test login
Invoke-RestMethod -Method Post -Uri "http://localhost:8000/api/login" `
  -ContentType "application/json" `
  -Body '{"email":"test@example.com","password":"password123"}'

# Test user (with token)
$token = "PASTE_TOKEN_HERE"
Invoke-RestMethod -Method Get -Uri "http://localhost:8000/api/user" `
  -Headers @{ "Authorization" = "Bearer $token" }
```

Expected: Valid JSON responses as per spec
