<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ExpenseCategory extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'icon',
        'description',
        'is_custom',
    ];

    protected $casts = [
        'is_custom' => 'boolean',
    ];

    public function suddenExpenses(): HasMany
    {
        return $this->hasMany(SuddenExpense::class);
    }

    public static function defaultCategories(): array
    {
        return [
            ['name' => 'Akomodasi', 'slug' => 'accommodation', 'icon' => 'hotel', 'description' => 'Hotel, villa, homestay, hostel, camping'],
            ['name' => 'Transportasi', 'slug' => 'transportation', 'icon' => 'directions_car', 'description' => 'Pesawat, kereta, sewa motor, ojek online'],
            ['name' => 'Konsumsi', 'slug' => 'food_and_beverage', 'icon' => 'restaurant', 'description' => 'Makan, jajan, air minum'],
            ['name' => 'Atraksi & Hiburan', 'slug' => 'attractions', 'icon' => 'attractions', 'description' => 'Tiket wisata, wahana, tur lokal'],
            ['name' => 'Itinerary', 'slug' => 'itinerary', 'icon' => 'schedule', 'description' => 'Jadwal atau rencana kegiatan'],
            ['name' => 'Komunikasi & Dokumen', 'slug' => 'communication', 'icon' => 'phone', 'description' => 'Paket data, paspor, visa, asuransi'],
            ['name' => 'Lainnya', 'slug' => 'others', 'icon' => 'more_horiz', 'description' => 'Pengeluaran lainnya'],
        ];
    }
}